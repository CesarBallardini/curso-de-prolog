:- encoding(utf8).

:- begin_tests(soluciones_torre).

test(torre, [true(P == [desapilar(d, c), soltar(d), desapilar(c, b),
                        apilar(c, d), desapilar(b, a), apilar(b, c),
                        tomar(a), apilar(a, b)])]) :-
    torre(E),
    once(planificar(E, [sobre(a, b), sobre(b, c), sobre(c, d)], P)).

% El plan, aplicado desde la torre, deja las tres metas cumplidas.
test(torre_aplicada) :-
    torre(E),
    Metas = [sobre(a, b), sobre(b, c), sobre(c, d)],
    once(planificar(E, Metas, P)),
    foldl([A, S0, S]>>aplicar(S0, A, S), P, E, Final),
    assertion(forall(member(M, Metas), memberchk(M, Final))).

:- end_tests(soluciones_torre).
