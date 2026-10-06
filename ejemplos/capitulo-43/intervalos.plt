:- encoding(utf8).

:- begin_tests(intervalos).

cerca(A, B) :-
    abs(A - B) < 1.0e-9.

test(numero, true(I == i(2, 2))) :-
    intervalo(2, [], I).

test(variable, true(I == i(1, 2))) :-
    intervalo(x, [x-i(1, 2)], I).

test(variable_sin_intervalo, fail) :-
    intervalo(y, [x-i(1, 2)], _).

test(resta_y_coseno, true((cerca(Lo, 0.5471975511965975),
                            cerca(Hi, 1.5707963267948966)))) :-
    intervalo(x - cos(x), [x-i(pi / 3, pi / 2)], i(Lo, Hi)).

test(producto, true(I == i(-4, 2))) :-
    intervalo(x * (x + 1), [x-i(-2, 1)], I).

test(cociente, true(I == i(0.5, 1))) :-
    intervalo(1 / x, [x-i(1, 2)], I).

test(divisor_con_cero, fail) :-
    intervalo(1 / x, [x-i(-1, 1)], _).

test(cuadrado_con_cero, true(I == i(0, 4))) :-
    intervalo(x ^ 2, [x-i(-2, 1)], I).

test(cuadrado_negativo, true(I == i(1, 4))) :-
    intervalo(x ^ 2, [x-i(-2, -1)], I).

test(cubo, true(I == i(-8, 1))) :-
    intervalo(x ^ 3, [x-i(-2, 1)], I).

test(raiz_negativa, fail) :-
    intervalo(sqrt(x), [x-i(-1, 4)], _).

test(seno_con_maximo, true((cerca(Lo, -0.7568024953079282), Hi == 1))) :-
    intervalo(sin(x), [x-i(0, 4)], i(Lo, Hi)).

test(coseno_periodo, true(I == i(-1, 1))) :-
    intervalo(cos(x), [x-i(3, 7)], I).

test(sin_regla, fail) :-
    intervalo(tan(x), [x-i(1, 2)], _).

test(distinto_de_cero) :-
    distinto_de_cero(x - cos(x), [x-i(pi / 3, pi / 2)]).

test(puede_anularse, fail) :-
    distinto_de_cero(x - cos(x), [x-i(0, 1)]).

test(sin_raices) :-
    sin_raices(x ^ 2 + 1 = 0, x, i(-100, 100)).

test(encerrar_coseno, true(Is == [i(0.738525390625, 0.7391357421875)])) :-
    encerrar(cos(x) = x, x, i(-10, 10), 0.001, Is).

test(encerrar_dos, true(Is == [i(-1.414306640625, -1.41357421875),
                               i(1.41357421875, 1.414306640625)])) :-
    encerrar(x ^ 2 - 2 = 0, x, i(-3, 3), 0.001, Is).

test(encerrar_ninguna, true(Is == [])) :-
    encerrar(x ^ 2 + 1 = 0, x, i(-3, 3), 0.001, Is).

test(unir, true(Is == [i(1, 3), i(4, 5)])) :-
    intervalos:unir([i(1, 2), i(2, 3), i(4, 5)], Is).

test(contiene_punto) :-
    intervalos:contiene_punto(7, 8, pi / 2).

test(no_contiene_punto, fail) :-
    intervalos:contiene_punto(2, 4, pi / 2).

:- end_tests(intervalos).
