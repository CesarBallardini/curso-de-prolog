:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 2
test(no_de_algo_falso) :-
    no(fail).

test(no_de_algo_cierto, [fail]) :-
    no(true).

test(una_vez_la_primera, all(X == [a])) :-
    una_vez(member(X, [a, b])).

test(ignorar_algo_falso) :-
    ignorar(fail).

% Ejercicio 3: las versiones con condicional son estables.
test(maximo, true(M == 3)) :-
    maximo(3, 1, M).

test(maximo_ligado_falso, [fail]) :-
    maximo(3, 1, 1).

test(descuento_de_un_chico, true(D == 50)) :-
    descuento(8, D).

test(descuento_ligado_falso, [fail]) :-
    descuento(8, 0).

% Ejercicio 4
test(valor_absoluto_negativo, true(A == 5)) :-
    valor_absoluto(-5, A).

test(valor_absoluto_positivo, true(A == 5)) :-
    valor_absoluto(5, A).

test(valor_absoluto_ligado_verdadero) :-
    valor_absoluto(-5, 5).

test(valor_absoluto_ligado_falso, [fail]) :-
    valor_absoluto(-5, 4).

% Ejercicio 5
test(cuatro_es_par, true(P == par)) :-
    paridad(4, P).

test(tres_es_impar, true(P == impar)) :-
    paridad(3, P).

test(tres_no_es_par, [fail]) :-
    paridad(3, par).

% Ejercicio 6
test(primera_aprobada_de_ana, true(M == am1)) :-
    primera_aprobada(101, M).

% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
% Ejercicio 7
test(aprobadas_de_diego, true(S == "log: 9\nalg: 7\npp: 8\n")) :-
    with_output_to(string(S), listar_aprobadas(104)).

% Ejercicios 8 y 14
test(menu_todas, true(S == "juan: 68\nana: 41\nluis: 12\nFin\n")) :-
    open_string("todas. salir.", In),
    with_output_to(string(S), menu(In)).

test(menu_orden_incompleta,
     true(S == "Orden incompleta: falta el nombre\nFin\n")) :-
    open_string("edad(X). salir.", In),
    with_output_to(string(S), menu(In)).

% Ejercicio 9
test(contar_hasta_tres, true(S == "1\n2\n3\n")) :-
    with_output_to(string(S), contar_hasta(3)).

test(contar_hasta_tres_con_recursion, true(S == "1\n2\n3\n")) :-
    with_output_to(string(S), contar_hasta_rec(3)).

test(suma_hasta_cuatro, true(S == 10)) :-
    suma_hasta(4, S).

% Ejercicio 11: bruno no aprobó ninguno de los dos requisitos de análisis 2.
test(faltan_los_dos_requisitos, true(F == [am1, alg])) :-
    requisitos_faltantes(102, am2, F).

test(no_falta_ninguno, true(F == [])) :-
    requisitos_faltantes(104, ssl, F).

% Ejercicio 12: elena ingresó en 2025; bases de datos es de tercer año.
test(elena_no_puede_cursar_bases_de_datos,
     true(R == rechazada(anio_no_permitido))) :-
    inscripcion_posible_por_anio(105, bd, R).

test(sin_cambios_para_los_demas, true(R == rechazada(falta(am1)))) :-
    inscripcion_posible_por_anio(102, am2, R).

% Ejercicio 16: las dos versiones dan las mismas respuestas, en el mismo orden.
test(tomada_por_ana, all(M-A == [pp-2, am1-1, alg-1, log-1, am2-2])) :-
    tomada_en_dos(101, M, A).

test(tomada_con_disyuncion,
     all(L-M-A == [101-pp-2, 103-am2-2, 105-am1-1,
                   101-am1-1, 101-alg-1, 101-log-1, 101-am2-2, 102-log-1,
                   103-am1-1, 104-log-1, 104-alg-1, 104-pp-2, 106-am1-1])) :-
    tomada(L, M, A).

test(tomada_con_dos_clausulas,
     all(L-M-A == [101-pp-2, 103-am2-2, 105-am1-1,
                   101-am1-1, 101-alg-1, 101-log-1, 101-am2-2, 102-log-1,
                   103-am1-1, 104-log-1, 104-alg-1, 104-pp-2, 106-am1-1])) :-
    tomada_en_dos(L, M, A).

% call_with_inference_limit/3, que acota las inferencias,
% se presenta en el capítulo 26.
% Ejercicio 17: eco/1 no termina por sí mismo; el límite de inferencias lo
% detiene. La versión corregida termina al final del stream, sin alternativas.
test(eco_no_termina, true(R == inference_limit_exceeded)) :-
    open_string("a. b.", In),
    with_output_to(string(_),
                   call_with_inference_limit(eco(In), 200, R)).

test(eco_hasta_el_final, true(S == "a\nb\n")) :-
    open_string("a. b.", In),
    with_output_to(string(S), eco_hasta_el_final(In)).

test(eco_vacio, true(S == "")) :-
    open_string("", In),
    with_output_to(string(S), eco_hasta_el_final(In)).

% Ejercicio 18: *-> recorre todas las propiedades; sin nondet, las pruebas
% verifican que cumple/1 y presentar/1 no dejan alternativas pendientes.
test(cumple_tres_propiedades, true(S == "par\npositivo\nmayor_que_10\n")) :-
    with_output_to(string(S), cumple(12)).

test(cumple_ninguna, true(S == "ninguna\n")) :-
    with_output_to(string(S), cumple(-3)).

test(presentar_con_edad, true(S == "ana (41 años)\n")) :-
    with_output_to(string(S), presentar(ana)).

test(presentar_sin_edad, true(S == "marta\n")) :-
    with_output_to(string(S), presentar(marta)).

:- end_tests(soluciones).
