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

test(gauss_jordan, [true(R == [[1, 0, 1, -1], [0, 1, -1, 2]])]) :-
    gauss_jordan([[2, 1, 1, 0], [1, 1, 0, 1]], [], R).

test(gauss_jordan_singular, [fail]) :-
    gauss_jordan([[1, 2, 1, 0], [2, 4, 0, 1]], [], _).

test(elegir_pivote, [true(P-R == [1, 0]-[[0, 1], [2, 2]])]) :-
    elegir_pivote(0, [[0, 1], [1, 0], [2, 2]], P, R).

test(elegir_pivote_columna, [true(P == [0, 3])]) :-
    elegir_pivote(1, [[5, 0], [0, 3]], P, _).

test(elegir_pivote_ninguno, [fail]) :-
    elegir_pivote(0, [[0, 1], [0, 2]], _, _).

test(dividir_por_exacto, [true(Z == 3r2)]) :-
    dividir_por(2, 3, Z).

test(dividir_por_flotante, [true(Z == 1.5)]) :-
    dividir_por(2.0, 3, Z).

test(eliminar, [true(N == [0, -1, 1])]) :-
    eliminar(0, [1, 1, 0], [1, 0, 1], N).

test(restar_multiplo, [true(Y == 1)]) :-
    restar_multiplo(2, 3, 7, Y).

test(mitad_derecha, [true(D == [c, d])]) :-
    mitad_derecha(2, [a, b, c, d], D).

test(fila_hilbert, [true(F == [1r2, 1r3, 1r4])]) :-
    fila_hilbert(racional, [1, 2, 3], 2, F).

test(elemento_hilbert, [true(X-Y == 1r5-0.2)]) :-
    elemento_hilbert(racional, 2, 4, X),
    elemento_hilbert(flotante, 2, 4, Y).

test(mayor_diferencia, [true(E == 3)]) :-
    mayor_diferencia(1, 4, 2, E).

test(desvio_cero, [true(E == 0)]) :-
    desvio([[2, 1], [1, 1]], [[1, -1], [-1, 2]], E).

test(inversa_vacia, [true(I == [])]) :-
    inversa([], I).

test(hilbert_cero, [true(H == [])]) :-
    hilbert(0, racional, H).

:- end_tests(inversa).

:- begin_tests(desvio_hilbert).

test(racional, [true(E == 0)]) :-
    desvio_hilbert(12, racional, E).

test(flotante, [true(E > 1.0)]) :-
    desvio_hilbert(12, flotante, E).

:- end_tests(desvio_hilbert).
