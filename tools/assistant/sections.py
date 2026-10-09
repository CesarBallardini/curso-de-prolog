"""What the course assistant's tools share: the sections it indexes, their keywords, and a static server.

The assistant ranks the sections of the built site's search index (site/search/search_index.json),
one entry per section of every page, except the solutions pages. Their keywords, the words and
questions a student would use for each, are stored in tools/assistant/keywords.json with a hash of
the section they were written for. The MkDocs hook (index_hook.py), the keywords tool (keywords.py)
and the evaluation (evaluate.py) read them through this module; the tests serve the site with the
same server.
"""

import hashlib
import html
import json
import re
import sys
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from threading import Thread
from typing import TYPE_CHECKING, NamedTuple, NotRequired, Protocol, TypedDict, cast, runtime_checkable
from urllib.parse import urlsplit

if TYPE_CHECKING:
    import socket
    from collections.abc import Callable, Iterable

ROOT = Path(__file__).resolve().parents[2]
SITE = ROOT / 'site'
SEARCH_INDEX = SITE / 'search' / 'search_index.json'
KEYWORDS = Path(__file__).with_name('keywords.json')
# The site is published at https://katra.ballardini.com.ar/curso-de-prolog/.
PUBLISHED_HOST = 'https://katra.ballardini.com.ar'
PREFIX = '/curso-de-prolog/'
SWISH_LINK = '▶ Abrir en SWISH'

type Location = str
"""A section's place in the site: `<page path>/#<anchor>`, relative to the site root; '' is the home page."""


class SearchDocumentDto(TypedDict):
    """One entry of Material's search index: a section of a page, its title and text as HTML."""

    location: Location
    title: str
    text: str


class KeywordEntryDto(TypedDict):
    """The keywords of one section and the hash of the text they were written for."""

    hash: str
    words: list[str]
    questions: list[str]


class KeywordsFileDto(TypedDict):
    """tools/assistant/keywords.json."""

    sections: dict[Location, KeywordEntryDto]


class ChunkDto(TypedDict):
    """A piece of a section in the assistant's index, as the browser reads it."""

    location: Location
    title: str
    text: str
    keywords: NotRequired[str]


class IndexDto(TypedDict):
    """site/assistant/index.json."""

    version: int
    chunks: list[ChunkDto]


class Section(NamedTuple):
    """A section as the assistant indexes it: plain text, without HTML."""

    title: str
    text: str


def is_solutions(location: Location) -> bool:
    """A solutions page: its last path segment, not a substring (chapter 17 is «Todas las soluciones»)."""
    return location.split('#')[0].rstrip('/').split('/')[-1] == 'soluciones'


def html_to_text(fragment: str) -> str:
    """The text of an HTML fragment of the search index, without tags, entities or the SWISH links."""
    text = html.unescape(re.sub(r'<[^>]+>', ' ', fragment)).replace(SWISH_LINK, '')
    return re.sub(r'[ \t]+', ' ', text).strip()


def section_hash(section: Section) -> str:
    """What a section's keywords were written for: when it changes, the keywords are out of date."""
    return hashlib.sha256(f'{section.title}\n{section.text}'.encode()).hexdigest()[:16]


def search_documents(path: Path = SEARCH_INDEX) -> list[SearchDocumentDto]:
    """The entries of a built site's search index, one per section of every page, in the site's order."""
    return cast('list[SearchDocumentDto]', json.loads(path.read_text(encoding='utf-8'))['docs'])


def section_of(document: SearchDocumentDto) -> Section:
    return Section(html_to_text(document['title']), html_to_text(document['text']))


def indexed_sections(path: Path = SEARCH_INDEX) -> dict[Location, Section]:
    """Every section the assistant indexes, in the site's order.

    Sections without text (a heading followed directly by another) are left out: there is nothing to
    describe. The index hook still writes them, as empty chunks, so that their title can be found.
    """
    out: dict[Location, Section] = {}
    for document in search_documents(path):
        section = section_of(document)
        if not is_solutions(document['location']) and section.text:
            out[document['location']] = section
    return out


def load_keywords(path: Path = KEYWORDS) -> KeywordsFileDto:
    if path.is_file():
        return cast('KeywordsFileDto', json.loads(path.read_text(encoding='utf-8')))
    return {'sections': {}}


def save_keywords(data: KeywordsFileDto, path: Path = KEYWORDS) -> None:
    data['sections'] = dict(sorted(data['sections'].items()))
    write_text(path, json.dumps(data, ensure_ascii=False, indent=1) + '\n')


def keywords_text(entry: KeywordEntryDto) -> str:
    """A section's keywords as the one field of text the search reads."""
    return ' · '.join(entry['words'] + entry['questions'])


@runtime_checkable
class Reconfigurable(Protocol):
    """A text stream whose encoding can be changed, as a console's sys.stdout."""

    def reconfigure(self, *, encoding: str) -> None: ...


def utf8_console() -> None:
    """Print UTF-8 to a Windows console, whose default code page cannot encode the course's text."""
    if isinstance(sys.stdout, Reconfigurable):
        sys.stdout.reconfigure(encoding='utf-8')


def write_text(path: Path, text: str) -> None:
    """Write UTF-8 with LF line ends, creating the directory."""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8', newline='\n')


def pack[T](items: Iterable[T], size: Callable[[T], int], limit: int) -> list[list[T]]:
    """Consecutive groups of items, each of total size about `limit`; an item larger than it goes alone."""
    groups: list[list[T]] = []
    current: list[T] = []
    total = 0
    for item in items:
        if current and total + size(item) > limit:
            groups.append(current)
            current, total = [], 0
        current.append(item)
        total += size(item)
    if current:
        groups.append(current)
    return groups


# Where each part of the course starts, as in tools/ci-parts.py; the rest are patterns and templates.
PARTS: list[tuple[str, int]] = [('I', 1), ('II', 13), ('III', 32), ('IV', 43)]
OUTSIDE_PARTS = 'patterns/templates'


def part_of(location: Location) -> str:
    """The part of the course a location belongs to: I to IV, or OUTSIDE_PARTS for the rest."""
    if not (match := re.match(r'capitulo-(\d+)-', location)):
        return OUTSIDE_PARTS
    chapter = int(match.group(1))
    return next(name for name, start in reversed(PARTS) if chapter >= start)


class SiteHandler(SimpleHTTPRequestHandler):
    """Serve site/ under PREFIX and nothing outside it, as GitHub Pages does.

    Material navigates without reloading only to the pages listed in sitemap.xml, and it compares their
    host and port with the page's: the sitemap is served with this server's address in place of the
    published one, or every link would be a full reload.
    """

    def translate_path(self, path: str) -> str:
        if not urlsplit(path).path.startswith(PREFIX):
            return str(SITE / '__outside_the_site__')
        return super().translate_path('/' + path[len(PREFIX) :])

    def do_GET(self) -> None:
        if urlsplit(self.path).path != PREFIX + 'sitemap.xml':
            super().do_GET()
            return
        local = f'http://{self.headers.get("Host", "")}'  # the host and port the browser used
        body = (SITE / 'sitemap.xml').read_bytes().replace(PUBLISHED_HOST.encode(), local.encode())
        self.send_response(200)
        self.send_header('Content-Type', 'application/xml')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format: str, *args: str) -> None:
        pass


class SiteServer(ThreadingHTTPServer):
    """Closing a browser context drops the requests it still had open; that is not an error of the site."""

    def handle_error(
        self, request: socket.socket | tuple[bytes, socket.socket], client_address: tuple[str, int]
    ) -> None:
        if not isinstance(sys.exception(), ConnectionError):
            super().handle_error(request, client_address)


class LocalSite(NamedTuple):
    server: SiteServer
    base: str  # the site's URL, ending in PREFIX


def serve_site() -> LocalSite:
    """Start serving site/ on a free local port."""
    server = SiteServer(('127.0.0.1', 0), partial(SiteHandler, directory=str(SITE)))
    Thread(target=server.serve_forever, daemon=True).start()
    # 127.0.0.1 and not localhost: on Windows, localhost tries IPv6 first.
    return LocalSite(server, f'http://127.0.0.1:{server.server_address[1]}{PREFIX}')
