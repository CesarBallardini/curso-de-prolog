:- encoding(utf8).

:- begin_tests(buscaminas).

test(valor, true(V == 2)) :-
    tablero(3, 4, [1-1, 2-3], T),
    valor(T, 2-2, V).

test(mina, true(V == mina)) :-
    tablero(3, 4, [1-1, 2-3], T),
    valor(T, 1-1, V).

test(fuera, [fail]) :-
    tablero(3, 4, [1-1, 2-3], T),
    valor(T, 4-1, _).

% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
test(mostrar, true(S == "*211\n12*1\n0111\n")) :-
    tablero(3, 4, [1-1, 2-3], T),
    with_output_to(string(S), mostrar(T)).

test(celda_numero, true(Cs == [1-1, 1-4, 2-1, 3-4])) :-
    maplist(celda_numero(4), [1, 4, 5, 12], Cs).

% Con la misma semilla, el mismo tablero: la prueba fija la semilla.
test(al_azar, [ setup(set_random(seed(42))),
                true(M == [2-3, 3-2, 3-4, 5-1]) ]) :-
    minas_al_azar(5, 5, 4, M).

test(cantidad_de_minas, true(N == 10)) :-
    minas_al_azar(9, 9, 10, M),
    length(M, N).

test(tablero_al_azar, true(N == 10)) :-
    tablero_al_azar(9, 9, 10, tablero(_, _, Celdas)),
    assoc_to_values(Celdas, Vs),
    aggregate_all(count, member(mina, Vs), N).

:- end_tests(buscaminas).
