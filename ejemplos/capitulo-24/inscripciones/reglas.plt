:- encoding(utf8).

% Pruebas del módulo reglas (capítulo 24): las reglas y las operaciones. Las
% que modifican la base guardan el estado en su setup y lo restauran en su
% cleanup, con estado/1 y restaurar/1 del módulo datos.

% Las pruebas cargan los módulos que usan además del que prueban.
:- use_module(datos).
:- use_module(informes).

:- begin_tests(reglas).

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
% --- Inscribir y dar de baja -----------------------------------------------

test(inscribir, [ setup(estado(E)), cleanup(restaurar(E)),
                  true(R-L-V == aceptada-[104]-19) ]) :-
    inscribir(104, ssl, R),
    inscriptos(ssl, L),
    vacantes(ssl, V).

test(inscribir_rechazada, [ setup(estado(E)), cleanup(restaurar(E)),
                            true(R-L == rechazada(falta(am1))-[101, 103]) ]) :-
    inscribir(102, am2, R),
    inscriptos(am2, L).

% Una vez inscripto, la misma inscripción se rechaza.
test(inscribir_dos_veces, [ setup(estado(E)), cleanup(restaurar(E)),
                            true(R == rechazada(ya_la_cursa)) ]) :-
    inscribir(104, ssl, _),
    inscribir(104, ssl, R).

test(dar_de_baja, [ setup(estado(E)), cleanup(restaurar(E)),
                    true(L-V == [101, 102, 103, 106]-31) ]) :-
    dar_de_baja(105, am1),
    inscriptos(am1, L),
    vacantes(am1, V).

% Solo se da de baja una materia que se está cursando.
test(baja_de_una_aprobada, [ setup(estado(E)), cleanup(restaurar(E)),
                             fail ]) :-
    dar_de_baja(101, am1).

test(operaciones, [ setup(estado(E)), cleanup(restaurar(E)),
                    true(N == 3) ]) :-
    inscribir(104, ssl, _),
    inscribir(102, am2, _),
    dar_de_baja(104, ssl),
    operaciones(N).

% Las pruebas anteriores dejaron la base como estaba.
test(estado_intacto, true(N-O == 17-0)) :-
    aggregate_all(count, inscripcion(_, _, _), N),
    operaciones(O).
% --- Requisitos memorizados -------------------------------------------------

test(requisitos_de_bd, true(R == [alg, log, pp, ssl])) :-
    requisitos_de(bd, R).

test(requisitos_de_am1, true(R == [])) :-
    requisitos_de(am1, R).

test(requisitos_guardados, true(R == [alg, am1])) :-
    requisitos_de(am2, _),
    reglas:requisitos_guardados(am2, R).

:- end_tests(reglas).
