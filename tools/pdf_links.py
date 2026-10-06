"""MkDocs hook: a link to a PDF that has not been built becomes plain text.

The PDFs come from `make pdf`, not from `make docs`, so a site built without
them would carry links to files that are not there, and the strict build fails
on each one. This leaves the word and drops the link, which is also the honest
thing to show a reader. A PDF that exists keeps its link, so when `make pdf`
runs first (CI does) every link is still checked by the strict build.

"Exists" means it is one of the site's files, not only a file under docs/: the
slide decks enter the site through tools/slides_files.py, from diapositivas/.
"""

import posixpath
import re

PDF_LINK = re.compile(r'\[(?P<text>[^\]]*)\]\((?P<target>[^)\s]+\.pdf)\)(?:\{[^}]*\})?')


def on_page_markdown(markdown, page, config, files):  # noqa: ARG001  (MkDocs calls it this way)
    """MkDocs hands each page's source here, before it becomes HTML."""
    folder = posixpath.dirname(page.file.src_uri)

    def unlink(match):
        target = posixpath.normpath(posixpath.join(folder, match.group('target')))
        return match.group(0) if files.get_file_from_path(target) else match.group('text')

    return PDF_LINK.sub(unlink, markdown)
