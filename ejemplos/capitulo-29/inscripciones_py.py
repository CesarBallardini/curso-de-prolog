"""Capítulo 29 - Inscripciones desde Python: la frontera con Prolog.

Es el único módulo de Python que usa Janus. Carga el programa de Prolog,
consulta los predicados del módulo puente, que ya devuelven datos que Python
entiende, y convierte los rechazos y los errores de Prolog en excepciones de
Python. El resto del programa de Python no ve consultas ni términos.
"""

from pathlib import Path

import janus_swi as janus

PROGRAMA = Path(__file__).parent / 'inscripciones' / 'inscripciones.pl'


class InscripcionRechazadaError(Exception):
    """Las reglas no permiten la inscripción; motivo dice por qué."""

    def __init__(self, legajo, materia, motivo):
        """Guarda el pedido y el motivo del rechazo."""
        super().__init__(f'{legajo} en {materia}: {motivo}')
        self.motivo = motivo


class DatoInvalidoError(ValueError):
    """Un dato no tiene el tipo que esperan las reglas de Prolog."""


def cargar():
    """Carga el programa de Prolog en el proceso."""
    janus.consult(str(PROGRAMA))


def _consultar(consulta, entrada=None):
    """Hace una consulta; un error de Prolog se convierte en DatoInvalidoError."""
    try:
        return janus.query_once(consulta, entrada or {})
    except janus.PrologError as error:
        raise DatoInvalidoError(str(error)) from error


def ranking():
    """Devuelve el ranking: una lista de diccionarios con legajo, nombre y promedio."""
    return _consultar('ranking_py(R)')['R']


def materias():
    """Devuelve las materias: diccionarios con codigo, nombre, anio e inscriptos."""
    return _consultar('materias_py(M)')['M']


def inscribir(legajo, materia):
    """Inscribe al alumno legajo en materia, o lanza InscripcionRechazadaError."""
    resultado = _consultar('inscribir_py(L, M, R)', {'L': legajo, 'M': materia})['R']
    if not resultado['aceptada']:
        raise InscripcionRechazadaError(legajo, materia, resultado['motivo'])


def estado():
    """Devuelve el estado del programa, un objeto que solo sirve para restaurar()."""
    return _consultar('estado_py(E)')['E']


def restaurar(guardado):
    """Vuelve al estado que devolvió estado()."""
    _consultar('restaurar_py(E)', {'E': guardado})
