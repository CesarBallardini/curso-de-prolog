:- encoding(utf8).

% Pruebas de Inscripciones (capítulo 19): las de los capítulos 17 y 18 sin
% cambios, y las de los motivos de rechazo escritos como reglas.

:- begin_tests(inscripciones).

% --- Datos ---------------------------------------------------------------

test(toda_inscripcion_es_de_un_alumno, [fail]) :-
    inscripcion(Legajo, _, _),
    \+ alumno(Legajo, _, _, _).

test(toda_inscripcion_es_a_una_materia, [fail]) :-
    inscripcion(_, Materia, _),
    \+ materia(Materia, _, _).

test(toda_correlativa_une_materias, [fail]) :-
    correlativa(Materia, Requisito),
    (   \+ materia(Materia, _, _)
    ;   \+ materia(Requisito, _, _)
    ).

% Un estado es cursando o nota(N) con N entero de 1 a 10.
test(los_estados_son_validos, [fail]) :-
    inscripcion(_, _, Estado),
    Estado \== cursando,
    \+ ( Estado = nota(N),
         integer(N),
         between(1, 10, N) ).

% --- aprobada/3 ------------------------------------------------------------

% Todo libre: la consulta más general enumera todas las aprobadas.
test(todas_las_aprobadas, all(L-M-N == [101-am1-8, 101-alg-9, 101-log-10,
                                         101-am2-7, 102-log-6, 103-am1-7,
                                         104-log-9, 104-alg-7, 104-pp-8,
                                         106-am1-6])) :-
    aprobada(L, M, N).

% Legajo y materia ligados, nota libre: una respuesta.
test(nota_de_ana_en_logica, all(N == [10])) :-
    aprobada(101, log, N).

% Todo ligado: comprueba, y con una nota falsa falla (estabilidad).
test(ana_aprobo_logica_con_10) :-
    aprobada(101, log, 10).

test(ana_no_aprobo_logica_con_9, [fail]) :-
    aprobada(101, log, 9).

% Con nota menor que la mínima, la materia no está aprobada.
test(bruno_no_aprobo_algebra, [fail]) :-
    aprobada(102, alg, _).

% --- cursa/2 ---------------------------------------------------------------

test(quienes_cursan, all(L-M == [101-pp, 103-am2, 105-am1])) :-
    cursa(L, M).

test(ana_cursa_paradigmas) :-
    cursa(101, pp).

% --- inscripcion_posible/3 -------------------------------------------------

% Un modo, det: una respuesta y sin alternativas pendientes.
test(diego_puede_cursar_sintaxis, true(R == aceptada)) :-
    inscripcion_posible(104, ssl, R).

test(bruno_puede_recursar_algebra, true(R == aceptada)) :-
    inscripcion_posible(102, alg, R).

test(alumno_inexistente, true(R == rechazada(alumno_inexistente))) :-
    inscripcion_posible(999, am1, R).

test(materia_inexistente, true(R == rechazada(materia_inexistente))) :-
    inscripcion_posible(101, quimica, R).

test(ana_ya_aprobo_logica, true(R == rechazada(ya_aprobada))) :-
    inscripcion_posible(101, log, R).

test(ana_ya_cursa_paradigmas, true(R == rechazada(ya_la_cursa))) :-
    inscripcion_posible(101, pp, R).

% Bruno desaprobó análisis 1 y álgebra: el motivo es el primer requisito.
test(bruno_no_aprobo_los_requisitos, true(R == rechazada(falta(am1)))) :-
    inscripcion_posible(102, am2, R).

test(logica_sin_vacantes, true(R == rechazada(sin_vacantes))) :-
    inscripcion_posible(105, log, R).

% Estabilidad: con el resultado ligado a un valor falso, falla.
test(resultado_ligado_falso, [fail]) :-
    inscripcion_posible(102, am2, aceptada).

test(puede_inscribirse) :-
    puede_inscribirse(104, ssl).

test(no_puede_inscribirse, [fail]) :-
    puede_inscribirse(102, am2).

% --- aprobada_por_nombre/2 -------------------------------------------------

test(aprobadas_de_ana, all(M == [am1, alg, log, am2])) :-
    aprobada_por_nombre(ana, M).

test(quienes_aprobaron_logica, all(N == [ana, bruno, diego])) :-
    aprobada_por_nombre(N, log).

test(un_nombre_que_no_existe, [fail]) :-
    aprobada_por_nombre(zoe, _).

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

% --- Reglas como datos ---------------------------------------------------

test(situacion_de_bruno_en_am2,
     true(Obs == [materia(am2), aprobada(log), requisito(am1),
                  requisito(alg), vacantes(25)])) :-
    situacion(102, am2, Obs).

% inscripcion_posible/3 da solo falta(am1); las reglas dan los dos requisitos.
test(todos_los_motivos, true(M == [falta(am1), falta(alg)])) :-
    motivos_de_rechazo(102, am2, M).

test(dos_motivos_distintos, true(M == [ya_aprobada, sin_vacantes])) :-
    motivos_de_rechazo(101, log, M).

test(sin_motivos, true(M == [])) :-
    motivos_de_rechazo(104, ssl, M).

% El árbol de la prueba muestra la regla y la negación que se cumplió.
test(arbol_del_motivo,
     [ nondet,
       true(A == deducido(rechazada(falta(am1)), v3,
                          observado(requisito(am1)) y no aprobada(am1))) ]) :-
    situacion(102, am2, Obs),
    prueba(rechazada(falta(am1)), Obs, A).

% Las reglas coinciden con inscripcion_posible/3 para todo alumno y toda
% materia: sin motivos se acepta, y el primer motivo está entre los motivos.
test(coinciden_con_inscripcion_posible) :-
    forall(( alumno(Legajo, _, _, _),
             materia(Materia, _, _) ),
           ( inscripcion_posible(Legajo, Materia, Resultado),
             motivos_de_rechazo(Legajo, Materia, Motivos),
             (   Resultado == aceptada
             ->  Motivos == []
             ;   Resultado = rechazada(Motivo),
                 memberchk(Motivo, Motivos)
             ) )).

:- end_tests(inscripciones).
