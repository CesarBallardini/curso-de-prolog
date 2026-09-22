:- encoding(utf8).

:- begin_tests(comparar).

% 2+1 y 3 tienen el mismo valor y no son el mismo término.
test(distinto_termino) :-
    distinto_termino(2 + 1, 3).

test(mismo_valor) :-
    mismo_valor(2 + 1, 3).

test(no_son_el_mismo_termino, [fail]) :-
    mismo_termino(2 + 1, 3).

% Con una variable libre, = y == producen resultados distintos.
test(una_variable_unifica_con_todo, [nondet]) :-
    pueden_ser_el_mismo(_, ana).

test(pero_no_es_el_mismo_termino, [fail]) :-
    mismo_termino(_, ana).

test(dos_atomos_iguales) :-
    mismo_termino(ana, ana).

test(dos_atomos_distintos) :-
    distinto_termino(ana, eva).

% =:= solo se aplica a expresiones aritméticas.
test(los_atomos_no_tienen_valor, [throws(error(type_error(evaluable, _), _))]) :-
    mismo_valor(ana, ana).

:- end_tests(comparar).
