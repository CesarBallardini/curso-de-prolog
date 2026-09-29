:- encoding(utf8).

:- begin_tests(metodos).

test(newton, [true(M == newton)]) :-
    resolver(x ^ 2 = 2, x, 1, R, M),
    abs(R - sqrt(2)) =< 1.0e-12.

% Newton entra en un ciclo; la secante, desde 0 y 1, encuentra la raíz.
test(secante_tras_newton, [true(M == secante)]) :-
    resolver(x ^ 3 - 2 * x + 2 = 0, x, 0, R, M),
    abs(R + 1.7692923542386314) =< 1.0e-12.

test(no_derivable, [true(M == secante)]) :-
    resolver(x = cos(x), x, 0-1, R, M),
    abs(R - 0.7390851332151607) =< 1.0e-12.

% La secante sale del intervalo; la bisección no.
test(biseccion, [true(M == biseccion)]) :-
    resolver(sin(x) = 0.01, x, 0-3, R, M),
    abs(R - asin(0.01)) =< 1.0e-11.

test(sin_intervalo, [true(M == secante)]) :-
    resolver(sin(x) = 0.01, x, 1, R, M),
    R > 200.

test(sin_raiz, [fail]) :-
    resolver(x ^ 2 + 1 = 0, x, 1, _, _).

test(metodo_ligado, [fail]) :-
    resolver(x ^ 2 = 2, x, 1, _, secante).

test(inicio_libre, [error(instantiation_error)]) :-
    resolver(x ^ 2 = 2, x, _, _, _).

test(errores, [true(Es == [0.5, 0.25])]) :-
    errores([1.5, 1.25], 1, Es).

:- end_tests(metodos).
