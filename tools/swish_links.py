"""MkDocs hook: put the SWISH link under every block that declares an example.

The author writes the marker and the fenced block; `sync-examples.py` fills the
block from the file, and this adds the link while the site is built. The link is
therefore never stale and never written by hand: it carries the whole source of
the example, URL-encoded, so there is nothing to host.

The query the link opens with is the first `%?-` of the example, or whatever the
marker's `consulta:` field says, which is how several sections showing pieces of
one file each get the query that suits them.

An example whose header says `% solo-local:` gets its reason printed instead of a
link, which is the honest thing to tell a reader who cannot run it in a browser.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import examples  # noqa: E402

OPEN_IN_SWISH = 'Abrir en SWISH'
LOCAL_ONLY = 'Solo local (`swipl`)'
PLAY = '&#9654;'


def footer(relative, query):
    """The line that goes under the block: the link, or why there is none."""
    path = examples.EXAMPLES / relative
    if not path.exists():
        return ''  # sync-examples.py is the one that reports a missing file
    example = examples.read(path)
    if example.local_only:
        return f'\n!!! info "{LOCAL_ONLY}"\n    {example.local_only}\n'
    if query is None:
        query = example.queries[0] if example.queries else None
    link = examples.swish_link(example.source, query)
    return f'\n[{PLAY} {OPEN_IN_SWISH}]({link})' + '{ .swish target="_blank" rel="noopener" }\n'


def on_page_markdown(markdown, page, config, files):  # noqa: ARG001  (MkDocs calls it this way)
    """MkDocs hands each page's source here, before it becomes HTML."""

    def add(match):
        query = examples.marker_parts(match.group('piece'))['consulta']
        return match.group(0) + footer(match.group('file'), query)

    return examples.MARKER.sub(add, markdown)
