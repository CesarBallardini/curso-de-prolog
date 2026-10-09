"""Unit tests of keywords.py, through its command line, over a small fake search index."""

import json
from typing import TYPE_CHECKING, NamedTuple

import keywords
import pytest
import sections as course
from sections import Section

if TYPE_CHECKING:
    from pathlib import Path

    from keywords import AgentAnswerDto
    from sections import KeywordEntryDto, Location

DOCS = [
    {'location': '', 'title': 'Curso de Prolog', 'text': '<p>Un curso.</p>'},
    {'location': 'capitulo-01-a/', 'title': 'Capítulo 1 — Hechos', 'text': '<p>Introducción.</p>'},
    {'location': 'capitulo-01-a/#11-hechos', 'title': '1.1 Hechos', 'text': '<p>Un hecho afirma algo.</p>'},
    {'location': 'capitulo-01-a/soluciones/#e1', 'title': 'Ejercicio 1', 'text': '<p>Solución.</p>'},
    {'location': 'capitulo-02-b/#21-reglas', 'title': '2.1 Reglas', 'text': '<p>' + 'Una regla. ' * 60 + '</p>'},
]


class Workspace(NamedTuple):
    search_index: Path
    keywords: Path
    work: Path

    def run(self, *argv: str) -> int:
        command, *rest = argv
        return keywords.run(
            [
                command,
                '--search-index',
                str(self.search_index),
                '--keywords',
                str(self.keywords),
                '--work',
                str(self.work),
                *rest,
            ]
        )

    def stored(self) -> dict[Location, KeywordEntryDto]:
        return course.load_keywords(self.keywords)['sections']

    def answer(self, name: str, entries: dict[str, AgentAnswerDto] | str) -> None:
        text = entries if isinstance(entries, str) else json.dumps(entries)
        course.write_text(self.work / 'out' / name, text)


@pytest.fixture
def space(tmp_path: Path) -> Workspace:
    search_index = tmp_path / 'search_index.json'
    search_index.write_text(json.dumps({'docs': DOCS}), encoding='utf-8')
    return Workspace(search_index, tmp_path / 'keywords.json', tmp_path / 'work')


def described(section: Section, words: list[str]) -> KeywordEntryDto:
    return {'hash': course.section_hash(section), 'words': words, 'questions': []}


def test_check_fails_while_a_section_lacks_keywords(space: Workspace) -> None:
    assert space.run('check') == 1


def test_export_writes_the_sections_without_keywords_and_never_a_solution(space: Workspace) -> None:
    assert space.run('export') == 0
    listed = keywords.listed_locations(space.work / 'in' / 'part-000.txt')
    assert listed == {'', 'capitulo-01-a/', 'capitulo-01-a/#11-hechos', 'capitulo-02-b/#21-reglas'}
    assert '@@@ <home>' in (space.work / 'in' / 'part-000.txt').read_text(encoding='utf-8')


def test_export_by_chapter_lists_the_whole_chapter(space: Workspace) -> None:
    space.run('export', '--toc', '--only', '^capitulo-01-')
    (chapter,) = (space.work / 'in').glob('*.txt')
    text = chapter.read_text(encoding='utf-8')
    assert text.startswith('CHAPTER: capitulo-01-a\nTABLE OF CONTENTS')
    assert '- capitulo-01-a/#11-hechos  |  1.1 Hechos' in text
    assert keywords.listed_locations(chapter) == {'capitulo-01-a/', 'capitulo-01-a/#11-hechos'}


def test_export_refuses_while_answers_of_an_earlier_export_wait(space: Workspace) -> None:
    space.run('export')
    space.answer('part-000.json', {})
    with pytest.raises(SystemExit, match='holds answers of an earlier export'):
        space.run('export')


def test_merge_stores_normalized_answers_with_the_hash_of_their_section(space: Workspace) -> None:
    space.run('export')
    answer: AgentAnswerDto = {'words': ['  Atrapar   un error ', 'atrapar un error', 'x' * 81], 'questions': ['¿Qué?']}
    space.answer('part-000.json', {'capitulo-01-a/#11-hechos': answer, '<home>': answer})
    assert space.run('merge') == 0
    entry = space.stored()['capitulo-01-a/#11-hechos']
    assert entry['words'] == ['atrapar un error']
    assert entry['questions'] == ['¿qué?']
    assert entry['hash'] == course.section_hash(Section('1.1 Hechos', 'Un hecho afirma algo.'))
    assert '' in space.stored()


@pytest.mark.parametrize(
    ('content', 'problem'),
    [
        ('{"capitulo-02-b/#21-reglas": {"words": [], "questions": []}}', 'is not a section of part-000.txt'),
        ('{"capitulo-01-a/#11-hechos": {"words": "texto", "questions": []}}', 'needs lists of text'),
        ('{"capitulo-01-a/#11-hechos": {"words": [1], "questions": []}}', 'needs lists of text'),
        ('[1, 2]', 'not a JSON object'),
        ('{"capitulo', 'not valid JSON'),
    ],
)
def test_merge_rejects_what_its_input_did_not_ask_for(
    space: Workspace, capsys: pytest.CaptureFixture[str], content: str, problem: str
) -> None:
    space.run('export', '--only', '^capitulo-01-a/#')
    space.answer('part-000.json', content)
    assert space.run('merge') == 1
    assert problem in capsys.readouterr().err
    assert 'capitulo-02-b/#21-reglas' not in space.stored()


def test_merge_rejects_an_answer_without_its_input_file(space: Workspace, capsys: pytest.CaptureFixture[str]) -> None:
    space.run('export')
    space.answer('part-999.json', {})
    assert space.run('merge') == 1
    assert 'no input file part-999.txt' in capsys.readouterr().err


def test_merge_drops_the_keywords_of_sections_that_no_longer_exist(space: Workspace) -> None:
    gone = described(Section('x', 'y'), ['viejo'])
    course.save_keywords({'sections': {'capitulo-99-ya-no/': gone}}, space.keywords)
    (space.work / 'out').mkdir(parents=True)
    space.run('merge')
    assert 'capitulo-99-ya-no/' not in space.stored()


def test_check_passes_when_every_section_has_current_keywords(space: Workspace) -> None:
    stored = {loc: described(section, ['w']) for loc, section in course.indexed_sections(space.search_index).items()}
    course.save_keywords({'sections': stored}, space.keywords)
    assert space.run('check') == 0


def test_a_changed_section_needs_new_keywords(space: Workspace) -> None:
    stored = {loc: described(section, ['w']) for loc, section in course.indexed_sections(space.search_index).items()}
    stored['capitulo-01-a/#11-hechos']['hash'] = 'old'
    course.save_keywords({'sections': stored}, space.keywords)
    space.run('export')
    assert keywords.listed_locations(space.work / 'in' / 'part-000.txt') == {'capitulo-01-a/#11-hechos'}


def test_blind_sets_are_reproducible_and_skip_excluded_sections(space: Workspace) -> None:
    stored = {loc: described(section, ['w']) for loc, section in course.indexed_sections(space.search_index).items()}
    course.save_keywords({'sections': stored}, space.keywords)
    space.run('blind', '--count', '1', '--seed', '3', '--name', 'a')
    space.run('blind', '--count', '1', '--seed', '3', '--name', 'b')
    first = (space.work / 'a' / 'truth.json').read_text(encoding='utf-8')
    assert first == (space.work / 'b' / 'truth.json').read_text(encoding='utf-8')
    # Only 2.1 is long enough for a blind question; excluding it leaves none.
    assert json.loads(first) == {'q00': 'capitulo-02-b/#21-reglas'}
    with pytest.raises(SystemExit, match='only 0 eligible sections'):
        space.run('blind', '--count', '1', '--exclude', str(space.work / 'a' / 'truth.json'))


def test_normalize_entries_keeps_the_first_of_each_entry_up_to_the_limit() -> None:
    assert keywords.normalize_entries(['B', 'a', 'b', 'c'], 2) == ['b', 'a']


def test_an_answer_needs_lists_of_strings() -> None:
    assert keywords.as_answer({'words': ['a'], 'questions': []}) == {'words': ['a'], 'questions': []}
    assert keywords.as_answer({'words': ['a']}) is None
    assert keywords.as_answer({'words': 'a', 'questions': []}) is None
    assert keywords.as_answer(['a']) is None
