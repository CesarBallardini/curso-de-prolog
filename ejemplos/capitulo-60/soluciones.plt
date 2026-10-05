:- encoding(utf8).

:- begin_tests(soluciones).

test(ej1_mcd, [N, R] == [8, 2]) :-
    ciclos(mcd, primera, [numero(18), numero(12), numero(8)], N),
    ejecutar(mcd, primera, [numero(18), numero(12), numero(8)], _, R).

test(ej2_maximo, [M, R] == [[numero(30)], 30]) :-
    ejecutar(maximo, [numero(25), numero(10), numero(15), numero(30)], M, R).

test(ej3_criba, P == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]) :-
    numeros(2, 30, H),
    ejecutar(criba, H, M, nada_aplicable),
    findall(X, member(numero(X), M), Xs),
    msort(Xs, P).

test(ej4_burbuja, [B, O, BR, OR] == [45, 45, 7, 5]) :-
    numlist(1, 10, L0),
    reverse(L0, L),
    posiciones(L, H),
    ciclos(burbuja, reciente, H, B),
    ciclos(ordenar, reciente, H, O),
    posiciones([4, 5, 1, 3, 2], Q),
    ciclos(burbuja, reciente, Q, BR),
    ciclos(ordenar, reciente, Q, OR).

test(ej4_burbuja_ordena, L == [1, 2, 3, 4, 5]) :-
    posiciones([4, 5, 1, 3, 2], H),
    ejecutar(burbuja, primera, H, M, nada_aplicable),
    valores(M, L).

test(ej5_lejana, [N, L] == [10, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
                                 14, 15, 16, 17, 18, 19, 20]]) :-
    numlist(1, 20, L0),
    reverse(L0, L1),
    posiciones(L1, H),
    ciclos(ordenar, lejana, H, N),
    ejecutar(ordenar, lejana, H, M, _),
    valores(M, L).

test(ej6_ejecuciones, [N, Rs] == [6, [4, 8, 12]]) :-
    aggregate_all(count, ejecucion(mcd, [numero(12), numero(8)], _, _), N),
    setof(R, M^ejecucion(mcd, [numero(12), numero(8)], M, R), Rs).

test(ej7_escrutinio, T == [total(ana, 3), total(eva, 1), total(luis, 1)]) :-
    ejecutar(escrutinio,
             [voto(ana), voto(luis), voto(ana), voto(eva), voto(ana)], M,
             nada_aplicable),
    msort(M, T).

test(ej8_subsuncion, all(F-B == [(p v -p)-2, (((p ==> q) ==> p) ==> p)-3])) :-
    member(F, [p v -p, ((p ==> q) ==> p) ==> p]),
    memoria_inicial(F, M),
    ciclos(resolucion_subsuncion, primera, M, B).

test(ej8_mismo_veredicto, all(R == [contradiccion, sin_contradiccion])) :-
    member(F, [(a ==> b) & (b ==> c) ==> (a ==> c),
               (p ==> q) ==> (q ==> p)]),
    memoria_inicial(F, M),
    vigilar(resolucion_subsuncion, primera, 500, M, _, R).

test(ej9_sin_control, [R, L] == [limite(50), 52]) :-
    memoria_inicial((p v q) ==> p, M0),
    vigilar(resolucion_sin_control, primera, 50, M0, M, R),
    length(M, L).

test(ej9_teorema_termina, R == contradiccion) :-
    memoria_inicial((a ==> b) & (b ==> c) ==> (a ==> c), M),
    vigilar(resolucion_sin_control, primera, 50, M, _, R).

test(ej10_historia, [H, R] == [[ciclo(1, resta, 3, [numero(12), numero(8)]),
                                ciclo(2, resta, 3, [numero(8), numero(4)]),
                                ciclo(3, resultado, 2, [numero(4)])], 4]) :-
    historia(mcd, primera, [numero(12), numero(8)], H, R).

test(ej10_igual_a_trazar, S1 == S2) :-
    Memoria = [numero(25), numero(10), numero(15), numero(30)],
    with_output_to(string(S1), trazar(mcd, primera, Memoria, _, _)),
    historia(mcd, primera, Memoria, H, _),
    with_output_to(string(S2), escribir_historia(H)).

test(ej11_ruido, [R1, R2] == [60, 60]) :-
    findall(numero(X), ( between(1, 12, I), X is I * 60 ), Ns),
    ruido(100, Ruido),
    append(Ns, Ruido, M),
    ejecutar(mcd, M, _, R1),
    ejecutar(mcd, primera, M, _, R2).

test(ej12_luz_limitada, [M, R] == [[luz(apagada), cambios(0)], listo]) :-
    vigilar(luz_limitada, primera, 100, [luz(encendida), cambios(3)], M, R).

test(ej3_primos_hasta, P == [2, 3, 5, 7, 11, 13, 17, 19]) :-
    primos_hasta(20, P).

test(ej9_vigilar_formula, [R, N] == [limite(50), 52]) :-
    vigilar_formula(resolucion_sin_control, (p v q) ==> p, 50, R, N).

test(ej5_ciclos_invertida, [N, P] == [10, 190]) :-
    ciclos_invertida(ordenar, lejana, 20, N),
    ciclos_invertida(ordenar, primera, 20, P).

test(distancia, [true(Cs == [-3, 0])]) :-
    distancia([reemplazar(pos(2, b), pos(2, a)),
               reemplazar(pos(5, a), pos(5, b))], C1),
    distancia([agregar(x)], C2),
    Cs = [C1, C2].

% La estrategia lejana prefiere el intercambio más distante.
test(clave_lejana, [true(C == -4)]) :-
    clave(lejana, 9, instancia(i, 3, [0, 4],
                               [reemplazar(pos(1, c), pos(1, a)),
                                reemplazar(pos(5, a), pos(5, c))]),
          C).

:- end_tests(soluciones).
