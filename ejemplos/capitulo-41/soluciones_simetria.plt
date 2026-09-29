:- encoding(utf8).

:- begin_tests(soluciones_simetria, [setup(abolish_all_tables)]).

test(canonica, [true(C == [o, v, v, v, v, v, v, v, x])]) :-
    canonica([v, v, x, v, v, v, o, v, v], C).

% Las cuatro esquinas tienen la misma forma canónica.
test(esquinas, [true(Cs == [[v, v, v, v, v, v, v, v, x]])]) :-
    findall(C, ( member(T, [[x, v, v, v, v, v, v, v, v],
                            [v, v, x, v, v, v, v, v, v],
                            [v, v, v, v, v, v, x, v, v],
                            [v, v, v, v, v, v, v, v, x]]),
                 canonica(T, C) ), Cs0),
    sort(Cs0, Cs).

test(vacio, [true(V-N == 0-765)]) :-
    abolish_all_tables,
    inicial(tateti(3), P),
    valor_simetrico(tateti(3), P, V),
    canonicas(N).

test(gana_x, [true(V == 102)]) :-
    valor_simetrico(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), V).

% Las ocho simetrías son permutaciones distintas de las nueve casillas.
test(simetrias, [true(N-M == 8-8)]) :-
    findall(O, ( simetria(O), msort(O, [1, 2, 3, 4, 5, 6, 7, 8, 9]) ), Os),
    length(Os, N),
    sort(Os, Distintas),
    length(Distintas, M).

% Una posición y su reflejo tienen el mismo valor.
test(reflejo, [true(V1 == V2)]) :-
    valor_simetrico(tateti(3), pos([x, o, v, v, v, v, v, v, v], x), V1),
    valor_simetrico(tateti(3), pos([v, o, x, v, v, v, v, v, v], x), V2).

:- end_tests(soluciones_simetria).
