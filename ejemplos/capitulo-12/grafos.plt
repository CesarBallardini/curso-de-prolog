:- encoding(utf8).

:- begin_tests(grafos).

% Ejercicio 4
test(walk_grafo_3, all(Vs == [[a, b, c, d], [a, b, c, e], [a, c, d, e],
                              [b, c, d, e]])) :-
    grafo_ejemplo(3, G),
    walk(G, _, Vs, 3).

test(walk_repite_aristas, [nondet]) :-
    grafo_ejemplo(4, G),
    walk(G, [arista(a, b), arista(b, c), arista(c, d), arista(d, a),
             arista(a, b)], [a, b, c, d, a, b], 5).

test(walk_sin_camino, [fail]) :-
    grafo_ejemplo(3, G),
    walk(G, _, [e|_], 1).

% Ejercicio 5
test(remover_aristas_de_e, all(As == [[a(a, b), a(a, d), a(b, c), a(b, d)]])) :-
    grafo_ejemplo(1, G),
    remover_aristas(G, e, grafo(_, As)).

test(remover_aristas_enumera_vertices, all(V == [a, b, c, d, e])) :-
    grafo_ejemplo(1, G),
    remover_aristas(G, V, _).

test(remover_aristas_vertice_ajeno, [fail]) :-
    grafo_ejemplo(1, G),
    remover_aristas(G, z, _).

test(cobertura_ecb, [nondet]) :-
    grafo_ejemplo(2, G),
    cobertura_vertices(G, [e, c, b]).

test(cobertura_ae, [fail]) :-
    grafo_ejemplo(2, G),
    cobertura_vertices(G, [a, e]).

test(clique_dab) :-
    grafo_ejemplo(1, G),
    clique(G, [d, a, b]).

test(clique_bc) :-
    grafo_ejemplo(2, G),
    clique(G, [b, c]).

test(clique_fed, [fail]) :-
    grafo_ejemplo(2, G),
    clique(G, [f, e, d]).

test(clique_vertice_ajeno, [fail]) :-
    grafo_ejemplo(2, G),
    clique(G, [b, z]).

% Ejercicio 6
test(trails_desde_a, all(C == [[a(a, b)], [a(a, b), a(b, c)],
                               [a(a, b), a(b, c), a(c, a)], [a(a, c)],
                               [a(a, c), a(c, b)],
                               [a(a, c), a(c, b), a(b, a)]])) :-
    grafo_ejemplo(2, G),
    trail(G, C, [a|_]).

test(trail_con_vuelta, [nondet]) :-
    grafo_ejemplo(1, G),
    trail(G, [a(b, c), a(c, e), a(e, d), a(d, b)], Vs),
    assertion(Vs == [b, c, e, d, b]).

test(trail_no_repite_aristas, [fail]) :-
    grafo_ejemplo(2, G),
    trail(G, [a(a, b), a(b, a)], _).

test(grafo_1_conexo) :-
    grafo_ejemplo(1, G),
    conexo(G).

test(grafo_2_no_conexo, [fail]) :-
    grafo_ejemplo(2, G),
    conexo(G).

% Ejercicio 7
test(vertices_grafo_3) :-
    grafo_ejemplo(3, G),
    vertices(G, Vs),
    assertion(Vs == [a, b, c, d, e]).

test(grado_2, all(V == [a, c])) :-
    grafo_ejemplo(3, G),
    grado_salida(G, V, 2).

test(grado_de_e, all(N == [0])) :-
    grafo_ejemplo(3, G),
    grado_salida(G, e, N).

test(grado_de_vertice_ajeno, [fail]) :-
    grafo_ejemplo(3, G),
    grado_salida(G, z, _).

test(ordenados_grafo_3, all(Vs == [[e, b, d, a, c]])) :-
    grafo_ejemplo(3, G),
    ordenados_x_grado(G, Vs).

test(ordenados_grafo_4, all(Vs == [[b, c, d, a]])) :-
    grafo_ejemplo(4, G),
    ordenados_x_grado(G, Vs).

% Ejercicio 8
test(genera_longitud_2) :-
    grafo_ejemplo(5, G),
    genera_grafo(G, 2, G2),
    assertion(G2 == [arista(1, 2), arista(1, 4), arista(1, 5), arista(2, 2),
                     arista(2, 4), arista(2, 5), arista(2, 6), arista(3, 5),
                     arista(4, 6)]).

test(genera_longitud_1_es_el_mismo) :-
    grafo_ejemplo(4, G),
    genera_grafo(G, 1, G2),
    assertion(G2 == G).

test(recorrido_de_longitud_3, all(Y == [2, 4, 5, 5, 6, 5])) :-
    grafo_ejemplo(5, G),
    recorrido(G, 3, 1, Y).

:- end_tests(grafos).
