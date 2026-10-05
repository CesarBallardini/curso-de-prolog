:- encoding(utf8).

:- begin_tests(racional).

test(forma_normal, [true(Q == fr(-3, 2))]) :-
    fraccion(6, -4, Q).

test(cero, [true(Q == fr(0, 1))]) :-
    fraccion(0, -7, Q).

test(denominador_cero, [error(evaluation_error(zero_divisor))]) :-
    fraccion(1, 0, _).

% La forma normal hace que la igualdad sea la unificación.
test(iguales_unifican, [true]) :-
    q_valor(1/3 + 1/6, Q),
    q_valor(fr(2, 4), Q).

test(suma, [true(Q == fr(1, 2))]) :-
    q_valor(1/3 + 1/6, Q).

test(expresion, [true(Q == fr(1, 2))]) :-
    q_valor(fr(3, 4) * 2 - 1, Q).

test(opuesto, [true(Q == fr(-1, 3))]) :-
    q_valor(-(fr(1, 3)), Q).

test(cociente_cero, [error(evaluation_error(zero_divisor))]) :-
    q_valor(1 / (2 - 2), _).

test(no_es_expresion, [error(type_error(expresion_racional, 0.5))]) :-
    q_valor(1 + 0.5, _).

test(sin_instanciar, [error(instantiation_error)]) :-
    q_valor(1 + _, _).

test(comparar, [true(Os == [<, =, >])]) :-
    q_comparar(O1, fr(1, 3), fr(1, 2)),
    q_comparar(O2, fr(2, 6), fr(1, 3)),
    q_comparar(O3, fr(-1, 3), fr(-1, 2)),
    Os = [O1, O2, O3].

test(flotante, [true(F =:= 0.75)]) :-
    q_float(fr(3, 4), F).

test(armonica, [true(Q == fr(7381, 2520))]) :-
    armonica_q(10, Q).

test(armonica_cero, [true(Q == fr(0, 1))]) :-
    armonica_q(0, Q).

test(q_suma, [true(Q == fr(5, 6))]) :-
    q_suma(fr(1, 2), fr(1, 3), Q).

test(q_suma_simplifica, [true(Q == fr(1, 1))]) :-
    q_suma(fr(1, 2), fr(1, 2), Q).

test(q_resta, [true(Q == fr(1, 6))]) :-
    q_resta(fr(1, 2), fr(1, 3), Q).

test(q_resta_negativa, [true(Q == fr(-1, 6))]) :-
    q_resta(fr(1, 3), fr(1, 2), Q).

test(q_producto, [true(Q == fr(1, 3))]) :-
    q_producto(fr(2, 3), fr(1, 2), Q).

test(q_producto_cero, [true(Q == fr(0, 1))]) :-
    q_producto(fr(0, 1), fr(7, 9), Q).

test(q_cociente, [true(Q == fr(-4, 3))]) :-
    q_cociente(fr(2, 3), fr(-1, 2), Q).

test(q_cociente_por_cero, [error(evaluation_error(zero_divisor))]) :-
    q_cociente(fr(1, 2), fr(0, 1), _).

:- end_tests(racional).
