:- encoding(utf8).

:- begin_tests(wumpus, [ cleanup(reiniciar) ]).

test(percepciones_de_la_cueva, all(P == [brisa, hedor, brillo])) :-
    percepcion(2-3, P).

test(explorar, true(R == oro(2-3))) :-
    explorar(R).

test(recorrido, [ setup(explorar(_)),
                  true(L == [1-1, 2-1, 1-2, 2-2, 3-2, 2-3]) ]) :-
    recorrido(L).

% (2, 2) es segura aunque sus dos vecinas visitadas percibieron algo: la
% brisa de (2, 1) no descarta el wumpus, pero la falta de hedor sí.
test(segura_por_dos_vecinas, [ setup(( reiniciar,
                                        visitar(1-1),
                                        visitar(2-1),
                                        visitar(1-2) )) ]) :-
    segura(2-2).

test(pozo_no_descartado, [ setup(( reiniciar,
                                    visitar(1-1),
                                    visitar(2-1) )),
                           fail ]) :-
    segura(3-1).

% El agente nunca entra en una celda con pozo o con el wumpus.
test(nunca_en_peligro, [ setup(explorar(_)), fail ]) :-
    visitada(C),
    ( pozo(C) ; wumpus(C) ).

test(reiniciar, [ setup(explorar(_)), true(N == 0) ]) :-
    reiniciar,
    aggregate_all(count, visitada(_), N).

:- end_tests(wumpus).
