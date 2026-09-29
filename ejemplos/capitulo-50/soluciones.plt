:- encoding(utf8).

:- begin_tests(soluciones).

test(ejercicio_1, [true(E == a(0) - a(2) - w(1) * (a(1) - a(3)))]) :-
    evaluar([0, 1, 2, 3], 3, 4, E0),
    simplificar_raices(4, E0, E).

test(ejercicio_2, [true(P-I == [0, 3]-[1, 2])]) :-
    alternar_mal([0, 1, 2, 3], P, I).

test(ejercicio_3, [true(S-P == 56-14)]) :-
    tdf_ingenua(8, Es0),
    maplist(simplificar_raices(8), Es0, Es),
    grafo(Es, Ns, _),
    contar_nodos(Ns, _, S, P).

test(ejercicio_4, [true(C == 3)]) :-
    fft_grafo(8, Ns, _),
    productos_por(Ns, 2, C).

test(ejercicio_4_sin_raiz, [true(C == 0)]) :-
    fft_grafo(8, Ns, _),
    productos_por(Ns, 7, C).

test(ejercicio_4_no_triviales, [true(Cs == [2, 10, 34])]) :-
    maplist(productos_no_triviales, [8, 16, 32], Cs).

test(ejercicio_5, [true(Ps == [2, 3, 2, 3])]) :-
    fft_grafo(4, Ns, Ss),
    maplist(profundidad(Ns), Ss, Ps).

test(ejercicio_5_maximas, [true(Ps-Qs == [3, 5, 7]-[4, 8, 16])]) :-
    findall(P, ( member(N, [4, 8, 16]),
                 fft_grafo(N, Ns, Ss),
                 profundidad_maxima(Ns, Ss, P) ), Ps),
    findall(Q, ( member(N, [4, 8, 16]),
                 tdf_ingenua(N, Es0),
                 maplist(simplificar_raices(N), Es0, Es),
                 grafo(Es, Ns, Ss),
                 profundidad_maxima(Ns, Ss, Q) ), Qs).

test(ejercicio_5_hoja, [true(P == 0)]) :-
    profundidad([nodo(1, a(0))], 1, P).

test(ejercicio_5_ausente, [fail]) :-
    profundidad([nodo(1, a(0))], 2, _).

test(ejercicio_8, [forall(member(N, [2, 4, 8, 16, 32]))]) :-
    fft_arboles(N, Es0),
    maplist(simplificar_raices(N), Es0, Es),
    grafo(Es, G1, S1),
    grafo_rapido(Es, G2, S2),
    assertion(G1 == G2),
    assertion(S1 == S2).

test(ejercicio_9, [true(Vs == [c(10, 0), c(-2, -2), c(-2, 0), c(-2, 2)])]) :-
    fft_grafo(4, Ns, Ss),
    valor_grafo_exacto(4, [1, 2, 3, 4], Ns, Ss, Vs).

test(ejercicio_9_orden, [error(domain_error(orden_exacto, 8))]) :-
    raiz_exacta(8, 1, _).

test(ejercicio_10, [forall(member(N, [1, 2, 4, 8, 16]))]) :-
    numlist(1, N, Cs),
    fft_numerica(Cs, Xs),
    fft_inversa(Xs, As),
    maplist([C, c(C, 0)]>>true, Cs, Esperados),
    cercanos(As, Esperados).

test(ejercicio_11, [true(R == [4, 13, 22, 15])]) :-
    producto_polinomios([1, 2, 3], [4, 5], R).

test(ejercicio_11_potencia, [true(R == [1, 4, 6, 4, 1])]) :-
    producto_polinomios([1, 2, 1], [1, 2, 1], R).

% Ejercicio 12: dos claves con variables libres unifican.
test(ejercicio_12, [true(V1 == V2)]) :-
    buscar(op(+, _, _), D, V1),
    buscar(op(-, _, _), D, _),
    buscar(op(+, _, _), D, V2).

:- end_tests(soluciones).
