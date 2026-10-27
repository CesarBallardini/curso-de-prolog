:- encoding(utf8).

:- begin_tests(soluciones_reglas).

% Ejercicio 3.
test(con_medida, [fail]) :-
    colectar:resolver(x * x + x = 6, x, _).

test(sin_medida, true(R == inference_limit_exceeded)) :-
    call_with_inference_limit(resolver_sin_medida(x * x + x = 6, x, _),
                              200000, R).

test(aumenta, true(E == (x * x + x = 6))) :-
    colectar_sin_medida(x ^ 2 + x = 6, x, E).

test(final, all(S == [x = 2.0, x = -3.0])) :-
    ecuaciones:resolver(x * x + x = 6, x, S).

% Ejercicio 4.
test(potencias, all(S == [x = asin(0.125 ^ (1 / 3)),
                          x = pi - asin(0.125 ^ (1 / 3))])) :-
    colectar:resolver(sin(x) ^ 2 * sin(x) = 0.125, x, S).

test(potencias_valor, true(abs(V - 0.5235987755982989) < 1.0e-9)) :-
    colectar:resolver(sin(x) ^ 2 * sin(x) = 0.125, x, x = E),
    !,
    V is E.

test(exponentes, all(S == [x = 32 ^ (1 / 5)])) :-
    colectar:resolver(x ^ 2 * x ^ 3 = 32, x, S).

test(sin_coeficiente, all(S == [x = 6 / 3])) :-
    colectar:resolver(x + 2 * x = 6, x, S).

% Ejercicio 5.
test(cociente, all(S == [x = log(5)])) :-
    ecuaciones:resolver(exp(2 * x) / exp(x) = 5, x, S).

test(identidad, [fail]) :-
    ecuaciones:resolver(3 ^ (x + 2) / 3 ^ x = 9, x, _).

test(identidad_valores, true(Vs == [])) :-
    ecuaciones:valores(3 ^ (x + 2) / 3 ^ x = 9, x, Vs).

test(expansion_coleccion, true(X \== W)) :-
    soluciones_reglas:term_expansion(
        coleccion(si('~>'(W + W, 2 * W), con(W))), C),
    C = colectar:(regla(X, W + W, 2 * W) :- con(X, W)).

test(expansion_atraccion,
     true(C =@= atraer:regla(_, log(U) - log(V), log(U / V)))) :-
    soluciones_reglas:term_expansion(
        atraccion('~>'(log(U) - log(V), log(U / V))), C).

test(expansion_otro_termino, [fail]) :-
    soluciones_reglas:term_expansion(otra, _).

:- end_tests(soluciones_reglas).
