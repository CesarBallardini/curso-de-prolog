:- encoding(utf8).

:- begin_tests(por_negacion).

test(el_mayor_es_juan, all(P == [juan])) :-
    mayor_edad(P).

test(ana_no_es_la_mayor, [fail]) :-
    mayor_edad(ana).

test(el_menor_de_pedro_es_eva, all(H == [eva])) :-
    hijo_menor(pedro, H).

test(los_hijos_menores, all(P-H == [juan-pedro, pedro-eva])) :-
    hijo_menor(P, H).

:- end_tests(por_negacion).
