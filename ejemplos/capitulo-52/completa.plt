:- encoding(utf8).

:- begin_tests(completa).

test(maquina_i, [true(T == tabla([b, c, e, k],
                                 [i(b, blanco, [p(0), r], c),
                                  i(c, blanco, [r], e),
                                  i(e, blanco, [p(1), r], k),
                                  i(k, blanco, [r], b)]))]) :-
    completa(i, b, [0, 1], 10, T).

test(maquina_ii, [true(NE-NI == 5-20)]) :-
    completa(ii, b, [0, 1, schwa, x], 100, tabla(Es, Is)),
    length(Es, NE),
    length(Is, NI).

test(misma_sucesion, [true(Fs == Gs)]) :-
    completa(ii, b, [0, 1, schwa, x], 100, T),
    figuras_tabla(T, 30, Fs),
    figuras(ii, b, 30, Gs).

test(alterna, [true(Fs == [0, 1, 0, 1, 0, 1])]) :-
    completa(alterna, a, [0, 1], 100, T),
    T = tabla([a, b, c, d], _),
    figuras_tabla(T, 6, Fs).

test(biblioteca, [true(NE-NI == 6-35)]) :-
    completa(biblioteca, e(fin, x), [0, 1, schwa, a, b, x], 1000,
             tabla(Es, Is)),
    length(Es, NE),
    length(Is, NI).

test(contador, [true(N == 101)]) :-
    completa(contador, inicio, [0, 1, schwa], 100, incompleta(Es)),
    length(Es, N).

test(contador_crece, [true(N == 19)]) :-
    completa(contador, inicio, [0, 1, schwa], 1000, incompleta(Es)),
    include([Q]>>(Q = unos(cero, m(_))), Es, Us),
    length(Us, N).

test(transicion, [true(Ops-Q1 == [p(0), r]-b)]) :-
    transicion(alterna, a, blanco, Ops, Q1).

test(cuantas, [true(Ns == [5, mas_de(1000)])]) :-
    cuantas(ii, b, [0, 1, schwa, x], 100, N1),
    cuantas(contador, inicio, [0, 1, schwa], 1000, N2),
    Ns = [N1, N2].

:- end_tests(completa).
