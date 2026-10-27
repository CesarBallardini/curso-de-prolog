"""El adaptador HTTP: implementa el puerto con el servicio de servicio_buscaminas.pl.

Las reglas se ejecutan del otro lado de la red; este módulo solo habla HTTP y
JSON, con urllib. No importa Janus: el proceso de Python no necesita
SWI-Prolog. Cumple el mismo puerto que adaptador_prolog.py, y la aplicación y
la interfaz no distinguen uno del otro.
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


class PartidaEnServicio:
    """Una partida que vive en el servicio; cumple dominio.Partida."""

    def __init__(self, base, respuesta):
        """Toma la partida de la respuesta de POST /partidas."""
        self._url = f'{base}/partidas/{respuesta["id"]}'
        self.filas = respuesta['filas']
        self.columnas = respuesta['columnas']
        self.estado = respuesta['estado']
        self._tablero = respuesta['tablero']

    def _jugar(self, accion, fila, columna):
        """Envía la jugada; una respuesta que no es 200 es un error."""
        codigo, cuerpo = _pedir(f'{self._url}/{accion}', {'fila': fila, 'columna': columna})
        if codigo != 200:
            raise ValueError(cuerpo['error'])
        self.estado = cuerpo['estado']
        self._tablero = cuerpo['tablero']

    def descubrir(self, fila, columna):
        """Descubre la celda."""
        self._jugar('descubrir', fila, columna)

    def marcar(self, fila, columna):
        """Marca la celda, o le quita la marca."""
        self._jugar('marcar', fila, columna)

    def tablero(self, mostrar_minas):
        """Devuelve las filas del tablero; el servicio muestra las minas al terminar."""
        return self._tablero


class ReglasEnServicio:
    """La fábrica de partidas del servicio, en la dirección base; cumple dominio.Reglas."""

    def __init__(self, base):
        """Guarda la dirección base del servicio, como 'http://127.0.0.1:8080'."""
        self.base = base

    def partida_al_azar(self, filas, columnas, minas, semilla):
        """Crea una partida nueva en el servicio."""
        datos = {'filas': filas, 'columnas': columnas, 'minas': minas, 'semilla': semilla}
        codigo, cuerpo = _pedir(f'{self.base}/partidas', datos)
        if codigo != 201:
            raise ValueError(cuerpo['error'])
        return PartidaEnServicio(self.base, cuerpo)
