:- encoding(utf8).

:- begin_tests(renombrar).

test(concatenar, true(L == [a, b])) :-
    concatenar([a], [b], L).

:- end_tests(renombrar).
