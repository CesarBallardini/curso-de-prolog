:- encoding(utf8).

:- begin_tests(contar).

test(between_da_todo_el_rango, all(N == [1, 2, 3, 4, 5])) :-
    between(1, 5, N).

test(cuenta_escribe_una_linea_por_numero) :-
    with_output_to(string(S), cuenta(1, 3)),
    assertion(S == "1\n2\n3\n").

test(cuenta_de_un_rango_vacio) :-
    with_output_to(string(S), cuenta(5, 1)),
    assertion(S == "").

test(suma_hasta_cinco, all(S == [15])) :-
    suma_hasta(5, S).

test(suma_hasta_cero, all(S == [0])) :-
    suma_hasta(0, S).

:- end_tests(contar).
