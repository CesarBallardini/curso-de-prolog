:- encoding(utf8).

:- begin_tests(sql).

test(cual, [true(S == "SELECT DISTINCT t1.legajo, t1.nombre\nFROM alumnos t1, \c
                      inscripciones t2\nWHERE t2.legajo = t1.legajo\n  AND \c
                      t2.materia = 'log'\nORDER BY t1.legajo")]) :-
    sql(cual(X, y(alumno(X), cursar(X, log))), S).

test(cuantos, [true(S == "SELECT COUNT(DISTINCT t1.legajo)\nFROM alumnos t1, \c
                         inscripciones t2\nWHERE t2.legajo = t1.legajo\n  \c
                         AND t2.materia = 'alg'\n  AND t2.nota >= 6")]) :-
    sql(cuantos(X, y(alumno(X), aprobar(X, alg))), S).

test(si_no, [true(S == "SELECT EXISTS (SELECT 1 FROM inscripciones t1 WHERE \c
                       t1.legajo = 101 AND t1.materia = 'log' AND \c
                       t1.nota >= 6)")]) :-
    sql(si_no(aprobar(101, log)), S).

test(negacion, [true(S == "SELECT DISTINCT t1.legajo, t1.nombre\nFROM \c
                          alumnos t1\nWHERE NOT EXISTS (SELECT 1 FROM \c
                          inscripciones t2 WHERE t2.legajo = t1.legajo AND \c
                          t2.materia = 'alg' AND t2.nota >= 6)\nORDER BY \c
                          t1.legajo")]) :-
    sql(cual(X, y(alumno(X), no(aprobar(X, alg)))), S).

test(todos, [true(S == "SELECT EXISTS (SELECT 1 WHERE NOT EXISTS (SELECT 1 \c
                       FROM alumnos t1, alumnos t2 WHERE t2.legajo = \c
                       t1.legajo AND t2.carrera = 'civil' AND NOT EXISTS \c
                       (SELECT 1 FROM inscripciones t3 WHERE t3.legajo = \c
                       t1.legajo AND t3.materia = 'am1')))")]) :-
    sql(si_no(todo(X, y(alumno(X), carrera(X, civil)), cursar(X, am1))), S).

test(recursiva, [true(sub_string(S, 0, _, _, "WITH RECURSIVE requisitos"))]) :-
    sql(cual(X, y(materia(X), necesitar(bd, X))), S).

test(sin_recursiva, [fail]) :-
    sql(cual(X, y(materia(X), cursar(101, X))), S),
    sub_string(S, _, _, _, "WITH").

% Una comilla del texto se duplica.
test(comilla, [true(S == "SELECT EXISTS (SELECT 1 FROM alumnos t1 WHERE \c
                         t1.legajo = 101 AND t1.carrera = 'o''higgins')")]) :-
    sql(si_no(carrera(101, 'o\'higgins')), S).

test(sin_tabla, [fail]) :-
    sql(si_no(dicta(perez, am1)), _).

test(atomo, [true(T-Cs == inscripciones-[legajo-L, materia-M])]) :-
    sql_atomo(cursar(L, M), T, Cs, _).

test(mostrar, [true(Salida == "SELECT EXISTS (SELECT 1 FROM inscripciones t1 \c
                              WHERE t1.legajo = 102 AND t1.materia = 'alg' \c
                              AND t1.nota >= 6)\n")]) :-
    with_output_to(string(Salida), mostrar_sql(si_no(aprobar(102, alg)))).

:- end_tests(sql).
