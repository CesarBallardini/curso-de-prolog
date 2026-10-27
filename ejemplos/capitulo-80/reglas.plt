:- encoding(utf8).

:- begin_tests(reglas).

% El rey negro en a1, en jaque por la torre en a8, solo puede ir a b1.
test(escape, [all(J == [rey(1-1, 2-1)])]) :-
    jugada(pos(negras, 3-3, 1-8, 1-1), J, _).

test(mate) :-
    mate(pos(negras, 2-3, 8-1, 1-1)).

% El rey blanco en c2 cubre b1 y b2, pero a2 queda libre: no es mate.
test(no_mate, [fail]) :-
    mate(pos(negras, 3-2, 8-1, 1-1)).

test(ahogado) :-
    ahogado(pos(negras, 1-3, 2-8, 1-1)).

test(ahogado_no_es_jaque, [fail]) :-
    jaque(pos(negras, 1-3, 2-8, 1-1)).

% El rey blanco tapa la línea de la torre.
test(jaque_tapado, [fail]) :-
    jaque(pos(negras, 1-4, 1-2, 1-8)).

test(jaque) :-
    jaque(pos(negras, 5-5, 1-8, 7-8)).

% Las negras capturan la torre que el rey blanco no defiende.
test(captura, [nondet, true(S == pos(blancas, 5-5, capturada, 2-2))]) :-
    jugada(pos(negras, 5-5, 2-2, 1-1), rey(1-1, 2-2), S).

% No pueden capturarla si el rey blanco la defiende.
test(torre_defendida, [fail]) :-
    jugada(pos(negras, 3-3, 2-2, 1-1), rey(1-1, 2-2), _).

% La torre no salta al rey blanco: desde a1, con el rey en a4, llega a a2 y
% a3 por la columna y a las siete casillas de b1 a h1 por la fila.
test(torre_no_salta, [true(N == 9)]) :-
    aggregate_all(count,
                  jugada(pos(blancas, 1-4, 1-1, 8-8), torre(_, _), _),
                  N).

% El rey blanco no se acerca al rey negro.
test(reyes_separados, [true(Ds == [])]) :-
    findall(A,
            ( jugada(pos(blancas, 3-3, 8-8, 1-1), rey(_, A), _),
              distancia(A, 1-1, 1) ),
            Ds).

test(diagonales_primero, [true(A == 4-4)]) :-
    once(jugada(pos(blancas, 3-3, 8-8, 1-8), rey(_, A), _)).

test(legal) :-
    legal(pos(blancas, 3-3, 8-2, 1-1)).

test(ilegal_reyes_juntos, [fail]) :-
    legal(pos(blancas, 2-2, 8-8, 1-1)).

test(ilegal_jaque_a_mover_blancas, [fail]) :-
    legal(pos(blancas, 3-3, 1-8, 1-1)).

test(ilegal_misma_casilla, [fail]) :-
    legal(pos(negras, 3-3, 1-1, 1-1)).

test(distancias, [true(D-M == 3-5)]) :-
    distancia(1-1, 4-3, D),
    manhattan(1-1, 4-3, M).

test(vecinas, [true(N == 3)]) :-
    aggregate_all(count, vecina(1-1, _), N).

test(ordenados) :-
    ordenados(5, 3, 1).

test(no_ordenados, [fail]) :-
    ordenados(1, 3, 3).

test(casilla, [true(C-N == 3-6-h1)]) :-
    casilla(c6, C),
    casilla(N, 8-1).

test(notacion, [true(Ts == ['Rc6', 'Th8'])]) :-
    notacion(rey(4-5, 3-6), T1),
    notacion(torre(1-8, 8-8), T2),
    Ts = [T1, T2].

test(filas, [true(F8-F1 == "8 . . . . . . . ."-"1 r . R . . . . T")]) :-
    filas(pos(blancas, 3-1, 8-1, 1-1), Fs),
    Fs = [F8|_],
    last(Fs, F1).

:- end_tests(reglas).
