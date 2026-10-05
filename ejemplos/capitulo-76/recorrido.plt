:- encoding(utf8).

:- begin_tests(recorrido).

test(ingenuo_5, [nondet]) :-
    recorrido(ingenuo, 5, 1-1, C),
    es_recorrido(5, C).

test(warnsdorff_8, [nondet]) :-
    recorrido(warnsdorff, 8, 1-1, C),
    es_recorrido(8, C).

test(warnsdorff_20, [nondet]) :-
    recorrido(warnsdorff, 20, 1-1, C),
    es_recorrido(20, C).

test(sin_recorrido, [fail]) :-
    recorrido(ingenuo, 4, 1-1, _).

test(no_es_recorrido, [fail]) :-
    es_recorrido(5, [1-1, 2-3]).

test(libres_desde, [true(L == 2)]) :-
    list_to_assoc([1-1-si], V),
    libres_desde(8, 1-1, V, L).

test(libres_desde_visitada, [true(L == 1)]) :-
    list_to_assoc([1-1-si, 2-3-si], V),
    libres_desde(8, 1-1, V, L).

test(tablero, [true(Fs == [[3, 2], [1, 4]])]) :-
    tablero(2, [1-1, 2-2, 1-2, 2-1], Fs).

:- end_tests(recorrido).

:- begin_tests(mostrar_recorrido).

test(cinco, [true(L == "  25  18   3  12  23")]) :-
    with_output_to(string(S), mostrar_recorrido(ingenuo, 5, 1-1)),
    split_string(S, "\n", "", [L|_]).

test(sin_recorrido, [fail]) :-
    mostrar_recorrido(ingenuo, 4, 1-1).

:- end_tests(mostrar_recorrido).
