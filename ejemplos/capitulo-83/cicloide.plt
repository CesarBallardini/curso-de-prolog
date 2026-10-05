:- encoding(utf8).

:- begin_tests(cicloide).

test(malla, true(V == [0, 0.25, 0.5, 0.75, 1])) :-
    malla(0, 1, 4, V).

test(malla_extremos, true(V-U =:= 0-(2*pi))) :-
    malla(0, 2*pi, 7, Vs),
    Vs = [V|_],
    last(Vs, U).

test(malla_cantidad, true(L == 101)) :-
    malla(0, 3, 100, Vs),
    length(Vs, L).

test(malla_sin_intervalos, error(type_error(positive_integer, 0))) :-
    malla(0, 1, 0, _).

test(cicloide_inicio, true(P == 0.0-(-3.0))) :-
    cicloide(5, 8, 0, P).

test(cicloide_media_vuelta, true(abs(X - 5*pi) + abs(Y - 13) < 1.0e-12)) :-
    cicloide(5, 8, pi, X-Y).

test(cicloide_comun_toca_la_recta, true(abs(X - 10*pi) + abs(Y) < 1.0e-12)) :-
    cicloide(5, 5, 2*pi, X-Y).

test(puntos, true(L == 5)) :-
    puntos_cicloide(5, 5, 1, 4, Ps),
    length(Ps, L).

test(comando, true(T == "\\newcommand{\\curva}{\\drawline(0.0000,0.0000)(2.8540,5.0000)(15.7080,10.0000)(28.5619,5.0000)(31.4159,0.0000)}")) :-
    puntos_cicloide(5, 5, 1, 4, Ps),
    comando(curva, Ps, T).

test(definir_cicloide, true(T == U)) :-
    definir_cicloide(curva, 5, 8, 3.5, 100, T),
    puntos_cicloide(5, 8, 3.5, 100, Ps),
    comando(curva, Ps, U).

test(decimal_sin_exponente, true(C == `0.0000`)) :-
    X is 10 * cos(pi / 2),
    phrase(decimal(X), C).

test(decimal_negativo, true(C == `-3.0000`)) :-
    phrase(decimal(-3), C).

test(decimal_menos_cero, true(C == `0.0000`)) :-
    phrase(decimal(-1.8e-16), C).

test(par, true(C == `(1.5000,-2.0000)`)) :-
    phrase(par(1.5-(-2)), C).

:- end_tests(cicloide).
