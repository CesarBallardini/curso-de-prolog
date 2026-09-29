:- encoding(utf8).

:- begin_tests(capitulo40).

test(vuelta, [true(P-C == [ir(2-2), ir(2-1), ir(1-1)]-3)]) :-
    vuelta(2-3, [1-1, 1-2, 2-1, 2-2, 2-3, 3-2], P, C, _).

test(en_casa, [true(P == [])]) :-
    vuelta(1-1, [1-1], P, _, _).

test(sin_camino, [fail]) :-
    vuelta(3-3, [1-1, 3-3], _, _, _).

:- end_tests(capitulo40).
