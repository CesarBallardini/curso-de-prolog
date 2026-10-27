:- encoding(utf8).

:- begin_tests(mariposa).

test(orden_cuatro, [true(Ns-Ss == [nodo(1, a(0)), nodo(2, a(2)),
                                   nodo(3, op(+, 1, 2)), nodo(4, a(1)),
                                   nodo(5, a(3)), nodo(6, op(+, 4, 5)),
                                   nodo(7, op(+, 3, 6)),
                                   nodo(8, op(-, 1, 2)), nodo(9, w(1)),
                                   nodo(10, op(-, 4, 5)),
                                   nodo(11, op(*, 9, 10)),
                                   nodo(12, op(+, 8, 11)),
                                   nodo(13, op(-, 3, 6)),
                                   nodo(14, op(-, 8, 11))]-[7, 12, 13, 14])]) :-
    fft_grafo(4, Ns, Ss).

% Las hojas de orden 8: los coeficientes y w(1), w(2) y w(3).
test(hojas_ocho, [true(Hojas == [a(0), a(1), a(2), a(3), a(4), a(5), a(6),
                                 a(7), w(1), w(2), w(3)])]) :-
    fft_grafo(8, Ns, _),
    findall(T, ( member(nodo(_, T), Ns), T \= op(_, _, _) ), Hojas0),
    msort(Hojas0, Hojas).

% N log2 N sumas y restas; N/2 log2 N productos menos los N - 1 por 1.
test(costo, [forall(member(N-L, [2-1, 4-2, 8-3, 16-4, 32-5]))]) :-
    fft_grafo(N, Ns, _),
    contar_nodos(Ns, _, S, P),
    assertion(S =:= N * L),
    assertion(P =:= N // 2 * L - (N - 1)).

test(como_definicion, [forall(member(N, [1, 2, 4, 8, 16, 32]))]) :-
    numlist(1, N, Cs0),
    maplist([X, c(X, -X)]>>true, Cs0, Cs),
    definicion(Cs, Vs),
    fft_numerica(Cs, Vs0),
    cercanos(Vs, Vs0).

test(orden_uno, [true(Ns-Ss == [nodo(1, a(0))]-[1])]) :-
    fft_grafo(1, Ns, Ss).

test(orden_dos, [true(Ns-Ss == [nodo(1, a(0)), nodo(2, a(1)),
                                nodo(3, op(+, 1, 2)),
                                nodo(4, op(-, 1, 2))]-[3, 4])]) :-
    fft_grafo(2, Ns, Ss).

test(un_coeficiente, [true(Vs == [c(5, 0)])]) :-
    fft_numerica([5], Vs).

test(no_potencia, [error(domain_error(potencia_de_dos, 3))]) :-
    fft_numerica([1, 2, 3], _).

:- end_tests(mariposa).
