"""Capítulo 30 - Un cliente de Python para el servicio de servidor.pl.

Usa urllib, de la biblioteca estándar de Python. Del otro lado de la red hay
un programa de Prolog, pero el cliente no depende de eso: habla HTTP y JSON,
como con cualquier otro servicio.
"""

import json
import urllib.error
import urllib.parse
import urllib.request


class PersonaDesconocidaError(LookupError):
    """El servidor no conoce a la persona: respondió 404."""


def _pedir(pedido):
    """Hace el pedido; devuelve el código de estado y el cuerpo leído como JSON."""
    try:
        with urllib.request.urlopen(pedido) as respuesta:  # noqa: S310
            return respuesta.status, json.load(respuesta)
    except urllib.error.HTTPError as error:
        return error.code, json.load(error)


def ficha(base, persona):
    """Devuelve la ficha de persona, o lanza PersonaDesconocidaError."""
    ruta = urllib.parse.quote(persona)
    codigo, cuerpo = _pedir(f'{base}/personas/{ruta}')
    if codigo == 404:
        raise PersonaDesconocidaError(persona)
    return cuerpo


def nietos(base, abuelo):
    """Devuelve la lista de los nietos de abuelo."""
    consulta = urllib.parse.urlencode({'abuelo': abuelo})
    _, cuerpo = _pedir(f'{base}/nietos?{consulta}')
    return cuerpo['nietos']


def cambiar_edad(base, persona, edad):
    """Pide registrar la edad de persona; devuelve el código de estado."""
    datos = json.dumps({'nombre': persona, 'edad': edad}).encode('utf-8')
    pedido = urllib.request.Request(  # noqa: S310
        f'{base}/edades', data=datos, headers={'Content-Type': 'application/json'}, method='POST'
    )
    codigo, _ = _pedir(pedido)
    return codigo
