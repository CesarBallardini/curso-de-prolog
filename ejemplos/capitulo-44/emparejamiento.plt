:- encoding(utf8).

:- begin_tests(emparejamiento).

test(variantes, all(V == [a * b + c, c + a * b, b * a + c, c + b * a])) :-
    variante(a * b + c, 2, V).

test(primera_variante, true(V == a * b + c)) :-
    once(variante(a * b + c, 2, V)).

test(un_nivel, all(V == [a * b + c, c + a * b])) :-
    variante(a * b + c, 1, V).

test(resta_no_conmuta, all(V == [a - b * c, a - c * b])) :-
    variante(a - b * c, 2, V).

test(profundidad_cero, all(V == [a + b])) :-
    variante(a + b, 0, V).

test(colectar_ac, true(E == (sin(x) * (2 + 3) = 1))) :-
    colectar_ac(sin(x) * 2 + 3 * sin(x) = 1, x, E).

test(colectar_ac_sin_regla, fail) :-
    colectar_ac(sin(x) + cos(x) = 1, x, _).

test(sin_conmutatividad, fail) :-
    ecuaciones:resolver(sin(x) * 2 + 3 * sin(x) = 1, x, _).

test(resolver_ac, all(S == [x = asin(1 / 5), x = pi - asin(1 / 5)])) :-
    resolver_ac(sin(x) * 2 + 3 * sin(x) = 1, x, S).

test(suma_sin_coeficiente, all(S == [x = log(10 / 5)])) :-
    resolver_ac(exp(x) + exp(x) * 4 = 10, x, S).

test(otra_ecuacion, all(S == [x = 9 / 3])) :-
    resolver_ac(3 * x + 2 = 11, x, S).

test(libre, error(instantiation_error)) :-
    resolver_ac(_ = 1, x, _).

:- end_tests(emparejamiento).
