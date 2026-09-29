:- encoding(utf8).

:- begin_tests(simplificar).

test(producto, true(E == 6 * x)) :-
    simplificar((x * 2) * 3, E).

test(neutros, true(E == x)) :-
    simplificar(x * (1 + 0), E).

test(suma, true(E == 2 * x + x)) :-
    simplificar(2 * x + (y - y) * z + x ^ 1, E).

test(doble, true(E == 6 * x)) :-
    simplificar((x + x) * 3, E).

test(numero, true(E == 10)) :-
    simplificar(2 * (3 + 2), E).

test(atomo, true(E == x)) :-
    simplificar(x, E).

test(sin_regla, true(E == 0 - x)) :-
    simplificar(0 - x, E).

test(potencia, true(E == 1)) :-
    simplificar((x + y) ^ (1 - 1), E).

% Con el resultado ligado, simplificar/2 comprueba.
test(comprueba, [true]) :-
    simplificar((x * 2) * 3, 6 * x).

test(comprueba_falla, [fail]) :-
    simplificar((x * 2) * 3, x * 6).

test(libre, [error(instantiation_error)]) :-
    simplificar(x * _, _).

test(expresion_libre, [error(instantiation_error)]) :-
    simplificar(_, _).

% Ninguna regla se aplica a ningún nodo del resultado.
test(punto_fijo, [true]) :-
    simplificar((x * 2) * 3 + (y * 1 + 0) * 4 - z * 0, E),
    \+ ( sub_term(S, E), regla(S, _) ).

:- end_tests(simplificar).
