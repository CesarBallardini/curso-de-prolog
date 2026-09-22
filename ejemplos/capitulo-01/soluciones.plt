:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1: con luis como padre de clara, pedro es abuelo de clara.
test(clara_es_nieta_de_pedro, all(A == [pedro])) :-
    nieto(clara, A).

% Ejercicio 5
test(nietos_de_juan, all(N == [luis, eva])) :-
    nieto(N, juan).

% Ejercicio 6
test(propietario_de_perro, all(P == [luis])) :-
    propietario_de_perro(P).

test(todos_tienen_mascota, all(P == [ana, luis, eva, pedro])) :-
    tiene_mascota(P).

% Ejercicio 7
test(eva_es_menor_que_luis) :-
    menor_que(eva, luis).

test(luis_no_es_menor_que_eva, [fail]) :-
    menor_que(luis, eva).

% Ejercicio 8
test(triple_de_11, all(T == [33])) :-
    triple(11, T).

test(triple_no_va_para_atras, [throws(error(instantiation_error, _))]) :-
    triple(_, 33).

% Ejercicio 9
test(cuenta_al_reves_escribe_de_mayor_a_menor) :-
    with_output_to(string(S), cuenta_al_reves(3, 1)),
    assertion(S == "3\n2\n1\n").

% Ejercicio 12
test(cuantos_con_uno_mas, all(N == [5])) :-
    cuantos_invitados_mas(pedro, N).

% Ejercicio 14
test(mayor_de_cuarenta, all(P == [juan, ana])) :-
    mayor_de(P, 40).

test(sofia_no_es_mayor_de_cuarenta, [fail]) :-
    mayor_de(sofia, 40).

test(en_edad_escolar, all(P == [luis, eva])) :-
    en_edad_escolar(P).

:- end_tests(soluciones).
