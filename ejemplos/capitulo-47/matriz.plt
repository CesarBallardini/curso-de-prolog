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

:- end_tests(matriz).
