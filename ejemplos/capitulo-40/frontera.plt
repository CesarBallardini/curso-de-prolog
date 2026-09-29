:- encoding(utf8).

:- begin_tests(frontera).

test(anchura, [true(P-C-K == [llenar(2), pasar(2, 1), llenar(2),
                              pasar(2, 1)]-10-67)]) :-
    buscar(anchura, jarras(4, 3, 2), P, C, K).

test(costo, [true(C-K == 10-24)]) :-
    buscar(mejor(costo), jarras(4, 3, 2), _, C, K).

% Sin visitados, en profundidad no termina.
test(profundidad_no_termina, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(buscar(profundidad, jarras(4, 3, 2),
                                     _, _, _),
                              1000000, R).

% La cola con contador del capítulo 34: primero en entrar, primero en
% salir, y falla vacía.
test(cola, [true(X-Y == a-b)]) :-
    frontera_inicial(anchura, p, a, C0),
    agregar(anchura, p, [b], C0, C1),
    sacar(anchura, C1, X, C2),
    sacar(anchura, C2, Y, C3),
    \+ sacar(anchura, C3, _, _).

test(pila, [true(X == b)]) :-
    frontera_inicial(profundidad, p, a, P0),
    agregar(profundidad, p, [b], P0, P1),
    sacar(profundidad, P1, X, _).

test(monticulo, [true(X == nodo(e2, [], 2))]) :-
    frontera_inicial(mejor(costo), p, nodo(e5, [], 5), M0),
    agregar(mejor(costo), p, [nodo(e2, [], 2), nodo(e7, [], 7)], M0, M1),
    sacar(mejor(costo), M1, X, _).

% Los hijos comparten el camino del padre: no es una copia.
test(camino_compartido, [true]) :-
    Camino = [llenar(1)],
    hijos(jarras(4, 3, 2), nodo(j(4, 0), Camino, 4), [nodo(_, [_|C], _)|_]),
    same_term(C, Camino).

:- end_tests(frontera).
