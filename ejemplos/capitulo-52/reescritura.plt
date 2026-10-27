:- encoding(utf8).

:- begin_tests(reescritura).

test(intercambio, [true(R == fin([b, a, a, b]))]) :-
    markov(intercambio, [a, b, b, a], 100, R).

test(intercambio_vacia, [true(R == fin([]))]) :-
    markov(intercambio, [], 100, R).

test(ordenar, [true(R == fin([a, a, b, b]))]) :-
    markov(ordenar, [b, a, b, a], 100, R).

% Sin regla que se aplique, la palabra queda como está.
test(ordenada, [true(R == fin([a, b]))]) :-
    markov(ordenar, [a, b], 100, R).

test(limite, [true(R == limite([b, a, b, b, a, a]))]) :-
    markov(ordenar, [b, b, b, a, a, a], 2, R).

% Un paso por cada par b-a desordenado: con n b y n a, n² pasos.
test(pasos_ordenar, [forall(member(N, [1, 2, 3, 4])),
                     true(P =:= N * N)]) :-
    length(Bs, N),
    maplist(=(b), Bs),
    length(As, N),
    maplist(=(a), As),
    append(Bs, As, W),
    between(0, 100, P),
    markov(ordenar, W, P, fin(_)),
    !.

test(reemplazar, [true(W == [x, y, b, a])]) :-
    reemplazar([a], [x, y], [a, b, a], W).

test(reemplazar_vacia, [true(W == [#, a])]) :-
    reemplazar([], [#], [a], W).

test(reemplazar_ausente, [fail]) :-
    reemplazar([c], [x], [a, b], _).

test(palindromo, [forall(member(W, [[a, b, b, a], [a, b, a], [a], []])),
                  true(R == fin([s, i]))]) :-
    post(palindromo_p, W, 100, R).

test(no_palindromo, [true(R == fin([b, a]))]) :-
    post(palindromo_p, [a, b, a, a], 100, R).

test(post_limite, [true(R == limite([b, b]))]) :-
    post(palindromo_p, [a, b, b, a], 1, R).

test(coincidir, all(X-Y == [[a]-[c, b], [a, b, c]-[]])) :-
    coincidir([X, [b], Y], [a, b, c, b]).

test(coincidir_literal, [fail]) :-
    coincidir([[a]], [b]).

:- end_tests(reescritura).
