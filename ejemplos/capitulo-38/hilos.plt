:- encoding(utf8).

:- begin_tests(hilos).

% Las ligaduras que la meta hace en el otro hilo no vuelven.
test(sin_ligaduras, [true(E-V == true-libre)]) :-
    ejecutar(X = 1, E),
    (   var(X)
    ->  V = libre
    ;   V = ligada
    ).

test(estados, [true(Es = [true, false, exception(error(Formal, _))])]) :-
    en_paralelo([true, fail, _ is 1 / 0], Es),
    Formal = evaluation_error(zero_divisor).

% Cien hilos que escriben en la base de datos: el hilo principal ve todos
% los hechos, cualquiera sea el orden en que los hilos terminaron.
test(base_compartida, [ cleanup(retractall(user:visto(_))),
                        true(Vistos == L) ]) :-
    retractall(user:visto(_)),
    numlist(1, 100, L),
    maplist([I, assertz(visto(I))]>>true, L, Metas),
    en_paralelo(Metas, Es),
    assertion(maplist(==(true), Es)),
    findall(V, user:visto(V), Vs),
    msort(Vs, Vistos).

test(nombres, [ cleanup(retractall(user:visto(_))),
                true(P-O == main-trabajador) ]) :-
    nombres(P, O).

test(global, [true(Formal == existence_error(variable, clave))]) :-
    global_en_hilo(exception(error(Formal, _))).

:- end_tests(hilos).
