:- encoding(utf8).

:- begin_tests(visitados).

test(profundidad, [true(L-C-K == 6-17-7)]) :-
    buscar(profundidad, jarras(4, 3, 2), P, C, K),
    length(P, L).

test(anchura, [true(P-C-K == [llenar(2), pasar(2, 1), llenar(2),
                              pasar(2, 1)]-10-9)]) :-
    buscar(anchura, jarras(4, 3, 2), P, C, K).

test(costo, [true(C-K == 10-7)]) :-
    buscar(mejor(costo), jarras(4, 3, 2), _, C, K).

% En anchura, el plan con menos acciones; con costo uniforme, el que mueve
% menos agua.
test(menos_acciones_o_menos_agua, [true(LA-CA-LC-CC == 6-17-8-15)]) :-
    buscar(anchura, jarras(7, 2, 1), PA, CA, _),
    buscar(mejor(costo), jarras(7, 2, 1), PC, CC, _),
    length(PA, LA),
    length(PC, LC).

% Sin solución: con el registro de visitados, las tres estrategias fallan.
test(sin_solucion, [true(Ss == [])]) :-
    findall(S, ( member(S, [profundidad, anchura, mejor(costo)]),
                 buscar(S, jarras(4, 2, 1), _, _, _) ),
            Ss).

test(plan_valido, [true(E == j(2, 3))]) :-
    buscar(profundidad, jarras(4, 3, 2), P, _, _),
    foldl(aplicar(jarras(4, 3, 2)), P, j(0, 0), E).

test(rastro, [true(N == 54)]) :-
    aggregate_all(count, resolver_sin_ciclos(jarras(4, 3, 2), _), N).

test(rastro_sin_repetir, [nondet]) :-
    resolver_sin_ciclos(jarras(4, 3, 2), P),
    foldl(aplicar(jarras(4, 3, 2)), P, j(0, 0), _).

aplicar(Problema, Accion, E0, E) :-
    once(sucesor(Problema, E0, Accion, E, _)).

:- end_tests(visitados).
