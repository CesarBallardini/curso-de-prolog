:- encoding(utf8).

:- begin_tests(tablero).

test(valores, true(V1-V2-V3 == mina-1-0)) :-
    tablero(3, 3, [1-1], T),
    valor(T, 1-1, V1),
    valor(T, 2-2, V2),
    valor(T, 3-3, V3).

test(fuera, fail) :-
    tablero(3, 3, [1-1], T),
    valor(T, 4-1, _).

% Con la semilla 42, las minas de un 5 x 5 con 4 son las del capítulo 28.
test(semilla, true(Minas == [2-3, 3-2, 3-4, 5-1])) :-
    tablero_al_azar(5, 5, 4, 42, T),
    T = tablero(_, _, Celdas),
    assoc_to_list(Celdas, Pares),
    findall(C, member(C-mina, Pares), Minas).

test(cantidad, true(N == 10)) :-
    tablero_al_azar(9, 9, 10, 7, T),
    cantidad_de_minas(T, N).

test(demasiadas_minas, error(domain_error(cantidad_de_minas, 4))) :-
    tablero_al_azar(2, 2, 4, 1, _).

test(dimension_invalida, error(type_error(positive_integer, 0))) :-
    tablero_al_azar(0, 2, 1, 1, _).

:- end_tests(tablero).
