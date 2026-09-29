:- encoding(utf8).

:- begin_tests(limpia).

test(aplanar_ingenuo, true(P == [a, b, c])) :-
    aplanar_ingenuo([a, [b, c]], P).

test(aplanar_ingenuo_ligado_antes, true(P == [a, b, c])) :-
    X = [b, c],
    aplanar_ingenuo([a, X], P).

% Con la lista ligada después, is_list/1 ya decidió que X era una hoja.
test(aplanar_ingenuo_ligado_despues, true(P == [a, [b, c]])) :-
    aplanar_ingenuo([a, X], P),
    X = [b, c].

test(aplanar_ingenuo_vacia, true(P == [])) :-
    aplanar_ingenuo([[], [[]]], P).

test(hojas, true(H == [a, b, c])) :-
    hojas(n([h(a), n([h(b), h(c)])]), H).

% Una hoja puede contener una lista: el functor h/1 dice que es una hoja.
test(hojas_con_lista, true(H == [a, [b, c]])) :-
    hojas(n([h(a), h([b, c])]), H).

test(hojas_nodo_vacio, true(H == [])) :-
    hojas(n([]), H).

% El árbol ligado después da el mismo resultado que ligado antes.
test(hojas_ligado_despues, true(H == [a, b])) :-
    hojas(n([h(a), h(X)]), H),
    X = b.

test(hojas_verifica, [nondet]) :-
    hojas(n([h(a), h(b)]), [a, b]).

test(hojas_primera, true(A == h(a))) :-
    once(hojas(A, [a])).

test(a_arbol, true(A == n([h(a), n([h(b), h(c)])]))) :-
    a_arbol([a, [b, c]], A).

test(a_arbol_libre, [error(instantiation_error)]) :-
    a_arbol([a, _], _).

% Convertir y después recorrer da lo mismo que aplanar.
test(convertir_y_recorrer, true(H == P)) :-
    L = [a, [b, [c, d]], e],
    a_arbol(L, A),
    hojas(A, H),
    aplanar_ingenuo(L, P).

:- end_tests(limpia).
