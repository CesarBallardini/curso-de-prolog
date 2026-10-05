:- encoding(utf8).

:- begin_tests(robot).

test(anchura, [true(P-K == 23-144)]) :-
    camino(taller, anchura, 1-4, 20-6, _, P, K).

test(a_estrella, [true(P-K == 23-42)]) :-
    camino(taller, a_estrella, 1-4, 20-6, _, P, K).

test(costo_uniforme, [true(P == 23)]) :-
    camino(taller, costo_uniforme, 1-4, 20-6, _, P, _).

test(voraz, [true(P == 25)]) :-
    camino(taller, voraz, 1-4, 20-6, _, P, _).

test(camino_valido) :-
    camino(taller, a_estrella, 1-4, 20-6, C, 23, _),
    length(C, 24),
    C = [1-4|_],
    last(C, 20-6),
    forall(nextto(A, B, C), plano:vecina(taller, A, _, B)).

test(sin_camino, [fail]) :-
    camino(galpon, a_estrella, 1-1, 23-15, _, _, _).

test(sin_visitados, [true(P-K == 12-10822)]) :-
    camino_sin_visitados(patio, 28-8, 32-8, _, P, K).

test(ida, [true(P-K == 12-220)]) :-
    camino_ida(patio, 28-8, 32-8, _, P, K).

test(manhattan, [true(D == 7)]) :-
    manhattan(1-4, 5-1, D).

:- end_tests(robot).
