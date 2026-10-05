:- encoding(utf8).

:- begin_tests(lazo).

test(bit, [true(B == 256)]) :-
    bit(6, 2-3, B).

test(mascara, [true(M == 7)]) :-
    mascara(6, [1-1, 1-2, 1-3], M).

test(sumar_bit, [true(M == 3)]) :-
    sumar_bit(6, 1-2, 1, M).

test(red, [true(L-Ks == 9-9)]) :-
    red(csenki1, 1-4, red(S, B, L, Tramos)),
    S == 1-4,
    B =:= 1 << 3,
    assoc_to_keys(Tramos, Marcas),
    length(Marcas, Ks).

test(estado_inicial, [true(A-N-U == (1-4)-8-8)]) :-
    red(csenki1, 1-4, Red),
    estado_inicial(Red, e(A, P, U)),
    length(P, N).

test(avanzar_primer_paso, [true(Qs == [2-1, 2-2, 2-2, 5-5])]) :-
    red(csenki1, 1-4, Red),
    estado_inicial(Red, E),
    findall(Q, avanzar(Red, E, _, e(Q, _, _)), Qs0),
    msort(Qs0, Qs).

test(avanzar_no_pisa, [fail]) :-
    red(csenki1, 1-4, Red),
    estado_inicial(Red, e(A, P, U0)),
    mascara(6, [1-3], M),
    U is U0 \/ M,
    avanzar(Red, e(A, P, U), [1-3|_], _).

test(planes_csenki1, [true(N-L == 2-9)]) :-
    planes(csenki1, 1-4, [P|Ps]),
    length([P|Ps], N),
    length(P, L).

test(lazo_de_plan, [true(L == [1-1, 1-2, 2-2, 2-1])]) :-
    lazo_de_plan(1-1, [[1-2, 2-2], [2-1, 1-1]], L).

test(lazos_csenki1, [nondet, true(N-K == 2-36)]) :-
    lazos(csenki1, 1-4, [L|Ls]),
    length([L|Ls], N),
    length(L, K).

test(lazos_desde_cada_semilla, [true(T == 18)]) :-
    aggregate_all(sum(N), ( lazos(csenki1, _, Ls), length(Ls, N) ), T).

test(sin_ultima, [true(R == [a, b])]) :-
    sin_ultima([a, b, c], R).

test(sin_ultima_vacia, [fail]) :-
    sin_ultima([], _).

test(lazos_desde, [true(N == 2)]) :-
    lazos_desde(csenki1, 1-4, Ls),
    length(Ls, N).

test(lazo_chico, [true(Ls == [[1-1, 1-2, 1-3, 2-3, 3-3, 3-2, 3-1, 2-1],
                              [1-1, 2-1, 3-1, 3-2, 3-3, 2-3, 1-3, 1-2]])]) :-
    lazos_desde(chico, 1-1, Ls0),
    msort(Ls0, Ls).

:- end_tests(lazo).
