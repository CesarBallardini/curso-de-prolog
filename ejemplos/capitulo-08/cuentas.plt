:- encoding(utf8).

:- begin_tests(cuentas).

test(meses_de_eva, all(M == [96])) :-
    edad_en_meses(eva, M).

test(los_mayores_de_edad, all(P == [juan, ana, pedro])) :-
    mayor_de_edad(P).

test(luis_no_es_mayor_de_edad, [fail]) :-
    mayor_de_edad(luis).

test(diferencia, all(D == [27])) :-
    diferencia_de_edad(juan, ana, D).

% La división de dos enteros produce punto flotante si el cociente no es exacto.
test(promedio_con_decimales, all(P == [24.5])) :-
    promedio_de_edad(ana, eva, P).
test(ana_y_pedro_estan_en_la_misma_decada, [nondet]) :-
    misma_decada(ana, pedro).

test(juan_y_eva_no, [fail]) :-
    misma_decada(juan, eva).

% is/2 requiere que la expresión de la derecha esté instanciada.
test(is_necesita_todos_los_numeros, [throws(error(instantiation_error, _))]) :-
    _ is _ + 1.

% doble/2 no despeja la incógnita: con el primer argumento libre, da un error.
test(doble_no_despeja, [throws(error(instantiation_error, _))]) :-
    doble(_, 42).

% Si otro objetivo genera el número, la misma forma admite la consulta inversa.
test(con_un_generador_delante_si, all(P == [eva])) :-
    edad_en_meses(P, 96).

:- end_tests(cuentas).
