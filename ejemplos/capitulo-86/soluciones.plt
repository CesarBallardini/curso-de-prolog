:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1
test(ejercicio_1, [true(Ts == [n(select), n(x), -, i(1), ',', s('it''s'),
                               n(from), n(t), n(where), n(a), <>, n(b), ;])]) :-
    tokens("SELECT x-1, 'it''s' FROM t WHERE a != b;", Ts).

% Ejercicio 2
test(ejercicio_2, [true(I-C == []-[[facundo], [gabriela]])]) :-
    T = "SELECT nombre FROM alumnos WHERE NOT (carrera = 'civil' OR carrera = 'sistemas')",
    consulta_ingenua(T, I),
    filas(T, _, C).

% Ejercicio 3
test(ejercicio_3, [true(K == [13, 1, 3])]) :-
    findall(N, ( member(T, [ "SELECT COUNT(*) FROM inscripciones WHERE nota <> 4",
                             "SELECT COUNT(*) FROM inscripciones WHERE NOT (nota <> 4)",
                             "SELECT COUNT(*) FROM inscripciones WHERE nota IS NULL" ]),
                 filas(T, _, [[N]]) ),
            K).

% Ejercicio 4
test(ejercicio_4, [true(Cs == [alumnos-legajo, alumnos-nombre,
                               inscripciones-legajo, inscripciones-nota])]) :-
    columnas_usadas("SELECT a.nombre FROM alumnos a, inscripciones i WHERE a.legajo = i.legajo AND nota > 6", Cs).

test(ejercicio_4_ambigua, [throws(error(sql(columna_ambigua(legajo)), _))]) :-
    columnas_usadas("SELECT legajo FROM alumnos a, inscripciones i", _).

% Ejercicio 5
test(ejercicio_5, [ setup(estado(E)), cleanup(restaurar(E)),
                    true(R1-R2 == [[a, 1000], [b, 1300], [c, 1200]]-
                                  [[a, 1000], [b, 1300], [c, 1400]]) ]) :-
    U = "UPDATE s SET x = x + 200 WHERE x = (SELECT MAX(x) FROM s) - 100",
    Crear = "CREATE TABLE s (n TEXT, x INTEGER); INSERT INTO s VALUES ('a', 1000), ('b', 1100), ('c', 1200)",
    guion(Crear, _),
    sql(U, actualizadas(1)),
    sql("SELECT * FROM s", filas(_, R1)),
    sql("DROP TABLE s", _),
    guion(Crear, _),
    actualizar_tupla(U, 2),
    sql("SELECT * FROM s", filas(_, R2)).

% Ejercicio 6
consulta_ana("SELECT i.materia, i.nota FROM inscripciones i, alumnos a WHERE a.nombre = 'ana' AND a.legajo = i.legajo").

test(ejercicio_6_orden, [true(M =@= (base:alumno(L, ana, _, _),
                                     base:inscripcion(L, Ma, N)))]) :-
    consulta_ana(T),
    traducir_ordenado(T, [Ma, N]-M).

test(ejercicio_6_costos) :-
    consulta_ana(T),
    traducir(T, _, F1-M1),
    traducir_ordenado(T, F2-M2),
    inferencias_meta(F1, M1, N1, Fs1),
    inferencias_meta(F2, M2, N2, Fs2),
    Fs1 == Fs2,
    en_banda(N1, 32),
    en_banda(N2, 16).

inferencias_meta(F, M, N, Fs) :-
    findall(F, M, Fs),
    statistics(inferences, I0),
    findall(F, M, _),
    statistics(inferences, I1),
    N is I1 - I0.

test(generadores, [true(Gs-R == [base:p(1), base:q(2)]-(X > 1))]) :-
    generadores((base:p(1), base:q(2), X > 1), Gs, R).

% Ejercicio 7
test(ejercicio_7_rechaza, [ setup(estado(E)), cleanup(restaurar(E)),
                            throws(error(sql(referencia(inscripciones, legajo, 999)), _)) ]) :-
    insertar_verificado("INSERT INTO inscripciones (legajo, materia) VALUES (999, 'am1')", _).

test(ejercicio_7_repone, [ setup(estado(E)), cleanup(restaurar(E)),
                           true(K == 17) ]) :-
    catch(insertar_verificado("INSERT INTO inscripciones (legajo, materia) VALUES (999, 'am1')", _),
          error(sql(_), _), true),
    aggregate_all(count, base:inscripcion(_, _, _), K).

test(ejercicio_7_acepta, [ setup(estado(E)), cleanup(restaurar(E)),
                           true(R == insertadas(1)) ]) :-
    insertar_verificado("INSERT INTO inscripciones (legajo, materia) VALUES (107, 'am1')", R).

% Ejercicio 8
test(ejercicio_8, [ setup(estado(E)), cleanup(restaurar(E)),
                    true(K-Fs == 2-[[alg], [log], [pp], [ssl]]) ]) :-
    recursiva(requisito, "CREATE TABLE requisito (r TEXT)",
              "SELECT requisito FROM correlativas WHERE materia = 'bd'",
              "SELECT c.requisito FROM correlativas c, requisito q WHERE c.materia = q.r",
              K),
    sql("SELECT r FROM requisito ORDER BY r", filas(_, Fs)).

% Ejercicio 9: las filas de SQLite con LEFT JOIN, el par 19 del capítulo 42.
test(ejercicio_9, [ setup(estado(E)), cleanup(restaurar(E)),
                    true(Fs == [[alg, 4], [am1, 5], [am2, 2], [bd, 0], [log, 4],
                                [pp, 2], [ssl, 0]]) ]) :-
    guion("CREATE VIEW materia_legajo AS
             SELECT m.codigo AS codigo, i.legajo AS legajo
             FROM materias m, inscripciones i WHERE i.materia = m.codigo
             UNION ALL
             SELECT m.codigo, NULL FROM materias m
             WHERE NOT EXISTS (SELECT * FROM inscripciones i
                               WHERE i.materia = m.codigo);
           SELECT codigo, COUNT(legajo) FROM materia_legajo GROUP BY codigo",
          [creada(materia_legajo), filas(_, Fs)]).

% Ejercicio 10
test(ejercicio_10, [true(Fs == [])]) :-
    filas("SELECT nombre FROM alumnos WHERE ingreso NOT IN (SELECT nota FROM inscripciones)", _, Fs).

test(ejercicio_10_meta,
     [true(M =@= (base:alumno(_, A, _, B),
                  \+ ( base:inscripcion(C, D, E), E == null ),
                  \+ ( base:inscripcion(C, D, E), E \== null, B =:= E )))]) :-
    traducir("SELECT nombre FROM alumnos WHERE ingreso NOT IN (SELECT nota FROM inscripciones)",
             _, [A]-M).

% Ejercicio 11
test(ejercicio_11, [true(K-M =@= [[14]]-(base:inscripcion(L, _, N), N \== null))]) :-
    filas("SELECT COUNT(*) FROM inscripciones WHERE nota = nota", _, K),
    traducir("SELECT legajo FROM inscripciones WHERE nota = nota", _, [L]-M).

:- end_tests(soluciones).
