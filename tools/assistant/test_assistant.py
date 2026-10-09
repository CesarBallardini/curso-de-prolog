"""End-to-end tests of the course assistant, in a real browser, through Playwright.

They check what a student sees and what leaves the browser: the panel, the
links to the sections and where they lead, the extracted passages, the written
answer when Chrome's Prompt API is there (a fake, see fake_prompt_api.js), the
conversation across navigation, and that no question is sent anywhere. Nothing
is compared by pixels.

Ranking quality is not measured here: that is the job of the evaluation over
the question set. The questions below are a few whose answer is unambiguous, so
that a failure means the widget is broken, not that the ranking moved.
"""

import re
from urllib.parse import urlsplit

import pytest
from conftest import INDEX, PREFIX, Panel
from playwright.sync_api import expect

FINDALL = PREFIX + 'capitulo-17-todas-las-soluciones/#172-findall3'
GREEN_CUT = PREFIX + 'capitulo-09-backtracking-y-corte/#95-corte-verde-y-corte-rojo'
CHAPTER_10 = PREFIX + 'capitulo-10-negacion-como-falla/'
NOT_COVERED = re.compile(r'no parece tratar', re.IGNORECASE)


def is_solutions(path):
    """True for a solutions page: its last path segment, not a substring (chapter 17 has one)."""
    return path.split('#')[0].rstrip('/').split('/')[-1] == 'soluciones'


# --- Loading -----------------------------------------------------------------


@pytest.mark.parametrize(
    'path', ['', 'capitulo-07-listas/', 'patrones/', 'capitulo-87-proyecto-preguntas-en-castellano/']
)
def test_launcher_on_every_kind_of_page(make_page, path):
    page, _ = make_page(path)
    expect(Panel(page).launcher).to_be_visible()


def test_index_is_fetched_when_the_panel_opens_not_before(make_page):
    page, record = make_page('capitulo-07-listas/')
    page.wait_for_load_state('networkidle')
    assert record.count(INDEX) == 0
    Panel(page).open().ask('¿Qué hace findall/3?')
    assert record.count(INDEX) == 1


def test_index_leaves_out_the_solutions_pages_only(page, base):
    chunks = page.request.get(base + INDEX).json()['chunks']
    locations = {c['location'] for c in chunks}
    assert not [loc for loc in locations if is_solutions(loc)]
    assert any(loc.startswith('capitulo-17-todas-las-soluciones/') for loc in locations)
    assert any(loc.startswith('capitulo-87-') for loc in locations)
    assert 'patrones/' in {loc.split('#')[0] for loc in locations}


# --- Answers by extraction (every browser) ----------------------------------


def test_predicate_name_finds_its_section(panel):
    answer = panel.ask('¿Qué hace findall/3?')
    assert FINDALL in answer.paths()
    expect(answer.passages.first).to_be_visible()
    expect(answer.passages.locator('mark').filter(has_text=re.compile('findall', re.I)).first).to_be_visible()


def test_words_of_a_title_find_the_section(panel):
    answer = panel.ask('¿Cuál es la diferencia entre corte verde y corte rojo?')
    assert GREEN_CUT in answer.paths()


def test_accents_do_not_matter(panel):
    with_accent = panel.ask('¿Qué es la negación como falla?').paths()
    without = panel.ask('que es la negacion como falla').paths()
    assert with_accent[0] == without[0]
    assert with_accent[0].startswith(CHAPTER_10)


def test_operator_is_kept_whole(panel):
    answer = panel.ask('¿Qué significa \\+ en una regla?')
    assert any(p.startswith(CHAPTER_10) for p in answer.paths())


def test_shape_of_an_answer(panel):
    answer = panel.ask('¿Cómo se recorre una lista con recursión?')
    paths = answer.paths()
    assert 1 <= len(paths) <= 5
    assert len(paths) == len(set(paths))
    assert 1 <= answer.passages.count() <= 3
    for passage in answer.passages.all():
        link = passage.get_by_role('link')
        expect(link).to_have_count(1)
        target = urlsplit(link.evaluate('a => a.href'))
        assert target.path + '#' + target.fragment in paths or target.path in paths


@pytest.mark.parametrize(
    'question',
    [
        'soluciones del capítulo 10',
        'solución del ejercicio 7.1',
        '¿Cuál es la respuesta del ejercicio de append/3?',
    ],
)
def test_never_links_a_solutions_page(panel, question):
    answer = panel.ask(question)
    assert not [p for p in answer.paths() if is_solutions(p)]


def test_question_outside_the_course(panel):
    answer = panel.ask('¿Cómo se prepara una pizza napolitana?')
    expect(answer.article.get_by_text(NOT_COVERED)).to_be_visible()


def test_empty_question_is_not_asked(panel):
    panel.question.fill('   ')
    panel.submit.click()
    expect(panel.exchanges).to_have_count(0)


def test_enter_asks(panel):
    panel.question.fill('¿Qué hace findall/3?')
    panel.question.press('Enter')
    expect(panel.exchanges).to_have_count(1)


def test_link_leads_to_the_section(panel):
    answer = panel.ask('¿Qué hace findall/3?')
    answer.links.filter(has_text=re.compile('17.2')).first.click()
    page = panel.page
    expect(page).to_have_url(re.compile(re.escape(FINDALL) + '$'))
    expect(page.locator('#172-findall3')).to_be_in_viewport()


# --- The conversation across pages -------------------------------------------


def test_instant_navigation_keeps_the_conversation_and_the_index(make_page):
    page, record = make_page('capitulo-07-listas/')
    panel = Panel(page).open()
    panel.ask('¿Qué hace findall/3?')
    panel.close_button.click()
    page.get_by_role('navigation').get_by_role('link', name=re.compile('Backtracking y corte')).first.click()
    expect(page).to_have_url(re.compile('capitulo-09-backtracking-y-corte/'))
    panel.open()
    expect(panel.exchanges).to_have_count(1)
    panel.ask('¿Qué es el corte rojo?')
    assert record.count(INDEX) == 1


def test_reload_keeps_the_conversation(page):
    panel = Panel(page).open()
    panel.ask('¿Qué hace findall/3?')
    page.reload()
    panel = Panel(page).open()
    expect(panel.exchanges).to_have_count(1)
    expect(panel.exchanges.first).to_contain_text('findall/3')


# --- Nothing leaves the browser ----------------------------------------------


def test_the_question_goes_nowhere(make_page):
    page, record = make_page('capitulo-07-listas/')
    page.wait_for_load_state('networkidle')
    record.external.clear()
    first = len(record.requests)
    marker = 'zqxjvw'
    Panel(page).open().ask(f'¿Qué hace findall/3? {marker}')
    later = record.requests[first:]
    assert record.external == []
    for request in later:
        assert marker not in request.url
        assert marker not in (request.post_data or '')
        assert urlsplit(request.url).path.startswith(PREFIX)


# --- The written answer (Chrome's Prompt API, faked) -------------------------

WRITTEN = 'findall/3 junta todas las soluciones en una lista [1]. Algo que ningún fragmento dice [99].'


def test_written_answer_cites_real_sections_only(make_page):
    page, _ = make_page('capitulo-07-listas/', prompt_api={'availability': 'available', 'answer': WRITTEN})
    answer = Panel(page).open().ask('¿Qué hace findall/3?')
    expect(answer.written).to_be_visible()
    expect(answer.written).to_contain_text('junta todas las soluciones')
    expect(answer.written).not_to_contain_text('[99]')
    citation = answer.written.get_by_role('link', name='[1]')
    expect(citation).to_have_count(1)
    target = urlsplit(citation.evaluate('a => a.href'))
    assert target.path + '#' + target.fragment in answer.paths()
    expect(answer.written.get_by_text(re.compile('modelo del navegador', re.I))).to_be_visible()
    # The extraction stays under the written answer.
    expect(answer.passages.first).to_be_visible()
    calls = page.evaluate('window.__promptApi.calls')
    prompts = [c['input'] for c in calls if c['method'] in ('prompt', 'promptStreaming')]
    assert len(prompts) == 1
    assert '¿Qué hace findall/3?' in prompts[0]


@pytest.mark.parametrize('availability', ['downloadable', 'downloading', 'unavailable'])
def test_model_not_on_the_device_is_never_downloaded(make_page, availability):
    page, _ = make_page('capitulo-07-listas/', prompt_api={'availability': availability, 'answer': WRITTEN})
    answer = Panel(page).open().ask('¿Qué hace findall/3?')
    expect(answer.passages.first).to_be_visible()
    expect(answer.written).to_have_count(0)
    calls = page.evaluate('window.__promptApi.calls')
    assert [c for c in calls if c['method'] == 'create'] == []


def test_failing_model_leaves_the_extraction(make_page):
    page, _ = make_page(
        'capitulo-07-listas/', prompt_api={'availability': 'available', 'answer': WRITTEN, 'fail': True}
    )
    answer = Panel(page).open().ask('¿Qué hace findall/3?')
    expect(answer.passages.first).to_be_visible()
    assert FINDALL in answer.paths()
    expect(answer.written).not_to_contain_text('junta todas las soluciones')


def test_without_the_prompt_api_there_is_no_written_answer(panel):
    answer = panel.ask('¿Qué hace findall/3?')
    expect(answer.written).to_have_count(0)


# --- Keyboard, phone, dark mode ----------------------------------------------


def test_escape_closes_and_gives_the_focus_back(panel):
    expect(panel.question).to_be_focused()
    panel.page.keyboard.press('Escape')
    expect(panel.dialog).to_be_hidden()
    expect(panel.launcher).to_be_focused()


def test_close_button_gives_the_focus_back(panel):
    panel.close_button.click()
    expect(panel.dialog).to_be_hidden()
    expect(panel.launcher).to_be_focused()


def test_focus_stays_in_the_panel(panel):
    panel.ask('¿Qué hace findall/3?')
    for _ in range(25):
        panel.page.keyboard.press('Tab')
        assert panel.dialog.evaluate('d => d.contains(document.activeElement)')


def test_phone_gets_the_whole_screen(make_page):
    page, _ = make_page('capitulo-07-listas/', viewport={'width': 390, 'height': 844}, has_touch=True)
    panel = Panel(page).open()
    box = panel.dialog.bounding_box()
    assert box['width'] >= 389
    assert box['height'] >= 0.9 * 844


def luminance(css_color):
    r, g, b = (int(v) for v in re.findall(r'\d+', css_color)[:3])
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def test_panel_follows_the_colour_scheme(make_page):
    colours = {}
    for scheme in ('light', 'dark'):
        page, _ = make_page('capitulo-07-listas/', color_scheme=scheme)
        dialog = Panel(page).open().dialog
        colours[scheme] = luminance(dialog.evaluate('d => getComputedStyle(d).backgroundColor'))
    assert colours['light'] > 128 > colours['dark']
