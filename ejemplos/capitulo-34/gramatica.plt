:- encoding(utf8).

:- begin_tests(gramatica).

test(phrase, true(L == [1, 2, 3])) :-
    phrase(en_orden(n(n(vacio, 1, vacio), 2, n(vacio, 3, vacio))), L).

test(phrase_resto, true(L == [1, fin])) :-
    phrase(en_orden(n(vacio, 1, vacio)), L, [fin]).

% La gramática deja la lista abierta si el resto queda libre.
test(phrase_abierta, true(L-F == [1|F]-F)) :-
    phrase(en_orden(n(vacio, 1, vacio)), L, F).

test(vacio, true(L == [])) :-
    phrase(en_orden(vacio), L).

test(a_mano, true(L == [1, 2])) :-
    en_orden_dif(n(n(vacio, 1, vacio), 2, vacio), L, []).

% La gramática y la traducción escrita a mano dan lo mismo.
test(iguales, true(L1 == L2)) :-
    A = n(n(vacio, 1, n(vacio, 2, vacio)), 3, n(vacio, 4, vacio)),
    phrase(en_orden(A), L1),
    en_orden_dif(A, L2, []).

:- end_tests(gramatica).
