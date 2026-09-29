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

:- end_tests(resolvente).
