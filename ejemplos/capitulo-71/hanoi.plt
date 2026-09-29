:- encoding(utf8).

:- begin_tests(hanoi).

test(expansion, [true(Hs == [torre(2, a, b)-0, mover(a, c)-1,
                             torre(2, b, c)-0])]) :-
    expansion(hanoi, torre(3, a, c), y, Hs).

test(primitivos) :-
    primitivo(hanoi, torre(0, a, c)),
    primitivo(hanoi, mover(a, b)).

test(tercero, [true(V == b)]) :-
    tercero(c, a, V).

test(estimacion, [true(H == 7)]) :-
    estimacion(hanoi, torre(3, a, c), H).

test(movimientos, [true(Ms == [a-c])]) :-
    movimientos(y(torre(1, a, c), [meta(torre(0, a, b))-0,
                                   meta(mover(a, c))-1,
                                   meta(torre(0, b, c))-0]),
                Ms).

:- end_tests(hanoi).
