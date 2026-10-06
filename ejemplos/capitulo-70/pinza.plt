:- encoding(utf8).

:- begin_tests(pinza).

test(inicial, [true(N == 6)]) :-
    findall(H, dado(sussman, H), Hs),
    length(Hs, N).

test(agrega, [true(As == [soltar(c), apilar(c, a), apilar(c, b),
                          desapilar(a, c), desapilar(b, c)])]) :-
    findall(A, agrega(libre(c), A), As0),
    msort(As0, As).

test(borra, [nondet]) :-
    borra(mano_vacia, tomar(a)).

test(warplan, [true(P == [desapilar(c, a), soltar(c), tomar(b),
                          apilar(b, c), tomar(a), apilar(a, b)])]) :-
    once(planificar(pinza, sussman, [sobre(a, b), sobre(b, c)], 6, P)).

test(medios_fines, [true(P == [desapilar(c, a), soltar(c), tomar(b),
                               apilar(b, c), tomar(a), apilar(a, b)])]) :-
    medios_fines(sussman, [sobre(a, b), sobre(b, c)], P).

test(sin_intercalar, [fail]) :-
    planificar(pinza, sussman, [sobre(a, b), sobre(b, c)], 5, _).

test(logra, [true]) :-
    Metas = [sobre(b, a)],
    once(planificar(pinza, sussman, Metas, 6, P)),
    regresion:logra(pinza, sussman, P, Metas).

test(puede, [true(Pre == [sostiene(a), libre(b)])]) :-
    puede(apilar(a, b), Pre).

test(puede_todas, [true(N == 18)]) :-
    findall(A, puede(A, _), As),
    length(As, N).

:- end_tests(pinza).
