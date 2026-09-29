:- encoding(utf8).

:- begin_tests(soluciones_racional).

test(potencia, [true(P == fr(8, 27))]) :-
    q_potencia(fr(2, 3), 3, P).

test(potencia_negativa, [true(P == fr(9, 4))]) :-
    q_potencia(fr(2, 3), -2, P).

test(potencia_cero, [true(P == fr(1, 1))]) :-
    q_potencia(fr(-5, 7), 0, P).

% El mismo resultado que ^ sobre los racionales de SWI-Prolog.
test(como_el_sistema, [true(Q == 9r4)]) :-
    q_potencia(fr(2, 3), -2, P),
    a_nativo(P, Q),
    Q =:= 2r3 ^ -2.

test(cero_negativa, [error(evaluation_error(zero_divisor))]) :-
    q_potencia(fr(0, 1), -1, _).

test(dec_valor, [true(Q == 5r4)]) :-
    dec_valor(dec(125, -2), Q).

test(dec_suma, [true(Q == 125r4)]) :-
    dec_suma(dec(125, -2), dec(3, 1), X),
    X == dec(3125, -2),
    dec_valor(X, Q).

test(dec_producto, [true(Q == 15r4)]) :-
    dec_producto(dec(125, -2), dec(3, 0), X),
    dec_valor(X, Q).

test(dec_de_racional, [true(X == dec(375, -3))]) :-
    dec_de_racional(3r8, X).

test(tercio_no, [fail]) :-
    dec_de_racional(1r3, _).

test(fraccion_continua, [true(Cs == [4, 2, 6, 7])]) :-
    fraccion_continua(415r93, Cs).

test(ida_y_vuelta, [true(Q == 355r113)]) :-
    fraccion_continua(355r113, Cs),
    valor_fraccion_continua(Cs, Q).

test(entero, [true(Cs == [5])]) :-
    fraccion_continua(5, Cs).

test(aproximacion_pi, [true(Q == 355r113)]) :-
    mejor_aproximacion(pi, 1000, Q).

test(aproximacion_exacta, [true(Q == 1r2)]) :-
    mejor_aproximacion(0.5, 10, Q).

:- end_tests(soluciones_racional).
