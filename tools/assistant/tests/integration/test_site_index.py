"""Integration tests over the built site: the assistant's index that tools/assistant/index_hook.py wrote."""

import gzip
import json
from typing import TYPE_CHECKING, cast

import index_hook
import pytest
import sections as course

if TYPE_CHECKING:
    from sections import IndexDto

INDEX = course.SITE / 'assistant' / 'index.json'
# The whole course, gzipped, as GitHub Pages serves it: a guard against an accidental growth.
MAX_GZIPPED_BYTES = 2_000_000


@pytest.fixture(scope='module')
def index_bytes() -> bytes:
    if not INDEX.is_file():
        pytest.fail(f'no {INDEX.relative_to(course.ROOT)}: build the site first (make docs)')
    return INDEX.read_bytes()


@pytest.fixture(scope='module')
def index(index_bytes: bytes) -> IndexDto:
    return cast('IndexDto', json.loads(index_bytes))


def test_the_index_has_the_version_the_widget_reads(index: IndexDto) -> None:
    assert index['version'] == index_hook.INDEX_VERSION


def test_every_indexed_section_is_in_the_index(index: IndexDto) -> None:
    locations = {chunk['location'] for chunk in index['chunks']}
    assert set(course.indexed_sections()) <= locations


def test_no_solutions_page_is_in_the_index(index: IndexDto) -> None:
    assert not [c['location'] for c in index['chunks'] if course.is_solutions(c['location'])]
    assert any(c['location'].startswith('capitulo-17-todas-las-soluciones/') for c in index['chunks'])


def test_every_section_with_keywords_carries_them(index: IndexDto) -> None:
    stored = course.load_keywords()['sections']
    for chunk in index['chunks']:
        entry = stored.get(chunk['location'])
        if entry and (entry['words'] or entry['questions']):
            assert chunk.get('keywords') == course.keywords_text(entry)


def test_the_index_stays_small_enough_to_download(index_bytes: bytes) -> None:
    assert len(gzip.compress(index_bytes)) < MAX_GZIPPED_BYTES
