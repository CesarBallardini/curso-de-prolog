:- encoding(utf8).

:- begin_tests(soluciones_voseo).

test(sin_diptongo, [true(Ps == ["contás", "pensás", "pedís",
                                "elegís"])]) :-
    findall(P,
            ( member(L, ["contar", "pensar", "pedir", "elegir"]),
              once(forma(P, verbo(L, presente, vos, singular))) ),
            Ps).

test(tenes, [true(As == [verbo("tener", presente, vos, singular)])]) :-
    findall(A, forma("tenés", A), As).

test(sos, [true(As == [verbo("ser", presente, vos, singular)])]) :-
    findall(A, forma("sos", A), As).

test(fuiste, [true(N == 4)]) :-
    findall(A, forma("fuiste", A), As),
    length(As, N).

test(tuviste, [true(Ps == ["tuviste"])]) :-
    findall(P, forma(P, verbo("tener", preterito, vos, singular)), Ps).

:- end_tests(soluciones_voseo).
