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

% Cada relación de signos es exacta en la ventana de -4 a 4: da el signo
% de cada resultado concreto, y cada signo que da tiene un par que lo
% produce.
exacta(Rel, Op) :-
    forall(( member(A, [neg, cero, pos]),
             member(B, [neg, cero, pos]) ),
           ( findall(S, call(Rel, A, B, S), Ss0),
             sort(Ss0, Ss),
             findall(T, ( between(-4, 4, X), signo_de(X, A),
                          between(-4, 4, Y), signo_de(Y, B),
                          resultado(Op, X, Y, T) ),
                     Ts0),
             sort(Ts0, Ts),
             Ss == Ts )).

resultado(+, X, Y, T) :- signo_de(X + Y, T).
resultado(-, X, Y, T) :- signo_de(X - Y, T).
resultado(*, X, Y, T) :- signo_de(X * Y, T).
resultado(/, X, Y, T) :- Y =\= 0, signo_de(X // Y, T).

test(mas_exacta) :-
    exacta(mas, +).

test(menos_exacta) :-
    exacta(menos, -).

test(por_exacta) :-
    exacta(por, *).

test(cociente_exacta) :-
    exacta(cociente, /).

% mas/3 en sentido inverso: los pares de signos cuya suma puede ser cero.
test(mas_inversa, all(A-B == [cero-cero, neg-pos, pos-neg])) :-
    mas(A, B, cero).

test(por_cero, all(S == [cero])) :-
    por(cero, neg, S).

test(cociente_trunca, all(S == [cero, neg])) :-
    cociente(neg, pos, S).

% Con x positiva solo la rama del si es posible; con x negativa, solo la
% del sino, que no hace nada.
test(efecto_si, set(R == [estado([x-cero])])) :-
    efecto(si(rel(>, id(x), num(0)), [asignar(x, num(0))], []),
           estado([x-pos]), R).

test(efecto_sino, set(R == [estado([x-neg])])) :-
    efecto(si(rel(>, id(x), num(0)), [asignar(x, num(0))], []),
           estado([x-neg]), R).

% Las respuestas de una tabla llegan en un orden que no se fija: set/1.
test(efecto_asignar, set(R == [estado([x-cero]), estado([x-neg]),
                              estado([x-pos])])) :-
    efecto(asignar(x, bin(-, id(x), num(1))), estado([x-pos]), R).

test(efecto_error, set(R == [error])) :-
    efecto(escribir(bin(/, num(1), id(x))), estado([x-cero]), R).

% x - x es cero, pero para los signos pos - pos puede ser cualquiera: el
% bucle sale con x en cero o, por imprecisión, en neg.
test(efecto_mientras, set(R == [estado([x-cero]), estado([x-neg])])) :-
    efecto(mientras(rel(>, id(x), num(0)),
                    [asignar(x, bin(-, id(x), id(x)))]),
           estado([x-pos]), R).

test(muertas_caso, [true(Ms == [escribir(num(0))])]) :-
    muertas_caso(cuadrado, Ms).

test(muertas_ninguna, [true(Ms == [])]) :-
    muertas_caso(factorial, Ms).

test(alcanzadas, [true(Ss == [asignar(x, num(1))])]) :-
    alcanzadas_signos([asignar(x, num(1))], [], Ss).

:- end_tests(signos).
