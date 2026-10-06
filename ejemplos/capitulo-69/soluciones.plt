:- encoding(utf8).

:- begin_tests(soluciones).

test(errores_iniciales, [true(N == 4)]) :-
    datos(puntos, Es),
    errores([0.13, -0.51, -0.35], Es, N).

test(errores_finales, [true(N == 0)]) :-
    datos(y, Es),
    errores([-6, 4, 2], Es, N).

test(entrenar_n, [true(P-C == [0, -2, 0]-[3, 3, 4, 4, 4, 4])]) :-
    datos(o_exclusivo, Es),
    entrenar_n(1, 6, Es, [0, 0, 0], P, C).

% Con un conjunto separable, las épocas sin errores siguen en la curva.
test(entrenar_n_separable, [true(C == [2, 2, 1, 0, 0])]) :-
    datos(o, Es),
    entrenar_n(1, 5, Es, [0, 0, 0], _, C).

test(bolsillo, [true(E == 1)]) :-
    puntos_con_ruido(Es),
    entrenar_bolsillo(0.25, 200, Es, [0.13, -0.51, -0.35], P, E),
    errores(P, Es, 1).

test(ruido_sin_ciclo, [fail]) :-
    puntos_con_ruido(Es),
    entrenar_o_ciclo(0.25, Es, [0.13, -0.51, -0.35], _).

test(capas_o_exclusivo) :-
    entrenar_capas(M),
    datos(o_exclusivo, Es),
    forall(member(ej(Xs, D), Es), salida_capas(M, Xs, D)).

test(binaria, [true(Bs == [1, 0])]) :-
    maplist(binaria, [1, -1], Bs).

test(tres_clases) :-
    tres_clases(Es),
    entrenar_clases(Es, M),
    forall(member(ej(Xs, C), Es), clase_de(M, Xs, C)).

test(clase_nueva, [true(C == b)]) :-
    tres_clases(Es),
    entrenar_clases(Es, M),
    clase_de(M, [3, 3], C).

test(recta, [true(abs(P + 0.7197) < 1.0e-4)]) :-
    datos(puntos, Es),
    entrenar(0.25, Es, [0.13, -0.51, -0.35], Pesos, _),
    recta(Pesos, P, O),
    abs(O - 9.5076) < 1.0e-4.

test(recta_vertical, [fail]) :-
    recta([1, 2, 0], _, _).

test(cola_igual_pasos, [true(P-N == P1-N1)]) :-
    datos(puntos, Es),
    entrenar_cola(0.25, Es, [0.13, -0.51, -0.35], P, N),
    entrenar_uno(0.25, Es, [0.13, -0.51, -0.35], P1, N1).

test(cola_menos_inferencias) :-
    datos(puntos, Es),
    inferencias(entrenar_cola(0.25, Es, [0.13, -0.51, -0.35], _, _), Ic),
    inferencias(entrenar_uno(0.25, Es, [0.13, -0.51, -0.35], _, _), Iu),
    Ic < Iu.

test(margen_cero, [true(M =:= 0)]) :-
    datos(y, Es),
    margen([-6, 4, 2], Es, M).

test(margenes_puntos) :-
    datos(puntos, Es),
    entrenar(0.25, Es, [0.13, -0.51, -0.35], P1, _),
    entrenar(1, Es, [0, 0, 0], P2, _),
    margen(P1, Es, M1),
    margen(P2, Es, M2),
    M1 > M2,
    M2 > 0.

test(anillo_sin_rasgos, [true(R = ciclo(2, _))]) :-
    anillo(Es),
    entrenar_o_ciclo(1, Es, [0, 0, 0], R).

test(anillo_cuadrados, [true(P == [14, -6, -8])]) :-
    anillo(Es0),
    maplist(cuadrados, Es0, Es),
    entrenar_o_ciclo(1, Es, [0, 0, 0], separa(P, _)).

test(errores_en, [true(N == 4)]) :-
    errores_en(puntos, [0.13, -0.51, -0.35], N).

test(bolsillo_con_ruido, [true(E == 1)]) :-
    bolsillo_con_ruido(200, _, E).

test(margen_en, [true(M > 0)]) :-
    margen_en(puntos, 1, [0, 0, 0], M).

test(probar_anillo, [true(R = ciclo(2, _))]) :-
    probar_anillo(entradas, R).

test(modelo_tres_clases, [true(length(M, 3))]) :-
    modelo_tres_clases(M).

test(costo_cola, [true(C < U)]) :-
    costo_cola(C, U).

test(epoca_contada, [true(P-E == [0, 2, 2]-2)]) :-
    datos(y, Es),
    epoca_contada(1, Es, 1, [0, 0, 0]-[E|C], P-C).

test(epoca_bolsillo_conserva, [true(B == b([0, 2, 2], [0, 0, 0], 3))]) :-
    datos(y, Es),
    epoca_bolsillo(1, Es, 1, b([0, 0, 0], [0, 0, 0], 3), B).

test(epoca_bolsillo_mejora, [true(B == b([0, 2, 2], [0, 2, 2], 3))]) :-
    datos(y, Es),
    epoca_bolsillo(1, Es, 1, b([0, 0, 0], [0, 0, 0], 4), B).

test(nand, [true(Cs == [1, 1, 1, -1])]) :-
    nand(Es),
    findall(C, member(ej(_, C), Es), Cs).

test(binaria_directa, [true(B0-B1 == 0-1)]) :-
    binaria(-1, B0),
    binaria(1, B1).

test(entrenar_clase, [true(P == a-[0, -10, -10])]) :-
    entrenar_clase([ej([0, 0], a), ej([5, 5], b)], a, P).

test(uno_contra_resto, [true(B1-B2 == ej([1], 1)-ej([2], -1))]) :-
    uno_contra_resto(a, ej([1], a), B1),
    uno_contra_resto(a, ej([2], b), B2).

test(suma, [true(S =:= 9)]) :-
    suma([1, 2, 3], [1, 2.0], S).

test(suma_de, [true(P == 5-a)]) :-
    suma_de([1, 1], a-[1, 2, 2], P).

test(distancia, [true(abs(D + 1.4) < 1.0e-9)]) :-
    distancia([0, 3, 4], 5, ej([1, 1], -1), D).

test(cuadrado, [true(C =:= 9)]) :-
    cuadrado(-3, C).

test(cuadrados, [true(E == ej([4, 0], 1))]) :-
    cuadrados(ej([-2, 0], 1), E).

:- end_tests(soluciones).
