:- encoding(utf8).

:- begin_tests(cueva).

%!  con_entrada(+Texto:string, +Semilla:integer, -Salida:string) is det.
%
%   Juega una partida con Semilla y las órdenes de Texto; Salida es todo lo
%   que se escribió.
con_entrada(Texto, Semilla, Salida) :-
    setup_call_cleanup(
        open_string(Texto, In),
        with_output_to(string(Salida), partida(In, Semilla)),
        close(In)).

% La cueva es un dodecaedro: 20 salas, tres túneles cada una, en los dos
% sentidos, 30 túneles en total, y el ciclo más corto tiene cinco salas.
test(salas, [true(N == 20)]) :-
    aggregate_all(count, sala(_), N).

test(tres_tuneles, [true(Malas == [])]) :-
    findall(S,
            ( sala(S),
              \+ aggregate_all(count, tunel(S, _), 3) ),
            Malas).

test(simetrica, [true(Malas == [])]) :-
    findall(A-B, ( tunel(A, B), \+ tunel(B, A) ), Malas).

test(aristas, [true(N == 30)]) :-
    aggregate_all(count, ( tunel(A, B), A < B ), N).

test(sin_triangulos, [fail]) :-
    tunel(A, B),
    tunel(B, C),
    tunel(C, A).

test(sin_cuadrados, [fail]) :-
    tunel(A, B),
    tunel(B, C),
    C \== A,
    tunel(C, D),
    D \== B,
    tunel(D, A).

test(pentagono, [nondet]) :-
    tunel(1, B),
    tunel(B, C),
    tunel(C, D),
    tunel(D, E),
    tunel(E, 1),
    sort([1, B, C, D, E], Ss),
    length(Ss, 5).

test(nueva, [true(N == 6)]) :-
    nueva_partida(7, j(J, W, Pozos, Murcielagos, 5, _)),
    append([[J, W], Pozos, Murcielagos], Salas),
    sort(Salas, Distintas),
    length(Distintas, N).

test(observacion, [true(O == obs(5, [1, 4, 6], [murcielagos], 5))]) :-
    nueva_partida(7, E),
    observacion(E, O).

test(avisos, [true(As == [corriente, murcielagos, wumpus])]) :-
    observacion(j(1, 2, [5, 11], [8, 12], 5, 0), obs(_, _, As, _)).

test(sin_tunel, [true(R-Ms-E == sigue-[sin_tunel(3)]-E0)]) :-
    E0 = j(1, 20, [11, 12], [13, 14], 5, 0),
    jugada(mover(3), E0, E, R, Ms).

test(mover, [true(E == j(2, 20, [11, 12], [13, 14], 5, 0))]) :-
    jugada(mover(2), j(1, 20, [11, 12], [13, 14], 5, 0), E, sigue, []).

test(pozo, [true(R-Ms == pierde(pozo)-[caes_en_pozo])]) :-
    jugada(mover(2), j(1, 20, [2, 12], [13, 14], 5, 0), _, R, Ms).

% Los murciélagos llevan al jugador a una sala al azar, donde vuelve a
% entrar.
test(murcielagos, [true(Ms = [murcielagos(_)|_])]) :-
    jugada(mover(2), j(1, 20, [11, 12], [2, 14], 5, 0), E, _, Ms),
    E = j(J, _, _, _, _, _),
    J \== 2.

test(acierta, [true(R-F == gana-4)]) :-
    jugada(disparar([2, 3]), j(1, 3, [11, 12], [13, 14], 5, 0),
           j(_, _, _, _, F, _), R, [acertaste]).

% La ruta vuelve a la sala del jugador.
test(propia_flecha, [true(R == pierde(flecha))]) :-
    jugada(disparar([2, 1]), j(1, 20, [11, 12], [13, 14], 5, 0), _, R, _).

test(sin_flechas, [true(Ms == [fallaste, sin_flechas])]) :-
    jugada(disparar([2]), j(1, 20, [11, 12], [13, 14], 1, 0), _, R, Ms),
    R == pierde(sin_flechas).

test(ruta_larga, [true(Ms == [ruta_invalida])]) :-
    jugada(disparar([2, 3, 4, 5, 6, 7]), j(1, 20, [], [], 5, 0), _, _, Ms).

% Al despertar, el wumpus se mueve en tres de cada cuatro semillas.
test(despertar, [true(N-M == 400-299)]) :-
    findall(W,
            ( between(1, 400, A),
              jugada(disparar([2]), j(1, 20, [], [], 5, A),
                     j(_, W, _, _, _, _), _, _) ),
            Ws),
    length(Ws, N),
    exclude(==(20), Ws, Movidos),
    length(Movidos, M).

test(orden, [true(Os == [mover(5), mover(5), disparar([2, 3]),
                         disparar([2])])]) :-
    findall(O,
            ( member(T, ["m 5", " mover  5 ", "d 2 3", "disparar 2"]),
              string_codes(T, Cs),
              once(phrase(orden(O), Cs)) ),
            Os).

test(orden_mal, [fail]) :-
    string_codes("saltar 3", Cs),
    phrase(orden(_), Cs).

test(texto, [true(T == Esperado)]) :-
    atomic_list_concat(
        [ "Estás en la sala 1. Hay túneles hacia las salas 2, 5 y 8.",
          "Sientes una corriente de aire."
        ], '\n', A),
    atom_string(A, Esperado),
    mensaje_texto(obs(1, [2, 5, 8], [corriente], 5), T).

test(partida, [true(sub_string(S, _, _, _, "Pierdes"))]) :-
    con_entrada("m 4\nm 5\nm 6\nm 16\n", 7, S).

test(partida_gana, [true(sub_string(S, _, _, _, "Ganas"))]) :-
    con_entrada("m 4\nd 3\n", 7, S).

test(partida_orden_mal, [true(sub_string(S, _, _, _, "No entiendo"))]) :-
    con_entrada("hola\n", 7, S).

test(despertar_semilla, [true(W-A == 2-12345)]) :-
    cueva:despertar(1, W, 0, A).

test(vuelo_wumpus, [true(I == wumpus)]) :-
    cueva:vuelo([4, 3], 5, 5, 3, 0, _, I).

test(vuelo_jugador, [true(I == jugador)]) :-
    cueva:vuelo([4, 5], 5, 5, 3, 0, _, I).

test(vuelo_vacio, [true(A-I == 0-nada)]) :-
    cueva:vuelo([], 5, 5, 3, 0, A, I).

:- end_tests(cueva).
