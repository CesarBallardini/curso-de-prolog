:- encoding(utf8).

:- begin_tests(reinas).

test(primera, [true(Qs == [4, 2, 7, 3, 6, 8, 5, 1])]) :-
    once(reinas(8, Qs)).

test(ocho, [true(N == 92)]) :-
    aggregate_all(count, reinas(8, _), N).

test(seis, [true(N == 4)]) :-
    aggregate_all(count, reinas(6, _), N).

test(tres, [fail]) :-
    reinas(3, _).

% Cada solución usa cada fila una vez: es una permutación de 1..N.
test(permutacion, [nondet]) :-
    reinas(6, Qs),
    msort(Qs, [1, 2, 3, 4, 5, 6]).

test(diagonal, [fail]) :-
    segura(2, [1], 1).

:- end_tests(reinas).
