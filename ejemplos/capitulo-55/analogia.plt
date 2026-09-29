:- encoding(utf8).

:- begin_tests(analogia).

test(invertir, true(N-Ops == 2-[invertir])) :-
    resolver(invertir, N, Ops).

test(dos_pasos, true(N-Ops == 3-[invertir, relacion(encima)])) :-
    resolver(dos_pasos, N, Ops).

test(quitar, true(N-Ops == 2-[quitar_exterior])) :-
    resolver(quitar, N, Ops).

test(dos_lecturas, true(N-Ops == 2-[invertir])) :-
    resolver(dos_lecturas, N, Ops).

test(dos_lecturas_sin_la_segunda,
     true(X-Ops == dentro(cuadrado, circulo)-[interior(cuadrado),
                                              exterior(circulo)])) :-
    analogia(dentro(circulo, cuadrado) es_a dentro(cuadrado, circulo),
             dentro(triangulo, rombo) es_a X,
             [dentro(cuadrado, circulo)], Ops).

test(sin_respuesta, fail) :-
    resolver(sin_respuesta, _, _).

test(operacion, all(Op == [invertir])) :-
    transformacion(Op, dentro(cuadrado, triangulo),
                   dentro(triangulo, cuadrado)).

test(aplicar, [nondet, true(D == encima(rombo, circulo))]) :-
    transforma([invertir, relacion(encima)], dentro(circulo, rombo), D).

test(cambiar, all(F == [circulo, triangulo, rombo])) :-
    transformacion(cambiar(F), cuadrado, _).

:- end_tests(analogia).
