:- encoding(utf8).

:- begin_tests(minisql).

% La conversación de Kluźniak y Szpakowicz con Toy-Sequel, en SQL y con
% los datos en castellano: cada resultado es el que da su texto.
test(conversacion, [ setup(estado(E)), cleanup(restaurar(E)),
                     true(Rs == [ creada(empleados),
                                  creada(deptos),
                                  insertadas(6),
                                  insertadas(2),
                                  filas([nombre, sueldo],
                                        [[brown, 1000], [morgan, 1050]]),
                                  insertadas(2),
                                  actualizadas(1),
                                  eliminadas(1),
                                  filas([nombre], [[morgan]]),
                                  actualizadas(3),
                                  filas([nombre, sueldo],
                                        [[white, 900], [miller, 925],
                                         [thomas, 925]]),
                                  filas([nombre], [[brown], [white], [thomas],
                                                   [jones], [smith]]),
                                  filas([nombre], []),
                                  borrada(deptos) ]) ]) :-
    conversacion(Texto),
    guion(Texto, Rs).

conversacion("
  CREATE TABLE empleados (nombre TEXT PRIMARY KEY, sueldo INTEGER NOT NULL,
                          depto INTEGER);
  CREATE TABLE deptos (depto INTEGER PRIMARY KEY, jefe TEXT);
  INSERT INTO empleados VALUES ('brown', 1000, 1), ('white', 800, 1),
    ('miller', 850, 1), ('barry', 900, 2), ('thomas', 850, 1),
    ('morgan', 1050, 1);
  INSERT INTO deptos VALUES (1, 'jones'), (2, 'smith');
  SELECT nombre, sueldo FROM empleados WHERE depto <> 2 AND sueldo >= 1000;
  INSERT INTO empleados SELECT jefe, 1000, depto FROM deptos;
  UPDATE empleados SET sueldo = 1200 WHERE nombre = 'smith';
  DELETE FROM empleados WHERE nombre = 'barry';
  SELECT e.nombre FROM empleados e, deptos d, empleados j
    WHERE e.depto = d.depto AND d.jefe = j.nombre AND j.sueldo < e.sueldo;
  UPDATE empleados
    SET sueldo = sueldo + ((SELECT j.sueldo FROM deptos d, empleados j
                            WHERE d.depto = empleados.depto
                              AND d.jefe = j.nombre) - sueldo) / 2
    WHERE sueldo + 100 < (SELECT j.sueldo FROM deptos d, empleados j
                          WHERE d.depto = empleados.depto
                            AND d.jefe = j.nombre);
  SELECT nombre, sueldo FROM empleados WHERE sueldo > 850 AND sueldo < 950;
  SELECT nombre FROM empleados WHERE nombre < 'm' OR nombre >= 'n';
  SELECT nombre FROM empleados WHERE NOT depto IN (SELECT depto FROM deptos);
  DROP TABLE deptos").

test(sql, [true(R == filas([nombre, carrera], [[ana, sistemas], [carla, civil]]))]) :-
    sql("SELECT nombre, carrera FROM alumnos WHERE ingreso = 2023", R).

test(tablas_y_describir, [true(T-D == tablas([alumnos, correlativas,
                                              inscripciones, materias])-
                                      columnas(materias, [codigo-texto-not_null,
                                                          nombre-texto-not_null,
                                                          anio-entero-not_null]))]) :-
    sql("SHOW TABLES", T),
    sql("DESCRIBE materias", D).

test(escribir, [true(S == "carrera     count
----------  -----
civil       2
industrial  2
sistemas    3
")]) :-
    with_output_to(string(S),
                   sql("SELECT carrera, COUNT(*) FROM alumnos GROUP BY carrera")).

test(escribir_tres_columnas, [true(S == "codigo  nombre      anio
------  ----------  ----
am2     analisis_2  2
pp      paradigmas  2
")]) :-
    with_output_to(string(S),
                   sql("SELECT * FROM materias WHERE anio = 2 AND codigo <> 'ssl'")).

test(escribir_error, [true(S == "Error: tabla_desconocida(x).\n")]) :-
    with_output_to(string(S), sql("SELECT a FROM x")).

test(guion_sigue_despues_de_un_error,
     [ setup(estado(E)), cleanup(restaurar(E)),
       true(Rs == [error(clave_repetida(alumnos, [101])),
                   filas([nombre], [[ana]])]) ]) :-
    guion("INSERT INTO alumnos VALUES (101, 'zoe', 'civil', 2025);
           SELECT nombre FROM alumnos WHERE legajo = 101;", Rs).

test(mensaje, [true(Ms == ['Filas insertadas: 2.', 'Relación t creada.',
                           'Error: sintaxis(fin).',
                           't: a entero no nulo, b texto'])]) :-
    maplist(mensaje, [insertadas(2), creada(t), error(sintaxis(fin)),
                      columnas(t, [a-entero-not_null, b-texto])],
            Ms).

test(sesion, [ setup(estado(E)), cleanup(restaurar(E)),
               true(S == "mini-SQL. Cada sentencia termina en ';'. «salir» termina.\nFilas eliminadas: 3.\n") ]) :-
    setup_call_cleanup(
        open_string("DELETE FROM inscripciones\nWHERE nota IS NULL;\nsalir\n", In),
        with_output_to(string(S), with_input_from(In, sesion)),
        close(In)).

with_input_from(In, Meta) :-
    setup_call_cleanup(( current_input(Viejo), set_input(In),
                         set_stream(In, alias(user_input)) ),
                       Meta,
                       ( set_input(Viejo),
                         set_stream(Viejo, alias(user_input)) )).

:- end_tests(minisql).
