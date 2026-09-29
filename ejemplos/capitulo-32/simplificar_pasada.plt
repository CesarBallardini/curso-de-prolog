:- encoding(utf8).

:- begin_tests(simplificar_pasada).

test(regla_numeros, [nondet, true(E == 5)]) :-
    regla(2 + 3, E).

test(regla_neutro, [nondet, true(E == x)]) :-
    regla(x * 1, E).

test(regla_ninguna, [fail]) :-
    regla(x + y, _).

% A 0 * 1 se aplican tres reglas, en el orden de las cláusulas.
test(regla_varias, all(E == [0, 0, 0])) :-
    regla(0 * 1, E).

test(raiz_sin_regla, true(E == x * (1 + 0))) :-
    simplificar_raiz(x * (1 + 0), E).

test(raiz, true(E == x)) :-
    simplificar_raiz(x + 0, E).

test(pasada, true(E == x)) :-
    simplificar_pasada(x * (1 + 0), E).

% Una pasada aplica una sola regla en cada nodo.
test(pasada_incompleta, true(E == 3 * (2 * x))) :-
    simplificar_pasada((x * 2) * 3, E).

test(pasada_atomo, true(E == x)) :-
    simplificar_pasada(x, E).

test(repetido, true(E == 6 * x)) :-
    simplificar_repetido((x * 2) * 3, E).

test(repetido_suma, true(E == 2 * x + x)) :-
    simplificar_repetido(2 * x + (y - y) * z + x ^ 1, E).

test(suma_de_prueba, true(E == 0 + y * 1 * 3 + y * 2 * 3)) :-
    suma_de_prueba(2, E).

test(verificando, true(E == 6 * x)) :-
    simplificar_verificando((x * 2) * 3, E).

test(verificando_libre, [error(instantiation_error)]) :-
    simplificar_verificando(x * _, _).

% Las dos versiones completas dan el mismo resultado.
test(verificando_igual_repetido, true(A == B)) :-
    suma_de_prueba(50, E),
    simplificar_verificando(E, A),
    simplificar_repetido(E, B).

:- end_tests(simplificar_pasada).
