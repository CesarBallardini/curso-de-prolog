:- encoding(utf8).

:- begin_tests(capitulo38).

test(estratificado, [true(M == [p, q])]) :-
    modelo_estandar_de([(p :- true), (q :- p, \+ r)], M).

test(no_estratificado, [fail]) :-
    modelo_estandar_de([(p :- \+ q), (q :- \+ p)], _).

:- end_tests(capitulo38).
