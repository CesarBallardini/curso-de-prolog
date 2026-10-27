"""El adaptador de Prolog: implementa el puerto con las reglas de buscaminas.pl.

Es el único módulo del paquete que usa Janus. La partida viaja entre los dos
lenguajes como un janus.Term, que el adaptador guarda y devuelve en cada
jugada sin examinarlo.
"""

from pathlib import Path

import janus_swi as janus

PROGRAMA = Path(__file__).parent / 'buscaminas.pl'


class PartidaEnProlog:
    """Una partida cuyas reglas están en Prolog; cumple dominio.Partida."""

    def __init__(self, filas, columnas, juego):
        """Guarda las dimensiones y la partida de Prolog, un janus.Term."""
        self.filas = filas
        self.columnas = columnas
        self.estado = 'sigue'
        self._juego = juego

    def _jugar(self, accion, fila, columna):
        """Aplica la jugada en Prolog; una celda fuera del tablero es un error."""
        entrada = {'J0': self._juego, 'A': accion, 'F': fila, 'C': columna}
        respuesta = janus.query_once('buscaminas:jugar_py(J0, A, F, C, J, E)', entrada)
        if respuesta['E'] == 'fuera':
            raise ValueError(f'La celda {fila}-{columna} está fuera del tablero.')
        self._juego = respuesta['J']
        self.estado = respuesta['E']

    def descubrir(self, fila, columna):
        """Descubre la celda."""
        self._jugar('descubrir', fila, columna)

    def marcar(self, fila, columna):
        """Marca la celda, o le quita la marca."""
        self._jugar('marcar', fila, columna)

    def tablero(self, mostrar_minas):
        """Devuelve las filas del tablero, un carácter por celda."""
        entrada = {'J': self._juego, 'M': mostrar_minas}
        return janus.query_once('buscaminas:filas_py(J, M, T)', entrada)['T']


class ReglasEnProlog:
    """La fábrica de partidas de Prolog; cumple dominio.Reglas."""

    def __init__(self):
        """Carga las reglas del juego en el Prolog del proceso."""
        janus.consult(str(PROGRAMA))

    def partida_al_azar(self, filas, columnas, minas, semilla):
        """Devuelve una partida nueva con minas al azar."""
        entrada = {'F': filas, 'C': columnas, 'N': minas, 'S': semilla}
        juego = janus.query_once('buscaminas:partida_al_azar_py(F, C, N, S, J)', entrada)['J']
        return PartidaEnProlog(filas, columnas, juego)

    def partida_con_minas(self, filas, columnas, minas):
        """Devuelve una partida nueva con minas en las celdas dadas, pares (fila, columna)."""
        entrada = {'F': filas, 'C': columnas, 'M': minas}
        juego = janus.query_once('buscaminas:nueva_partida_py(F, C, M, J)', entrada)['J']
        return PartidaEnProlog(filas, columnas, juego)
