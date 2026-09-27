:- encoding(utf8).

:- begin_tests(renombrar).

test(pegar, true(L == [a, b])) :-
    pegar([a], [b], L).

:- end_tests(renombrar).
