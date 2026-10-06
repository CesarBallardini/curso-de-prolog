:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1
test(sucesores, true(L == [2, 3, 4])) :-
    maplist(succ, [1, 2, 3], L).

% succ(X, 0) falla: 0 no es el sucesor de ningún natural.
test(antecesores_desde_cero, [fail]) :-
    maplist(succ, _, [0, 1, 2]).

test(producto, true(P == 24)) :-
    foldl([X, A0, A]>>(A is A0 * X), [1, 2, 3, 4], 1, P).

test(particion, true(I-E == [1, 1]-[3, 4, 5])) :-
    partition([X]>>(X < 3), [3, 1, 4, 1, 5], I, E).

% Ejercicio 2
test(dobles, true(D == [2, 4, 6])) :-
    dobles([1, 2, 3], D).

test(todos_positivos) :-
    todos_positivos([1, 2]).

test(no_todos_positivos, [fail]) :-
    todos_positivos([1, 0]).

% Ejercicio 3
test(largo, true(N == 3)) :-
    largo([a, b, c], N).

test(largo_vacia, true(N == 0)) :-
    largo([], N).

test(maximo, true(M == 9)) :-
    maximo([3, 9, 2], M).

test(maximo_vacia, [fail]) :-
    maximo([], _).

test(dar_vuelta, true(R == [c, b, a])) :-
    dar_vuelta([a, b, c], R).

% Ejercicio 4
test(conservar, true(L == [3, 4, 5])) :-
    conservar([X]>>(X > 2), [3, 1, 4, 1, 5], L).

test(descartar, true(L == [1, 1])) :-
    descartar([X]>>(X > 2), [3, 1, 4, 1, 5], L).

test(conservar_igual_que_include, true(L1 == L2)) :-
    conservar(positivo, [1, -1, 2], L1),
    include(positivo, [1, -1, 2], L2).

% Ejercicio 5
test(lambda_sin_llaves) :-
    maplist([X]>>(X = _Y), [a, b]).

test(lambda_con_llaves, [fail]) :-
    maplist({Y}/[X]>>(X = Y), [a, b]).

test(hijos_de_pedro, true(P == pedro)) :-
    todos_hijos_de(P, [luis, eva]).

test(hijos_de_padres_distintos, [fail]) :-
    todos_hijos_de(_, [ana, luis]).

% Ejercicio 6
test(mi_foldl, true(S == 6)) :-
    mi_foldl([X, A0, A]>>(A is A0 + X), [1, 2, 3], 0, S).

test(mi_foldl_igual_que_foldl, true(R1 == R2)) :-
    mi_foldl([X, A, [X|A]]>>true, [a, b, c], [], R1),
    foldl([X, A, [X|A]]>>true, [a, b, c], [], R2).

test(mi_foldl_falla, [fail]) :-
    mi_foldl([X, A0, A]>>(X > 0, A is A0 + X), [1, -1], 0, _).

% Ejercicio 7: todos los alumnos aparecen, con 0 los que no cursan nada.
test(informe_cursando,
     true(F == [101-1, 102-0, 103-1, 104-0, 105-1, 106-0, 107-0])) :-
    legajos(L),
    informe(materias_cursando, L, F).

% Ejercicio 8: ssl y bd no tienen notas, y quedan fuera.
test(informe_de_materias,
     true(F == [am1-6.25, alg-5.75, log-7, am2-7, pp-8])) :-
    materias(M),
    informe(promedio_de_materia, M, F).

% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
test(mostrar_informe_de_materias,
     true(S == "Promedios\n  log logica: 7\n  pp paradigmas: 8\n")) :-
    with_output_to(string(S),
                   mostrar_informe(nombre_de_materia, 'Promedios',
                                   [log-7, pp-8])).

test(mostrar_informe_de_alumnos,
     true(S == "Cursando\n  101 ana: 1\n")) :-
    with_output_to(string(S),
                   mostrar_informe(nombre_de_alumno, 'Cursando', [101-1])).

% Ejercicio 9
test(partida_en_curso, true(N == 20)) :-
    jugar([1-6, 6-1], en_curso(D)),
    length(D, N).

test(partida_perdida, true(R == perdida(1-1))) :-
    jugar([1-6, 1-1, 2-1], R).

test(partida_ganada, true(R == ganada)) :-
    findall(F-C, ( between(1, 6, F), between(1, 6, C), \+ mina(F, C) ),
            Todas),
    jugar(Todas, R).

% Ejercicio 10: el mismo conjunto de celdas, en otro orden.
test(a_lo_ancho,
     true(D == [1-6, 1-5, 2-5, 2-6, 1-4, 2-4, 3-4, 3-5, 3-6, 1-3, 2-3,
                3-3, 1-2, 2-2])) :-
    descubrir_a_lo_ancho(1-6, D).

% msort/2, que ordena sin eliminar repetidos, se presenta en el capítulo 22.
test(mismas_celdas, true(S1 == S2)) :-
    descubrir_a_lo_ancho(1-6, D1),
    descubrir(1-6, [], D2),
    msort(D1, S1),
    msort(D2, S2).

% Ejercicio 11
test(promedios_parciales, true(P == [8, 7, 8])) :-
    promedios_parciales([8, 6, 10], P).

test(promedios_parciales_vacia, true(P == [])) :-
    promedios_parciales([], P).

test(promedios_parciales_fraccion, true(P =:= 7.5)) :-
    promedios_parciales([7, 8], [_, P]).

% Ejercicio 12
test(producto_interno, true(P == 32)) :-
    producto_interno([1, 2, 3], [4, 5, 6], P).

test(producto_interno_vacio, true(P == 0)) :-
    producto_interno([], [], P).

test(producto_interno_largos_distintos, [fail]) :-
    producto_interno([1, 2, 3], [4, 5], _).

test(producto_interno_largos_distintos_2, [fail]) :-
    producto_interno([1, 2], [4, 5, 6], _).

:- end_tests(soluciones).
