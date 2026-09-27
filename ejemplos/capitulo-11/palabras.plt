:- encoding(utf8).

:- begin_tests(palabras).

test(prolog_empieza_con_pro, [nondet]) :-
    empieza_con(prolog, pro).

test(los_comienzos_de_ana, all(P == ['', a, an, ana])) :-
    empieza_con(ana, P).

test(prolog_termina_con_log, [nondet]) :-
    termina_con(prolog, log).

test(las_a_de_banana, all(N == [3])) :-
    contar_letra(a, banana, N).

test(ninguna_z, all(N == [0])) :-
    contar_letra(z, banana, N).

test(tres_palabras_con_espacios_de_mas, all(N == [3])) :-
    contar_palabras("el  perro   ladra", N).

test(un_texto_vacio_no_tiene_palabras, all(N == [0])) :-
    contar_palabras("", N).

test(nombre_y_apellido, all(C == ['ana paz'])) :-
    nombre_completo(ana, paz, C).

test(el_mismo_nombre_escrito_distinto) :-
    mismo_nombre('  Ana   Paz ', 'ana paz').

test(nombres_distintos, [fail]) :-
    mismo_nombre('Ana Paz', 'Ana Luz').

:- end_tests(palabras).
