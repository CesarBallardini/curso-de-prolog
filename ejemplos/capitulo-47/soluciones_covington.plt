:- encoding(utf8).

:- begin_tests(soluciones_covington).

test(ampliado, [true(V == 5.0)]) :-
    valor_ampliado(sqrt(2 ^ 2 * 4) - -1, V).

test(potencia_negativa, [true(V == 0.5)]) :-
    valor_ampliado(2 ^ -1, V).

test(potencia_no_entera,
     [error(type_error(expresion_evaluable, 2 ^ 0.5))]) :-
    valor_ampliado(2 ^ 0.5, _).

test(como_covington, [true(V == 1.5)]) :-
    valor_ampliado(2 * rec(4) + 1, V).

test(ampliado_libre, [error(instantiation_error)]) :-
    valor_ampliado(_ + 1, _).

test(ampliado_falla, [fail]) :-
    ampliado(cos(0), _).

test(operacion_ampliada, [true(V == -3)]) :-
    operacion_ampliada(-(1 + 2), V).

test(newton, [true(M == newton)]) :-
    resolver_variable(X ^ 2 = 2, M),
    abs(X - sqrt(2)) =< 1.0e-12.

test(secante, [true(M == secante)]) :-
    resolver_variable(X = cos(X), M),
    abs(X - cos(X)) =< 1.0e-12.

% La secante horizontal de Covington no detiene a Newton.
test(horizontal, [true(X-M == 0.0-newton)]) :-
    resolver_variable(X * X = X * 3, M).

test(sin_raiz, [fail]) :-
    resolver_variable(X ^ 2 + 1 = 0, _),
    number(X).

test(sin_incognita, [fail]) :-
    resolver_variable(1 + 1 = 2, _).

test(nueva_incognita, [true(A == x3)]) :-
    nueva_incognita(f(x1, x2, _), A).

test(nueva_incognita_libre, [true(A == x1)]) :-
    nueva_incognita(f(_), A).

:- end_tests(soluciones_covington).
