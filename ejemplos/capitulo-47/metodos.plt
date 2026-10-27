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

test(derivable_exito) :-
    derivable(newton(x ^ 2 = 2, x, 1, _)).

test(derivable_no_derivable, [fail]) :-
    derivable(newton(x = cos(x), x, 1, _)).

% Solo el error de dominio de derivar/3 se convierte en fallo.
test(derivable_otro_error, [error(existence_error(incognita, y))]) :-
    derivable(newton(x ^ 2 = y, x, 1, _)).

test(punto_inicial_numero, [true(X0 == 3)]) :-
    punto_inicial(3, X0).

test(punto_inicial_intervalo, [true(X0 =:= 1.5)]) :-
    punto_inicial(1-2, X0).

test(punto_inicial_otro, [error(type_error(number, a))]) :-
    punto_inicial(a, _).

test(par_inicial_numero, [true(P == 3-4)]) :-
    par_inicial(3, P).

test(par_inicial_intervalo, [true(P == 1-2)]) :-
    par_inicial(1-2, P).

test(dentro_intervalo) :-
    dentro(0-3, 1.5).

test(fuera_intervalo, [fail]) :-
    dentro(0-3, 213.6).

test(dentro_sin_intervalo) :-
    dentro(1, 213.6).

test(error_de, [true(E =:= 0.5)]) :-
    error_de(1, 0.5, E).

test(errores_vacio, [true(Es == [])]) :-
    errores([], 1, Es).

:- end_tests(metodos).
