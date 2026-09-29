:- encoding(utf8).

% Capítulo 41 - Posiciones, jugadas y fin de partida del ta-te-ti.
%
% El juego es un término: tateti(N) es el ta-te-ti en un tablero de N por N,
% con N igual a 3 o 4, que gana quien completa una fila, una columna o una
% diagonal. Una posición es pos(Tablero, Turno): Tablero es la lista de las
% N * N casillas por filas, cada una x, o o v (vacía), y Turno es el
% jugador que mueve. Una jugada es el número de la casilla, de 1 a N * N.
% Cinco predicados describen el juego, y las búsquedas del capítulo solo
% llaman a ellos: inicial/2, jugada/4, turno/3, fin/3 y valor_final/3.
%
%?- inicial(tateti(3), P), jugada(tateti(3), P, J, P1).
%?- ganada(tateti(3), pos([x,o,v, v,x,v, v,v,o], x)).

%!  inicial(+Juego, -Posicion) is det.
%
%   Posicion es la de partida de Juego: el tablero vacío, y mueve x.
inicial(tateti(N), pos(Tablero, x)) :-
    Casillas is N * N,
    length(Tablero, Casillas),
    maplist(=(v), Tablero).

%!  jugada(+Juego, +Posicion, ?Casilla:integer, -Siguiente) is nondet.
%
%   Siguiente es la posición que resulta de que el jugador de turno en
%   Posicion marque Casilla, una casilla vacía. No comprueba si la partida
%   terminó: las búsquedas llaman antes a fin/3.
jugada(tateti(_), pos(Tablero0, Jugador), Casilla, pos(Tablero, Otro)) :-
    nth1(Casilla, Tablero0, v, Resto),
    nth1(Casilla, Tablero, Jugador, Resto),
    otro(Jugador, Otro).

% otro(J, K): K es el rival de J.
otro(x, o).
otro(o, x).

%!  turno(+Juego, +Posicion, -Lado) is det.
%
%   Lado es max si en Posicion mueve x, que busca los valores altos, y min
%   si mueve o.
turno(tateti(_), pos(_, Jugador), Lado) :-
    lado(Jugador, Lado).

% lado(J, L): el jugador J es L, max o min.
lado(x, max).
lado(o, min).

%!  fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   La partida terminó en Posicion con Resultado: gana(J) si J completó una
%   línea, o empate si el tablero está lleno. Falla si la partida sigue.
fin(Juego, pos(Tablero, _), Resultado) :-
    lineas(Juego, Lineas),
    (   member([C|Cs], Lineas),
        marca(Tablero, J, C),
        J \== v,
        maplist(marca(Tablero, J), Cs)
    ->  Resultado = gana(J)
    ;   \+ memberchk(v, Tablero),
        Resultado = empate
    ).

%!  marca(+Tablero:list, ?Marca, +Casilla:integer) is semidet.
%
%   Marca es lo que hay en Casilla: x, o o v.
marca(Tablero, Marca, Casilla) :-
    nth1(Casilla, Tablero, Marca).

% lineas(Juego, Lineas): Lineas son las filas, las columnas y las dos
% diagonales del tablero de Juego, cada una como la lista de sus casillas.
lineas(tateti(3), [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],
                   [1, 5, 9], [3, 5, 7]]).
lineas(tateti(4), [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12],
                   [13, 14, 15, 16],
                   [1, 5, 9, 13], [2, 6, 10, 14], [3, 7, 11, 15],
                   [4, 8, 12, 16],
                   [1, 6, 11, 16], [4, 7, 10, 13]]).

%!  valor_final(+Resultado, +Posicion, -Valor:integer) is det.
%
%   Valor es el de una partida terminada, para x: 0 el empate, y 100 más la
%   cantidad de casillas vacías si gana x, con el signo cambiado si gana o.
%   Las casillas vacías premian ganar antes.
valor_final(empate, _, 0).
valor_final(gana(J), pos(Tablero, _), Valor) :-
    include(==(v), Tablero, Vacias),
    length(Vacias, K),
    signo(J, S),
    Valor is S * (100 + K).

% signo(J, S): S es 1 si J es x, que maximiza, y -1 si es o, que minimiza.
signo(x, 1).
signo(o, -1).

%!  ganada(+Juego, +Posicion) is semidet.
%
%   El jugador de turno en Posicion gana, juegue lo que juegue el rival:
%   tiene una jugada tras la cual todas las respuestas llevan a una
%   posición en la que vuelve a ganar. Recorre el árbol entero de la
%   partida.
ganada(Juego, Posicion) :-
    \+ fin(Juego, Posicion, _),
    jugada(Juego, Posicion, _, Siguiente),
    perdida(Juego, Siguiente),
    !.

%!  perdida(+Juego, +Posicion) is semidet.
%
%   El jugador de turno en Posicion pierde: la partida terminó con la
%   victoria del rival, o todas sus jugadas llevan a posiciones ganadas
%   por el rival.
perdida(Juego, Posicion) :-
    (   fin(Juego, Posicion, Resultado)
    ->  Resultado = gana(_)
    ;   forall(jugada(Juego, Posicion, _, Siguiente),
               ganada(Juego, Siguiente))
    ).

%!  partidas(+Juego, +Posicion, -Cantidad:integer) is det.
%
%   Cantidad es la cantidad de partidas distintas que pueden seguir a
%   Posicion: las ramas del árbol de la partida.
partidas(Juego, Posicion, Cantidad) :-
    aggregate_all(count, partida(Juego, Posicion, _), Cantidad).

%!  partida(+Juego, +Posicion, -Jugadas:list(integer)) is nondet.
%
%   Jugadas es una secuencia de jugadas que lleva de Posicion al fin de la
%   partida.
partida(Juego, Posicion, Jugadas) :-
    (   fin(Juego, Posicion, _)
    ->  Jugadas = []
    ;   Jugadas = [J|Js],
        jugada(Juego, Posicion, J, Siguiente),
        partida(Juego, Siguiente, Js)
    ).

%!  filas(+Juego, +Posicion, -Lineas:list(string)) is det.
%
%   Lineas muestran el tablero de Posicion, una fila por línea, con el
%   número de cada casilla vacía. Todas las casillas ocupan el ancho del
%   número más grande.
filas(tateti(N), pos(Tablero, _), Lineas) :-
    Ultima is N * N,
    atom_length(Ultima, Ancho),
    numlist(1, N, Fs),
    maplist(fila(N, Ancho, Tablero), Fs, Lineas).

%!  fila(+N:integer, +Ancho:integer, +Tablero:list, +F:integer,
%!       -Linea:string) is det.
%
%   Linea muestra la fila F de Tablero.
fila(N, Ancho, Tablero, F, Linea) :-
    numlist(1, N, Cs),
    maplist(casilla(N, F), Cs, Casillas),
    maplist(dibujo(Ancho, Tablero), Casillas, Dibujos),
    atomic_list_concat(Dibujos, ' ', Linea0),
    atom_string(Linea0, Linea).

%!  casilla(+N:integer, +Fila:integer, +Columna:integer, -Casilla:integer)
%!      is det.
%
%   Casilla es el número de la casilla en Fila y Columna, contadas desde 1.
casilla(N, Fila, Columna, Casilla) :-
    Casilla is (Fila - 1) * N + Columna.

%!  dibujo(+Ancho:integer, +Tablero:list, +Casilla:integer, -Dibujo:atom)
%!      is det.
%
%   Dibujo es X u O, o el número de la casilla si está vacía, alineado a
%   la derecha en Ancho columnas.
dibujo(Ancho, Tablero, Casilla, Dibujo) :-
    nth1(Casilla, Tablero, Marca),
    (   Marca == v
    ->  Texto = Casilla
    ;   upcase_atom(Marca, Texto)
    ),
    format(atom(Dibujo), "~t~w~*|", [Texto, Ancho]).
