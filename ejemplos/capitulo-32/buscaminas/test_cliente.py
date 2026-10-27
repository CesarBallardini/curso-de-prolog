"""Pruebas de cliente.py, contra buscaminas.pl --servicio ejecutado como programa."""

import re
import shutil
import subprocess
from pathlib import Path

import cliente
import pytest

AQUI = Path(__file__).parent


@pytest.fixture(scope='module')
def base():
    """Arranca el programa como servicio y devuelve su dirección base."""
    swipl = shutil.which('swipl')
    assert swipl is not None, 'swipl no está en el PATH'
    proceso = subprocess.Popen(  # noqa: S603
        [swipl, '-q', 'buscaminas.pl', '--servicio'], cwd=AQUI, stdout=subprocess.PIPE, text=True
    )
    try:
        puerto = re.search(r'localhost:(\d+)', proceso.stdout.readline()).group(1)
        yield f'http://127.0.0.1:{puerto}'
    finally:
        proceso.kill()
        proceso.wait()


# Con la semilla 42, las minas de un 5 x 5 con 4 son 2-3, 3-2, 3-4 y 5-1.
def test_perder(base):
    partida = cliente.Partida(base, 5, 5, 4, semilla=42)
    assert partida.tablero == ['#####'] * 5
    partida.descubrir(2, 3)
    assert partida.estado == 'perdio'
    assert partida.tablero == ['#####', '##*##', '#*#*#', '#####', '*####']


def test_ganar(base):
    # Con la semilla 42, la mina de un 2 x 2 con 1 está en 1-1.
    partida = cliente.Partida(base, 2, 2, 1, semilla=42)
    for fila, columna in [(1, 2), (2, 1), (2, 2)]:
        partida.descubrir(fila, columna)
    assert partida.estado == 'gano'


def test_marcar(base):
    partida = cliente.Partida(base, 5, 5, 4, semilla=42)
    partida.marcar(2, 3)
    assert partida.minas_restantes == 3
    assert partida.tablero[1] == '##M##'


def test_sin_sugerencia(base):
    assert cliente.Partida(base, 5, 5, 4, semilla=42).sugerencia() is None


def test_error(base):
    partida = cliente.Partida(base, 5, 5, 4, semilla=42)
    with pytest.raises(ValueError, match='celda_del_tablero'):
        partida.descubrir(9, 9)
    with pytest.raises(ValueError, match='cantidad_de_minas'):
        cliente.Partida(base, 2, 2, 4)
