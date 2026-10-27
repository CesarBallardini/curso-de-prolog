:- encoding(utf8).

:- begin_tests(newton).

test(raiz_de_dos, [true(abs(R - sqrt(2)) =< 1.0e-12)]) :-
    newton(x ^ 2 = 2, x, 1, R).

test(seis_pasos, [true(N == 6)]) :-
    newton(x ^ 2 = 2, x, 1, 1.0e-12, Xs),
    length(Xs, N).

test(cubica, [true(abs(R + 1.7692923542386314) =< 1.0e-12)]) :-
    newton(x ^ 3 - 2 * x + 2 = 0, x, -2, R).

% Desde 0, las aproximaciones repiten 1, 0, 1, 0...
test(ciclo, [fail]) :-
    newton(x ^ 3 - 2 * x + 2 = 0, x, 0, _).

test(derivada_nula, [fail]) :-
    newton(x ^ 2 - 2, x, 0, _).

test(sin_raiz_real, [fail]) :-
    newton(x ^ 2 + 1 = 0, x, 1, _).

% Con una raíz doble, el error solo se reduce a la mitad por paso.
test(raiz_doble, [true(N == 40)]) :-
    newton(x ^ 2 = 0, x, 1, 1.0e-12, Xs),
    length(Xs, N).

test(no_derivable, [error(domain_error(expresion_derivable, cos(x)))]) :-
    newton(x = cos(x), x, 1, _).

% Con tolerancia 0, las dos últimas aproximaciones alternan entre dos
% flotantes vecinos.
test(tolerancia_cero, [fail]) :-
    newton(x ^ 2 = 2, x, 1, 0.0, _).

test(paso, [true(X1-E-C == 1.5-1.5-0.5)]) :-
    paso_newton(x ^ 2 - 2, 2 * x, x, 1.0, X1, E, C).

test(paso_derivada_nula, [fail]) :-
    paso_newton(x ^ 2 - 2, 2 * x, x, 0.0, _, _, _).

test(newton_primeros, [true(Xs == [1.5, 1.4166666666666667])]) :-
    newton(x ^ 2 = 2, x, 1, 0.1, Xs).

:- end_tests(newton).
