:- encoding(utf8).

:- begin_tests(soluciones).

% cerca(Xs, Ys, Tol): las dos listas difieren en menos de Tol por
% componente.
cerca(Xs, Ys, Tol) :-
    maplist([X, Y]>>(abs(X - Y) < Tol), Xs, Ys).

test(sin_limite_no_termina, [true(R == inference_limit_exceeded)]) :-
    funcion(x ^ 2 = 2, F),
    call_with_inference_limit(
        iterar_sin_limite(paso_biseccion(F, x), 1.0e-20,
                          intervalo(1.0, -1.0, 2.0), _),
        1000000, R).

test(sin_limite_termina, [true(N == 40)]) :-
    funcion(x ^ 2 = 2, F),
    iterar_sin_limite(paso_biseccion(F, x), 1.0e-12,
                      intervalo(1.0, -1.0, 2.0), Xs),
    length(Xs, N).

test(relativa, [true(abs(R - sqrt(2.0e12)) =< 1.0e-3)]) :-
    biseccion_relativa(x ^ 2 = 2.0e12, x, 0-2.0e6, 1.0e-12, Xs),
    last(Xs, R).

test(relativa_como_absoluta_cerca_de_1, [true(N == 40)]) :-
    biseccion_relativa(x ^ 2 = 2, x, 1-2, 1.0e-12, Xs),
    length(Xs, N).

test(falsa_posicion, [true(N == 17)]) :-
    falsa_posicion(x ^ 2 = 2, x, 1-2, 1.0e-12, Xs),
    length(Xs, N),
    last(Xs, R),
    abs(R - sqrt(2)) =< 1.0e-12.

test(falsa_posicion_sin_cambio,
     [error(domain_error(intervalo_con_cambio_de_signo, 2-3))]) :-
    falsa_posicion(x ^ 2 = 2, x, 2-3, 1.0e-12, _).

test(derivar_coseno, [true(D == 1 - -1 * sin(x))]) :-
    derivar_ampliado(x - cos(x), x, D).

test(derivar_cadena,
     [true(D == cos(x ^ 2) * (2 * x) + 2 * exp(2 * x) + 1 / x)]) :-
    derivar_ampliado(sin(x ^ 2) + exp(2 * x) + log(x), x, D).

test(derivar_otra, [error(domain_error(expresion_derivable, tan(x)))]) :-
    derivar_ampliado(tan(x), x, _).

test(newton_ampliado, [true(abs(R - cos(R)) =< 1.0e-12)]) :-
    newton_ampliado(x = cos(x), x, 1, 1.0e-12, Xs),
    last(Xs, R).

test(newton_multiple, [true(N == 5)]) :-
    newton_multiple((x - 1) ^ 2 * (x + 2) = 0, x, 2, 2, 1.0e-12, Xs),
    length(Xs, N),
    last(Xs, R),
    abs(R - 1) =< 1.0e-12.

test(jacobi, [true(N == 33)]) :-
    jacobi([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18], [0, 0, 0],
           1.0e-12, As),
    length(As, N),
    last(As, Xs),
    cerca(Xs, [1, 2, 3], 1.0e-9).

test(jacobi_primer_barrido, [true(X1 == [0.75, 3.4, 3.0])]) :-
    jacobi([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18], [0, 0, 0],
           1.0e-12, [X1|_]).

test(dominante) :-
    diagonal_dominante([[4, 1, -1], [1, 5, 2], [2, -1, 6]]).

test(no_dominante, [fail]) :-
    diagonal_dominante([[1, 5, 2], [4, 1, -1], [2, -1, 6]]).

test(ordenar,
     [true(Fs-Bs == [[4, 1, -1], [1, 5, 2], [2, -1, 6]]-[3, 17, 18])]) :-
    ordenar_filas([[1, 5, 2], [4, 1, -1], [2, -1, 6]], [17, 3, 18], Fs, Bs).

test(ordenar_imposible, [fail]) :-
    ordenar_filas([[1, 1], [1, 1]], [2, 2], _, _).

test(residuo_exacto, [true(R =:= 0)]) :-
    residuo([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18], [1, 2, 3], R).

test(residuo_lento, [true(Error > 5 * R)]) :-
    gauss_seidel([[1, 0.95], [0.95, 1]], [1.95, 1.95], [0, 0], 1.0e-3, As),
    last(As, Xs),
    residuo([[1, 0.95], [0.95, 1]], [1.95, 1.95], Xs, R),
    foldl([X, M0, M]>>(M is max(M0, abs(X - 1))), Xs, 0.0, Error).

test(newton_sistema, [true(cerca([X, Y], [1.9318516525781364,
                                           0.5176380902050416], 1.0e-9))]) :-
    newton_sistema([x ^ 2 + y ^ 2 = 4, x * y = 1], x-y, 2-0.5, X-Y).

test(newton_sistema_singular, [fail]) :-
    newton_sistema([x + y = 1, 2 * x + 2 * y = 3], x-y, 0-0, _).

test(raices, [true(cerca(Rs, [pi, 2 * pi, 3 * pi], 1.0e-9))]) :-
    raices(sin(x) = 0, x, 1-10, 9, Rs).

test(raices_perdidas, [true(length(Rs, 1))]) :-
    raices(sin(x) = 0, x, 1-10, 2, Rs).

test(raices_sin_tramos, [error(type_error(positive_integer, 0))]) :-
    raices(sin(x) = 0, x, 1-10, 0, _).

:- end_tests(soluciones).
