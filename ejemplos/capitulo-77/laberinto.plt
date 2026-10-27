:- encoding(utf8).

:- begin_tests(laberinto).

test(csenki, [true(N == 12)]) :-
    laberinto(csenki, Filas),
    length(Filas, N).

test(salida, [true(C-Co == [g(1, 2), g(2, 7), g(3, 2), g(4, 5), g(5, 2),
                            g(6, 13), g(7, 15), g(8, 7), g(9, 4), g(10, 3),
                            g(11, 3), g(12, 5)]-54)]) :-
    salida(csenki, C, Co, _).

test(heuristicas, [true(Cs == [54, 54, 54, 54, 54, 54])]) :-
    findall(Co,
            ( member(A, [a_estrella, ida_estrella]),
              member(H, [cero, euclidea, vuelo]),
              salida_con(A, H, csenki, _, Co, _) ),
            Cs).

test(expandidos, [true(Ks == [25, 20, 20])]) :-
    findall(K,
            ( member(H, [cero, euclidea, vuelo]),
              salida_con(a_estrella, H, csenki, _, _, K) ),
            Ks).

test(euclidea, [true(E =:= sqrt(15**2 + 4**2))]) :-
    laberinto(csenki, Fs),
    laberinto:estimacion(euclidea, Fs, g(3, 17), g(7, 2), E).

test(vuelo, [true(abs(H - 17.1327) < 0.0001)]) :-
    laberinto(csenki, Fs),
    laberinto:estimacion(vuelo, Fs, g(3, 17), g(7, 2), H).

test(estimacion_orden) :-
    forall(member(G, [g(1, 2), g(4, 8), g(9, 18)]),
           ( estimacion(euclidea, csenki, G, E),
             estimacion(vuelo, csenki, G, V),
             E =< V )).

test(sembrado, [true(Filas == Filas2)]) :-
    sembrado(1, 8, 40, 4, Filas),
    sembrado(1, 8, 40, 4, Filas2).

test(sembrado_forma, [true(L-P1-PN == 8-1-1)]) :-
    sembrado(1, 8, 40, 4, Filas),
    length(Filas, L),
    Filas = [F1|_],
    last(Filas, FN),
    length(F1, P1),
    length(FN, PN).

test(sembrado_salida, [true(Co-K == 131-94)]) :-
    salida(sembrado(1, 30, 40, 4), _, Co, K).

test(mostrar, [true(L == "  1 -*------------------")]) :-
    with_output_to(string(S), mostrar_laberinto(csenki, [g(1, 2)])),
    split_string(S, "\n", "", Ls),
    nth1(12, Ls, L).

:- end_tests(laberinto).
