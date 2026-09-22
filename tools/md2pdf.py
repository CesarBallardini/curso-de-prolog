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
import html
import re
import sys
from pathlib import Path

import katex_pdf
import swish_links
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


# A `|` inside an inline code span, on a table row, is read by markdown-it as a
# cell separator: the row is split and its last cell is dropped. Python-Markdown,
# which renders the site, is lenient and keeps the span whole — so the site looks
# right while the PDF is mangled. Escaping it in the source is not an option: the
# site would then print the backslash. The escape is added here instead, for the
# PDF alone, which is the renderer that needs it.
#
# It matters for the rows that teach `[Primero|Resto]` and `'[|]'`, where the
# pipe is the subject and cannot be reworded away.
ROW = re.compile(r'^[ \t]*\|.*$', re.M)
CODE_SPAN = re.compile(r'`[^`\n]*`')


def escape_pipes_in_table_code(text):
    """Escape the `|` of an inline code span when it sits on a table row."""

    def row(match):
        return CODE_SPAN.sub(lambda span: span.group(0).replace('|', r'\|'), match.group(0))

    return ROW.sub(row, text)


def to_html(text):
    """The Markdown of a chapter, as the body of an HTML document."""
    text = escape_pipes_in_table_code(text)
    md = MarkdownIt('commonmark', {'html': True, 'typographer': True})
    md.enable('table')
    # commonmark ships the typographic rules off. The site turns them on through
    # the smarty extension, so the PDF turns them on here and both agree.
    md.enable(['replacements', 'smartquotes'])
    md.use(admon_plugin).use(attrs_plugin).use(deflist_plugin).use(footnote_plugin)
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


# Mermaid is fetched from a CDN rather than vendored: the alternative is three
# megabytes of JavaScript in the repository for the few chapters that draw a
# diagram. It only runs when a page actually has one.
MERMAID = 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js'
DRAWN = "() => !document.querySelector('pre.mermaid:not([data-processed])')"


def has_diagrams(body):
    return 'class="mermaid"' in body


def document(body, css):
    mermaid = ''
    if has_diagrams(body):
        mermaid = (
            f'<script src="{MERMAID}"></script>\n'
            "<script>mermaid.initialize({startOnLoad: true, theme: 'neutral'});</script>"
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
                    f'the mermaid diagrams were not drawn in 30 seconds: check that {MERMAID} can be reached'
                ) from None
        if katex_pdf.has_formulas(html_text):
            # A formula left untypeset would print as its LaTeX source.
            try:
                page.wait_for_function(katex_pdf.TYPESET, timeout=30000)
            except PlaywrightTimeout:
                browser.close()
                raise SystemExit(
                    f'KaTeX did not typeset the formulas in 30 seconds: check that {katex_pdf.BASE} can be reached'
                ) from None
        page.pdf(
            path=output,
            format='A4',
            print_background=True,
            margin={'top': '2.5cm', 'bottom': '2.5cm', 'left': '2cm', 'right': '2cm'},
        )
        browser.close()


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
    text = source.read_text(encoding='utf-8')
    # The same links the site gets, from the same place, including each
    # marker's own `consulta:` when it has one.
    text = swish_links.examples.MARKER.sub(
        lambda m: (
            m.group(0)
            + swish_links.footer(m.group('file'), swish_links.examples.marker_parts(m.group('piece'))['consulta'])
        ),
        text,
    )
    output = args.output or str(source.with_suffix('.pdf'))
    to_pdf(document(to_html(text), css.read_text(encoding='utf-8') if css.exists() else ''), output)
    print(f'PDF written: {output}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
