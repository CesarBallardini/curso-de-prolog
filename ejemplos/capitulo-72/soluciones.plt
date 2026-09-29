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

:- end_tests(soluciones).
