:- encoding(utf8).

:- begin_tests(soluciones).

test(longitud_abierta, true(N == 2)) :-
    longitud_abierta([a, b|_], N).

test(longitud_abierta_vacia, true(N == 0)) :-
    longitud_abierta(_, N).

test(longitud_abierta_no_cierra, true(var(F))) :-
    longitud_abierta([a|F], _).

test(a_dif, true(L-F == [a, b|F]-F)) :-
    a_dif([a, b], L-F).

test(de_dif, true(L == [a, b])) :-
    de_dif([a, b|F]-F, L).

test(ida_y_vuelta, true(L == [a, b, c])) :-
    a_dif([a, b], D1),
    concatenar_dif(D1, [c|F]-F, D),
    de_dif(D, L).

test(bandera, true(B == [rojo, rojo, blanco, azul, azul])) :-
    bandera([azul, rojo, blanco, rojo, azul], B).

test(bandera_vacia, true(B == [])) :-
    bandera([], B).

% Cada color conserva su orden: la bandera es estable.
test(bandera_un_color, true(B == [blanco, blanco])) :-
    bandera([blanco, blanco], B).

arbol(n(n(vacio, 1, vacio), 2, n(vacio, 3, n(vacio, 4, vacio)))).

test(preorden, true(L == [2, 1, 3, 4])) :-
    arbol(A),
    phrase(preorden(A), L).

test(postorden, true(L == [1, 4, 3, 2])) :-
    arbol(A),
    phrase(postorden(A), L).

test(dos_veces, [fail]) :-
    D = [a|_]-_,
    concatenar_dif(D, [b|Y]-Y, _),
    concatenar_dif(D, [c|Z]-Z, _).

test(copia_antes, true(R1-R2 == [a, b]-[a, c])) :-
    D = [a|X]-X,
    copy_term(D, D2),
    concatenar_dif(D, [b|Y]-Y, R1-[]),
    concatenar_dif(D2, [c|Z]-Z, R2-[]).

test(elementos_cola, true(L == [a, b])) :-
    cola_vacia(C0),
    encolar(a, C0, C1),
    encolar(b, C1, C2),
    elementos_cola(C2, L).

test(elementos_cola_desencolada, true(L == [b])) :-
    cola_vacia(C0),
    encolar(a, C0, C1),
    encolar(b, C1, C2),
    desencolar(_, C2, C3),
    elementos_cola(C3, L).

test(elementos_cola_vacia, true(L == [])) :-
    cola_vacia(C0),
    elementos_cola(C0, L).

% La cola sigue admitiendo agregados después de listarla.
test(elementos_cola_no_cambia, true(L == [a, b])) :-
    cola_vacia(C0),
    encolar(a, C0, C1),
    elementos_cola(C1, _),
    encolar(b, C1, C2),
    elementos_cola(C2, L).

test(es_vacia_dif, true(cyclic_term(X))) :-
    es_vacia_dif([a|X]-X).

test(ocurrencias, [fail]) :-
    unify_with_occurs_check([a|X]-X, F-F).

test(claves, true(C == [a, b])) :-
    claves([a-1, b-_|_], C).

test(claves_no_cierra, true(var(F))) :-
    claves([a-1|F], _).

test(claves_vacio, true(K == [])) :-
    claves(_, K).

test(pares, true(P == [a-1, b-2, c-3])) :-
    buscar_arbol(b, A, 2),
    buscar_arbol(c, A, 3),
    buscar_arbol(a, A, 1),
    phrase(pares(A), P).

test(pares_vacio, true(P == [])) :-
    phrase(pares(_), P).

test(hojas, true(L == [a, b, c])) :-
    phrase(hojas(n([h(a), n([h(b), h(c)])])), L).

test(hojas_lista_en_hoja, true(L == [[x], y])) :-
    phrase(hojas(n([h([x]), h(y)])), L).

test(invertir_iguales, true(L1 == L2)) :-
    numlist(1, 100, L),
    invertir_app(L, L1),
    invertir(L, L2).

% Ejercicio 15
test(nivelar,
     true(N == n(n(vacio, 9, vacio), 9, n(vacio, 9, vacio)))) :-
    nivelar(n(n(vacio, 4, vacio), 3, n(vacio, 9, vacio)), N).

test(nivelar_vacio, true(N == vacio)) :-
    nivelar(vacio, N).

% El máximo está en la raíz y no en una hoja.
test(nivelar_maximo_en_la_raiz,
     true(N == n(n(n(vacio, 3, vacio), 3, vacio), 3, vacio))) :-
    nivelar(n(n(n(vacio, 1, vacio), 2, vacio), 3, vacio), N).

% Ejercicio 16: las dos versiones, con las dos formas de la suma.
test(asociar_izquierda, true(S == a + b + c + d)) :-
    asociar_izquierda((a + b) + (c + d), S).

test(asociar_izquierda_derecha, true(S == +(+(+(a, b), c), d))) :-
    asociar_izquierda(a + (b + (c + d)), S).

test(asociar_izquierda_un_sumando, true(S == a)) :-
    asociar_izquierda(a, S).

test(asociar_izquierda_2, true(S1-S2 == (a + b + c + d)-(a + b + c + d))) :-
    asociar_izquierda_2((a + b) + (c + d), S1),
    asociar_izquierda_2(a + (b + (c + d)), S2).

test(sumandos, true(L == [x * y, 2, z])) :-
    sumandos(x * y + (2 + z), L-[]).

% Ejercicio 10: el subárbol libre queda libre, y no hay otra respuesta.
test(pares_deja_libre, [true(var(D)), nondet]) :-
    buscar_arbol(b, A, 2),
    phrase(pares(A), _),
    A = t(_, _, _, D).

test(pares_una_respuesta, all(P == [[b-2]])) :-
    buscar_arbol(b, A, 2),
    phrase(pares(A), P).

% Ejercicio 16: un átomo como valor inicial queda en el resultado.
test(agregar_ninguno, true(S == ninguno + a + b + c + d)) :-
    agregar((a + b) + (c + d), ninguno, S).

:- end_tests(soluciones).
