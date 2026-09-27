:- encoding(utf8).

:- begin_tests(agregados).

test(el_mayor, true(Q-E == juan-68)) :-
    mayor_edad(Q, E).

test(el_promedio, true(P =:= 33.6)) :-
    edad_promedio(P).

test(los_hijos_de_pedro_son_menores) :-
    todos_los_hijos_son_menores(pedro).

test(los_hijos_de_juan_no_son_menores, [fail]) :-
    todos_los_hijos_son_menores(juan).

% Sin hijos, forall/2 se cumple: no hay ningún hijo que no sea menor.
test(ana_no_tiene_hijos_y_se_cumple) :-
    todos_los_hijos_son_menores(ana).

test(orden_por_edad, all(P == [juan, ana, pedro, luis, eva])) :-
    de_mayor_a_menor(P, _).

test(los_dos_mayores, all(P == [juan, ana])) :-
    los_dos_mayores(P, _).

:- end_tests(agregados).
