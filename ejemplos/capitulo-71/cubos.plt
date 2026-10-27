:- encoding(utf8).

:- begin_tests(cubos).

test(inicial, [true(Hs == [libre(b), libre(c), sobre(a, mesa),
                           sobre(b, mesa), sobre(c, a)])]) :-
    findall(H, dado(sussman, H), Hs0),
    msort(Hs0, Hs).

test(agrega, [true(Hs == [libre(a), sobre(c, b)])]) :-
    findall(H, agrega(H, mover(c, a, b)), Hs0),
    msort(Hs0, Hs).

test(no_libera_la_mesa, [true(Hs == [sobre(b, a)])]) :-
    findall(H, agrega(H, mover(b, mesa, a)), Hs).

test(borra, [true(Hs =@= [sobre(c, _), libre(b)])]) :-
    findall(H, borra(H, mover(c, a, b)), Hs).

test(a_la_mesa, [true(Pre == [sobre(c, a), distinto(a, mesa), libre(c)])]) :-
    once(puede(mover(c, a, mesa), Pre)).

test(distinto) :-
    distinto(a, b).

test(distinto_libre, [fail]) :-
    distinto(_, b).

test(imposible, [nondet]) :-
    imposible([sobre(_, Y), libre(Y)]).

test(prueba) :-
    prueba(distinto(a, b)).

% En el mundo de los cubos ninguna acción deja hechos fijos.
test(siempre, [fail]) :-
    siempre(_).

:- end_tests(cubos).
