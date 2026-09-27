"""La interfaz de texto: el Buscaminas en la terminal completa, con curses.

Es un adaptador de entrada: traduce teclas en órdenes para aplicacion.Juego, y
dibuja lo que el juego muestra. Depende de la aplicación, y nunca al revés.
pantalla() y aplicar() no usan curses, y se prueban sin terminal; solo
ejecutar() y lo que llama tocan la terminal. En Windows, curses necesita el
paquete windows-curses.
"""

import curses

AYUDA = 'Flechas: mover   Espacio: descubrir   m: marcar   q: salir'
MENSAJES = {
    'sigue': '',
    'gano': 'Todas las celdas libres están descubiertas: partida ganada.',
    'perdio': 'La celda tenía una mina: partida perdida.',
}
ORDENES = {
    'arriba': lambda juego: juego.mover(-1, 0),
    'abajo': lambda juego: juego.mover(1, 0),
    'izquierda': lambda juego: juego.mover(0, -1),
    'derecha': lambda juego: juego.mover(0, 1),
    'descubrir': lambda juego: juego.descubrir(),
    'marcar': lambda juego: juego.marcar(),
}
TECLAS = {
    curses.KEY_UP: 'arriba',
    curses.KEY_DOWN: 'abajo',
    curses.KEY_LEFT: 'izquierda',
    curses.KEY_RIGHT: 'derecha',
    ord(' '): 'descubrir',
    ord('m'): 'marcar',
    ord('q'): 'salir',
}


def pantalla(juego):
    """Devuelve las líneas de la pantalla: el tablero en un recuadro y el estado."""
    ancho = 3 * juego.partida.columnas
    lineas = ['Buscaminas', '┌' + '─' * ancho + '┐']
    for fila, texto in enumerate(juego.tablero(), start=1):
        celdas = []
        for columna, simbolo in enumerate(texto, start=1):
            en_el_cursor = (fila, columna) == (juego.fila, juego.columna)
            celdas.append(f'[{simbolo}]' if en_el_cursor else f' {simbolo} ')
        lineas.append('│' + ''.join(celdas) + '│')
    lineas.append('└' + '─' * ancho + '┘')
    lineas.append(MENSAJES[juego.partida.estado])
    lineas.append('q: salir' if juego.terminado else AYUDA)
    return lineas


def aplicar(juego, orden):
    """Aplica una orden, por su nombre; devuelve False si la orden es salir."""
    if orden == 'salir':
        return False
    if orden in ORDENES:
        ORDENES[orden](juego)
    return True


def _dibujar(ventana, lineas):
    """Escribe las líneas en la ventana, desde la esquina superior izquierda."""
    ventana.erase()
    for numero, linea in enumerate(lineas):
        ventana.addstr(numero, 0, linea)
    ventana.refresh()


def _jugar(ventana, juego):
    """Dibuja, lee una tecla y la aplica, hasta que la orden sea salir."""
    curses.curs_set(0)
    ventana.keypad(True)
    seguir = True
    while seguir:
        _dibujar(ventana, pantalla(juego))
        seguir = aplicar(juego, TECLAS.get(ventana.getch()))


def ejecutar(juego):
    """Juega en la terminal completa; curses la restaura al terminar."""
    curses.wrapper(_jugar, juego)
