:- encoding(utf8).

:- begin_tests(buscaminas).

test(deducir, true(S-M == [3-4, 4-3]-[1-1, 3-3])) :-
    deducir(["#100", "1211", "01##", "01##"], S, M).

% Con el total de minas, (4, 4) queda determinada.
test(con_total_2, true(S-M == [3-4, 4-3, 4-4]-[1-1, 3-3])) :-
    deducir(["#100", "1211", "01##", "01##"], 2, S, M).

test(con_total_3, true(S-M == [3-4, 4-3]-[1-1, 3-3, 4-4])) :-
    deducir(["#100", "1211", "01##", "01##"], 3, S, M).

test(una_mina, true(M == [1-1])) :-
    deducir(["#1", "11"], _, M).

% Un tablero cuyos números no se pueden cumplir.
test(inconsistente, [fail]) :-
    deducir(["##1#", "1211", "0000"], _, _).

test(sin_informacion, true(S-M == []-[])) :-
    deducir(["#2#", "###"], S, M).

:- end_tests(buscaminas).
