:- encoding(utf8).

:- begin_tests(biseccion).

test(raiz_de_dos, [true(abs(R - sqrt(2)) =< 1.0e-12)]) :-
    biseccion(x ^ 2 = 2, x, 1-2, R).

% El intervalo [1, 2] se parte 40 veces hasta un ancho de 1.0e-12.
test(cuarenta_pasos, [true(N == 40)]) :-
    biseccion(x ^ 2 = 2, x, 1-2, 1.0e-12, Xs),
    length(Xs, N).

test(primeros_puntos_medios,
     [true(Xs == [1.5, 1.25, 1.375, 1.4375, 1.40625])]) :-
    biseccion(x ^ 2 = 2, x, 1-2, 0.05, Xs).

test(raiz_negativa, [true(abs(R + sqrt(2)) =< 1.0e-12)]) :-
    biseccion(x ^ 2 - 2, x, -2-0, R).

test(raiz_con_resultado_ligado) :-
    biseccion(x ^ 2 = 2, x, 1-2, 1.4142135623724243).

test(sin_cambio_de_signo,
     [error(domain_error(intervalo_con_cambio_de_signo, 2-3))]) :-
    biseccion(x ^ 2 = 2, x, 2-3, _).

test(intervalo_invertido,
     [error(domain_error(intervalo_con_cambio_de_signo, 2-1))]) :-
    biseccion(x ^ 2 = 2, x, 2-1, _).

% Una tolerancia menor que la separación entre flotantes no se alcanza.
test(tolerancia_inalcanzable, [fail]) :-
    biseccion(x ^ 2 = 2, x, 1-2, 1.0e-20, _).

test(ecuacion_libre, [error(instantiation_error)]) :-
    biseccion(_, x, 1-2, _).

:- end_tests(biseccion).
