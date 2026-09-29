:- encoding(utf8).

:- begin_tests(soluciones_metodos).

valores(Soluciones, Vs) :-
    findall(V, ( member(_ = E, Soluciones), V is E ), Vs0),
    msort(Vs0, Vs).

% Ejercicio 6.
test(factores, all(S == [x = acos(0), x = -acos(0),
                         x = asin(1 / 2), x = pi - asin(1 / 2)])) :-
    resolver_factores(cos(x) * (1 - 2 * sin(x)) = 0, x, S).

test(sin_factores, [fail]) :-
    ecuaciones:resolver(cos(x) * (1 - 2 * sin(x)) = 0, x, _).

test(factor_x, all(S == [x = 0, x = sqrt(4), x = -sqrt(4)])) :-
    resolver_factores(x * (x ^ 2 - 4) = 0, x, S).

test(no_producto, all(S == [x = 9 / 3])) :-
    resolver_factores(3 * x + 2 = 11, x, S).

% Ejercicio 7.
test(homogeneo, true(Vs =@= [1.0, 3.0])) :-
    findall(S, resolver_homogeneo(2 ^ (2 * x) - 5 * 2 ^ (x + 1) + 16 = 0,
                                  x, S), Ss),
    valores(Ss, Vs).

test(sin_homogeneo, [fail]) :-
    ecuaciones:resolver(2 ^ (2 * x) - 5 * 2 ^ (x + 1) + 16 = 0, x, _).

test(no_lineal, [fail]) :-
    resolver_homogeneo(2 ^ (x ^ 2) - 2 ^ x = 0, x, _).

test(una_potencia, all(S == [x = log(16 / 2) / log(2)])) :-
    resolver_homogeneo(2 ^ (x + 1) = 16, x, S).

% Ejercicio 8.
test(bicuadrada, all(S == [x = sqrt(4.0), x = -sqrt(4.0),
                           x = sqrt(1.0), x = -sqrt(1.0)])) :-
    resolver_bicuadrada(x ^ 4 - 5 * x ^ 2 + 4 = 0, x, S).

test(no_bicuadrada, all(S == [x = 2.0, x = 1.0])) :-
    resolver_bicuadrada(x ^ 2 - 3 * x + 2 = 0, x, S).

% Ejercicio 12.
test(parcial, all(S == [x = 4.0, x = -9.0])) :-
    resolver_parcial(sqrt(x) * sqrt(x + 5) = 6, x, S).

test(sin_parcial, [fail]) :-
    ecuaciones:resolver(sqrt(x) * sqrt(x + 5) = 6, x, _).

test(aislar_parcial, all(E == [(x + 1) * (x - 1) = exp(3)])) :-
    aislar_parcial(log((x + 1) * (x - 1)) = 3, x, E).

test(parcial_lado, [fail]) :-
    aislar_parcial(x * x = 3 * x, x, _).

test(parcial_logaritmos, all(S == [x = sqrt(exp(3) + 1),
                                   x = -sqrt(exp(3) + 1)])) :-
    resolver_parcial(log(x + 1) + log(x - 1) = 3, x, S).

:- end_tests(soluciones_metodos).
