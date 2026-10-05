:- encoding(utf8).

:- begin_tests(soluciones).

test(comparar_giros, [true(K1-K2 == 96-97)]) :-
    comparar_giros(patio, 28-8, 32-8, K1, K2).

test(comparar_giros_igual_costo) :-
    giros:camino_con_giros(taller, 1-4, 20-6, _, C, _),
    capitulo40:buscar(mejor(a_estrella),
                      soluciones:giros2(taller, 1-4, 20-6), _, C, _).

test(camino8, [true(P-K == 20-53)]) :-
    camino8(taller, 1-4, 20-6, P, K).

test(cantidad_minimos, [true(Ns == [5, 125970])]) :-
    findall(N,
            ( member(H, [32-8, 20-20]),
              cantidad_minimos(patio, 28-8, H, N) ),
            Ns).

test(cantidad_minimos_sin_camino, [fail]) :-
    cantidad_minimos(galpon, 1-1, 23-15, _).

test(ida_con_tabla, [true(P-K == 12-83)]) :-
    camino_ida_con_tabla(patio, 28-8, 32-8, P, K).

test(ida_con_tabla_puzzle, [true(C == 8)]) :-
    ida_con_tabla(capitulo40:puzzle([2, 4, 3, 7, 1, 5, 0, 8, 6], manhattan),
                  _, C, _).

test(salida_manhattan, [true(C-K == 54-20)]) :-
    salida_manhattan(csenki, C, K).

test(salida_h3, [true(C-K == 54-18)]) :-
    salida_h3(csenki, C, K).

test(estimacion_h3) :-
    estimacion_h3(csenki, g(1, 2), H3),
    laberinto:estimacion(vuelo, csenki, g(1, 2), V),
    V =< H3,
    H3 =< 54.

test(sobreestimaciones, [true(L == 146)]) :-
    sobreestimaciones(minima, Ps),
    length(Ps, L).

test(sobreestimaciones_ninguna, [true(Ps == [])]) :-
    sobreestimaciones(combinada, Ps).

test(distancias, [true(D == 6)]) :-
    distancias(8, 1-8, Ds),
    get_assoc(8-1, Ds, D).

test(saltos_minimos, [true(D == 2)]) :-
    saltos_minimos(8, 1-1, 4-4, D).

test(admisible) :-
    admisible(6, entera(combinada)).

test(no_admisible, [fail]) :-
    admisible(8, minima).

test(cerrado, [nondet]) :-
    recorrido_cerrado(8, 1-1, C),
    recorrido:es_recorrido(8, C),
    last(C, U),
    caballo:salto(8, U, 1-1, _).

:- end_tests(soluciones).
