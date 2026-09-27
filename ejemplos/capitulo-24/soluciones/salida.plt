:- encoding(utf8).

:- use_module('../inscripciones/informes', except([mostrar_informe/2])).

:- begin_tests(salida).

test(mostrar, true(S == "aprobadas\n  101 ana: 4\n")) :-
    with_output_to(string(S), mostrar_informe(aprobadas, [101-4])).

test(con_informe, true(S == "aprobadas\n  101 ana: 4\n  105 elena: 0\n")) :-
    informe(aprobadas, [101, 105], F),
    with_output_to(string(S), mostrar_informe(aprobadas, F)).

:- end_tests(salida).
