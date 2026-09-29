:- encoding(utf8).

:- begin_tests(especializar).

test(construcciones, [true(Nombres == [mientras_1, si_2])]) :-
    programa_ejemplo(mcd, P),
    construcciones(P, Tabla),
    pairs_values(Tabla, Nombres).

test(factorial, [true(Cs =@= [ (principal(S0, S) :-
                                   mientras_1(1, 5, F, _, S0, [F|S])),
                               (mientras_1(A, B, C, D, E, G) :-
                                   B > 0,
                                   H is A * B,
                                   I is B - 1,
                                   mientras_1(H, I, C, D, E, G)),
                               (mientras_1(J, K, J, K, L, L) :-
                                   K =< 0) ])]) :-
    programa_ejemplo(factorial, P),
    especializar_programa(P, Cs).

% Sin bucles, todo se calcula al especializar.
test(sin_bucles, [true(Cs =@= [(principal([6, 6|S], S) :- true)])]) :-
    analizar("x := 2 * 3; escribir x; y := x + z; escribir y", P),
    especializar_programa(P, Cs).

test(vacio, [true(S == [])]) :-
    correr_especializado([], S).

% La versión especializada escribe lo mismo que el intérprete.
test(como_el_interprete, [forall(programa_ejemplo(_, P)),
                          true(Especializado == Interprete)]) :-
    correr_especializado(P, Especializado),
    interpretar(P, Interprete).

test(menos_inferencias) :-
    programa_ejemplo(suma, P),
    inferencias(interpretar(P, _), N1),
    inferencias(correr_especializado(P, _), N2),
    N2 * 5 < N1.

test(division_por_cero_en_ejecucion, [error(evaluation_error(zero_divisor))]) :-
    analizar("mientras x < 1 hacer x := 1 / x fin", P),
    correr_especializado(P, _).

:- end_tests(especializar).
