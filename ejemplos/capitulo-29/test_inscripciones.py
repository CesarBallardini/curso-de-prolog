"""Pruebas de inscripciones_py.py e informes.py: el proyecto visto desde Python."""

import informes
import inscripciones_py as inscripciones
import pytest

inscripciones.cargar()


@pytest.fixture
def estado_intacto():
    """Guarda el estado del programa de Prolog y lo restaura al terminar la prueba."""
    guardado = inscripciones.estado()
    yield
    inscripciones.restaurar(guardado)


def test_ranking():
    ranking = inscripciones.ranking()
    assert ranking[0] == {'legajo': 101, 'nombre': 'ana', 'promedio': 8.5}
    assert [fila['legajo'] for fila in ranking] == [101, 104, 103, 106, 102]


def test_materias():
    materias = inscripciones.materias()
    assert len(materias) == 7
    assert materias[0] == {'codigo': 'am1', 'nombre': 'analisis_1', 'anio': 1, 'inscriptos': 5}


def test_inscribir(estado_intacto):
    inscripciones.inscribir(104, 'ssl')
    ssl = next(m for m in inscripciones.materias() if m['codigo'] == 'ssl')
    assert ssl['inscriptos'] == 1


def test_rechazada(estado_intacto):
    with pytest.raises(inscripciones.InscripcionRechazadaError) as rechazo:
        inscripciones.inscribir(105, 'log')
    assert rechazo.value.motivo == 'sin_vacantes'


def test_dato_invalido(estado_intacto):
    with pytest.raises(inscripciones.DatoInvalidoError, match='integer'):
        inscripciones.inscribir('ciento cuatro', 'ssl')


def test_estado_restaurado():
    # La prueba anterior inscribió y el estado se restauró: ssl sigue vacía.
    ssl = next(m for m in inscripciones.materias() if m['codigo'] == 'ssl')
    assert ssl['inscriptos'] == 0


def test_informe():
    lineas = informes.informe().splitlines()
    assert lineas[:3] == ['Ranking', '', ' 1. ana         101   8.50']
    assert lineas[-1] == 'bd   bases_de_datos     0'
