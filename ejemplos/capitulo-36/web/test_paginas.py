"""Pruebas de las páginas web del capítulo 36 en un navegador real.

El fixture base arranca `swipl -q servidor.pl` en otro proceso, lee de su
primera línea el puerto que eligió y lo detiene al terminar. Las pruebas abren
las páginas en Chromium sin ventana, con Playwright, y verifican lo que una
persona ve: títulos, textos, cantidades de elementos, enlaces seguidos con un
clic, formularios enviados y el tablero después de cada jugada. Nada se compara
por píxeles.

Las pruebas del formulario inscriben efectivamente en el servidor de la prueba, que
se descarta al terminar: los datos del programa no cambian.
"""

import re
import shutil
import subprocess
from contextlib import contextmanager
from pathlib import Path

import pytest
from playwright.sync_api import Page, expect, sync_playwright

AQUI = Path(__file__).parent


@contextmanager
def servidor():
    """Arranca servidor.pl y da su dirección base."""
    swipl = shutil.which('swipl')
    assert swipl is not None, 'swipl no está en el PATH'
    proceso = subprocess.Popen(  # noqa: S603
        [swipl, '-q', 'servidor.pl'], cwd=AQUI, stdout=subprocess.PIPE, text=True, errors='replace'
    )
    try:
        linea = proceso.stdout.readline()
        puerto = re.search(r'localhost:(\d+)', linea).group(1)
        # 127.0.0.1 y no localhost: en Windows, localhost prueba primero IPv6.
        yield f'http://127.0.0.1:{puerto}'
    finally:
        proceso.kill()
        proceso.wait()


@pytest.fixture(scope='module')
def base():
    with servidor() as url:
        yield url


@pytest.fixture(scope='module')
def navegador():
    with sync_playwright() as p:
        chromium = p.chromium.launch()
        yield chromium
        chromium.close()


@pytest.fixture
def pagina(navegador):
    contexto = navegador.new_context(viewport={'width': 1000, 'height': 800})
    yield contexto.new_page()
    contexto.close()


def nueva_partida(pagina: Page, base: str) -> str:
    """Crea en el servicio la partida de semilla 7 y da la dirección de su tablero."""
    respuesta = pagina.request.post(f'{base}/partidas', data={'filas': 9, 'columnas': 9, 'minas': 10, 'semilla': 7})
    assert respuesta.status == 201
    return f'{base}/juego/{respuesta.json()["id"]}'


def test_materias(pagina, base):
    pagina.goto(f'{base}/pagina/materias')
    expect(pagina).to_have_title('Materias')
    expect(pagina.locator('h1')).to_have_text('Materias')
    filas = pagina.locator('tr')
    expect(filas).to_have_count(8)
    expect(filas.nth(3)).to_have_text(re.compile(r'log\s*logica\s*4'))


def test_enlace(pagina, base):
    pagina.goto(f'{base}/pagina/materias')
    pagina.get_by_role('link', name='logica').click()
    expect(pagina).to_have_url(f'{base}/pagina/materias/log')
    expect(pagina.locator('h1')).to_have_text('logica')
    expect(pagina.locator('li')).to_have_count(4)
    expect(pagina.get_by_text('Promedio: 7.00')).to_be_visible()


def test_inscribir(pagina, base):
    pagina.goto(f'{base}/pagina/materias/ssl')
    expect(pagina.get_by_text('Promedio: sin notas')).to_be_visible()
    pagina.get_by_label('Legajo').fill('104')
    pagina.get_by_role('button', name='Inscribir').click()
    expect(pagina.get_by_text('Aceptada: 104 en ssl.')).to_be_visible()
    pagina.get_by_role('link', name='Volver').click()
    expect(pagina.locator('li')).to_have_text(['104 diego'])


def test_inscripcion_rechazada(pagina, base):
    pagina.goto(f'{base}/pagina/materias/ssl')
    pagina.get_by_label('Legajo').fill('103')
    pagina.get_by_role('button', name='Inscribir').click()
    expect(pagina.get_by_text('Rechazada: 103 en ssl, falta(log).')).to_be_visible()


def test_legajo_no_numerico(pagina, base):
    pagina.goto(f'{base}/pagina/materias/ssl')
    pagina.get_by_label('Legajo').fill('abc')
    with pagina.expect_response(lambda r: r.url.endswith('/pagina/inscribir')) as info:
        pagina.get_by_role('button', name='Inscribir').click()
    assert info.value.status == 400


def test_tablero(pagina, base):
    pagina.goto(nueva_partida(pagina, base))
    expect(pagina).to_have_title('Buscaminas')
    celdas = pagina.locator('button[name=celda]')
    expect(celdas).to_have_count(81)
    expect(pagina.get_by_text('Minas sin marcar: 10')).to_be_visible()
    # La celda 1-1 no tiene minas vecinas: descubrirla abre una región.
    pagina.locator('button[name=celda][value="1-1"]').click()
    expect(pagina.locator('button[name=celda][value="1-1"]')).to_have_count(0)
    ocultas = celdas.count()
    assert ocultas < 80
    # Marcar la primera celda oculta que queda.
    pagina.get_by_label('marcar').check()
    primera = celdas.first.get_attribute('value')
    celdas.first.click()
    expect(pagina.locator(f'button[name=celda][value="{primera}"]')).to_have_text('M')
    expect(pagina.get_by_text('Minas sin marcar: 9')).to_be_visible()
    expect(celdas).to_have_count(ocultas)
