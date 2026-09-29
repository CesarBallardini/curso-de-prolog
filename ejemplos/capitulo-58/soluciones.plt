:- encoding(utf8).

:- begin_tests(soluciones).

test(ejercicio_1, [true(VS-VI == top-i(1, sup))]) :-
    analizar("x := n - 1; escribir 10 / x", P),
    analisis(signos, P, [n-entre(2, sup)], estado(_, ES), OS),
    analisis(intervalos, P, [n-entre(2, sup)], estado(_, EI), OI),
    memberchk(x-VS, ES),
    memberchk(x-VI, EI),
    memberchk(division(_, _), OS),
    \+ memberchk(division(_, _), OI).

test(ejercicio_2, [true(Ss-Ts == [cero, neg]-[cero])]) :-
    findall(S, op_signos(/, neg, pos, S), Ss0),
    msort(Ss0, Ss),
    findall(T, op_signos(*, cero, neg, T), Ts).

test(paridad, [true(F-Os == nada-[siempre(rel(<>, id(x), num(0)))])]) :-
    analizar("x := 2 * n + 1; mientras x <> 0 hacer x := x - 2 fin", P),
    analisis(paridad, P, [n-entre(inf, sup)], F, Os).

test(paridad_par, [true(F == estado(paridad, [x-par]))]) :-
    analizar("x := 10; mientras x <> 0 hacer x := x - 2 fin", P),
    analisis(paridad, P, [], F, _).

test(sin_asignar, [true(Xs == [z])]) :-
    sin_asignar_texto("escribir z; z := z + 1", Xs).

test(sin_asignar_rama, [true(Xs == [y])]) :-
    sin_asignar_texto("x := 1; si x > 0 entonces y := 1 fin; escribir y",
                      Xs).

test(sin_asignar_ejemplos, [forall(programa_ejemplo(_, P)), true(Xs == [])]) :-
    sin_asignar(P, Xs).

test(estrechar, [true(I-Fuera == estado(intervalos, [i-i(0, 10)])-
                                 estado(intervalos, [i-i(10, 10)]))]) :-
    diez_estrechado(I, Fuera).

test(signos6, [true(F == estado(signos6, [i-noneg, n-noneg, s-noneg]))]) :-
    analisis_caso(signos6, promedio, [n-entre(0, sup)], F, _).

test(signos6_cubre, [forall(caso(N, _, _))]) :-
    programa_caso(N, P, Es),
    analisis(signos6, P, Es, F, Os),
    muestra(N, Cs),
    forall(member(C, Cs), cubre(F, Os, C)).

test(mcd_cualquier_a, [true(Fs == [estado([a-pos, b-pos])])]) :-
    finales_caso(mcd, [a-entre(inf, sup), b-entre(1, sup)], Fs).

test(caminos, [true(Rs == [[n*n>=0]-[n*n]])]) :-
    findall(C-S, camino_posible(cuadrado, C, S), Rs).

test(inalcanzable_si, [true(Ss == [escribir(id(x))])]) :-
    analizar("x := 0 - 1; si x > 0 entonces escribir x fin", P),
    inalcanzables(signos, P, [], Ss).

test(inalcanzable_bucle, [true(Ss == [escribir(id(x))])]) :-
    analizar("x := 1; mientras x > 0 hacer x := x + 1 fin; escribir x", P),
    inalcanzables(signos, P, [], Ss).

test(umbrales, [true(F == estado(umbrales([0, 1, 10]), [i-i(10, 10)]))]) :-
    programa_caso(diez, P, _),
    analisis_umbrales(P, [], F, _).

test(umbrales_cubre, [forall(caso(N, _, _))]) :-
    programa_caso(N, P, Es),
    analisis_umbrales(P, Es, F, Os),
    muestra(N, Cs),
    forall(member(C, Cs), cubre(F, Os, C)).

:- end_tests(soluciones).
