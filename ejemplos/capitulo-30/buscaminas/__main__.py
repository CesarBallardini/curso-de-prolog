"""La raíz de composición: arma las piezas y juega.

    uv run --group apendice-a python -m buscaminas 9 9 10 --semilla 7
    uv run --group apendice-a python -m buscaminas 9 9 10 --servidor http://127.0.0.1:8080

(desde ejemplos/capitulo-30, en una terminal: curses no funciona con la
entrada redirigida). Sin --servidor, las reglas se ejecutan con Janus en el
mismo proceso, y en Windows SWI_HOME_DIR tiene que estar definida; con
--servidor, las ejecuta el servicio de servicio_buscaminas.pl.

Es el único módulo que importa todas las piezas. Importa el adaptador que
elige, y solo ese: jugar contra el servicio no necesita Janus.
"""

import argparse

from buscaminas import tui
from buscaminas.aplicacion import Juego


def reglas_elegidas(servidor):
    """Devuelve la fábrica de partidas: la del servicio, o la de Prolog con Janus."""
    if servidor:
        from buscaminas.adaptador_http import ReglasEnServicio  # noqa: PLC0415

        return ReglasEnServicio(servidor)
    from buscaminas.adaptador_prolog import ReglasEnProlog  # noqa: PLC0415

    return ReglasEnProlog()


def main():
    """Lee los argumentos, crea la partida y la juega en la terminal."""
    argumentos = argparse.ArgumentParser(prog='buscaminas')
    argumentos.add_argument('filas', type=int)
    argumentos.add_argument('columnas', type=int)
    argumentos.add_argument('minas', type=int)
    argumentos.add_argument('--semilla', type=int, default=0)
    argumentos.add_argument('--servidor', help='dirección del servicio, como http://127.0.0.1:8080')
    pedido = argumentos.parse_args()
    reglas = reglas_elegidas(pedido.servidor)
    partida = reglas.partida_al_azar(pedido.filas, pedido.columnas, pedido.minas, pedido.semilla)
    tui.ejecutar(Juego(partida))


if __name__ == '__main__':
    main()
