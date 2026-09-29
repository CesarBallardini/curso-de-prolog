:- encoding(utf8).

% Capítulo 36 - El Buscaminas a pantalla completa, sobre el módulo partida
% del capítulo 31.
%
% Un juego es juego(Partida, Cursor, Pedido): la partida del capítulo 31,
% la celda Fila-Columna donde está el cursor, y jugar o salir. pantalla/2
% es el modelo de pantalla: da las líneas que muestran un juego. paso/3 es
% la respuesta a una tecla. Los dos son puros; bucle/3 es el único que lee
% y escribe.
%
% solo-local: SWISH no admite módulos propios ni tiene una terminal.
%
%?- partida:partida_con_minas(3, 3, [1-1], P), pantalla(juego(P,2-2,jugar), L).

:- module(buscaminas_pantalla,
          [ pantalla/2,
            paso/3,
            bucle/3,
            buscaminas/4
          ]).

:- meta_predicate
    bucle(1, +, -).

:- use_module(pantalla).
:- use_module('../../capitulo-31/buscaminas/partida').

%!  buscaminas(+Filas:integer, +Columnas:integer, +Minas:integer,
%!             +Semilla:integer) is det.
%
%   Juega en la terminal una partida nueva con las teclas.
buscaminas(Filas, Columnas, Minas, Semilla) :-
    nueva_partida(Filas, Columnas, Minas, Semilla, Partida),
    con_pantalla(bucle(get_single_char, juego(Partida, 1-1, jugar), _)).

%!  bucle(:Siguiente, +Juego0, -Juego) is det.
%
%   Dibuja Juego0 y, si no terminó, lee una tecla de Siguiente, la aplica y
%   sigue con el juego que resulta. Juego es el juego terminado.
bucle(Siguiente, Juego0, Juego) :-
    pantalla(Juego0, Lineas),
    dibujar(Lineas),
    (   terminado(Juego0)
    ->  Juego = Juego0
    ;   leer_tecla(Siguiente, Tecla),
        paso(Tecla, Juego0, Juego1),
        bucle(Siguiente, Juego1, Juego)
    ).


%!  terminado(+Juego) is semidet.
%
%   Juego terminó: la partida se ganó o se perdió, o se pidió salir.
terminado(juego(_, _, salir)) :-
    !.
terminado(juego(Partida, _, _)) :-
    estado(Partida, Estado),
    Estado \== sigue.

%!  paso(+Tecla, +Juego0, -Juego) is det.
%
%   Juego es Juego0 después de Tecla: las flechas mueven el cursor, la
%   barra descubre la celda, m la marca, q y el fin de la entrada salen; las
%   demás teclas no cambian nada.
paso(arriba, Juego0, Juego) :-
    !,
    mover(-1, 0, Juego0, Juego).
paso(abajo, Juego0, Juego) :-
    !,
    mover(1, 0, Juego0, Juego).
paso(izquierda, Juego0, Juego) :-
    !,
    mover(0, -1, Juego0, Juego).
paso(derecha, Juego0, Juego) :-
    !,
    mover(0, 1, Juego0, Juego).
paso(espacio, juego(P0, Celda, Pedido), juego(P, Celda, Pedido)) :-
    !,
    jugar(descubrir, Celda, P0, P).
paso(letra(m), juego(P0, Celda, Pedido), juego(P, Celda, Pedido)) :-
    !,
    jugar(marcar, Celda, P0, P).
paso(letra(q), juego(P, Celda, _), juego(P, Celda, salir)) :-
    !.
paso(fin, juego(P, Celda, _), juego(P, Celda, salir)) :-
    !.
paso(_, Juego, Juego).

%!  mover(+DF:integer, +DC:integer, +Juego0, -Juego) is det.
%
%   Mueve el cursor DF filas y DC columnas, sin salir del tablero.
mover(DF, DC, juego(P, F0-C0, Pedido), juego(P, F-C, Pedido)) :-
    dimensiones(P, Filas, Columnas),
    F is max(1, min(Filas, F0 + DF)),
    C is max(1, min(Columnas, C0 + DC)).

%!  pantalla(+Juego, -Lineas:list(string)) is det.
%
%   Lineas es la pantalla de Juego: el tablero en una caja, con el cursor
%   entre corchetes, el estado en otra y una línea de ayuda.
pantalla(juego(Partida, Cursor, Pedido), Lineas) :-
    estado(Partida, Estado),
    (   Estado == sigue
    ->  Minas = false
    ;   Minas = true
    ),
    filas(Partida, Minas, Filas),
    foldl(fila_con_cursor(Cursor), Filas, Tablero, 1, _),
    caja("Buscaminas", Tablero, Caja1),
    minas_restantes(Partida, Restantes),
    format(string(Linea1), "Minas sin marcar: ~d", [Restantes]),
    mensaje(Estado, Pedido, Linea2),
    caja("Estado", [Linea1, Linea2], Caja2),
    Ayuda = "Flechas: mover  Espacio: descubrir  m: marcar  q: salir",
    append([Caja1, Caja2, [Ayuda]], Lineas).

%!  fila_con_cursor(+Cursor:pair, +Fila:string, -Linea:string,
%!                  +N0:integer, -N:integer) is det.
%
%   Linea muestra Fila, la fila número N0, con cada celda en tres columnas;
%   la celda del cursor va entre corchetes. N es N0 + 1.
fila_con_cursor(F-C, Fila, Linea, N0, N) :-
    N is N0 + 1,
    string_chars(Fila, Simbolos),
    foldl(celda(F-C, N0), Simbolos, Celdas, 1, _),
    atomics_to_string(Celdas, Linea).

%!  celda(+Cursor:pair, +Fila:integer, +Simbolo:char, -Texto:string,
%!        +C0:integer, -C:integer) is det.
%
%   Texto muestra Simbolo, de la columna C0; C es C0 + 1.
celda(Cursor, Fila, Simbolo, Texto, C0, C) :-
    C is C0 + 1,
    (   Cursor == Fila-C0
    ->  format(string(Texto), "[~w]", [Simbolo])
    ;   format(string(Texto), " ~w ", [Simbolo])
    ).

%!  mensaje(+Estado:atom, +Pedido:atom, -Linea:string) is det.
%
%   Linea describe cómo sigue el juego.
mensaje(gano, _, "Partida ganada") :-
    !.
mensaje(perdio, _, "Partida perdida") :-
    !.
mensaje(sigue, salir, "Partida abandonada") :-
    !.
mensaje(sigue, jugar, "En juego").
