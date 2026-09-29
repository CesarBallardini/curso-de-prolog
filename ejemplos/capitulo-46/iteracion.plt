:- encoding(utf8).

:- begin_tests(iteracion).

test(funcion_igualdad, [true(F == x * x - 2)]) :-
    funcion(x * x = 2, F).

test(funcion_expresion, [true(F == x ^ 2 - 2)]) :-
    funcion(x ^ 2 - 2, F).

test(valor_flotante, [true(V =:= 0.25)]) :-
    valor_en(x ^ 2 - 2, x, 1.5, V),
    float(V).

test(valor_entero_da_flotante, [true(V == -1.0)]) :-
    valor_en(x ^ 2 - 2, x, 1, V).

test(otro_atomo, [error(existence_error(incognita, y))]) :-
    valor_en(x + y, x, 1, _).

test(ecuacion_libre, [error(instantiation_error)]) :-
    funcion(_, F),
    valor_en(F, x, 1, _).

% Un paso que divide por dos: se detiene en el primero que cambia menos
% de 0.1.
test(iterar_mitades, [true(Xs == [0.5, 0.25, 0.125, 0.0625])]) :-
    iterar(mitad, 0.1, 1.0, Xs).

test(iterar_sin_converger, [fail]) :-
    iterar(mitad, 0.0, 1.0, _).

test(iterar_paso_que_falla, [fail]) :-
    iterar(nada, 0.1, 1.0, _).

% mitad(X0, X, X, Cambio): un paso que divide por dos.
mitad(X0, X, X, Cambio) :-
    X is X0 / 2,
    Cambio is X0 - X.

% nada(X0, X, X, Cambio): un paso que siempre falla.
nada(_, _, _, _) :-
    fail.

:- end_tests(iteracion).
