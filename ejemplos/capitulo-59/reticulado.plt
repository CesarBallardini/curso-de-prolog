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

% Las dos ramas asignan positivos: la unión es pos.
test(sentencia_si, [true(E-Os == estado(signos, [x-top, y-pos])-[])]) :-
    phrase(abs_sentencia(si(rel(>, id(x), num(0)), [asignar(y, num(1))],
                            [asignar(y, num(2))]),
                         signos, [x-top, y-cero], E),
           Os).

test(sentencia_escribir, [true(E-Os == estado(signos, [x-neg])-
                                       [escribe(id(x), neg)])]) :-
    phrase(abs_sentencia(escribir(id(x)), signos, [x-neg], E), Os).

% top restringido por x > 0 es pos; por x =< 0, neg o cero, que es top.
test(partir, [true(Si-No-Os == estado(signos, [x-pos])-
                               estado(signos, [x-top])-[])]) :-
    phrase(partir(rel(>, id(x), num(0)), estado(signos, [x-top]), Si, No),
           Os).

test(partir_siempre, [true(No-Os == nada-[siempre(rel(>, id(x), num(0)))])]) :-
    phrase(partir(rel(>, id(x), num(0)), estado(signos, [x-pos]), _, No),
           Os).

test(partir_nada, [true(Si-No-Os == nada-nada-[])]) :-
    phrase(partir(rel(>, id(x), num(0)), nada, Si, No), Os).

test(unir_estados, [true(E == estado(signos, [x-top, y-pos]))]) :-
    unir_estados(estado(signos, [x-cero, y-pos]),
                 estado(signos, [x-pos, y-pos]), E).

test(unir_nada) :-
    unir_estados(nada, estado(signos, [x-pos]), E1),
    unir_estados(estado(signos, [x-pos]), nada, E2),
    E1 == estado(signos, [x-pos]),
    E2 == E1.

test(ensanchar_estados, [true(E == estado(signos, [x-top]))]) :-
    ensanchar_estados(estado(signos, [x-cero]), estado(signos, [x-pos]), E).

% El invariante del bucle de factorial: f positiva, n de cualquier signo.
test(cabeza, all(I == [estado(signos, [f-pos, n-top])])) :-
    cabeza(mientras(rel(>, id(n), num(0)),
                    [ asignar(f, bin(*, id(f), id(n))),
                      asignar(n, bin(-, id(n), num(1))) ]),
           estado(signos, [f-pos, n-pos]), I).

test(dom_constante, [true(Vs == [neg, cero, pos])]) :-
    maplist(dom_constante(signos), [-3, 0, 7], Vs).

test(dom_unir, [true(Vs == [pos, top, top])]) :-
    dom_unir(signos, pos, pos, V1),
    dom_unir(signos, cero, pos, V2),
    dom_unir(signos, top, neg, V3),
    Vs = [V1, V2, V3].

% Las dos cláusulas de dom_contiene/3 para signos admiten top: tras la
% primera queda la segunda por probar.
test(dom_contiene, [nondet]) :-
    dom_contiene(signos, top, -5),
    dom_contiene(signos, pos, 3),
    \+ dom_contiene(signos, pos, 0).

test(dom_refinar, [true(V == pos)]) :-
    dom_refinar(signos, >, top, cero, V).

test(dom_refinar_imposible, [fail]) :-
    dom_refinar(signos, >, neg, pos, _).

:- end_tests(reticulado).
