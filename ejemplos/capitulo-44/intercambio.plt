:- encoding(utf8).

:- begin_tests(intercambio).

test(intercambiar, true(E == (x + 3 = (x + 1) ^ 2))) :-
    intercambiar(sqrt(x + 3) = x + 1, x, E).

test(intercambiar_y_desarrollar,
     true(E == (5 * x - 25 = 2 ^ 2 + 2 * 2 * sqrt(x - 1) + (x - 1)))) :-
    intercambiar(sqrt(5 * x - 25) - sqrt(x - 1) = 2, x, E).

test(sin_raices, fail) :-
    intercambiar(x + 1 = 3, x, _).

test(no_reduce_las_raices, fail) :-
    intercambiar(x - 1 = (sqrt(5 * x - 25) - 2) ^ 2 + sqrt(x), x, _).

test(z_ocupada, fail) :-
    intercambiar(sqrt(x) + z = x, x, _).

test(raices_con, true(N == 2)) :-
    raices_con(sqrt(x) + sqrt(2) + sqrt(x + 1) = 1, x, N).

test(desarrollar, true(E == 1 ^ 2 + 2 * 1 * sqrt(x) + x)) :-
    desarrollar((1 + sqrt(x)) ^ 2, E).

test(desarrollar_resta, true(E == (y - 2 * 3 * sqrt(y) + 3 ^ 2 = 4))) :-
    desarrollar((sqrt(y) - 3) ^ 2 = 4, E).

test(desarrollar_raiz, true(E == x + 1)) :-
    desarrollar(sqrt(x + 1) ^ 2, E).

test(desarrollar_nada, true(E == (x + 1) ^ 2)) :-
    desarrollar((x + 1) ^ 2, E).

test(resolver, all(S == [x = -2.0, x = 1.0])) :-
    resolver_intercambio(sqrt(x + 3) = x + 1, x, S).

test(resolver_sin_intercambio, all(S == [x = 9 / 3])) :-
    resolver_intercambio(3 * x + 2 = 11, x, S).

test(espuria, true(Vs == [1.0])) :-
    valores_intercambio(sqrt(x + 3) = x + 1, x, Vs).

test(dos_raices, true(Vs == [0.0, 4.0])) :-
    valores_intercambio(sqrt(2 * x + 1) - sqrt(x) = 1, x, Vs).

test(press, all(S == [x = 5.0, x = 10.0])) :-
    resolver_intercambio(sqrt(5 * x - 25) - sqrt(x - 1) = 2, x, S).

test(press_valores, true(Vs == [10.0])) :-
    valores_intercambio(sqrt(5 * x - 25) - sqrt(x - 1) = 2, x, Vs).

test(libre, error(instantiation_error)) :-
    resolver_intercambio(sqrt(_) = 1, x, _).

:- end_tests(intercambio).
