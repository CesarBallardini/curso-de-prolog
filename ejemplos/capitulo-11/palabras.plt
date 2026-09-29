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

test(sin_el_prefijo_error, all(R == ["falta el archivo"])) :-
    sin_prefijo("ERROR: ", "ERROR: falta el archivo", R).

test(otro_prefijo, [fail]) :-
    sin_prefijo("ERROR: ", "Aviso: falta el archivo", _).

test(tres_maneras_de_partir_ab, all(P-R == [""-"ab", "a"-"b", "ab"-""])) :-
    sin_prefijo(P, "ab", R).

test(na_aparece_dos_veces_en_banana, all(P == [2, 4])) :-
    aparece_en("banana", "na", P).

test(x_no_aparece_en_banana, [fail]) :-
    aparece_en("banana", "x", _).

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
