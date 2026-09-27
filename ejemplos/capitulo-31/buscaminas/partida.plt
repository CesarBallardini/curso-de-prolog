:- encoding(utf8).

:- begin_tests(partida).

test(ganar, true(E-F == gano-["*1.", "11.", "..."])) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(descubrir, 3-3, P0, P),
    estado(P, E),
    filas(P, true, F).

test(perder, true(E == perdio)) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(descubrir, 1-1, P0, P),
    estado(P, E).

test(marcar, true(F-N == ["M##", "###", "###"]-0)) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(marcar, 1-1, P0, P),
    filas(P, false, F),
    minas_restantes(P, N).

test(desmarcar, true(F == ["###", "###", "###"])) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(marcar, 1-1, P0, P1),
    jugar(marcar, 1-1, P1, P),
    filas(P, false, F).

test(fuera, error(domain_error(celda_del_tablero, 4-1))) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(descubrir, 4-1, P0, _).

test(terminada, error(domain_error(partida_en_curso, perdio))) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(descubrir, 1-1, P0, P1),
    jugar(descubrir, 2-2, P1, _).

test(accion, error(domain_error(accion, saltar))) :-
    partida_con_minas(3, 3, [1-1], P0),
    jugar(saltar, 1-1, P0, _).

test(sugerencia, true(S == 3-2)) :-
    partida_con_minas(4, 4, [1-1, 3-3], P0),
    jugar(descubrir, 1-4, P0, P),
    sugerencia(P, S).

test(sin_sugerencia, fail) :-
    partida_con_minas(3, 3, [1-1], P),
    sugerencia(P, _).

:- end_tests(partida).
