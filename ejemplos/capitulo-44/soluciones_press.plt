:- encoding(utf8).

:- begin_tests(soluciones_press).

% Ejercicio 13.
test(cubo_negativo, true(S == (x > -(8 ^ (1 / 3))))) :-
    desigualdades:resolver_desigualdad(x ^ 3 + 1 > -7, x, S).

test(cubo_valor, true(V =:= -2.0)) :-
    desigualdades:resolver_desigualdad(x ^ 3 + 1 > -7, x, x > E),
    V is E.

test(quinta, true(S == (x =< (64 / 2) ^ (1 / 5)))) :-
    desigualdades:resolver_desigualdad(2 * x ^ 5 =< 64, x, S).

test(potencia_par, fail) :-
    desigualdades:resolver_desigualdad(x ^ 2 < 4, x, _).

test(raiz_impar, true(R == 27 ^ (1 / 3))) :-
    raiz_impar(27, 3, R).

test(raiz_impar_negativa, true(R == -(27 ^ (1 / 3)))) :-
    raiz_impar(-27, 3, R).

% Ejercicio 14.
test(en_el_intervalo, true(Vs == [1.4142135623730951])) :-
    valores_en(x ^ 2 - 2 = 0, x, i(0, 3), Vs).

test(sin_raices, true(Vs == [])) :-
    valores_en(x ^ 2 + 1 = 0, x, i(-10, 10), Vs).

test(fuera_del_intervalo, true(Vs == [])) :-
    valores_en(x ^ 3 - 2 * x - 5 = 0, x, i(-1, 1), Vs).

test(entre) :-
    soluciones_press:entre(1, 2, 1.5).

test(no_entre, fail) :-
    soluciones_press:entre(1, 2, 3).

:- end_tests(soluciones_press).
