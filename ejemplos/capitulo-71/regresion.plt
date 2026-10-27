:- encoding(utf8).

:- begin_tests(regresion).

test(despues_de_mover, [true(Hs == [libre(a), libre(b), libre(c),
                                    sobre(a, mesa), sobre(b, mesa),
                                    sobre(c, mesa)])]) :-
    findall(H, vale(cubos, sussman, H, [mover(c, a, mesa)]), Hs0),
    msort(Hs0, Hs).

test(borrado, [fail]) :-
    vale(cubos, sussman, sobre(c, a), [mover(c, a, mesa)]).

test(inicial, [nondet]) :-
    vale(cubos, sussman, sobre(c, a), []).

% La última acción va primero: b se mueve después de c.
test(dos_acciones, [true(X == c)]) :-
    once(vale(cubos, sussman, sobre(b, X),
              [mover(b, mesa, c), mover(c, a, mesa)])).

test(preservada) :-
    preservada(cubos, libre(b), mover(c, a, mesa)).

test(no_preservada, [fail]) :-
    preservada(cubos, libre(b), mover(c, a, b)).

% Una variable libre se toma como un objeto desconocido, distinto de b.
test(desconocido) :-
    preservada(cubos, libre(b), mover(c, a, _)).

test(no_liga, [true(var(W))]) :-
    preservada(cubos, libre(b), mover(c, a, W)).

test(sussman) :-
    logra(cubos, sussman, [mover(c, a, mesa), mover(b, mesa, c),
                           mover(a, mesa, b)],
          [sobre(a, b), sobre(b, c)]).

test(no_ejecutable, [fail]) :-
    ejecutable(cubos, sussman, [mover(a, mesa, b)]).

test(no_logra, [fail]) :-
    logra(cubos, sussman, [mover(c, a, mesa), mover(a, mesa, b)],
          [sobre(a, b), sobre(b, c)]).

test(es_prueba) :-
    es_prueba(cubos, distinto(_, _)).

:- end_tests(regresion).
