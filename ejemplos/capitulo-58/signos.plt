:- encoding(utf8).

:- begin_tests(signos).

test(suma, [true(Ss == [cero, neg, pos])]) :-
    findall(S, op_signos(+, pos, neg, S), Ss0),
    msort(Ss0, Ss).

test(cociente, [true(Ss == [cero, pos])]) :-
    findall(S, op_signos(/, pos, pos, S), Ss0),
    msort(Ss0, Ss).

test(division_por_cero, [true(Ss == [error])]) :-
    findall(S, op_signos(/, pos, cero, S), Ss).

test(posible) :-
    posible(<, neg, pos),
    posible(=, cero, cero),
    \+ posible(<>, cero, cero),
    \+ posible(>, neg, pos).

test(rango, [true(Ss == [cero, pos])]) :-
    findall(S, signo_en(entre(0, sup), S), Ss).

test(cuadrado, [true(Fs == [estado([n-cero, y-cero]), estado([n-neg, y-pos]),
                            estado([n-pos, y-pos])])]) :-
    programa_caso(cuadrado, P, Es),
    finales_signos(P, Es, Fs).

test(muerta, [true(Ms == [escribir(num(0))])]) :-
    programa_caso(cuadrado, P, Es),
    muertas_signos(P, Es, Ms).

test(promedio_error) :-
    programa_caso(promedio, P, Es),
    finales_signos(P, Es, Fs),
    memberchk(error, Fs).

test(promedio_seguro, [true(Fs == [estado([i-pos, n-pos, s-cero]),
                                   estado([i-pos, n-pos, s-pos])])]) :-
    programa_caso(promedio, P, _),
    finales_signos(P, [n-entre(1, sup)], Fs).

% Los estados donde a o b dejan de ser positivas no salen del bucle.
test(mcd, [true(Fs == [estado([a-pos, b-pos])])]) :-
    programa_caso(mcd, P, Es),
    finales_signos(P, Es, Fs).

% Un bucle que no termina no tiene estados finales, y la tabla termina.
test(sin_fin, [true(Fs == [])]) :-
    analizar("x := 1; mientras x > 0 hacer x := x + 1 fin", P),
    finales_signos(P, [], Fs).

:- end_tests(signos).
