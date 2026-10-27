:- encoding(utf8).

:- use_module(cubos, []).
:- use_module(robot, []).

:- begin_tests(ciclos).

test(sussman, [true(P == [mover(c, a, mesa), mover(b, mesa, c),
                          mover(a, mesa, b)])]) :-
    once(planificar_sin_ciclos(cubos, sussman, [sobre(a, b), sobre(b, c)],
                               P)).

test(figura, [true(P == [mover(c, a, mesa), mover(a, mesa, b),
                         mover(c, mesa, a)])]) :-
    once(planificar_sin_ciclos(cubos, sussman, [sobre(c, a), sobre(a, b)],
                               P)).

test(luz, [true(L == 4)]) :-
    once(planificar_sin_ciclos(robot, strips1,
                               [estado(interruptor(1), encendido)], P)),
    length(P, L).

test(logra, [true]) :-
    Metas = [sobre(c, a), sobre(a, b)],
    once(planificar_sin_ciclos(cubos, sussman, Metas, P)),
    regresion:logra(cubos, sussman, P, Metas).

% El árbol de búsqueda es finito, pero en el segundo orden de la anomalía
% no da un plan en dos millones de inferencias.
test(segundo_orden, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(
        once(planificar_sin_ciclos(cubos, sussman,
                                   [sobre(b, c), sobre(a, b)], _)),
        2000000, R).

test(inconsistente, [fail]) :-
    planificar_sin_ciclos(cubos, sussman, [sobre(a, b), sobre(a, c)], _).

% resolver/8 no elige una acción para una meta que ya está en la cadena.
test(resolver_cadena, [fail]) :-
    ciclos:resolver(cubos, sussman, libre(a), [libre(a)], [], _, [], _).

test(resolver_accion, [true(H == [mover(c, a, mesa)]), nondet]) :-
    ciclos:resolver(cubos, sussman, libre(a), [], [], _, [], H).

test(planear_vacio, [true(H == []), nondet]) :-
    ciclos:planear(cubos, sussman, [], [], [], _, [], H).

test(lograr, [true(H == [mover(c, a, mesa)]), nondet]) :-
    ciclos:lograr(cubos, sussman, libre(a), mover(c, a, mesa), [libre(a)],
                  [], [], H).

:- end_tests(ciclos).
