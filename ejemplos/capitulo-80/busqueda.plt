:- encoding(utf8).

:- begin_tests(busqueda).

test(mate_en_1, [true(J == torre(4-2, 4-1))]) :-
    mate_forzado(pos(blancas, 2-3, 4-2, 2-1), 1, J).

% El mate más rápido de esta posición tarda dos jugadas.
test(sin_mate_en_1, [fail]) :-
    mate_forzado(pos(blancas, 1-3, 1-4, 2-1), 1, _).

test(mate_en_2, [true(N-J == 2-torre(1-4, 3-4))]) :-
    menor_mate(pos(blancas, 1-3, 1-4, 2-1), 3, N, J).

test(mate_en_3, [true(N-J == 3-rey(1-3, 2-3))]) :-
    menor_mate(pos(blancas, 1-3, 4-2, 2-1), 3, N, J).

% Con el límite por debajo del mate, la búsqueda falla.
test(limite_corto, [fail]) :-
    menor_mate(pos(blancas, 1-3, 4-2, 2-1), 2, _, _).

:- end_tests(busqueda).
