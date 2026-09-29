:- encoding(utf8).

:- begin_tests(macros).

test(compilada_igual_a_la_lista, [true(C1 == C2)]) :-
    resuelto(C),
    aplicar([r, u, -r, u, r, u, u, -r], C, C1),
    usar(sune, C, C2).

test(compilar_es_una_unificacion, [true(C1 == C2)]) :-
    compilar([f, -l, d], Antes-Despues),
    resuelto(C),
    aplicar([f, -l, d], C, C1),
    Antes = C,
    Despues = C2.

test(efecto_del_conmutador, [true(Ps == ['UBL', 'UB', 'DFR', 'FR', 'UBR',
                                        'UR', 'UFR'])]) :-
    compilar([r, u, -r, -u], M),
    efecto(M, Ps).

test(efecto_tres_esquinas, [true(Ps == ['UBL', 'UBR', 'UFR'])]) :-
    macro(tres_esquinas, A, D),
    efecto(A-D, Ps).

test(efecto_vacio, [true(Ps == [])]) :-
    compilar([u, -u], M),
    efecto(M, Ps).

test(veinte_piezas, [true(N-Esq == 20-8)]) :-
    aggregate_all(count, pieza(_, _, _), N),
    aggregate_all(count, ( pieza(_, _, Is), length(Is, 3) ), Esq).

test(nombres, [true(Ns == ['BL', 'BR', 'DB', 'DBL', 'DBR', 'DF', 'DFL', 'DFR',
                           'DL', 'DR', 'FL', 'FR', 'UB', 'UBL', 'UBR', 'UF',
                           'UFL', 'UFR', 'UL', 'UR'])]) :-
    findall(N, pieza(_, N, _), Ns0),
    msort(Ns0, Ns).

test(conmutador, [true(S == [r, u, -r, -u])]) :-
    conmutador([r], [u], S).

test(conjugado, [true(S == [f, u, -f])]) :-
    conjugado([f], [u], S).

test(orden_de_una_macro, [true(N == 3)]) :-
    leer_notacion("R U' L' U R' U' L U", Ms),
    orden(Ms, N).

test(efecto_de, [true(Ps == [])]) :-
    efecto_de("R L R' L'", Ps).

test(efecto_macro, [true(Ps == ['UBR', 'UFR'])]) :-
    efecto_macro(dos_esquinas, Ps).

test(inferencias, [true(C < L)]) :-
    inferencias(dos_esquinas, 100, L, C).

:- end_tests(macros).
