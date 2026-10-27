:- encoding(utf8).

:- begin_tests(diagnostico).

test(normal, [nondet, true(Ss == [1, 0])]) :-
    simular(sumador, [0, 0, 1], Ss).

test(mas_simples, [true(Ds == [[[m1, x1]-invertida],
                               [[m1, x1]-pegada(1)]])]) :-
    mas_simples(fuerte, sumador, [[0, 0, 1]-[0, 1]], Ds).

test(minimos, [true(N == 14)]) :-
    minimos(fuerte, sumador, [[0, 0, 1]-[0, 1]], 2, Ds),
    length(Ds, N).

test(localizar, [true(Ds == [[[s1, m2, x1]-pegada(1)]])]) :-
    localizar(sumador3, [[s1, m2, x1]-pegada(1)],
              [[1, 1, 0, 1, 0, 1]-[0, 1, 0, 1]], _, Ds).

:- end_tests(diagnostico).
