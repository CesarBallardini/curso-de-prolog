"""Pruebas de soluciones.py: los servicios se ejecutan como programas."""

import re
import shutil
import subprocess
from pathlib import Path

import pytest
import soluciones

AQUI = Path(__file__).parent


def arrancar(programa, directorio):
    """Arranca un servicio de Prolog; devuelve el proceso y su dirección base."""
    swipl = shutil.which('swipl')
    assert swipl is not None, 'swipl no está en el PATH'
    proceso = subprocess.Popen([swipl, '-q', programa], cwd=directorio, stdout=subprocess.PIPE, text=True)  # noqa: S603
    puerto = re.search(r'localhost:(\d+)', proceso.stdout.readline()).group(1)
    return proceso, f'http://127.0.0.1:{puerto}'


@pytest.fixture(scope='module')
def familia():
    """El servidor de servidor.pl."""
    proceso, base = arrancar('servidor.pl', AQUI)
    yield base
    proceso.kill()
    proceso.wait()


@pytest.fixture
def inscripciones():
    """Un servicio de Inscripciones nuevo para cada prueba: las inscripciones no se acumulan."""
    proceso, base = arrancar('servicio.pl', AQUI / 'inscripciones')
    yield soluciones.Inscripciones(base)
    proceso.kill()
    proceso.wait()


# Ejercicio 6.
def test_ficha_o_none(familia):
    assert soluciones.ficha_o_none(familia, 'ana')['edad'] == 41
    assert soluciones.ficha_o_none(familia, 'zoe') is None


# Ejercicio 13.
def test_ranking(inscripciones):
    assert inscripciones.ranking()[0] == {'legajo': 101, 'nombre': 'ana', 'promedio': 8.5}


def test_materias(inscripciones):
    assert len(inscripciones.materias()) == 7


def test_inscribir(inscripciones):
    inscripciones.inscribir(104, 'ssl')
    ssl = next(m for m in inscripciones.materias() if m['codigo'] == 'ssl')
    assert ssl['inscriptos'] == 1


def test_rechazada(inscripciones):
    with pytest.raises(soluciones.InscripcionRechazadaError) as rechazo:
        inscripciones.inscribir(105, 'log')
    assert rechazo.value.motivo == 'sin_vacantes'


def test_alumno_inexistente(inscripciones):
    with pytest.raises(soluciones.InscripcionRechazadaError) as rechazo:
        inscripciones.inscribir(999, 'log')
    assert rechazo.value.motivo == 'alumno_inexistente'


def test_dato_invalido(inscripciones):
    with pytest.raises(soluciones.DatoInvalidoError, match='integer'):
        inscripciones.inscribir('ciento cuatro', 'ssl')
