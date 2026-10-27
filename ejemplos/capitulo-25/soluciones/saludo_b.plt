:- encoding(utf8).

:- begin_tests(saludo_b).

test(saludo, true(S == chau)) :-
    saludo(S).

:- end_tests(saludo_b).
