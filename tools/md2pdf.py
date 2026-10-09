#!/usr/bin/env python
"""Turn one chapter of the book into a PDF, with markdown-it-py and Chromium.

    uv run tools/md2pdf.py docs/capitulo-01-la-primera-hora/index.md \
        -o docs/capitulo-01-la-primera-hora/capitulo-01-la-primera-hora.pdf

It renders the same Markdown the site renders, through the same pipeline of
extensions (admonitions, footnotes, attributes, tables, typographic quotes) and
with the same SWISH links: `tools/swish_links.py` is what puts those in, and
this calls it, so the PDF and the site never disagree. The links stay clickable
in the PDF.

Chromium comes from Playwright, installed by `make browser`.
"""

import argparse
import base64
import html
import re
import sys
from pathlib import Path

import katex_pdf
import swish_links
import vendor
from markdown.extensions.toc import slugify, unique
from markdown_it import MarkdownIt
from mdit_py_plugins.admon import admon_plugin
from mdit_py_plugins.attrs import attrs_plugin
from mdit_py_plugins.deflist import deflist_plugin
from mdit_py_plugins.dollarmath import dollarmath_plugin
from mdit_py_plugins.footnote import footnote_plugin
from playwright.sync_api import TimeoutError as PlaywrightTimeout
from playwright.sync_api import sync_playwright
from pygments import highlight
from pygments.formatters import HtmlFormatter
from pygments.lexers import get_lexer_by_name, guess_lexer

STYLE = Path(__file__).resolve().parent / 'pdf-style.css'


def highlighted(code, language):
    try:
        lexer = get_lexer_by_name(language) if language else guess_lexer(code)
    except Exception:  # noqa: BLE001
        return f'<pre><code>{code}</code></pre>'
    coloured = highlight(code, lexer, HtmlFormatter(nowrap=True))
    return f'<pre><code class="highlight">{coloured}</code></pre>'


# A `|` inside an inline code span, on a table row, is written `\|` in the
# source, as GFM requires; markdown-it reads that escape natively, so nothing is
# added here. The site and the decks remove the backslash themselves
# (tools/tabla_pipes.py, tools/tabla_pipes.lua).


MKDOCS = (swish_links.examples.ROOT / 'mkdocs.yml').read_text(encoding='utf-8')
SITE_URL = re.search(r'^site_url:\s*(\S+)', MKDOCS, re.M).group(1)


def chapter_pages(source):
    """The pages of the chapter whose index.md is `source`, in the order of the nav.

    A long chapter moves some sections out of index.md into pages of their own,
    which the nav lists after «Soluciones». They are part of the chapter, so its
    PDF carries them after index.md. The solutions page has its own PDF, and any
    other source is a PDF of one page.
    """
    if source.name != 'index.md':
        return [source]
    docs = swish_links.examples.DOCS.resolve()
    folder = source.resolve().parent.relative_to(docs).as_posix() + '/'
    nav = MKDOCS[MKDOCS.index('\nnav:') :]
    entries = re.findall(r'^\s*-\s(?:.*\s)?"?(\S+?\.md)"?\s*$', nav, re.M)
    extra = [e for e in entries if e.startswith(folder) and e[len(folder) :] not in ('index.md', 'soluciones.md')]
    return [source] + [docs / e for e in extra]


def site_links(body, source, inside=None, anchors=frozenset()):
    """Send the links between chapters and sections to the published site.

    A PDF holds one chapter, so `../capitulo-02-.../index.md#28-...` leads
    nowhere inside it. It becomes the absolute URL of the same page and anchor
    on the site, which is where the reader can follow it. Links that already
    point outside are left alone.

    `inside` maps each page this PDF holds to the prefix its ids carry and the
    id of its first heading, and `anchors` is every id of the PDF: a link to one
    of those pages whose anchor is there stays inside the PDF, and one without
    an anchor goes to the page's first heading. Any other link goes to the site,
    so none is left dead.
    """
    docs = swish_links.examples.DOCS
    inside = inside or {}

    def page_url(page):
        relative = page.resolve().relative_to(docs.resolve()).as_posix()
        # MkDocs publishes docs/x/index.md at /x/ and docs/x/y.md at /x/y/.
        relative = relative[: -len('index.md')] if relative.endswith('index.md') else relative[:-3] + '/'
        return SITE_URL + relative

    def published_file(path, original):
        """The site URL of a file other than a page, such as generated HTML."""
        try:
            return f'href="{SITE_URL}{path.resolve().relative_to(docs.resolve()).as_posix()}"'
        except ValueError:  # outside docs/: the site does not publish it
            return original

    def fix(match):
        href = match.group(1)
        path, _, fragment = href.partition('#')
        if path == '':
            page = source
        elif '://' in path or path.startswith('mailto:'):
            return match.group(0)
        elif path.endswith('.md'):
            page = source.parent / path
        else:
            return published_file(source.parent / path, match.group(0))
        if page.resolve() in inside:
            prefix, top = inside[page.resolve()]
            target = prefix + fragment if fragment else top
            if target in anchors:
                return f'href="#{target}"'
        try:
            url = page_url(page)
        except ValueError:  # outside docs/: not a page of the site
            return match.group(0)
        return f'href="{url}#{fragment}"' if fragment else f'href="{url}"'

    return re.sub(r'href="([^"]*)"', fix, body)


MIME = {'.svg': 'image/svg+xml', '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.gif': 'image/gif'}


def embed_images(body, source):
    """Put each local image inside the HTML itself, as a data: URI.

    The page is handed to Chromium as a string, so a relative `src` has no
    directory to resolve against. Embedding the bytes sidesteps that, and keeps
    the PDF a single file with nothing to fetch.
    """

    def fix(match):
        src = match.group(1)
        image = source.parent / src
        mime = MIME.get(image.suffix.lower())
        if '://' in src or mime is None or not image.exists():
            return match.group(0)
        return f'src="data:{mime};base64,{base64.b64encode(image.read_bytes()).decode("ascii")}"'

    return re.sub(r'src="([^"]*)"', fix, body)


def heading_ids(state):
    """Give each heading the id the site gives it, so links to its anchors work.

    Python-Markdown's toc extension names the anchors on the site, and its own
    slugify and unique compute them here from the heading's text.
    """
    used = set()
    for heading, inline in zip(state.tokens, state.tokens[1:], strict=False):
        if heading.type == 'heading_open':
            text = ''.join(
                child.content if child.type in ('text', 'code_inline') else ' '
                for child in inline.children or []
                if child.type in ('text', 'code_inline', 'softbreak')
            )
            heading.attrSet('id', unique(slugify(text, '-'), used))


def to_html(text):
    """The Markdown of a chapter, as the body of an HTML document."""
    md = MarkdownIt('commonmark', {'html': True, 'typographer': True})
    md.enable('table')
    # commonmark ships the typographic rules off. The site turns them on through
    # the smarty extension, so the PDF turns them on here and both agree.
    md.enable(['replacements', 'smartquotes'])
    md.use(admon_plugin).use(attrs_plugin).use(deflist_plugin).use(footnote_plugin)
    md.core.ruler.push('heading_ids', heading_ids)
    # $…$ and $$…$$ become the same \(…\) and \[…\] that arithmatex emits on
    # the site, so one KaTeX configuration serves both. The plugin also keeps
    # the contents away from the Markdown parser, which would otherwise read the
    # underscore of a predicate name as the start of emphasis.
    md.use(dollarmath_plugin, double_inline=True)

    def math_inline(tokens, idx, options, env):  # noqa: ARG001
        return r'\(' + html.escape(tokens[idx].content) + r'\)'

    def math_block(tokens, idx, options, env):  # noqa: ARG001
        return '<p class="formula">' + r'\[' + html.escape(tokens[idx].content) + r'\]' + '</p>\n'

    md.renderer.rules['math_inline'] = math_inline
    md.renderer.rules['math_block'] = math_block
    md.renderer.rules['math_inline_double'] = math_block

    def fence(tokens, idx, options, env):  # noqa: ARG001
        token = tokens[idx]
        language = token.info.strip() if token.info else ''
        if language == 'mermaid':
            # Left for the browser to draw, exactly as the site leaves it.
            return f'<pre class="mermaid">{html.escape(token.content)}</pre>'
        return highlighted(token.content, language)

    md.renderer.rules['fence'] = fence
    return md.render(text)


# Mermaid is vendored, the same file the site serves. The page that becomes the PDF
# is built with `set_content()` and has no base URL, so the script is inlined, and
# only when the page actually has a diagram.
MERMAID = vendor.library_directory('mermaid') / 'mermaid.min.js'
DRAWN = "() => !document.querySelector('pre.mermaid:not([data-processed])')"


def has_diagrams(body):
    return 'class="mermaid"' in body


def document(body, css):
    mermaid = ''
    if has_diagrams(body):
        mermaid = (
            f'<script>{MERMAID.read_text(encoding="utf-8")}</script>\n'
            "<script>mermaid.initialize({startOnLoad: true, theme: 'neutral', "
            'flowchart: {wrappingWidth: 280}});</script>'
        )
    katex = katex_pdf.TAGS if katex_pdf.has_formulas(body) else ''
    return '\n'.join(
        [
            '<!DOCTYPE html>',
            '<html lang="es">',
            '<head>',
            '<meta charset="utf-8">',
            '<style>',
            css,
            HtmlFormatter().get_style_defs('.highlight'),
            '</style>',
            mermaid,
            katex,
            '</head>',
            '<body>',
            body,
            '</body>',
            '</html>',
        ]
    )


def to_pdf(html_text, output):
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch()
        page = browser.new_page()
        page.set_content(html_text, wait_until='networkidle')
        if has_diagrams(html_text):
            # Nothing is printed until every diagram has been drawn, or the PDF
            # would carry the source of the diagram instead of the diagram.
            try:
                page.wait_for_function(DRAWN, timeout=30000)
            except PlaywrightTimeout:
                browser.close()
                raise SystemExit(
                    f'the mermaid diagrams were not drawn in 30 seconds ({MERMAID.parent.name}, vendored)'
                ) from None
        if katex_pdf.has_formulas(html_text):
            # A formula left untypeset would print as its LaTeX source.
            try:
                page.wait_for_function(katex_pdf.TYPESET, timeout=30000)
            except PlaywrightTimeout:
                browser.close()
                raise SystemExit(
                    f'KaTeX did not typeset the formulas in 30 seconds ({katex_pdf.DIR.name}, vendored)'
                ) from None
        page.pdf(
            path=output,
            format='A4',
            print_background=True,
            margin={'top': '2.5cm', 'bottom': '2.5cm', 'left': '2cm', 'right': '2cm'},
        )
        browser.close()


ID = re.compile(r'\bid="([^"]*)"')


def page_html(page, prefix):
    """One page as HTML, with `prefix` in front of each of its ids."""
    text = page.read_text(encoding='utf-8')
    # The same links the site gets, from the same place, including each
    # marker's own `consulta:` when it has one.
    text = swish_links.examples.MARKER.sub(
        lambda m: (
            m.group(0)
            + swish_links.footer(m.group('file'), swish_links.examples.marker_parts(m.group('piece'))['consulta'])
        ),
        text,
    )
    return ID.sub(lambda m: f'id="{prefix}{m.group(1)}"', to_html(text))


def chapter_body(source):
    """The body of the PDF: `source` and, after it, the other pages of its chapter.

    Each page is rendered on its own, as the site renders it, and the next one
    starts on a new sheet because it opens with its own h1. The ids of each page
    other than the first get the page's name in front, `odbc--la-base-en-sqlite`,
    so that two pages may share a heading or a footnote number; a link between
    them is then a link inside the PDF.
    """
    pages = chapter_pages(source.resolve())
    missing = [page for page in pages if not page.exists()]
    if missing:
        raise SystemExit(f'mkdocs.yml lists pages that do not exist: {", ".join(map(str, missing))}')
    prefixes = {page: '' if page == pages[0] else page.stem + '--' for page in pages}
    bodies = {page: page_html(page, prefixes[page]) for page in pages}
    anchors = {anchor for body in bodies.values() for anchor in ID.findall(body)}
    inside = {}
    for page, body in bodies.items():
        heading = re.search(r'<h[1-6][^>]*\bid="([^"]*)"', body)
        inside[page] = (prefixes[page], heading.group(1) if heading else None)
    return '\n'.join(embed_images(site_links(body, page, inside, anchors), page) for page, body in bodies.items())


def main():
    parser = argparse.ArgumentParser(description='Turn one chapter into a PDF')
    parser.add_argument('input', help='the chapter Markdown file')
    parser.add_argument('--css', default=str(STYLE), help='stylesheet (default: tools/pdf-style.css)')
    parser.add_argument('-o', '--output', help='the PDF to write (default: the input, with .pdf)')
    args = parser.parse_args()

    source = Path(args.input)
    if not source.exists():
        print(f'There is no {source}', file=sys.stderr)
        return 1
    css = Path(args.css)
    output = args.output or str(source.with_suffix('.pdf'))
    body = chapter_body(source)
    to_pdf(document(body, css.read_text(encoding='utf-8') if css.exists() else ''), output)
    print(f'PDF written: {output}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
