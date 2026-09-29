:- encoding(utf8).

:- begin_tests(soluciones_puzzle).

test(anchura_lista, [true(C-K == 8-176)]) :-
    ejemplo(facil, E),
    buscar(anchura_lista, puzzle(E, cero), _, C, K).

test(doble, [true(H == 16)]) :-
    ejemplo(facil, E),
    heuristica(puzzle(E, doble), E, H).

% Con una heurística que estima de más, A* ya no asegura el plan más corto.
test(doble_medio, [true(C-K == 24-619)]) :-
    ejemplo(medio, E),
    buscar(mejor(a_estrella), puzzle(E, doble), _, C, K).

test(doble_dificil, [true(C-K == 30-245)]) :-
    ejemplo(dificil, E),
    buscar(mejor(a_estrella), puzzle(E, doble), _, C, K).

:- end_tests(soluciones_puzzle).
