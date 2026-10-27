:- encoding(utf8).

:- use_module(partida).

:- begin_tests(terminal).

%!  jugar_con(+Partida, +Jugadas:string, -Estado, -Lineas:list(string)) is det.
%
%   Juega Partida leyendo Jugadas; Lineas es lo que escribió.
jugar_con(Partida, Jugadas, Estado, Lineas) :-
    setup_call_cleanup(
        open_string(Jugadas, In),
        with_output_to(string(S), jugar_en_terminal(In, Partida, Estado)),
        close(In)),
    split_string(S, "\n", "", Lineas).

test(jugadas, true(J == [jugar(descubrir, 3-4), jugar(marcar, 10-2),
                         sugerencia])) :-
    maplist([T, X]>>( string_codes(T, Cs), once(phrase(jugada(X), Cs)) ),
            ["d 3 4", " m 10 2 ", "?"], J).

test(ganar, true(E == gano)) :-
    partida_con_minas(3, 3, [1-1], P),
    jugar_con(P, "d 3 3\n", E, _).

% Una jugada que no se entiende, una fuera del tablero y una sugerencia no
% terminan la partida.
test(perder, true(E == perdio)) :-
    partida_con_minas(4, 4, [1-1, 3-3], P),
    jugar_con(P, "hola\nd 1 4\n?\nd 9 9\nd 1 1\n", E, Lineas),
    once(( member(L, Lineas), sub_string(L, _, _, _, "no válida") )),
    once(( member(L2, Lineas), sub_string(L2, _, _, _, "Sugerencia: d 3 2") )),
    once(( member(L3, Lineas), sub_string(L3, _, _, _, "fuera del tablero") )).

test(fin_de_la_entrada, error(existence_error(jugada, fin_de_la_entrada))) :-
    partida_con_minas(3, 3, [1-1], P),
    jugar_con(P, "", _, _).

:- end_tests(terminal).
