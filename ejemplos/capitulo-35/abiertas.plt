:- encoding(utf8).

:- begin_tests(abiertas).

test(agregar, true(L = [a, b, c, d|_])) :-
    L = [a, b|_],
    agregar_al_final(L, c),
    agregar_al_final(L, d).

% La lista sigue abierta después de agregar.
test(agregar_sigue_abierta, true(var(F))) :-
    L = [a|F0],
    agregar_al_final(L, b),
    F0 = [b|F].

test(agregar_a_vacia, true(L = [x|_])) :-
    agregar_al_final(L, x).

test(cerrar, true(L == [a, b, c])) :-
    L = [a, b|_],
    agregar_al_final(L, c),
    cerrar(L).

test(cerrar_vacia, true(L == [])) :-
    cerrar(L).

test(conocidos, true(C == [a, b])) :-
    conocidos([a, b|_], C).

% conocidos/2 no liga el final de la lista.
test(conocidos_no_cierra, true(var(F))) :-
    conocidos([a, b|F], _).

test(conocidos_vacia, true(C == [])) :-
    conocidos(_, C).

test(agregar_varias_veces, true(C == [a, b, c])) :-
    L = [a|_],
    agregar_al_final(L, b),
    agregar_al_final(L, c),
    conocidos(L, C).

% memberchk/2 agrega a una lista abierta el elemento que no encuentra.
test(memberchk_agrega, true(L = [a, b, c|_])) :-
    L = [a, b|_],
    memberchk(c, L).

test(memberchk_encuentra, true(C == [a, b])) :-
    L = [a, b|_],
    memberchk(a, L),
    conocidos(L, C).

% Con una lista cerrada no hay final libre: los dos predicados fallan.
test(agregar_a_cerrada, [fail]) :-
    agregar_al_final([a], b).

test(cerrar_cerrada, [fail]) :-
    cerrar([a]).

:- end_tests(abiertas).
