:- encoding(utf8).

:- begin_tests(soluciones_analogia).

test(anidado, true(N-Ops == 2-[en_exterior(invertir)])) :-
    resolver(anidado, N, Ops).

test(dos_niveles, [nondet, true(D == dentro(a, encima(b, dentro(rombo,
                                                              circulo))))]) :-
    transformacion(en_exterior(en_exterior(invertir)),
                   dentro(a, encima(b, dentro(circulo, rombo))), D).

test(los_de_antes, true(N-Ops == 2-[invertir])) :-
    resolver(invertir, N, Ops).

:- end_tests(soluciones_analogia).
