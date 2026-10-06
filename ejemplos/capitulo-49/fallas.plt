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

test(falla, all(E == [pegada(0), pegada(1), invertida])) :-
    falla(E).

% Una compuerta de la lista toma su estado; las demás, ok.
test(con_fallas_en_lista, all(S == [1])) :-
    con_fallas([[g]-pegada(1)], [g], and, [0, 0], S).

test(con_fallas_fuera_de_lista, all(S == [0])) :-
    con_fallas([[h]-pegada(1)], [g], and, [1, 0], S).

test(con_fallas_invertida, all(S == [0])) :-
    con_fallas([[g]-invertida], [g], or, [1, 0], S).

% Con una observación correcta, las fallas que no cambian las salidas
% también la explican.
test(una_falla_observacion_correcta,
     all(F == [[m1, x1]-pegada(0), [m1, y1]-pegada(0), [m2, x1]-pegada(1),
               [m2, y1]-pegada(0), [o1]-pegada(0)])) :-
    una_falla(sumador, [[0, 0, 1]-[1, 0]], F).

test(k_fallas_cero, all(F == [[]])) :-
    k_fallas(sumador, [[0, 0, 1]-[1, 0]], 0, F).

test(k_fallas_cero_mal, [fail]) :-
    k_fallas(sumador, [[0, 0, 1]-[0, 1]], 0, _).

test(explica_sin_fallas, [fail]) :-
    explica(sumador, [[0, 0, 1]-[0, 1]], []).

test(subsecuencia, all(X == [[], [a], [a, b], [a, b, c], [a, c], [b],
                             [b, c], [c]])) :-
    fallas:subsecuencia(X, [a, b, c]).

test(subsecuencia_orden, [fail]) :-
    fallas:subsecuencia([c, a], [a, b, c]).

test(con_estado, all(F == [[g]-pegada(0), [g]-pegada(1), [g]-invertida])) :-
    fallas:con_estado([g], F).

:- end_tests(fallas).
