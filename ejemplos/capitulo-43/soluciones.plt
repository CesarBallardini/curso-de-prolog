:- encoding(utf8).

:- begin_tests(soluciones).

test(lineal, all(S == [[x = 2, y = 1]])) :-
    sistema(x + y = 3, x - y = 1, x, y, S).

test(cociente, all(S == [[x = 3.0, y = 1.0]])) :-
    sistema(2 * x + y = 7, x - y = 2, x, y, S).

test(cuadratico, all(S == [[x = 3.0, y = 2.0], [x = 2.0, y = 3.0]])) :-
    sistema(x + y = 5, x * y = 6, x, y, S).

% Con las ecuaciones en el otro orden, la segunda queda 6 / y + y = 5,
% que ningún método de ecuaciones.pl resuelve.
test(otro_orden, [fail]) :-
    sistema(x * y = 6, x + y = 5, x, y, _).

:- end_tests(soluciones).
