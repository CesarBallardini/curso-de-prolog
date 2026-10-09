"""Fixtures shared by the course assistant's tests.

The built site (`make docs`) is served from `site/` under the path it has when published,
/curso-de-prolog/, so that a widget that builds a URL from the domain root instead of the site's base
fails here and not in production. Every request to another host is aborted and recorded: the tests
need no network, and the privacy scenario reads the record. `--base URL` runs the browser tests against
a published site instead, after a deploy.

    uv run --frozen --group assistant pytest tools/assistant/tests
    uv run --frozen --group assistant pytest tools/assistant/tests -m bdd --browser firefox
    uv run --frozen --group assistant pytest tools/assistant/tests -m bdd --base https://katra.ballardini.com.ar/curso-de-prolog/
"""

import json
import sys
from pathlib import Path
from typing import TYPE_CHECKING, cast
from urllib.parse import urlsplit

import pytest

# Playwright reads the annotations of the handlers it is given when it calls them, so the types of their
# parameters are imported here and not only for the type checkers.
from playwright.sync_api import Request, Route, sync_playwright  # noqa: TC002

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import sections as course  # noqa: E402
from pages import INDEX, PREFIX, ContextOptionsDto, PageMaker, PromptApiDto, RequestLog, ViewportDto  # noqa: E402

if TYPE_CHECKING:
    from collections.abc import Iterator

    from playwright.sync_api import Browser, BrowserContext, Page

# Searching a 6 MB index the first time includes downloading and tokenising it.
TIMEOUT = 20_000
# Wider than Material's breakpoint for the navigation sidebar (1 220 px), so its links can be clicked.
VIEWPORT: ViewportDto = {'width': 1280, 'height': 900}
FAKE_PROMPT_API = Path(__file__).with_name('fake_prompt_api.js')
# The markers of each test directory: every test that needs a browser is e2e.
MARKERS = {'unit': ['unit'], 'integration': ['integration'], 'e2e': ['e2e'], 'acceptance': ['bdd', 'e2e']}


def pytest_addoption(parser: pytest.Parser) -> None:
    parser.addoption(
        '--browser', default='chromium', choices=['chromium', 'firefox', 'webkit'], help='browser to run the tests in'
    )
    parser.addoption('--base', help='URL of a published site to test instead of the local build')


def pytest_collection_modifyitems(items: list[pytest.Item]) -> None:
    """Mark each test after its directory: unit/, integration/, e2e/ or acceptance/."""
    for item in items:
        for part in item.path.parts:
            for marker in MARKERS.get(part, []):
                item.add_marker(marker)


@pytest.fixture(scope='session')
def base(pytestconfig: pytest.Config) -> Iterator[str]:
    """The URL of the site under test, ending in /curso-de-prolog/."""
    published = cast('str | None', pytestconfig.getoption('--base'))
    if published:
        yield published.rstrip('/') + '/'
        return
    if not (course.SITE / INDEX).is_file():
        pytest.fail(f'no {INDEX} under site/: build the site first (make docs)')
    site = course.serve_site()
    assert urlsplit(site.base).path == PREFIX
    yield site.base
    site.server.shutdown()


@pytest.fixture(scope='session')
def browser(pytestconfig: pytest.Config) -> Iterator[Browser]:
    name = cast('str', pytestconfig.getoption('--browser'))
    with sync_playwright() as playwright:
        launched = {'chromium': playwright.chromium, 'firefox': playwright.firefox, 'webkit': playwright.webkit}[
            name
        ].launch()
        yield launched
        launched.close()


def open_context(
    browser: Browser, base: str, prompt_api: PromptApiDto | None, options: ContextOptionsDto
) -> tuple[BrowserContext, RequestLog]:
    """A browser context that only reaches the site under test, optionally with a fake Prompt API."""
    context = browser.new_context(
        viewport=options.get('viewport', VIEWPORT),
        color_scheme=options.get('color_scheme'),
        has_touch=options.get('has_touch'),
    )
    context.set_default_timeout(TIMEOUT)
    log = RequestLog()
    origin = urlsplit(base).netloc

    def keep_local(route: Route) -> None:
        if urlsplit(route.request.url).netloc == origin:
            route.continue_()
        else:
            log.external.append(route.request)
            route.abort()

    context.route('**/*', keep_local)

    def record(request: Request) -> None:
        log.requests.append(request)

    # A plain function: Playwright marks its listeners with an attribute, which neither a bound method
    # nor a built-in such as list.append can take.
    context.on('request', record)
    if prompt_api is not None:
        context.add_init_script(path=str(FAKE_PROMPT_API))
        context.add_init_script(f'window.__promptApi.configure({json.dumps(prompt_api)})')
    return context, log


@pytest.fixture
def make_page(browser: Browser, base: str) -> Iterator[PageMaker]:
    """Open a page of the site in a fresh context; returns the page and its request log."""
    contexts: list[BrowserContext] = []

    def make(
        path: str = '', prompt_api: PromptApiDto | None = None, options: ContextOptionsDto | None = None
    ) -> tuple[Page, RequestLog]:
        context, log = open_context(browser, base, prompt_api, options or {})
        contexts.append(context)
        page = context.new_page()
        page.goto(base + path)
        return page, log

    yield make
    for context in contexts:
        context.close()
