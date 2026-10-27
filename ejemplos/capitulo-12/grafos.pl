:- encoding(utf8).

% Capítulo 12 - Ejercicios 4 a 8: grafos.
%
% Los grafos no dirigidos 1 y 2 se escriben grafo(Vertices, Aristas), con
% aristas a(X, Y); los grafos dirigidos 3, 4 y 5, como listas de aristas
% arista(X, Y), que van de X a Y.
%
%?- grafo_ejemplo(3, G3), walk(G3, C, Vs, 3).
%?- grafo_ejemplo(1, G1), remover_aristas(G1, e, G).
%?- grafo_ejemplo(2, G2), conexo(G2).
%?- grafo_ejemplo(3, G3), ordenados_x_grado(G3, Vs).

% grafo_ejemplo(N, G): G es el grafo N de los enunciados.
grafo_ejemplo(1, grafo([a, b, c, d, e],
                       [a(a, b), a(a, d), a(a, e), a(b, c), a(b, d),
                        a(c, e), a(e, d)])).
grafo_ejemplo(2, grafo([a, b, c, d, e, f],
                       [a(a, b), a(a, c), a(b, c), a(d, e), a(f, e)])).
grafo_ejemplo(3, [arista(a, b), arista(a, c), arista(b, c), arista(c, d),
                  arista(c, e), arista(d, e)]).
grafo_ejemplo(4, [arista(a, b), arista(a, c), arista(b, c), arista(c, d),
                  arista(d, a)]).
grafo_ejemplo(5, [arista(1, 2), arista(1, 3), arista(2, 2), arista(2, 4),
                  arista(2, 5), arista(3, 4), arista(4, 5), arista(5, 6)]).

% --- Ejercicio 4 -----------------------------------------------------------

%!  walk(+G, ?Camino, ?Vertices, +Long) is nondet.
%
%   Camino es una lista de Long aristas consecutivas del grafo G, que puede
%   repetir aristas, y Vertices es la lista de los vértices que recorre.
walk(G, [arista(X, Y)], [X, Y], 1) :-
    member(arista(X, Y), G).
walk(G, [arista(X, Y)|Camino], [X, Y|Vertices], Long) :-
    Long > 1,
    member(arista(X, Y), G),
    Anterior is Long - 1,
    walk(G, Camino, [Y|Vertices], Anterior).

% --- Ejercicio 5 -----------------------------------------------------------

%!  remover_aristas(+G, ?V, -G2) is nondet.
%
%   V es un vértice de G, y G2 es G sin las aristas que incluyen a V.
remover_aristas(grafo(Vs, As), V, grafo(Vs, Restantes)) :-
    member(V, Vs),
    sin_aristas_de(V, As, Restantes).

%!  sin_aristas_de(+V, +As, -Restantes) is det.
%
%   Restantes son las aristas de As que no incluyen al vértice V.
sin_aristas_de(_, [], []).
sin_aristas_de(V, [A|As], Restantes) :-
    incluye(A, V),
    sin_aristas_de(V, As, Restantes).
sin_aristas_de(V, [A|As], [A|Restantes]) :-
    \+ incluye(A, V),
    sin_aristas_de(V, As, Restantes).

%!  incluye(?A, ?V) is nondet.
%
%   La arista A incluye al vértice V, en cualquiera de sus dos extremos.
incluye(a(V, _), V).
incluye(a(_, V), V).

%!  cobertura_vertices(+G, +C) is semidet.
%
%   C es una cobertura de vértices de G: al quitar de G las aristas de cada
%   vértice de C no queda ninguna arista.
cobertura_vertices(G, C) :-
    remover_todas(C, G, grafo(_, [])).

%!  remover_todas(+Vs, +G, -G2) is semidet.
%
%   G2 es G sin las aristas que incluyen a alguno de los vértices de Vs.
remover_todas([], G, G).
remover_todas([V|Vs], G, G2) :-
    remover_aristas(G, V, G1),
    remover_todas(Vs, G1, G2).

%!  clique(+G, +C) is semidet.
%
%   C es un clique de G: todos sus elementos son vértices de G y cada par de
%   vértices distintos de C es adyacente.
clique(grafo(Vs, As), C) :-
    \+ ( member(X, C),
         \+ member(X, Vs) ),
    \+ ( member(X, C),
         member(Y, C),
         X \== Y,
         \+ adyacente(X, Y, As) ).

%!  adyacente(?X, ?Y, +As) is nondet.
%
%   Alguna arista de As une X con Y, en cualquiera de los dos sentidos.
adyacente(X, Y, As) :-
    member(a(X, Y), As).
adyacente(X, Y, As) :-
    member(a(Y, X), As).

% --- Ejercicio 6 -----------------------------------------------------------

%!  trail(+G, ?Camino, ?Vertices) is nondet.
%
%   Camino es una lista no vacía de aristas de G, cada una a lo sumo una vez
%   y escrita en el sentido del recorrido; Vertices son los vértices por los
%   que pasa, en orden.
trail(grafo(_, As), [a(X, Y)|Camino], [X|Vertices]) :-
    adyacente(X, Y, As),
    seguir(As, [a(X, Y)], Y, Camino, Vertices).

%!  seguir(+As, +Usadas, +Y, ?Camino, ?Vertices) is nondet.
%
%   Camino continúa desde el vértice Y con aristas de As que no están en
%   Usadas; Vertices son los vértices desde Y.
seguir(_, _, Y, [], [Y]).
seguir(As, Usadas, Y, [a(Y, Z)|Camino], [Y|Vertices]) :-
    adyacente(Y, Z, As),
    \+ adyacente(Y, Z, Usadas),
    seguir(As, [a(Y, Z)|Usadas], Z, Camino, Vertices).

%!  conexo(+G) is semidet.
%
%   Para todo par de vértices distintos de G hay un camino que los une: no
%   existe un par de vértices distintos sin camino entre ellos.
conexo(grafo(Vs, As)) :-
    \+ ( member(X, Vs),
         member(Y, Vs),
         X \== Y,
         \+ ( trail(grafo(Vs, As), _, Recorrido),
              Recorrido = [X|_],
              last(Recorrido, Y) ) ).

% --- Ejercicio 7 -----------------------------------------------------------

%!  vertice(+G, ?V) is nondet.
%
%   V es el origen o el destino de alguna arista del grafo dirigido G.
vertice(G, V) :-
    member(arista(V, _), G).
vertice(G, V) :-
    member(arista(_, V), G).

%!  vertices(+G, -Vs) is det.
%
%   Vs es la lista de los vértices de G, cada uno una vez. Vs debe llegar
%   libre: el corte de armar_vertices/3 es rojo.
vertices(G, Vs) :-
    armar_vertices(G, Vs, []).

%!  armar_vertices(+G, -Vs, +YaIncluidas) is det.
%
%   Vs es la lista de los vértices de G que no están en YaIncluidas.
armar_vertices(G, [V|Vs], YaIncluidas) :-
    vertice(G, V),
    \+ member(V, YaIncluidas),
    !,
    append(YaIncluidas, [V], YaIncluidasConV),
    armar_vertices(G, Vs, YaIncluidasConV).
armar_vertices(_, [], _).

%!  grado_salida(+G, ?V, ?N) is nondet.
%
%   N es la cantidad de aristas de G que salen del vértice V.
grado_salida(G, V, N) :-
    vertices(G, Vs),
    member(V, Vs),
    salientes(G, V, N).

%!  salientes(+As, +V, -N) is det.
%
%   N es la cantidad de aristas de la lista As que salen de V.
salientes([], _, 0).
salientes([arista(V, _)|As], V, N) :-
    salientes(As, V, N0),
    N is N0 + 1.
salientes([arista(X, _)|As], V, N) :-
    X \== V,
    salientes(As, V, N).

%!  ordenados_x_grado(+G, -Vs) is det.
%
%   Vs son los vértices de G en orden ascendente de grado de salida; los de
%   igual grado quedan en el orden de vertices/2.
ordenados_x_grado(G, Ordenados) :-
    vertices(G, Vs),
    ordena_por_grado(G, Vs, Ordenados).

%!  ordena_por_grado(+G, +Vs, -Ordenados) is det.
%
%   Ordenados tiene los vértices de Vs en orden ascendente de grado de
%   salida en G. Ordenamiento por inserción, como ordena/2.
ordena_por_grado(_, [], []).
ordena_por_grado(G, [V|Vs], Ordenados) :-
    ordena_por_grado(G, Vs, Parcial),
    inserta_por_grado(G, V, Parcial, Ordenados).

%!  inserta_por_grado(+G, +V, +Vs, -Zs) is det.
%
%   Zs es la lista Vs, ordenada por grado, con V insertado en su lugar.
inserta_por_grado(_, V, [], [V]).
inserta_por_grado(G, V, [W|Ws], [W|Zs]) :-
    grado_salida(G, V, N),
    grado_salida(G, W, M),
    N > M,
    inserta_por_grado(G, V, Ws, Zs).
inserta_por_grado(G, V, [W|Ws], [V, W|Ws]) :-
    grado_salida(G, V, N),
    grado_salida(G, W, M),
    N =< M.

% --- Ejercicio 8 -----------------------------------------------------------

%!  recorrido(+G, +N, ?X, ?Y) is nondet.
%
%   En el grafo dirigido G hay un camino de N aristas, N mayor que cero,
%   que va de X a Y. Las aristas se pueden repetir.
recorrido(G, 1, X, Y) :-
    member(arista(X, Y), G).
recorrido(G, N, X, Y) :-
    N > 1,
    member(arista(X, Z), G),
    N1 is N - 1,
    recorrido(G, N1, Z, Y).

%!  genera_grafo(+G1, +N, -G2) is det.
%
%   G2 tiene una arista de X a Y por cada par de vértices unidos en G1 por un
%   camino de N aristas. G2 debe llegar libre.
genera_grafo(G1, N, G2) :-
    armar_grafo(G1, N, G2, []).

%!  armar_grafo(+G1, +N, -G2, +YaIncluidas) is det.
%
%   G2 son las aristas de caminos de longitud N en G1 que no están en
%   YaIncluidas.
armar_grafo(G1, N, [arista(X, Y)|G2], YaIncluidas) :-
    recorrido(G1, N, X, Y),
    \+ member(arista(X, Y), YaIncluidas),
    !,
    append(YaIncluidas, [arista(X, Y)], YaIncluidasConArista),
    armar_grafo(G1, N, G2, YaIncluidasConArista).
armar_grafo(_, _, [], _).
