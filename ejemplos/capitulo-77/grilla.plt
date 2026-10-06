:- encoding(utf8).

:- begin_tests(grilla).

%!  quieto(+Ps:list, +K, -Accion, -K) is det.
%
%   Un agente que sale enseguida.
quieto(_, K, salir, K).

%!  guion(+Ps:list, +Acciones0:list, -Accion, -Acciones:list) is det.
%
%   Un agente que ejecuta las acciones de una lista, una por turno.
guion(_, [A|As], A, As).

test(figura, [true(M == mundo(4, [3-1, 3-3, 4-4], 1-3, 2-3))]) :-
    mundo(figura_7_2, M).

test(mostrar, [true(S == ". . . P\nW O P .\n. . . .\n. . P .\n")]) :-
    mundo(figura_7_2, M),
    with_output_to(string(S), mostrar(M)).

test(sembrado_reproducible, [true(M1 == M2)]) :-
    mundo_sembrado(3, M1),
    mundo_sembrado(3, M2).

% En 1000 mundos, la entrada nunca tiene pozo, wumpus ni oro, y la
% proporción de celdas con pozo es cercana a 1/5.
test(sembrados, [true(Proporcion =:= 0.2)]) :-
    findall(N,
            ( between(1, 1000, S),
              mundo_sembrado(S, mundo(4, Pozos, W, O)),
              \+ memberchk(1-1, Pozos),
              W \== 1-1,
              O \== 1-1,
              length(Pozos, N) ),
            Ns),
    length(Ns, 1000),
    sum_list(Ns, Total),
    Proporcion is round(Total / 15000 * 100) / 100.

test(vecinas, [true(Vs == [2-1, 1-2])]) :-
    findall(V, vecina(4, 1-1, V), Vs).

test(percepciones, [true(Ps == [hedor, brisa, brillo])]) :-
    mundo(figura_7_2, M),
    percepciones(M, e(2-3, no, si, vivo), Ps).

test(pared, [true(E-X == e(1-1, no, si, vivo)-[golpe])]) :-
    mundo(figura_7_2, M),
    actuar(M, ir(0-1), e(1-1, no, si, vivo), E, X, sigue).

test(no_vecina, [error(domain_error(celda_vecina, 3-3))]) :-
    mundo(figura_7_2, M),
    actuar(M, ir(3-3), e(1-1, no, si, vivo), _, _, _).

test(pozo, [true(F == murio(pozo))]) :-
    mundo(figura_7_2, M),
    actuar(M, ir(3-1), e(2-1, no, si, vivo), _, _, F).

test(grito, [true(E-X == e(1-1, no, no, muerto)-[grito])]) :-
    mundo(figura_7_2, M),
    actuar(M, disparar(norte), e(1-1, no, si, vivo), E, X, _).

test(fallo, [true(X == [])]) :-
    mundo(figura_7_2, M),
    actuar(M, disparar(este), e(1-1, no, si, vivo), _, X, _).

test(sin_flecha, [true(X == [])]) :-
    mundo(figura_7_2, M),
    actuar(M, disparar(norte), e(1-1, no, no, vivo), _, X, _).

test(linea, [true(L == [2-3, 3-3, 4-3])]) :-
    linea(4, 1-3, este, L).

test(salir, [true(F == final(salio(no), -1, [salir]))]) :-
    mundo(figura_7_2, M),
    simular(M, quieto, sin_conocimiento, 10, F).

test(guion, [true(F == final(salio(si), 992,
                             [ir(1-2), ir(2-2), ir(2-3), tomar, ir(2-2),
                              ir(1-2), ir(1-1), salir]))]) :-
    mundo(figura_7_2, M),
    simular(M, guion,
            [ir(1-2), ir(2-2), ir(2-3), tomar, ir(2-2), ir(1-2), ir(1-1),
             salir],
            20, F).

test(muerte, [true(F == final(murio(wumpus), -1002, [ir(1-2), ir(1-3)]))]) :-
    mundo(figura_7_2, M),
    simular(M, guion, [ir(1-2), ir(1-3)], 20, F).

test(limite, [true(F == final(limite, -2, [tomar, tomar]))]) :-
    mundo(figura_7_2, M),
    simular(M, guion, [tomar, tomar, tomar], 2, F).

test(percibe_hedor) :-
    grilla:percibe(hedor, 4, 1-2, [], 1-3, 4-4, no).

test(percibe_sin_brisa, [fail]) :-
    grilla:percibe(brisa, 4, 1-2, [3-1], 1-3, 4-4, no).

:- end_tests(grilla).
