:- encoding(utf8).

:- begin_tests(usa_utiles).

% par/1 es privado de usa_utiles: meta_predicate hace que utiles lo busque
% allí.
test(pares, true(N == 2)) :-
    cuantos_pares([1, 2, 3, 4], N).

:- end_tests(usa_utiles).
