:- encoding(utf8).

:- use_module(partida).

:- begin_tests(kalah).

%!  inicial6(-Tablero) is det.
%
%   El tablero de partida con seis piedras por hoyo.
inicial6(tablero([6, 6, 6, 6, 6, 6], 0, [6, 6, 6, 6, 6, 6], 0)).

test(sembrar, [true(U-T == 7-tablero([0, 7, 7, 7, 7, 7], 1,
                                     [6, 6, 6, 6, 6, 6], 0))]) :-
    inicial6(T0),
    sembrar(1, T0, U, T).

test(sembrar_al_rival, [true(U-T == 10-tablero([6, 6, 6, 0, 7, 7], 1,
                                               [7, 7, 7, 6, 6, 6], 0))]) :-
    inicial6(T0),
    sembrar(4, T0, U, T).

test(sembrar_vacio, [fail]) :-
    sembrar(1, tablero([0, 1, 1, 1, 1, 1], 0, [1, 1, 1, 1, 1, 1], 0), _, _).

% Trece piedras dan una vuelta entera: cada casilla recibe una, y la
% última vuelve al hoyo de partida.
test(vuelta, [true(U-T == 1-tablero([1, 1, 1, 1, 1, 1], 1,
                                    [1, 1, 1, 1, 1, 1], 0))]) :-
    sembrar(1, tablero([13, 0, 0, 0, 0, 0], 0, [0, 0, 0, 0, 0, 0], 0), U, T).

% Catorce piedras desde el hoyo 6 terminan en el kalah después de una
% vuelta: el jugador vuelve a sembrar.
test(vuelta_al_kalah, [true(U == 7)]) :-
    sembrar(6, tablero([0, 0, 0, 0, 0, 14], 0, [1, 1, 1, 1, 1, 1], 0), U, _).

test(capturar, [true(T == tablero([0, 0, 0, 0, 2, 2], 3, [5, 4, 1, 1, 0, 1], 0))]) :-
    capturar(2, tablero([0, 1, 0, 0, 2, 2], 1, [5, 4, 1, 1, 1, 1], 0), T).

test(no_captura_enfrente_vacio,
     [true(T == tablero([0, 1, 0, 0, 2, 2], 1, [5, 4, 1, 1, 0, 1], 0))]) :-
    capturar(2, tablero([0, 1, 0, 0, 2, 2], 1, [5, 4, 1, 1, 0, 1], 0), T).

test(no_captura_en_el_rival, [true(T == T0)]) :-
    inicial6(T0),
    capturar(9, T0, T).

test(barrer, [true(T == tablero([0, 0, 0, 0, 0, 0], 30,
                                [0, 0, 0, 0, 0, 0], 42))]) :-
    barrer(tablero([0, 0, 0, 0, 0, 0], 30, [2, 0, 0, 3, 0, 7], 30), T).

test(no_barrer, [true(T == T0)]) :-
    inicial6(T0),
    barrer(T0, T).

test(terminado) :-
    terminado(tablero([0, 0, 0, 0, 0, 0], 30, [0, 0, 0, 0, 0, 0], 42)).

test(no_terminado, [fail]) :-
    inicial6(T),
    terminado(T).

test(turnos, [true(Js == [[1, 2], [1, 3], [1, 4], [1, 5], [1, 6],
                         [2], [3], [4], [5], [6]])]) :-
    inicial6(T),
    findall(J, turno_completo(T, J, _), Js).

% El turno de la figura 21.3 de Sterling y Shapiro.
test(figura_21_3, [true(T == tablero([0, 7, 7, 0, 8, 8], 2,
                                     [7, 7, 7, 7, 6, 6], 0))]) :-
    inicial6(T0),
    turno_completo(T0, [1, 4], T).

test(turno_incompleto, [fail]) :-
    inicial6(T0),
    turno_completo(T0, [1], _).

test(girar, [true(T == tablero([1, 2, 3, 4, 5, 6], 9, [6, 5, 4, 3, 2, 1], 8))]) :-
    girar(tablero([6, 5, 4, 3, 2, 1], 8, [1, 2, 3, 4, 5, 6], 9), T).

test(kalahs, [true(S-N-S1-N1 == 8-9-9-8)]) :-
    T = tablero([0, 0, 0, 0, 0, 0], 8, [0, 0, 0, 0, 0, 0], 9),
    kalahs(T, sur, S, N),
    kalahs(T, norte, S1, N1).

test(jugada, [true(P == k(tablero([7, 7, 7, 7, 6, 6], 0,
                                  [0, 7, 7, 0, 8, 8], 2), norte))]) :-
    inicial(kalah(6), P0),
    jugada(kalah(6), P0, [1, 4], P).

test(fin_gana, [true(R == gana(sur))]) :-
    fin(kalah(6), k(tablero([1, 0, 0, 0, 0, 0], 30, [1, 1, 1, 0, 0, 1], 37),
                    norte), R).

test(fin_empate, [true(R == empate)]) :-
    fin(kalah(6), k(tablero([0, 0, 0, 0, 0, 0], 36, [0, 0, 0, 0, 0, 0], 36),
                    sur), R).

test(no_fin, [fail]) :-
    inicial(kalah(6), P),
    fin(kalah(6), P, _).

test(valor_final, [true(V == 107)]) :-
    capitulo41:valor_final(gana(sur),
                           k(tablero([1, 0, 0, 0, 0, 0], 30,
                                     [1, 1, 1, 0, 0, 1], 37), norte), V).

test(evaluar, [true(V == 3)]) :-
    capitulo41:evaluar(kalah(6),
                       k(tablero([1, 0, 0, 0, 0, 0], 5,
                                 [1, 1, 1, 0, 0, 1], 8), norte), V).

test(alfabeta, [true(Ns == [11, 26, 94, 225])]) :-
    inicial(kalah(6), P),
    findall(N, ( between(1, 4, D),
                 alfabeta(kalah(6), P, D, _, _, N) ),
            Ns).

% Una partida entera conserva las 72 piedras.
test(conserva, [true(Total == 72)]) :-
    inicial(kalah(6), P0),
    partida(kalah(6), P0, profundidad(2), primera, Js, _),
    foldl(aplicar, Js, P0, k(tablero(Ms, K, Ss, L), _)),
    sum_list(Ms, A),
    sum_list(Ss, B),
    Total is A + K + B + L.

%!  aplicar(+Jugada, +P0, -P) is det.
%
%   P es la posición de kalah(6) después de Jugada.
aplicar(Jugada, P0, P) :-
    once(jugada(kalah(6), P0, Jugada, P)).

%!  minimax(+Posicion, +D:integer, -Valor:integer) is det.
%
%   Valor es el valor minimax de Posicion en kalah(6) buscando D jugadas
%   hacia adelante, sin poda.
minimax(P, D, V) :-
    (   fin(kalah(6), P, R)
    ->  capitulo41:valor_final(R, P, V)
    ;   D =:= 0
    ->  capitulo41:evaluar(kalah(6), P, V)
    ;   capitulo41:turno(kalah(6), P, Lado),
        D1 is D - 1,
        findall(V1, ( jugada(kalah(6), P, _, P1),
                      minimax(P1, D1, V1) ),
                Vs),
        extremo(Lado, Vs, V)
    ).

% extremo(L, Vs, V): V es el mayor de Vs si L es max, el menor si es min.
extremo(max, Vs, V) :-
    max_list(Vs, V).
extremo(min, Vs, V) :-
    min_list(Vs, V).

% En las posiciones de una partida, una de cada tres, la poda da los valores
% de minimax sin poda con las profundidades 1 a 3.
test(igual_a_minimax, [true(Distintas == [])]) :-
    inicial(kalah(6), P0),
    partida(kalah(6), P0, profundidad(1), profundidad(1), Js, _),
    findall(K-D, ( nth0(K, Js, _), K mod 3 =:= 0,
                   length(Previas, K),
                   append(Previas, _, Js),
                   foldl(aplicar, Previas, P0, P),
                   between(1, 3, D),
                   minimax(P, D, V1),
                   alfabeta(kalah(6), P, D, _, V2, _),
                   V1 =\= V2 ),
            Distintas).

test(partida, [true(R == gana(sur))]) :-
    partida(kalah(6), profundidad(2), primera, _, R).

test(pantalla, [true(Ls == ["     6  6  6  6  6  6",
                            "  0                    0",
                            "     6  6  6  6  6  6",
                            "   (1)(2)(3)(4)(5)(6)"])]) :-
    inicial(kalah(6), P),
    partida:pantalla(kalah(6), P, Ls).

test(pantalla_norte, [true(L1-L2 == "     6  6  7  7  7  7"-"  0                    2")]) :-
    partida:pantalla(kalah(6), k(tablero([7, 7, 7, 7, 6, 6], 0,
                                         [0, 7, 7, 0, 8, 8], 2), norte),
                     [L1, L2|_]).

test(leer_jugada, [true(J == [1, 4])]) :-
    partida:leer_jugada(kalah(6), _, "1 4", J).

test(leer_mal, [fail]) :-
    partida:leer_jugada(kalah(6), _, "uno", _).

:- end_tests(kalah).
