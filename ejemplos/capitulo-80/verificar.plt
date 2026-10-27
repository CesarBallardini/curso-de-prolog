:- encoding(utf8).

:- use_module(krk, []).
:- use_module(corregida, []).

:- begin_tests(verificar).

test(salidas, [true(S == [2-nueva(pos(blancas, 5-5, 3-6, 4-7)),
                          2-nueva(pos(blancas, 5-5, 3-6, 4-8)),
                          2-nueva(pos(blancas, 5-5, 3-6, 5-7)),
                          2-nueva(pos(blancas, 5-5, 3-6, 5-8)),
                          2-nueva(pos(blancas, 5-5, 3-6, 6-7)),
                          2-nueva(pos(blancas, 5-5, 3-6, 6-8))])]) :-
    salidas(krk, pos(blancas, 5-5, 1-1, 4-7), S0),
    sort(S0, S).

test(salida_ahogado, [true(S == [1-falla(ahogado)])]) :-
    salidas(krk, pos(blancas, 1-3, 2-2, 1-1), S).

test(salida_mate, [true(S == [2-mate])]) :-
    salidas(krk, pos(blancas, 1-3, 1-4, 2-1), S).

test(desde_centro, [true(R == r(145, 145, 14))]) :-
    verificar_desde(krk, pos(blancas, 5-5, 1-1, 4-7), R).

test(desde_ahogado, [true(R-Ps == r(0, 1, 0)-[pos(blancas, 1-3, 2-2, 1-1)])]) :-
    verificar_desde(krk, pos(blancas, 1-3, 2-2, 1-1), R),
    no_aseguradas(krk, Ps).

test(corregida, [true(R == r(25, 25, 14))]) :-
    verificar_desde(corregida, pos(blancas, 1-3, 2-2, 1-1), R).

test(peor_partida, [true(P-K == pos(blancas, 1-3, 2-2, 1-1)-14)]) :-
    verificar_desde(corregida, pos(blancas, 1-3, 2-2, 1-1), _),
    peor_partida(corregida, P, K).

:- end_tests(verificar).
