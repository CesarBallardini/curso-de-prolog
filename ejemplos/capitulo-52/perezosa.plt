:- encoding(utf8).

:- begin_tests(perezosa).

test(alterna, [true(Fs == [0, 1, 0, 1, 0, 1, 0, 1, 0, 1])]) :-
    figuras(alterna, a, 10, Fs).

test(maquina_ii, [true(Fs == [0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1])]) :-
    figuras(ii, b, 15, Fs).

test(maquina_i, [true(Fs == [0, 1, 0, 1, 0, 1])]) :-
    figuras(i, b, 6, Fs).

test(resolver, [true(Q-N == emite(b, 0)-1)]) :-
    resolver(alterna, a, Q, N).

test(resolver_sin_alias, [true(Q-N == emite(b, 0)-0)]) :-
    resolver(alterna, emite(b, 0), Q, N).

test(seleccionar, [true(Ops-Q1 == [p(0), r]-b)]) :-
    seleccionar(alterna, a, blanco, _, _, Ops, Q1).

test(detenida, [true(R == detenida(fin, C0))]) :-
    cinta_de([schwa], 0, C0),
    ejecutar(alterna, fin, C0, 10, R).

test(limite, [true(Q == salta(a))]) :-
    cinta_vacia_local(C0),
    ejecutar(alterna, a, C0, 3, limite(Q, _)).

test(cinta_de, [true(C == c([a, schwa], x, [b]))]) :-
    cinta_de([schwa, a, x, b], 2, C).

test(cinta_de_final, [true(C == c([a, schwa], blanco, []))]) :-
    cinta_de([schwa, a], 2, C).

test(cinta_de_fuera, [fail]) :-
    cinta_de([schwa, a], 3, _).

test(sucesion, [true(S == '0101010101')]) :-
    sucesion(alterna, a, 10, S).

cinta_vacia_local(c([], blanco, [])).

:- end_tests(perezosa).
