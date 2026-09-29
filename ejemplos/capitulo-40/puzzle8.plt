:- encoding(utf8).

:- begin_tests(puzzle8).

test(sucesores, [true(As == [arriba, derecha])]) :-
    findall(A, sucesor(puzzle(_, cero), [2, 4, 3, 7, 1, 5, 0, 8, 6],
                       A, _, _),
            As0),
    msort(As0, As).

test(mover, [nondet, true(E == [2, 4, 3, 0, 1, 5, 7, 8, 6])]) :-
    sucesor(puzzle(_, cero), [2, 4, 3, 7, 1, 5, 0, 8, 6], arriba, E, 1).

test(heuristicas, [true(F-M == 6-8)]) :-
    ejemplo(facil, E),
    heuristica(puzzle(E, fuera), E, F),
    heuristica(puzzle(E, manhattan), E, M).

test(meta_cero, [true(H == 0)]) :-
    heuristica(puzzle(_, manhattan), [1, 2, 3, 4, 5, 6, 7, 8, 0], H).

test(a_estrella, [true(C-K == 20-530)]) :-
    ejemplo(medio, E),
    buscar(mejor(a_estrella), puzzle(E, manhattan), _, C, K).

test(a_estrella_fuera, [true(C-K == 20-2992)]) :-
    ejemplo(medio, E),
    buscar(mejor(a_estrella), puzzle(E, fuera), _, C, K).

% La búsqueda voraz expande menos nodos, y su plan no es el más corto.
test(voraz, [true(C-K == 72-182)]) :-
    ejemplo(medio, E),
    buscar(mejor(heuristica), puzzle(E, manhattan), _, C, K).

test(ida_estrella, [true(C-K == 20-1394)]) :-
    ejemplo(medio, E),
    ida_estrella(puzzle(E, manhattan), _, C, K).

% El plan de IDA* lleva de verdad a la meta.
test(plan_valido, [true(F == [1, 2, 3, 4, 5, 6, 7, 8, 0])]) :-
    ejemplo(facil, E),
    ida_estrella(puzzle(E, manhattan), P, 8, _),
    foldl(aplicar(puzzle(E, manhattan)), P, E, F).

test(anchura_facil, [true(C-K == 8-176)]) :-
    ejemplo(facil, E),
    buscar(anchura, puzzle(E, cero), _, C, K).

% Media permutación de las fichas no se puede alcanzar: con dos fichas
% intercambiadas, la búsqueda recorre las 181 440 disposiciones alcanzables
% y falla. Aquí se prueba solo que IDA* no termina en ese caso.
test(inalcanzable, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(
        ida_estrella(puzzle([2, 1, 3, 4, 5, 6, 7, 8, 0], manhattan),
                     _, _, _),
        1000000, R).

aplicar(Problema, Accion, E0, E) :-
    once(sucesor(Problema, E0, Accion, E, _)).

% Los auxiliares de sucesor/5 y de las heurísticas.
test(movimientos_centro, [all(A-D == [arriba-1, abajo-7, izquierda-3,
                                      derecha-5])]) :-
    movimiento(A, 4, D).

test(movimientos_esquina, [all(A-D == [abajo-3, derecha-1])]) :-
    movimiento(A, 0, D).

test(intercambiar, [true(S == [1, 2, 3, 4, 5, 0, 6, 7, 8])]) :-
    intercambiar([1, 2, 3, 4, 0, 5, 6, 7, 8], 4, 5, 5, S).

test(distancia_esquinas, [true(D == 4)]) :-
    distancia(0, 9, D).

% En la meta, las dos heurísticas dan 0; con todas las fichas corridas un
% lugar, fuera cuenta las 8 y manhattan suma 12.
test(estimaciones, [true(Hs == [0-0, 8-12])]) :-
    findall(F-M,
            ( member(E, [[1, 2, 3, 4, 5, 6, 7, 8, 0],
                         [0, 1, 2, 3, 4, 5, 6, 7, 8]]),
              estimacion(fuera, E, F),
              estimacion(manhattan, E, M) ),
            Hs).

:- end_tests(puzzle8).
