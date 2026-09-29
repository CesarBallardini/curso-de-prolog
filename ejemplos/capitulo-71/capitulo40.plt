:- encoding(utf8).

:- begin_tests(capitulo40).

test(tres, [true(P-K == [a-c, a-b, c-b, a-c, b-a, b-c, a-c]-24)]) :-
    torres_en_anchura(3, P, K).

test(cinco, [true(L-K == 31-232)]) :-
    torres_en_anchura(5, P, K),
    length(P, L).

:- end_tests(capitulo40).
