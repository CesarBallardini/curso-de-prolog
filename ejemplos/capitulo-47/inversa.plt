:- encoding(utf8).

:- begin_tests(inversa).

test(entera, [true(I == [[1, -1], [-1, 2]])]) :-
    inversa([[2, 1], [1, 1]], I).

test(singular, [fail]) :-
    inversa([[1, 2], [2, 4]], _).

% El primer elemento es 0: el pivote es la segunda fila.
test(pivote_en_otra_fila, [true(I == [[0, 1], [1, 0]])]) :-
    inversa([[0, 1], [1, 0]], I).

test(racional, [true(I == [[12, -20], [-15, 30]])]) :-
    inversa([[1r2, 1r3], [1r4, 1r5]], I).

test(no_cuadrada, [error(domain_error(matriz_cuadrada, _))]) :-
    inversa([[1, 2, 3], [4, 5, 6]], _).

test(hilbert_3, [true(I == [[9, -36, 30], [-36, 192, -180], [30, -180, 180]])]) :-
    hilbert(3, racional, H),
    inversa(H, I).

% Con racionales, H * I es exactamente la identidad.
test(hilbert_exacta, [true(E == 0)]) :-
    hilbert(10, racional, H),
    inversa(H, I),
    desvio(H, I, E).

% Con números de punto flotante, el desvío crece con el orden.
test(hilbert_flotante, [true(E4 < 1.0e-9), true(E12 > 1.0e-3)]) :-
    hilbert(4, flotante, H4),
    inversa(H4, I4),
    desvio(H4, I4, E4),
    hilbert(12, flotante, H12),
    inversa(H12, I12),
    desvio(H12, I12, E12).

test(tipo, [error(type_error(oneof([racional, flotante]), entero))]) :-
    hilbert(3, entero, _).

:- end_tests(inversa).

:- begin_tests(desvio_hilbert).

test(racional, [true(E == 0)]) :-
    desvio_hilbert(12, racional, E).

test(flotante, [true(E > 1.0)]) :-
    desvio_hilbert(12, flotante, E).

:- end_tests(desvio_hilbert).
