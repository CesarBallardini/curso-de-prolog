:- encoding(utf8).

:- begin_tests(vista).

test(aristas, [true(A == [(1-1)-(1-2), (1-1)-(2-1), (1-2)-(2-2),
                          (2-1)-(2-2)])]) :-
    aristas([1-1, 1-2, 2-2, 2-1], A).

test(aristas_vacio, [true(A == [])]) :-
    aristas([], A).

test(pares, [true(P == [(1-1)-(1-2), (1-1)-(1-2)])]) :-
    pares([1-1, 1-2, 1-1], P).

test(pares_con_anterior, [true(P == [(1-1)-(2-1)])]) :-
    pares([1-1], 2-1, P).

test(tablero_sin_lazo, [true(L == ["· · · O · #", "", "# # · · · ·"])]) :-
    lineas(csenki1, [], [A, B, C|_]),
    L = [A, B, C].

test(lineas_del_lazo, [true(Ls == ["┌─────O ┌─#", "│     │ │ │"])]) :-
    distintos(csenki1, [F]),
    lineas(csenki1, F, [A, B|_]),
    Ls = [A, B].

test(once_lineas, [true(N == 11)]) :-
    lineas(csenki1, [], Ls),
    length(Ls, N).

test(lineas_de_fila, [true(L == ["# · · · · # · #", ""])]) :-
    lineas_de_fila(csenki2, 9, 8, [], 1, L, []).

test(casilla_y_trazo, [true(P == ['─', '─'])]) :-
    casilla_y_trazo(chico, 3, [(1-1)-(1-2), (1-2)-(1-3)], 1, 2, P, []).

test(vertical, [true(V-W == '│'-' ')]) :-
    vertical([(1-1)-(2-1)], 1, 2, 1, V),
    vertical([(1-1)-(2-1)], 1, 2, 2, W).

test(sin_espacios_finales, [true(S == "a b")]) :-
    sin_espacios_finales('a b  ', S).

test(quitar_espacios, [true(R == `ab `)]) :-
    quitar_espacios(`  ab `, R).

test(caracter_marca, [true(C == 'O')]) :-
    caracter(csenki1, [], 1-4, C).

test(caracter_esquina, [true(C == '┘')]) :-
    caracter(csenki1, [(1-1)-(2-1), (2-1)-(2-2)], 2-1, C0),
    caracter(chico, [(1-2)-(2-2), (2-1)-(2-2)], 2-2, C),
    C0 == '#'.

test(simbolo, [true(S == '#')]) :-
    simbolo(numeral, S).

test(direcciones, [true(Ds == [arriba, derecha])]) :-
    findall(D, direccion([(1-1)-(2-1), (2-1)-(2-2)], 2-1, D), Ds).

test(peso, [true(P == 8)]) :-
    peso(derecha, P).

test(trazo, [true(T == '│')]) :-
    trazo(3, T).

test(mostrar, [true(S == "O───O\n│   │\n│ · │\n│   │\n└─#─┘\n")]) :-
    distintos(chico, [L]),
    with_output_to(string(S), mostrar(chico, L)).

test(cubre) :-
    distintos(csenki1, [F]),
    cubre(csenki1, F).

test(no_cubre, [fail]) :-
    cubre(csenki1, [1-1, 1-2, 2-2, 2-1]).

test(cobertura, [true(D-C == 1-1)]) :-
    cobertura(csenki1, D, C).

test(cobertura_cruz, [true(D-C == 5-0)]) :-
    cobertura(cruz, D, C).

test(dibujar, [true(N == 29)]) :-
    with_output_to(string(S), dibujar(cruz)),
    split_string(S, "\n", "", Ls),
    length(Ls, N0),
    N is N0 - 1.

test(cobertura_csenki2, [true(D-C == 10-1)]) :-
    cobertura(csenki2, D, C).

:- end_tests(vista).
