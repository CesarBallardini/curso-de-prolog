"""Pruebas del ejercicio 13: el Buscaminas con puertos y adaptadores.

La aplicación y la interfaz se prueban con una partida de prueba escrita en
Python, que cumple el puerto: no necesitan Prolog. El adaptador de Prolog se
prueba contra las reglas de buscaminas.pl. Una última prueba verifica que las
dependencias apuntan hacia el dominio.
"""

import ast
from pathlib import Path

import pytest
from buscaminas import tui
from buscaminas.adaptador_prolog import ReglasEnProlog
from buscaminas.aplicacion import Juego

PAQUETE = Path(__file__).parent / 'buscaminas'


class PartidaDePrueba:
    """Una partida de 3 x 3 sin reglas: registra las jugadas y se gana o se pierde a pedido."""

    filas = 3
    columnas = 3

    def __init__(self):
        """Empieza sin jugadas, con el estado sigue."""
        self.estado = 'sigue'
        self.jugadas = []

    def descubrir(self, fila, columna):
        """Registra la jugada."""
        self.jugadas.append(('descubrir', fila, columna))

    def marcar(self, fila, columna):
        """Registra la jugada."""
        self.jugadas.append(('marcar', fila, columna))

    def tablero(self, mostrar_minas):
        """Devuelve un tablero fijo, con * en 1-1 si se piden las minas."""
        return ['*##' if mostrar_minas else '###', '###', '###']


# --- La aplicación, con la partida de prueba ---------------------------------


def test_cursor_sin_salir_del_tablero():
    juego = Juego(PartidaDePrueba())
    juego.mover(-1, -1)
    assert (juego.fila, juego.columna) == (1, 1)
    juego.mover(5, 5)
    assert (juego.fila, juego.columna) == (3, 3)


def test_ordenes_en_el_cursor():
    partida = PartidaDePrueba()
    juego = Juego(partida)
    juego.mover(1, 2)
    juego.marcar()
    juego.descubrir()
    assert partida.jugadas == [('marcar', 2, 3), ('descubrir', 2, 3)]


def test_sin_jugadas_al_terminar():
    partida = PartidaDePrueba()
    partida.estado = 'perdio'
    juego = Juego(partida)
    juego.descubrir()
    juego.mover(1, 1)
    assert partida.jugadas == []
    assert (juego.fila, juego.columna) == (1, 1)
    assert juego.tablero()[0] == '*##'


# --- La interfaz, con la partida de prueba -----------------------------------


def test_pantalla():
    assert tui.pantalla(Juego(PartidaDePrueba())) == [
        'Buscaminas',
        '┌─────────┐',
        '│[#] #  # │',
        '│ #  #  # │',
        '│ #  #  # │',
        '└─────────┘',
        '',
        tui.AYUDA,
    ]


def test_ordenes_de_la_interfaz():
    partida = PartidaDePrueba()
    juego = Juego(partida)
    for orden in ['abajo', 'derecha', 'derecha', 'descubrir', None]:
        assert tui.aplicar(juego, orden)
    assert partida.jugadas == [('descubrir', 2, 3)]
    assert not tui.aplicar(juego, 'salir')


def test_pantalla_al_perder():
    partida = PartidaDePrueba()
    partida.estado = 'perdio'
    lineas = tui.pantalla(Juego(partida))
    assert lineas[2] == '│[*] #  # │'
    assert lineas[-2:] == [tui.MENSAJES['perdio'], 'q: salir']


# --- El adaptador, con las reglas de Prolog ----------------------------------


@pytest.fixture(scope='module')
def reglas():
    """Carga las reglas de Prolog una vez para todas las pruebas del adaptador."""
    return ReglasEnProlog()


def test_ganar_en_prolog(reglas):
    juego = Juego(reglas.partida_con_minas(3, 3, [(1, 1)]))
    juego.mover(2, 2)
    juego.descubrir()
    assert juego.partida.estado == 'gano'
    assert juego.tablero() == ['*1.', '11.', '...']


def test_marcar_en_prolog(reglas):
    partida = reglas.partida_con_minas(3, 3, [(1, 1)])
    partida.marcar(2, 2)
    assert partida.tablero(mostrar_minas=False) == ['###', '#M#', '###']


def test_fuera_del_tablero(reglas):
    partida = reglas.partida_con_minas(3, 3, [(1, 1)])
    with pytest.raises(ValueError, match='fuera del tablero'):
        partida.descubrir(4, 1)


def test_semilla(reglas):
    # Con la semilla 42, las minas de un 5 x 5 con 4 son las del capítulo 27.
    partida = reglas.partida_al_azar(5, 5, 4, 42)
    partida.descubrir(2, 3)
    assert partida.estado == 'perdio'
    assert partida.tablero(mostrar_minas=True) == ['#####', '##*##', '#*#*#', '#####', '*####']


def test_la_interfaz_con_prolog(reglas):
    juego = Juego(reglas.partida_con_minas(3, 3, [(1, 1)]))
    for orden in ['abajo', 'abajo', 'derecha', 'derecha', 'descubrir']:
        tui.aplicar(juego, orden)
    assert tui.pantalla(juego)[2:5] == ['│ *  1  . │', '│ 1  1  . │', '│ .  . [.]│']


# --- La dirección de las dependencias ----------------------------------------


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
        ('dominio', {'janus_swi', 'curses', 'buscaminas.aplicacion', 'buscaminas.tui'}),
        ('aplicacion', {'janus_swi', 'curses', 'buscaminas.tui', 'buscaminas.adaptador_prolog'}),
        ('adaptador_prolog', {'curses', 'buscaminas.aplicacion', 'buscaminas.tui'}),
        ('tui', {'janus_swi', 'buscaminas.adaptador_prolog'}),
    ],
)
def test_dependencias_hacia_el_dominio(modulo, prohibidos):
    assert not importados(modulo) & prohibidos
