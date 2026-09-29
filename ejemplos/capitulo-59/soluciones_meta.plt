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

:- end_tests(soluciones_meta).
