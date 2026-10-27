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

test(factores_lista, true(Fs == [cos(x), 1 - 2 * sin(x)])) :-
    soluciones_metodos:factores(cos(x) * (1 - 2 * sin(x)) * 3, x, Fs).

test(factores_ninguno, true(Fs == [])) :-
    soluciones_metodos:factores(2 * 3, x, Fs).

test(homogeneizar, true(B-E == 2-(u ^ 2 - 5 * (2 ^ 1 * u) + 16 = 0))) :-
    soluciones_metodos:homogeneizar(2 ^ (2 * x) - 5 * 2 ^ (x + 1) + 16 = 0,
                                    x, u, B, E).

test(homogeneizar_sin_potencias, [fail]) :-
    soluciones_metodos:homogeneizar(x ^ 2 = 4, x, u, _, _).

test(homogeneo_termino, true(E == 2 ^ 1 * u)) :-
    soluciones_metodos:homogeneo(2, x, u, 2 ^ (x + 1), E).

test(homogeneo_no_lineal, [fail]) :-
    soluciones_metodos:homogeneo(2, x, u, 2 ^ (x * x), _).

test(lineal, true(C-D == 3-2)) :-
    soluciones_metodos:lineal([1-3, 0-2], C, D).

test(lineal_sin_constante, true(C-D == 3-0)) :-
    soluciones_metodos:lineal([1-3], C, D).

test(lineal_grado_2, [fail]) :-
    soluciones_metodos:lineal([2-1, 0-2], _, _).

test(grado_par) :-
    soluciones_metodos:grado_par(4-1).

test(grado_impar, [fail]) :-
    soluciones_metodos:grado_par(3-1).

test(mitad, true(M == 2-(-5))) :-
    soluciones_metodos:mitad(4-(-5), M).

test(parcial_directo, all(S == [x = 4.0, x = -9.0])) :-
    soluciones_metodos:parcial(sqrt(x) * sqrt(x + 5) = 6, x, S).

test(subtermino, true(S == b)) :-
    soluciones_metodos:subtermino([1, 2], f(g(a, b), c), S).

test(subtermino_raiz, true(S == f(a))) :-
    soluciones_metodos:subtermino([], f(a), S).

test(reemplazo, true(T == z)) :-
    soluciones_metodos:reemplazo(x + 1, z, x + 1, T).

test(reemplazo_otro, [fail]) :-
    soluciones_metodos:reemplazo(x + 1, z, x + 2, _).

:- end_tests(soluciones_metodos).
