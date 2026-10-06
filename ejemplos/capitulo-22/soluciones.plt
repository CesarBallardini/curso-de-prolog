:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1
test(msort, true(L == [1.5, 2, "a", b, f(1)])) :-
    msort([b, 2, "a", f(1), 1.5], L).

test(sort_descendente, true(L == [3, 3, 2, 1])) :-
    sort(0, @>=, [3, 1, 2, 3], L).

test(sort_por_clave, true(L == [a-2, b-1])) :-
    sort(1, @<, [b-1, a-2, b-3], L).

% Ejercicio 2
test(tres_formas, true(S-M-T == [a, b, c]-[a, a, b, c]-[c, a, b])) :-
    sort([c, a, b, a], S),
    msort([c, a, b, a], M),
    list_to_set([c, a, b, a], T).

% Ejercicio 3
test(por_longitud, true(L == [[d], [e, f], [a, b, c]])) :-
    por_longitud([[a, b, c], [d], [e, f]], L).

test(por_longitud_estable, true(L == [[x], [y], [a, b]])) :-
    por_longitud([[a, b], [x], [y]], L).

% Ejercicio 4
test(anagramas, true(L == [amor, mora, ramo])) :-
    anagramas(roma, [amor, mora, ramo, rama, roma], L).

% Ejercicio 5
test(escuela, true(L2-L1-L3 == [eva, luis]-[ana]-[])) :-
    escuela([2-luis, 1-ana, 2-eva, 1-ana], E),
    alumnos_de(E, 2, L2),
    alumnos_de(E, 1, L1),
    alumnos_de(E, 3, L3).

% Ejercicio 6: con predsort/3 que nunca responde =, no se pierde ninguno.
test(por_valor, true(L == [b-1, d-2, a-3, c-3])) :-
    por_valor([a-3, b-1, c-3, d-2], L).

% Ejercicio 7
test(la_mayor, true(N == b)) :-
    la_mayor([_{n: a, edad: 3}, _{n: b, edad: 9}, _{n: c, edad: 9}], M),
    get_dict(n, M, N).

test(la_mayor_vacia, [fail]) :-
    la_mayor([], _).

% La notación funcional dentro de una lambda se expande fuera de ella.
test(punto_en_lambda, [error(instantiation_error)]) :-
    foldl([P, M0, M]>>( P.edad > M0.edad -> M = P ; M = M0 ),
          [_{edad: 1}], _{edad: 0}, _).

% Ejercicio 8
test(formatear, true(T == 'Sra. ANA')) :-
    formatear_nombre(ana, [mayusculas(true), prefijo('Sra. ')], T).

test(formatear_por_omision, true(T == ana)) :-
    formatear_nombre(ana, [], T).

% Ejercicio 9: con la misma semilla, el mismo sorteo.
test(sorteo, [ setup(set_random(seed(1))),
               true(L == [35, 19, 40, 15, 48, 28]) ]) :-
    sorteo(6, 49, L).

test(sorteo_sin_repetidos, true(N == 6)) :-
    sorteo(6, 49, L),
    sort(L, S),
    length(S, N).

% Ejercicio 16: la versión incorrecta pierde la raíz, o deja el árbol libre.
test(insertar_mal_pierde_la_raiz, [nondet, true(A == n(vacio, 5, vacio))]) :-
    insertar_mal(5, n(vacio, 7, vacio), A).

% var/1, que reconoce una variable libre, se presenta en el capítulo 32.
test(insertar_mal_deja_libre, true(var(A))) :-
    insertar_mal(7, n(vacio, 7, vacio), A).

test(insertar_menor, true(A == n(n(vacio, 5, vacio), 7, vacio))) :-
    insertar(5, n(vacio, 7, vacio), A).

test(insertar_existente, true(A == n(vacio, 7, vacio))) :-
    insertar(7, n(vacio, 7, vacio), A).

test(insertar_varias,
     true(A == n(n(n(vacio, 1, vacio), 3, n(vacio, 5, vacio)), 7,
                 n(vacio, 9, vacio)))) :-
    foldl(insertar, [7, 3, 9, 1, 5], vacio, A).

test(reinsertar_da_el_mismo_arbol, true(A == B)) :-
    foldl(insertar, [7, 3, 9, 1, 5], vacio, A),
    insertar(9, A, B).

% El subárbol derecho de la raíz no está en el camino de 4: no se copia.
test(insertar_comparte, true(same_term(D, D1))) :-
    foldl(insertar, [7, 3, 9, 1, 5], vacio, A),
    insertar(4, A, B),
    A = n(_, 7, D),
    B = n(_, 7, D1).

:- end_tests(soluciones).
