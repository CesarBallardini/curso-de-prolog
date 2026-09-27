"""Capítulo 29 - Consultar las reglas de familia.pl desde Python.

Cada función hace una consulta con Janus y devuelve datos de Python. Los
valores de entrada viajan como ligaduras, en un diccionario, y nunca se pegan
dentro del texto de la consulta.
"""

from pathlib import Path

import janus_swi as janus

AQUI = Path(__file__).parent


def cargar():
    """Carga familia.pl en el Prolog del proceso."""
    janus.consult(str(AQUI / 'familia.pl'))


def es_abuelo(abuelo, nieto):
    """Devuelve True si abuelo es abuelo de nieto."""
    return janus.query_once('abuelo(A, N)', {'A': abuelo, 'N': nieto})['truth']


def nietos_de(abuelo):
    """Devuelve la lista de los nietos de abuelo, en el orden de las respuestas."""
    return [respuesta['N'] for respuesta in janus.query('abuelo(A, N)', {'A': abuelo})]


def primer_nieto(abuelo):
    """Devuelve el primer nieto de abuelo, o None si no tiene."""
    respuesta = janus.query_once('abuelo(A, N)', {'A': abuelo})
    return respuesta['N'] if respuesta['truth'] else None


def ficha(persona):
    """Devuelve la ficha de persona como diccionario, o None si no se conoce."""
    respuesta = janus.query_once('ficha(P, F)', {'P': persona})
    return respuesta['F'] if respuesta['truth'] else None


def edad_armando_el_texto(persona):
    """Consulta la edad pegando el nombre en el texto: la forma que no se debe usar."""
    return janus.query_once(f'edad_de({persona}, E)')


class PersonaDesconocidaError(LookupError):
    """La persona no está en la base de familia.pl."""


def edad(persona):
    """Devuelve la edad de persona.

    Una falla de Prolog se convierte en PersonaDesconocidaError, y un error de tipo
    de Prolog, en TypeError de Python.
    """
    try:
        respuesta = janus.query_once('edad_de(P, E)', {'P': persona})
    except janus.PrologError as error:
        raise TypeError(str(error)) from error
    if not respuesta['truth']:
        raise PersonaDesconocidaError(persona)
    return respuesta['E']
