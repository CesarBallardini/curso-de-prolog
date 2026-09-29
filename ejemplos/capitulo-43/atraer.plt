:- encoding(utf8).

:- begin_tests(atraer).

test(logaritmos, all(S == [x = sqrt(exp(3) + 1), x = -sqrt(exp(3) + 1)])) :-
    resolver(log(x + 1) + log(x - 1) = 3, x, S).

test(atraer, true(E == (log((x + 1) * (x - 1)) = 3))) :-
    atraer(log(x + 1) + log(x - 1) = 3, x, E).

test(atraer_falla, [fail]) :-
    atraer(x ^ 2 - 3 * x + 2 = 0, x, _).

test(colecta_antes, all(S == [x = 10 / 5])) :-
    resolver(2 * x + 3 * x = 10, x, S).

test(exponentes, [fail]) :-
    resolver(2 ^ x * 2 ^ (x + 1) = 32, x, _).

test(distancia, true(D == 6)) :-
    distancia(log(x + 1) + log(x - 1) = 3, x, D).

test(distancia_atraida, true(D == 4)) :-
    distancia(log((x + 1) * (x - 1)) = 3, x, D).

test(distancia_una, true(D == 0)) :-
    distancia(3 * x = 1, x, D).

test(distancia_ninguna, [fail]) :-
    distancia(3 = 1, x, _).

test(libre, [error(instantiation_error)]) :-
    resolver(_ = 3, x, _).

:- end_tests(atraer).
