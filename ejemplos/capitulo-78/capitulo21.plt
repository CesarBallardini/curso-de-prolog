:- encoding(utf8).

:- begin_tests(capitulo21).

test(cueva, [true(P-W-O == [3-1, 3-3, 4-4]-(1-3)-(2-3))]) :-
    cueva_21(P, W, O).

test(agente, [true(R-Cs == oro(2-3)-[1-1, 2-1, 1-2, 2-2, 3-2, 2-3])]) :-
    explorar(R),
    recorrido(Cs).

:- end_tests(capitulo21).
