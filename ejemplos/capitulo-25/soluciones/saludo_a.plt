:- encoding(utf8).

:- begin_tests(saludo_a).

test(saludo, true(S == hola)) :-
    saludo(S).

:- end_tests(saludo_a).
