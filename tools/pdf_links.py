"""MkDocs hook: a link to a PDF that has not been built becomes plain text.

The PDFs come from `make pdf`, not from `make docs`, so a site built without
them would carry links to files that are not there, and the strict build fails
on each one. This leaves the word and drops the link, which is also the honest
thing to show a reader. A PDF that exists keeps its link, so when `make pdf`
runs first (CI does) every link is still checked by the strict build.
"""

import re
from pathlib import Path

PDF_LINK = re.compile(r'\[(?P<text>[^\]]*)\]\((?P<target>[^)\s]+\.pdf)\)(?:\{[^}]*\})?')


def on_page_markdown(markdown, page, config, files):  # noqa: ARG001  (MkDocs calls it this way)
    """MkDocs hands each page's source here, before it becomes HTML."""
    folder = Path(config['docs_dir']) / Path(page.file.src_path).parent

    def unlink(match):
        return match.group(0) if (folder / match.group('target')).exists() else match.group('text')

    return PDF_LINK.sub(unlink, markdown)
