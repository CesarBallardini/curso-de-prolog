:- encoding(utf8).

:- begin_tests(soluciones).

test(escrituras_chico, [true(Ns == [6, 2, 1])]) :-
    findall(N, ( member(M, [todas, semilla, sentido]),
                 escrituras(M, chico, Ls), length(Ls, N) ),
            Ns).

test(costo_por_semilla, [true(Ts == [4, 6, 3, 4, 3, 4, 6, 3, 5])]) :-
    costo_por_semilla(csenki1, Filas),
    findall(T, member(s(_, T, _), Filas), Ts).

test(simetrias_propias,
     [true(Ss == [identidad, giro180, espejo_filas, espejo_columnas])]) :-
    simetrias_propias(cruz, Ss).

test(orbitas_cruz, [true(Ls == [4, 1])]) :-
    orbitas(cruz, Os),
    maplist(length, Os, Ls).

test(orbita_unitaria, [true(O == [L])]) :-
    distintos(chico, [L]),
    orbita([identidad], 3, 3, L, O).

test(imagen_de_lazo, [true(F == [1-1, 1-2, 2-2, 2-1])]) :-
    imagen_de_lazo(2, 2, [1-1, 1-2, 2-2, 2-1], giro180, F).

test(leer_tablero, [nondet]) :-
    forall(member(N, [chico, cruz, csenki1, csenki2]),
           ( lineas(N, [], Ls),
             leer_tablero(Ls, F, C, Ms),
             problema(N, F, C, Ms0),
             msort(Ms, X),
             msort(Ms0, X) )).

test(marcas_de_fila, [true(M-F == [circulo(2-1), numeral(2-3)]-3)]) :-
    marcas_de_fila("O · #", M, 2, F).

test(lazo_recto, [true(N == 1)]) :-
    lazo_recto(recto, Ls),
    length(Ls, N).

test(lazo_recto_cubre, [true(K == 36)]) :-
    lazo_recto(recto, [L]),
    length(L, K).

test(vecinas_de_esquina, [true(Vs == [1-2, 2-1])]) :-
    findall(V, vecina(6, 6, 1-1, V), Vs0),
    msort(Vs0, Vs).

test(recta_si_marca) :-
    recta_si_marca([2-2], 1-2, 2-2, 3-2).

test(giro_en_marca, [fail]) :-
    recta_si_marca([2-2], 1-2, 2-2, 2-3).

test(camino_recto_sin_salida, [fail]) :-
    camino_recto(t(2, 2, [], 4), 1-1, 1-2, [1-2, 1-1], 2, [_, _, _, _]).

test(cantidad_desarreglos, [nondet]) :-
    forall(between(1, 8, N),
           ( cantidad_desarreglos(N, D), desarreglos(N, Ps), length(Ps, D) )).

test(cantidad_desarreglos_20, [true(D == 895014631192902121)]) :-
    cantidad_desarreglos(20, D).

test(particiones_libres, [true(N == 22)]) :-
    aggregate_all(count, particion_libre(8, _), N).

test(conjugacion_6) :-
    conjugacion_verificada(6).

test(polinomio, [true(T == 544)]) :-
    polinomio(8, T).

test(conjetura) :-
    conjetura(20).

test(lineas_matriz, [true(Ls == ["  1  1", "  3 12"])]) :-
    lineas_matriz([[1, 1], [3, 12]], Ls).

test(linea_matriz, [true(L == " 1 2")]) :-
    linea_matriz(2, [1, 2], L).

test(celda_matriz, [true(L == "a  7")]) :-
    celda_matriz(3, 7, "a", L).

test(mostrar_matriz, [true(S == " 1 2\n 2 1\n")]) :-
    with_output_to(string(S), mostrar_matriz([[1, 2], [2, 1]])).

:- end_tests(soluciones).
