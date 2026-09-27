"""Pruebas del ejercicio 14: el adaptador HTTP contra el servicio del Buscaminas.

El fixture arranca servicio_buscaminas.pl como programa. La aplicación y la
interfaz son las del capítulo 29, sin cambios: aquí juegan contra el servicio.
Una última prueba verifica que las dependencias siguen apuntando hacia el
dominio con el adaptador nuevo.
"""

import ast
import re
import shutil
import subprocess
from pathlib import Path

import pytest
from buscaminas import tui
from buscaminas.adaptador_http import ReglasEnServicio
from buscaminas.aplicacion import Juego

PAQUETE = Path(__file__).parent / 'buscaminas'


@pytest.fixture(scope='module')
def reglas():
    """Arranca el servicio del Buscaminas; devuelve su fábrica de partidas."""
    swipl = shutil.which('swipl')
    assert swipl is not None, 'swipl no está en el PATH'
    proceso = subprocess.Popen(  # noqa: S603
        [swipl, '-q', 'servicio_buscaminas.pl'], cwd=PAQUETE, stdout=subprocess.PIPE, text=True
    )
    try:
        puerto = re.search(r'localhost:(\d+)', proceso.stdout.readline()).group(1)
        yield ReglasEnServicio(f'http://127.0.0.1:{puerto}')
    finally:
        proceso.kill()
        proceso.wait()


# Con la semilla 42, las minas de un 5 x 5 con 4 son las del capítulo 28.
def test_partida_nueva(reglas):
    partida = reglas.partida_al_azar(5, 5, 4, 42)
    assert (partida.filas, partida.columnas, partida.estado) == (5, 5, 'sigue')
    assert partida.tablero(mostrar_minas=False) == ['#####'] * 5


def test_perder(reglas):
    partida = reglas.partida_al_azar(5, 5, 4, 42)
    partida.marcar(1, 1)
    partida.descubrir(2, 3)
    assert partida.estado == 'perdio'
    assert partida.tablero(mostrar_minas=True) == ['M####', '##*##', '#*#*#', '#####', '*####']


def test_fuera_del_tablero(reglas):
    partida = reglas.partida_al_azar(5, 5, 4, 42)
    with pytest.raises(ValueError, match='celda_del_tablero'):
        partida.descubrir(9, 9)


def test_parametros_invalidos(reglas):
    with pytest.raises(ValueError, match='positive_integer'):
        reglas.partida_al_azar(0, 5, 4, 42)


# Con la semilla 42, la mina de un 2 x 2 con 1 está en 1-1.
def test_la_interfaz_contra_el_servicio(reglas):
    juego = Juego(reglas.partida_al_azar(2, 2, 1, 42))
    for orden in ['derecha', 'descubrir', 'abajo', 'descubrir', 'izquierda', 'descubrir']:
        assert tui.aplicar(juego, orden)
    assert juego.partida.estado == 'gano'
    assert tui.pantalla(juego)[2:4] == ['│ *  1 │', '│[1] 1 │']


def importados(modulo):
    """Devuelve los nombres de los módulos que importa un módulo del paquete."""
    arbol = ast.parse((PAQUETE / f'{modulo}.py').read_text(encoding='utf-8'))
    nombres = set()
    for nodo in ast.walk(arbol):
        if isinstance(nodo, ast.Import):
            nombres |= {alias.name for alias in nodo.names}
        elif isinstance(nodo, ast.ImportFrom):
            nombres.add(nodo.module)
    return nombres


@pytest.mark.parametrize(
    ('modulo', 'prohibidos'),
    [
        ('dominio', {'janus_swi', 'curses', 'urllib.request', 'buscaminas.aplicacion', 'buscaminas.tui'}),
        ('aplicacion', {'janus_swi', 'curses', 'buscaminas.tui', 'buscaminas.adaptador_http'}),
        ('adaptador_http', {'janus_swi', 'curses', 'buscaminas.aplicacion', 'buscaminas.tui'}),
        ('tui', {'janus_swi', 'urllib.request', 'buscaminas.adaptador_prolog', 'buscaminas.adaptador_http'}),
    ],
)
def test_dependencias_hacia_el_dominio(modulo, prohibidos):
    assert not importados(modulo) & prohibidos
