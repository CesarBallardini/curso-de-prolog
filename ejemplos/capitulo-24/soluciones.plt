:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1
test(dominio_con_agujero, true(D == 1\/3)) :-
    X in 1..3,
    X #\= 2,
    fd_dom(X, D).

% Ejercicio 2
test(celsius, true(C == 100)) :-
    celsius_fahrenheit(C, 212).

test(fahrenheit, true(F == 212)) :-
    celsius_fahrenheit(100, F).

% 213 °F no corresponde a un número entero de grados Celsius.
test(sin_entero, [fail]) :-
    celsius_fahrenheit(_, 213).

% Ejercicio 3
test(cambio, true(M == [2, 1, 3])) :-
    cambio(37, M).

% Ejercicio 4
test(cuadrados_magicos, true(N == 8)) :-
    aggregate_all(count, cuadrado_magico(_), N).

% Ejercicio 5
test(sudoku, true(S == [[1, 3, 2, 4], [4, 2, 3, 1], [2, 4, 1, 3],
                        [3, 1, 4, 2]])) :-
    S = [[1, _, _, _], [_, _, 3, _], [_, 4, _, _], [_, _, _, 2]],
    sudoku(S).

% Ejercicio 6: 6! / (2! 2! 2!) = 90.
test(dos_de_cada, true(N == 90)) :-
    aggregate_all(count, dos_de_cada(_), N).

% Ejercicio 7: 3 posiciones para el dado distinto, con 5 valores cada una.
test(dos_seis, true(N == 15)) :-
    dados_con_dos_seis(N).

test(exactamente_inverso, true(Xs == [1, 1, 2])) :-
    Xs = [_, _, 2],
    Xs ins 1..2,
    exactamente(2, Xs, 1),
    label(Xs).

% Ejercicio 8
test(to_go_out, all(L == [[2, 1, 8, 0]])) :-
    to_go_out(L).

test(sin_ceros, true(C-S == 1-25)) :-
    soluciones_sin_ceros(C, S).

% Ejercicio 9: generar y probar da los mismos 480 coloreos.
test(colorear_gyp, true(N == 480)) :-
    aggregate_all(count, colorear_gyp(4, _), N).

test(gyp_tres_colores, [fail]) :-
    colorear_gyp(3, _).

% Ejercicio 10
test(reinas_ff, true(N == 30)) :-
    once(reinas([ff], 30, Qs)),
    length(Qs, N).

% Ejercicio 11
test(todos_distintos, true(X == c)) :-
    todos_distintos([a, X, b]),
    X = c.

test(todos_distintos_falla, [fail]) :-
    todos_distintos([a, X, b]),
    X = a.

% all_different/1 solo admite enteros; dif/2, cualquier término.
test(all_different_con_atomos, [error(type_error(integer, a), _)]) :-
    all_different([a, b]).

:- end_tests(soluciones).
