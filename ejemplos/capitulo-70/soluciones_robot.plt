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

:- end_tests(soluciones_robot).
