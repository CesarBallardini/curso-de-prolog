:- encoding(utf8).

:- use_module(programas).

:- begin_tests(sin_rastro).

test(antepasado, all(D == [ana, pedro, luis, eva])) :-
    resolver(familia, antepasado(juan, D)).

test(concatenar, [true(Rs =@= Ns)]) :-
    findall(concatenar(X, Y, [1, 2, 3]),
            resolver(listas, concatenar(X, Y, [1, 2, 3])), Rs),
    respuestas_nativas(listas, concatenar(_, _, [1, 2, 3]), Ns).

% Las mismas medidas que la versión 3, sin rastro.
test(medir, [true(M == [ respuestas-1, pasos-506, intentos-407, metas-4,
                         elecciones-101, rastro-0, celdas-914
                       ])]) :-
    medir(listas, suma_hasta(100, _), M).

:- end_tests(sin_rastro).
