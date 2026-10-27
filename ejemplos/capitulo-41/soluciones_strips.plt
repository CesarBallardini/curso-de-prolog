:- encoding(utf8).

:- begin_tests(soluciones_strips).

test(sussman, [true(P == [mover(c, a, mesa), mover(b, mesa, a),
                          mover(b, a, c), mover(a, mesa, b)])]) :-
    sussman(E),
    once(planificar(E, [sobre(a, b), sobre(b, c)], P)).

% El plan de tres acciones existe, y medios y fines no lo construye.
test(tres_acciones, [true]) :-
    sussman(E),
    foldl(paso, [mover(c, a, mesa), mover(b, mesa, c), mover(a, mesa, b)],
          E, F),
    ord_subset([sobre(a, b), sobre(b, c)], F).

test(sin_plan_de_tres, [fail]) :-
    sussman(E),
    length(P, 3),
    lograr(E, [sobre(a, b), sobre(b, c)], P, _).

test(a_la_mesa, [nondet,
                  true(E1 == [libre(a), libre(b), libre(c), sobre(a, mesa),
                              sobre(b, mesa), sobre(c, mesa)])]) :-
    sussman(E),
    aplicar(E, mover(c, a, mesa), E1).

paso(Accion, E0, E) :-
    once(aplicar(E0, Accion, E)).

:- end_tests(soluciones_strips).
