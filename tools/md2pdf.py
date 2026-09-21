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
import sys
from pathlib import Path

import swish_links
from markdown_it import MarkdownIt
from mdit_py_plugins.admon import admon_plugin
from mdit_py_plugins.attrs import attrs_plugin
from mdit_py_plugins.deflist import deflist_plugin
from mdit_py_plugins.footnote import footnote_plugin
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


def to_html(text):
    """The Markdown of a chapter, as the body of an HTML document."""
    md = MarkdownIt('commonmark', {'html': True, 'typographer': True})
    md.enable('table')
    # commonmark ships the typographic rules off. The site turns them on through
    # the smarty extension, so the PDF turns them on here and both agree.
    md.enable(['replacements', 'smartquotes'])
    md.use(admon_plugin).use(attrs_plugin).use(deflist_plugin).use(footnote_plugin)

    def fence(tokens, idx, options, env):  # noqa: ARG001
        token = tokens[idx]
        return highlighted(token.content, token.info.strip() if token.info else '')

    md.renderer.rules['fence'] = fence
    return md.render(text)


def document(body, css):
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
            '</head>',
            '<body>',
            body,
            '</body>',
            '</html>',
        ]
    )


def to_pdf(html, output):
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch()
        page = browser.new_page()
        page.set_content(html, wait_until='networkidle')
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
    # The same links the site gets, from the same place.
    text = swish_links.examples.MARKER.sub(lambda m: m.group(0) + swish_links.footer(m.group('file')), text)
    output = args.output or str(source.with_suffix('.pdf'))
    to_pdf(document(to_html(text), css.read_text(encoding='utf-8') if css.exists() else ''), output)
    print(f'PDF written: {output}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
