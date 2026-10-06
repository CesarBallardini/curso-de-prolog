:- encoding(utf8).

:- begin_tests(sintaxis).

test(seleccion,
     [true(S == consulta(seleccion(no, [item(columna(nombre), sin_alias)],
                                   [desde(alumnos, alumnos)],
                                   comparar(=, columna(carrera), cad(civil)),
                                   [], cierto),
                         [], sin_limite))]) :-
    analizar("SELECT nombre FROM alumnos WHERE carrera = 'civil'", S).

test(join_y_precedencia,
     [true(D == y(comparar(=, columna(a, legajo), columna(i, legajo)),
                  y(comparar(=, columna(i, materia), cad(am1)),
                    o(comparar(>, columna(i, nota), ent(5)),
                      es_nulo(columna(i, nota))))))]) :-
    analizar("SELECT a.nombre FROM alumnos a JOIN inscripciones i ON a.legajo = i.legajo WHERE i.materia = 'am1' AND (i.nota > 5 OR i.nota IS NULL)",
             consulta(seleccion(_, _, _, D, _, _), _, _)).

test(aritmetica, [true(E == ent(1) + ent(2) * columna(x) - ent(3))]) :-
    analizar("SELECT 1 + 2 * x - 3 FROM t",
             consulta(seleccion(_, [item(E, _)], _, _, _, _), _, _)).

test(agrupar_ordenar,
     [true(Q == consulta(seleccion(no, [item(columna(carrera), sin_alias),
                                        item(agregado(count, no, todo), n)],
                                   [desde(alumnos, alumnos)], cierto,
                                   [columna(carrera)],
                                   comparar(>=, agregado(count, no, todo),
                                            ent(2))),
                         [orden(columna(n), desc), orden(columna(carrera), asc)],
                         2))]) :-
    analizar("SELECT carrera, COUNT(*) AS n FROM alumnos GROUP BY carrera HAVING COUNT(*) >= 2 ORDER BY n DESC, carrera LIMIT 2", Q).

test(crear_tabla,
     [true(S == crear_tabla(emp, [columna(nombre, texto, no_nulo),
                                  columna(sueldo, entero, no_nulo),
                                  columna(depto, entero, nulo)],
                            [nombre]))]) :-
    analizar("CREATE TABLE emp (nombre TEXT PRIMARY KEY, sueldo INTEGER NOT NULL, depto INT)", S).

test(clave_compuesta, [true(K == [a, b])]) :-
    analizar("CREATE TABLE t (a TEXT, b TEXT, PRIMARY KEY (a, b))",
             crear_tabla(t, _, K)).

test(insertar,
     [true(S == insertar(emp, todas, valores([[cad(a), ent(1), ent(2)],
                                              [cad(b), ent(3), nulo]])))]) :-
    analizar("INSERT INTO emp VALUES ('a', 1, 2), ('b', 3, NULL);", S).

test(actualizar_y_eliminar, [true(F1-F2 == actualizar-eliminar)]) :-
    analizar("UPDATE emp SET sueldo = sueldo + 1 WHERE nombre NOT IN (SELECT nombre FROM x)", S1),
    analizar("DELETE FROM emp WHERE x BETWEEN 1 AND 3", S2),
    functor(S1, F1, _),
    functor(S2, F2, _).

test(union, [true(F == union)]) :-
    analizar("SELECT a FROM t UNION SELECT a FROM u",
             consulta(C, [], sin_limite)),
    functor(C, F, _).

test(vista_y_otras, [true(Fs == [crear_vista, borrar_vista, borrar_tabla,
                                 tablas, describir])]) :-
    maplist([T, F]>>( analizar(T, S), functor(S, F, _) ),
            [ "CREATE VIEW v AS SELECT a FROM t", "DROP VIEW v",
              "DROP TABLE t", "SHOW TABLES", "DESCRIBE t" ],
            Fs).

test(error_lejos, [throws(error(sql(sintaxis([n(where), n(x), =])), _))]) :-
    analizar("SELECT nombre FROM WHERE x = 1", _).

test(error_al_final, [throws(error(sql(sintaxis(fin)), _))]) :-
    analizar("SELECT nombre FROM", _).

:- end_tests(sintaxis).
