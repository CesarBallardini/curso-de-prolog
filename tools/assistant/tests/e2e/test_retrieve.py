"""E2e Playwright tests of the assistant's domain modules and its language adapter, run in the browser.

The modules only run in a browser, so a page of the site imports them and runs them on a small
synthetic index whose expected ranking is known; the Spanish stemmer is the one the site ships.
"""

from typing import TYPE_CHECKING, NotRequired, TypedDict, cast

import pytest

if TYPE_CHECKING:
    from pages import PageMaker
    from playwright.sync_api import Page

# A page script: imports the modules from the site and runs CODE with them and the argument.
HARNESS = """
async ({ code, argument }) => {
  const config = JSON.parse(document.getElementById('__config').textContent);
  const site = new URL(config.base.replace(/\\/?$/, '/'), location.href);
  const modules = new URL('javascripts/assistant/', site);
  const load = (path) => import(new URL(path, modules));
  const [{ createSearch }, { createTokenizer }, { sectionKey }, { inCourseOrder }, { citedParts }, { loadSpanish }] =
    await Promise.all(['domain/ranking.js', 'domain/text.js', 'domain/section-key.js', 'domain/course-order.js',
      'domain/written-answer.js', 'adapters/lunr-spanish.js'].map(load));
  const tokenizer = createTokenizer(await loadSpanish(site));
  const domain = { createSearch, tokenizer, sectionKey, inCourseOrder, citedParts };
  return new Function('domain', 'argument', code)(domain, argument);
}
"""


class ChunkInputDto(TypedDict):
    location: str
    title: str
    text: str
    keywords: NotRequired[str]


class OptionsDto(TypedDict, total=False):
    useKeywords: bool


class AskArgumentDto(TypedDict):
    chunks: list[ChunkInputDto]
    options: OptionsDto
    question: str


class CitedPartDto(TypedDict, total=False):
    text: str
    citation: int


class SectionResultDto(TypedDict):
    location: str
    title: str
    position: int


class PassageResultDto(TypedDict):
    location: str
    text: str
    code: bool


class AnswerResultDto(TypedDict):
    sections: list[SectionResultDto]
    passages: list[PassageResultDto]
    covered: bool
    terms: list[str]


CHUNKS: list[ChunkInputDto] = [
    {'location': 'capitulo-01-listas/', 'title': 'Capítulo 1 — Listas', 'text': 'Las listas guardan elementos.'},
    {
        'location': 'capitulo-01-listas/#11-recorrer-una-lista',
        'title': '1.1 Recorrer una lista',
        'text': 'Una lista se procesa por su cabeza y su cola.',
    },
    {
        'location': 'capitulo-01-listas/#12-longitud',
        'title': '1.2 Longitud',
        'text': 'La longitud cuenta los elementos; para eso se recorre la lista entera, y se recorre otra vez.',
    },
    {
        'location': 'capitulo-01-listas/#ejercicios',
        'title': 'Ejercicios',
        'text': 'Escribir un predicado que sume los números de una lista.',
    },
    {
        'location': 'capitulo-01-listas/#13-sumar',
        'title': '1.3 Un predicado',
        'text': 'Escribir un predicado que sume los números de una lista.',
    },
    {
        'location': 'capitulo-02-errores/#21-excepciones',
        'title': '2.1 Excepciones',
        'text': 'Un error se lanza con throw/1 y se maneja con catch/3.',
        'keywords': 'atrapar un fallo',
    },
    {'location': 'capitulo-03-arboles/#31-arboles-binarios', 'title': '3.1 Árboles binarios', 'text': 'Un árbol.'},
    {
        'location': 'capitulo-03-arboles/extra/#arboles-binarios',
        'title': 'Árboles binarios',
        'text': 'Un árbol binario tiene una raíz, un subárbol izquierdo y uno derecho.',
    },
    {
        'location': 'capitulo-04-codigo/#41-pertenencia',
        'title': '4.1 Un ejemplo',
        'text': 'Un programa:\n\n```\nmiembro(X, [X|_]).\nmiembro(X, [_|R]) :- miembro(X, R).\n```',
    },
]


@pytest.fixture
def site_page(make_page: PageMaker) -> Page:
    """The home page of the site: the origin the modules are imported from."""
    page, _ = make_page('')
    return page


def run_code(
    page: Page, code: str, argument: str | AskArgumentDto
) -> str | bool | list[str] | AnswerResultDto | list[CitedPartDto]:
    return page.evaluate(HARNESS, {'code': code, 'argument': argument})


def tokens(page: Page, text: str) -> list[str]:
    return cast('list[str]', run_code(page, 'return domain.tokenizer.terms(argument);', text))


def ask(page: Page, question: str, options: OptionsDto | None = None) -> AnswerResultDto:
    argument: AskArgumentDto = {'chunks': CHUNKS, 'options': options or {}, 'question': question}
    code = 'return domain.createSearch(argument.chunks, domain.tokenizer, argument.options).ask(argument.question);'
    return cast('AnswerResultDto', run_code(page, code, argument))


def locations(answer: AnswerResultDto) -> list[str]:
    return [section['location'] for section in answer['sections']]


# --- The tokenizer ---------------------------------------------------------------------------------


def test_accents_and_case_do_not_matter(site_page: Page) -> None:
    assert tokens(site_page, 'Negación') == tokens(site_page, 'negacion')


def test_stopwords_are_dropped(site_page: Page) -> None:
    assert tokens(site_page, 'el de la que') == []


def test_a_predicate_indicator_is_kept_whole_and_as_a_name(site_page: Page) -> None:
    found = tokens(site_page, 'findall/3')
    assert found[0] == 'findall/3'
    assert len(found) == 2


def test_operators_are_read_longest_first(site_page: Page) -> None:
    found = tokens(site_page, 'X \\== Y')
    assert '\\==' in found
    assert '\\=' not in found


# --- section-key.js --------------------------------------------------------------------------------


@pytest.mark.parametrize(
    ('first', 'second', 'same'),
    [
        ('capitulo-03-a/#31-arboles-binarios', 'capitulo-03-a/extra/#arboles-binarios', True),
        ('capitulo-03-a/#31-arboles', 'capitulo-03-a/extra/#arboles_1', True),
        ('capitulo-03-a/#31-arboles', 'capitulo-04-b/extra/#arboles', False),
        ('capitulo-03-a/', 'capitulo-03-a/extra/', False),
    ],
)
def test_the_same_heading_on_two_pages_of_a_chapter_is_one_section(
    site_page: Page, first: str, second: str, same: bool
) -> None:
    code = 'return domain.sectionKey(argument.split("|")[0]) === domain.sectionKey(argument.split("|")[1]);'
    assert run_code(site_page, code, f'{first}|{second}') is same


# --- The ranking -----------------------------------------------------------------------------------


def test_words_in_a_title_count_more_than_in_the_text(site_page: Page) -> None:
    assert locations(ask(site_page, 'recorrer'))[0] == 'capitulo-01-listas/#11-recorrer-una-lista'


def test_a_section_that_lists_exercises_ranks_below_one_that_explains(site_page: Page) -> None:
    found = locations(ask(site_page, 'sumar números de una lista'))
    assert found.index('capitulo-01-listas/#13-sumar') < found.index('capitulo-01-listas/#ejercicios')


def test_question_words_carry_no_topic(site_page: Page) -> None:
    answer = ask(site_page, '¿para qué sirve prolog?')
    assert answer['terms'] == []
    assert answer['sections'] == []


def test_the_keywords_find_a_section_by_words_it_does_not_use(site_page: Page) -> None:
    assert locations(ask(site_page, 'atrapar un fallo'))[0] == 'capitulo-02-errores/#21-excepciones'
    assert 'capitulo-02-errores/#21-excepciones' not in locations(
        ask(site_page, 'atrapar un fallo', {'useKeywords': False})
    )


def test_a_section_on_two_pages_is_listed_once_with_the_fuller_page(site_page: Page) -> None:
    found = locations(ask(site_page, 'árboles binarios'))
    assert found.count('capitulo-03-arboles/extra/#arboles-binarios') == 1
    assert 'capitulo-03-arboles/#31-arboles-binarios' not in found


def test_a_question_outside_the_course_is_not_covered(site_page: Page) -> None:
    answer = ask(site_page, 'pizza napolitana')
    assert answer['covered'] is False
    assert answer['passages'] == []


def test_passages_come_one_per_section_and_at_most_three(site_page: Page) -> None:
    answer = ask(site_page, 'lista elementos recorre')
    passage_locations = [p['location'] for p in answer['passages']]
    assert 1 <= len(passage_locations) <= 3
    assert len(passage_locations) == len(set(passage_locations))
    assert set(passage_locations) <= set(locations(answer))


def test_a_code_passage_is_marked_as_code(site_page: Page) -> None:
    (first, *_) = ask(site_page, 'miembro')['passages']
    assert first['code'] is True
    assert 'miembro(X, [X|_]).' in first['text']


# --- The order of the course, and the citations of a written answer ----------------------------------


def test_an_answer_in_course_order_keeps_its_sections_and_sorts_them(site_page: Page) -> None:
    argument: AskArgumentDto = {'chunks': CHUNKS, 'options': {}, 'question': 'lista elementos recorre árbol'}
    code = (
        'const answer = domain.createSearch(argument.chunks, domain.tokenizer).ask(argument.question);'
        'return [answer, domain.inCourseOrder(answer)];'
    )
    relevance, course = cast(
        'list[AnswerResultDto]', site_page.evaluate(HARNESS, {'code': code, 'argument': argument})
    )
    positions = [s['position'] for s in course['sections']]
    assert positions == sorted(positions)
    assert sorted(locations(course)) == sorted(locations(relevance))
    passage_places = [locations(course).index(p['location']) for p in course['passages']]
    assert passage_places == sorted(passage_places)


def test_a_citation_of_no_passage_is_dropped(site_page: Page) -> None:
    code = 'return domain.citedParts(argument, 2);'
    parts = cast('list[CitedPartDto]', run_code(site_page, code, 'Uno [1], dos [2], nueve [9].'))
    assert [p.get('citation') for p in parts if 'citation' in p] == [1, 2]
    assert ''.join(p.get('text', '') for p in parts) == 'Uno [1], dos [2], nueve .'
