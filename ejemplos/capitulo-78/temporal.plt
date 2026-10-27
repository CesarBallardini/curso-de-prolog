:- encoding(utf8).

:- begin_tests(temporal).

test(percibio, [true(Ps == [brisa])]) :-
    ejemplo_historia(figura_7_4, H),
    findall(P, percibio(H, P, 1), Ps).

test(percibio_nada, [fail]) :-
    ejemplo_historia(figura_7_4, H),
    percibio(H, _, 0).

test(hizo, [true(A == girar(derecha))]) :-
    ejemplo_historia(figura_7_4, H),
    hizo(H, A, 4).

test(hizo_despues, [fail]) :-
    ejemplo_historia(figura_7_4, H),
    hizo(H, _, 6).

test(inicial, [true(Fs == [en(1-1), mira(este), tiene_flecha, wumpus_vivo])]) :-
    ejemplo_historia(figura_7_4, H),
    findall(F, vale(H, F, 0), Fs).

test(final, [true(Fs == [en(1-2), mira(norte), tiene_flecha, wumpus_vivo])]) :-
    ejemplo_historia(figura_7_4, H),
    findall(F, vale(H, F, 6), Fs).

test(miradas, [true(Ds == [este, este, norte, oeste, oeste, norte, norte])]) :-
    ejemplo_historia(figura_7_4, H),
    findall(D, ( between(0, 6, T), vale(H, mira(D), T) ), Ds).

test(sin_flecha, [true(Fs == [en(1-2), mira(norte)])]) :-
    ejemplo_historia(disparo, H),
    findall(F, vale(H, F, 7), Fs).

test(sucesor, [nondet, true(C == 2-1)]) :-
    ejemplo_historia(figura_7_4, H),
    temporal:sucesor(en(C), H, 0, 1).

test(adelante, [true(Cs == [2-1, 0-1, 1-2, 1-0])]) :-
    findall(C, ( member(D, [este, oeste, norte, sur]),
                 adelante(1-1, D, C) ), Cs).

test(girar, [true(Ds == [norte, sur])]) :-
    findall(D, girar(_, este, D), Ds).

test(girar_vuelta) :-
    forall(member(D, [este, norte, oeste, sur]),
           ( girar(izquierda, D, D1),
             girar(derecha, D1, D2),
             D2 == D )).

test(conocimiento,
     [true(K == c(4, 1-2, [1-1-[], 2-1-[brisa], 1-2-[hedor]], no, si,
                  vivo([]), []))]) :-
    ejemplo_historia(figura_7_4, H),
    conocimiento_en(H, 6, K).

test(conocimiento_muerto,
     [true(F-W == no-muerto)]) :-
    ejemplo_historia(disparo, H),
    conocimiento_en(H, 7, c(_, _, _, _, F, W, _)).

test(visitar, [true(Vs == [1-1-[], 2-1-[brisa]])]) :-
    ejemplo_historia(figura_7_4, H),
    foldl(temporal:visitar(H), [0, 1, 2, 3, 4], [], Vs).

test(ok_segura) :-
    ejemplo_historia(figura_7_4, H),
    ok(H, 2-2, 6).

test(ok_wumpus, [fail]) :-
    ejemplo_historia(figura_7_4, H),
    ok(H, 1-3, 6).

test(ok_wumpus_muerto) :-
    ejemplo_historia(disparo, H),
    ok(H, 1-3, 7).

test(celdas_ok, [true(Cs1-Cs2 == [1-1, 1-2, 2-1, 2-2]-[1-1, 1-2, 1-3, 2-1, 2-2])]) :-
    ejemplo_historia(figura_7_4, H1),
    celdas_ok(H1, 6, Cs1),
    ejemplo_historia(disparo, H2),
    celdas_ok(H2, 7, Cs2).

test(trayectoria, [true(Cs == [1-1, 2-1, 2-1, 2-1, 1-1, 1-1, 1-2])]) :-
    ejemplo_historia(figura_7_4, H),
    trayectoria(H, Cs).

test(celda_en, [true(C == 1-1)]) :-
    ejemplo_historia(figura_7_4, H),
    temporal:celda_en(H, 4, C).

test(giros, [true(Gs == [[], [girar(izquierda)], [girar(derecha)],
                         [girar(izquierda), girar(izquierda)]])]) :-
    findall(G, ( member(D, [este, norte, sur, oeste]),
                 giros(este, D, G) ), Gs).

test(traducir,
     [true(As-Fin == [ girar(izquierda), avanzar, girar(izquierda),
                       girar(izquierda), avanzar, girar(izquierda),
                       disparar ]-p(1-1, este))]) :-
    traducir([ir(1-2), ir(1-1), disparar(este)], p(1-1, este), As, Fin).

test(traducir_lejos, [fail]) :-
    traducir([ir(3-3)], p(1-1, este), _, _).

test(paso, [true(As-R-P == [tomar|R]-R-p(2-3, sur))]) :-
    temporal:paso(tomar, p(2-3, sur), As, R, P).

% La historia de la figura 7.4 es la de la cueva de la figura 7.2.
test(historia, [true(H == E)]) :-
    mundo(figura_7_2, M),
    historia(M, [ avanzar, girar(izquierda), girar(izquierda), avanzar,
                  girar(derecha), avanzar ], H),
    ejemplo_historia(figura_7_4, E).

test(golpe, [true(H-Cs == h(4, [[], [], [golpe]], [girar(derecha), avanzar])-
                          [1-1, 1-1, 1-1])]) :-
    mundo(figura_7_2, M),
    historia(M, [girar(derecha), avanzar], H),
    trayectoria(H, Cs).

test(disparo, [true(H == E)]) :-
    mundo(figura_7_2, M),
    historia(M, [ avanzar, girar(izquierda), girar(izquierda), avanzar,
                  girar(derecha), avanzar, disparar ], H),
    ejemplo_historia(disparo, E).

% En (3, 1) hay un pozo: la historia se corta en la segunda acción.
test(muere, [true(Ps-As == [[], [brisa], []]-[avanzar, avanzar])]) :-
    mundo(figura_7_2, M),
    historia(M, [avanzar, avanzar, avanzar], h(_, Ps, As)).

% La partida de la versión 3, con las acciones del libro: la trayectoria
% que deduce el agente es la del simulador, y termina en (1, 1).
test(partida, [true(N-C == 18-(1-1))]) :-
    mundo(figura_7_2, M),
    jugar(M, final(_, _, Plan)),
    traducir(Plan, p(1-1, este), As, _),
    length(As, N),
    historia(M, As, H),
    trayectoria(H, Cs),
    last(Cs, C),
    findall(C1, ( member(ir(C1), Plan) ), Visitadas),
    forall(member(V, Visitadas), memberchk(V, Cs)).

test(ejecutar_girar, [true(E == s(1-1, norte, no, si, vivo))]) :-
    mundo(figura_7_2, M),
    temporal:ejecutar(girar(izquierda), M, s(1-1, este, no, si, vivo), E,
                      [], sigue).

test(percibir, [true(Ps == [brisa, golpe])]) :-
    mundo(figura_7_2, M),
    temporal:percibir(M, s(2-1, este, no, si, vivo), [golpe], Ps).

test(pasos, [true(Ps-As == [[]]-[girar(izquierda)])]) :-
    mundo(figura_7_2, M),
    temporal:pasos([girar(izquierda)], M, s(1-1, este, no, si, vivo),
                   Ps, As).

:- end_tests(temporal).
