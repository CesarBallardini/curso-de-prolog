:- encoding(utf8).

:- begin_tests(sin_choque).

test(saludos, true(L == [hola, chau])) :-
    saludos(L).

:- end_tests(sin_choque).
