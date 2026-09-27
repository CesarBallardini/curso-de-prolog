:- encoding(utf8).

:- begin_tests(menu).

test(dos_ordenes_y_salir,
     true(S == "ana tiene 41 años\nsofia no está en la base\nFin\n")) :-
    open_string("edad(ana). edad(sofia). salir.", In),
    with_output_to(string(S), menu(In)).

test(una_orden_desconocida,
     true(S == "Orden desconocida: hola\nFin\n")) :-
    open_string("hola. salir.", In),
    with_output_to(string(S), menu(In)).

% Sin la orden salir, el menú termina al llegar al final del texto.
test(fin_del_texto, true(S == "luis tiene 12 años\n")) :-
    open_string("edad(luis).", In),
    with_output_to(string(S), menu(In)).

:- end_tests(menu).
