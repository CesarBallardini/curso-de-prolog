:- encoding(utf8).

:- begin_tests(aislar).

test(lineal, [true(S == (x = 9 / 3)), nondet]) :-
    resolver(3 * x + 2 = 11, x, S).

test(seno, all(S == [x = asin(1 / 2), x = pi - asin(1 / 2)])) :-
    resolver(1 - 2 * sin(x) = 0, x, S).

test(derecha, [true(S == (x = 9 / 3)), nondet]) :-
    resolver(11 = 3 * x + 2, x, S).

test(cociente, [fail]) :-
    resolver(x / 2 = 5, x, _).

test(exponente, [true(S == (x = log(16) / log(2) - 1)), nondet]) :-
    resolver(2 ^ (x + 1) = 16, x, S).

test(cuadrado, all(S == [x = sqrt(9), x = -sqrt(9)])) :-
    resolver(x ^ 2 = 9, x, S).

test(valores, all(V =:= [3.0])) :-
    resolver(2 ^ (x + 1) = 16, x, x = E),
    V is E.

test(dos_apariciones, [fail]) :-
    resolver(2 * x + 3 * x = 10, x, _).

test(sin_incognita, [fail]) :-
    resolver(2 + 3 = 5, x, _).

test(comprueba, [nondet]) :-
    resolver(1 - 2 * sin(x) = 0, x, x = pi - asin(1 / 2)).

test(posicion, all(P == [[1, 2, 2, 1]])) :-
    posicion(x, 1 - 2 * sin(x) = 0, P).

test(posiciones, all(P == [[1, 1], [1, 2], [2, 2]])) :-
    posicion(x, x * x = 3 * x, P).

test(libre, [error(instantiation_error)]) :-
    resolver(_ = 3, x, _).

test(incognita_libre, [error(instantiation_error)]) :-
    resolver(x = 3, _, _).

:- end_tests(aislar).
