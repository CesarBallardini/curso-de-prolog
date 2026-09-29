:- encoding(utf8).

% Capítulo 40 - Soluciones de los ejercicios 5 y 9 sobre el rompecabezas
% de 8.
%
% El archivo incluye puzzle8.pl y le agrega cláusulas: la estrategia
% anchura_lista, con la cola como lista cerrada y append/3 (ejercicio 5), y
% la heurística doble, el doble de manhattan, que estima de más
% (ejercicio 9).
%
% solo-local: incluye puzzle8.pl con include/1, y SWISH no permite cargar
% otro archivo.
%
%?- ejemplo(medio, E), buscar(anchura_lista, puzzle(E, cero), _, C, K).
%?- ejemplo(dificil, E), buscar(mejor(a_estrella), puzzle(E, doble), _, C, K).

:- discontiguous vacia/2, sacar/4, agregar/5, estimacion/3.

:- include(puzzle8).

% Ejercicio 5

%!  vacia(+Estrategia, -Frontera) is det.
%
%   Para anchura_lista, la frontera es una lista cerrada, vacía al empezar.
vacia(anchura_lista, []).

%!  sacar(+Estrategia, +Frontera0, -Nodo, -Frontera) is semidet.
%
%   Para anchura_lista, Nodo es el primero de la lista.
sacar(anchura_lista, [Nodo|Cola], Nodo, Cola).

%!  agregar(+Estrategia, +Problema, +Nodos:list, +Frontera0, -Frontera)
%!      is det.
%
%   Para anchura_lista, Nodos van al final de la lista, con append/3.
agregar(anchura_lista, _, Nodos, Cola0, Cola) :-
    append(Cola0, Nodos, Cola).

% Ejercicio 9

%!  estimacion(+Nombre, +Estado, -H:integer) is det.
%
%   La heurística doble estima el doble que manhattan, y por eso estima de
%   más.
estimacion(doble, Estado, H) :-
    estimacion(manhattan, Estado, H0),
    H is 2 * H0.
