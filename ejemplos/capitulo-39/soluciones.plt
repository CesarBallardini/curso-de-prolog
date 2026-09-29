:- encoding(utf8).

:- begin_tests(soluciones, [setup(abolish_all_tables)]).

test(camino_der, [setup(abolish_all_tables),
                  true(Ys-T == [a, b, c, d]-4)]) :-
    findall(Y, camino_der(a, Y), Ys0),
    msort(Ys0, Ys),
    tablas(T).

test(suma_hasta, [setup(abolish_all_tables), true(S-T == 5050-100)]) :-
    suma_hasta(100, S),
    tablas(T).

test(suma_hasta_cero, [fail]) :-
    suma_hasta(0, _).

test(formas, [true(N == 292)]) :-
    formas(100, [1, 5, 10, 25, 50], N).

test(formas_iguales, [forall(member(M, [0, 7, 30, 64])), true(N1 == N2)]) :-
    formas(M, [1, 5, 10, 25, 50], N1),
    formas_sin_tabla(M, [1, 5, 10, 25, 50], N2).

test(formas_imposible, [true(N == 0)]) :-
    formas(3, [2], N).

test(distancia_desde_b, [true(Ps == [a-8, b-11, c-9, d-5])]) :-
    findall(Y-D, distancia(b, Y, D), Ps0),
    msort(Ps0, Ps).

test(distancia_max_no_termina, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(distancia_max(a, b, _), 1000000, R).

% De a a b: un tramo, de longitud 4; el más corto tiene dos, y mide 3.
test(saltos, [true(N-D == 1-3)]) :-
    saltos(a, b, N),
    distancia(a, b, D).

test(saltos_todos, [true(Ps == [a-3, b-1, c-1, d-2])]) :-
    findall(Y-N, saltos(a, Y, N), Ps0),
    msort(Ps0, Ps).

test(mas_larga, [true(R == 9-[s, b, a, t])]) :-
    ruta_mas_larga(s, t, R).

test(j3, [true(Vs == [a-verdadero, b-falso, c-verdadero, d-falso,
                      e-falso])]) :-
    findall(X-V, ( member(X, [a, b, c, d, e]), valor(gana(j3, X), V) ), Vs).

test(j2_empate, [true(V == indefinido)]) :-
    valor(gana(j2, b), V).

test(pqr, [true(Vs == [indefinido, indefinido, indefinido])]) :-
    findall(V, ( member(A, [p, q, r]), valor(A, V) ), Vs).

test(r_prolog, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(catch(r_prolog, error(resource_error(_), _),
                                    true),
                              1000000, R).

:- end_tests(soluciones).
