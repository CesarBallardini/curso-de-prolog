:- encoding(utf8).

:- use_module(library(nb_set)).

:- begin_tests(consistencia).

% minimo(P): un proyecto de dos tareas, la segunda después de la primera,
% con un solo procesador.
minimo(proyecto([tarea(a, 2), tarea(b, 3)], [antes(a, b)], 1)).

test(alcanzables_minimo,
     [true(Es == [ e([], [5], [a-2, b-5]), e([a, b], [0], []),
                   e([b], [2], [a-2]) ])]) :-
    minimo(P),
    alcanzables(P, Es).

test(alcanzables_casa, [true(N == 1017)]) :-
    ejemplo(casa, P),
    alcanzables(P, Es),
    length(Es, N).

test(alcanzables_coffman, [true(N == 22685)]) :-
    ejemplo(coffman, P),
    alcanzables(P, Es),
    length(Es, N).

test(casa_consistentes) :-
    ejemplo(casa, P),
    consistente(P, reparto),
    consistente(P, camino),
    consistente(P, combinada).

test(coffman_combinada) :-
    ejemplo(coffman, P),
    consistente(P, combinada).

test(salteada_no_consistente, [fail]) :-
    ejemplo(casa, P),
    consistente(P, salteada).

test(inconsistentes, [true(N1-N2 == 225-0)]) :-
    ejemplo(casa, P),
    inconsistentes(P, salteada, N1),
    inconsistentes(P, camino, N2).

test(arista,
     [true(E-S-C == e([t1, t2, t4, t5], [2, 13, 13],
                      [t3-2, t6-13, t7-13]) -
                    e([t2, t4, t5], [6, 13, 13],
                      [t1-6, t3-2, t6-13, t7-13]) - 0)]) :-
    ejemplo(coffman, P),
    once(arista_inconsistente(P, salteada, E, S, C)).

test(salteada, [true(H1-H2-H3 == 0-20-20)]) :-
    ejemplo(coffman, P),
    salteada(P, e([t2, t4, t5, t6, t7], [0, 2, 4], [t1-4, t3-2]), H1),
    salteada(P, e([t2, t3, t4, t5, t6, t7], [0, 0, 4], [t1-4]), H2),
    camino(P, e([t2, t3, t4, t5, t6, t7], [0, 0, 4], [t1-4]), H3).

test(salteada_optima, [true(D-K == 24-52)]) :-
    ejemplo(coffman, P),
    optimo(P, salteada, C, K),
    valido(P, C),
    duracion(C, D).

test(recorrer, [true(N == 3)]) :-
    minimo(P),
    empty_nb_set(S),
    add_nb_set(e([a, b], [0], []), S),
    consistencia:recorrer([e([a, b], [0], [])], P, S),
    size_nb_set(S, N).

test(medir_consistencia, [true(E-N1-N2 == 1017-0-225)]) :-
    medir_consistencia(casa, combinada, E, N1),
    medir_consistencia(casa, salteada, _, N2).

:- end_tests(consistencia).
