:- encoding(utf8).

:- begin_tests(aplicar).

% --- call/N ----------------------------------------------------------------

test(call_agrega_argumentos, all(H == [ana, pedro])) :-
    call(padre, juan, H).

test(call_con_un_objetivo_incompleto, all(H == [ana, pedro])) :-
    G = padre(juan),
    call(G, H).

test(cumplen_mayores, true(L == [juan, ana, pedro])) :-
    cumplen(mayor_de_edad, L).

test(cumplen_menores, true(L == [luis, eva])) :-
    cumplen(menor_de_edad, L).

% --- maplist ---------------------------------------------------------------

test(edades, true(E == [68, 41, 8])) :-
    edades([juan, ana, eva], E).

% maplist/3 conserva los modos de edad/2: de las edades a las personas.
test(personas_por_edad, true(P == [ana, eva])) :-
    edades(P, [41, 8]).

test(todos_mayores) :-
    todos_mayores([juan, ana]).

test(no_todos_mayores, [fail]) :-
    todos_mayores([juan, eva]).

test(todos_mayores_de_ninguno) :-
    todos_mayores([]).

% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
test(mostrar_edades, true(S == "juan: 68\neva: 8\n")) :-
    with_output_to(string(S), mostrar_edades([juan, eva])).

test(maplist_4, true(L == [11, 22])) :-
    maplist(plus, [1, 2], [10, 20], L).

% --- foldl -----------------------------------------------------------------

test(suma_de_edades, true(S == 117)) :-
    suma_de_edades([juan, ana, eva], S).

test(suma_de_ninguna_edad, true(S == 0)) :-
    suma_de_edades([], S).

test(mayor, true(M == 9)) :-
    mayor([3, 9, 2], M).

test(mayor_de_la_lista_vacia, [fail]) :-
    mayor([], _).

% --- include, exclude, partition, convlist --------------------------------

test(separar_por_edad, true(A-B == [juan, ana]-[luis, eva])) :-
    separar_por_edad([juan, luis, ana, eva], A, B).

test(edades_conocidas, true(E == [68, 8])) :-
    edades_conocidas([juan, zoe, eva], E).

% maplist/3 falla si un elemento no cumple; convlist/3 lo omite.
test(maplist_con_una_persona_sin_edad, [fail]) :-
    edades([juan, zoe, eva], _).

% --- yall ------------------------------------------------------------------

test(sumar_a_todos, true(R == [11, 12, 13])) :-
    sumar_a_todos(10, [1, 2, 3], R).

test(mayores_que, true(M == [juan, ana])) :-
    mayores_que(40, [juan, ana, pedro, luis], M).

% var/1, que reconoce una variable libre, se presenta en el capítulo 32.
% Una variable libre en la lambda y no declarada entre llaves se copia en
% cada llamada: Y no queda ligada, y la conjunción se cumple con 1 y 2.
test(lambda_sin_llaves, true(var(Y))) :-
    maplist([X]>>(X = Y), [1, 2]).

test(lambda_con_llaves, true(Y == 1)) :-
    maplist({Y}/[X]>>(X = Y), [1, 1]).

test(lambda_con_llaves_distintos, [fail]) :-
    maplist({Y}/[X]>>(X = Y), [1, 2]).

:- end_tests(aplicar).
