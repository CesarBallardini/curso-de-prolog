:- encoding(utf8).

:- begin_tests(krk).

test(dos_reglas, [true(Rs == [borde, resto])]) :-
    findall(R, regla(R, _), Rs).

test(seis_consejos, [true(N == 6)]) :-
    aggregate_all(count, consejo(_, _, _, _, _), N).

test(mueve, [true(B-N == nosotros-ellos)]) :-
    mueve(pos(blancas, 1-1, 2-2, 8-8), B),
    mueve(pos(negras, 1-1, 2-2, 8-8), N).

% La torre en c6 confina al rey negro en d8 al rectángulo d7-h8: 5 x 2.
test(espacio, [true(E == 10)]) :-
    espacio(pos(blancas, 5-5, 3-6, 4-8), E).

test(espacio_sin_confinar, [true(E == 64)]) :-
    espacio(pos(negras, 5-5, 3-6, 3-8), E).

test(casilla_critica, [true(C == 4-7)]) :-
    casilla_critica(pos(blancas, 5-5, 3-6, 4-8), C).

test(torre_perdida) :-
    torre_perdida(pos(negras, 8-8, 3-3, 4-4)).

test(torre_defendida, [fail]) :-
    torre_perdida(pos(negras, 4-3, 3-3, 4-4)).

test(torre_capturada) :-
    torre_perdida(pos(blancas, 8-8, capturada, 4-4)).

test(torre_expuesta) :-
    torre_expuesta(pos(blancas, 8-8, 3-3, 5-5)).

% El rey blanco está más cerca de la torre que el rey negro.
test(torre_no_expuesta, [fail]) :-
    torre_expuesta(pos(blancas, 5-3, 3-3, 3-6)).

test(torre_divide) :-
    meta(torre_divide, pos(blancas, 5-5, 3-6, 4-8), _).

test(patron_l) :-
    meta(patron_l, pos(blancas, 1-6, 3-7, 1-8), _).

test(espacio_menor) :-
    meta(espacio_menor, pos(negras, 5-5, 3-7, 4-8),
         pos(blancas, 5-5, 3-6, 4-8)).

test(acerca_casilla_critica) :-
    meta(acerca_casilla_critica, pos(negras, 5-6, 3-6, 4-8),
         pos(blancas, 5-5, 3-6, 4-8)).

test(rey_no_se_aleja, [fail]) :-
    meta(rey_no_se_aleja, pos(negras, 6-5, 3-6, 4-8),
         pos(blancas, 5-5, 3-6, 4-8)).

test(bordes, [true(B == [si, no])]) :-
    findall(X,
            ( member(P, [pos(blancas, 1-5, 3-6, 4-8),
                         pos(blancas, 5-5, 3-6, 4-7)]),
              (   meta(rey_blanco_en_borde, P, _)
              ->  X = si
              ;   X = no
              ) ),
            B).

test(reyes_cerca, [fail]) :-
    meta(reyes_cerca, pos(blancas, 1-1, 3-6, 5-5), _).

test(mueven_negras) :-
    meta(mueven_negras, pos(negras, 1-1, 3-6, 5-5), _).

test(mate_y_ahogado, [true(R == [mate, ahogado])]) :-
    findall(M,
            ( member(M-P, [mate-pos(negras, 2-3, 8-1, 1-1),
                           ahogado-pos(negras, 1-3, 2-8, 1-1)]),
              meta(M, P, P) ),
            R).

test(rey_diagonal_primero, [true(J == rey(5-5, 6-6))]) :-
    once(jugadas(rey_diagonal_primero, pos(blancas, 5-5, 3-6, 4-8), J, _)).

test(solo_torre, [true(Fs == [torre])]) :-
    findall(F,
            ( jugadas(torre, pos(blancas, 5-5, 3-6, 4-8), J, _),
              functor(J, F, _) ),
            Fs0),
    sort(Fs0, Fs).

test(jaque_con_torre, [true(Js == [torre(3-6, 3-8), torre(3-6, 4-6)])]) :-
    findall(J, jugadas(jaque_con_torre, pos(blancas, 5-5, 3-6, 4-8), J, _),
            Js0),
    msort(Js0, Js).

test(ninguna, [fail]) :-
    jugadas(ninguna, pos(negras, 5-5, 3-6, 4-8), _, _).

:- end_tests(krk).
