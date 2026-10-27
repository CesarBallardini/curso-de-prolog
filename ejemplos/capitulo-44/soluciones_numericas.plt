:- encoding(utf8).

:- begin_tests(soluciones_numericas).

cerca(A, B) :-
    abs(A - B) < 1.0e-9.

% Ejercicio 9.
test(derivada_coseno, true(D == -sin(x) - 1)) :-
    derivar_mas(cos(x) - x, x, D).

test(derivada_cociente, true(D == -1 / x ^ 2)) :-
    derivar_mas(1 / x, x, D).

test(derivada_logaritmo, true(D == 1 / x)) :-
    derivar_mas(log(x), x, D).

test(no_derivable, [error(domain_error(expresion_derivable, tan(x)))]) :-
    derivar_mas(tan(x), x, _).

test(coseno, [true(cerca(R, 0.7390851332151607)), nondet]) :-
    resolver_mas(cos(x) = x, x, x = R).

test(aurea, true(maplist(cerca, Rs, [-1.618033988749895,
                                      0.6180339887498948]))) :-
    findall(R, resolver_mas(x + 1 = 1 / x, x, x = R), Rs).

test(simbolica_primero, all(S == [x = 9 / 3])) :-
    resolver_mas(3 * x + 2 = 11, x, S).

% Ejercicio 10.
test(ciclo, true(Xs == [0, 1, 0, 1, 0, 1])) :-
    pasos_newton(x ^ 3 - 2 * x + 2, x, 0, 5, Xs).

test(pendiente_nula, true(Xs == [1, 0])) :-
    pasos_newton(x ^ 2 + 1, x, 1, 5, Xs).

test(pendiente_inicial, true(Xs == [0])) :-
    pasos_newton(x ^ 2 - 2, x, 0, 5, Xs).

test(una_raiz, all(R =:= [-1.7692923542386314])) :-
    ecuaciones:resolver(x ^ 3 - 2 * x + 2 = 0, x, x = R).

test(derivada_sin_simplificar, true(D == cos(x) * 1 * x + sin(x) * 1)) :-
    soluciones_numericas:derivada(sin(x) * x, x, D).

test(derivada_no_derivable,
     [error(domain_error(expresion_derivable, tan(x)))]) :-
    soluciones_numericas:derivada(tan(x), x, _).

test(pasos, true(Xs == [1.5, 1.4166666666666667])) :-
    soluciones_numericas:pasos(x ^ 2 - 2, 2 * x, x, 1, 2, Xs).

test(pasos_cero, true(Xs == [])) :-
    soluciones_numericas:pasos(x ^ 2 - 2, 2 * x, x, 1, 0, Xs).

test(pasos_pendiente_nula, true(Xs == [])) :-
    soluciones_numericas:pasos(x ^ 2 - 2, 2 * x, x, 0, 3, Xs).

:- end_tests(soluciones_numericas).
