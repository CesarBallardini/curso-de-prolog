:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1
test(dos_lleva_dos_eses, all(N == [s(s(cero))])) :-
    dos(N).

test(cuatro_lleva_cuatro_eses, all(V == [4])) :-
    cuatro(N),
    valor(N, V).

% Ejercicio 3
test(dos_es_mayor_que_uno) :-
    mayor(s(s(cero)), s(cero)).

test(uno_no_es_mayor_que_dos, [fail]) :-
    mayor(s(cero), s(s(cero))).

test(nadie_es_mayor_que_si_mismo, [fail]) :-
    mayor(s(s(cero)), s(s(cero))).

% Ejercicio 4
test(el_doble_de_dos_es_cuatro, all(V == [4])) :-
    doble_natural(s(s(cero)), D),
    valor(D, V).

% Ejercicio 5
test(desde_tres, all(N == [s(s(s(cero)))])) :-
    desde(3, N).

test(desde_cero, all(N == [cero])) :-
    desde(0, N).

% Ejercicio 7
test(juan_es_tatarabuelo_de_nadie, [fail]) :-
    tatarabuelo(juan, _).

test(hay_tres_escalones_hasta_eva, all(N == [3])) :-
    generaciones(juan, eva, N).

% Ejercicio 9
test(cero_es_par) :-
    par(cero).

test(dos_es_par, [nondet]) :-
    par(s(s(cero))).

test(uno_no_es_par, [fail]) :-
    par(s(cero)).

test(tres_no_es_par, [fail]) :-
    par(s(s(s(cero)))).

% Ejercicio 13
test(menor_o_igual_hasta_uno, all(A == [cero, s(cero)])) :-
    menor_o_igual(A, s(cero)).

test(cero_es_menor_o_igual_que_todo) :-
    menor_o_igual(cero, s(s(cero))).

test(dos_no_es_menor_o_igual_que_uno, [fail]) :-
    menor_o_igual(s(s(cero)), s(cero)).

% Ejercicio 14
test(impar_de_uno) :-
    impar(s(cero)).

test(paridad_de_dos, all(P == [par])) :-
    paridad(s(s(cero)), P).

test(paridad_de_tres, all(P == [impar])) :-
    paridad(s(s(s(cero))), P).

:- end_tests(soluciones).
