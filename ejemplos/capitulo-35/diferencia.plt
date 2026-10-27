:- encoding(utf8).

:- begin_tests(diferencia).

test(concatenar, true(L == [a, b, c])) :-
    concatenar_dif([a, b|X]-X, [c|Y]-Y, L-[]).

% El resultado sigue siendo una lista diferencia: se puede seguir agregando.
test(concatenar_abierta, true(L == [a, b, c, d])) :-
    concatenar_dif([a|X]-X, [b|Y]-Y, D1),
    concatenar_dif(D1, [c, d|Z]-Z, L-[]).

test(concatenar_vacia, true(L == [a])) :-
    vacia_dif(V),
    concatenar_dif(V, [a|X]-X, L-[]).

% Sin verificación de ocurrencias, vacia_dif/1 acepta un término cíclico.
test(vacia_ciclica, true(cyclic_term(T))) :-
    vacia_dif([a|T]-T).

test(vacia_con_ocurrencias, [fail]) :-
    unify_with_occurs_check([a|T]-T, L-L).

% Una lista diferencia se usa una sola vez: su final ya quedó ligado.
test(dos_veces, [fail]) :-
    D = [a|_]-_,
    concatenar_dif(D, [b|Y]-Y, _),
    concatenar_dif(D, [c|Z]-Z, _).

arbol(n(n(vacio, 1, vacio), 2, n(vacio, 3, n(vacio, 4, vacio)))).

test(inorden_app, true(L == [1, 2, 3, 4])) :-
    arbol(A),
    inorden_app(A, L).

test(inorden, true(L == [1, 2, 3, 4])) :-
    arbol(A),
    inorden(A, L).

test(inorden_vacio, true(L == [])) :-
    inorden(vacio, L).

test(inorden_dif_abierta, true(L-F == [1, 2|F]-F)) :-
    inorden_dif(n(vacio, 1, n(vacio, 2, vacio)), L-F).

test(degenerado, true(A == n(n(n(vacio, 1, vacio), 2, vacio), 3, vacio))) :-
    degenerado(3, A).

test(degenerado_iguales, true(L1 == L2)) :-
    degenerado(200, A),
    inorden_app(A, L1),
    inorden(A, L2).

test(invertir_app, true(L == [c, b, a])) :-
    invertir_app([a, b, c], L).

test(invertir, true(L == [c, b, a])) :-
    invertir([a, b, c], L).

test(invertir_vacia, true(L == [])) :-
    invertir([], L).

% Las versiones con listas diferencia usan una cantidad lineal de
% inferencias; las de append/3, cuadrática.
test(costo_lineal, true(I < 5000)) :-
    degenerado(1000, A),
    statistics(inferences, I0),
    inorden(A, _),
    statistics(inferences, I1),
    I is I1 - I0.

test(costo_cuadratico, true(I > 400000)) :-
    degenerado(1000, A),
    statistics(inferences, I0),
    inorden_app(A, _),
    statistics(inferences, I1),
    I is I1 - I0.

test(vacia_cerrada, true) :-
    vacia_dif([]-[]).

test(vacia_con_elemento, [fail]) :-
    vacia_dif([a]-[]).

test(invertir_dif_abierta, true(L-F == [b, a|F]-F)) :-
    invertir_dif([a, b], L-F).

:- end_tests(diferencia).
