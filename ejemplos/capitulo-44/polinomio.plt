:- encoding(utf8).

:- begin_tests(polinomio).

test(forma_normal, true(Ms == [2-1, 1-(-2), 0-5])) :-
    forma_normal((x + 1) * (x - 1) - 2 * (x - 3), x, Ms).

test(semejantes, true(Ms == [2-(-4), 1-1])) :-
    forma_normal(-(x ^ 2) + x - 3 * x ^ 2, x, Ms).

test(nulo, true(Ms == [])) :-
    forma_normal(x - x, x, Ms).

test(cociente, true(Ms == [1-0.5, 0-(-0.25)])) :-
    forma_normal(x / 2 - 1 / 4, x, Ms).

test(no_polinomio, [fail]) :-
    forma_normal(x + sin(x), x, _).

test(division_por_x, [fail]) :-
    forma_normal(1 / x, x, _).

test(otra_incognita, [fail]) :-
    forma_normal(x + y, x, _).

test(termino, true(T == -4 * x ^ 2 + x - 3)) :-
    polinomio_termino([2-(-4), 1-1, 0-(-3)], x, T).

test(termino_asociado, true(T == x ^ 3 + 2 * x ^ 2 + x + 1)) :-
    forma_normal(1 + (x + (2 * x ^ 2 + x ^ 3)), x, Ms),
    polinomio_termino(Ms, x, T).

test(termino_vacio, true(T == 0)) :-
    polinomio_termino([], x, T).

test(normalizar, true(E == (2 ^ (2 * x + 1) = 32))) :-
    normalizar(2 ^ (x + (x + 1)) = 32, x, E).

test(normalizar_sin_x, true(E == (sin(y) + 2 * 3 = x))) :-
    normalizar(sin(y) + 2 * 3 = x, x, E).

test(cuadratica, all(S == [x = 2.0, x = 1.0])) :-
    resolver(x ^ 2 - 3 * x + 2 = 0, x, S).

test(doble, all(S == [x = 1])) :-
    resolver(x ^ 2 - 2 * x + 1 = 0, x, S).

test(sin_raices_reales, [fail]) :-
    resolver(x ^ 2 + x + 1 = 0, x, _).

test(lineal, all(S == [x = 2])) :-
    resolver(2 * x + 3 * x = 10, x, S).

test(ambos_lados, all(S == [x = 2.0, x = -2.0])) :-
    resolver((x + 1) ^ 2 = 2 * x + 5, x, S).

test(exponentes, all(S == [x = (log(32) / log(2) - 1) / 2])) :-
    resolver(2 ^ x * 2 ^ (x + 1) = 32, x, S).

test(exponenciales, all(S == [x = log(5) / 3])) :-
    resolver(exp(x) * exp(2 * x) = 5, x, S).

test(logaritmos, all(S == [x = sqrt(exp(3) + 1), x = -sqrt(exp(3) + 1)])) :-
    resolver(log(x + 1) + log(x - 1) = 3, x, S).

test(cubica, [fail]) :-
    resolver(x ^ 3 - 2 * x - 5 = 0, x, _).

test(resolver_polinomio, all(S == [x = 3.0, x = -1.0])) :-
    resolver_polinomio([2-1, 1-(-2), 0-(-3)], x, S).

test(libre, [error(instantiation_error)]) :-
    resolver(_ = 3, x, _).

test(monomios, true(Ms == [2-1, 1-(-1), 0-3])) :-
    polinomio:monomios(x * (x - 1) + 3, x, Ms).

test(monomios_signo, true(Ms == [2-(-1)])) :-
    polinomio:monomios(-(x ^ 2), x, Ms).

test(monomios_no_polinomio, [fail]) :-
    polinomio:monomios(sin(x), x, _).

test(semejantes_directo, true(Ms == [1-1, 0-3])) :-
    polinomio:semejantes([0-1, 2-3, 0-2, 2-(-3), 1-1], Ms).

test(sumar_grupo, true(Ms == [2-3, 0-1])) :-
    polinomio:sumar_grupo(2-[1, 2], [0-1], Ms).

test(sumar_grupo_nulo, true(Ms == [0-1])) :-
    polinomio:sumar_grupo(2-[1, -1], [0-1], Ms).

test(colectar_normal, true(E == (2 ^ (2 * x + 1) = 32))) :-
    colectar_normal(2 ^ (x + (x + 1)) = 32, x, E).

test(colectar_normal_no_reduce, [fail]) :-
    colectar_normal((x + 1) ^ 2 = 4, x, _).

test(resolver_, all(S == [x = 2.0, x = 1.0])) :-
    polinomio:resolver_(x ^ 2 - 3 * x + 2 = 0, x, S).

:- end_tests(polinomio).
