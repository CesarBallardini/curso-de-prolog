"""Toma las dos capturas de las páginas web que muestra web.md.

    uv run --group apendice-a python ejemplos/capitulo-36/web/capturas.py

Arranca servidor.pl como lo hacen las pruebas (test_paginas.py), abre las
páginas en Chromium sin ventana, con Playwright, a 1000 píxeles de ancho, y
guarda las imágenes junto al capítulo: la página de la materia logica, y el
tablero de la partida de semilla 7 después de descubrir la celda 1-1 y de
marcar una celda oculta. No es una prueba: se ejecuta a mano cuando cambian
las páginas.
"""

from pathlib import Path

from playwright.sync_api import sync_playwright
from test_paginas import servidor

CAPITULO = Path(__file__).resolve().parents[3] / 'docs' / 'capitulo-36-interfaces-de-usuario'


def main() -> None:
    with servidor() as base, sync_playwright() as p:
        navegador = p.chromium.launch()
        pagina = navegador.new_page(viewport={'width': 1000, 'height': 600})
        pagina.goto(f'{base}/pagina/materias/log')
        pagina.screenshot(path=CAPITULO / 'pagina-materia.png', full_page=True)
        respuesta = pagina.request.post(
            f'{base}/partidas', data={'filas': 9, 'columnas': 9, 'minas': 10, 'semilla': 7}
        )
        pagina.goto(f'{base}/juego/{respuesta.json()["id"]}')
        pagina.locator('button[name=celda][value="1-1"]').click()
        pagina.get_by_label('marcar').check()
        pagina.locator('button[name=celda]').first.click()
        pagina.get_by_text('Minas sin marcar: 9').wait_for()
        pagina.screenshot(path=CAPITULO / 'pagina-tablero.png', full_page=True)
        navegador.close()


if __name__ == '__main__':
    main()
