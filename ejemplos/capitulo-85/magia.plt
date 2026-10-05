:- encoding(utf8).

:- use_module(semantica38).

:- begin_tests(magia).

% nilsson(-Cs): el programa del ejemplo 15.1 de Nilsson y Małuszyński.
nilsson([ (edge(a, b) :- true), (edge(b, a) :- true),
          (path(X, Y) :- edge(X, Y)),
          (path(X, Y) :- path(X, Z), edge(Z, Y)) ]).

test(adorno, [true(As == [bf, fb, bb, ff])]) :-
    findall(A, ( member(M, [p(a, _), p(_, b), p(a, b), p(_, _)]),
                 adorno(M, [], A) ), As).

test(adorno_ligadas, [true(A == bbf)]) :-
    adorno(p(X, a, Y), [X], A),
    ignore(Y = Y).

test(magico, [true(P =@= [ (edge(a, b) :- true), (edge(b, a) :- true),
                           (m_path_bf(a) :- true),
                           (path_bf(X, Y) :- m_path_bf(X), edge(X, Y)),
                           (path_bf(X1, Y1) :- m_path_bf(X1),
                                               path_bf(X1, Z1),
                                               edge(Z1, Y1)),
                           (m_path_bf(X2) :- m_path_bf(X2)) ])]) :-
    nilsson(Cs),
    magico(Cs, path(a, _), P).

test(respuestas, [true(Rs-C == [path(a, a), path(a, b)]-costo(3, 6))]) :-
    nilsson(Cs),
    respuestas(Cs, path(a, _), Rs, C).

test(respuestas_magicas, [true(Rs == [path(a, a), path(a, b)])]) :-
    nilsson(Cs),
    respuestas_magicas(Cs, path(a, _), Rs, _).

% Sobre la fila de 40 arcos, la consulta por los caminos desde 0 deriva
% 41 átomos en lugar de 820.
test(cadena, [true(D-D1 == 820-41)]) :-
    clausulas(cadena(40), Cs),
    respuestas(Cs, camino(0, _), Rs, costo(_, D)),
    respuestas_magicas(Cs, camino(0, _), Rs1, costo(_, D1)),
    Rs == Rs1.

% Con el segundo argumento ligado y la recursión a la izquierda, el
% literal recursivo queda con los dos argumentos libres.
test(cadena_al_reves, [true(D == 862)]) :-
    clausulas(cadena(40), Cs),
    respuestas_magicas(Cs, camino(_, 40), Rs, costo(_, D)),
    length(Rs, 40).

% Un predicado usado negado se evalúa completo, con sus reglas originales.
test(negacion, [true(Rs == [inalcanzable(d, a), inalcanzable(d, b),
                            inalcanzable(d, c), inalcanzable(d, d)])]) :-
    clausulas(grafo, Cs),
    respuestas_magicas(Cs, inalcanzable(d, _), Rs, _),
    respuestas(Cs, inalcanzable(d, _), Rs1, _),
    Rs == Rs1.

test(negacion_completa) :-
    clausulas(grafo, Cs),
    magico(Cs, inalcanzable(d, _), P),
    memberchk((camino(_, _) :- camino(_, _), arco(_, _)), P).

test(sin_reglas, [error(domain_error(predicado_con_reglas, arco/2))]) :-
    clausulas(caminos, Cs),
    magico(Cs, arco(a, _), _).

% El mismo resultado con todos los argumentos ligados y con ninguno.
test(adornos_extremos, [forall(member(M, [camino(a, d), camino(_, _),
                                         camino(d, _)]))]) :-
    clausulas(caminos, Cs),
    respuestas(Cs, M, Rs, _),
    respuestas_magicas(Cs, M, Rs1, _),
    Rs == Rs1.

:- end_tests(magia).
