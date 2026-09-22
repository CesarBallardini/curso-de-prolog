:- encoding(utf8).

:- begin_tests(comparar).

test(luis_es_mayor_que_eva) :-
    mayor_que(luis, eva).

test(eva_no_es_mayor_que_luis, [fail]) :-
    mayor_que(eva, luis).

test(nadie_es_mayor_que_si_mismo, [fail]) :-
    mayor_que(ana, ana).

test(ana_y_ana_no_son_distintas, [fail]) :-
    distintos(ana, ana).

test(ana_y_pedro_son_distintos) :-
    distintos(ana, pedro).

% En esta base no hay dos personas distintas con la misma edad.
test(sin_edades_repetidas, [fail]) :-
    comparten_edad(_, _).

:- end_tests(comparar).
