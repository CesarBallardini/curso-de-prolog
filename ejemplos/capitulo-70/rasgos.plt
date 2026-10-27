:- encoding(utf8).

:- begin_tests(rasgos).

test(rasgos_entradas, [true(Ys == [1, 0])]) :-
    rasgos(entradas, [1, 0], Ys).

test(rasgos_producto, [true(Ys == [3, 2, 6])]) :-
    rasgos(producto, [3, 2], Ys).

test(ampliar, [true(E == ej([1, 1, 1], -1))]) :-
    ampliar(producto, ej([1, 1], -1), E).

test(o_exclusivo_entradas, [true(R == ciclo(1, [3, 3, 4]))]) :-
    aprender(o_exclusivo, entradas, R).

test(o_exclusivo_producto,
     [true(R == separa([-2, 2, 2, -6], [3, 3, 4, 3, 1, 2, 1, 0]))]) :-
    aprender(o_exclusivo, producto, R).

test(y_producto, [true(R == separa([-4, 2, 0, 2], [2, 2, 0]))]) :-
    aprender(y, producto, R).

test(pesos_separan_o_exclusivo) :-
    aprender(o_exclusivo, producto, separa(P, _)),
    datos(o_exclusivo, Es0),
    maplist(ampliar(producto), Es0, Es),
    maplist(bien_clasificado(P), Es).

test(separables_entradas, [true(N == 14)]) :-
    separables_con(entradas, N).

test(separables_producto, [true(N == 16)]) :-
    separables_con(producto, N).

test(conjunto_desconocido, [fail]) :-
    aprender(nand, entradas, _).

test(multiplicar, [true(P =:= 6)]) :-
    multiplicar(3, 2, P).

test(entrenar_ampliados_producto,
     [true(R == separa([-2, 2, 2, -6], [3, 3, 4, 3, 1, 2, 1, 0]))]) :-
    datos(o_exclusivo, Es),
    entrenar_ampliados(producto, Es, R).

test(entrenar_ampliados_entradas, [true(R == ciclo(1, [3, 3, 4]))]) :-
    datos(o_exclusivo, Es),
    entrenar_ampliados(entradas, Es, R).

:- end_tests(rasgos).
