:- encoding(utf8).

:- begin_tests(matriz).

test(transpuesta, [true(T == [[1, 4], [2, 5], [3, 6]])]) :-
    transpuesta([[1, 2, 3], [4, 5, 6]], T).

test(transpuesta_vacia, [true(T == [])]) :-
    transpuesta([], T).

test(transpuesta_dos_veces, [true(T2 == M)]) :-
    M = [[1, 2], [3, 4], [5, 6]],
    transpuesta(M, T),
    transpuesta(T, T2).

test(dimensiones, [true(F-C == 2-3)]) :-
    dimensiones([[1, 2, 3], [4, 5, 6]], F, C).

test(no_es_matriz, [error(domain_error(matriz, _))]) :-
    dimensiones([[1, 2], [3]], _, _).

test(producto_interno, [true(X == 31)]) :-
    producto_interno([5, 3], [2, 7], X).

test(producto, [true(C == [[2, 1], [4, 3]])]) :-
    producto([[1, 2], [3, 4]], [[0, 1], [1, 0]], C).

test(producto_racional, [true(C == [[1], [1]])]) :-
    producto([[1r2, 0], [0, 1r3]], [[2], [3]], C).

test(producto_no_conmuta, [true(C == [[3, 4], [1, 2]])]) :-
    producto([[0, 1], [1, 0]], [[1, 2], [3, 4]], C).

test(incompatibles, [error(domain_error(matrices_compatibles, _))]) :-
    producto([[1, 2]], [[1, 2]], _).

test(identidad, [true(I == [[1, 0, 0], [0, 1, 0], [0, 0, 1]])]) :-
    identidad(3, I).

test(neutro, [true(C == M)]) :-
    M = [[1, 2, 3], [4, 5, 6]],
    identidad(3, I),
    producto(M, I, C).

test(columnas, [true(T == [[1, 3], [2, 4]])]) :-
    columnas([a, b], [[1, 2], [3, 4]], T).

test(columnas_sin_guia, [true(T == [])]) :-
    columnas([], [[1, 2], [3, 4]], T).

test(primero_y_resto, [true(X-Xs == 1-[2, 3])]) :-
    primero_y_resto([1, 2, 3], X, Xs).

test(primero_y_resto_vacia, [fail]) :-
    primero_y_resto([], _, _).

test(sumar_producto, [true(S == 7)]) :-
    sumar_producto(2, 3, 1, S).

test(producto_interno_vacio, [true(X == 0)]) :-
    producto_interno([], [], X).

% Con otro producto interno, producto_con/4 da otra operación sobre el
% mismo recorrido.
test(producto_con_otro_interno, [true(C == [[2-2, 2-1], [2-4, 2-3]])]) :-
    producto_con(con_longitud, [[1, 2], [3, 4]], [[0, 1], [1, 0]], C).

test(fila_por_columnas, [true(R == [2, 1])]) :-
    fila_por_columnas(producto_interno, [[0, 1], [1, 0]], [1, 2], R).

test(fila_identidad, [true(F == [0, 1, 0])]) :-
    fila_identidad([1, 2, 3], 2, F).

test(uno_si_igual, [true(Xs == [1, 0])]) :-
    uno_si_igual(2, 2, X1),
    uno_si_igual(2, 3, X2),
    Xs = [X1, X2].

test(identidad_cero, [true(I == [])]) :-
    identidad(0, I).

test(identidad_negativa, [error(type_error(nonneg, -1))]) :-
    identidad(-1, _).

% con_longitud(V, W, L-S): L es la longitud de V y S su producto interno
% con W.
con_longitud(V, W, L-S) :-
    length(V, L),
    producto_interno(V, W, S).

:- end_tests(matriz).
