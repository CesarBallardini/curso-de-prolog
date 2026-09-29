:- encoding(utf8).

:- begin_tests(numeros).

test(descripcion_i, [true(SD == "DADDCRDAA;DAADDRDAAA;DAAADDCCRDAAAA;DAAAADDRDA;")]) :-
    descripcion(i, b, [0, 1], SD).

test(numero_i, [true(N == 31332531173113353111731113322531111731111335317)]) :-
    numero(i, b, [0, 1], N).

test(estandar_ii, [true(NE-NI == 15-70)]) :-
    tabla_estandar(ii, b, [0, 1, schwa, x], tabla(Es, Is)),
    length(Es, NE),
    length(Is, NI).

test(misma_sucesion, [true(Fs == Gs)]) :-
    tabla_estandar(ii, b, [0, 1, schwa, x], T),
    figuras_estandar(T, 30, Fs),
    figuras(ii, b, 30, Gs).

test(resto, [true(A-Q1 == e(schwa, r)-resto([p(schwa), r, p(0), r, r,
                                               p(0), l, l], o))]) :-
    estandar(ii, b, blanco, A, Q1).

test(sin_operaciones, [true(A-Q1 == e(0, n)-q)]) :-
    estandar(ii, o, 0, A, Q1).

test(borrar, [true(A-Q1 == e(blanco, n)-resto([p(y)], fin))]) :-
    estandar(biblioteca, re1(fin, falta, x, y), x, A, Q1).

test(contador, [fail]) :-
    numero(contador, inicio, [0, 1, schwa], _).

test(dos_maquinas, [true(N1 \== N2)]) :-
    numero(i, b, [0, 1], N1),
    numero(i_bis, b, [0, 1], N2).

:- end_tests(numeros).
