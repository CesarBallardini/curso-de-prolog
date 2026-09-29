:- encoding(utf8).

:- begin_tests(reticulado).

test(factorial, [true(F-Os == estado(signos, [f-pos, n-top])-
                              [escribe(id(f), pos)])]) :-
    programa_caso(factorial, P, Es),
    analisis(signos, P, Es, F, Os).

% La unión pierde lo que el análisis por conjuntos distingue.
test(cuadrado, [true(F == estado(signos, [n-top, y-top]))]) :-
    programa_caso(cuadrado, P, Es),
    analisis(signos, P, Es, F, _).

test(siempre, [true(F-Os == nada-[siempre(rel(>, id(x), num(0)))])]) :-
    analizar("x := 1; mientras x > 0 hacer x := x + 1 fin", P),
    analisis(signos, P, [], F, Os).

test(nunca, [true(Os == [nunca(rel(>, id(x), num(0)))])]) :-
    analizar("x := 0 - 1; si x > 0 entonces escribir x fin", P),
    analisis(signos, P, [], _, Os).

test(alarma, [true(Os == [division(bin(/, id(s), id(n)), top),
                          escribe(bin(/, id(s), id(n)), top)])]) :-
    programa_caso(promedio, P, Es),
    analisis(signos, P, Es, _, Os).

test(sin_alarma, [true(Os == [escribe(bin(/, id(s), id(n)), top)])]) :-
    programa_caso(promedio, P, _),
    analisis(signos, P, [n-entre(1, sup)], _, Os).

test(cubre, [forall(caso(N, _, _))]) :-
    programa_caso(N, P, Es),
    analisis(signos, P, Es, F, Os),
    muestra(N, Cs),
    forall(member(C, Cs), cubre(F, Os, C)).

test(ramas, [true(N-F == 729-estado(signos, [s-top, x1-top, x2-top, x3-top,
                                             x4-top, x5-top, x6-top]))]) :-
    ramas(6, P, Es),
    finales_signos(P, Es, Fs),
    length(Fs, N),
    analisis(signos, P, Es, F, _).

:- end_tests(reticulado).
