:- encoding(utf8).

:- begin_tests(soluciones_pinza).

test(sussman, [true(P == [desapilar(c, a), soltar(c), tomar(b),
                          apilar(b, c), tomar(a), apilar(a, b)])]) :-
    once(planificar(pinza2, sussman, [sobre(a, b), sobre(b, c)], 6, P)).

test(inconsistente) :-
    extension:inconsistente(pinza2, [sostiene(a), mano_vacia], []).

test(consistente, [fail]) :-
    extension:inconsistente(pinza, [sostiene(a), mano_vacia], []).

test(mismo_plan, [true(P1 == P2)]) :-
    once(planificar(pinza, sussman, [sobre(b, a)], 6, P1)),
    once(planificar(pinza2, sussman, [sobre(b, a)], 6, P2)).

test(imposible, [true(N == 5)]) :-
    aggregate_all(count, imposible(_), N).

test(imposible_dos_lugares, [nondet]) :-
    imposible([sobre(X, Y), sobre(X, Z), distinto(Y, Z)]),
    var(X), var(Y), var(Z).

:- end_tests(soluciones_pinza).
