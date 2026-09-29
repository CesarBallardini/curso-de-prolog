:- encoding(utf8).

:- begin_tests(agente).

%!  aima(-K) is det.
%
%   El conocimiento de la figura 7.4 de Russell y Norvig: (1, 1) sin
%   percepciones, brisa en (2, 1) y hedor en (1, 2).
aima(K) :-
    conocer(4, [1-1-[], 2-1-[brisa], 1-2-[hedor]], K).

test(frontera, [true(F == [1-3, 2-2, 3-1])]) :-
    aima(K),
    frontera(K, F).

test(pozos, [true(M == [[3-1]])]) :-
    aima(K),
    mundos_pozos(K, M).

test(wumpus, [true(W == [1-3])]) :-
    aima(K),
    posiciones_wumpus(K, W).

test(clasificar, [true(Cs == [visitada, segura, pozo, wumpus, desconocida])]) :-
    aima(K),
    maplist(clasificar(K), [2-1, 2-2, 3-1, 1-3, 4-4], Cs).

test(seguras, [true(S == [2-2])]) :-
    aima(K),
    seguras(K, S).

% Sin percepciones en (1, 1), sus dos vecinas son seguras.
test(inicio, [true(S == [1-2, 2-1])]) :-
    conocer(4, [1-1-[]], K),
    seguras(K, S).

test(registrar, [true(K == c(4, 1-1, [1-1-[brisa, hedor]], no, si,
                             vivo([]), []))]) :-
    conocimiento_inicial(4, K0),
    registrar([hedor, brisa, brillo], K0, K).

% Un disparo sin grito descarta las celdas de la línea.
test(fallo, [true(W == [2-1])]) :-
    conocer(4, [1-1-[hedor]], K0),
    K0 = c(N, C, Vs, O, F, vivo([]), _),
    siguiente(c(N, C, Vs, O, F, vivo([]), [disparar(norte)]), _, K1),
    registrar([hedor], K1, K),
    posiciones_wumpus(K, W).

test(grito, [true(W == [])]) :-
    conocer(4, [1-1-[hedor]], K0),
    registrar([grito], K0, K),
    posiciones_wumpus(K, W).

% El A* del capítulo 40 va a (1, 1); ruta/4 traslada las celdas.
test(ruta, [true(P == [ir(2-1), ir(2-2), ir(3-2)])]) :-
    ruta(1-1, 3-2, [1-1, 2-1, 2-2, 3-2], P).

test(ruta_imposible, [fail]) :-
    ruta(1-1, 3-3, [1-1, 3-3], _).

test(explorar, [true(D-P == (2-2)-[ir(2-2)])]) :-
    aima(K0),
    K0 = c(N, _, Vs, O, F, W, Plan),
    explorar(c(N, 2-1, Vs, O, F, W, Plan), D, P).

test(volver, [true(P == [ir(1-1)])]) :-
    aima(K),
    volver(K, P).

test(figura, [true(F == final(salio(si), 990,
                              [ir(1-2), ir(1-1), ir(2-1), ir(2-2), ir(2-3),
                               tomar, ir(2-2), ir(2-1), ir(1-1), salir]))]) :-
    mundo(figura_7_2, M),
    jugar(M, F).

% Sin celdas seguras, el agente prudente sale sin el oro.
test(prudente, [true(Fin == salio(no))]) :-
    mundo_sembrado(2, M),
    jugar(M, final(Fin, _, _)).

% El agente prudente nunca muere.
test(nunca_muere, [true(Muertes == [])]) :-
    findall(S,
            ( between(1, 40, S),
              mundo_sembrado(S, M),
              jugar(M, final(murio(_), _, _)) ),
            Muertes).

:- end_tests(agente).
