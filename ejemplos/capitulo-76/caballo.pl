:- encoding(utf8).

% Capítulo 76 - Versión 6: el caballo de ajedrez, de una casilla a otra.
%
% En un tablero de N x N, la casilla X-Y está en la columna X y la fila Y,
% de 1 a N; en el de 8 x 8 la columna 1 es la a y la fila 1 la de abajo,
% así que a8 es 1-8 y h1 es 8-1. Un salto del caballo avanza dos casillas
% en una dirección y una en la otra, y cuesta 1. El problema es
% saltos(N, Desde, Hasta, Heuristica), con las heurísticas de Csenki:
%
%   cero        0;
%   manhattan   la distancia con movimientos horizontales y verticales,
%               dividida por 3, lo que un salto avanza en esa medida;
%   euclidea    la distancia en línea recta dividida por la raíz de 5, la
%               longitud de un salto;
%   combinada   la mayor de las dos anteriores;
%   minima      la menor de las diferencias de columna y de fila, que
%               estima de más: no es admisible;
%   entera(H)   la heurística H redondeada hacia arriba, que sigue siendo
%               admisible porque la cantidad de saltos es entera.
%
% solo-local: carga las búsquedas del capítulo 40.
%
%?- saltos_entre(a8, h1, Casillas).
%?- caballo(8, a_estrella, euclidea, 1-8, 8-1, Camino, Saltos, K).

:- module(caballo,
          [ salto/4,
            caballo/8,
            saltos_entre/3,
            casilla/2,
            estimar/4
          ]).

:- use_module(capitulo40).

% --- El tablero ---------------------------------------------------------------

%!  salto(+N:integer, +Desde, ?Hasta, -Vector) is nondet.
%
%   Hasta es una casilla del tablero de N x N a la que el caballo llega
%   desde Desde con un salto de Vector DX-DY.
salto(N, X-Y, X1-Y1, DX-DY) :-
    vector(DX, DY),
    X1 is X + DX,
    Y1 is Y + DY,
    X1 >= 1, X1 =< N,
    Y1 >= 1, Y1 =< N.

% vector(DX, DY): los ocho saltos del caballo.
vector(1, 2).
vector(2, 1).
vector(2, -1).
vector(1, -2).
vector(-1, -2).
vector(-2, -1).
vector(-2, 1).
vector(-1, 2).

%!  casilla(?Nombre, ?Celda) is det.
%
%   Nombre es la casilla Celda del tablero de 8 x 8 en la notación del
%   ajedrez: a8 es 1-8. Con Nombre o con Celda instanciado; falla si la
%   casilla no existe.
casilla(Nombre, X-Y) :-
    (   atom(Nombre)
    ->  atom_chars(Nombre, [Columna, Fila]),
        columna(Columna, X),
        atom_number(Fila, Y),
        between(1, 8, Y)
    ;   columna(Columna, X),
        between(1, 8, Y),
        atom_concat(Columna, Y, Nombre)
    ).

% columna(Letra, X): la columna X del tablero se nombra con Letra.
columna(a, 1).
columna(b, 2).
columna(c, 3).
columna(d, 4).
columna(e, 5).
columna(f, 6).
columna(g, 7).
columna(h, 8).

% --- El problema --------------------------------------------------------------

%!  inicial(+Problema, -Estado) is det.
%
%   Estado es la casilla de partida.
inicial(saltos(_, Desde, _, _), Desde).

%!  meta(+Problema, +Estado) is semidet.
%
%   Estado es la casilla de llegada.
meta(saltos(_, _, Hasta, _), Hasta).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   Siguiente es una casilla a un salto de Estado; la Accion es la casilla.
sucesor(saltos(N, _, _, _), Casilla, Siguiente, Siguiente, 1) :-
    salto(N, Casilla, Siguiente, _).

%!  heuristica(+Problema, +Estado, -H:number) is det.
%
%   H es lo que estima la heurística del problema desde Estado.
heuristica(saltos(_, _, Hasta, Nombre), Casilla, H) :-
    estimar(Nombre, Casilla, Hasta, H).

%!  estimar(+Nombre, +A, +B, -H:number) is det.
%
%   H es lo que estima la heurística Nombre de la cantidad de saltos entre
%   las casillas A y B.
estimar(cero, _, _, 0).
estimar(manhattan, X1-Y1, X2-Y2, H) :-
    H is (abs(X1 - X2) + abs(Y1 - Y2)) / 3.
estimar(euclidea, X1-Y1, X2-Y2, H) :-
    H is sqrt((X1 - X2)**2 + (Y1 - Y2)**2) / sqrt(5).
estimar(combinada, A, B, H) :-
    estimar(manhattan, A, B, H1),
    estimar(euclidea, A, B, H2),
    H is max(H1, H2).
estimar(minima, X1-Y1, X2-Y2, H) :-
    H is min(abs(X1 - X2), abs(Y1 - Y2)).
estimar(entera(Nombre), A, B, H) :-
    estimar(Nombre, A, B, H0),
    H is ceiling(H0).

% --- Las consultas ------------------------------------------------------------

%!  caballo(+N:integer, +Algoritmo, +Heuristica, +Desde, +Hasta,
%!          -Camino:list, -Saltos:integer, -Expandidos:integer) is semidet.
%
%   Camino lleva el caballo de Desde a Hasta en el tablero de N x N con
%   Saltos saltos, hallado con Algoritmo, a_estrella o ida_estrella, y la
%   Heuristica. Con una heurística admisible, Saltos es el mínimo.
caballo(N, Algoritmo, Heuristica, Desde, Hasta, [Desde|Plan], Saltos,
        Expandidos) :-
    Problema = caballo:saltos(N, Desde, Hasta, Heuristica),
    resolver(Algoritmo, Problema, Plan, Costo, Expandidos),
    Saltos is integer(Costo).

%!  resolver(+Algoritmo, +Problema, -Plan:list, -Costo:number,
%!           -Expandidos:integer) is semidet.
%
%   Resuelve Problema con A* o con IDA*, las búsquedas del capítulo 40.
resolver(a_estrella, Problema, Plan, Costo, Expandidos) :-
    buscar(mejor(a_estrella), Problema, Plan, Costo, Expandidos).
resolver(ida_estrella, Problema, Plan, Costo, Expandidos) :-
    ida_estrella(Problema, Plan, Costo, Expandidos).

%!  saltos_entre(+Desde, +Hasta, -Casillas:list) is semidet.
%
%   Casillas es un camino más corto del caballo de Desde a Hasta, dos
%   casillas del tablero de 8 x 8 en la notación del ajedrez, hallado con
%   IDA* y la heurística combinada, como la sesión de Csenki.
saltos_entre(Desde, Hasta, Casillas) :-
    casilla(Desde, A),
    casilla(Hasta, B),
    caballo(8, ida_estrella, combinada, A, B, Camino, _, _),
    maplist(casilla, Casillas, Camino).
