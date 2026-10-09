"""Unit tests of index_hook.py: how a section's HTML becomes chunks of the assistant's index."""

from typing import TYPE_CHECKING

import index_hook
import sections as course
from sections import Section

if TYPE_CHECKING:
    from sections import KeywordEntryDto, SearchDocumentDto


def test_paragraphs_list_items_and_code_are_blocks_in_order() -> None:
    html = '<p>Uno <code>X</code>.</p><ul><li>dos</li></ul><pre><code>p(X) :-\n    q(X).</code></pre>'
    assert index_hook.section_blocks(html) == ['Uno X .', 'dos', '```\np(X) :-\n    q(X).\n```']


def test_code_inside_a_paragraph_is_a_code_block() -> None:
    html = '<p><pre><code>?- X = 1.</code></pre> ▶ Abrir en SWISH</p>'
    assert index_hook.section_blocks(html) == ['```\n?- X = 1.\n```']


def test_entities_in_code_are_decoded() -> None:
    assert index_hook.section_blocks('<pre><code>X \\== Y, A &gt; B</code></pre>') == ['```\nX \\== Y, A > B\n```']


def test_text_without_blocks_is_one_block() -> None:
    assert index_hook.section_blocks('solo texto') == ['solo texto']


def document(location: str, title: str, text: str) -> SearchDocumentDto:
    return {'location': location, 'title': title, 'text': text}


def test_solutions_pages_are_left_out_and_chapter_17_stays() -> None:
    documents = [
        document('capitulo-10-n/soluciones/#e1', 'Ejercicio 1', '<p>Solución</p>'),
        document('capitulo-17-todas-las-soluciones/#172-findall3', '17.2', '<p>findall</p>'),
    ]
    chunks, _ = index_hook.index_chunks(documents, {})
    assert [c['location'] for c in chunks] == ['capitulo-17-todas-las-soluciones/#172-findall3']


def test_a_long_section_is_split_on_its_blocks() -> None:
    paragraph = 'palabra ' * 150
    chunks, _ = index_hook.index_chunks([document('c/#s', 'S', f'<p>{paragraph}</p>' * 4)], {})
    assert len(chunks) > 1
    assert all(len(c['text']) <= index_hook.MAX_CHUNK_CHARS for c in chunks)
    assert {c['location'] for c in chunks} == {'c/#s'}


def test_a_section_without_text_is_one_empty_chunk() -> None:
    chunks, _ = index_hook.index_chunks([document('c/#vacia', 'Vacía', '')], {})
    assert chunks == [{'location': 'c/#vacia', 'title': 'Vacía', 'text': ''}]


def test_keywords_are_attached_and_outdated_ones_counted() -> None:
    documents = [document('c/#a', 'A', '<p>texto a</p>'), document('c/#b', 'B', '<p>texto b</p>')]
    current: KeywordEntryDto = {'hash': course.section_hash(Section('A', 'texto a')), 'words': ['x'], 'questions': []}
    outdated: KeywordEntryDto = {'hash': 'old', 'words': ['y'], 'questions': ['¿z?']}
    chunks, stale = index_hook.index_chunks(documents, {'c/#a': current, 'c/#b': outdated})
    assert [c.get('keywords') for c in chunks] == ['x', 'y · ¿z?']
    assert stale == 1


def test_documents_follow_the_navigation_and_keep_their_sections_in_order() -> None:
    documents = [
        document('licencia/', 'Licencia', ''),
        document('capitulo-01-a/', 'C1', ''),
        document('capitulo-01-a/#11-x', '1.1', ''),
        document('plantillas/#1-p', 'P1', ''),
        document('fuera/', 'Fuera', ''),
    ]
    pages = ['', 'plantillas/', 'capitulo-01-a/', 'licencia/']
    ordered = index_hook.in_navigation_order(documents, pages)
    assert [d['location'] for d in ordered] == [
        'plantillas/#1-p',
        'capitulo-01-a/',
        'capitulo-01-a/#11-x',
        'licencia/',
        'fuera/',
    ]
