:- encoding(utf8).

:- begin_tests(grafo).

test(producto_comun, [true(Ns-Ss == [nodo(1, a), nodo(2, b), nodo(3, c),
                                     nodo(4, op(*, 2, 3)),
                                     nodo(5, op(+, 1, 4)), nodo(6, d),
                                     nodo(7, op(+, 6, 4))]-[5, 7])]) :-
    grafo([a + b * c, d + b * c], Ns, Ss).

test(cuadrado, [true(Ns-Ss == [nodo(1, a), nodo(2, b),
                               nodo(3, op(+, 1, 2)),
                               nodo(4, op(*, 3, 3))]-[4])]) :-
    grafo([(a + b) * (a + b)], Ns, Ss).

% Una variable unificaría con cualquier clave del diccionario.
test(con_variables, [error(instantiation_error)]) :-
    grafo([a + _], _, _).

% Las ocho salidas de orden 8: 64 nodos, como en Clause and Effect.
test(fft_ocho, [true(H-S-P == 16-24-24)]) :-
    fft_arboles(8, Es),
    grafo(Es, Ns, _),
    contar_nodos(Ns, H, S, P).

% Cada nodo aparece después de sus hijos.
test(orden, [forall(member(N, [2, 4, 8, 16]))]) :-
    fft_arboles(N, Es),
    grafo(Es, Ns, _),
    forall(member(nodo(Id, op(_, I, J)), Ns), ( I < Id, J < Id )).

test(como_definicion, [forall(member(N, [1, 2, 4, 8, 16, 32]))]) :-
    numlist(1, N, Cs),
    definicion(Cs, Vs),
    fft_arboles(N, Es),
    grafo(Es, Ns, Ss),
    valor_grafo(N, Cs, Ns, Ss, Vs0),
    cercanos(Vs, Vs0).

:- end_tests(grafo).
