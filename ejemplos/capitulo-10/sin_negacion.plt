:- encoding(utf8).

:- begin_tests(sin_negacion).

test(mayor_con_corte, all(P == [juan])) :-
    mayor_edad_con_corte(P).

test(mayor_sin_negacion, all(P == [juan])) :-
    mayor_edad_sin_negacion(P).

test(menores_con_corte, all(P-H == [juan-pedro, pedro-eva])) :-
    hijo_menor_con_corte(P, H).

test(menores_sin_negacion, all(P-H == [juan-pedro, pedro-eva])) :-
    hijo_menor_sin_negacion(P, H).

% En esta familia no hay hijos únicos: cada padre tiene dos hijos.
test(no_hay_hijos_unicos_con_corte, [fail]) :-
    hijo_unico_con_corte(_).

test(no_hay_hijos_unicos_sin_negacion, [fail]) :-
    hijo_unico_sin_negacion(_).

:- end_tests(sin_negacion).
