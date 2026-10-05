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

test(nombrar, true(T == [si(a, b, c)-si_1, mientras(d, e)-mientras_2])) :-
    nombrar([si(a, b, c), mientras(d, e)], 1, T).

test(compuesta, fail) :-
    compuesta(escribir(_)).

test(llamada, true(L == si_1(1, 2, A, B, S0, S))) :-
    llamada(si_1, [x-1, y-2], [x-A, y-B], S0, S, L).

test(definicion, true(N == 2)) :-
    K = mientras(rel(>, id(n), num(0)),
                 [escribir(id(n)), asignar(n, bin(-, id(n), num(1)))]),
    findall(C, definicion(K, mientras_1, [n], [K-mientras_1], C), Cs),
    length(Cs, N).

test(control_mini_valor, all(A-V == [dejar(true)-3])) :-
    control_mini([], valor(x, [x-3], V), A).

test(control_mini_comparacion, true(A == dejar(true))) :-
    control_mini([], 3 < 4, A).

test(control_mini_falsa, fail) :-
    control_mini([], 3 > 4, _).

test(comparaciones, true(N == 6)) :-
    findall(C, comparacion(C), Cs),
    length(Cs, N).

test(listar_especializado, true(S == "principal([1|A], A).\n")) :-
    with_output_to(string(S), listar_especializado([escribir(num(1))])).

test(listar_ejemplo, true(sub_string(S, 0, _, _, "principal(A, B) :-"))) :-
    with_output_to(string(S), listar_ejemplo(cuenta)).

:- end_tests(especializar).
