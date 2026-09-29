:- encoding(utf8).

% Los planificadores se cargan sin importar nada: el mundo ya define
% predicados con los mismos nombres.
:- use_module(warplan, []).
:- use_module(extension, []).

:- begin_tests(soluciones_cubos).

test(torre, [true(P == [mover(a, b, mesa), mover(b, c, a),
                        mover(c, mesa, b)])]) :-
    once(warplan:planificar(cubos2, torre, [sobre(c, b), sobre(b, a)], 6,
                            P)).

test(torre_sin_cota, [true(L == 4)]) :-
    once(warplan:planificar_sin_cota(cubos2, torre,
                                     [sobre(c, b), sobre(b, a)], P)),
    length(P, L).

test(torre_extension, [true(L == 3)]) :-
    once(extension:planificar(cubos2, torre, [sobre(c, b), sobre(b, a)], 6,
                              P)),
    length(P, L).

test(cuatro, [true(P == [mover(d, c, mesa), mover(c, b, d), mover(b, a, c),
                         mover(a, mesa, b)])]) :-
    once(warplan:planificar(cubos2, cuatro,
                            [sobre(a, b), sobre(b, c), sobre(c, d)], 6, P)).

test(cuatro_sin_cota, [true(L == 6)]) :-
    once(warplan:planificar_sin_cota(cubos2, cuatro,
                                     [sobre(a, b), sobre(b, c), sobre(c, d)],
                                     P)),
    length(P, L).

test(ciclo, [fail]) :-
    warplan:planificar(cubos2, sussman, [sobre(X, b), sobre(b, X)], 4, _).

test(ciclo_inconsistente) :-
    extension:inconsistente(cubos2, [sobre(X, b), sobre(b, X)], []).

test(ciclo_sin_detectar, [fail]) :-
    extension:inconsistente(cubos, [sobre(X, b), sobre(b, X)], []).

:- end_tests(soluciones_cubos).
