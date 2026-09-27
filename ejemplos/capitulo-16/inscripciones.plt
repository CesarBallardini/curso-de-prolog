:- encoding(utf8).

% Pruebas de Inscripciones (capítulo 16): las del capítulo 15, y las de
% aprobada_por_nombre/2.

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

:- end_tests(inscripciones).
