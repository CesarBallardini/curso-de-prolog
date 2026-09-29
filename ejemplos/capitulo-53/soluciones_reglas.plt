:- encoding(utf8).

:- begin_tests(soluciones_reglas).

test(leer, [true(Ps == ["leyó", "leyeron", "lee", "creyó"])]) :-
    findall(P,
            ( member(A, [ verbo("leer", preterito, 3, singular),
                          verbo("leer", preterito, 3, plural),
                          verbo("leer", presente, 3, singular),
                          verbo("creer", preterito, 3, singular) ]),
              once(forma(P, A)) ),
            Ps).

% Sin una regla más, la primera persona del plural queda sin tilde.
test(leimos, [true(P == "leimos")]) :-
    once(forma(P, verbo("leer", preterito, 1, plural))).

test(leyeron, [true(As == [verbo("leer", preterito, 3, plural)])]) :-
    findall(A, forma("leyeron", A), As).

test(averigue, [true(As == [verbo("averiguar", preterito, 1, singular)])]) :-
    findall(A, forma("averigüé", A), As).

test(averiguo, [true(P == "averiguo")]) :-
    once(forma(P, verbo("averiguar", presente, 1, singular))).

% Las demás palabras no cambian.
test(sin_cambios, [true(Ps == ["vivieron", "sigues"])]) :-
    findall(P,
            ( member(A, [ verbo("vivir", preterito, 3, plural),
                          verbo("seguir", presente, 2, singular) ]),
              once(forma(P, A)) ),
            Ps).

test(version_2, [true(P == "leió")]) :-
    once(reglas:forma(P, verbo("leer", preterito, 3, singular))).

test(version_2_averiguar, [fail]) :-
    reglas:forma(_, verbo("averiguar", preterito, 1, singular)).

:- end_tests(soluciones_reglas).
