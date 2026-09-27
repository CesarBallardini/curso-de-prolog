:- encoding(utf8).

% Ejercicio 3: una prueba por modo de aprobada/3 y por caso límite.
:- begin_tests(aprobada_por_modo).

% (+, +, -): legajo y materia dados; una respuesta o ninguna.
test(legajo_y_materia, true(N == 10)) :-
    aprobada(101, log, N).

% (+, -, -): las materias aprobadas de un alumno, en el orden de los hechos.
test(materias_de_un_alumno, all(M-N == [am1-8, alg-9, log-10, am2-7])) :-
    aprobada(101, M, N).

% (-, +, -): quiénes aprobaron una materia.
test(alumnos_de_una_materia, all(L == [101, 102, 104])) :-
    aprobada(L, log, _).

% (-, -, -): la consulta más general.
test(todas, true(N == 10)) :-
    aggregate_all(count, aprobada(_, _, _), N).

% Caso límite: la nota mínima aprueba; una menos, no.
test(nota_minima_aprueba) :-
    aprobada(106, am1, 6).

test(nota_menor_no_aprueba, [fail]) :-
    aprobada(106, log, _).

% Caso límite: una materia que se está cursando no está aprobada.
test(cursando_no_aprobada, [fail]) :-
    aprobada(101, pp, _).

:- end_tests(aprobada_por_modo).

% Ejercicio 4: una tabla de casos con la opción forall.
:- begin_tests(tabla_de_inscripciones).

caso(104, ssl, aceptada).
caso(102, alg, aceptada).
caso(999, am1, rechazada(alumno_inexistente)).
caso(101, quimica, rechazada(materia_inexistente)).
caso(101, log, rechazada(ya_aprobada)).
caso(101, pp, rechazada(ya_la_cursa)).
caso(102, am2, rechazada(falta(am1))).
caso(105, log, rechazada(sin_vacantes)).

test(inscripcion_posible, [forall(caso(L, M, Esperado)), true(R == Esperado)]) :-
    inscripcion_posible(L, M, R).

:- end_tests(tabla_de_inscripciones).

% Ejercicio 5: la cláusula de comprobar_datos/0 que ninguna prueba cubría.
:- begin_tests(cobertura).

:- dynamic advertido/1.

user:message_hook(inscripcion_sin_datos(L, M), warning, _) :-
    assertz(plunit_cobertura:advertido(L-M)).

test(advertencia, [ setup(estado(E)),
                    cleanup(( restaurar(E), retractall(advertido(_)) )),
                    true(A == [999-am1]) ]) :-
    agregar_inscripcion(999, am1, cursando),
    comprobar_datos,
    findall(X, advertido(X), A).

:- end_tests(cobertura).

% Ejercicios 7 y 8.
:- begin_tests(depuracion).

test(registrado, [ setup(estado(E)), cleanup(restaurar(E)),
                   true(R == aceptada) ]) :-
    inscribir_registrado(104, ssl, R).

test(invariante) :-
    vacantes_no_negativas.

:- end_tests(depuracion).

% Ejercicio 13: la segunda llamada a requisitos_de/2 usa el valor guardado.
:- begin_tests(memoria).

inferencias(G, I) :-
    statistics(inferences, I0),
    once(G),
    statistics(inferences, I1),
    I is I1 - I0.

test(segunda_llamada_mas_barata) :-
    retractall(reglas:requisitos_guardados(_, _)),
    inferencias(requisitos_de(bd, _), Primera),
    inferencias(requisitos_de(bd, _), Segunda),
    Segunda < Primera,
    Segunda < 10.

:- end_tests(memoria).
