:- encoding(utf8).

% Capítulo 76 - Versión 4: caminos con menos giros.
%
% El problema giros(Plano, Desde, Hasta) es el de robot.pl con otra medida
% del costo: el estado lleva, además de la celda, la dirección del último
% paso, y cada paso cuesta 10, más 1 si cambia de dirección. De dos caminos
% igual de cortos se prefiere el que gira menos, y un camino más corto
% siempre cuesta menos mientras tenga menos de diez giros. Es la medida de
% Csenki, largo + 0,1 x giros, multiplicada por 10 para que los costos
% sean enteros. La heurística es 10 veces la distancia de manhattan.
%
% solo-local: carga robot.pl y las búsquedas del capítulo 40.
%
%?- camino_con_giros(taller, 1-4, 20-6, Camino, Costo, K).

:- module(giros,
          [ camino_con_giros/6,
            camino_con_giros_sin_visitados/6,
            camino_con_giros_ida/6,
            giros_de/2
          ]).

:- reexport(robot).
:- use_module(capitulo40).

% --- El problema ------------------------------------------------------------

%!  inicial(+Problema, -Estado) is det.
%
%   Estado es la celda de partida, todavía sin dirección.
inicial(giros(_, Desde, _), c(Desde, ninguna)).

%!  meta(+Problema, +Estado) is semidet.
%
%   El robot está en la celda de llegada, en cualquier dirección.
meta(giros(_, _, Hasta), c(Hasta, _)).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   El robot pasa a una celda vecina libre, la Accion, en la dirección D;
%   Costo es 10, más 1 si D no es la dirección del paso anterior.
sucesor(giros(Plano, _, _), c(Celda, D0), Vecina, c(Vecina, D), Costo) :-
    vecina(Plano, Celda, D, Vecina),
    costo_paso(D0, D, Costo).

%!  costo_paso(+D0, +D, -Costo:integer) is det.
%
%   Costo es el de un paso en la dirección D después de uno en D0: 10, o
%   11 si es un giro.
costo_paso(D0, D, Costo) :-
    (   ( D0 == ninguna ; D0 == D )
    ->  Costo = 10
    ;   Costo = 11
    ).

%!  heuristica(+Problema, +Estado, -H:integer) is det.
%
%   H es 10 veces la distancia de manhattan a la llegada: cada paso que
%   falta cuesta al menos 10.
heuristica(giros(_, _, Hasta), c(Celda, _), H) :-
    manhattan(Celda, Hasta, D),
    H is 10 * D.

% --- Las consultas ----------------------------------------------------------

%!  camino_con_giros(+Plano, +Desde, +Hasta, -Camino:list, -Costo:integer,
%!                   -Expandidos:integer) is semidet.
%
%   Camino es uno de los caminos más cortos de Desde a Hasta, y de ellos uno
%   con menos giros, hallado con A*; Costo es 10 por paso más 1 por giro.
camino_con_giros(Plano, Desde, Hasta, [Desde|Plan], Costo, Expandidos) :-
    buscar(mejor(a_estrella), giros:giros(Plano, Desde, Hasta), Plan, Costo,
           Expandidos).

%!  camino_con_giros_sin_visitados(+Plano, +Desde, +Hasta, -Camino:list,
%!                                  -Costo:integer, -Expandidos:integer)
%!      is semidet.
%
%   Como camino_con_giros/6, con el bucle que no recuerda los estados vistos.
camino_con_giros_sin_visitados(Plano, Desde, Hasta, [Desde|Plan], Costo,
                               Expandidos) :-
    buscar_sin_visitados(mejor(a_estrella), giros:giros(Plano, Desde, Hasta),
                         Plan, Costo, Expandidos).

%!  camino_con_giros_ida(+Plano, +Desde, +Hasta, -Camino:list,
%!                       -Costo:integer, -Expandidos:integer) is semidet.
%
%   Como camino_con_giros/6, con IDA*.
camino_con_giros_ida(Plano, Desde, Hasta, [Desde|Plan], Costo, Expandidos) :-
    ida_estrella(giros:giros(Plano, Desde, Hasta), Plan, Costo, Expandidos).

%!  giros_de(+Camino:list, -Giros:integer) is det.
%
%   Giros es la cantidad de cambios de dirección de Camino, una lista de
%   celdas vecinas.
giros_de(Camino, Giros) :-
    direcciones(Camino, Ds),
    cambios(Ds, Giros).

%!  direcciones(+Camino:list, -Ds:list) is det.
%
%   Ds son los desplazamientos DX-DY de cada paso de Camino.
direcciones([C|Cs], Ds) :-
    direcciones_(Cs, C, Ds).

%!  direcciones_(+Cs:list, +C0, -Ds:list) is det.
%
%   Ds son los desplazamientos de cada paso de C0 seguida de Cs.
direcciones_([], _, []).
direcciones_([X2-Y2|Cs], X1-Y1, [DX-DY|Ds]) :-
    DX is X2 - X1,
    DY is Y2 - Y1,
    direcciones_(Cs, X2-Y2, Ds).

%!  cambios(+Ds:list, -N:integer) is det.
%
%   N es la cantidad de pares de elementos consecutivos distintos en Ds.
cambios([], 0).
cambios([D|Ds], N) :-
    cambios_(Ds, D, N).

%!  cambios_(+Ds:list, +D0, -N:integer) is det.
%
%   N es la cantidad de pares consecutivos distintos en D0 seguido de Ds.
cambios_([], _, 0).
cambios_([D|Ds], D0, N) :-
    cambios_(Ds, D, N0),
    (   D == D0
    ->  N = N0
    ;   N is N0 + 1
    ).
