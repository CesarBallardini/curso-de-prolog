"""El caso de uso: jugar una partida con un cursor.

Depende solo del puerto, dominio.Partida. El cursor es lo que la aplicación
agrega al dominio: la celda sobre la que actúan descubrir y marcar, que siempre
queda dentro del tablero.
"""

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from buscaminas.dominio import Partida


class Juego:
    """Una partida y la posición del cursor, que empieza en la celda 1-1."""

    def __init__(self, partida: Partida):
        """Empieza a jugar la partida, con el cursor en la esquina 1-1."""
        self.partida = partida
        self.fila = 1
        self.columna = 1

    @property
    def terminado(self):
        """Devuelve True si la partida ya se ganó o se perdió."""
        return self.partida.estado != 'sigue'

    def mover(self, filas, columnas):
        """Mueve el cursor, sin salir del tablero; no hace nada si terminó."""
        if self.terminado:
            return
        self.fila = min(max(self.fila + filas, 1), self.partida.filas)
        self.columna = min(max(self.columna + columnas, 1), self.partida.columnas)

    def descubrir(self):
        """Descubre la celda del cursor; no hace nada si terminó."""
        if not self.terminado:
            self.partida.descubrir(self.fila, self.columna)

    def marcar(self):
        """Marca la celda del cursor; no hace nada si terminó."""
        if not self.terminado:
            self.partida.marcar(self.fila, self.columna)

    def tablero(self):
        """Devuelve las filas del tablero; al terminar, con las minas a la vista."""
        return self.partida.tablero(mostrar_minas=self.terminado)
