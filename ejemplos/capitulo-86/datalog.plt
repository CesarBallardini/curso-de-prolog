:- encoding(utf8).

:- begin_tests(datalog).

test(nilsson, [true(Cs == [ (edge(a, b) :- true), (edge(b, a) :- true) ])]) :-
    clausulas(nilsson, Todas),
    include([C]>>(C = (_ :- true)), Todas, Cs).

test(fila, [true(N == 5)]) :-
    clausulas(fila(3), Cs),
    length(Cs, N).

test(modelo, [true(C == costo(3, 6))]) :-
    modelo(nilsson, M, C),
    memberchk(path(a, a), M).

test(consulta, [true(Rs == [path(a, a), path(a, b)])]) :-
    consulta(nilsson, path(a, _), Rs, _).

test(consulta_magica, [true(D == 41)]) :-
    consulta_magica(cadena(40), camino(0, _), _, costo(_, D)).

% Con la recursión a la derecha, la magia no reduce el trabajo.
test(fila_magica, [true(D-D1 == 820-860)]) :-
    consulta(fila(40), camino(0, _), Rs, costo(_, D)),
    consulta_magica(fila(40), camino(0, _), Rs, costo(_, D1)).

test(agregar_a, [true(C-N == costo(2, 41)-902)]) :-
    agregar_a(cadena(40), [arco(40, 41)], C, M),
    length(M, N).

test(mostrar_magico, [true(S == "m_path_bf(a).\n")]) :-
    with_output_to(string(T), mostrar_magico(nilsson, path(a, _))),
    sub_string(T, 0, 14, _, S).

:- end_tests(datalog).
