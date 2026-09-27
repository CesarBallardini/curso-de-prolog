"""La raíz de composición: arma las piezas y juega.

    uv run --group apendice-a python -m buscaminas 9 9 10 --semilla 7

(desde ejemplos/capitulo-29, en una terminal: curses no funciona con la
entrada redirigida). En Windows, SWI_HOME_DIR tiene que estar definida antes
de ejecutarlo, porque Janus inicia Prolog al importarse.

Es el único módulo que importa todas las piezas: elige el adaptador de Prolog
para el puerto, y la interfaz de texto para jugar.
"""

import argparse

from buscaminas import tui
from buscaminas.adaptador_prolog import ReglasEnProlog
from buscaminas.aplicacion import Juego


def main():
    """Lee los argumentos, crea la partida y la juega en la terminal."""
    argumentos = argparse.ArgumentParser(prog='buscaminas')
    argumentos.add_argument('filas', type=int)
    argumentos.add_argument('columnas', type=int)
    argumentos.add_argument('minas', type=int)
    argumentos.add_argument('--semilla', type=int, default=0)
    pedido = argumentos.parse_args()
    reglas = ReglasEnProlog()
    partida = reglas.partida_al_azar(pedido.filas, pedido.columnas, pedido.minas, pedido.semilla)
    tui.ejecutar(Juego(partida))


if __name__ == '__main__':
    main()
