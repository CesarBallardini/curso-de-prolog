:- encoding(utf8).

% Pruebas de paralelo.pl: el resumen de un día, la combinación, la lectura
% en serie y en paralelo, y los umbrales calculados desde el resumen, que
% son los de la versión 4.

:- begin_tests(paralelo).

% cerca(X, Y): X e Y difieren en menos de una millonésima.
cerca(X, Y) :-
    abs(X - Y) < 1.0e-6.

test(resumir_dia_4, [true(R == r(12, 116, 4584, [0-3, 1-1, 2-1, 3-1, 5-2,
                                                6-1, 8-1, 24-1, 62-1]))]) :-
    resumir(fallos, registros('2026-10-01.log'), R).

test(combinar, [true(R == r(5, 10, 24, [1-2, 2-1, 3-2]))]) :-
    combinar(r(2, 4, 10, [1-1, 3-1]), r(3, 6, 14, [1-1, 2-1, 3-1]), R).

test(combinar_vacio, [true(R == r(2, 4, 10, [1-1, 3-1]))]) :-
    combinar(r(2, 4, 10, [1-1, 3-1]), r(0, 0, 0, []), R).

test(combinar_conmuta) :-
    R1 = r(2, 4, 10, [1-1, 3-1]),
    R2 = r(3, 7, 21, [0-1, 3-1, 4-1]),
    combinar(R1, R2, A),
    combinar(R2, R1, B),
    assertion(A == B).

test(serie_igual_paralelo) :-
    dias_de_referencia(As),
    resumir_en_serie(fallos, As, R1),
    resumir_en_paralelo(fallos, As, R2),
    assertion(R1 == R2).

test(resumen_de_referencia,
     [true(R == r(36, 166, 1606, [0-3, 1-4, 2-7, 3-3, 4-5, 5-4, 6-3, 7-1,
                                 8-1, 9-2, 10-2, 28-1]))]) :-
    dias_de_referencia(As),
    resumir_en_paralelo(fallos, As, R).

test(media_desvio_como_version_4, [forall(member(M, [fallos, pedidos, cpu]))]) :-
    dias_de_referencia(As),
    resumir_en_paralelo(M, As, R),
    ajustar_resumen(media_desvio(3), R, entre(I1, S1)),
    referencia(Horas),
    valores(M, Horas, Vs),
    ajustar(media_desvio(3), Vs, entre(I2, S2)),
    assertion(cerca(I1, I2)),
    assertion(cerca(S1, S2)).

test(mediana_mad_como_version_4, [forall(member(M, [fallos, pedidos, cpu]))]) :-
    dias_de_referencia(As),
    resumir_en_paralelo(M, As, R),
    ajustar_resumen(mediana_mad(3.5), R, entre(I1, S1)),
    referencia(Horas),
    valores(M, Horas, Vs),
    ajustar(mediana_mad(3.5), Vs, entre(I2, S2)),
    assertion(cerca(I1, I2)),
    assertion(cerca(S1, S2)).

test(mediana_histograma_impar, [true(M == 2)]) :-
    mediana_histograma([1-1, 2-1, 5-1], 3, M).

test(mediana_histograma_par, [true(M =:= 2.5)]) :-
    mediana_histograma([1-1, 2-1, 3-1, 9-1], 4, M).

test(mediana_histograma_repetidos, [true(M == 4)]) :-
    mediana_histograma([0-2, 4-5, 7-2], 9, M).

:- end_tests(paralelo).
