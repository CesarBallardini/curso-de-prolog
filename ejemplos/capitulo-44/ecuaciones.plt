:- encoding(utf8).

:- begin_tests(ecuaciones).

cercanos(As, Bs) :-
    maplist([A, B]>>(abs(A - B) < 1.0e-9), As, Bs).

test(simbolica, all(S == [x = asin(1 / 2), x = pi - asin(1 / 2)])) :-
    resolver(1 - 2 * sin(x) = 0, x, S).

test(cubica, all(R =:= [2.0945514815423265])) :-
    resolver(x ^ 3 - 2 * x - 5 = 0, x, x = R).

test(cuartica, true(cercanos(Vs, [-2, -1, 1, 2]))) :-
    valores(x ^ 4 - 5 * x ^ 2 + 4 = 0, x, Vs).

test(sin_derivada, [fail]) :-
    resolver(cos(x) = x, x, _).

test(newton, true(abs(R - 2.0945514815423265) < 1.0e-12)) :-
    newton(x ^ 3 - 2 * x - 5, x, 1, R).

% Desde 0, Newton pasa por 1 y vuelve a 0: no converge.
test(ciclo, [fail]) :-
    newton(x ^ 3 - 2 * x + 2, x, 0, _).

test(sin_raiz, [fail]) :-
    newton(x ^ 2 + 1, x, 1, _).

test(espuria, true(cercanos(Vs, [4.591899054115592]))) :-
    valores(log(x + 1) + log(x - 1) = 3, x, Vs).

test(sin_valor_real, true(Vs == [])) :-
    valores(x ^ 2 + 1 = 0, x, Vs).

test(seno, true(cercanos(Vs, [0.5235987755982989, 2.617993877991494]))) :-
    valores(1 - 2 * sin(x) = 0, x, Vs).

test(exponentes, true(cercanos(Vs, [2.0]))) :-
    valores(2 ^ x * 2 ^ (x + 1) = 32, x, Vs).

test(quintica, true(cercanos(Vs, [1.1329975658850653]))) :-
    valores(x ^ 5 + x = 3, x, Vs).

test(sin_derivable_valores, true(Vs == [])) :-
    valores(cos(x) = x, x, Vs).

test(libre, [error(instantiation_error)]) :-
    resolver(_ = 3, x, _).

test(valor, true(Y == 5)) :-
    ecuaciones:valor(x ^ 2 + 1, x, 2, Y).

test(valor_no_real, [fail]) :-
    ecuaciones:valor(log(x), x, -1, _).

test(cerca) :-
    ecuaciones:cerca(1.0, 1.0000000001).

test(lejos, [fail]) :-
    ecuaciones:cerca(1.0, 1.001).

test(cumple) :-
    ecuaciones:cumple(x ^ 2 = 4, x, 2).

test(no_cumple, [fail]) :-
    ecuaciones:cumple(x ^ 2 = 4, x, 3).

test(cumple_sin_valor_real, [fail]) :-
    ecuaciones:cumple(log(x) = 0, x, -1).

test(raices, true(cercanos(Rs, [-1.4142135623730951, 1.4142135623730951]))) :-
    raices(x ^ 2 - 2, 2 * x, x, Rs).

test(raices_ninguna, true(Rs == [])) :-
    raices(x ^ 2 + 1, 2 * x, x, Rs).

test(resolver_numerico, all(R =:= [2.0945514815423265])) :-
    ecuaciones:resolver_numerico(x ^ 3 - 2 * x - 5 = 0, x, x = R).

test(resolver_numerico_sin_derivada, [fail]) :-
    ecuaciones:resolver_numerico(cos(x) = x, x, _).

test(iniciales, all(X0 == [-10, -1, 1, 10])) :-
    ecuaciones:inicial(X0).

:- end_tests(ecuaciones).
