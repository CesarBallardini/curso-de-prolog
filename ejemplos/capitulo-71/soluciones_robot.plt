:- encoding(utf8).

% Los planificadores se cargan sin importar nada: el mundo ya define
% predicados con los mismos nombres.
:- use_module(warplan, []).
:- use_module(extension, []).

:- begin_tests(soluciones_robot).

test(sin_empujar_hacia_el_robot, [fail]) :-
    puede(empujar(caja(1), robot, habitacion(1)), Pre),
    forall(member(distinto(X, Y), Pre), X \= Y).

test(planes, [true(N1-N2 == 6-0)]) :-
    aggregate_all(count,
                  ( warplan:planificar(robot, strips1, [en(robot, punto(5))],
                                       6, P),
                    memberchk(empujar(_, robot, _), P) ),
                  N1),
    aggregate_all(count,
                  ( warplan:planificar(robot2, strips1, [en(robot, punto(5))],
                                       6, P),
                    memberchk(empujar(_, robot, _), P) ),
                  N2).

test(luz, [true(L == 4)]) :-
    once(warplan:planificar(robot2, strips1,
                            [estado(interruptor(1), encendido)], 6, P)),
    length(P, L).

test(otra_habitacion,
     [true(P == [acercarse(caja(2), habitacion(1)),
                 empujar(caja(2), puerta(1), habitacion(1)),
                 empujar_por(caja(2), puerta(1), habitacion(1),
                             habitacion(5)),
                 empujar(caja(2), puerta(2), habitacion(5)),
                 empujar_por(caja(2), puerta(2), habitacion(5),
                             habitacion(2))])]) :-
    once(warplan:planificar_sin_cota(robot2, strips1,
                                     [en_habitacion(caja(2), habitacion(2))],
                                     P)).

test(logra, [true]) :-
    Metas = [en_habitacion(caja(2), habitacion(2))],
    once(warplan:planificar_sin_cota(robot2, strips1, Metas, P)),
    regresion:logra(robot2, strips1, P, Metas).

test(agrega_empujar_por,
     [all(H == [en_habitacion(caja(2), habitacion(5)),
                en_habitacion(robot, habitacion(5)),
                junto(robot, caja(2))])]) :-
    agrega(H, empujar_por(caja(2), puerta(1), habitacion(1), habitacion(5))).

test(agrega_heredado, [nondet]) :-
    agrega(estado(interruptor(1), encendido), encender(interruptor(1))).

test(borra_junto_puerta, [nondet]) :-
    borra(junto(caja(2), puerta(1)),
          empujar_por(caja(2), puerta(1), habitacion(1), habitacion(5))).

% El robot sigue junto a la caja que empuja por la puerta.
test(conserva_junto_robot, [fail]) :-
    borra(junto(robot, caja(2)),
          empujar_por(caja(2), puerta(1), habitacion(1), habitacion(5))).

test(borra_heredado, [nondet]) :-
    borra(en_el_piso, subir(caja(1))).

:- end_tests(soluciones_robot).
