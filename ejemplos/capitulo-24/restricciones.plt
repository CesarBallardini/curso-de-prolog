:- encoding(utf8).

:- begin_tests(restricciones).

test(doble_de_3, true(Y == 6)) :-
    doble(3, Y).

test(mitad_de_8, true(X == 4)) :-
    doble(X, 8).

test(mitad_de_7, [fail]) :-
    doble(_, 7).

% Queda una alternativa: la segunda cláusula, que falla con N = 0.
test(factorial, [nondet, true(F == 120)]) :-
    n_factorial(5, F).

% En sentido inverso: de 120 a 5.
test(factorial_inverso, [nondet, true(N == 5)]) :-
    n_factorial(N, 120).

test(factorial_inverso_todas, all(N == [5])) :-
    n_factorial(N, 120).

test(factorial_inexistente, [fail]) :-
    n_factorial(_, 3).

test(dominio, true(D == 8..10)) :-
    X in 1..10,
    X #> 7,
    fd_dom(X, D).

test(tres_que_suman, all(Xs == [[0, 1, 5], [0, 2, 4], [1, 2, 3]])) :-
    tres_que_suman(6, Xs).

test(cantidad_de_unos, true(N == 2)) :-
    cantidad_de_unos([1, 0, 1], N).

test(cantidad_de_unos_inversa, true(A-B == 1-1)) :-
    cantidad_de_unos([A, B], 2).

test(send_more_money, all(L == [[9, 5, 6, 7, 1, 0, 8, 2]])) :-
    send_more_money(L).

test(dif_postergado, true(X == b)) :-
    distintos(X, a),
    X = b.

test(dif_falla_al_ligar, [fail]) :-
    distintos(X, a),
    X = a.

% Una expresión que no es aritmética produce un error, no una falla.
test(no_aritmetica, [error(domain_error(clpfd_expression, a), _)]) :-
    _ #= a.

:- end_tests(restricciones).
