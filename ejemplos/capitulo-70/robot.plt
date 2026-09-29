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

:- end_tests(robot).
