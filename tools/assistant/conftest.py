"""Fixtures of the end-to-end tests of the course assistant.

The built site (`make docs assistant`) is served from `site/` under the same
path it has when published, /curso-de-prolog/, so that a widget that builds a
URL from the domain root instead of the site's base fails here and not in
production. Every request to another host is aborted and recorded: the tests
need no network, and the privacy test reads the record.

    uv run --frozen --group assistant pytest tools/assistant
    uv run --frozen --group assistant pytest tools/assistant --browser firefox

The panel is driven through `Panel`, which holds the whole contract between the
tests and the widget: accessible names, roles and the index's path. A change to
the widget's interface is a change here first.
"""

import functools
import json
import threading
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

import pytest
from playwright.sync_api import Page, expect, sync_playwright

ROOT = Path(__file__).resolve().parents[2]
SITE = ROOT / 'site'
PREFIX = '/curso-de-prolog/'
INDEX = 'assistant/index.json'

# Searching a 4 MB index the first time includes downloading and tokenising it.
TIMEOUT = 20_000


def pytest_addoption(parser):
    parser.addoption(
        '--browser', default='chromium', choices=['chromium', 'firefox', 'webkit'], help='browser to run the tests in'
    )


class SiteHandler(SimpleHTTPRequestHandler):
    """Serve site/ under PREFIX and nothing outside it, as GitHub Pages does."""

    def translate_path(self, path):
        if not urlsplit(path).path.startswith(PREFIX):
            return str(SITE / '__outside_the_site__')
        return super().translate_path('/' + path[len(PREFIX) :])

    def log_message(self, *args):
        pass


@pytest.fixture(scope='session')
def base():
    if not (SITE / INDEX).is_file():
        pytest.fail(f'no {INDEX} under site/: build the site and the index first (make docs assistant)')
    server = ThreadingHTTPServer(('127.0.0.1', 0), functools.partial(SiteHandler, directory=str(SITE)))
    threading.Thread(target=server.serve_forever, daemon=True).start()
    # 127.0.0.1 and not localhost: on Windows, localhost tries IPv6 first.
    yield f'http://127.0.0.1:{server.server_address[1]}{PREFIX}'
    server.shutdown()


@pytest.fixture(scope='session')
def browser(pytestconfig):
    with sync_playwright() as playwright:
        launched = getattr(playwright, pytestconfig.getoption('--browser')).launch()
        yield launched
        launched.close()


class Record:
    """Every request a page made: to the site, and the aborted ones to other hosts."""

    def __init__(self):
        self.requests = []
        self.external = []

    def count(self, path):
        return sum(1 for r in self.requests if urlsplit(r.url).path == PREFIX + path)


def open_context(browser, base, prompt_api=None, **options):
    """A browser context that only reaches the local site, optionally with a fake Prompt API."""
    context = browser.new_context(viewport={'width': 1200, 'height': 900}, **options)
    context.set_default_timeout(TIMEOUT)
    record = Record()
    origin = urlsplit(base).netloc

    def route(r):
        if urlsplit(r.request.url).netloc == origin:
            r.continue_()
        else:
            record.external.append(r.request)
            r.abort()

    context.route('**/*', route)
    context.on('request', lambda request: record.requests.append(request))
    if prompt_api is not None:
        context.add_init_script(path=str(Path(__file__).with_name('fake_prompt_api.js')))
        context.add_init_script(f'window.__promptApi.configure({json.dumps(prompt_api)})')
    return context, record


@pytest.fixture
def make_page(browser, base):
    """Open a page of the site; returns (page, record). Keyword arguments go to open_context."""
    contexts = []

    def make(path='', prompt_api=None, **options):
        context, record = open_context(browser, base, prompt_api, **options)
        contexts.append(context)
        page = context.new_page()
        page.goto(base + path)
        return page, record

    yield make
    for context in contexts:
        context.close()


@pytest.fixture
def page(make_page):
    """Chapter 7, in a browser without the Prompt API: the extraction path."""
    page, _ = make_page('capitulo-07-listas/')
    return page


class Panel:
    """The widget as a student sees it, through roles and accessible names only."""

    NAME = 'Preguntale al curso'

    def __init__(self, page: Page):
        self.page = page
        self.launcher = page.get_by_role('button', name=self.NAME)
        self.dialog = page.get_by_role('dialog', name=self.NAME)
        self.question = self.dialog.get_by_role('textbox', name='Tu pregunta')
        self.submit = self.dialog.get_by_role('button', name='Preguntar')
        self.close_button = self.dialog.get_by_role('button', name='Cerrar')
        self.log = self.dialog.get_by_role('log', name='Conversación')
        self.exchanges = self.log.get_by_role('article')

    def open(self):
        self.launcher.click()
        expect(self.dialog).to_be_visible()
        return self

    def ask(self, text):
        """Ask one question and wait for its answer; returns the answer's article."""
        before = self.exchanges.count()
        self.question.fill(text)
        self.submit.click()
        expect(self.exchanges).to_have_count(before + 1)
        exchange = Exchange(self.exchanges.nth(before))
        expect(exchange.where).to_be_visible()
        return exchange


class Exchange:
    """One question and its answer."""

    def __init__(self, article):
        self.article = article
        self.where = article.get_by_role('list', name='Dónde leerlo')
        self.links = self.where.get_by_role('link')
        self.passages = article.locator('blockquote')
        self.written = article.get_by_role('region', name='Respuesta escrita')

    def paths(self):
        """The links as the browser resolves them, path and fragment, e.g. /curso-de-prolog/x/#y."""
        urls = self.links.evaluate_all('links => links.map(a => a.href)')
        return [urlsplit(u).path + ('#' + urlsplit(u).fragment if urlsplit(u).fragment else '') for u in urls]


@pytest.fixture
def panel(page):
    return Panel(page).open()
