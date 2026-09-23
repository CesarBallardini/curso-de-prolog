:- encoding(utf8).

:- begin_tests(babushka).

test(la_maciza_ya_esta_desarmada) :-
    desarma(babushka_maciza).

test(tres_huecas_y_una_maciza) :-
    desarma(babushka_hueca(babushka_hueca(babushka_hueca(babushka_maciza)))).

% Sin la muñeca maciza en el centro no se llega nunca al caso base.
test(algo_que_no_es_una_babushka, [fail]) :-
    desarma(babushka_hueca(pelota)).

:- end_tests(babushka).
