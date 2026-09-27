:- encoding(utf8).

% Pruebas del módulo informes (capítulo 30): los informes, el ranking y el
% índice por alumno.

:- begin_tests(informes).

% --- Informes --------------------------------------------------------------

test(inscriptos_en_am1, true(L == [101, 102, 103, 105, 106])) :-
    inscriptos(am1, L).

test(inscriptos_en_una_materia_sin_nadie, true(L == [])) :-
    inscriptos(bd, L).

% elena (105) solo cursa; gabriela (107) no se inscribió en nada.
test(sin_notas, true(L == [105, 107])) :-
    sin_notas(L).

test(promedio_de_logica, true(P =:= 7)) :-
    promedio_de_materia(log, P).

test(promedio_de_una_materia_sin_notas, [fail]) :-
    promedio_de_materia(bd, _).

test(promedio_de_ana, true(P =:= 8.5)) :-
    promedio_de_alumno(101, P).

test(los_tres_mejores, true(R == [101-8.5, 104-8, 103-6])) :-
    mejores(3, R).
% --- Orden superior ------------------------------------------------------

test(legajos, true(L == [101, 102, 103, 104, 105, 106, 107])) :-
    legajos(L).

test(promedio, true(P =:= 7.5)) :-
    promedio([6, 9], P).

test(promedio_de_ninguna_nota, [fail]) :-
    promedio([], _).

test(aprobadas_de_ana, true(N == 4)) :-
    aprobadas(101, N).

test(aprobadas_de_gabriela, true(N == 0)) :-
    aprobadas(107, N).

% informe/3 omite a los alumnos sin promedio: elena (105) y gabriela (107).
test(informe_de_promedios,
     true(F == [101-8.5, 102-4, 103-6, 104-8, 106-4.5])) :-
    legajos(L),
    informe(promedio_de_alumno, L, F).

test(informe_de_aprobadas, true(F == [101-4, 105-0])) :-
    informe(aprobadas, [101, 105], F).

test(informe_vacio, true(F == [])) :-
    informe(aprobadas, [], F).

test(mostrar_informe,
     true(S == "Aprobadas
  101 ana: 4
  105 elena: 0
")) :-
    with_output_to(string(S),
                   mostrar_informe('Aprobadas', [101-4, 105-0])).
% --- Ranking e índice -------------------------------------------------------

test(ranking, true(R == [101-8.5, 104-8, 103-6, 106-4.5, 102-4])) :-
    ranking(R).

% mejores/2 da el mismo resultado que con order_by/2 en el capítulo 17.
test(mejores_con_sort, true(R == [101-8.5, 104-8])) :-
    mejores(2, R).

test(mejores_mas_que_alumnos, true(N == 5)) :-
    mejores(10, R),
    length(R, N).

test(materias_de_ana,
     true(M == [am1-nota(8), alg-nota(9), log-nota(10), am2-nota(7),
                pp-cursando])) :-
    indice_por_alumno(I),
    materias_de(I, 101, M).

test(materias_de_gabriela, true(M == [])) :-
    indice_por_alumno(I),
    materias_de(I, 107, M).

test(indice_completo, true(N == 6)) :-
    indice_por_alumno(I),
    assoc_to_keys(I, Ks),
    length(Ks, N).

% --- Rendimiento -------------------------------------------------------------

% Una prueba de rendimiento con una cota de inferencias, no de tiempo: la
% cantidad de inferencias no depende de la máquina ni de la carga. Con los
% datos del proyecto, ranking/1 usa unas 330.
test(ranking_rapido, true(R \== inference_limit_exceeded)) :-
    call_with_inference_limit(ranking(_), 1000, R).

:- end_tests(informes).
