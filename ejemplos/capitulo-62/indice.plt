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

test(clave_de, [true(Cs == [libre, a, 3, '[|]'/2, f/1, []])]) :-
    maplist(indice:clave_de, ['$v'(0), a, 3, [x], f(y), []], Cs).

test(compatibles, [true]) :-
    indice:compatibles(libre, f/1),
    indice:compatibles(a, libre),
    indice:compatibles(f/1, f/1).

test(incompatibles, [fail]) :-
    indice:compatibles(a, f/1).

% siguiente/4 salta las cláusulas incompatibles antes y después de la
% elegida; sin otra compatible, lo que queda es [].
test(siguiente, [true(C-Ps == c2-[libre-c4])]) :-
    indice:siguiente([[]-c1, '[|]'/2-c2, []-c3, libre-c4], '[|]'/2, C, Ps).

test(siguiente_ultima, [true(C-Ps == c1-[])]) :-
    indice:siguiente([[]-c1, '[|]'/2-c2], [], C, Ps).

test(siguiente_ninguna, [fail]) :-
    indice:siguiente([[]-c1, a-c2], b, _, _).

test(saltar, [true(Ps == [a-c2])]) :-
    indice:saltar([b-c1, a-c2], a, Ps).

test(saltar_vacia, [true(Ps == [])]) :-
    indice:saltar([b-c1], a, Ps).

:- end_tests(indice).
