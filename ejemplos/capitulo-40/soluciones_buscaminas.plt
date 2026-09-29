:- encoding(utf8).

:- begin_tests(soluciones_buscaminas).

test(dos_minas, [true(S-M == [3-4, 4-3, 4-4]-[1-1, 3-3])]) :-
    tablero(chico, T),
    deducir(T, 2, S, M).

test(tres_minas, [true(S-M == [3-4, 4-3]-[1-1, 3-3, 4-4])]) :-
    tablero(chico, T),
    deducir(T, 3, S, M).

test(imposible, [fail]) :-
    tablero(chico, T),
    deducir(T, 5, _, _).

% Sin saber el total, (4, 4) no se deduce, como con deducir/3.
test(como_deducir_3, [true(S-M == [3-4, 4-3]-[1-1, 3-3])]) :-
    tablero(chico, T),
    deducir(T, S, M).

test(ganadas, [true(N == 5)]) :-
    partidas_ganadas(6, 5, 20, N).

test(minas_al_azar, [true(N == 5)]) :-
    minas_al_azar(6, 5, 1, Minas),
    sort(Minas, S),
    length(S, N).

:- end_tests(soluciones_buscaminas).
