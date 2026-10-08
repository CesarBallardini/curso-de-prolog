:- encoding(utf8).

% Pruebas de las reglas del Buscaminas, del lado de Prolog. Un tablero de
% 3 × 3 con una mina en la esquina 1-1.

:- begin_tests(buscaminas).

test(partida_nueva, true(F == ["###", "###", "###"])) :-
    nueva_partida_py(3, 3, [1-1], prolog(J)),
    filas_py(J, @(false), F).

test(ganar, true(E-F == gano-["*1.", "11.", "..."])) :-
    nueva_partida_py(3, 3, [1-1], prolog(J0)),
    jugar_py(J0, descubrir, 3, 3, prolog(J), E),
    filas_py(J, @(true), F).

test(perder, true(E == perdio)) :-
    nueva_partida_py(3, 3, [1-1], prolog(J0)),
    jugar_py(J0, descubrir, 1, 1, _, E).

test(marcar, true(F == ["###", "#M#", "###"])) :-
    nueva_partida_py(3, 3, [1-1], prolog(J0)),
    jugar_py(J0, marcar, 2, 2, prolog(J), sigue),
    filas_py(J, @(false), F).

test(fuera, true(E-J == fuera-J0)) :-
    nueva_partida_py(3, 3, [1-1], prolog(J0)),
    jugar_py(J0, descubrir, 4, 1, prolog(J), E).

% Con la semilla 42, las minas de un 5 × 5 con 4 son las del capítulo 28.
test(semilla, true(F == ["#####", "##*##", "#*#*#", "#####", "*####"])) :-
    partida_al_azar_py(5, 5, 4, 42, prolog(J0)),
    jugar_py(J0, descubrir, 2, 3, prolog(J), perdio),
    filas_py(J, @(true), F).

:- end_tests(buscaminas).
