"""Pruebas de consultas.py: las reglas de familia.pl, vistas desde Python."""

import consultas
import janus_swi as janus
import pytest

consultas.cargar()


def test_es_abuelo():
    assert consultas.es_abuelo('juan', 'luis')
    assert not consultas.es_abuelo('ana', 'luis')


def test_nietos_de():
    assert consultas.nietos_de('juan') == ['luis', 'eva']


def test_sin_nietos():
    assert consultas.nietos_de('eva') == []
    assert consultas.primer_nieto('eva') is None


def test_primer_nieto():
    assert consultas.primer_nieto('juan') == 'luis'


def test_ficha():
    assert consultas.ficha('ana') == {'nombre': 'ana', 'edad': 41, 'hijos': ['luis', 'eva']}


def test_ficha_desconocida():
    assert consultas.ficha('zoe') is None


def test_edad():
    assert consultas.edad('juan') == 68


def test_persona_desconocida():
    with pytest.raises(consultas.PersonaDesconocidaError):
        consultas.edad('zoe')


def test_error_de_tipo():
    with pytest.raises(TypeError, match='atom'):
        consultas.edad(3)


def test_texto_armado_con_mayuscula():
    # 'Ana' pegado en el texto es una variable de Prolog, no un átomo.
    with pytest.raises(janus.PrologError, match='not sufficiently instantiated'):
        consultas.edad_armando_el_texto('Ana')


def test_ligadura_con_mayuscula():
    # Como ligadura, 'Ana' es el átomo 'Ana', que no está en la base.
    with pytest.raises(consultas.PersonaDesconocidaError):
        consultas.edad('Ana')


def test_datos_que_cruzan():
    consulta = 'X = [hola, "hola", 3, 2.5, a-1, _{a: 1}], Y = 12345678901234567890'
    respuesta = janus.query_once(consulta)
    assert respuesta['X'] == ['hola', 'hola', 3, 2.5, ('a', 1), {'a': 1}]
    assert respuesta['Y'] == 12345678901234567890


def test_cadena_de_python_es_atomo():
    assert janus.query_once('atom(S)', {'S': 'hola'})['truth']


def test_compuesto_no_cruza():
    with pytest.raises(janus.PrologError, match='py_term'):
        janus.query_once('X = f(x)')


def test_compuesto_envuelto():
    termino = janus.query_once('X = prolog(f(x, [a]))')['X']
    assert str(termino) == 'f(x,[a])'
    assert janus.query_once('T = f(x, L)', {'T': termino})['L'] == ['a']
