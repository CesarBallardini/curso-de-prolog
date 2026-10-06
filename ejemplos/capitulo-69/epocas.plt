:- encoding(utf8).

:- begin_tests(epocas).

test(epoca_y, [true(P-E == [0, 2, 2]-2)]) :-
    datos(y, Es),
    epoca(1, Es, [0, 0, 0], P, E).

test(epoca_sin_errores, [true(P-E == [-2, 2, 2]-0)]) :-
    datos(o, Es),
    epoca(1, Es, [-2, 2, 2], P, E).

test(entrenar_y, [true(P-C == [-6, 4, 2]-[2, 3, 3, 2, 1, 0])]) :-
    datos(y, Es),
    entrenar(1, Es, [0, 0, 0], P, C).

test(entrenar_o, [true(P-C == [-2, 2, 2]-[2, 2, 1, 0])]) :-
    datos(o, Es),
    entrenar(1, Es, [0, 0, 0], P, C).

test(o_exclusivo_falla, [fail]) :-
    datos(o_exclusivo, Es),
    entrenar(1, Es, [0, 0, 0], _, _).

% Los mismos pesos que la versión 1, que corrige en el mismo orden.
test(igual_que_version_1, [true(P == P1)]) :-
    datos(puntos, Es),
    entrenar(0.25, Es, [0.13, -0.51, -0.35], P, C),
    entrenar_uno(0.25, Es, [0.13, -0.51, -0.35], P1, _),
    length(C, 102).

test(pesos_clasifican) :-
    datos(puntos, Es),
    entrenar(0.25, Es, [0.13, -0.51, -0.35], P, _),
    maplist(bien_clasificado(P), Es).

% Con pesos iniciales nulos la tasa solo escala los pesos: la misma
% curva, y los pesos por 4.
test(tasa_con_pesos_nulos, [true(C1 == C2)]) :-
    datos(puntos, Es),
    entrenar(0.25, Es, [0, 0, 0], P1, C1),
    entrenar(1, Es, [0, 0, 0], P2, C2),
    length(C1, 58),
    maplist([A, B]>>(abs(4 * A - B) < 1.0e-9), P1, P2).


test(curva_puntos_tasa_1, [true(length(C, 58))]) :-
    curva(puntos, 1, [0, 0, 0], _, C).

% La versión 1 usa más del doble de inferencias (46 400 y 21 758).
test(costos, [true(U > 2 * E)]) :-
    costos(puntos, 0.25, [0.13, -0.51, -0.35], U, E).

test(maximo_de_epocas, [true(N == 1000)]) :-
    maximo_de_epocas(N).

test(paso_epoca, [true(P-R-E == [0, 2, 2]-(2-[0, 2, 2])-2)]) :-
    datos(y, Es),
    paso_epoca(1, Es, [0, 0, 0], P, R, E).

% Con pesos que ya separan, la época no tiene errores y el cambio es 0.
test(paso_epoca_sin_errores, [true(P-E == [-3, 2, 2]-0)]) :-
    datos(y, Es),
    paso_epoca(1, Es, [-3, 2, 2], P, _, E).

:- end_tests(epocas).
