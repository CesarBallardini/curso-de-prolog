:- encoding(utf8).

:- begin_tests(todas).

test(hijos_de_juan, true(H == [ana, pedro])) :-
    hijos_de(juan, H).

% Sin respuestas, findall/3 da la lista vacía: hijos_de/2 es det.
test(hijos_de_ana, true(H == [])) :-
    hijos_de(ana, H).

test(cuantos_hijos_de_pedro, true(N == 2)) :-
    cuantos_hijos(pedro, N).

test(cuantos_hijos_de_eva, true(N == 0)) :-
    cuantos_hijos(eva, N).

% bagof/3 agrupa por la variable libre P: una respuesta por padre.
test(hijos_agrupados, all(P-H == [juan-[ana, pedro], pedro-[luis, eva]])) :-
    hijos_agrupados(P, H).

% Sin respuestas, bagof/3 falla.
test(ana_no_tiene_grupo, [fail]) :-
    hijos_agrupados(ana, _).

% setof/3 elimina los repetidos: juan una sola vez.
test(los_padres, true(P == [juan, pedro])) :-
    padres(P).

test(sin_hijos, all(P == [ana, luis, eva])) :-
    no_tiene_hijos(P).

:- end_tests(todas).
