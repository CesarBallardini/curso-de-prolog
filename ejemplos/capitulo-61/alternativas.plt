:- encoding(utf8).

:- use_module(programas).

:- begin_tests(alternativas).

test(antepasado, all(D == [ana, pedro, luis, eva])) :-
    resolver(familia, antepasado(juan, D)).

test(concatenar, [true(Rs =@= Ns)]) :-
    findall(concatenar(X, Y, [1, 2, 3]),
            resolver(listas, concatenar(X, Y, [1, 2, 3])), Rs),
    respuestas_nativas(listas, concatenar(_, _, [1, 2, 3]), Ns).

test(invertir, all(R == [[5, 4, 3, 2, 1]])) :-
    resolver(listas, invertir_hasta(5, R)).

test(pasos, [true(P-A == 810-2)]) :-
    medir(listas, suma_hasta(100, _), [pasos-P, respuestas-1,
                                       alternativas-A, copiado-_]).

% Duplicar la lista multiplica lo copiado por más de tres.
test(copiado, [true(C200 > 3 * C100)]) :-
    medir(listas, suma_hasta(100, _), [_, _, _, copiado-C100]),
    medir(listas, suma_hasta(200, _), [_, _, _, copiado-C200]).

:- end_tests(alternativas).
