"""The course assistant's widget as the browser tests see it.

`Panel` holds the contract between the tests and the widget: accessible names, roles and the index's
path. A change to the widget's interface is a change here first. The settings of the fake Prompt API
(fake_prompt_api.js), the record of a page's requests and the page factory live here too, so the
step definitions import them instead of importing conftest.
"""

from typing import TYPE_CHECKING, Literal, NotRequired, Protocol, TypedDict, cast
from urllib.parse import urlsplit

from playwright.sync_api import expect

if TYPE_CHECKING:
    from playwright.sync_api import Locator, Page, Request

PREFIX = '/curso-de-prolog/'
INDEX = 'assistant/index.json'

type Availability = Literal['available', 'downloadable', 'downloading', 'unavailable']


class PromptApiDto(TypedDict):
    """The settings of the fake Prompt API."""

    availability: Availability
    answer: str
    fail: NotRequired[bool]


class PromptApiCallDto(TypedDict):
    """One call the fake Prompt API recorded."""

    method: Literal['availability', 'create', 'prompt', 'promptStreaming', 'destroy']
    input: NotRequired[str]


class ViewportDto(TypedDict):
    width: int
    height: int


class ContextOptionsDto(TypedDict, total=False):
    """The options of a browser context that the tests change."""

    viewport: ViewportDto
    color_scheme: Literal['light', 'dark']
    has_touch: bool


class RequestLog:
    """Every request a page made: to the site, and the aborted ones to other hosts."""

    def __init__(self) -> None:
        self.requests: list[Request] = []
        self.external: list[Request] = []

    def requests_to(self, path: str) -> int:
        return sum(1 for r in self.requests if urlsplit(r.url).path == PREFIX + path)


class PageMaker(Protocol):
    """Opens a page of the site in a fresh browser context (the make_page fixture)."""

    def __call__(
        self, path: str = '', prompt_api: PromptApiDto | None = None, options: ContextOptionsDto | None = None
    ) -> tuple[Page, RequestLog]: ...


def prompt_api_calls(page: Page) -> list[PromptApiCallDto]:
    """The calls the fake Prompt API recorded in this page."""
    return cast('list[PromptApiCallDto]', page.evaluate('window.__promptApi.calls'))


NAVIGATION_ORDER = """() => {
  const order = {};
  document.querySelectorAll('.md-nav--primary a.md-nav__link[href]').forEach((link, i) => {
    const path = new URL(link.href).pathname;
    if (!(path in order)) order[path] = i;
  });
  return order;
}"""


def navigation_order(page: Page) -> dict[str, int]:
    """The place of each page of the site in its navigation, by path: the order of the course."""
    return cast('dict[str, int]', page.evaluate(NAVIGATION_ORDER))


def in_course_order(page: Page, paths: list[str]) -> bool:
    """Whether the paths (with or without a fragment) follow the order of the course."""
    order = navigation_order(page)
    places = [order[path.split('#')[0]] for path in paths]
    return places == sorted(places)


def path_and_fragment(url: str) -> str:
    """/curso-de-prolog/x/#y from a full URL."""
    parts = urlsplit(url)
    return parts.path + (f'#{parts.fragment}' if parts.fragment else '')


class Exchange:
    """One question and its answer."""

    def __init__(self, article: Locator) -> None:
        self.article = article
        self.where_to_read = article.get_by_role('list', name='Dónde leerlo')
        self.links = self.where_to_read.get_by_role('link')
        self.passages = article.locator('blockquote')
        self.written_answer = article.get_by_role('region', name='Respuesta escrita')

    def link_paths(self) -> list[str]:
        """The links as the browser resolves them, path and fragment."""
        urls = cast('list[str]', self.links.evaluate_all('links => links.map(a => a.href)'))
        return [path_and_fragment(u) for u in urls]


class Panel:
    """The launcher and the dialog, through roles and accessible names only."""

    NAME = 'Preguntar al curso'

    def __init__(self, page: Page) -> None:
        self.page = page
        # exact=True: «Preguntar» is a substring of «Preguntar al curso».
        self.launcher = page.get_by_role('button', name=self.NAME, exact=True)
        self.dialog = page.get_by_role('dialog', name=self.NAME, exact=True)
        self.question = self.dialog.get_by_role('textbox', name='Pregunta', exact=True)
        self.submit = self.dialog.get_by_role('button', name='Preguntar', exact=True)
        self.close_button = self.dialog.get_by_role('button', name='Cerrar')
        self.status = self.dialog.get_by_role('status')
        self.log = self.dialog.get_by_role('log', name='Conversación')
        self.exchanges = self.log.get_by_role('article')

    def open(self) -> Panel:
        self.launcher.click()
        expect(self.dialog).to_be_visible()
        return self

    def send(self, text: str) -> Exchange:
        """Ask one question without waiting for its answer."""
        before = self.exchanges.count()
        self.question.fill(text)
        self.submit.click()
        expect(self.exchanges).to_have_count(before + 1)
        return Exchange(self.exchanges.nth(before))

    def ask(self, text: str) -> Exchange:
        """Ask one question and wait for its answer."""
        exchange = self.send(text)
        expect(exchange.where_to_read).to_be_visible()
        return exchange
