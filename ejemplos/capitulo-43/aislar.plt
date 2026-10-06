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

test(aislar, all(S == [x = asin((1 - 0) / 2), x = pi - asin((1 - 0) / 2)])) :-
    aislar(1 - 2 * sin(x) = 0, x, S).

test(aislar_dos_apariciones, [fail]) :-
    aislar(2 * x + 3 * x = 10, x, _).

test(axioma_seno, all(E == [x = asin(1 / 2), x = pi - asin(1 / 2)])) :-
    aislar:axioma(1, sin(x) = 1 / 2, E).

test(axioma_producto, all(E == [x = 6 / 3])) :-
    aislar:axioma(2, 3 * x = 6, E).

test(axioma_divisor_nulo, [fail]) :-
    aislar:axioma(2, 0 * x = 6, _).

test(axioma_raiz, all(E == [x = 8 ^ (1 / 3)])) :-
    aislar:axioma(1, x ^ 3 = 8, E).

test(orientar_izquierda, true(E == (x + 1 = 3))) :-
    aislar:orientar(1, x + 1 = 3, E).

test(orientar_derecha, true(E == (x + 1 = 3))) :-
    aislar:orientar(2, 3 = x + 1, E).

test(aislar_camino,
     all(E == [x = asin((1 - 0) / 2), x = pi - asin((1 - 0) / 2)])) :-
    aislar:aislar_camino([2, 2, 1], 1 - 2 * sin(x) = 0, E).

test(aislar_camino_vacio, all(E == [x = 3])) :-
    aislar:aislar_camino([], x = 3, E).

:- end_tests(aislar).
