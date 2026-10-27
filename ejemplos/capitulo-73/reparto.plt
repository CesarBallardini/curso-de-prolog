:- encoding(utf8).

:- begin_tests(reparto).

test(inicial, [true(H == 24)]) :-
    ejemplo(coffman, P),
    inicial(datos(P, reparto), E),
    reparto(P, E, H).

test(redondeo, [true(H == 3)]) :-
    reparto(proyecto([tarea(a, 2), tarea(b, 2), tarea(c, 1)], [], 2),
            e([a, b, c], [0, 0], []), H).

test(ya_pasado, [true(H == 0)]) :-
    reparto(proyecto([tarea(a, 1)], [], 2), e([a], [0, 10], [x-10]), H).

test(coffman, [true(D-K == 24-21)]) :-
    ejemplo(coffman, P),
    optimo(P, reparto, C, K),
    valido(P, C),
    duracion(C, D).

test(casa, [true(D-K == 28-231)]) :-
    ejemplo(casa, P),
    optimo(P, reparto, C, K),
    valido(P, C),
    duracion(C, D).

test(voraz, [true(D == 33)]) :-
    ejemplo(coffman, P),
    voraz(P, reparto, C, _),
    valido(P, C),
    duracion(C, D).

test(estimacion_casa, [true(H == 18)]) :-
    estimacion_inicial(casa, reparto, H).

:- end_tests(reparto).
