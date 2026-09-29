:- encoding(utf8).

:- begin_tests(soluciones_ebg).

test(pesado, [true(R =@= (pesado(A) :- [peso(A, P), volumen(A, V),
                                         D is P / V, D > 1]))]) :-
    aprender_is(bloque1, pesado(bloque1), R).

test(corcho, [fail]) :-
    aprender_is(corcho1, pesado(corcho1), _).

test(explicar, [true]) :-
    hechos_is(bloque1, Hs),
    once(explicar_is(Hs, pesado(bloque1))).

:- end_tests(soluciones_ebg).
