:- encoding(utf8).

:- begin_tests(proyecto).

test(simular, [nondet, true(Ss == [0, 0, 0, 1])]) :-
    simular(sumador3, [1, 1, 0, 1, 0, 1], Ss).

test(formula, [nondet, true(Ps == [[a, b], [a, ci, ~b], [b, ci, ~a]])]) :-
    formula(sumador, co, F),
    suma_de_productos(F, Ps).

test(equivalentes) :-
    equivalentes(sumador, sumador_mayoria).

test(ejecutar, [nondet, true(Ss == [[0, 0, 0], [1, 0, 0], [1, 1, 0]])]) :-
    ejecutar(contador_gray, [0, 0, 0], [[], [], []], Ss).

test(alcanzables, [true(N == 8)]) :-
    alcanzables(contador_gray, [0, 0, 0], Es),
    length(Es, N).

:- end_tests(proyecto).
