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

% Ejercicio 5
test(cuatro_es_par, true(P == par)) :-
    paridad(4, P).

test(tres_es_impar, true(P == impar)) :-
    paridad(3, P).

% Ejercicio 6
test(primera_aprobada_de_ana, true(M == am1)) :-
    primera_aprobada(101, M).

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

:- end_tests(soluciones).
