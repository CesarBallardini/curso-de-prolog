"""Pruebas de las soluciones del capítulo 29."""

from pathlib import Path

import consultas
import inscripciones_py as inscripciones
import janus_swi as janus
import pytest
import soluciones

AQUI = Path(__file__).parent

consultas.cargar()
inscripciones.cargar()


def test_hijos_de():
    assert soluciones.hijos_de('ana') == ['luis', 'eva']
    assert soluciones.hijos_de('eva') == []


def test_hermanos_de():
    assert soluciones.hermanos_de('luis') == ['eva']
    assert soluciones.hermanos_de('juan') == []


def test_texto_pegado_con_parentesis():
    # Ejercicio 5: el texto armado es edad_de(juan), halt(, E), que no se puede leer.
    with pytest.raises(janus.PrologError, match='Syntax error'):
        consultas.edad_armando_el_texto('juan), halt(')


def test_ligadura_con_parentesis():
    # Como ligadura, 'juan), halt(' es un átomo más, que no está en la base.
    with pytest.raises(consultas.PersonaDesconocidaError):
        consultas.edad('juan), halt(')


def test_edad_o_cero():
    assert soluciones.edad_o_cero('ana') == 41
    assert soluciones.edad_o_cero('zoe') == 0


def test_mayores_de_edad():
    personas = [{'nombre': 'ana', 'edad': 20}, {'nombre': 'luis', 'edad': 12}, {'nombre': 'eva', 'edad': 18}]
    assert soluciones.mayores_de_edad(personas) == ['ana', 'eva']


def test_clase_de_error():
    with pytest.raises(janus.PrologError) as error:
        janus.query_once('no_existe_este_predicado')
    assert soluciones.clase_de_error(error.value) == 'existence_error'


def test_clase_de_un_error_de_tipo():
    with pytest.raises(janus.PrologError) as error:
        janus.query_once('atom_length(X, 3)')
    assert soluciones.clase_de_error(error.value) == 'instantiation_error'


# Ejercicio 8: la segunda inscripción se rechaza porque el alumno ya la cursa.
def test_inscribir_dos_veces():
    guardado = inscripciones.estado()
    try:
        inscripciones.inscribir(104, 'ssl')
        with pytest.raises(inscripciones.InscripcionRechazadaError) as rechazo:
            inscripciones.inscribir(104, 'ssl')
        assert rechazo.value.motivo == 'ya_la_cursa'
    finally:
        inscripciones.restaurar(guardado)


# Ejercicios 10 y 11: las pruebas de plunit de soluciones.pl, que usa Python.
def test_plunit_de_soluciones():
    janus.consult(str(AQUI / 'soluciones.pl'))
    janus.consult(str(AQUI / 'soluciones.plt'))
    assert janus.query_once('run_tests(soluciones)')['truth']


def test_inscriptos():
    assert soluciones.inscriptos('log') == [
        {'legajo': 101, 'nombre': 'ana'},
        {'legajo': 102, 'nombre': 'bruno'},
        {'legajo': 104, 'nombre': 'diego'},
        {'legajo': 106, 'nombre': 'facundo'},
    ]
