:- encoding(utf8).

:- begin_tests(finales, [setup(calcular)]).

% Las cifras de Bramer (1979) para rey y torre contra rey, y las 16 jugadas
% de Bratko.
test(resumen, [true(R == r(27352, 34968, 3495, 16))]) :-
    resumen(R).

test(normal, [true(N == pos(blancas, 2-2, 1-8, 4-1))]) :-
    normal(pos(blancas, 7-7, 8-1, 5-8), N).

test(normal_ya_normal, [true(N == pos(negras, 3-3, 8-8, 1-1))]) :-
    normal(pos(negras, 3-3, 8-8, 1-1), N).

test(posiciones, [true(N == 27352)]) :-
    posiciones(blancas, Ps),
    length(Ps, N).

test(mate_en, [true(K == 8)]) :-
    mate_en(pos(blancas, 5-5, 1-1, 4-7), K).

test(mate_en_simetrica, [true(K1 == K2)]) :-
    mate_en(pos(blancas, 5-5, 1-1, 4-7), K1),
    mate_en(pos(blancas, 4-5, 8-1, 5-7), K2).

test(mate_en_negras, [true(K == 0)]) :-
    mate_en(pos(negras, 2-3, 8-1, 1-1), K).

% Con la torre colgada y las negras a mover, no hay mate.
test(tablas, [fail]) :-
    mate_en(pos(negras, 5-5, 2-2, 1-1), _).

test(mejor_jugada, [true(K-J == 14-torre(4-4, 4-1))]) :-
    P = pos(blancas, 1-1, 4-4, 3-3),
    mate_en(P, K),
    mejor_jugada(P, J).

test(optima_captura, [true(J == rey(1-1, 2-2))]) :-
    optima(pos(negras, 5-5, 2-2, 1-1), J).

test(codigo, [true(P == pos(negras, 5-5, 2-2, 1-1))]) :-
    codigo(pos(negras, 5-5, 2-2, 1-1), C),
    decodificar(negras, C, P).

test(sucesora_captura, [true(C == captura)]) :-
    sucesora(pos(blancas, 5-5, capturada, 2-2), C).

test(nodo_mate, [true(Cs == [])]) :-
    normal(pos(negras, 2-3, 8-1, 1-1), P),
    codigo(P, C),
    nodo(negras, C, Cs).

:- end_tests(finales).
