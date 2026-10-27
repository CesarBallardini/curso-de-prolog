:- encoding(utf8).

:- begin_tests(secante).

test(raiz_de_dos, [true(abs(R - sqrt(2)) =< 1.0e-12)]) :-
    secante(x ^ 2 = 2, x, 1-2, R).

test(siete_pasos, [true(N == 7)]) :-
    secante(x ^ 2 = 2, x, 1-2, 1.0e-12, Xs),
    length(Xs, N).

test(coseno, [true(abs(R - cos(R)) =< 1.0e-12)]) :-
    secante(x = cos(x), x, 1-2, R).

% Los tres fallos que describe Covington: la secante horizontal, la
% ecuación sin solución y la que no converge.
test(secante_horizontal, [fail]) :-
    secante(x * x = x * 3, x, 1-2, _).

test(sin_solucion, [fail]) :-
    secante(x = x + 1, x, 1-2, _).

test(no_converge, [fail]) :-
    secante(sin(x) = 0.001, x, 1-2, _).

% Y la raíz lejana: sin(x) = 0.01 tiene una raíz cerca de 0.01, pero el
% método llega a otra, cerca de 213.6.
test(raiz_lejana, [true(abs(R - 213.6383006107801) =< 1.0e-9)]) :-
    secante(sin(x) = 0.01, x, 1-2, R).

test(otro_atomo, [error(existence_error(incognita, y))]) :-
    secante(x = y, x, 1-2, _).

% Secante por (1, -1) y (2, 2): corta el eje en 4/3.
test(paso, [true(X2-C == 1.3333333333333335-0.6666666666666665)]) :-
    paso_secante(x ^ 2 - 2, x, secante(1.0, -1.0, 2.0, 2.0),
                 secante(2.0, 2.0, X2, _), X2, C).

test(paso_horizontal, [fail]) :-
    paso_secante(x * x - x * 3, x, secante(1.0, -2.0, 2.0, -2.0), _, _, _).

test(secante_primeros,
     [true(Xs == [1.3333333333333335, 1.4000000000000001])]) :-
    secante(x ^ 2 = 2, x, 1-2, 0.1, Xs).

:- end_tests(secante).
