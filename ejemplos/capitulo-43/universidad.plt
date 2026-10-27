:- encoding(utf8).

:- begin_tests(universidad).

% Las tablas tienen las filas de schema.sql.
test(filas, [true(Ns == [7, 7, 7, 17])]) :-
    aggregate_all(count, alumno(_, _, _, _), A),
    aggregate_all(count, materia(_, _, _), M),
    aggregate_all(count, correlativa(_, _), C),
    aggregate_all(count, inscripcion(_, _, _), I),
    Ns = [A, M, C, I].

test(de_carrera, [all(L-N == [101-ana, 102-bruno, 104-diego])]) :-
    de_carrera(sistemas, L, N).

test(acta, [all(A-N == [ana-8, bruno-4, carla-7, elena-null,
                        facundo-6])]) :-
    acta(am1, A, N).

test(companeros, [all(A1-A2 == [ana-bruno, ana-diego, ana-facundo,
                                bruno-diego, bruno-facundo,
                                diego-facundo])]) :-
    companeros(log, A1, A2).

% La unión da una respuesta por fila: 7 + 7.
test(vinculada, [true(K-Ms == 14-[alg, am1, am2, bd, log, pp, ssl])]) :-
    aggregate_all(count, vinculada(_), K),
    setof(M, vinculada(M), Ms).

test(sin_correlativas, [all(M == [am1, alg, log])]) :-
    sin_correlativas(M).

% Con la negación primero, la variable llega libre y no hay respuestas.
test(negacion_primero, [fail]) :-
    Meta = ( \+ correlativa(M, _), materia(M, _, _) ),
    call(Meta).

test(en_ambas, [all(L == [101, 102, 103])]) :-
    en_ambas(am1, alg, L).

test(aprobadas, [true(K == 10)]) :-
    aggregate_all(count, aprobada(_, _, _), K).

% null queda del lado de la negación: 17 = 10 + 7.
test(no_aprobadas, [true(K == 7)]) :-
    aggregate_all(count, ( inscripcion(L, M, N),
                           \+ aprobada(L, M, N) ), K).

test(comparar_null, [error(type_error(evaluable, null/0))]) :-
    null >= 6.

test(inscriptos, [all(M-K == [am1-5, alg-4, log-4, am2-2, pp-2, ssl-0,
                              bd-0])]) :-
    inscriptos(M, K).

test(inscriptos_grupo, [all(M-K == [alg-4, am1-5, am2-2, log-4,
                                    pp-2])]) :-
    inscriptos_grupo(M, K).

test(promedio, [all(M-P == [alg-5.75, am1-6.25, am2-7, log-7, pp-8])]) :-
    promedio(M, P).

test(consistente, [fail]) :-
    violacion(_).

% Una clave repetida aparece en las dos filas que la comparten. Los hechos
% se agregan en user: en la unidad de pruebas crearían predicados propios.
test(clave_repetida, [true(Vs == [clave(alumnos, alumno(101, ana, sistemas,
                                                        2023)),
                                  clave(alumnos, alumno(101, zoe, civil,
                                                        2025))])]) :-
    snapshot(( assertz(user:alumno(101, zoe, civil, 2025)),
               findall(V, violacion(V), Vs) )).

test(violaciones, [true(Vs == [nulo(alumnos, nombre),
                               tipo(alumnos, ingreso, dos_mil),
                               rango(inscripciones, nota, 0),
                               referencia(inscripciones, materia, fis)])]) :-
    snapshot(( assertz(user:alumno(108, null, civil, dos_mil)),
               assertz(user:inscripcion(101, fis, 0)),
               findall(V, violacion(V), Vs) )).

test(insertar, [true(Fs == [inscripcion(107, am1, null)])]) :-
    snapshot(( insertar(inscripcion(107, am1, null)),
               findall(inscripcion(107, M, N), inscripcion(107, M, N),
                       Fs) )).

test(insertar_clave,
     [error(restriccion(clave(alumnos,
                              alumno(101, ana, sistemas, 2023))))]) :-
    snapshot(insertar(alumno(101, zoe, civil, 2025))).

test(insertar_referencia,
     [error(restriccion(referencia(inscripciones, legajo, 999)))]) :-
    snapshot(insertar(inscripcion(999, am1, null))).

test(insertar_rango,
     [error(restriccion(rango(inscripciones, nota, 11)))]) :-
    snapshot(insertar(inscripcion(107, am1, 11))).

test(insertar_otra_forma, [fail]) :-
    insertar(alumno(108, hugo)).

test(borrar, [true(K == 6)]) :-
    snapshot(( borrar(alumno(107, _, _, _)),
               aggregate_all(count, alumno(_, _, _, _), K) )).

test(borrar_referida,
     [error(restriccion(referida(alumnos, alumno(101, ana, sistemas, 2023),
                                 inscripcion(101, am1, 8))))]) :-
    snapshot(borrar(alumno(101, _, _, _))).

test(borrar_inexistente, [fail]) :-
    borrar(alumno(999, _, _, _)).

test(poner_nota, [true(N == 8)]) :-
    snapshot(( poner_nota(101, pp, 8),
               inscripcion(101, pp, N) )).

test(poner_nota_inexistente, [fail]) :-
    snapshot(poner_nota(107, pp, 8)).

test(poner_nota_rango,
     [error(restriccion(rango(inscripciones, nota, 12)))]) :-
    snapshot(poner_nota(101, pp, 12)).

% Una fila con varias faltas da todas, en el orden de las cláusulas.
test(violaciones_al_insertar,
     [true(Vs == [rango(inscripciones, nota, 11),
                  referencia(inscripciones, legajo, 999),
                  referencia(inscripciones, materia, xyz)])]) :-
    findall(V, violacion_al_insertar(inscripciones, inscripcion(999, xyz, 11),
                                     V), Vs).

test(violaciones_de_valor,
     [true(Vs == [nulo(alumnos, nombre), tipo(alumnos, carrera, 7),
                  clave(alumnos, alumno(101, ana, sistemas, 2023))])]) :-
    findall(V, violacion_al_insertar(alumnos, alumno(101, null, 7, 2025), V),
            Vs).

test(misma_clave, [all(O == [inscripcion(101, am1, 8)])]) :-
    misma_clave(inscripciones, inscripcion(101, am1, 3), O).

test(tabla_de, [true(T == inscripciones)]) :-
    tabla_de(inscripcion(1, am1, null), T).

% Un hecho con otra aridad no es una fila de la tabla.
test(tabla_de_otra_aridad, [fail]) :-
    tabla_de(alumno(1, ana, civil), _).

test(valor, [all(C-V == [codigo-am1, nombre-n, anio-1])]) :-
    valor(materias, materia(am1, n, 1), C, V).

test(poner_nota_null, [true(N == null)]) :-
    snapshot(( poner_nota(101, am1, null),
               inscripcion(101, am1, N) )).

test(poner_nota_tipo,
     [error(restriccion(tipo(inscripciones, nota, ocho)))]) :-
    snapshot(poner_nota(101, pp, ocho)).

:- end_tests(universidad).
