:- encoding(utf8).

:- begin_tests(utiles).

test(predefinido, true(N == 2)) :-
    contar_cumplen(integer, [1, a, 2], N).

:- end_tests(utiles).
