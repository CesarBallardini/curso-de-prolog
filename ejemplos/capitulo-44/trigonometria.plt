:- encoding(utf8).

:- begin_tests(trigonometria).

test(reducir_en_seno, true(F-E == sin-(1 - 2 * u ^ 2 - u = 0))) :-
    reducir_trigonometrica(cos(2 * x) - sin(x) = 0, x, u, F, E).

test(reducir_en_coseno, true(F-E == cos-(2 * (1 - u ^ 2) + 3 * u = 3))) :-
    reducir_trigonometrica(2 * sin(x) ^ 2 + 3 * cos(x) = 3, x, u, F, E).

test(no_reducible, fail) :-
    reducir_trigonometrica(sin(x) + x = 1, x, u, _, _).

test(u_ocupada, fail) :-
    reducir_trigonometrica(sin(x) + u = 1, x, u, _, _).

test(en_funcion_de, true(E == 1 - u ^ 2 + u)) :-
    en_funcion_de(cos, x, u, sin(x) ^ 2 + cos(x), E).

test(en_funcion_de_otra_variable, true(E == sin(y) + u)) :-
    en_funcion_de(sin, x, u, sin(y) + sin(x), E).

test(angulo_doble, all(S == [x = asin(-1.0), x = pi - asin(-1.0),
                             x = asin(0.5), x = pi - asin(0.5)])) :-
    resolver_trigonometrica(cos(2 * x) - sin(x) = 0, x, S).

test(cuadrado, all(S == [x = acos(0.5), x = -acos(0.5),
                         x = acos(1.0), x = -acos(1.0)])) :-
    resolver_trigonometrica(2 * sin(x) ^ 2 + 3 * cos(x) = 3, x, S).

test(cumplen, true(Ok == [true, true, true, true])) :-
    findall(Ok1,
            ( resolver_trigonometrica(cos(2 * x) - sin(x) = 0, x, x = E),
              V is E,
              R is cos(2 * V) - sin(V),
              ( abs(R) < 1.0e-9 -> Ok1 = true ; Ok1 = false ) ),
            Ok).

test(fuera_de_rango, fail) :-
    resolver_trigonometrica(sin(x) ^ 2 = 4, x, _).

test(otra_ecuacion, all(S == [x = 9 / 3])) :-
    resolver_trigonometrica(3 * x + 2 = 11, x, S).

test(libre, error(instantiation_error)) :-
    resolver_trigonometrica(sin(_) = 0, x, _).

:- end_tests(trigonometria).
