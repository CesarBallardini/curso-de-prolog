:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1
test(dos_lleva_dos_eses, all(N == [s(s(0))])) :-
    dos(N).

test(cuatro_lleva_cuatro_eses, all(V == [4])) :-
    cuatro(N),
    valor(N, V).

% Ejercicio 3
test(dos_es_mayor_que_uno) :-
    mayor(s(s(0)), s(0)).

test(uno_no_es_mayor_que_dos, [fail]) :-
    mayor(s(0), s(s(0))).

test(nadie_es_mayor_que_si_mismo, [fail]) :-
    mayor(s(s(0)), s(s(0))).

% Ejercicio 4
test(el_doble_de_dos_es_cuatro, all(V == [4])) :-
    doble_natural(s(s(0)), D),
    valor(D, V).

% Ejercicio 5
test(desde_tres, all(N == [s(s(s(0)))])) :-
    desde(3, N).

test(desde_cero, all(N == [0])) :-
    desde(0, N).

% Ejercicio 7
test(juan_es_tatarabuelo_de_nadie, [fail]) :-
    tatarabuelo(juan, _).

test(hay_tres_escalones_hasta_eva, all(N == [3])) :-
    generaciones(juan, eva, N).

% Ejercicio 9
test(cero_es_par) :-
    par(0).

test(dos_es_par, [nondet]) :-
    par(s(s(0))).

test(uno_no_es_par, [fail]) :-
    par(s(0)).

test(tres_no_es_par, [fail]) :-
    par(s(s(s(0)))).

% Ejercicio 13
test(menor_o_igual_hasta_uno, all(A == [0, s(0)])) :-
    menor_o_igual(A, s(0)).

test(cero_es_menor_o_igual_que_todo) :-
    menor_o_igual(0, s(s(0))).

test(dos_no_es_menor_o_igual_que_uno, [fail]) :-
    menor_o_igual(s(s(0)), s(0)).

% Ejercicio 14
test(impar_de_uno) :-
    impar(s(0)).

test(paridad_de_dos, all(P == [par])) :-
    paridad(s(s(0)), P).

test(paridad_de_tres, all(P == [impar])) :-
    paridad(s(s(s(0))), P).

:- end_tests(soluciones).
