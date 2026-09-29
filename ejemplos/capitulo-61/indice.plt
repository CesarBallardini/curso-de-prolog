:- encoding(utf8).

:- use_module(programas).

:- begin_tests(indice).

% La indexación separa [] de [_|_]: la respuesta no deja alternativas.
test(suma, [true(S == 6)]) :-
    resolver(listas, suma([1, 2, 3], S)).

test(medir, [true(I-E-T == 206-1-2)]) :-
    medir(listas, suma_hasta(100, _),
          [_, _, intentos-I, _, elecciones-E, rastro-T, _]).

test(longitud, [true(M-E == 101-1)]) :-
    medir(listas, longitud_hasta(100, _),
          [_, _, _, metas-M, elecciones-E, _, _]).

test(maximo, all(M == [4])) :-
    resolver(maximo, maximo(4, 3, M)).

test(nativas, [forall(member(N-Q, [ familia-antepasado(_, _),
                                     familia-abuelo(juan, _),
                                     listas-concatenar(_, _, [1, 2, 3]),
                                     listas-invertir_hasta(6, _),
                                     corte-primero(_, [x, y]),
                                     maximo-maximo(3, 3, _)
                                   ])),
               true(Rs =@= Ns)]) :-
    findall(Q, resolver(N, Q), Rs),
    respuestas_nativas(N, Q, Ns).

:- end_tests(indice).
