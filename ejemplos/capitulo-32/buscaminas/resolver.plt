:- encoding(utf8).

:- begin_tests(resolver).

test(una_segura, true(S-M == [3-2]-[])) :-
    deducir(["#1..", "#211", "####", "####"], S, M).

test(una_mina, true(S-M == []-[1-1])) :-
    deducir(["#1", "11"], S, M).

% Una celda marcada se trata como oculta.
test(marcada, true(M == [1-1])) :-
    deducir(["M1", "11"], _, M).

% Un tablero cuyos números no se pueden cumplir: nada se deduce.
test(inconsistente, true(S-M == []-[])) :-
    deducir(["##1#", "1211", "...."], S, M).

:- end_tests(resolver).
