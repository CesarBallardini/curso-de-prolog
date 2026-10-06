:- encoding(utf8).

:- begin_tests(covington).

test(evaluar, [true(R == 1.5)]) :-
    R := 2 * rec(4) + 1.

test(evaluar_cociente, [true(R == 3.5)]) :-
    R := 7 / 2.

test(evaluar_resta_entera, [true(R == 2)]) :-
    R := 5 - 3.

test(evaluar_ligado) :-
    6 := 2 * 3.

test(evaluar_otra_operacion,
     [error(type_error(expresion_evaluable, 2 ^ 3))]) :-
    _ := 2 ^ 3.

test(evaluar_atomo, [error(type_error(expresion_evaluable, a + 1))]) :-
    _ := a + 1.

test(evaluar_libre, [error(instantiation_error)]) :-
    _ := _ + 1.

test(evaluar_por_cero, [error(evaluation_error(zero_divisor))]) :-
    _ := rec(0).

test(valor_c, [true(V == 0.25)]) :-
    valor_c(rec(2 * 2), V).

test(valor_c_otra, [fail]) :-
    valor_c(sqrt(4), _).

test(operacion, [true(V == 3)]) :-
    operacion(1 + 2, V).

test(operacion_numero, [fail]) :-
    operacion(3, _).

% Una respuesta por aparición: A, B y otra vez A.
test(libre_en, all(I == [1, 2, 1])) :-
    T = f(A, g(B, A)),
    libre_en(T, V),
    (   V == A
    ->  I = 1
    ;   V == B
    ->  I = 2
    ).

test(libre_en_cerrado, [fail]) :-
    libre_en(f(a, [1, 2]), _).

test(libre_en_variable, [nondet, true(V == X)]) :-
    libre_en(X, V).

test(aureo, [true(abs(X - 0.6180339887498948) =< 1.0e-12)]) :-
    resolver_libre(X + 1 = 1 / X).

test(coseno, [true(abs(X - cos(X)) =< 1.0e-12)]) :-
    resolver_libre(X = cos(X)).

test(kepler, [true(abs(E - 0.01 * sin(E) - 2.5) =< 1.0e-12)]) :-
    resolver_libre(E - 0.01 * sin(E) = 2.5).

% Los fallos de Covington: la secante horizontal, la ecuación sin
% solución, la que no converge y la raíz lejana.
test(horizontal, [fail]) :-
    resolver_libre(X * X = X * 3).

test(sin_solucion, [fail]) :-
    resolver_libre(X = X + 1).

test(no_converge, [fail]) :-
    resolver_libre(sin(_X) = 0.001).

test(raiz_lejana, [true(abs(X - 213.6383006107801) =< 1.0e-9)]) :-
    resolver_libre(sin(X) = 0.01).

test(sin_incognita, [fail]) :-
    resolver_libre(1 + 1 = 2).

test(dos_incognitas, [error(instantiation_error)]) :-
    resolver_libre(_ + _ = 3).

test(diferencia_en, [true(V-F == 3.0-(X * X - 1))]) :-
    F = X * X - 1,
    diferencia_en(X, F, 2, V).

test(paso_libre, [true(X2 == 1.3333333333333335)]) :-
    paso_libre(X, X * X - 2, secante(1.0, -1.0, 2.0, 2.0), _, X2, _).

test(paso_libre_horizontal, [fail]) :-
    paso_libre(X, X * X - X * 3, secante(1.0, -2.0, 2.0, -2.0), _, _, _).

:- end_tests(covington).
