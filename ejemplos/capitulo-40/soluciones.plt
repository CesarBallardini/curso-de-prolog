:- encoding(utf8).

:- begin_tests(soluciones).

test(rio, [true(P-C == [cruzar(cabra), cruzar(solo), cruzar(lobo),
                        cruzar(cabra), cruzar(col), cruzar(solo),
                        cruzar(cabra)]-7)]) :-
    buscar(anchura, rio, P, C, _).

% Ningún estado del plan deja a la cabra sola con el lobo o con la col.
test(rio_seguro, [true]) :-
    buscar(anchura, rio, P, _, _),
    foldl(paso(rio), P, r(i, i, i, i), r(d, d, d, d)).

test(misioneros, [true(C == 11)]) :-
    buscar(anchura, misioneros, _, C, _).

test(misioneros_a_salvo, [fail]) :-
    a_salvo(1, 2).

test(anchura_lista, [true(P-K == [llenar(2), pasar(2, 1), llenar(2),
                                  pasar(2, 1)]-9)]) :-
    buscar(anchura_lista, jarras(4, 3, 2), P, _, K).

test(caballo, [true(N-U == 25-25)]) :-
    once(recorrido_caballo(5, R)),
    length(R, N),
    sort(R, S),
    length(S, U).

test(caballo_saltos, [true]) :-
    once(recorrido_caballo(5, R)),
    saltos_validos(R).

test(caballo_cuatro, [fail]) :-
    recorrido_caballo(4, _).

test(mas_cortos, [true(Ps == [[llenar(2), pasar(2, 1), llenar(2),
                               pasar(2, 1)]])]) :-
    mas_cortos(jarras(4, 3, 2), Ps).

test(mas_cortos_rio, [true(N == 2)]) :-
    mas_cortos(rio, Ps),
    length(Ps, N).

paso(Problema, Accion, E0, E) :-
    once(sucesor(Problema, E0, Accion, E, _)).

saltos_validos([A|R]) :-
    saltos_desde(R, A).

saltos_desde([], _).
saltos_desde([B|R], A) :-
    once(salto(A, B)),
    saltos_desde(R, B).

% Los auxiliares del ejercicio 3 y del 4.
test(pasajeros, [all(Q-S == [solo-r(d, i, i, i), lobo-r(d, d, i, i),
                             cabra-r(d, i, d, i), col-r(d, i, i, d)])]) :-
    pasajero(Q, r(i, i, i, i), d, S).

test(segura) :-
    assertion(\+ segura(r(d, i, i, d))),
    assertion(segura(r(i, d, i, d))).

test(a_salvo) :-
    assertion(\+ a_salvo(1, 2)),
    assertion(a_salvo(0, 3)),
    assertion(a_salvo(2, 2)).

:- end_tests(soluciones).
