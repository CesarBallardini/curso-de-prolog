:- encoding(utf8).

:- begin_tests(espacio).

test(capas, [true(Ns == [1, 12, 114, 1068])]) :-
    capas(3, Ns).

test(estados, [true(N == 43252003274489856000)]) :-
    estados(N).

test(profundizando, [true(L == 4)]) :-
    medir(profundizando, 4, 4, L, _).

test(anchura, [true(L == 3)]) :-
    medir(en_anchura, 3, 3, L, _).

test(misma_longitud, [true(L1 == L2)]) :-
    medir(profundizando, 11, 3, L1, _),
    medir(en_anchura, 11, 3, L2, _).

:- end_tests(espacio).
