:- encoding(utf8).

:- begin_tests(soluciones_bloques).

% Ejercicio 10: el mismo plan más corto que la búsqueda a lo ancho.
test(iterativo, true(P1 == P2)) :-
    I = estado([[c, a], [b]], vacia),
    M = estado([[a, b, c]], vacia),
    plan_iterativo(I, M, P1),
    plan(I, M, P2).

test(iterativo_torre, true(N == 6)) :-
    plan_iterativo(estado([[a], [b], [c], [d]], vacia),
                   estado([[d, c, b, a]], vacia), P),
    length(P, N).

test(iterativo_imposible, [fail]) :-
    plan_iterativo(estado([[a]], vacia), estado([[a], [b]], vacia), _).

% Ejercicio 11
test(contando, true(N == 22)) :-
    plan_contando(estado([[c, a], [b]], vacia), estado([[a, b, c]], vacia),
                  _, N).

:- end_tests(soluciones_bloques).
