:- encoding(utf8).

:- begin_tests(soluciones_estados).

test(coffman, [true(D-K == 24-653)]) :-
    ejemplo(coffman, P),
    optimo_normalizado(P, cero, C, K),
    valido(P, C),
    duracion(C, D).

test(casa, [true(D-K == 28-341)]) :-
    ejemplo(casa, P),
    optimo_normalizado(P, cero, C, K),
    valido(P, C),
    duracion(C, D).

test(combinada, [true(D-K == 24-9)]) :-
    ejemplo(coffman, P),
    optimo_normalizado(P, combinada, C, K),
    duracion(C, D).

:- end_tests(soluciones_estados).
