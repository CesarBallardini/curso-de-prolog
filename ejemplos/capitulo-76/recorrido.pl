:- encoding(utf8).

% Capítulo 76 - Versión 7: el recorrido del caballo.
%
% Un recorrido del caballo pasa por todas las casillas del tablero de N x N
% exactamente una vez. No hay una meta a la que acercarse: la búsqueda es en
% profundidad, con la vuelta atrás de Prolog, y las casillas visitadas se
% llevan en un assoc (capítulo 22). recorrido/4 prueba los saltos en el
% orden fijo de salto/4; con la regla de Warnsdorff (1823) prueba primero
% las casillas desde las que quedan menos saltos libres. La heurística no
% estima una distancia, como en A*: ordena los hijos de la búsqueda en
% profundidad, y la vuelta atrás sigue disponible por si el orden falla.
%
% solo-local: carga caballo.pl, que carga las búsquedas del capítulo 40.
%
%?- recorrido(ingenuo, 5, 1-1, Camino).
%?- recorrido(warnsdorff, 8, 1-1, Camino).

:- module(recorrido,
          [ recorrido/4,
            es_recorrido/2,
            libres_desde/4,
            tablero/3,
            mostrar_recorrido/3
          ]).

:- use_module(library(assoc)).
:- use_module(library(pairs)).
:- use_module(caballo).

%!  recorrido(+Orden, +N:integer, +Desde, -Camino:list) is nondet.
%
%   Camino es un recorrido del caballo por el tablero de N x N que empieza
%   en Desde: N x N casillas distintas, cada una a un salto de la
%   anterior. Orden es ingenuo o warnsdorff, el orden en que se prueban los
%   saltos; por reintento da los demás recorridos.
recorrido(Orden, N, Desde, [Desde|Camino]) :-
    Total is N * N,
    list_to_assoc([Desde-si], Visitadas),
    continuar(Orden, N, Total, 1, Desde, Visitadas, Camino).

%!  continuar(+Orden, +N:integer, +Total:integer, +K:integer, +Casilla,
%!            +Visitadas, -Camino:list) is nondet.
%
%   Camino completa el recorrido desde Casilla, la K-ésima, sin pasar por
%   las Visitadas.
continuar(_, _, Total, Total, _, _, []).
continuar(Orden, N, Total, K, Casilla, Visitadas, [Siguiente|Camino]) :-
    K < Total,
    candidatas(Orden, N, Casilla, Visitadas, Candidatas),
    member(Siguiente, Candidatas),
    put_assoc(Siguiente, Visitadas, si, Visitadas1),
    K1 is K + 1,
    continuar(Orden, N, Total, K1, Siguiente, Visitadas1, Camino).

%!  candidatas(+Orden, +N:integer, +Casilla, +Visitadas,
%!             -Candidatas:list) is det.
%
%   Candidatas son las casillas sin visitar a un salto de Casilla, en el
%   orden en que se prueban.
candidatas(ingenuo, N, Casilla, Visitadas, Candidatas) :-
    findall(S, sin_visitar(N, Casilla, Visitadas, S), Candidatas).
candidatas(warnsdorff, N, Casilla, Visitadas, Candidatas) :-
    findall(L-S,
            ( sin_visitar(N, Casilla, Visitadas, S),
              libres_desde(N, S, Visitadas, L) ),
            Pares),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Candidatas).

%!  sin_visitar(+N:integer, +Casilla, +Visitadas, -S) is nondet.
%
%   S es una casilla sin visitar a un salto de Casilla.
sin_visitar(N, Casilla, Visitadas, S) :-
    salto(N, Casilla, S, _),
    \+ get_assoc(S, Visitadas, _).

%!  libres_desde(+N:integer, +S, +Visitadas, -L:integer) is det.
%
%   L es la cantidad de casillas sin visitar a un salto de S.
libres_desde(N, S, Visitadas, L) :-
    aggregate_all(count, sin_visitar(N, S, Visitadas, _), L).

%!  es_recorrido(+N:integer, +Camino:list) is semidet.
%
%   Camino pasa una vez por cada casilla del tablero de N x N, y cada una
%   está a un salto de la anterior.
es_recorrido(N, Camino) :-
    Total is N * N,
    length(Camino, Total),
    sort(Camino, Distintas),
    length(Distintas, Total),
    forall(nextto(A, B, Camino), salto(N, A, B, _)).

%!  tablero(+N:integer, +Camino:list, -Filas:list) is det.
%
%   Filas son las filas del tablero de N x N, de arriba hacia abajo, con el
%   número de orden en que Camino pasa por cada casilla.
tablero(N, Camino, Filas) :-
    findall(Fila,
            ( between(1, N, I),
              Y is N + 1 - I,
              findall(K,
                      ( between(1, N, X),
                        nth1(K, Camino, X-Y) ),
                      Fila) ),
            Filas).

%!  mostrar_recorrido(+Orden, +N:integer, +Desde) is semidet.
%
%   Escribe el tablero de N x N con el número de orden de cada casilla en
%   el primer recorrido que encuentra recorrido/4 desde Desde. Falla si no
%   hay recorrido.
mostrar_recorrido(Orden, N, Desde) :-
    once(recorrido(Orden, N, Desde, Camino)),
    tablero(N, Camino, Filas),
    forall(member(Fila, Filas),
           ( forall(member(K, Fila), format("~|~t~d~4+", [K])),
             nl )).
