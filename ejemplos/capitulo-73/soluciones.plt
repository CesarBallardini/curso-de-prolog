:- encoding(utf8).

:- begin_tests(soluciones).

test(casa_tres, [true(R-Ca-B-D == 12-27-27-27)]) :-
    ejemplo(casa, P0),
    con_procesadores(P0, 3, P),
    inicial(datos(P, combinada), E),
    reparto(P, E, R),
    camino(P, E, Ca),
    cota_inferior(P, B),
    planificar(P, 1000000, C, optima(por_lista)),
    duracion(C, D).

test(mejor_de_todas, [true(D == 33)]) :-
    ejemplo(coffman, P),
    mejor_de_todas(P, D).

test(cabezas, [true(L == [t1-0, t2-0, t3-0, t4-4, t5-4, t6-2, t7-2])]) :-
    ejemplo(coffman, P),
    findall(T-C, ( tarea(P, T, _), cabeza(P, T, C) ), L).

test(criticas, [true(Ts == [t1, t4, t5])]) :-
    ejemplo(coffman, P),
    criticas(P, Ts).

test(criticas_casa, [true(Ts == [cimientos, paredes, techo, revoque,
                                 pintura])]) :-
    ejemplo(casa, P),
    criticas(P, Ts).

test(suma, [true(D-K == 33-7)]) :-
    ejemplo(coffman, P),
    optimo(P, suma, C, K),
    valido(P, C),
    duracion(C, D).

test(comparar_voraz,
     [true(F == [ 6-voraz(16, 23)-optimo(15, 29),
                  12-voraz(30, 15)-optimo(26, 43) ])]) :-
    comparar_voraz([6, 12], F).

test(ida, [true(L == [24-11, 24-9, 28-1022, 28-24])]) :-
    findall(D-K,
            ( member(E, [coffman, casa]),
              member(H, [reparto, combinada]),
              ejemplo(E, P),
              optimo_ida(P, H, D, K) ),
            L).

test(curva, [true(L == [1-36, 2-28, 3-27, 4-27])]) :-
    ejemplo(casa, P),
    curva(P, [1, 2, 3, 4], L).

test(curva_coffman, [true(L == [1-70, 2-35, 3-24, 4-24])]) :-
    ejemplo(coffman, P),
    curva(P, [1, 2, 3, 4], L).

test(regla, [true(R == "   0         5         10")]) :-
    regla(12, R).

test(errores, [true(E == [repetida(a), duracion(b, 0), desconocida(x),
                          procesadores(0)])]) :-
    errores(proyecto([tarea(a, 1), tarea(a, 2), tarea(b, 0)],
                     [antes(a, x), antes(b, b)], 0), E).

test(errores_ciclo, [true(E == [ciclo])]) :-
    errores(proyecto([tarea(a, 1), tarea(b, 2)],
                     [antes(a, b), antes(b, a)], 2), E).

test(sin_errores, [true(E == [])]) :-
    ejemplo(coffman, P),
    errores(P, E).

test(suma_estado, [true(H == 24)]) :-
    ejemplo(coffman, P),
    suma(P, e([t1, t4], [0, 0, 0], []), H).

test(sumar, [true(S == 23)]) :-
    ejemplo(coffman, P),
    soluciones:sumar(P, t4, 3, S).

test(multiplo_de_5) :-
    soluciones:multiplo_de_5(10).

test(no_multiplo_de_5, [fail]) :-
    soluciones:multiplo_de_5(7).

test(marca, [true(L == "abc        4")]) :-
    soluciones:marca(4, "abc", L).

test(duracion_con, [true(R == 2-35)]) :-
    ejemplo(coffman, P),
    soluciones:duracion_con(P, 2, R).

test(fila_voraz, [true(F == 6-voraz(16, 23)-optimo(15, 29))]) :-
    soluciones:fila_voraz(6, F).

% La regla va sobre el calendario: una línea más que mostrar/2.
test(mostrar_con_regla, [true(N1 =:= N0 + 1)]) :-
    ejemplo(coffman, P),
    calendario_coffman(C),
    with_output_to(string(S1), mostrar_con_regla(P, C)),
    with_output_to(string(S0), mostrar(P, C)),
    split_string(S1, [10], "", L1),
    split_string(S0, [10], "", L0),
    length(L1, N1),
    length(L0, N0).

test(por_colas, [true(Ds == [ base-12, otra_lista-12,
                              sin_dos_precedencias-12, mas_cortas-10,
                              cuatro_procesadores-12 ])]) :-
    findall(N-D, ( variante(N, P, _), por_colas(P, D) ), Ds).

test(por_colas_coffman, [true(D == 33)]) :-
    ejemplo(coffman, P),
    por_colas(P, D).

test(por_colas_ciclo, [fail]) :-
    por_colas(proyecto([tarea(a, 1), tarea(b, 1)],
                       [antes(a, b), antes(b, a)], 1), _).

:- end_tests(soluciones).
