:- encoding(utf8).

:- use_module('../../capitulo-31/buscaminas/partida').

:- begin_tests(buscaminas_pantalla).

%!  con_teclas(+Teclas:string, +Juego0, -Juego, -Salida:string) is det.
%
%   Juega Juego0 con las teclas escritas en Teclas; Salida es todo lo que
%   bucle/3 escribió.
con_teclas(Teclas, Juego0, Juego, Salida) :-
    setup_call_cleanup(
        open_string(Teclas, In),
        with_output_to(string(Salida), bucle(get_code(In), Juego0, Juego)),
        close(In)).

test(pantalla, true(L == ["┌─ Buscaminas ┐",
                          "│  #  #  #    │",
                          "│  # [#] #    │",
                          "│  #  #  #    │",
                          "└─────────────┘",
                          "┌─ Estado ────────────┐",
                          "│ Minas sin marcar: 1 │",
                          "│ En juego            │",
                          "└─────────────────────┘",
                          "Flechas: mover  Espacio: descubrir  m: marcar  \c
                           q: salir"])) :-
    partida_con_minas(3, 3, [1-1], P),
    pantalla(juego(P, 2-2, jugar), L).

test(cursor_en_el_borde, true(C == 1-1)) :-
    partida_con_minas(3, 3, [1-1], P),
    foldl(paso, [arriba, arriba, izquierda, izquierda], juego(P, 2-2, jugar),
          juego(_, C, _)).

test(marcar_y_descubrir, true(F-N == ["M##", "#1#", "###"]-0)) :-
    partida_con_minas(3, 3, [1-1], P0),
    foldl(paso, [arriba, izquierda, letra(m), derecha, abajo, espacio],
          juego(P0, 2-2, jugar), juego(P, _, _)),
    filas(P, false, F),
    minas_restantes(P, N).

test(ganar, true(E == gano)) :-
    partida_con_minas(3, 3, [1-1], P0),
    con_teclas("\e[B\e[B\e[C\e[C ", juego(P0, 1-1, jugar), juego(P, _, _),
               _),
    estado(P, E).

% La última pantalla dibujada muestra la mina bajo el cursor y el resultado.
test(perder, true(E == perdio)) :-
    partida_con_minas(3, 3, [1-1], P0),
    con_teclas(" ", juego(P0, 1-1, jugar), juego(P, _, _), Salida),
    estado(P, E),
    atomic_list_concat(Pantallas, '\e[2J', Salida),
    last(Pantallas, Ultima),
    once(sub_atom(Ultima, _, _, _, '[*]')),
    once(sub_atom(Ultima, _, _, _, 'Partida perdida')).

test(salir, true(S == salir)) :-
    partida_con_minas(3, 3, [1-1], P0),
    con_teclas("xq", juego(P0, 1-1, jugar), juego(_, _, S), _).

test(fin_de_la_entrada, true(S == salir)) :-
    partida_con_minas(3, 3, [1-1], P0),
    con_teclas("", juego(P0, 1-1, jugar), juego(_, _, S), _).

% Una tecla sin significado no cambia el juego.
test(otra_tecla, true(J == juego(P, 2-2, jugar))) :-
    partida_con_minas(3, 3, [1-1], P),
    paso(otra, juego(P, 2-2, jugar), J).

test(terminado_en_juego, [fail]) :-
    partida_con_minas(3, 3, [1-1], P),
    buscaminas_pantalla:terminado(juego(P, 1-1, jugar)).

test(cursor_en_el_otro_borde, true(C == 3-3)) :-
    partida_con_minas(3, 3, [1-1], P),
    foldl(paso, [abajo, abajo, derecha, derecha], juego(P, 2-2, jugar),
          juego(_, C, _)).

% La caja del estado dice cómo terminó la partida.
test(mensajes, true(M == ["│ Partida ganada      │",
                          "│ Partida abandonada  │"])) :-
    partida_con_minas(3, 3, [1-1], P0),
    paso(espacio, juego(P0, 3-3, jugar), Ganado),
    pantalla(Ganado, L1),
    nth1(8, L1, M1),
    pantalla(juego(P0, 1-1, salir), L2),
    nth1(8, L2, M2),
    M = [M1, M2].

:- end_tests(buscaminas_pantalla).
