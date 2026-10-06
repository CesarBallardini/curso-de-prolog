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

% normalizar/3 olvida el fin de las tareas sin sucesoras pendientes.
test(normalizar, [true(E == e([t4, t6], [4, 4, 4], [t1-4, t2-2, t3-2]))]) :-
    ejemplo(coffman, P),
    soluciones_estados:normalizar(datos(P, cero),
                                  e([t4, t6], [4, 4, 4],
                                    [t1-4, t2-2, t3-2, t5-24]), E).

test(sirve) :-
    ejemplo(coffman, P),
    soluciones_estados:sirve(P, [t4], t1-4).

test(no_sirve, [fail]) :-
    ejemplo(coffman, P),
    soluciones_estados:sirve(P, [t6], t1-4).

test(sucesor, [all(A == [empezar(t1, 0, 4), empezar(t2, 0, 2),
                         empezar(t3, 0, 2)])]) :-
    ejemplo(coffman, P),
    espacio:inicial(datos(P, cero), E0),
    soluciones_estados:sucesor(datos(P, cero), E0, A, _, _).

:- end_tests(soluciones_estados).
