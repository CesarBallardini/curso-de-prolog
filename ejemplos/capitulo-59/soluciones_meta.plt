:- encoding(utf8).

:- begin_tests(soluciones_meta).

% Sin la declaración, q/1 no se alcanza; con ella, sí. Las dos mediciones
% van en una prueba porque la declaración queda en el módulo externo.
test(ejercicio_6, [true(Antes-Despues == [q/1]-[])]) :-
    leidos_con_meta(Leidos),
    programa(Leidos, Cs0, Rs0),
    no_usados_de(Cs0, [p/0|Rs0], Antes),
    no_usados(con_meta, Despues).

test(ejercicio_7_inferidas, [true(Ds == [responder(0)])]) :-
    metas_inferidas(inscripciones, Ds).

test(ejercicio_7_sin_no_usados, [true(Ps == [])]) :-
    declarar_inferidas(inscripciones),
    no_usados(inscripciones, Ps).

% call/3 con la meta en un argumento de la cabeza agrega dos argumentos.
test(ejercicio_7_call, [true(D == aplicar2(2, ?, ?))]) :-
    metaargumentos([(aplicar2(G, X, Y) :- call(G, X, Y))], aplicar2/3, D).

% Una variable llamada directamente, como clausura de maplist/3 con dos
% argumentos más, y dentro de la negación y de once/1.
test(variable_llamada, [true(Ps == [x-0, y-2, z-0])]) :-
    G = (X, maplist(Y, _, _) ; \+ once(Z)),
    findall(N-E, ( variable_llamada(G, V, E),
                   once(( V == X, N = x ; V == Y, N = y ; V == Z, N = z )) ),
            Ps).

test(variable_llamada_ninguna, [fail]) :-
    variable_llamada((p(X), q(X)), _, _).

test(declarar_meta, [true(D == aplicar_dos(1, ?))]) :-
    declarar_meta(aplicar_dos(1, ?)),
    predicate_property(externo:aplicar_dos(_, _), meta_predicate(D)).

test(declarar_metas, [true(D == con_meta(0))]) :-
    declarar_metas([ leido((:- meta_predicate(con_meta(0))), f:1, [], []),
                     leido(otra, f:2, [], []) ]),
    predicate_property(externo:con_meta(_), meta_predicate(D)).

:- end_tests(soluciones_meta).
