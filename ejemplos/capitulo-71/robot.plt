:- encoding(utf8).

:- begin_tests(robot).

test(inicial, [true(N == 10)]) :-
    findall(H, dado(strips1, H), Hs),
    length(Hs, N).

test(conecta_en_los_dos_sentidos, [nondet]) :-
    siempre(conecta(puerta(2), habitacion(5), habitacion(2))),
    siempre(conecta(puerta(2), habitacion(2), habitacion(5))).

test(puerta_en_dos_habitaciones,
     [true(Rs == [habitacion(3), habitacion(5)])]) :-
    findall(R, siempre(en_habitacion(puerta(3), R)), Rs0),
    msort(Rs0, Rs).

test(puntos, [true(N == 6)]) :-
    findall(P, siempre(punto_en(P, _)), Ps),
    length(Ps, N).

test(empujar_agrega, [true(Hs == [junto(caja(1), caja(2)),
                                  junto(caja(2), caja(1))])]) :-
    findall(H, agrega(H, empujar(caja(1), caja(2), habitacion(1))), Hs0),
    msort(Hs0, Hs).

% El robot sigue junto a la caja que empuja.
test(conserva, [fail]) :-
    borra(junto(robot, caja(1)), empujar(caja(1), caja(2), habitacion(1))).

test(caminar_aleja, [nondet]) :-
    borra(junto(robot, caja(1)), ir_a(punto(4), habitacion(1))).

test(caja_movida, [nondet]) :-
    borra(junto(caja(3), caja(1)), empujar(caja(1), caja(2), habitacion(1))).

test(subir, [true(Hs == [en_el_piso])]) :-
    findall(H, ( member(H, [en_el_piso, junto(robot, caja(1))]),
                 borra(H, subir(caja(1))) ),
            Hs).

test(imposible, [nondet]) :-
    imposible([en(X, Y), en(X, Z), distinto(Y, Z)]).

test(une, [all(D-R == [puerta(1)-habitacion(1), puerta(2)-habitacion(2),
                       puerta(3)-habitacion(3), puerta(4)-habitacion(4)])]) :-
    robot:une(D, R, habitacion(5)).

test(une_pasillo_segundo, [fail]) :-
    robot:une(_, habitacion(5), _).

test(movido_empujar, [all(X == [robot, caja(1)])]) :-
    robot:movido(X, empujar(caja(1), caja(2), habitacion(1))).

test(movido_encender, [fail]) :-
    robot:movido(_, encender(interruptor(1))).

test(conserva_subir, [all(H == [junto(robot, caja(1)),
                                junto(caja(1), robot)])]) :-
    robot:conserva(H, subir(caja(1))).

test(conserva_otra_caja, [fail]) :-
    robot:conserva(junto(robot, caja(2)), empujar(caja(1), caja(2),
                                                  habitacion(1))).

test(puede_subir, [true(Pre == [junto(robot, caja(1)), en_el_piso])]) :-
    puede(subir(caja(1)), Pre).

test(prueba) :-
    prueba(distinto(a, b)).

test(siempre_puntos, [all(P == [punto(1), punto(2), punto(3), punto(4),
                                punto(5)])]) :-
    siempre(punto_en(P, habitacion(1))).

:- end_tests(robot).
