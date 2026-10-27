:- encoding(utf8).

:- begin_tests(soluciones).

test(triple_de_cinco, all(T == [15])) :-
    triple(5, T).

test(triple_no_despeja, [throws(error(instantiation_error, _))]) :-
    triple(_, 15).

test(ocho_es_par) :-
    es_par(8).

test(nueve_no_es_par, [fail]) :-
    es_par(9).

test(el_mayor_de_dos, all(M == [9])) :-
    mayor_de_los_dos(3, 9, M).

test(el_mayor_con_iguales, all(M == [5])) :-
    mayor_de_los_dos(5, 5, M).

test(cuantos_mayores_de_18, all(N == [2])) :-
    cuantos_mayores([12, 41, 8, 68], N).

test(ninguno_mayor, all(N == [0])) :-
    cuantos_mayores([1, 2], N).

test(promedio, all(P == [20])) :-
    promedio([10, 20, 30], P).

test(la_lista_vacia_no_tiene_promedio, [fail]) :-
    promedio([], _).

test(maximo, all(M == [9])) :-
    maximo([3, 9, 4], M).

test(maximo_al_final, all(M == [9])) :-
    maximo([3, 4, 9], M).

test(maximo_de_la_vacia_falla, [fail]) :-
    maximo([], _).

test(factorial_de_cinco, all(F == [120])) :-
    factorial(5, F).

test(factorial_de_cero, all(F == [1])) :-
    factorial(0, F).

test(cuenta_atras, all(L == [[3, 2, 1]])) :-
    cuenta_atras(3, L).

test(cuenta_atras_de_cero, all(L == [[]])) :-
    cuenta_atras(0, L).

% Las dos versiones del ejercicio 10 producen la misma lista.
test(cuenta_atras_con_acumulador, all(L == [[3, 2, 1]])) :-
    cuenta_atras_con(3, L).

test(cuenta_atras_con_acumulador_de_cero, all(L == [[]])) :-
    cuenta_atras_con(0, L).

test(cuenta_atras_con_acumulador_de_uno, all(L == [[1]])) :-
    cuenta_atras_con(1, L).

% Ejercicio 12
test(hasta_llega_al_tope, [nondet]) :-
    hasta(3, 1).

test(hasta_no_pasa_del_tope, [fail]) :-
    hasta(3, 5).

% Ejercicio 14
test(suma_hasta_sin_acumulador, all(S == [15])) :-
    suma_hasta_sin(5, S).

test(suma_hasta_con_acumulador, all(S == [15])) :-
    suma_hasta_con(5, S).

% Ejercicio 15: las pruebas de maximo/2
test(maximo_de_varios, all(M == [9])) :-
    maximo([3, 9, 4], M).

test(maximo_de_uno, all(M == [7])) :-
    maximo([7], M).

test(la_lista_vacia_no_tiene_maximo, [fail]) :-
    maximo([], _).

% Ejercicio 17
test(enesimo_da_el_elemento, all(E == [c])) :-
    enesimo([a, b, c, d], 3, E).

test(enesimo_genera_las_posiciones, all(N-E == [1-a, 2-b, 3-c, 4-d])) :-
    enesimo([a, b, c, d], N, E).

test(enesimo_con_repetidos, all(N == [1, 3, 4])) :-
    enesimo([a, b, a, a], N, a).

test(enesimo_fuera_de_la_lista, [fail]) :-
    enesimo([a, b, c, d], 5, _).

% Ejercicio 18
test(ordered_con_repetidos, [nondet]) :-
    ordered([1, 2, 2, 5]).

test(ordered_desordenada, [fail]) :-
    ordered([3, 1, 2]).

test(ordena, all(L == [[-1, 2, 4, 5, 10]])) :-
    ordena([10, 2, 5, -1, 4], L).

test(ordena_conserva_repetidos, all(L == [[0, 0, 0, 1, 2, 5]])) :-
    ordena([5, 0, 1, 0, 2, 0], L).

test(ordena_verifica, [fail]) :-
    ordena([3, 1, 2], [3, 2, 1]).

% Ejercicio 19
test(profundidad, all(P == [3])) :-
    arbol_ejemplo(T),
    profundidad(T, P).

test(profundidad_de_un_nodo, all(P == [0])) :-
    profundidad(tree(9, void, void), P).

test(sum_tree, all(S == [28])) :-
    arbol_ejemplo(T),
    sum_tree(T, S).

test(sum_tree_verifica, [fail]) :-
    sum_tree(tree(0, void, void), 1).

test(cantidad_hojas, all(N == [3])) :-
    arbol_ejemplo(T),
    cantidad_hojas(T, N).

test(cantidad_hojas_de_una_hoja, all(N == [1])) :-
    cantidad_hojas(tree(4, void, void), N).

test(lista_nivel, all(L == [[4, 5, 6]])) :-
    arbol_ejemplo(T),
    lista_nivel(T, 2, L).

test(lista_nivel_de_la_raiz, all(L == [[1]])) :-
    arbol_ejemplo(T),
    lista_nivel(T, 0, L).

test(lista_nivel_mas_alla_de_la_profundidad, all(L == [[]])) :-
    arbol_ejemplo(T),
    lista_nivel(T, 4, L).

% Ejercicio 20
test(ocurrencias, all(P == [[4, 5, 8]])) :-
    ocurrencias(a, [s, 1, 3, a, a, 2, d, a], P).

test(ocurrencias_verifica, [nondet]) :-
    ocurrencias(2, [2, 1, 3, a, a, 2, d, a], [1, 6]).

test(ocurrencias_ninguna, all(P == [[]])) :-
    ocurrencias(4, [s, 1, 3, a, a, 2, d, a], P).

test(ocurrencias_equivocadas, [fail]) :-
    ocurrencias(2, [2, 1, 3, a, a, 2, d, a], [1]).

% Ejercicio 21
test(intercala_verifica, [nondet]) :-
    intercala([a1, a2, a3, a4, a5, a6], [b1, b2, b3, b4], 3, 2,
              [a1, a2, a3, b1, b2, a4, a5, a6, b3, b4]).

test(intercala_comienza_con_la_segunda,
     all(R == [[b1, a1, a2, a3, a4, b2]])) :-
    intercala([a1, a2, a3, a4], [b1, b2], 4, 1, R).

test(intercala_dos_formas, all(R == [[a1, a2, b1, a3, a4, b2],
                                     [b1, a1, a2, b2, a3, a4]])) :-
    intercala([a1, a2, a3, a4], [b1, b2], 2, 1, R).

test(intercala_tramos_incompletos, [fail]) :-
    intercala([a1, a2, a3], [b1, b2], 2, 1, _).

% Ejercicio 22
test(peso_arbol1, all(P == [46])) :-
    arbol_ponderado(arbol1, A),
    peso_arbol(A, P).

test(peso_arbol2, all(P == [45])) :-
    arbol_ponderado(arbol2, A),
    peso_arbol(A, P).

test(mapeo_arboles, all(Nombre == [arbol2])) :-
    arbol_ponderado(arbol1, A1),
    arbol_ponderado(arbol2, A2),
    mapeo_arboles([A1, A2, A1], T),
    arbol_ponderado(Nombre, T).

test(mapeo_arboles_de_la_vacia, [fail]) :-
    mapeo_arboles([], _).

% Ejercicio 23
test(es_hoja) :-
    es_hoja(nodo(c, [])).

test(la_raiz_no_es_hoja, [fail]) :-
    arbol_nario(A),
    es_hoja(A).

test(cantidad, all(N == [8])) :-
    arbol_nario(A),
    cantidad(A, N).

test(cantidad_de_una_hoja, all(N == [1])) :-
    cantidad(nodo(c, []), N).

test(lista_hojas_n, all(L == [[e, f, g, c, h]])) :-
    arbol_nario(A),
    lista_hojas_n(A, L).

test(lista_hojas_n_de_una_hoja, all(L == [[c]])) :-
    lista_hojas_n(nodo(c, []), L).

test(quita_hojas, all(A2 == [nodo(a, [nodo(b, []), nodo(d, [])])])) :-
    arbol_nario(A),
    quita_hojas(A, A2).

test(quita_hojas_de_una_hoja, [fail]) :-
    quita_hojas(nodo(c, []), _).

% Ejercicio 24
test(recorrido_horizontal, all(L == [[a, c, j, t, r, h, m, q, z]])) :-
    arbol_horizontal(A),
    recorrido_horizontal(A, L).

test(recorrido_horizontal_nario, all(L == [[a, b, c, d, e, f, g, h]])) :-
    arbol_nario(A),
    recorrido_horizontal(A, L).

test(recorrido_horizontal_verifica, [fail]) :-
    arbol_horizontal(A),
    recorrido_horizontal(A, [a, c, t, r, q, z, j, h, m]).

% Ejercicio 25
test(secuencia_faltante, all(L == [[2, 3, 5, 7, 8, 9, 10, 11]])) :-
    secuencia_faltante([1, 4, 6, 12], L).

test(secuencia_faltante_equivocada, [fail]) :-
    secuencia_faltante([2, 4, 6], [1, 3, 5]).

test(secuencia_sin_faltantes, all(L == [[]])) :-
    secuencia_faltante([-1, 0, 1, 2], L).

:- end_tests(soluciones).
