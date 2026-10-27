:- encoding(utf8).

:- begin_tests(soluciones_aislar).

test(dividendo, all(S == [x = 10])) :-
    resolver(x / 2 = 5, x, S).

test(divisor, all(S == [x = 12 / 4])) :-
    resolver(12 / x = 4, x, S).

test(divisor_cero, [fail]) :-
    resolver(12 / x = 0, x, _).

test(valor, all(V =:= [10])) :-
    resolver(3 - x / 2 = -2, x, x = E),
    V is E.

:- end_tests(soluciones_aislar).
