:- encoding(utf8).

:- begin_tests(extension).

test(una_accion, [true(P == [mover(c, a, b)]), nondet]) :-
    planificar(cubos, sussman, [sobre(c, b)], 4, P).

test(nada, [true(P == []), nondet]) :-
    planificar(cubos, sussman, [sobre(c, a)], 4, P).

% La anomalía de Sussman: cuatro acciones, con un rodeo.
test(sussman, [true(P == [mover(c, a, mesa), mover(b, mesa, a),
                          mover(b, a, c), mover(a, mesa, b)])]) :-
    once(planificar(cubos, sussman, [sobre(a, b), sobre(b, c)], 8, P)).

test(sussman_otro_orden, [true(L == 4)]) :-
    once(planificar(cubos, sussman, [sobre(b, c), sobre(a, b)], 8, P)),
    length(P, L).

% Con tres acciones no hay plan por extensión.
test(sin_intercalar, [fail]) :-
    planificar(cubos, sussman, [sobre(a, b), sobre(b, c)], 3, _).

test(inconsistente, [fail]) :-
    planificar(cubos, sussman, [sobre(a, b), sobre(a, c)], 8, _).

test(cada_plan_logra, [true]) :-
    Metas = [sobre(c, a), sobre(a, b)],
    once(planificar(cubos, sussman, Metas, 8, P)),
    regresion:logra(cubos, sussman, P, Metas).

test(gastar, [true(C == 2)]) :-
    gastar(3, C).

test(gastar_cero, [fail]) :-
    gastar(0, _).

test(sin_cota, [true(C == sin_cota)]) :-
    gastar(sin_cota, C).

test(proteger, [true(Ps == [libre(a)])]) :-
    proteger(libre(a), [libre(a)], Ps).

:- end_tests(extension).
