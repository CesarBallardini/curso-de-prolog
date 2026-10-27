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

test(operacion, [true(Op-A-B == (+)-a-b)]) :-
    operacion(a + b, Op, A, B).

test(operacion_otra, [fail]) :-
    operacion(a / b, _, _, _).

test(operacion_hoja, [fail]) :-
    operacion(a, _, _, _).

test(contenido_operacion, [true(T == op(+, 1, 2))]) :-
    contenido(x + a, [x-1, a-2|_], T).

test(contenido_hoja, [true(T == x)]) :-
    contenido(x, [x-1|_], T).

% agregar/3 agrega una vez cada subexpresión distinta, hijos primero.
test(agregar, [true(Ns-Id == [nodo(1, a), nodo(2, b), nodo(3, op(*, 1, 2)),
                              nodo(4, op(+, 3, 3))]-4)]) :-
    agregar(D, a * b + a * b, Id),
    numerar(D, 1),
    nodos(D, D, Ns).

test(nodos_vacio, [true(Ns == [])]) :-
    nodos(_, [], Ns).

test(contar_nodos, [true(H-S-P == 3-1-1)]) :-
    grafo([a * b - c], Ns, _),
    contar_nodos(Ns, H, S, P).

test(contar_vacio, [true(H-S-P == 0-0-0)]) :-
    contar_nodos([], H, S, P).

test(listar_grafo, [true(Ls == ["n1 = a", "n2 = n1 + n1", ""])]) :-
    with_output_to(string(T),
                   listar_grafo([nodo(1, a), nodo(2, op(+, 1, 1))])),
    split_string(T, "\n", "", Ls).

test(valor_nodo_hoja, [true(V == c(7, 0))]) :-
    empty_assoc(T0),
    valor_nodo(4, [5, 7], nodo(1, a(1)), T0, T1),
    get_assoc(1, T1, V).

test(valor_nodo_operacion, [true(V == c(3, 0))]) :-
    list_to_assoc([1-c(1, 0), 2-c(2, 0)], T0),
    valor_nodo(4, [1, 2], nodo(3, op(+, 1, 2)), T0, T1),
    get_assoc(3, T1, V).

test(valor_grafo, [true(Vs == [c(-1, 0)])]) :-
    valor_grafo(2, [1, 2], [nodo(1, a(0)), nodo(2, a(1)),
                            nodo(3, op(-, 1, 2))], [3], Vs).

:- end_tests(grafo).
