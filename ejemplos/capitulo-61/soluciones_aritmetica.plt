:- encoding(utf8).

:- use_module(programas).

:- begin_tests(aritmetica).

test(codigo, [true(C == [ celda('$v'(0)), numero(2), celda('$v'(1)),
                          op(*), op(+)
                        ])]) :-
    codigo('$v'(0) + 2 * '$v'(1), C).

test(no_evaluable, [error(type_error(evaluable, _))]) :-
    codigo(sqrt('$v'(0)), _).

test(nativas, [forall(member(Q, [ suma_hasta(30, _), longitud_hasta(12, _),
                                   invertir_hasta(8, _)
                                 ])),
               true(Rs == Ns)]) :-
    findall(Q, almacen:resolver_con(aritmetica, listas, Q), Rs),
    respuestas_nativas(listas, Q, Ns).

test(libre, [error(instantiation_error)]) :-
    almacen:resolver_clausulas(aritmetica, [(p(X, Y) :- Y is X + 1)],
                               p(_, _)).

% Las dos cifras son de la misma búsqueda y son positivas.
test(comparar, [true((C > 0, A > 0))]) :-
    comparar(listas, suma_hasta(20, _), C, A).

test(compilar_llamada,
     [true(L == '$is'('$v'(0), [celda('$v'(1)), numero(1), op(+)]))]) :-
    aritmetica:compilar_llamada('$predefinida'('$v'(0) is '$v'(1) + 1), L).

test(compilar_llamada_otra, [true(L == '$llamar'(p/0, p))]) :-
    aritmetica:compilar_llamada('$llamar'(p/0, p), L).

% evaluar/4: los operandos se apilan y la operación toma los dos de arriba,
% el segundo operando primero.
test(evaluar, [true(P == [3])]) :-
    list_to_assoc([0-10], A),
    foldl(aritmetica:evaluar(A),
          [celda('$v'(0)), numero(7), op(-)], [], P).

test(evaluar_libre, [error(instantiation_error)]) :-
    empty_assoc(A),
    aritmetica:evaluar(A, celda('$v'(0)), [], _).

test(paso_liga, [true(Ms-L == [r]-[0-5])]) :-
    empty_assoc(A0),
    aritmetica:paso('$is'('$v'(0), [numero(2), numero(3), op(+)]), [r], _,
                    m([], [], A0, [], 1, med(0, 0, 0, 0, 0)),
                    sigue(m(Ms, _, A, _, _, _))),
    assoc_to_list(A, L).

test(paso_falla, [true(R == falla(E0))]) :-
    list_to_assoc([0-6], A0),
    E0 = m([], [], A0, [], 1, med(0, 0, 0, 0, 0)),
    aritmetica:paso('$is'('$v'(0), [numero(2), numero(3), op(+)]), [r], _,
                    E0, R).

:- end_tests(aritmetica).
