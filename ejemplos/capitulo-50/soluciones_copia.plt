:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(soluciones_copia).

test(ninguna_simple, [true(N == 23)]) :-
    mas_simples(fuerte, sumador, [[1, 1, 1]-[0, 0]], Ds),
    length(Ds, N).

test(copia, [nondet]) :-
    mas_simples(fuerte, sumador, [[1, 1, 1]-[0, 0]], Ds),
    member([[m2, x1]-copia(1), [o1]-copia(2)], Ds).

:- end_tests(soluciones_copia).
