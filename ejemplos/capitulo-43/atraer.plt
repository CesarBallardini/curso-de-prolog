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

test(regla, all(D == [log((x + 1) * (x - 1))])) :-
    atraer:regla(x, log(x + 1) + log(x - 1), D).

test(regla_una_aparicion, [fail]) :-
    atraer:regla(x, log(2) + log(x), _).

test(prefijo_comun, true(R == [1, 2])) :-
    atraer:prefijo_comun([1, 2, 3], [1, 2, 4, 5], R).

test(prefijo_comun_vacio, true(R == [])) :-
    atraer:prefijo_comun([], [1], R).

test(profundidad_bajo, true(D == 7)) :-
    atraer:profundidad_bajo(1, [1, 2, 3], 5, D).

test(resolver_,
     all(S == [x = sqrt(exp(3) + 1 * 1), x = -sqrt(exp(3) + 1 * 1)])) :-
    atraer:resolver_(log(x + 1) + log(x - 1) = 3, x, S).

test(distancia_sin_incognita, [fail]) :-
    distancia(2 + 3 = 5, x, _).

:- end_tests(atraer).
