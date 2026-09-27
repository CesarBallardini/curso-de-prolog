:- encoding(utf8).

:- begin_tests(indexacion).

% ultimo/2 deja una alternativa: la prueba lo declara.
test(ultimo_deja_una_alternativa, [nondet, true(U == c)]) :-
    ultimo([a, b, c], U).

% ultimo_indexado/2 no deja ninguna: la prueba no declara nondet.
test(ultimo_indexado_sin_alternativas, true(U == c)) :-
    ultimo_indexado([a, b, c], U).

test(ultimo_de_la_vacia, [fail]) :-
    ultimo_indexado([], _).

test(todos_estan, [nondet]) :-
    todos_estan([a, b], [a, b, c]).

test(todos_estan_chk_sin_alternativas) :-
    todos_estan_chk([a, b], [a, b, c]).

test(falta_uno, [fail]) :-
    todos_estan_chk([a, z], [a, b, c]).

:- end_tests(indexacion).
