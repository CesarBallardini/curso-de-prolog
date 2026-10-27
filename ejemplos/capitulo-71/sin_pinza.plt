:- encoding(utf8).

:- begin_tests(sin_pinza).

test(inicial, [true(N == 5)]) :-
    findall(H, dado(sussman, H), Hs),
    length(Hs, N).

% WARPLAN intercala: tres acciones.
test(warplan, [true(P == [mover(c, a, mesa), mover(b, mesa, c),
                          mover(a, mesa, b)])]) :-
    once(planificar(sin_pinza, sussman, [sobre(a, b), sobre(b, c)], 6, P)).

% Medios y fines no intercala: cuatro acciones.
test(medios_fines, [true(P == [mover(c, a, mesa), mover(b, mesa, a),
                               mover(b, a, c), mover(a, mesa, b)])]) :-
    medios_fines(sussman, [sobre(a, b), sobre(b, c)], P).

test(otro_orden, [true(L == 3)]) :-
    once(planificar(sin_pinza, sussman, [sobre(b, c), sobre(a, b)], 6, P)),
    length(P, L).

test(mismo_plan_que_cubos, [true(P1 == P2)]) :-
    once(planificar(sin_pinza, sussman, [sobre(a, b), sobre(b, c)], 6, P1)),
    once(planificar(cubos, sussman, [sobre(a, b), sobre(b, c)], 6, P2)).

:- end_tests(sin_pinza).
