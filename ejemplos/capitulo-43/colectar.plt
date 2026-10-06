:- encoding(utf8).

:- begin_tests(colectar).

test(lineal, all(S == [x = 10 / 5])) :-
    resolver(2 * x + 3 * x = 10, x, S).

test(seno, all(S == [x = asin(1 / 5), x = pi - asin(1 / 5)])) :-
    resolver(2 * sin(x) + 3 * sin(x) = 1, x, S).

test(producto, all(S == [x = sqrt(4), x = -sqrt(4)])) :-
    resolver(x * x = 4, x, S).

test(diferencia_de_cuadrados, all(S == [x = sqrt(9), x = -sqrt(9)])) :-
    resolver((x + 2) * (x - 2) = 5, x, S).

test(una_aparicion, all(S == [x = 9 / 3])) :-
    resolver(3 * x + 2 = 11, x, S).

test(colectar, true(E == ((2 + 3) * sin(x) = 1))) :-
    colectar(2 * sin(x) + 3 * sin(x) = 1, x, E).

test(colectar_falla, [fail]) :-
    colectar(log(x + 1) + log(x - 1) = 3, x, _).

test(logaritmos, [fail]) :-
    resolver(log(x + 1) + log(x - 1) = 3, x, _).

test(cuadratica, [fail]) :-
    resolver(x ^ 2 - 3 * x + 2 = 0, x, _).

test(comprueba, [nondet]) :-
    resolver(x * x = 4, x, x = -sqrt(4)).

test(libre, [error(instantiation_error)]) :-
    resolver(_ = 3, x, _).

test(regla, all(D == [(2 + 3) * x])) :-
    colectar:regla(x, 2 * x + 3 * x, D).

test(regla_sin_incognita, [fail]) :-
    colectar:regla(x, 2 * y + 3 * y, _).

test(resolver_, all(S == [x = 10 / (2 + 3)])) :-
    colectar:resolver_(2 * x + 3 * x = 10, x, S).

test(resolver_sin_metodo, [fail]) :-
    colectar:resolver_(log(x + 1) + log(x - 1) = 3, x, _).

:- end_tests(colectar).
