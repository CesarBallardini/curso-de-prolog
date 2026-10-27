:- encoding(utf8).

:- begin_tests(soluciones).

test(inicial, [true(K == 14)]) :-
    inicial(en_su_agujero(3), T),
    clavijas(T, K),
    arg(3, T, 0).

test(meta_en_su_agujero) :-
    inicio(1, T0),
    T0 =.. [t|As0],
    maplist([A, B]>>(B is 1 - A), As0, As),
    T =.. [t|As],
    meta(en_su_agujero(1), T).

test(meta_bloqueada, [fail]) :-
    inicio(1, T),
    meta(bloqueada(1, 14), T).

test(sucesor, [true(N == 2)]) :-
    inicio(1, T),
    aggregate_all(count, sucesor(en_su_agujero(1), T, _, _, _), N).

test(terminar_en, [true(L-K == 13-740)]) :-
    terminar_en(1, Saltos, K),
    length(Saltos, L),
    inicio(1, T),
    jugar(Saltos, T, Ts),
    last(Ts, Final),
    arg(1, Final, 1).

test(terminar_en_imposible, [fail]) :-
    terminar_en(5, _, _).

test(bloqueo) :-
    bloqueo(1, 8, Saltos),
    inicio(1, T),
    jugar(Saltos, T, Ts),
    last(Ts, Final),
    clavijas(Final, 8),
    \+ salto(_, Final, _).

test(bloqueo_imposible, [fail]) :-
    bloqueo(4, 8, _).

test(mayor_bloqueo, [true(Ks == [8, 8, 7, 10])]) :-
    maplist(mayor_bloqueo, [1, 2, 4, 5], Ks).

test(cuenta_desde, [true(Ns == [29760, 14880, 85258, 1550])]) :-
    maplist(cuenta_desde, [1, 2, 4, 5], Ns).

test(cuenta_total, [true(N == 438984)]) :-
    aggregate_all(sum(K), ( between(1, 15, V), cuenta_desde(V, K) ), N).

test(cuenta_una_clavija, [true(N == 1)]) :-
    T = t(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    cuenta(T, N).

test(cuenta_forma_bloqueada, [true(N == 0)]) :-
    T = t(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1),
    forma(T, F),
    cuenta_forma(F, N).

test(agujeros4, [true(N == 10)]) :-
    aggregate_all(count, agujero4(_, _, _), N).

test(lineas4, [true(N == 9)]) :-
    aggregate_all(count, linea4(_, _, _), N).

test(salto4, [true(P == [3, 4, 5, 6, 7, 8, 9, 10])]) :-
    once(salto4([1, 2, 3, 5, 6, 7, 8, 9, 10], s(1, 2, 4), P)).

test(resolver4_una, [nondet, true(Ss == [])]) :-
    resolver4([7], Ss).

test(triangulo4, [true(Vs == [2, 3, 4, 6, 8, 9])]) :-
    findall(V, ( between(1, 10, V), once(triangulo4(V, _)) ), Vs).

test(triangulo4_cuenta, [true(N == 14)]) :-
    aggregate_all(count, triangulo4(2, _), N).

test(naftaleno, [true(R6-R10-K-F == 2-1-3-'C10H8')]) :-
    aggregate_all(count, anillo(naftaleno, 6, _), R6),
    aggregate_all(count, anillo(naftaleno, 10, _), R10),
    aggregate_all(count, ordenes(naftaleno, _), K),
    formula(naftaleno, F).

test(valor_total, [true(T == 586)]) :-
    valor_total(sello(_, _, _, _), T).

test(valor_total_serie, [true(T == 120)]) :-
    valor_total(sello(_, castillos, _, _), T).

test(sumar_valor, [true(T == 15)]) :-
    sumar_valor(sello(a, b, 1, 5), 10, T).

test(por_pais, [true(Ps == [alemania-195, reino_unido-391])]) :-
    por_pais(Ps).

test(conflictos, [true(N-K == 44-30)]) :-
    conflictos(auto, C),
    length(C, N),
    aggregate_all(count,
                  ( member(_-_-[A|_], C),
                    A \== detenerse ),
                  K).

test(cuenta_conflictos, [true(N-K == 44-30)]) :-
    cuenta_conflictos(auto, N, K).

test(peaton_v3, [true(As == [ceder_y_avanzar])]) :-
    findall(A, peaton_v3([luz(silueta, intermitente)], A), As).

test(accion_v3, [true(As == [ceder_y_avanzar])]) :-
    findall(A, accion_v3([cruce_horario, luz(verde, fija),
                          luz(silueta, intermitente)], peaton, A), As).

test(accion_v3_auto, [true(As == [detenerse])]) :-
    findall(A, accion_v3([luz(rojo, fija)], auto, A), As).

test(partes, [true(Ps == [sistema_de_propulsion, sistema_electrico])]) :-
    partes(auto, Ps).

test(partes_instancia, [true(Ps == [bateria_de_juan, sistema_de_propulsion,
                                    sistema_electrico])]) :-
    partes(rabbit_de_juan, Ps).

test(esqueleto, [true(L == [3, 2, 1])]) :-
    esqueleto(3, L).

test(hombres, [true(Ts == ["un hombre", "veintiún hombres"])]) :-
    maplist(hombres, [1, 21], Ts).

test(estrofa_segar, [true(Ls == ["Tres hombres fueron a segar,",
                                 "fueron a segar un prado;",
                                 "Tres hombres, dos hombres, un hombre y su perro",
                                 "fueron a segar un prado."])]) :-
    estrofa_segar(3, Ls).

test(estrofa_segar_uno, [true(L3 == "Un hombre y su perro")]) :-
    estrofa_segar(1, [_, _, L3, _]).

:- end_tests(soluciones).
