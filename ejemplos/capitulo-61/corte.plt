:- encoding(utf8).

:- use_module(programas).

:- begin_tests(corte).

test(maximo, all(M == [4])) :-
    resolver(maximo, maximo(4, 3, M)).

test(maximo_segundo, all(M == [4])) :-
    resolver(maximo, maximo(3, 4, M)).

test(nativo, [true(Rs == Ns)]) :-
    findall(maximo(4, 3, M), resolver(maximo, maximo(4, 3, M)), Rs),
    respuestas_nativas(maximo, maximo(4, 3, _), Ns).

test(primero, all(X == [a])) :-
    resolver(corte, primero(X, [a, b, c])).

% Un corte en la consulta deja solo la primera respuesta.
test(consulta, all(X == [[]])) :-
    resolver(listas, (concatenar(X, _, [1, 2]), !)).

test(suma, all(S == [5050])) :-
    resolver(corte, suma_hasta(100, S)).

% Con los cortes, la pila y el rastro no crecen con la lista.
test(medir, [true(E-T == 1-1)]) :-
    medir(corte, suma_hasta(100, _),
          [_, _, _, _, elecciones-E, rastro-T, _]).

test(sin_cortes, all(D == [ana, pedro, luis, eva])) :-
    resolver(familia, antepasado(juan, D)).

:- end_tests(corte).
