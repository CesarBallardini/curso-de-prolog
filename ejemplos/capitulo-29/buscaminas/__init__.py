"""Capítulo 29 - Solución del ejercicio 13: el Buscaminas, con puertos y adaptadores.

    dominio.py           el puerto: lo que la aplicación necesita del juego
    aplicacion.py        el caso de uso jugar, con un cursor; solo usa el puerto
    adaptador_prolog.py  implementa el puerto con las reglas de buscaminas.pl
    tui.py               la interfaz de texto, con curses; solo usa la aplicación
    __main__.py          arma las piezas: python -m buscaminas 9 9 10

Las dependencias apuntan hacia el dominio: la interfaz usa la aplicación,
la aplicación usa el puerto, y el adaptador lo implementa. Ni el puerto ni la
aplicación dependen de Prolog o de curses.
"""
