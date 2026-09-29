:- encoding(utf8).

:- begin_tests(gauss_seidel).

% cerca(Xs, Ys): las dos listas difieren en menos de 1.0e-9 por componente.
cerca(Xs, Ys) :-
    maplist([X, Y]>>(abs(X - Y) < 1.0e-9), Xs, Ys).

test(sistema, [true(cerca(Xs, [1, 2, 3]))]) :-
    gauss_seidel([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18], Xs).

test(primer_barrido, [true(X1 == [0.75, 3.25, 3.2916666666666665])]) :-
    gauss_seidel([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18],
                 [0, 0, 0], 1.0e-12, [X1|_]).

test(barridos, [true(N == 19)]) :-
    gauss_seidel([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18],
                 [0, 0, 0], 1.0e-12, Aproximaciones),
    length(Aproximaciones, N).

% El sistema de Csenki, con la diagonal unitaria.
test(csenki, [true(cerca(Xs, [87.5, 87.5, 62.5, 62.5]))]) :-
    gauss_seidel([[1, -0.25, -0.25, 0], [-0.25, 1, 0, -0.25],
                  [-0.25, 0, 1, -0.25], [0, -0.25, -0.25, 1]],
                 [50, 50, 25, 25], Xs).

% Las mismas ecuaciones en otro orden: la diagonal ya no domina.
test(no_converge, [fail]) :-
    gauss_seidel([[1, 5, 2], [4, 1, -1], [2, -1, 6]], [17, 3, 18], _).

test(diagonal_nula, [fail]) :-
    gauss_seidel([[0, 1], [1, 1]], [1, 2], _).

test(producto_escalar, [true(P =:= 32)]) :-
    producto_escalar([1, 2, 3], [4, 5, 6], P).

:- end_tests(gauss_seidel).
