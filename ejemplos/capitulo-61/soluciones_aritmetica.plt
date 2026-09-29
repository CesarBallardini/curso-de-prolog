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

:- end_tests(aritmetica).
