:- encoding(utf8).

:- begin_tests(soluciones).

test(techo_sussman, [true(P == [mover(c, a, mesa), mover(b, mesa, c),
                                mover(a, mesa, b)])]) :-
    once(planificar_techo(cubos, sussman, [sobre(b, c), sobre(a, b)], 6, P)).

test(techo_robot, [true(L == 10)]) :-
    once(planificar_techo(robot, strips1,
                          [estado(interruptor(1), encendido),
                           en(robot, punto(6))], 12, P)),
    length(P, L).

test(estado_final, [true(E == [libre(a), sobre(a, b), sobre(b, c),
                               sobre(c, mesa)])]) :-
    estado_final(cubos, sussman, [mover(c, a, mesa), mover(b, mesa, c),
                                  mover(a, mesa, b)], E).

test(estado_robot, [true(N == 10)]) :-
    estado_final(robot, strips1, [ir_a(punto(4), habitacion(1))], E),
    length(E, N).

test(orden_robot, [true(L1-L2 == 10-10)]) :-
    once(planificar(robot, strips1, [en(robot, punto(6)),
                                     estado(interruptor(1), encendido)],
                    10, P1)),
    once(planificar(robot, strips1, [estado(interruptor(1), encendido),
                                     en(robot, punto(6))],
                    10, P2)),
    length(P1, L1),
    length(P2, L2).

:- end_tests(soluciones).
