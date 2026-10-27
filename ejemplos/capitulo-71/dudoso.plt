:- encoding(utf8).

:- begin_tests(dudoso).

test(c_sobre_b, [true(Hs == [libre(a), libre(c), sobre(a, mesa),
                             sobre(b, mesa), sobre(c, b)])]) :-
    findall(H, dado(c_sobre_b, H), Hs0),
    msort(Hs0, Hs).

test(c_sobre_a, [true(Hs1 == Hs2)]) :-
    findall(H, dado(c_sobre_a, H), Hs1),
    findall(H, dado(sussman, H), Hs2).

test(reexporta, [nondet]) :-
    agrega(sobre(c, mesa), mover(c, b, mesa)).

:- end_tests(dudoso).
