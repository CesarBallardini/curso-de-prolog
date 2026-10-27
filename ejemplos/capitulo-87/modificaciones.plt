:- encoding(utf8).

% Cada prueba guarda el estado de la base con estado/1 y lo repone con
% restaurar/1, de catalogo.pl.

:- use_module(catalogo).
:- use_module(sintaxis).

:- begin_tests(modificaciones).

alumnos(Ls) :-
    findall(L-N, base:alumno(L, N, _, _), Ls).

test(crear_e_insertar, [ setup(estado(E)), cleanup(restaurar(E)),
                         true(R1-R2-Fs == creada(t)-insertadas(2)-[t(a, 1), t(b, null)]) ]) :-
    analizar("CREATE TABLE t (x TEXT PRIMARY KEY, y INTEGER)", S1),
    modificar(S1, R1),
    analizar("INSERT INTO t VALUES ('a', 1), ('b', NULL)", S2),
    modificar(S2, R2),
    findall(t(X, Y), relaciones:t(X, Y), Fs).

test(ya_existe, [ setup(estado(E)), cleanup(restaurar(E)),
                  throws(error(sql(ya_existe(alumnos)), _)) ]) :-
    modificar(crear_tabla(alumnos, [columna(x, entero, nulo)], []), _).

test(columna_repetida, [ setup(estado(E)), cleanup(restaurar(E)),
                         throws(error(sql(columna_repetida(x)), _)) ]) :-
    modificar(crear_tabla(t, [columna(x, entero, nulo),
                              columna(x, texto, nulo)], []), _).

test(insertar_columnas, [ setup(estado(E)), cleanup(restaurar(E)),
                          true(F == [107, log, null]) ]) :-
    modificar(insertar(inscripciones, [legajo, materia],
                       valores([[ent(107), cad(log)]])), insertadas(1)),
    findall([L, M, N], ( base:inscripcion(L, M, N), L == 107 ), [F]).

test(insertar_select, [ setup(estado(E)), cleanup(restaurar(E)),
                        true(N-K == 2-19) ]) :-
    analizar("INSERT INTO inscripciones SELECT legajo, 'ssl', NULL FROM alumnos WHERE carrera = 'civil'", S),
    modificar(S, insertadas(N)),
    aggregate_all(count, base:inscripcion(_, _, _), K).

test(clave_repetida, [ setup(estado(E)), cleanup(restaurar(E)),
                       throws(error(sql(clave_repetida(alumnos, [101])), _)) ]) :-
    modificar(insertar(alumnos, todas,
                       valores([[ent(101), cad(zoe), cad(civil), ent(2025)]])), _).

test(nada_si_falla_una, [ setup(estado(E)), cleanup(restaurar(E)),
                          true(Ls0 == Ls) ]) :-
    alumnos(Ls0),
    catch(modificar(insertar(alumnos, todas,
                             valores([[ent(108), cad(hugo), cad(civil), ent(2025)],
                                      [ent(109), nulo, cad(civil), ent(2025)]])), _),
          error(sql(nulo(alumnos, nombre)), _),
          true),
    alumnos(Ls).

test(tipo, [ setup(estado(E)), cleanup(restaurar(E)),
             throws(error(sql(tipo(alumnos, ingreso, x)), _)) ]) :-
    modificar(insertar(alumnos, todas,
                       valores([[ent(108), cad(hugo), cad(civil), cad(x)]])), _).

test(rango, [ setup(estado(E)), cleanup(restaurar(E)),
              throws(error(sql(rango(inscripciones, nota, 11)), _)) ]) :-
    modificar(insertar(inscripciones, todas,
                       valores([[ent(107), cad(log), ent(11)]])), _).

test(cantidad, [ setup(estado(E)), cleanup(restaurar(E)),
                 throws(error(sql(cantidad_de_valores), _)) ]) :-
    modificar(insertar(alumnos, todas, valores([[ent(108)]])), _).

test(eliminar, [ setup(estado(E)), cleanup(restaurar(E)),
                 true(N-K == 3-14) ]) :-
    analizar("DELETE FROM inscripciones WHERE nota IS NULL", S),
    modificar(S, eliminadas(N)),
    aggregate_all(count, base:inscripcion(_, _, _), K).

test(actualizar_en_su_lugar, [ setup(estado(E)), cleanup(restaurar(E)),
                               true(N-Ms == 1-[am1-8, alg-9, log-10, am2-7, pp-8]) ]) :-
    analizar("UPDATE inscripciones SET nota = 8 WHERE legajo = 101 AND materia = 'pp'", S),
    modificar(S, actualizadas(N)),
    findall(M-X, base:inscripcion(101, M, X), Ms).

test(actualizar_con_expresion, [ setup(estado(E)), cleanup(restaurar(E)),
                                 true(Is == [2024, 2026]) ]) :-
    analizar("UPDATE alumnos SET ingreso = ingreso + 1 WHERE carrera = 'civil'", S),
    modificar(S, actualizadas(2)),
    findall(I, base:alumno(_, _, civil, I), Is).

% La subconsulta de la condición se evalúa sobre el estado anterior a la
% sentencia: los dos alumnos de 2023 pasan a 2024.
test(instantanea, [ setup(estado(E)), cleanup(restaurar(E)),
                    true(Is == [2024, 2024, 2024, 2024, 2025, 2024, 2025]) ]) :-
    analizar("UPDATE alumnos SET ingreso = ingreso + 1 WHERE ingreso = (SELECT MIN(ingreso) FROM alumnos)", S),
    modificar(S, actualizadas(2)),
    findall(I, base:alumno(_, _, _, I), Is).

test(actualizar_clave, [ setup(estado(E)), cleanup(restaurar(E)),
                         throws(error(sql(clave_repetida(alumnos, [101])), _)) ]) :-
    analizar("UPDATE alumnos SET legajo = 101 WHERE legajo = 102", S),
    modificar(S, _).

test(borrar_tabla, [ setup(estado(E)), cleanup(restaurar(E)),
                     true(R-Ns == borrada(correlativas)-[alumnos, inscripciones, materias]) ]) :-
    modificar(borrar_tabla(correlativas), R),
    relaciones(Ns).

test(no_es_tabla, [ setup(estado(E)), cleanup(restaurar(E)),
                    throws(error(sql(tabla_desconocida(x)), _)) ]) :-
    modificar(eliminar(x, cierto), _).

:- end_tests(modificaciones).
