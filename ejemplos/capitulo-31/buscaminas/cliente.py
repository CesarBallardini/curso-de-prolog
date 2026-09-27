"""Capítulo 31 - Buscaminas completo: un cliente de Python del servicio.

Juega contra buscaminas.pl --servicio con urllib, de la biblioteca estándar:
del lado de Python no hace falta SWI-Prolog. Es el adaptador HTTP del
capítulo 30, con la sugerencia que agrega el servicio completo.
"""

import json
import urllib.error
import urllib.request


def _pedir(url, datos=None):
    """Hace un pedido GET, o POST si hay datos; devuelve el código y el JSON."""
    cuerpo = None if datos is None else json.dumps(datos).encode('utf-8')
    pedido = urllib.request.Request(url, data=cuerpo, headers={'Content-Type': 'application/json'})  # noqa: S310
    try:
        with urllib.request.urlopen(pedido) as respuesta:  # noqa: S310
            return respuesta.status, json.load(respuesta)
    except urllib.error.HTTPError as error:
        return error.code, json.load(error)


class Partida:
    """Una partida que vive en el servicio de la dirección base."""

    def __init__(self, base, filas, columnas, minas, semilla=0):
        """Crea la partida en el servicio."""
        datos = {'filas': filas, 'columnas': columnas, 'minas': minas, 'semilla': semilla}
        codigo, cuerpo = _pedir(f'{base}/partidas', datos)
        if codigo != 201:
            raise ValueError(cuerpo['error'])
        self._url = f'{base}/partidas/{cuerpo["id"]}'
        self._actualizar(cuerpo)

    def _actualizar(self, cuerpo):
        """Toma el estado, las minas sin marcar y el tablero de una respuesta."""
        self.estado = cuerpo['estado']
        self.minas_restantes = cuerpo['minas_restantes']
        self.tablero = cuerpo['tablero']

    def _jugar(self, accion, fila, columna):
        """Envía la jugada; una respuesta que no es 200 es un error."""
        codigo, cuerpo = _pedir(f'{self._url}/{accion}', {'fila': fila, 'columna': columna})
        if codigo != 200:
            raise ValueError(cuerpo['error'])
        self._actualizar(cuerpo)

    def descubrir(self, fila, columna):
        """Descubre la celda."""
        self._jugar('descubrir', fila, columna)

    def marcar(self, fila, columna):
        """Marca la celda, o le quita la marca."""
        self._jugar('marcar', fila, columna)

    def sugerencia(self):
        """Devuelve una celda segura (fila, columna), o None si no hay ninguna a la vista."""
        codigo, cuerpo = _pedir(f'{self._url}/sugerencia')
        return (cuerpo['fila'], cuerpo['columna']) if codigo == 200 else None
