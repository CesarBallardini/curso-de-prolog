:- encoding(utf8).

:- begin_tests(bloques).

test(sucesores, all(A == [tomar(c), tomar(b)])) :-
    sucesor(estado([[c, a], [b]], vacia), A, _).

test(normalizar, true(E == estado([[a], [b, c]], vacia))) :-
    normalizar(estado([[b, c], [a]], vacia), E).

% La anomalía de Sussman: seis acciones.
test(sussman, true(P == [tomar(c), soltar(c), tomar(b), apilar(b, c),
                         tomar(a), apilar(a, b)])) :-
    plan(estado([[c, a], [b]], vacia), estado([[a, b, c]], vacia), P).

test(torre, true(N == 6)) :-
    plan(estado([[a], [b], [c], [d]], vacia), estado([[d, c, b, a]], vacia),
         P),
    length(P, N).

test(ya_en_la_meta, true(P == [])) :-
    plan(estado([[a, b]], vacia), estado([[a, b]], vacia), P).

% Un bloque que no existe no se puede crear.
test(meta_imposible, [fail]) :-
    plan(estado([[a]], vacia), estado([[a], [b]], vacia), _).

:- end_tests(bloques).
