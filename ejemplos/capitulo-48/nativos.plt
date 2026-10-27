:- encoding(utf8).

:- begin_tests(nativos).

test(rdiv, [true(X == 1r2)]) :-
    X is 1 rdiv 3 + 1 rdiv 6.

% 2r4 se lee ya en forma normal.
test(lectura_normal, [true]) :-
    X = 2r4,
    X == 1r2.

test(entero, [true(X == 1)]) :-
    X is 1r3 * 3.

test(barra_da_flotante, [true(X == 0.5)]) :-
    X is 2 / 4.

% Con la bandera prefer_rationals, / da un racional.
test(bandera, [ setup(current_prolog_flag(prefer_rationals, Antes)),
                cleanup(set_prolog_flag(prefer_rationals, Antes)),
                true(X == 1r2) ]) :-
    set_prolog_flag(prefer_rationals, true),
    X is 2 / 4.

test(ida_y_vuelta, [true(F == fr(-3, 2))]) :-
    a_nativo(fr(-3, 2), Q),
    Q == -3r2,
    de_nativo(Q, F).

test(entero_a_fr, [true(F == fr(4, 1))]) :-
    de_nativo(4, F).

test(flotante_no, [error(type_error(rational, 0.5))]) :-
    de_nativo(0.5, _).

% La misma suma que armonica_q/2 de la versión 1.
test(armonica, [true(Q == 7381r2520)]) :-
    armonica(10, Q).

test(suma_flotante, [true(S =\= 1)]) :-
    suma_repetida(0.1, 10, S).

test(suma_racional, [true(S == 1)]) :-
    suma_repetida(1r10, 10, S).

:- end_tests(nativos).
