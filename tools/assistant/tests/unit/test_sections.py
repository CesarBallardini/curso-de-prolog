"""Unit tests of sections.py: what the assistant's tools share."""

import json
from typing import TYPE_CHECKING

import pytest
import sections as course
from sections import KeywordEntryDto, Section

if TYPE_CHECKING:
    from pathlib import Path


@pytest.mark.parametrize(
    ('location', 'expected'),
    [
        ('capitulo-10-negacion-como-falla/soluciones/', True),
        ('capitulo-10-negacion-como-falla/soluciones/#ejercicio-3', True),
        ('capitulo-10-negacion-como-falla/soluciones', True),
        ('capitulo-17-todas-las-soluciones/', False),
        ('capitulo-17-todas-las-soluciones/#172-findall3', False),
        ('capitulo-10-negacion-como-falla/#soluciones', False),
        ('', False),
    ],
)
def test_is_solutions_compares_the_last_path_segment(location: str, expected: bool) -> None:
    assert course.is_solutions(location) is expected


def test_html_to_text_drops_tags_entities_and_swish_links() -> None:
    html = '<p><code>X \\= Y</code> &amp; <em>más</em>   texto ▶ Abrir en SWISH</p>'
    assert course.html_to_text(html) == 'X \\= Y & más texto'


def test_section_hash_is_stable_and_follows_title_and_text() -> None:
    section = Section('1.1 Hechos', 'Un hecho es una afirmación.')
    assert course.section_hash(section) == course.section_hash(Section('1.1 Hechos', 'Un hecho es una afirmación.'))
    assert course.section_hash(section) != course.section_hash(Section('1.1 Hechos', 'Un hecho es otra cosa.'))
    assert course.section_hash(section) != course.section_hash(Section('1.2 Hechos', 'Un hecho es una afirmación.'))
    assert len(course.section_hash(section)) == 16


def test_pack_groups_consecutive_items_under_the_limit() -> None:
    assert course.pack(['aa', 'bb', 'cc', 'd'], len, 4) == [['aa', 'bb'], ['cc', 'd']]


def test_pack_gives_an_oversized_item_a_group_of_its_own() -> None:
    assert course.pack(['a', 'bbbbbb', 'c'], len, 4) == [['a'], ['bbbbbb'], ['c']]


def test_pack_of_nothing_is_no_group() -> None:
    assert course.pack([], len, 4) == []


@pytest.mark.parametrize(
    ('location', 'part'),
    [
        ('capitulo-01-la-primera-hora/', 'I'),
        ('capitulo-12-prolog-y-la-logica/#121-x', 'I'),
        ('capitulo-13-el-entorno-de-trabajo/', 'II'),
        ('capitulo-31-ejecutables-y-distribucion/', 'II'),
        ('capitulo-32-inspeccion-de-terminos/', 'III'),
        ('capitulo-42-prolog-y-sql/odbc/', 'III'),
        ('capitulo-43-proyecto-resolver-ecuaciones/', 'IV'),
        ('capitulo-87-proyecto-preguntas-en-castellano/', 'IV'),
        ('patrones/#8-recursion-en-espacio-constante', course.OUTSIDE_PARTS),
        ('', course.OUTSIDE_PARTS),
    ],
)
def test_part_of_follows_where_each_part_starts(location: str, part: str) -> None:
    assert course.part_of(location) == part


def test_keywords_text_joins_words_and_questions() -> None:
    entry: KeywordEntryDto = {'hash': 'h', 'words': ['atrapar un error', 'catch/3'], 'questions': ['¿cómo sigo?']}
    assert course.keywords_text(entry) == 'atrapar un error · catch/3 · ¿cómo sigo?'


def test_indexed_sections_leave_out_solutions_and_sections_without_text(tmp_path: Path) -> None:
    index = tmp_path / 'search_index.json'
    docs = [
        {'location': '', 'title': 'Curso', 'text': '<p>Inicio</p>'},
        {'location': 'capitulo-01-a/#11-x', 'title': '1.1 X', 'text': '<p>Texto</p>'},
        {'location': 'capitulo-01-a/#vacia', 'title': 'Vacía', 'text': ''},
        {'location': 'capitulo-01-a/soluciones/#e1', 'title': 'Ejercicio 1', 'text': '<p>Solución</p>'},
        {'location': 'capitulo-17-todas-las-soluciones/#172-findall3', 'title': '17.2', 'text': '<p>findall</p>'},
    ]
    index.write_text(json.dumps({'docs': docs}), encoding='utf-8')
    sections = course.indexed_sections(index)
    assert list(sections) == ['', 'capitulo-01-a/#11-x', 'capitulo-17-todas-las-soluciones/#172-findall3']
    assert sections['capitulo-01-a/#11-x'] == Section('1.1 X', 'Texto')


def test_keywords_are_saved_sorted_and_read_back(tmp_path: Path) -> None:
    path = tmp_path / 'keywords.json'
    entry: KeywordEntryDto = {'hash': 'h', 'words': ['w'], 'questions': []}
    course.save_keywords({'sections': {'b/': entry, 'a/': entry}}, path)
    assert list(course.load_keywords(path)['sections']) == ['a/', 'b/']
    assert path.read_bytes().endswith(b'}\n')
    assert b'\r\n' not in path.read_bytes()


def test_a_missing_keywords_file_reads_as_empty(tmp_path: Path) -> None:
    assert course.load_keywords(tmp_path / 'none.json') == {'sections': {}}
