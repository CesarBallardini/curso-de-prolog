:- encoding(utf8).

% Capítulo 79 - Versión 1: las reglas del final de rey y torre contra rey.
%
% Una posición es pos(Lado, ReyBlanco, Torre, ReyNegro): Lado es blancas o
% negras, el bando que mueve, y cada pieza ocupa una casilla X-Y, con la
% columna X y la fila Y entre 1 y 8 (a1 es 1-1, h8 es 8-8). Si las negras
% capturaron la torre, Torre es el átomo capturada. Una jugada es
% rey(Desde, Hasta) o torre(Desde, Hasta). Las blancas son el bando que
% busca el mate; las negras, el que se defiende.
%
%?- jugada(pos(negras, 3-3, 1-8, 1-1), J, P).
%?- mate(pos(negras, 3-2, 8-1, 1-1)).

:- module(reglas,
          [ jugada/3,
            jaque/1,
            mate/1,
            ahogado/1,
            legal/1,
            vecina/2,
            distancia/3,
            manhattan/3,
            ordenados/3,
            casilla/2,
            notacion/2,
            filas/2,
            mostrar/1
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).

%!  vecina(+Casilla, -Vecina) is nondet.
%
%   Vecina es una de las hasta ocho casillas del tablero que tocan a
%   Casilla. Las diagonales salen primero, después las horizontales y por
%   último las verticales: el orden en que el consejo prueba las jugadas del
%   rey blanco.
vecina(X-Y, X1-Y1) :-
    member(DX-DY, [1-1, -1-1, 1 - -1, -1 - -1, 1-0, -1-0, 0-1, 0 - -1]),
    X1 is X + DX,
    Y1 is Y + DY,
    en_tablero(X1),
    en_tablero(Y1).

%!  en_tablero(+N:integer) is semidet.
%
%   N es una columna o una fila del tablero, de 1 a 8.
en_tablero(N) :-
    N >= 1,
    N =< 8.

%!  distancia(+A, +B, -D:integer) is det.
%
%   D es la distancia de A a B en jugadas de rey: la mayor de las dos
%   diferencias de coordenadas.
distancia(X1-Y1, X2-Y2, D) :-
    D is max(abs(X1 - X2), abs(Y1 - Y2)).

%!  manhattan(+A, +B, -D:integer) is det.
%
%   D es la suma de las dos diferencias de coordenadas de A y B.
manhattan(X1-Y1, X2-Y2, D) :-
    D is abs(X1 - X2) + abs(Y1 - Y2).

%!  entre(+A, +B, +C) is semidet.
%
%   B está estrictamente entre A y C, en la misma columna o en la misma
%   fila que las dos.
entre(X-Y1, X-Y2, X-Y3) :-
    ordenados(Y1, Y2, Y3).
entre(X1-Y, X2-Y, X3-Y) :-
    ordenados(X1, X2, X3).

%!  ordenados(+A:integer, +B:integer, +C:integer) is semidet.
%
%   B está estrictamente entre A y C, en uno u otro orden.
ordenados(A, B, C) :-
    (   A < B, B < C
    ->  true
    ;   C < B, B < A
    ).

%!  ataca_torre(+Torre, +ReyBlanco, +Casilla) is semidet.
%
%   La torre, que no fue capturada, ataca Casilla: está en su columna o en
%   su fila, y el rey blanco no se interpone. El rey negro nunca tapa una
%   casilla que está detrás de él, porque es él quien se mueve.
ataca_torre(TX-TY, ReyBlanco, X-Y) :-
    TX-TY \== X-Y,
    (   TX =:= X
    ;   TY =:= Y
    ),
    !,
    \+ entre(TX-TY, ReyBlanco, X-Y).

%!  jaque(+Posicion) is semidet.
%
%   Mueven las negras y la torre ataca al rey negro.
jaque(pos(negras, ReyBlanco, Torre, ReyNegro)) :-
    Torre \== capturada,
    ataca_torre(Torre, ReyBlanco, ReyNegro).

%!  jugada(+Posicion, ?Jugada, -Siguiente) is nondet.
%
%   Jugada es una jugada legal del bando que mueve en Posicion, y Siguiente
%   la posición que resulta. Las blancas mueven primero el rey, con las
%   diagonales primero, y después la torre.
jugada(pos(blancas, RB, T, RN), rey(RB, R1), pos(negras, R1, T, RN)) :-
    vecina(RB, R1),
    R1 \== T,
    distancia(R1, RN, D),
    D > 1.
jugada(pos(blancas, RB, T, RN), torre(T, T1), pos(negras, RB, T1, RN)) :-
    T = TX-TY,
    between(1, 8, I),
    (   T1 = TX-I
    ;   T1 = I-TY
    ),
    T1 \== T,
    T1 \== RB,
    T1 \== RN,
    \+ entre(T, RB, T1).
jugada(pos(negras, RB, T, RN), rey(RN, N1), pos(blancas, RB, T1, N1)) :-
    vecina(RN, N1),
    distancia(RB, N1, D),
    D > 1,
    (   N1 == T
    ->  T1 = capturada
    ;   T1 = T,
        \+ ( T \== capturada, ataca_torre(T, RB, N1) )
    ).

%!  mate(+Posicion) is semidet.
%
%   Mueven las negras, su rey está en jaque y no tiene ninguna jugada.
mate(Posicion) :-
    jaque(Posicion),
    \+ jugada(Posicion, _, _).

%!  ahogado(+Posicion) is semidet.
%
%   Mueven las negras, su rey no está en jaque y no tiene ninguna jugada:
%   la partida termina en tablas.
ahogado(Posicion) :-
    Posicion = pos(negras, _, _, _),
    \+ jaque(Posicion),
    \+ jugada(Posicion, _, _).

%!  legal(+Posicion) is semidet.
%
%   Posicion puede darse en una partida: las tres piezas en casillas
%   distintas del tablero, los reyes no se tocan y, si mueven las blancas,
%   el rey negro no está en jaque.
legal(pos(Lado, RB, T, RN)) :-
    memberchk(Lado, [blancas, negras]),
    maplist(dentro, [RB, RN]),
    (   T == capturada
    ->  true
    ;   dentro(T),
        T \== RB,
        T \== RN
    ),
    distancia(RB, RN, D),
    D > 1,
    (   Lado == blancas, T \== capturada
    ->  \+ ataca_torre(T, RB, RN)
    ;   true
    ).

%!  dentro(+Casilla) is semidet.
%
%   Casilla es una casilla del tablero.
dentro(X-Y) :-
    integer(X),
    integer(Y),
    en_tablero(X),
    en_tablero(Y).

%!  casilla(?Nombre:atom, ?Casilla) is det.
%
%   Nombre es el nombre algebraico de Casilla: c6 es 3-6.
casilla(Nombre, X-Y) :-
    (   atom(Nombre)
    ->  atom_codes(Nombre, [CX, CY]),
        X is CX - 0'a + 1,
        Y is CY - 0'0
    ;   CX is 0'a + X - 1,
        CY is 0'0 + Y,
        atom_codes(Nombre, [CX, CY])
    ).

%!  notacion(+Jugada, -Texto:atom) is det.
%
%   Texto es Jugada en notación algebraica abreviada, con R para el rey y T
%   para la torre: rey(4-5, 3-6) es Rc6.
notacion(rey(_, A), Texto) :-
    casilla(N, A),
    atom_concat('R', N, Texto).
notacion(torre(_, A), Texto) :-
    casilla(N, A),
    atom_concat('T', N, Texto).

%!  filas(+Posicion, -Filas:list) is det.
%
%   Filas es el tablero de Posicion como una lista de ocho cadenas, de la
%   fila 8 a la 1: R el rey blanco, T la torre, r el rey negro y un punto
%   cada casilla vacía.
filas(Posicion, Filas) :-
    findall(Fila,
            ( between(1, 8, I),
              Y is 9 - I,
              fila(Posicion, Y, Fila) ),
            Filas).

%!  fila(+Posicion, +Y:integer, -Fila:string) is det.
%
%   Fila es la fila Y de Posicion, con su número delante.
fila(Posicion, Y, Fila) :-
    findall(S,
            ( between(1, 8, X),
              pieza(Posicion, X-Y, S) ),
            Ss),
    atomic_list_concat([Y|Ss], ' ', A),
    atom_string(A, Fila).

%!  pieza(+Posicion, +Casilla, -Simbolo) is det.
%
%   Simbolo es lo que se dibuja en Casilla.
pieza(pos(_, RB, T, RN), C, S) :-
    (   C == RB
    ->  S = 'R'
    ;   C == T
    ->  S = 'T'
    ;   C == RN
    ->  S = r
    ;   S = '.'
    ).

%!  mostrar(+Posicion) is det.
%
%   Escribe el tablero de Posicion, con las letras de las columnas debajo.
mostrar(Posicion) :-
    filas(Posicion, Filas),
    forall(member(F, Filas), format("~s~n", [F])),
    format("  a b c d e f g h~n").
