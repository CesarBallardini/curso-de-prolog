:- encoding(utf8).

:- begin_tests(soluciones_piezas).

test(por_etapa, [true(Sin-Con == [1-540, 2-1626, 3-2403, 4-1199, 5-2602]-
                                [1-617, 2-1738, 3-2352, 4-1303, 5-2466])]) :-
    por_etapa(resolver, 50, Sin),
    por_etapa(resolver_con_ayuda, 50, Con).

% Las predicciones del ejercicio 12.
test(predicciones, [true(R == ['FL'-fuera, 'DR'-fuera, 'DF'-en_su_lugar,
                               p(u, r)])]) :-
    donde_tras([f], 'DF', L1, E1),
    donde_tras([d], 'DF', L2, E2),
    donde_tras([f, f, d, d, -f, -f], 'DF', L3, E3),
    pieza_tras([u], 'UF', P),
    R = [L1-E1, L2-E2, L3-E3, P].

:- end_tests(soluciones_piezas).
