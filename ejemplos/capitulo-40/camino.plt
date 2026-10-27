:- encoding(utf8).

:- begin_tests(camino).

% Las respuestas de una tabla no tienen un orden fijo: se comparan
% ordenadas.
test(desde_a, [true(Ys == [a, b, c, d])]) :-
    findall(Y, camino(a, Y), Ys0),
    msort(Ys0, Ys).

% Cada respuesta aparece una sola vez, aunque haya infinitos caminos.
test(sin_repetidos, [true(N == 12)]) :-
    aggregate_all(count, camino(_, _), N).

test(desde_d, [fail]) :-
    camino(d, _).

test(verificar, [true]) :-
    camino(b, d).

test(no_hay, [fail]) :-
    camino(d, a).

% Sin tabla, las respuestas se repiten: las primeras ocho son dos vueltas.
test(prolog_repite, [true(Ys == [b, c, a, d, b, c, a, d])]) :-
    findall(Y, limit(8, camino_prolog(a, Y)), Ys).

test(antepasados_de_eva, [true(As == [ana, juan, luis])]) :-
    findall(A, antepasado_izq(A, eva), As0),
    msort(As0, As).

test(descendientes_de_juan, [true(Ds == [ana, eva, luis, pedro])]) :-
    findall(D, antepasado_izq(juan, D), Ds0),
    msort(Ds0, Ds).

:- end_tests(camino).
