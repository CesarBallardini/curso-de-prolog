:- encoding(utf8).

:- begin_tests(espacio).

test(coffman, [true(D-K == 24-803)]) :-
    ejemplo(coffman, P),
    optimo(P, cero, C, K),
    valido(P, C),
    duracion(C, D).

test(casa, [true(D == 28)]) :-
    ejemplo(casa, P),
    optimo(P, cero, C, _),
    valido(P, C),
    duracion(C, D).

test(inicial, [true(E == e([t1, t2, t3, t4, t5, t6, t7], [0, 0, 0], []))]) :-
    ejemplo(coffman, P),
    inicial(datos(P, cero), E).

test(sucesores_iniciales,
     [true(As == [empezar(t1, 0, 4), empezar(t2, 0, 2), empezar(t3, 0, 2)])]) :-
    ejemplo(coffman, P),
    inicial(datos(P, cero), E),
    findall(A, sucesor(datos(P, cero), E, A, _, _), As).

test(esperar, [true(A-S-C == esperar(2, 4)-e([t4, t5], [4, 4, 13], F)-0)]) :-
    ejemplo(coffman, P),
    F = [t1-4, t2-2, t3-2, t6-13],
    findall(A0-S0-C0,
            sucesor(datos(P, cero), e([t4, t5], [2, 4, 13], F), A0, S0, C0),
            [A-S-C]).

test(costo, [nondet, true(C == 11)]) :-
    ejemplo(coffman, P),
    sucesor(datos(P, cero), e([t6, t7], [2, 2, 2], [t1-2, t2-2, t3-2]),
            empezar(t6, 2, 13), _, C).

test(voraz_valido) :-
    ejemplo(casa, P),
    voraz(P, cero, C, _),
    valido(P, C).

test(ciclo, [fail]) :-
    P = proyecto([tarea(a, 1), tarea(b, 1)], [antes(a, b), antes(b, a)], 2),
    optimo(P, cero, _, _).

test(meta) :-
    meta(datos(_, cero), e([], [3, 5], [a-3, b-5])).

test(medir, [true(D-K == 28-381)]) :-
    medir(casa, cero, D, K).

test(medir_voraz, [true(D == 36)]) :-
    medir_voraz(casa, cero, D, _).

test(estimacion_inicial, [true(H == 0)]) :-
    estimacion_inicial(coffman, cero, H).

test(ver_optimo) :-
    with_output_to(string(S), ver_optimo(coffman, cero)),
    once(sub_string(S, _, _, _, "duración: 24")).

:- end_tests(espacio).
