:- encoding(utf8).

:- use_module(semantica38).

:- begin_tests(incremental).

test(iniciar, [true(C == costo(41, 820))]) :-
    clausulas(cadena(40), Cs),
    iniciar(Cs, E, C),
    modelo_estado(E, M),
    semi_ingenua_de(Cs, [], M, _).

% Un arco más: 41 caminos nuevos, y el mismo modelo que la fila de 41
% arcos.
test(agregar, [true(C == costo(2, 41))]) :-
    clausulas(cadena(40), Cs),
    iniciar(Cs, E, _),
    agregar_hechos([arco(40, 41)], E, E1, C),
    modelo_estado(E1, M),
    clausulas(cadena(41), Cs41),
    semi_ingenua_de(Cs41, [], M, _).

test(agregar_repetido, [true(C == costo(0, 0))]) :-
    iniciar([(p(a) :- true), (q(X) :- p(X))], E, _),
    agregar_hechos([p(a)], E, _, C).

% Un arco que cierra un ciclo: todos los caminos entre los nodos.
test(ciclo, [true(L == 6)]) :-
    iniciar([ (arco(a, b) :- true),
              (camino(X, Y) :- arco(X, Y)),
              (camino(X, Y) :- camino(X, Z), arco(Z, Y)) ], E, _),
    agregar_hechos([arco(b, a)], E, E1, _),
    modelo_estado(E1, M),
    length(M, L).

test(modelo_estado, [true(M == [p(a), q(a)])]) :-
    iniciar([(p(a) :- true), (q(X) :- p(X))], E, _),
    modelo_estado(E, M).

test(negacion, [error(domain_error(programa_sin_negacion, \+ q(_)))]) :-
    iniciar([(p(X) :- r(X), \+ q(X))], _, _).

:- end_tests(incremental).
