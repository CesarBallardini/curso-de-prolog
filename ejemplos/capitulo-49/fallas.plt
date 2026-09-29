:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(fallas).

test(modelo_ok, [nondet, true(S == 0)]) :-
    modelo(ok, and, [1, 0], S).

test(modelo_pegada, [true(S == 1)]) :-
    modelo(pegada(1), and, [0, 0], S).

test(modelo_invertida, [nondet, true(S == 1)]) :-
    modelo(invertida, and, [1, 0], S).

% Sin fallas, con_fallas/5 simula como normal/4.
test(sin_fallas, [forall(( member(A, [0, 1]), member(B, [0, 1]),
                           member(C, [0, 1]) )),
                  nondet, true(Ss == Ss1)]) :-
    simular(con_fallas([]), sumador, [A, B, C], Ss),
    simular(sumador, [A, B, C], Ss1).

% La observación de Flach: una falla de una compuerta alcanza.
test(una_falla, [true(Fs == [[m1, x1]-pegada(1), [m1, x1]-invertida])]) :-
    findall(F, una_falla(sumador, [[0, 0, 1]-[0, 1]], F), Fs).

test(ninguna_simple, [fail]) :-
    una_falla(sumador, [[1, 1, 1]-[0, 0]], _).

test(dos_fallas, [true(N == 12)]) :-
    aggregate_all(count, k_fallas(sumador, [[1, 1, 1]-[0, 0]], 2, _), N).

test(explica, [true]) :-
    explica(sumador, [[1, 1, 1]-[0, 0]], [[m1, y1]-pegada(0), [m2, x1]-invertida]).

:- end_tests(fallas).
