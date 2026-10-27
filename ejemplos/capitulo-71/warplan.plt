:- encoding(utf8).

:- begin_tests(warplan).

test(sussman, [true(P == [mover(c, a, mesa), mover(b, mesa, c),
                          mover(a, mesa, b)])]) :-
    once(planificar(cubos, sussman, [sobre(a, b), sobre(b, c)], 6, P)).

test(sussman_otro_orden, [true(P == [mover(c, a, mesa), mover(b, mesa, c),
                                     mover(a, mesa, b)])]) :-
    once(planificar(cubos, sussman, [sobre(b, c), sobre(a, b)], 6, P)).

test(figura, [true(P == [mover(c, a, mesa), mover(a, mesa, b),
                         mover(c, mesa, a)])]) :-
    once(planificar(cubos, sussman, [sobre(c, a), sobre(a, b)], 6, P)).

test(sin_cota, [true(P == [mover(c, a, mesa), mover(b, mesa, c),
                           mover(a, mesa, b)])]) :-
    once(planificar_sin_cota(cubos, sussman, [sobre(a, b), sobre(b, c)],
                             P)).

test(cada_plan_logra, [true]) :-
    forall(member(Metas, [[sobre(a, b), sobre(b, c)],
                          [sobre(b, c), sobre(a, b)],
                          [sobre(c, b), sobre(b, a)]]),
           ( once(planificar(cubos, sussman, Metas, 6, P)),
             regresion:logra(cubos, sussman, P, Metas) )).

test(regresar, [true(Ps == [libre(b), distinto(b, mesa), sobre(a, mesa),
                            distinto(a, b), libre(a), sobre(c, mesa)])]) :-
    regresar(cubos, [sobre(a, b), sobre(c, mesa)], mover(a, mesa, b), Ps).

test(luz, [true(P == [acercarse(caja(1), habitacion(1)),
                      empujar(caja(1), interruptor(1), habitacion(1)),
                      subir(caja(1)), encender(interruptor(1))])]) :-
    once(planificar(robot, strips1, [estado(interruptor(1), encendido)], 6,
                    P)).

test(punto6, [true(L == 5)]) :-
    once(planificar(robot, strips1, [en(robot, punto(6))], 6, P)),
    length(P, L).

test(cajas, [true(P == [acercarse(caja(1), habitacion(1)),
                        empujar(caja(1), caja(2), habitacion(1)),
                        acercarse(caja(3), habitacion(1)),
                        empujar(caja(3), caja(2), habitacion(1))])]) :-
    once(planificar(robot, strips1, [junto(caja(1), caja(2)),
                                     junto(caja(3), caja(2))], 6, P)).

test(dos_puntos, [fail]) :-
    planificar(robot, strips1, [en(robot, punto(1)), en(robot, punto(2))],
               6, _).

test(ya_esta, [true(P == []), nondet]) :-
    planificar(robot, strips1, [en(robot, punto(5))], 6, P).

test(robot_logra, [true]) :-
    Metas = [estado(interruptor(1), encendido), en(robot, punto(6))],
    once(planificar(robot, strips1, Metas, 10, P)),
    length(P, 10),
    regresion:logra(robot, strips1, P, Metas).

% lograr/9, segunda cláusula: mover(b, mesa, c) no puede ir al final de
% [mover(c, a, mesa), mover(a, mesa, b)] y se inserta antes de la última.
test(lograr_inserta, [true(H == [mover(a, mesa, b), mover(b, mesa, c),
                                 mover(c, a, mesa)])]) :-
    once(warplan:lograr(cubos, sussman, sobre(b, c), mover(b, mesa, c),
                        [sobre(a, b)], [mover(a, mesa, b), mover(c, a, mesa)],
                        H, 2, _)).

% regresar/4 con un protegido que la acción agrega: solo quedan las
% precondiciones.
test(regresar_agregado, [true(Ps == [sobre(c, a), distinto(a, mesa),
                                     libre(c)])]) :-
    regresar(cubos, [sobre(c, mesa)], mover(c, a, mesa), Ps).

:- end_tests(warplan).
