"""MkDocs hook: a `\\|` inside an inline code span, on a table row, becomes `|`.

The source of the book follows GFM there: a pipe inside a code span on a table
row is written `\\|`, as in `` `[Primero\\|Resto]` ``. That is what GitHub, the
VS Code previews and markdown-it (which prints the PDF) understand. Python-
Markdown, which renders the site, keeps such a row whole but prints the
backslash, so this hook removes it before the page is rendered. Pandoc, which
builds the slide decks, does the same through `tools/tabla_pipes.lua`.

The rows it matters for teach `[Primero|Resto]`, `'[|]'` and the `~|` of
`format/2`, where the pipe is the subject and cannot be reworded away.
"""

import re

ROW = re.compile(r'^[ \t]*\|.*$', re.M)
# A double-backtick span first, so that a span holding a backtick (`` ~`-t ``)
# is not read as two single-backtick spans.
CODE_SPAN = re.compile(r'``(?:[^`\n]|`(?!`))*``|`[^`\n]*`')


def unescape_pipes_in_table_code(text):
    """Turn `\\|` into `|` inside the inline code spans of every table row."""

    def row(match):
        return CODE_SPAN.sub(lambda span: span.group(0).replace(r'\|', '|'), match.group(0))

    return ROW.sub(row, text)


def on_page_markdown(markdown, page, config, files):
    """MkDocs hands each page's Markdown here, before Python-Markdown renders it."""
    return unescape_pipes_in_table_code(markdown)
