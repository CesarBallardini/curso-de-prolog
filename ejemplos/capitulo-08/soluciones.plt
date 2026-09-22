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

test(la_lista_vacia_no_tiene_maximo, [fail]) :-
    maximo([], _).

test(factorial_de_cinco, all(F == [120])) :-
    factorial(5, F).

test(factorial_de_cero, all(F == [1])) :-
    factorial(0, F).

test(cuenta_atras, all(L == [[3, 2, 1]])) :-
    cuenta_atras(3, L).

test(cuenta_atras_de_cero, all(L == [[]])) :-
    cuenta_atras(0, L).

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

:- end_tests(soluciones).
