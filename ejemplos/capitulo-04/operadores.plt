:- encoding(utf8).

:- begin_tests(operadores).

% Las dos notaciones designan el mismo término.
test(dos_maneras_de_escribir_lo_mismo) :-
    2 + 3 = +(2, 3).

test(lados_de_una_suma, all(A-B == [2-3])) :-
    lados(2 + 3, A, B).

test(dar_vuelta_una_suma, all(S == [3 + 2])) :-
    al_reves(2 + 3, S).

test(una_suma_de_sumas, all(A-B == [(1 + 2)-3])) :-
    lados(1 + 2 + 3, A, B).

test(es_suma) :-
    es_suma(2 + 3).

test(un_producto_no_es_suma, [fail]) :-
    es_suma(2 * 3).

% El término no se evalúa de manera automática: es 2+3, no 5.
test(el_termino_no_se_calcula, [fail]) :-
    2 + 3 = 5.

:- end_tests(operadores).
