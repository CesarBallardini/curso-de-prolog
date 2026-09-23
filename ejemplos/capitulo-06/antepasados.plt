:- encoding(utf8).

:- begin_tests(antepasados).

test(un_progenitor_es_antepasado, [nondet]) :-
    antepasado(tare, abraham).

test(el_abuelo_tambien, [nondet]) :-
    antepasado(tare, isaac).

test(la_madre_tambien, [nondet]) :-
    antepasado(sara, isaac).

test(no_al_reves, [fail]) :-
    antepasado(isaac, tare).

test(entre_hermanos_no, [fail]) :-
    antepasado(abraham, lot).

test(todos_los_descendientes_de_tare,
     all(Q == [abraham, nacor, haran, isaac, lot, milca, isca])) :-
    antepasado(tare, Q).

:- end_tests(antepasados).
