:- encoding(utf8).

:- begin_tests(resolver).

test(deducir, true(S-M == [3-4, 4-3]-[1-1, 3-3])) :-
    deducir(["#100", "1211", "01##", "01##"], S, M).

% El tablero construido con las minas deducidas tiene los números visibles.
test(coherente, true(V == 2)) :-
    deducir(["#100", "1211", "01##", "01##"], 2, _, M),
    tablero:tablero(4, 4, M, T),
    tablero:valor(T, 2-2, V).

:- end_tests(resolver).
