:- encoding(utf8).

:- use_module(corregida, []).

:- begin_tests(partida).

test(mate_en_12, [true(F-N == mate-12)]) :-
    partida(krk, primera, pos(blancas, 5-5, 1-1, 4-7), Js, F),
    include([J]>>(J = blancas(_, _)), Js, Bs),
    length(Bs, N).

test(primera_jugada, [true(J1 == blancas(torre(1-1, 3-1), dividir_en_2))]) :-
    partida(krk, primera, pos(blancas, 5-5, 1-1, 4-7), [J1|_], _).

test(jugadas_hasta_mate, [true(N == 12)]) :-
    jugadas_hasta_mate(krk, primera, pos(blancas, 5-5, 1-1, 4-7), N).

test(resistente, [true(N == 9)]) :-
    jugadas_hasta_mate(krk, resistente, pos(blancas, 5-5, 1-1, 4-7), N).

% La tabla original ahoga al rey negro en una jugada.
test(ahogado, [true(F-Js == ahogado-[blancas(rey(1-3, 2-3),
                                               mantener_espacio)])]) :-
    partida(krk, primera, pos(blancas, 1-3, 2-2, 1-1), Js, F).

test(corregida, [true(F == mate)]) :-
    partida(corregida, primera, pos(blancas, 1-3, 2-2, 1-1), _, F).

% Las negras capturan la torre si la defensa puede.
test(resistente_captura, [true(J == rey(1-1, 2-2))]) :-
    resistente(pos(negras, 5-5, 2-2, 1-1), J).

test(primera, [true(J == rey(1-1, 2-1))]) :-
    primera(pos(negras, 3-3, 1-8, 1-1), J).

test(narrar, [true(Lineas == ["1. Ta2 Rb1", "2. Rb3 Rc1"])]) :-
    with_output_to(string(S),
                   narrar(corregida, primera, pos(blancas, 1-3, 2-2, 1-1))),
    split_string(S, "\n", "", [L1, L2|_]),
    maplist(primeras_palabras, [L1, L2], Lineas).

% primeras_palabras(L, P): P son las tres primeras palabras de L.
primeras_palabras(L, P) :-
    split_string(L, " ", " ", [A, B, C|_]),
    atomic_list_concat([A, B, C], ' ', At),
    atom_string(At, P).

:- end_tests(partida).
