:- encoding(utf8).

:- begin_tests(pares).

test(por_largo, true(L == [ana, eva, luis, pedro])) :-
    por_largo([pedro, ana, luis, eva], L).

% keysort/2 es estable: con la misma clave, conserva el orden.
test(keysort_estable, true(L == [a-2, a-1, b-1, b-0])) :-
    keysort([b-1, a-2, b-0, a-1], L).

test(hijos_de_pedro, true(H == [luis, eva])) :-
    hijos_por_padre(A),
    get_assoc(pedro, A, H).

test(sin_hijos, [fail]) :-
    hijos_por_padre(A),
    get_assoc(eva, A, _).

% put_assoc/4 construye un assoc nuevo; el anterior no cambia.
test(agregar_hijo, true(K0-K == [juan, pedro]-[ana, juan, pedro])) :-
    hijos_por_padre(A0),
    agregar_hijo(ana, sofia, A0, A),
    assoc_to_keys(A0, K0),
    assoc_to_keys(A, K).

test(en_los_dos, true(L == [ana, luis])) :-
    en_los_dos([eva, ana, luis], [luis, juan, ana], L).

test(solo_en_el_primero, true(L == [eva])) :-
    solo_en_el_primero([eva, ana, luis], [luis, juan, ana], L).

:- end_tests(pares).
