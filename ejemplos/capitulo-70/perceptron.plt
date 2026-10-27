:- encoding(utf8).

:- begin_tests(perceptron).

test(salida_positiva, [true(C == 1)]) :-
    salida([-3, 2, 2], [1, 1], C).

test(salida_ligada, [fail]) :-
    salida([-3, 2, 2], [1, 0], 1).

test(salida_negativa, [true(C == -1)]) :-
    salida([-3, 2, 2], [1, 0], C).

% Una suma exactamente nula da la clase 1.
test(salida_cero, [true(C == 1)]) :-
    salida([-2, 2, 2], [1, 0], C).

test(corregir_bien_clasificado, [true(P == [-3, 2, 2])]) :-
    corregir(1, ej([1, 1], 1), [-3, 2, 2], P).

% Clase deseada -1, salida 1: cada peso resta 2·Xi, y el sesgo 2.
test(corregir_mal_clasificado, [true(P == [-2, -2, 0])]) :-
    corregir(1, ej([1, 0], -1), [0, 0, 0], P).

test(entrenar_y, [true(P-N == [-6, 4, 2]-18)]) :-
    datos(y, Es),
    entrenar_uno(1, Es, [0, 0, 0], P, N).

test(entrenar_o, [true(P-N == [-2, 2, 2]-9)]) :-
    datos(o, Es),
    entrenar_uno(1, Es, [0, 0, 0], P, N).

test(pesos_finales_clasifican) :-
    datos(y, Es),
    entrenar_uno(1, Es, [0, 0, 0], P, _),
    forall(member(E, Es), bien_clasificado(P, E)).

% La cantidad de pasos de Csenki para su tabla 1.4.
test(entrenar_puntos, [true(N == 801)]) :-
    datos(puntos, Es),
    entrenar_uno(0.25, Es, [0.13, -0.51, -0.35], _, N).

test(o_exclusivo_no_termina, [true(R == inference_limit_exceeded)]) :-
    datos(o_exclusivo, Es),
    call_with_inference_limit(entrenar_uno(1, Es, [0, 0, 0], _, _),
                              100_000, R).

test(ya_entrenado, [true(N == 0)]) :-
    datos(o, Es),
    entrenar_uno(1, Es, [-2, 2, 2], _, N).

test(inferencias, [true(I > 0)]) :-
    inferencias(salida([0, 1], [1], _), I).


test(pasos_y, [true(P-N == [-6, 4, 2]-18)]) :-
    pasos(y, 1, [0, 0, 0], P, N).

test(ajustar, [true(W =:= 1.5)]) :-
    ajustar(0.25, 1, 2, W).

test(ajustar_negativo, [true(W =:= -1)]) :-
    ajustar(-2, 1, 1, W).

test(sumar_producto, [true(S =:= 7)]) :-
    sumar_producto(2, 3, 1, S).

:- end_tests(perceptron).
