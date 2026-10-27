"""Pruebas de cliente.py, contra servidor.pl ejecutado como programa.

El fixture servidor arranca `swipl -q servidor.pl` en otro proceso, lee de
su primera línea el puerto que eligió, y lo detiene al terminar las pruebas.
"""

import re
import shutil
import subprocess
from pathlib import Path

import cliente
import pytest

AQUI = Path(__file__).parent


@pytest.fixture(scope='module')
def base():
    """Arranca el servidor de Prolog y devuelve su dirección base."""
    swipl = shutil.which('swipl')
    assert swipl is not None, 'swipl no está en el PATH'
    proceso = subprocess.Popen(  # noqa: S603
        [swipl, '-q', 'servidor.pl'], cwd=AQUI, stdout=subprocess.PIPE, text=True
    )
    try:
        linea = proceso.stdout.readline()
        puerto = re.search(r'localhost:(\d+)', linea).group(1)
        # 127.0.0.1 y no localhost: en Windows, localhost prueba primero IPv6, y
        # cada pedido espera antes de volver a IPv4.
        yield f'http://127.0.0.1:{puerto}'
    finally:
        proceso.kill()
        proceso.wait()


def test_ficha(base):
    assert cliente.ficha(base, 'ana') == {'nombre': 'ana', 'edad': 41, 'hijos': ['luis', 'eva']}


def test_persona_desconocida(base):
    with pytest.raises(cliente.PersonaDesconocidaError):
        cliente.ficha(base, 'zoe')


def test_nietos(base):
    assert cliente.nietos(base, 'juan') == ['luis', 'eva']


def test_nombre_con_espacios(base):
    assert cliente.nietos(base, 'juan pérez') == []


def test_cambiar_edad(base):
    assert cliente.cambiar_edad(base, 'eva', 9) == 201
    assert cliente.ficha(base, 'eva')['edad'] == 9


def test_edad_negativa(base):
    assert cliente.cambiar_edad(base, 'eva', -1) == 400
