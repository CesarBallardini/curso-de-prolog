:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 5
test(dia_de_oliva, all(D == [3])) :-
    dia_de(ficha(mascota(gato, felix), fecha(2021, 5, 3), ana), D).

% Ejercicio 6
test(los_gatos, all(N == [felix, gaturro])) :-
    registro(F),
    es_gato(F),
    nombre_de(F, N).

test(rocco_no_es_gato, [fail]) :-
    es_gato(ficha(mascota(perro, rocco), fecha(2019, 11, 20), luis)).

% Ejercicio 8
test(lados_de_un_producto, all(A-B == [2-3])) :-
    producto(2 * 3, A, B).

test(operacion_vale_para_las_dos, all(A-B == [2-3])) :-
    operacion(2 + 3, A, B).

test(operacion_con_producto, all(A-B == [4-5])) :-
    operacion(4 * 5, A, B).

test(una_resta_no_es_operacion, [fail]) :-
    operacion(2 - 3, _, _).

% Ejercicio 9: los dos gatos, en los dos órdenes; rocco queda excluido.
test(misma_especie, all(N1-N2 == [felix-gaturro, gaturro-felix])) :-
    misma_especie(F1, F2),
    nombre_de(F1, N1),
    nombre_de(F2, N2).

test(ninguna_ficha_consigo_misma, [fail]) :-
    registro(F),
    misma_especie(F, F).

% Ejercicio 13
test(propietario_y_especie, all(P-E == [ana-gato])) :-
    propietario_y_especie(ficha(mascota(gato, felix), fecha(2021, 5, 3), ana), P, E).

% Ejercicio 14
test(ficha_de_ana, all(F == [ficha(mascota(gato, felix), fecha(2021, 5, 3), ana)])) :-
    ficha_de(ana, F).

% Ejercicio 17
test(no_hay_dos_fichas_del_mismo_propietario, [fail]) :-
    mismo_propietario(_, _).

:- end_tests(soluciones).
