:- encoding(utf8).

:- begin_tests(soluciones_simplificar).

test(agrupa, true(E == 3 * x)) :-
    simplificar(2 * x + (y - y) * z + x ^ 1, E).

test(agrupa_tres, true(E == 6 * x)) :-
    simplificar(x + 2 * x + 3 * x, E).

test(agrupa_izquierda, true(E == 3 * x)) :-
    simplificar(x + 2 * x, E).

test(anteriores, true(E == 6 * x)) :-
    simplificar((x * 2) * 3, E).

test(derivar, true(D == 2 * x + 3)) :-
    derivar(x ^ 2 + 3 * x, x, D).

test(derivar_otra_incognita, true(D == y)) :-
    derivar(x * y + y, x, D).

test(derivar_potencia, true(D == 3 * x ^ 2)) :-
    derivar(x ^ 3, x, D).

test(derivar_constante, true(D == 0)) :-
    derivar(y * 5, x, D).

test(derivar_resta, true(D == 2 * x - 3)) :-
    derivar(x ^ 2 - 3 * x, x, D).

test(derivar_otra_variable, true(D == 2 * y)) :-
    derivar(y ^ 2 + x, y, D).

test(derivar_dominio, [error(domain_error(expresion_derivable, sin(x)))]) :-
    derivar(sin(x), x, _).

test(derivar_libre, [error(instantiation_error)]) :-
    derivar(_, x, _).

:- end_tests(soluciones_simplificar).
