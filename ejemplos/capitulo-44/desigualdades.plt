:- encoding(utf8).

:- begin_tests(desigualdades).

test(resta_y_producto, true(S == (x > -4 / 2))) :-
    resolver_desigualdad(3 - 2 * x < 7, x, S).

test(divisor_negativo, true(S == (x < -20))) :-
    resolver_desigualdad(10 < x / -2, x, S).

test(exponencial, true(S == (x >= log(5) - 1))) :-
    resolver_desigualdad(exp(x + 1) >= 5, x, S).

test(opuesto, true(S == (x >= -(4)))) :-
    resolver_desigualdad(-x =< 4, x, S).

test(exponencial_de_negativo, fail) :-
    resolver_desigualdad(exp(x) > -1, x, _).

test(factor_nulo, fail) :-
    resolver_desigualdad(0 * x < 1, x, _).

test(dos_apariciones, fail) :-
    resolver_desigualdad(x * x < 4, x, _).

test(no_es_desigualdad, fail) :-
    resolver_desigualdad(x = 4, x, _).

test(invertida, all(I == [>, >=, <, =<])) :-
    member(R, [<, =<, >, >=]),
    invertida(R, I).

test(comprueba, true(Rs == [true, false])) :-
    resolver_desigualdad(3 - 2 * x < 7, x, x > E),
    L is E,
    findall(R, ( member(V, [L + 0.5, L - 0.5]),
                 ( 3 - 2 * V < 7 -> R = true ; R = false ) ), Rs).

test(libre, error(instantiation_error)) :-
    resolver_desigualdad(_ < 3, x, _).

:- end_tests(desigualdades).
