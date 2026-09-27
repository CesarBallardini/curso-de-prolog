"""Capítulo 29 - Soluciones de los ejercicios 1, 3, 4, 6, 7 y 12, del lado de Python.

Usan familia.pl, que carga consultas.cargar(), y el proyecto, que carga
inscripciones_py.cargar(). Los valores de entrada viajan siempre como
ligaduras.
"""

from pathlib import Path

import janus_swi as janus

AQUI = Path(__file__).parent

# --- Ejercicio 1 ---------------------------------------------------------------


def hijos_de(persona):
    """Devuelve la lista de los hijos de persona, en el orden de los hechos."""
    return [respuesta['H'] for respuesta in janus.query('padre(P, H)', {'P': persona})]


# --- Ejercicio 3 ---------------------------------------------------------------

HERMANO = r"""
hermano(A, B) :-
    padre(P, A),
    padre(P, B),
    A \== B.
"""


def hermanos_de(persona):
    """Devuelve los hermanos de persona, con la regla hermano/2 cargada desde el texto."""
    janus.consult('hermanos', HERMANO)
    return [respuesta['H'] for respuesta in janus.query('hermano(P, H)', {'P': persona})]


# --- Ejercicio 4 ---------------------------------------------------------------


def edad_o_cero(persona):
    """Devuelve la edad de persona, o 0 si no se conoce."""
    return janus.apply_once('user', 'edad_de', persona, fail=0)


# --- Ejercicio 6 ---------------------------------------------------------------


def mayores_de_edad(personas):
    """Devuelve los nombres de las personas, diccionarios con nombre y edad, de 18 o más."""
    consulta = 'member(_D, L), get_dict(edad, _D, _E), _E >= 18, get_dict(nombre, _D, N)'
    return [respuesta['N'] for respuesta in janus.query(consulta, {'L': personas})]


# --- Ejercicio 7 ---------------------------------------------------------------


def clase_de_error(error):
    """Devuelve el nombre del error formal de un janus.PrologError, o None si no es error/2."""
    consulta = 'E = error(_Formal, _), functor(_Formal, Nombre, _)'
    respuesta = janus.query_once(consulta, {'E': error.term})
    return respuesta['Nombre'] if respuesta['truth'] else None


# --- Ejercicio 12 --------------------------------------------------------------


def inscriptos(materia):
    """Devuelve los inscriptos en materia: diccionarios con legajo y nombre."""
    janus.consult(str(AQUI / 'soluciones_proyecto.pl'))
    return janus.query_once('inscriptos_py(M, A)', {'M': materia})['A']
