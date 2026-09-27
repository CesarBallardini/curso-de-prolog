:- encoding(utf8).

:- begin_tests(buscaminas).

test(una_esquina_tiene_tres_vecinas, true(N == 3)) :-
    aggregate_all(count, vecina(1, 1, _, _), N).

test(el_centro_tiene_ocho_vecinas, true(N == 8)) :-
    aggregate_all(count, vecina(3, 3, _, _), N).

% (2, 2) toca las minas de (1, 1) y (2, 3).
test(minas_alrededor_de_2_2, true(N == 2)) :-
    minas_alrededor(2, 2, N).

test(minas_alrededor_de_3_3, true(N == 2)) :-
    minas_alrededor(3, 3, N).

test(ninguna_mina_cerca, true(N == 0)) :-
    minas_alrededor(1, 5, N).

:- end_tests(buscaminas).
