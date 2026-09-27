"""El puerto del dominio: lo que la aplicación necesita del juego.

Las reglas del Buscaminas son lógicas, y están en Prolog; este módulo solo
describe cómo se usan, con protocolos de Python. No importa Janus ni curses:
cualquier implementación que cumpla los protocolos sirve, como el adaptador de
Prolog o una partida de prueba escrita en Python.
"""

from typing import Literal, Protocol

Estado = Literal['sigue', 'gano', 'perdio']


class Partida(Protocol):
    """Una partida en curso, en un tablero de filas por columnas."""

    filas: int
    columnas: int
    estado: Estado

    def descubrir(self, fila: int, columna: int) -> None:
        """Descubre la celda; puede ganar o perder la partida."""

    def marcar(self, fila: int, columna: int) -> None:
        """Marca la celda, o le quita la marca."""

    def tablero(self, mostrar_minas: bool) -> list[str]:
        """Devuelve las filas del tablero, un carácter por celda.

        Los caracteres son: # oculta, M marcada, . sin minas vecinas, un dígito
        con la cantidad de minas vecinas, y * mina, visible solo con
        mostrar_minas o en una celda descubierta.
        """


class Reglas(Protocol):
    """La fábrica de partidas."""

    def partida_al_azar(self, filas: int, columnas: int, minas: int, semilla: int) -> Partida:
        """Devuelve una partida nueva con minas al azar; la semilla la repite."""
