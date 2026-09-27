:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 2
test(nietos_de_juan, true(N == [sofia, luis, eva])) :-
    nietos_de(juan, N).

% Ejercicio 3: con P^, una respuesta por abuelo.
test(abuelos_con_nietos, all(A-N == [juan-[sofia, luis, eva]])) :-
    abuelos_con_nietos(A, N).

% Ejercicio 4
test(edades_ordenadas, true(E == [3, 8, 12, 39, 41, 68])) :-
    edades_ordenadas(E).

test(edades_ordenadas_2, true(E == [3, 8, 12, 39, 41, 68])) :-
    edades_ordenadas_2(E).

% Ejercicio 5
test(materias_de_primer_anio, true(M == [am1, alg, log])) :-
    materia_de_anio(1, M).

test(un_anio_sin_materias, true(M == [])) :-
    materia_de_anio(4, M).

% Ejercicio 6
test(faltan_los_dos_requisitos, true(F == [am1, alg])) :-
    requisitos_faltantes_2(102, am2, F).

% Ejercicio 7: con empate, cada versión elige a una persona distinta.
test(menor_edad, true(Q-E == sofia-3)) :-
    menor_edad(Q, E).

test(mayor_con_aggregate_all, true(Q == juan)) :-
    aggregate_all(max(E, P), edad(P, E), max(_, Q)).

test(mayor_con_max_member, true(Q-E == marta-68)) :-
    mayor_edad_2(Q, E).

% Ejercicio 8: la prueba que el capítulo 13 no podía escribir.
test(sin_inscripciones_repetidas, [fail]) :-
    inscripcion(L, M, E),
    aggregate_all(count, inscripcion(L, M, E), N),
    1 < N.

% Ejercicio 9: diego (104) aprobó todo; ana cursa una; gabriela, nada.
test(diego_aprobo_todo) :-
    todos_aprobados(104).

test(ana_no, [fail]) :-
    todos_aprobados(101).

test(gabriela_sin_inscripciones, [fail]) :-
    todos_aprobados(107).

% Ejercicio 10
test(cantidad_en_am1, true(N == 5)) :-
    cantidad_por_materia(am1, N).

% Ejercicio 11
test(mejor_de_logica, true(L-N == 101-10)) :-
    mejor_de_materia(log, L, N).

% Ejercicio 13
test(listar_inscriptos_en_pp, true(S == "101 ana\n104 diego\n")) :-
    with_output_to(string(S), listar_inscriptos(pp)).

% Ejercicio 14
test(tablero, true(L == ["*2110", "12*10", "12221", "1*11*", "11111"])) :-
    tablero_texto(L).

% Ejercicio 15
test(mejores_por_carrera,
     all(C-L == [civil-103, industrial-106, sistemas-101])) :-
    los_mejores_de_cada_carrera(C, L).

% Ejercicio 16: las dos versiones dan el mismo ranking.
test(mejores_igual, true(R1 == R2)) :-
    mejores(3, R1),
    mejores_2(3, R2).

:- end_tests(soluciones).
