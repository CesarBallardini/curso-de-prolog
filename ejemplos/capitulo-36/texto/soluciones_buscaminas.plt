:- encoding(utf8).

:- use_module('../../capitulo-31/buscaminas/partida').

:- begin_tests(soluciones_buscaminas).

test(al_lado, true(L == ["┌─ Buscaminas ┐  ┌─ Estado ────────────┐",
                         "│  #  #  #    │  │ Minas sin marcar: 1 │",
                         "│  # [#] #    │  │ En juego            │",
                         "│  #  #  #    │  └─────────────────────┘",
                         "└─────────────┘                         ",
                         "Flechas: mover  Espacio: descubrir  m: marcar  \c
                          q: salir"])) :-
    partida_con_minas(3, 3, [1-1], P),
    pantalla_al_lado(juego(P, 2-2, jugar), L).

test(sugerencia, true(C == 3-2)) :-
    partida_con_minas(4, 4, [1-1, 3-3], P0),
    jugar(descubrir, 1-4, P0, P),
    paso_con_sugerencia(letra(?), juego(P, 1-1, jugar), juego(_, C, _)).

test(sin_sugerencia, true(C == 2-2)) :-
    partida_con_minas(3, 3, [1-1], P),
    paso_con_sugerencia(letra(?), juego(P, 2-2, jugar), juego(_, C, _)).

test(otras_teclas, true(C == 1-2)) :-
    partida_con_minas(3, 3, [1-1], P),
    paso_con_sugerencia(derecha, juego(P, 1-1, jugar), juego(_, C, _)).

:- end_tests(soluciones_buscaminas).
