:- encoding(utf8).

:- begin_tests(camino).

test(colas, [true(Cs == [t1-24, t2-22, t3-22, t4-20, t5-20, t6-11, t7-11])]) :-
    ejemplo(coffman, P),
    findall(T-C, ( tarea(P, T, _), cola(P, T, C) ), Cs).

test(cola_casa, [true(C == 27)]) :-
    ejemplo(casa, P),
    cola(P, cimientos, C).

test(camino_inicial, [true(H == 24)]) :-
    ejemplo(coffman, P),
    inicial(datos(P, camino), E),
    camino(P, E, H).

test(predecesora_empezada, [true(H == 20)]) :-
    ejemplo(coffman, P),
    camino(P, e([t4, t5, t6, t7], [2, 2, 4], [t1-4, t2-2, t3-2]), H).

test(combinada, [true(H == 24)]) :-
    ejemplo(coffman, P),
    inicial(datos(P, combinada), E),
    combinada(P, E, H).

test(coffman, [true(D-K == 24-9)]) :-
    ejemplo(coffman, P),
    optimo(P, combinada, C, K),
    valido(P, C),
    duracion(C, D).

test(casa, [true(D-K1-K2 == 28-16-16)]) :-
    ejemplo(casa, P),
    optimo(P, camino, _, K1),
    optimo(P, combinada, C, K2),
    valido(P, C),
    duracion(C, D).

test(colas_nombre, [true(C == [t1-24, t2-22, t3-22, t4-20, t5-20, t6-11,
                                t7-11])]) :-
    colas(coffman, C).

:- end_tests(camino).
