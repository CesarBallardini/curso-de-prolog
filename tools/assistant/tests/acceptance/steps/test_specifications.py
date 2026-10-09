"""Step definitions of the widget's Gherkin specifications (acceptance/features/*.feature).

The scenarios drive the widget in a real browser, through roles and accessible names only (pages.py),
and check what a student sees and what leaves the browser. Nothing is compared by pixels. Ranking
quality is not measured here: the questions are a few whose answer is unambiguous, so that a failure
means the widget is broken, not that the ranking moved; the evaluation over blind question sets
(evaluate.py) measures the ranking.
"""

import json
import re
from typing import TYPE_CHECKING, NamedTuple, cast
from urllib.parse import urlsplit

import pytest

# pytest-bdd reads the annotations of the step functions when it runs them, so their types are imported
# here and not only for the type checkers.
from pages import (
    INDEX,
    PREFIX,
    Availability,  # noqa: TC002
    Exchange,
    Panel,
    in_course_order,
    path_and_fragment,
    prompt_api_calls,
)
from playwright.sync_api import Route, expect  # noqa: TC002 -- Playwright reads handler annotations
from pytest_bdd import given, parsers, scenarios, then, when

if TYPE_CHECKING:
    from pages import ContextOptionsDto, PageMaker, PromptApiDto, RequestLog
    from playwright.sync_api import Page

scenarios('../features')

PHONE: ContextOptionsDto = {'viewport': {'width': 390, 'height': 844}, 'has_touch': True}
HOME = 'home'


def is_solutions(path: str) -> bool:
    """True for a solutions page: its last path segment, not a substring (chapter 17 has one).

    Written here again on purpose, rather than imported from sections.py: the test must not share a
    mistake with the code it checks.
    """
    return path.split('#')[0].rstrip('/').split('/')[-1] == 'soluciones'


def luminance(css_color: str) -> float:
    red, green, blue = (int(v) for v in re.findall(r'\d+', css_color)[:3])
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue


class Box(NamedTuple):
    x: float
    y: float
    width: float
    height: float

    def overlaps(self, other: Box) -> bool:
        return not (
            self.x + self.width <= other.x
            or other.x + other.width <= self.x
            or self.y + self.height <= other.y
            or other.y + other.height <= self.y
        )


class Student:
    """What the scenario has done so far: the page, its panel, its requests, the questions asked."""

    def __init__(self, make_page: PageMaker) -> None:
        self.make_page = make_page
        self.prompt_api: PromptApiDto | None = None
        self.held: list[Route] = []
        self.questions: list[str] = []
        self.focus_stayed: list[bool] = []
        self.requests_before_panel = 0
        self._page: Page | None = None
        self._log: RequestLog | None = None

    def open(self, path: str, options: ContextOptionsDto | None = None) -> None:
        self._page, self._log = self.make_page('' if path == HOME else path, self.prompt_api, options)

    @property
    def page(self) -> Page:
        assert self._page is not None, 'the scenario has not opened a page yet'
        return self._page

    @property
    def log(self) -> RequestLog:
        assert self._log is not None, 'the scenario has not opened a page yet'
        return self._log

    @property
    def panel(self) -> Panel:
        return Panel(self.page)

    @property
    def last(self) -> Exchange:
        return Exchange(self.panel.exchanges.last)


@pytest.fixture
def student(make_page: PageMaker) -> Student:
    return Student(make_page)


# --- Given ---------------------------------------------------------------------------------------


@given(parsers.parse('the browser\'s own language model is "{availability}" and answers "{answer}"'))
def model_answers(student: Student, availability: Availability, answer: str) -> None:
    student.prompt_api = {'availability': availability, 'answer': answer}


@given('the browser\'s own language model is "available" and fails while answering')
def model_fails(student: Student) -> None:
    student.prompt_api = {'availability': 'available', 'answer': 'findall/3 junta todas las soluciones.', 'fail': True}


@given(parsers.parse('a student reading the page "{path}"'))
def reading(student: Student, path: str) -> None:
    student.open(path)


@given(parsers.parse('a student reading the page "{path}" on a phone'))
def reading_on_a_phone(student: Student, path: str) -> None:
    student.open(path, PHONE)


@given(parsers.parse('a student whose system prefers the "{scheme}" scheme, reading the page "{path}"'))
def reading_in_a_scheme(student: Student, scheme: str, path: str) -> None:
    student.open(path, {'color_scheme': 'dark' if scheme == 'dark' else 'light'})


@given('the student has opened the panel')
@when('the student has opened the panel')
def opened(student: Student) -> None:
    student.panel.open()


@given(parsers.parse('the student has asked "{question}"'))
@when(parsers.parse('the student asks "{question}"'))
def asks(student: Student, question: str) -> None:
    student.questions.append(question)
    student.panel.ask(question)


@given('the page has finished loading')
@when('the page has finished loading')
def loaded(student: Student) -> None:
    student.page.wait_for_load_state('networkidle')
    student.requests_before_panel = len(student.log.requests)
    student.log.external.clear()


@given("the course's index is slow to arrive")
def index_held(student: Student) -> None:
    def hold(route: Route) -> None:
        student.held.append(route)

    # A plain function: Playwright marks its handlers with an attribute, which list.append cannot take.
    student.page.route(f'**/{INDEX}', hold)


@given('the search worker cannot be downloaded')
def worker_unreachable(student: Student) -> None:
    student.page.route('**/javascripts/assistant/worker.js', lambda route: route.abort())


@given("the course's index cannot be downloaded")
def index_unreachable(student: Student) -> None:
    student.page.route(f'**/{INDEX}', lambda route: route.abort())


@given(parsers.parse("the course's index is of version {version:d}"))
def index_of_version(student: Student, version: int) -> None:
    body = json.dumps({'version': version, 'chunks': []})
    student.page.route(f'**/{INDEX}', lambda route: route.fulfill(body=body, content_type='application/json'))


@given(parsers.parse('the written answer says "{text}"'))
@then(parsers.parse('the written answer says "{text}"'))
def written_answer_says(student: Student, text: str) -> None:
    expect(student.last.written_answer).to_contain_text(text)


# --- When ----------------------------------------------------------------------------------------


@when(parsers.parse('the student opens the panel and asks "{question}"'))
def opens_and_asks(student: Student, question: str) -> None:
    student.panel.open()
    asks(student, question)


@when(parsers.parse('the student opens the panel and sends "{question}"'))
def opens_and_sends(student: Student, question: str) -> None:
    student.panel.open()
    student.questions.append(question)
    student.panel.send(question)


@when("the course's index arrives")
def index_arrives(student: Student) -> None:
    for _ in range(100):
        if student.held:
            break
        student.page.wait_for_timeout(100)
    assert student.held, 'the index was never requested'
    for route in student.held:
        route.continue_()


@when(parsers.parse('the student removes the question "{question}"'))
def removes(student: Student, question: str) -> None:
    exchange = student.panel.exchanges.filter(has_text=question)
    exchange.get_by_role('button', name='Quitar').click()


@when(parsers.parse('the student searches the site for "{text}"'))
def searches_site(student: Student, text: str) -> None:
    box = student.page.get_by_role('textbox', name='Búsqueda')
    box.click()
    box.fill(text)
    expect(student.page.locator('.md-search-result__item').nth(1)).to_be_visible()


@when('the student sends a question made of spaces')
def sends_blank(student: Student) -> None:
    student.panel.question.fill('   ')
    student.panel.submit.click()


@when(parsers.parse('the student types "{question}" and presses Enter'))
def types_and_enters(student: Student, question: str) -> None:
    student.panel.question.fill(question)
    student.panel.question.press('Enter')


@when(parsers.parse('the student follows the link of section "{number}"'))
def follows(student: Student, number: str) -> None:
    student.last.links.filter(has_text=re.compile(re.escape(number))).first.click()


@when('the student closes the panel')
def closes(student: Student) -> None:
    student.panel.close_button.click()


@when(parsers.parse('the student goes to the chapter "{name}" from the navigation'))
def navigates(student: Student, name: str) -> None:
    student.page.get_by_role('navigation').get_by_role('link', name=re.compile(re.escape(name))).first.click()
    expect(student.page).to_have_url(re.compile(r'capitulo-\d+-'))


@when('the student reloads the page')
def reloads(student: Student) -> None:
    student.page.reload()


@when(parsers.parse('the student presses "{key}"'))
def presses(student: Student, key: str) -> None:
    student.page.keyboard.press(key)


@when(parsers.parse('the student presses "{key}" {count:d} times'))
def presses_repeatedly(student: Student, key: str, count: int) -> None:
    for _ in range(count):
        student.page.keyboard.press(key)
        inside = cast('bool', student.panel.dialog.evaluate('d => d.contains(document.activeElement)'))
        student.focus_stayed.append(inside)


@when(parsers.parse('the student presses the button "{name}"'))
def presses_button(student: Student, name: str) -> None:
    student.panel.dialog.get_by_role('button', name=name).click()


@when('the student scrolls down and back up a little')
def scrolls(student: Student) -> None:
    student.page.mouse.wheel(0, 4000)
    student.page.wait_for_timeout(500)
    student.page.mouse.wheel(0, -400)
    student.page.wait_for_timeout(500)


@when(parsers.parse('the student switches the site to "{label}"'))
def switches_scheme(student: Student, label: str) -> None:
    scheme = cast('str | None', student.page.locator('body').get_attribute('data-md-color-scheme'))
    student.page.locator(f'label[title="{label}"]:visible').first.click()
    expect(student.page.locator('body')).not_to_have_attribute('data-md-color-scheme', scheme or '')


# --- Then ----------------------------------------------------------------------------------------


def answered(student: Student) -> Exchange:
    """The last exchange, once its answer is there."""
    exchange = student.last
    expect(exchange.where_to_read).to_be_visible()
    return exchange


@then(parsers.parse('"Dónde leerlo" links to "{location}"'))
def links_to(student: Student, location: str) -> None:
    assert PREFIX + location in answered(student).link_paths()


@then(parsers.parse('"Dónde leerlo" links to a section of the page "{page}"'))
def links_into(student: Student, page: str) -> None:
    assert any(p.startswith(PREFIX + page) for p in answered(student).link_paths())


@then('both answers list the same sections')
def same_sections(student: Student) -> None:
    exchanges = student.panel.exchanges
    earlier = Exchange(exchanges.nth(exchanges.count() - 2)).link_paths()
    assert sorted(earlier) == sorted(answered(student).link_paths())


@then('the sections of "Dónde leerlo" are in the order of the course')
def sections_in_course_order(student: Student) -> None:
    paths = answered(student).link_paths()
    assert len(paths) > 1
    assert in_course_order(student.page, paths)


@then('the passages follow the order of "Dónde leerlo"')
def passages_in_list_order(student: Student) -> None:
    exchange = answered(student)
    listed = exchange.link_paths()
    hrefs = cast('list[str]', exchange.passages.locator('footer a').evaluate_all('links => links.map(a => a.href)'))
    places = [listed.index(path_and_fragment(href)) for href in hrefs]
    assert places == sorted(places)


@then('the site search lists its results in the order of the course')
def site_search_in_course_order(student: Student) -> None:
    hrefs = cast(
        'list[str]',
        student.page.locator('.md-search-result__item > a').evaluate_all('links => links.map(a => a.href)'),
    )
    assert len(hrefs) > 1
    assert in_course_order(student.page, [path_and_fragment(href) for href in hrefs])


@then('"Dónde leerlo" lists between 1 and 5 different sections')
def lists_sections(student: Student) -> None:
    paths = answered(student).link_paths()
    assert 1 <= len(paths) <= 5
    assert len(paths) == len(set(paths))


@then('between 1 and 3 passages are shown, each with one link to a section of that list')
def passages_with_links(student: Student) -> None:
    exchange = answered(student)
    paths = exchange.link_paths()
    assert 1 <= exchange.passages.count() <= 3
    for passage in exchange.passages.all():
        link = passage.get_by_role('link')
        expect(link).to_have_count(1)
        assert path_and_fragment(cast('str', link.evaluate('a => a.href'))) in paths


@then(parsers.parse('"{word}" is highlighted in a passage'))
def highlighted(student: Student, word: str) -> None:
    marks = answered(student).passages.locator('mark').filter(has_text=re.compile(re.escape(word), re.I))
    expect(marks.first).to_be_visible()


@then('no link leads to a solutions page')
def no_solutions(student: Student) -> None:
    assert not [p for p in answered(student).link_paths() if is_solutions(p)]


@then(parsers.parse('the answer says "{text}"'))
def answer_says(student: Student, text: str) -> None:
    expect(student.last.article.get_by_text(re.compile(re.escape(text), re.I))).to_be_visible()


@then('the conversation is empty')
def conversation_empty(student: Student) -> None:
    expect(student.panel.exchanges).to_have_count(0)


@then(parsers.parse('the conversation has {count:d} exchange'))
@then(parsers.parse('the conversation has {count:d} exchanges'))
def conversation_has(student: Student, count: int) -> None:
    expect(student.panel.exchanges).to_have_count(count)


@then(parsers.parse('the first exchange mentions "{text}"'))
def first_mentions(student: Student, text: str) -> None:
    expect(student.panel.exchanges.first).to_contain_text(text)


@then(parsers.parse('the browser shows "{location}"'))
def shows(student: Student, location: str) -> None:
    expect(student.page).to_have_url(re.compile(re.escape(PREFIX + location) + '$'))


@then(parsers.parse('the heading "{anchor}" is in view'))
def heading_in_view(student: Student, anchor: str) -> None:
    # An attribute selector: an id that starts with a digit is not a valid CSS #id.
    expect(student.page.locator(f'[id="{anchor}"]')).to_be_in_viewport()


@then('the panel is closed')
def panel_closed(student: Student) -> None:
    expect(student.panel.dialog).to_be_hidden()


@then(parsers.parse('the button "{name}" is visible'))
def button_visible(student: Student, name: str) -> None:
    expect(student.page.get_by_role('button', name=name, exact=True)).to_be_visible()


@then(parsers.parse('the button "{name}" has the focus'))
def button_focused(student: Student, name: str) -> None:
    expect(student.page.get_by_role('button', name=name, exact=True)).to_be_focused()


@then('the question box has the focus')
def question_focused(student: Student) -> None:
    expect(student.panel.question).to_be_focused()


@then(parsers.parse("the course's index has been requested {count:d} time"))
@then(parsers.parse("the course's index has been requested {count:d} times"))
def index_requested(student: Student, count: int) -> None:
    assert student.log.requests_to(INDEX) == count


@then(parsers.parse('the panel says "{text}"'))
def panel_says(student: Student, text: str) -> None:
    expect(student.panel.dialog).to_contain_text(text)


@then(parsers.parse('the written answer does not show "{text}"'))
def written_answer_lacks(student: Student, text: str) -> None:
    expect(student.last.written_answer).not_to_contain_text(text)


@then(parsers.parse('the citation "{citation}" links to a section of "Dónde leerlo"'))
def citation_links(student: Student, citation: str) -> None:
    exchange = answered(student)
    link = exchange.written_answer.get_by_role('link', name=citation)
    expect(link).to_have_count(1)
    assert path_and_fragment(cast('str', link.evaluate('a => a.href'))) in exchange.link_paths()


@then(parsers.parse('the written answer says it was written by the "{author}"'))
def written_by(student: Student, author: str) -> None:
    expect(student.last.written_answer.get_by_text(re.compile(re.escape(author), re.I))).to_be_visible()


@then('the passages are still shown')
def passages_shown(student: Student) -> None:
    expect(answered(student).passages.first).to_be_visible()


@then('the model was asked once, with the question')
def asked_once(student: Student) -> None:
    prompts = [
        c.get('input', '') for c in prompt_api_calls(student.page) if c['method'] in {'prompt', 'promptStreaming'}
    ]
    assert len(prompts) == 1
    assert student.questions[-1] in prompts[0]


@then('there is no written answer')
def no_written_answer(student: Student) -> None:
    answered(student)
    expect(student.last.written_answer).to_have_count(0)


@then('no model session was created')
def no_session(student: Student) -> None:
    answered(student)
    assert not [c for c in prompt_api_calls(student.page) if c['method'] == 'create']


@then(parsers.parse('{created:d} model sessions were created and {closed:d} were closed'))
def sessions(student: Student, created: int, closed: int) -> None:
    student.page.wait_for_function(f"window.__promptApi.calls.filter(c => c.method === 'destroy').length >= {closed}")
    calls = prompt_api_calls(student.page)
    assert sum(c['method'] == 'create' for c in calls) == created
    assert sum(c['method'] == 'destroy' for c in calls) == closed


@then('no request went to another host after the panel opened')
def nothing_external(student: Student) -> None:
    assert student.log.external == []


@then(parsers.parse('no request carried "{marker}"'))
def marker_never_sent(student: Student, marker: str) -> None:
    for request in student.log.requests[student.requests_before_panel :]:
        assert marker not in request.url
        assert marker not in (request.post_data or '')


@then('every request was for a file of the site')
def only_site_files(student: Student) -> None:
    for request in student.log.requests[student.requests_before_panel :]:
        assert urlsplit(request.url).path.startswith(PREFIX)


@then('the focus never left the panel')
def focus_stayed(student: Student) -> None:
    assert student.focus_stayed
    assert all(student.focus_stayed)


@then('the panel covers the screen')
def covers_screen(student: Student) -> None:
    box = student.panel.dialog.bounding_box()
    viewport = student.page.viewport_size
    assert box is not None and viewport is not None
    assert box['width'] >= viewport['width'] - 1
    assert box['height'] >= 0.9 * viewport['height']


@then('the back-to-top button is visible')
def back_to_top_visible(student: Student) -> None:
    expect(student.page.locator('.md-top')).to_be_visible()


@then(parsers.parse('the button "{name}" does not overlap it'))
def no_overlap(student: Student, name: str) -> None:
    launcher = student.page.get_by_role('button', name=name, exact=True).bounding_box()
    top = student.page.locator('.md-top').bounding_box()
    assert launcher is not None and top is not None
    assert not Box(**launcher).overlaps(Box(**top))


@then(parsers.re(r'the panel is (?P<scheme>light|dark)'))
def panel_scheme(student: Student, scheme: str) -> None:
    colour = cast('str', student.panel.dialog.evaluate('d => getComputedStyle(d).backgroundColor'))
    assert (luminance(colour) > 128) == (scheme == 'light')
