:- encoding(utf8).

:- begin_tests(formato).

test(la_ficha_de_juan, [true(Salida == "juan tiene 68 años\n")]) :-
    with_output_to(string(Salida), ficha(juan)).

test(una_tabla, [true(Salida == "juan        68\nluis        12\n")]) :-
    with_output_to(string(Salida), tabla([juan, luis])).

test(una_tabla_con_alguien_sin_edad, [fail]) :-
    with_output_to(string(_), tabla([juan, sofia])).

test(la_etiqueta_de_ana, all(E == ['ana (41)'])) :-
    etiqueta(ana, E).

:- end_tests(formato).
