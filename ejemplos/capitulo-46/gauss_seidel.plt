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

% El primer barrido del sistema de la sección 46.7 desde (0, 0, 0).
test(barrido, [true(Xs == [0.75, 3.25, 3.2916666666666665])]) :-
    barrido([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18], [], [0, 0, 0],
            Xs).

test(barrido_vacio, [true(Xs == [])]) :-
    barrido([], [], [], [], Xs).

test(barrido_diagonal_nula, [fail]) :-
    barrido([[0, 1], [1, 1]], [1, 2], [], [0, 0], _).

test(paso, [true(Xs-C == [0.75, 3.25, 3.2916666666666665]
                         -3.2916666666666665)]) :-
    paso_gauss_seidel([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18],
                      [0, 0, 0], Xs, Xs, C).

test(gauss_seidel_tolerancia_ancha, [true(length(As, 1))]) :-
    gauss_seidel([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18],
                 [1, 2, 3], 1.0e-9, As).

test(producto_escalar_vacio, [true(P =:= 0)]) :-
    producto_escalar([], [], P).

test(sumar_producto, [true(S =:= 7)]) :-
    sumar_producto(2, 3, 1, S).

test(mayor_diferencia, [true(M =:= 3)]) :-
    mayor_diferencia(1, 4, 2.0, M).

test(mayor_diferencia_conserva, [true(M =:= 5)]) :-
    mayor_diferencia(1, 2, 5, M).

:- end_tests(gauss_seidel).
