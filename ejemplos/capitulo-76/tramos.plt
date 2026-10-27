:- encoding(utf8).

:- begin_tests(tramos).

test(circulos, [true(Ps == [1-4, 3-5, 4-2, 6-6])]) :-
    findall(P, marca(csenki1, P, circulo), Ps).

test(marca_de_una_casilla, [all(C == [numeral])]) :-
    marca(csenki1, 2-2, C).

test(clase, [true(C-P == numeral-(2-2))]) :-
    clase(numeral(2-2), C, P).

test(tramos_desde_1_4,
     [true(Ts == [(2-1)-[1-3, 1-2, 1-1, 2-1],
                  (2-2)-[1-3, 1-2, 2-2],
                  (2-2)-[2-4, 2-3, 2-2],
                  (5-5)-[2-4, 3-4, 4-4, 5-4, 5-5]])]) :-
    findall(Q-C, tramo(csenki1, 1-4, Q, C), Ts).

test(llegadas_desde_3_5, [true(Qs == [1-6, 1-6, 2-1, 2-2, 2-2, 4-1])]) :-
    findall(Q, tramo(csenki1, 3-5, Q, _), Qs0),
    msort(Qs0, Qs).

test(tramo_recto_entre_iguales, [all(C == [[3-1, 2-1]])]) :-
    tramo(csenki1, 4-1, 2-1, C).

test(giro_bloqueado_por_una_marca,
     [all(C == [[5-4, 4-4, 3-4, 2-4, 1-4]])]) :-
    tramo(csenki1, 5-5, 1-4, C).

test(iguales_no_alineadas, [fail]) :-
    tramo(csenki1, 1-4, 3-5, _).


test(treinta_y_ocho_tramos, [true(N == 38)]) :-
    aggregate_all(count, tramo(csenki1, _, _, _), N).

test(linea_horizontal, [true(C == [3-4, 3-3, 3-2])]) :-
    linea(3-5, 3-2, C).

test(linea_vertical, [true(C == [2-1, 3-1])]) :-
    linea(1-1, 3-1, C).

test(linea_diagonal, [fail]) :-
    linea(1-1, 2-2, _).

test(pasos, [true(A-B == [3, 4, 5]-[1, 0])]) :-
    pasos(2, 5, A),
    pasos(2, 0, B).

test(con_giro, [all(C == [[1-2, 2-2], [2-1, 2-2]])]) :-
    con_giro(1-1, 2-2, C).

test(sin_marcas_intermedias) :-
    sin_marcas_intermedias(csenki1, [1-3, 1-2, 2-2]).

test(con_marca_intermedia, [fail]) :-
    sin_marcas_intermedias(csenki1, [2-2, 2-3]).

:- end_tests(tramos).
