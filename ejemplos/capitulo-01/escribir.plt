:- encoding(utf8).

:- begin_tests(escribir).

test(saludar) :-
    with_output_to(string(S), saludar(ana)),
    assertion(S == "Hola, ana\n").

test(presentar) :-
    with_output_to(string(S), presentar(luis, 3)),
    assertion(S == "luis tiene 3 hermanos\n").

:- end_tests(escribir).
