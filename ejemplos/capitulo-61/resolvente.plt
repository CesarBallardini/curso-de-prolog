:- encoding(utf8).

:- use_module(programas).

:- begin_tests(resolvente).

test(abuelo, all(N == [luis])) :-
    resolver(familia, abuelo(juan, N)).

test(concatenar, [true(Rs =@= Ns)]) :-
    findall(concatenar(X, Y, [1, 2, 3]),
            resolver(listas, concatenar(X, Y, [1, 2, 3])), Rs),
    respuestas_nativas(listas, concatenar(_, _, [1, 2, 3]), Ns).

test(suma, [true(S == 5050), nondet]) :-
    resolver(listas, suma_hasta(100, S)).

% El corte se ejecuta como true: la segunda respuesta es incorrecta.
test(maximo, all(M == [4, 3])) :-
    resolver(maximo, maximo(4, 3, M)).

% Un paso por cada clase de meta.
test(paso_conjuncion, all(Ms == [[a, b, c]])) :-
    resolvente:paso(conjuncion(a, b), [c], [], Ms).

test(paso_predefinida, all(Ms == [[c]])) :-
    resolvente:paso(predefinida(1 < 2), [c], [], Ms).

test(paso_predefinida_falla, [fail]) :-
    resolvente:paso(predefinida(2 < 1), [c], [], _).

% Una resolvente por cada cláusula, con variables propias.
test(paso_usuario, [true(Rs =@= [[true, c]-1, [q(Y), c]-Y])]) :-
    findall(Ms-X,
            resolvente:paso(usuario(p(X)), [c],
                            [(p(1) :- true), (p(Z) :- q(Z))], Ms),
            Rs).

test(resolver_metas, all(X == [1, 2])) :-
    resolvente:resolver_metas([p(X), X > 0],
                              [(p(1) :- true), (p(2) :- true), (p(0) :- true)]).

test(resolver_metas_vacia, [true]) :-
    resolvente:resolver_metas([], []).

:- end_tests(resolvente).
