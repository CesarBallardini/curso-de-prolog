"""Capítulo 30 - Soluciones de los ejercicios 6 y 13, del lado de Python.

El ejercicio 6 usa cliente.py. El 13 es un cliente del servicio del proyecto
con las mismas funciones y excepciones que inscripciones_py.py del capítulo
29: quien lo usa no nota si las reglas están en el mismo proceso, con Janus,
o del otro lado de la red.
"""

import json
import urllib.error
import urllib.request

import cliente

# --- Ejercicio 6 ---------------------------------------------------------------


def ficha_o_none(base, persona):
    """Devuelve la ficha de persona, o None si el servidor no la conoce."""
    try:
        return cliente.ficha(base, persona)
    except cliente.PersonaDesconocidaError:
        return None


# --- Ejercicio 13 --------------------------------------------------------------


class InscripcionRechazadaError(Exception):
    """Las reglas no permiten la inscripción; motivo dice por qué."""

    def __init__(self, legajo, materia, motivo):
        """Guarda el pedido y el motivo del rechazo."""
        super().__init__(f'{legajo} en {materia}: {motivo}')
        self.motivo = motivo


class DatoInvalidoError(ValueError):
    """Un dato no tiene el tipo que esperan las reglas: el servicio respondió 400."""


class Inscripciones:
    """Un cliente del servicio de Inscripciones, en la dirección base."""

    def __init__(self, base):
        """Guarda la dirección base del servicio, como 'http://127.0.0.1:8080'."""
        self.base = base

    def _pedir(self, ruta, datos=None):
        """Hace el pedido; devuelve el código de estado y el cuerpo leído como JSON."""
        cuerpo = None if datos is None else json.dumps(datos).encode('utf-8')
        pedido = urllib.request.Request(  # noqa: S310
            f'{self.base}{ruta}', data=cuerpo, headers={'Content-Type': 'application/json'}
        )
        try:
            with urllib.request.urlopen(pedido) as respuesta:  # noqa: S310
                return respuesta.status, json.load(respuesta)
        except urllib.error.HTTPError as error:
            return error.code, json.load(error)

    def ranking(self):
        """Devuelve el ranking: una lista de diccionarios con legajo, nombre y promedio."""
        return self._pedir('/ranking')[1]

    def materias(self):
        """Devuelve las materias: diccionarios con codigo, nombre, anio e inscriptos."""
        return self._pedir('/materias')[1]

    def inscribir(self, legajo, materia):
        """Inscribe al alumno legajo en materia, o lanza una de las dos excepciones."""
        codigo, cuerpo = self._pedir('/inscripciones', {'legajo': legajo, 'materia': materia})
        if codigo == 400:
            raise DatoInvalidoError(cuerpo['error'])
        if codigo != 201:
            raise InscripcionRechazadaError(legajo, materia, cuerpo['motivo'])
