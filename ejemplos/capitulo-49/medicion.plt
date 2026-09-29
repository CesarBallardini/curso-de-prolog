:- encoding(utf8).

:- use_module(library(lists)).
:- use_module(minimos).

:- begin_tests(medicion).

test(predecir, [true(Ss == [0, 1])]) :-
    predecir(sumador, [0, 0, 1], [[m1, x1]-pegada(1)], Ss).

test(proxima, [true(Es-P == [0, 1, 1]-5)]) :-
    minimos(fuerte, sumador, [[0, 0, 1]-[0, 1]], 2, Ds),
    proxima(sumador, Ds, Es, P).

test(localizar_simple, [true(Ds == [[[s1, m2, x1]-pegada(1)]])]) :-
    localizar(sumador3, [[s1, m2, x1]-pegada(1)],
              [[1, 1, 0, 1, 0, 1]-[0, 1, 0, 1]], _, Ds).

% Una avería doble queda entre candidatos que ninguna entrada separa.
test(localizar_doble, [true(N-M == 4-3)]) :-
    Averia = [[m1, y1]-pegada(1), [m2, x1]-pegada(0)],
    localizar(sumador, Averia, [[0, 0, 1]-[0, 1]], Obs, Ds),
    length(Obs, N),
    length(Ds, M),
    memberchk(Averia, Ds).

:- end_tests(medicion).
