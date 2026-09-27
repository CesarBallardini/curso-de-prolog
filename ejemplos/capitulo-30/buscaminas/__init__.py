"""Capítulo 30 - Solución del ejercicio 14: el Buscaminas, también como servicio.

Es el paquete del capítulo 29 con un adaptador más:

    dominio.py           el puerto: lo que la aplicación necesita del juego
    aplicacion.py        el caso de uso jugar, con un cursor; solo usa el puerto
    adaptador_prolog.py  implementa el puerto con Janus y buscaminas.pl
    adaptador_http.py    implementa el puerto con servicio_buscaminas.pl
    tui.py               la interfaz de texto, con curses; solo usa la aplicación
    __main__.py          arma las piezas: python -m buscaminas 9 9 10 [--servidor URL]

El dominio, la aplicación y la interfaz no cambian: jugar contra el servicio es
elegir otro adaptador en la raíz de composición.
"""
