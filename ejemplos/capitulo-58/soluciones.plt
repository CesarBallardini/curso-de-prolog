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

test(operar_paridad, [true(Vs == [impar, par, top, top])]) :-
    maplist(operar_paridad(+), [par, impar, top], [impar, impar, par], Vs0),
    operar_paridad(/, par, par, V4),
    append(Vs0, [V4], Vs).

% Un factor par hace par el producto aunque el otro sea top.
test(multiplicar_paridad, [true(Vs == [par, impar, top, par])]) :-
    maplist(multiplicar_paridad, [par, impar, top, top], [top, impar, impar, par],
            Vs).

test(refinar_paridad, [true(Vs == [par, impar, top])]) :-
    refinar_paridad(=, top, par, V1),
    refinar_paridad(<>, impar, impar, V2),
    refinar_paridad(<, top, par, V3),
    Vs = [V1, V2, V3].

test(refinar_paridad_imposible, [fail]) :-
    refinar_paridad(=, impar, par, _).

test(def_lee_sin_asignar, all(S == [s([x-asignada, y-sin_asignar], [y])])) :-
    def(asignar(x, bin(+, id(x), id(y))), s([x-asignada, y-sin_asignar], []),
        S).

% Un mientras sale sin vueltas o después de alguna: dos estados.
test(def_mientras, set(S == [s([x-asignada], []), s([x-sin_asignar], [])])) :-
    def(mientras(rel(<, num(0), num(1)), [asignar(x, num(1))]),
        s([x-sin_asignar], []), S).

test(leer, [true(L == [a, z])]) :-
    leer(rel(<, id(a), id(b)), [a-sin_asignar, b-asignada], [z], L).

test(estrechar_bucle, [true(I == estado(intervalos, [i-i(0, 10)]))]) :-
    estrechar(mientras(rel(<, id(i), num(10)),
                       [asignar(i, bin(+, id(i), num(1)))]),
              estado(intervalos, [i-i(0, 0)]), I).

test(representa6, all(V == [noneg])) :-
    representa6(V, [cero, pos]).

% Un conjunto sin valor propio, como neg y pos, se representa con top.
test(alfa6, [true(Vs == [noneg, top, top, nopos])]) :-
    maplist(alfa6, [[pos, cero, pos], [], [neg, pos], [neg, cero]], Vs).

test(restriccion_imposible, [fail]) :-
    Ps = [n-N],
    restriccion(Ps, n*n < 0),
    label([N]).

test(restriccion, [true(D == 4..sup)]) :-
    Ps = [n-N],
    restriccion(Ps, n > 3),
    fd_dom(N, D).

test(muertas_desde_muerto, [true(Ss == [escribir(id(x)),
                                        asignar(x, num(1))])]) :-
    phrase(muertas([escribir(id(x)), asignar(x, num(1))], muerto, []), Ss).

% Un mientras cuya condición siempre se cumple mata lo que le sigue.
test(muerta_en_mientras, [true(Ss-Sigue == []-muerto)]) :-
    phrase(muerta_en(mientras(rel(>, id(x), num(0)), [escribir(id(x))]),
                     [siempre(rel(>, id(x), num(0)))], Sigue),
           Ss).

test(rama, [true(Ss1-Ss2 == [escribir(id(x))]-[])]) :-
    phrase(rama([escribir(id(x))], nunca(c), [nunca(c)]), Ss1),
    phrase(rama([escribir(id(x))], nunca(c), []), Ss2).

test(umbral_arriba, [true(Fs == [10, 1, sup])]) :-
    maplist(umbral_arriba([0, 1, 10]), [5, 1, 11], Fs).

test(umbral_abajo, [true(Es == [1, 0, inf])]) :-
    maplist(umbral_abajo([0, 1, 10]), [5, 0, -1], Es).

test(ej12_cociente, [true(Cs == [])]) :-
    bloque_caso(cociente, B, Es),
    contextos_con_error(B, Es, Cs).

test(ej12_directo, [true(Cs == [dividir-[cero]])]) :-
    cociente_directo(B),
    contextos_con_error(B, [a-entre(inf, sup)], Cs).

test(ej12_factorial, [true(Cs == [])]) :-
    contextos_caso(factorial, Cs).

test(ej12_directo_caso, [true(Cs == [dividir-[cero]])]) :-
    contextos_directo(Cs).

:- end_tests(soluciones).
