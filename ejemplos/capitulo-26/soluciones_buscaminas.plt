:- encoding(utf8).

:- begin_tests(soluciones_buscaminas).

% Con la semilla fija, el resultado se conoce de antemano.
test(semilla_fija, [ setup(set_random(seed(42))),
                     true(M == [2-3, 3-2, 3-4, 5-1]) ]) :-
    minas_al_azar(5, 5, 4, M).

% La misma semilla da el mismo tablero dos veces.
test(reproducible, true(T1 == T2)) :-
    set_random(seed(7)),
    tablero_al_azar(6, 6, 5, T1),
    set_random(seed(7)),
    tablero_al_azar(6, 6, 5, T2).

% Propiedades que valen para cualquier semilla: la cantidad de minas, y que
% cada número cuenta las minas vecinas.
test(cantidad_de_minas, [forall(between(1, 20, S)), true(N == 10)]) :-
    set_random(seed(S)),
    tablero_al_azar(9, 9, 10, tablero(_, _, Celdas)),
    assoc_to_values(Celdas, Vs),
    aggregate_all(count, member(mina, Vs), N).

test(numeros_correctos, [forall(between(1, 20, S)), fail]) :-
    set_random(seed(S)),
    tablero_al_azar(6, 6, 6, T),
    valor(T, F-C, N),
    integer(N),
    aggregate_all(count, ( vecina(6, 6, F-C, V), valor(T, V, mina) ), M),
    M =\= N.

:- end_tests(soluciones_buscaminas).
