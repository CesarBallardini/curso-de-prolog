:- encoding(utf8).

:- begin_tests(soluciones).

test(primero_y_ultimo, all(P-U == [ana-eva])) :-
    primero_y_ultimo([ana, luis, eva], P, U).

test(sin_el_primero, all(R == [[luis, eva]])) :-
    sin_el_primero([ana, luis, eva], R).

test(contar_gatos, all(N == [2])) :-
    cuantos_gatos([gato, perro, gato, tortuga], N).

test(sin_gatos, all(N == [0])) :-
    cuantos_gatos([perro, tortuga], N).

test(empieza_con, [nondet]) :-
    empieza_con([ana, luis, eva], [ana, luis]).

test(no_empieza_con, [fail]) :-
    empieza_con([ana, luis, eva], [luis]).

test(reversa, all(R == [[eva, luis, ana]])) :-
    reversa([ana, luis, eva], R).

test(reversa_de_la_vacia, all(R == [[]])) :-
    reversa([], R).

test(sacar_uno, all(R == [[ana, eva]])) :-
    sacar(luis, [ana, luis, eva], R).

test(sacar_solo_la_primera, all(R == [[ana, eva, luis]])) :-
    sacar(luis, [ana, luis, eva, luis], R).

test(sacar_a_quien_no_esta, [fail]) :-
    sacar(pedro, [ana, luis], _).

test(es_sublista, [nondet]) :-
    es_sublista([luis, eva], [ana, luis, eva, sofia]).

test(no_es_sublista_si_no_estan_juntos, [fail]) :-
    es_sublista([ana, eva], [ana, luis, eva]).

test(es_subsecuencia_sin_estar_juntos, [nondet]) :-
    es_subsecuencia([ana, eva], [ana, luis, eva]).

test(no_es_subsecuencia_en_otro_orden, [fail]) :-
    es_subsecuencia([eva, ana], [ana, luis, eva]).

test(todas_las_subsecuencias,
     all(S == [[a, b], [a], [b], []])) :-
    es_subsecuencia(S, [a, b]).

% Ejercicio 12
test(todos_gatos_si) :-
    todos_gatos([gato, gato]).

test(todos_gatos_de_la_vacia) :-
    todos_gatos([]).

test(todos_gatos_no, [fail]) :-
    todos_gatos([gato, perro]).

test(algun_gato_si, [nondet]) :-
    algun_gato([perro, gato]).

test(algun_gato_de_la_vacia, [fail]) :-
    algun_gato([]).

% Ejercicio 13
test(duplicar, all(R == [[a, a, b, b]])) :-
    duplicar([a, b], R).

test(duplicar_la_vacia, all(R == [[]])) :-
    duplicar([], R).

% Ejercicio 15
test(segundo, all(X == [luis])) :-
    segundo([ana, luis, eva], X).

test(una_lista_de_uno_no_tiene_segundo, [fail]) :-
    segundo([ana], _).

% Ejercicio 16: las pruebas de sacar/3
% Una sola respuesta, aunque el elemento aparezca dos veces: la condición
% Otro \== X impide saltear la primera aparición.
test(sacar_la_primera_aparicion, all(R == [[b, a]])) :-
    sacar(a, [a, b, a], R).

test(sacar_lo_que_no_esta, [fail]) :-
    sacar(z, [a, b], _).

test(sacar_de_la_vacia, [fail]) :-
    sacar(a, [], _).

% Ejercicio 17: nth1/3 en los dos sentidos
test(materia_en_la_posicion_3, all(M == [fisica])) :-
    materia_en(3, M).

test(posicion_de_fisica, all(N == [3])) :-
    materia_en(N, fisica).

test(materia_en_todas, all(N-M == [1-logica, 2-algebra, 3-fisica, 4-quimica])) :-
    materia_en(N, M).

test(no_hay_posicion_5, [fail]) :-
    materia_en(5, _).

% Una posición por cada aparición del elemento.
test(posiciones_de_un_repetido, all(N == [1, 3])) :-
    nth1(N, [a, b, a], a).

% Ejercicio 19
test(sufijos, all(S == [[a, b, c], [b, c], [c], []])) :-
    suffix(S, [a, b, c]).

test(un_sufijo, [nondet]) :-
    suffix([c1, d1], [a1, b1, c1, d1]).

test(no_es_sufijo, [fail]) :-
    suffix([b1, c1], [a1, b1, c1, d1]).

% Ejercicio 20
test(adyacentes, all(X-Y == [a-b, b-c])) :-
    adjacent(X, Y, [a, b, c]).

test(adyacentes_en_otro_orden, [fail]) :-
    adjacent(c, b, [a, b, c]).

% Ejercicio 21: una respuesta por cada aparición de a.
test(selecciona_cada_aparicion, all(R == [[b, a], [a, b]])) :-
    selecciona(a, [a, b, a], R).

test(selecciona_inserta, all(L == [[x, a, b], [a, x, b], [a, b, x]])) :-
    selecciona(x, L, [a, b]).

test(selecciona_lo_que_no_esta, [fail]) :-
    selecciona(z, [a, b], _).

test(permutaciones, all(P == [[a, b, c], [a, c, b], [b, a, c],
                              [b, c, a], [c, a, b], [c, b, a]])) :-
    permuta([a, b, c], P).

test(permuta_con_repetidos, all(P == [[a, a], [a, a]])) :-
    permuta([a, a], P).

test(no_es_permutacion, [fail]) :-
    permuta([a, b], [a, a]).

% Ejercicio 22
test(substitute_todas, all(L == [[a, 9, c, d, 9, 9, c, 1]])) :-
    substitute(b, 9, [a, b, c, d, b, b, c, 1], L).

test(substitute_sin_apariciones, all(L == [[a, z]])) :-
    substitute(0, a, [a, z], L).

test(substitute_no_deja_ninguna, [fail]) :-
    substitute(a, x, [a, b, a, c], [a, b, x, c]).

% Ejercicio 23
test(elimina_todas, all(L == [[a, c, d]])) :-
    elimina([a, b, c, b, d], b, L).

test(elimina_lo_que_no_esta, all(L == [[a, b]])) :-
    elimina([a, b], z, L).

test(elimina_no_deja_ninguna, [fail]) :-
    elimina([a, b, a], a, [b, a]).

% Ejercicio 24: las listas internas también son respuestas.
test(ocurre_en_todos_los_niveles,
     all(E == [1, [a, b], a, b, [d, [a, 2]], d, [a, 2], a, 2, 6])) :-
    ocurre(E, [1, [a, b], [d, [a, 2]], 6]).

test(ocurre_una_vez_por_aparicion, all(E == [a, a])) :-
    E = a,
    ocurre(E, [1, [a, b], [d, [a, 2]], 6]).

test(no_ocurre, [fail]) :-
    ocurre(9, [1, [a, b], [d, [a, 2]], 6]).

% Ejercicio 25
test(es_arbol_binario) :-
    arbol_ejemplo(T),
    binary_tree(T).

test(no_es_arbol_binario, [fail]) :-
    binary_tree(tree(1, void, hoja)).

test(elementos_del_arbol, all(X == [1, 2, 4, 3, 5, 7, 6])) :-
    arbol_ejemplo(T),
    tree_member(X, T).

test(no_esta_en_el_arbol, [fail]) :-
    arbol_ejemplo(T),
    tree_member(9, T).

test(hojas_del_ejemplo, all(H == [[4, 7, 6]])) :-
    arbol_ejemplo(T),
    lista_hojas(T, H).

test(un_arbol_de_una_hoja, all(H == [[9]])) :-
    lista_hojas(tree(9, void, void), H).

test(una_hoja_no_es_lista_vacia, [fail]) :-
    lista_hojas(tree(9, void, void), []).

% Ejercicio 26
test(preorden) :-
    arbol_ejemplo(T),
    preorder(T, Xs),
    Xs == [1, 2, 4, 3, 5, 7, 6].

test(inorden) :-
    arbol_ejemplo(T),
    inorder(T, Xs),
    Xs == [2, 4, 1, 7, 5, 3, 6].

test(postorden) :-
    arbol_ejemplo(T),
    postorder(T, Xs),
    Xs == [4, 2, 7, 5, 6, 3, 1].

test(recorridos_del_arbol_vacio) :-
    preorder(void, []),
    inorder(void, []),
    postorder(void, []).

test(preorden_equivocado, [fail]) :-
    arbol_ejemplo(T),
    preorder(T, [1, 2, 3, 4, 5, 6, 7]).

:- end_tests(soluciones).
