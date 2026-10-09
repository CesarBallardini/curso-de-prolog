"""MkDocs hook: build the course assistant's index when the site is built.

The assistant runs in the student's browser and answers by ranking the course's sections, so the site
carries one file for it, assistant/index.json. This reads the search index that Material's search
plugin has just written, which has one entry per section of every page, and writes the same sections as
chunks of plain text, in the order of the site's navigation (the order of the course): paragraphs and
code blocks, packed into pieces of about MAX_CHUNK_CHARS characters, with the keywords stored for the
section in tools/assistant/keywords.json. The solutions pages are left out: the assistant must neither
quote nor link a solution.

Hooks run after the plugins, so the search index is already on disk. A section whose text changed
after its keywords were written still gets them, and the build log says how many are out of date.
"""

import gzip
import html
import json
import logging
import re
import sys
from pathlib import Path
from typing import TYPE_CHECKING

# MkDocs loads a hook from its file, so the directory of its sibling modules is not on the path.
sys.path.insert(0, str(Path(__file__).resolve().parent))
import sections as course  # noqa: E402

if TYPE_CHECKING:
    from mkdocs.config.defaults import MkDocsConfig
    from mkdocs.structure.files import Files
    from mkdocs.structure.nav import Navigation
    from sections import ChunkDto, IndexDto, KeywordEntryDto, Location, SearchDocumentDto

log = logging.getLogger('mkdocs.hooks.assistant')

# Read by docs/javascripts/assistant/worker.js, which refuses an index of another version.
INDEX_VERSION = 1
MAX_CHUNK_CHARS = 2000
# The pages in the order of the site's navigation, which on_nav records: the index lists its chunks in
# that order, the order of the course, because Material's search index follows the order of the files.
navigation: list[str] = []
BLOCK = re.compile(r'<pre><code[^>]*>(.*?)</code></pre>|<(p|li)>(.*?)</\2>', re.S)


def section_blocks(fragment: str) -> list[str]:
    """Paragraphs and code blocks of a section's HTML, in order. A <p> that wraps a <pre> yields the code."""
    out: list[str] = []
    position = 0
    for match in BLOCK.finditer(fragment):
        if match.start() < position:
            continue
        if match.group(1) is not None:
            out.append('```\n' + html.unescape(match.group(1)).rstrip() + '\n```')
        elif '<pre>' in match.group(3):
            out.extend(section_blocks(match.group(3)))
        elif paragraph := course.html_to_text(match.group(3)):
            out.append(paragraph)
        position = match.end()
    if not out and (paragraph := course.html_to_text(fragment)):
        out.append(paragraph)
    return out


def index_chunks(
    documents: list[SearchDocumentDto], stored: dict[Location, KeywordEntryDto]
) -> tuple[list[ChunkDto], int]:
    """The chunks of the index, and how many sections have keywords that no longer match their text."""
    chunks: list[ChunkDto] = []
    outdated = 0
    for doc in documents:
        location = doc['location']
        if course.is_solutions(location):
            continue
        section = course.section_of(doc)
        entry = stored.get(location)
        if entry and entry['hash'] != course.section_hash(section):
            outdated += 1
        # A section without text still gets one empty chunk, so that its title can be found.
        for piece in course.pack(section_blocks(doc['text']), len, MAX_CHUNK_CHARS) or [[]]:
            chunk: ChunkDto = {'location': location, 'title': section.title, 'text': '\n\n'.join(piece)}
            if entry:
                chunk['keywords'] = course.keywords_text(entry)
            chunks.append(chunk)
    return chunks, outdated


def in_navigation_order(documents: list[SearchDocumentDto], pages: list[str]) -> list[SearchDocumentDto]:
    """The documents in the order of the pages; a page outside the navigation goes last, its sections in order."""
    place = {page: i for i, page in enumerate(pages)}
    return sorted(documents, key=lambda doc: place.get(doc['location'].split('#')[0], len(place)))


def on_nav(nav: Navigation, config: MkDocsConfig, files: Files) -> Navigation:
    """MkDocs calls this with the site's navigation; its pages give the order of the course."""
    navigation[:] = [page.url for page in nav.pages]
    return nav


def on_post_build(config: MkDocsConfig) -> None:
    """MkDocs calls this once the site is on disk."""
    site = Path(config.site_dir)
    documents = in_navigation_order(course.search_documents(site / 'search' / 'search_index.json'), navigation)
    chunks, outdated = index_chunks(documents, course.load_keywords()['sections'])
    index: IndexDto = {'version': INDEX_VERSION, 'chunks': chunks}
    data = json.dumps(index, ensure_ascii=False, separators=(',', ':')).encode()
    target = site / 'assistant' / 'index.json'
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)
    log.info(
        'assistant index: %d chunks, %d KB (%d KB gzipped), %d sections with outdated keywords',
        len(chunks),
        len(data) // 1024,
        len(gzip.compress(data)) // 1024,
        outdated,
    )
