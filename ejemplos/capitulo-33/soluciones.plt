:- encoding(utf8).

:- begin_tests(soluciones).

test(aridad_maxima, true(N == 3)) :-
    aridad_maxima(f(a, g(b, c, d), [x]), N).

test(aridad_maxima_atomo, true(N == 0)) :-
    aridad_maxima(ana, N).

test(posiciones_iguales, true(Ps == [1, 2])) :-
    posiciones_iguales(f(a, X, c), f(a, X, d), Ps).

test(posiciones_distinto_functor, [fail]) :-
    posiciones_iguales(f(a), g(a), _).

% La versión ingenua liga Y y la reemplaza también.
test(sustituir_ingenuo, true(Y-T == x-f(3, 3))) :-
    sustituir_ingenuo(x, 3, f(Y, x), T).

test(profundidad, true(P == 3)) :-
    profundidad(f(a, g(h(b)), c), P).

test(profundidad_lista, true(P == 2)) :-
    profundidad([a, b], P).

test(profundidad_variable, true(P == 0)) :-
    profundidad(_, P).

test(apariciones, true(N == 3)) :-
    apariciones(f(a, g(a, b), a), a, N).

test(apariciones_variable, true(N == 2)) :-
    apariciones(f(X, g(_, X)), X, N).

test(apariciones_ninguna, true(N == 0)) :-
    apariciones(f(a), b, N).

test(variantes, [true]) :-
    variantes(f(X, _, X), f(A, _, A)).

test(no_variantes, [fail]) :-
    variantes(f(_, _), f(A, A)).

test(variantes_no_liga, true(X-Y == a-b)) :-
    variantes(f(X), f(Y)),
    X = a,
    Y = b.

test(a_limpia, true(L == suma(producto(inc(x), num(2)), inc(y)))) :-
    a_limpia(x * 2 + y, L).

test(a_limpia_libre, [error(instantiation_error)]) :-
    a_limpia(x * _, _).

test(a_limpia_dominio, [error(domain_error(expresion, x / 2))]) :-
    a_limpia(x / 2, _).

test(valor, true(V == 7)) :-
    a_limpia(x * 2 + y, L),
    valor(L, [x-3, y-1], V).

test(valor_sin_incognita, [fail]) :-
    valor(inc(z), [x-3], _).

test(valor_determinista, true(V == 1)) :-
    valor(resta(producto(num(2), inc(x)), num(5)), [x-3], V).

test(valor_compara, [true]) :-
    valor(suma(inc(x), num(1)), [x-3], 4).

test(profundidad_atomo, true(P == 0)) :-
    profundidad(ana, P).

test(sustituir_ingenuo_sin_variables, true(T == f(3, y))) :-
    sustituir_ingenuo(x, 3, f(x, y), T).

test(evaluar, true(V == 10)) :-
    evaluar(x * x + y, [x-3, y-1], V).

test(evaluar_sin_valor, [error(existence_error(incognita, z))]) :-
    evaluar(x * z, [x-3], _).

:- end_tests(soluciones).
