:- encoding(utf8).

:- begin_tests(minimax).

% El árbol de ejemplo: d vale 5, e 9, f 2 y g 8; b vale 5 y c 2.
test(arbol, [true(J-V-N == b-5-15)]) :-
    minimax(arbol, a, 3, J, V, N).

test(arbol_min, [true(J-V == f-2)]) :-
    minimax(arbol, c, 2, J, V, _).

% x tiene dos jugadas que amenazan dos líneas; minimax elige la primera.
test(gana_x, [true(J-V == 4-102)]) :-
    minimax(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), 9, J, V, _).

% o evita la amenaza doble de x con una amenaza propia.
test(defiende_o, [true(J-V-N == 3-0-250)]) :-
    minimax(tateti(3), pos([x, o, v, v, x, v, v, v, o], o), 9, J, V, N).

% Contra una esquina, la única respuesta que empata es el centro.
test(centro, [true(J-V == 5-0)]) :-
    minimax(tateti(3), pos([x, v, v, v, v, v, v, v, v], o), 8, J, V, _).

test(terminada, [true(J-V-N == ninguna-104-1)]) :-
    minimax(tateti(3), pos([x, x, x, o, o, v, v, v, v], o), 5, J, V, N).

test(profundidad_0, [true(J-V-N == ninguna-0-1)]) :-
    minimax(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), 0, J, V, N).

% Con la evaluación nula y profundidad 2, todas las jugadas valen 0.
test(horizonte, [true(J-V-N == 1-0-82)]) :-
    inicial(tateti(3), P),
    minimax(tateti(3), P, 2, J, V, N).

:- end_tests(minimax).
