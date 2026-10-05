:- encoding(utf8).

:- begin_tests(tipos).

test(ciclos, [true(C == [[1, 2, 3], [4, 5]])]) :-
    ciclos([2, 3, 1, 5, 4], C).

test(ciclos_pendientes, [true(C == [[2, 3]])]) :-
    ciclos([2, 3], [1, 3, 2], C).

test(ciclo_desde, [true(C == [3, 1, 2])]) :-
    ciclo_desde(3, 3, [2, 3, 1], C).

test(tipo, [true(T == [2, 3])]) :-
    tipo([2, 3, 1, 5, 4], T).

test(tipo_con_puntos_fijos, [true(T == [1, 1, 2])]) :-
    tipo([1, 2, 4, 3], T).

test(conjugada, [true(Q == [3, 2, 1])]) :-
    conjugada([2, 1, 3], [3, 1, 2], Q).

test(imagen_renombrada, [true(P == 3-1)]) :-
    imagen_renombrada([2, 1, 3], [3, 1, 2], 1, P).

test(conjugada_mismo_tipo, [nondet]) :-
    forall(( desarreglo(5, P), desarreglo(5, S) ),
           ( conjugada(P, S, Q), tipo(P, T), tipo(Q, T) )).

test(conjugada_mismo_total, [nondet]) :-
    forall(( member(P, [[2, 1, 4, 5, 6, 3], [2, 3, 1, 5, 6, 4]]),
             member(S, [[6, 5, 4, 3, 2, 1], [3, 1, 2, 6, 4, 5]]) ),
           ( conjugada(P, S, Q),
             once(tablero(6, P, _, T)),
             once(tablero(6, Q, _, T)) )).

test(visitar_salta_el_tipo_visto, [true(E == [[2, 2]]-[[2, 2]-40])]) :-
    foldl(visitar, [[2, 1, 4, 3], [3, 4, 1, 2]], []-[], E).

test(visitar_sin_filas_distintas, [true(E == [[2]]-[])]) :-
    visitar([2, 1], []-[], E).

test(maximo_por_tipo_8, [true(T-N == 544-6)]) :-
    maximo_por_tipo(8, T, Tipos),
    length(Tipos, N).

test(igual_a_ingenuo, [nondet]) :-
    forall(between(3, 7, N),
           ( maximo(N, T, _), maximo_por_tipo(N, T, _) )).

:- end_tests(tipos).
