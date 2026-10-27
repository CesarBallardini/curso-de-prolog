:- encoding(utf8).

:- use_module(catalogo).
:- use_module(sintaxis).
:- use_module(consultas).

:- begin_tests(vistas).

test(crear_y_usar, [ setup(estado(E)), cleanup(restaurar(E)),
                     true(R-Fs == creada(aprobadas)-[[am1], [alg], [log], [am2]]) ]) :-
    analizar("CREATE VIEW aprobadas AS SELECT legajo, materia, nota FROM inscripciones WHERE nota >= 6", S),
    vista(S, R),
    filas("SELECT materia FROM aprobadas WHERE legajo = 101", _, Fs).

test(clausula, [ setup(estado(E)), cleanup(restaurar(E)),
                 true(C =@= (aprobadas(L, M, N) :- base:inscripcion(L, M, N),
                                                   N \== null, N >= 6)) ]) :-
    analizar("CREATE VIEW aprobadas AS SELECT legajo, materia, nota FROM inscripciones WHERE nota >= 6", S),
    vista(S, _),
    clause(relaciones:aprobadas(A, B, D), Cuerpo),
    C = (aprobadas(A, B, D) :- Cuerpo).

test(catalogo, [ setup(estado(E)), cleanup(restaurar(E)),
                 true(Clase-Cs =@= vista-[col(materia, texto, no_nulo, M),
                                          col(promedio, real, nulo, P)]) ]) :-
    analizar("CREATE VIEW notas AS SELECT materia, AVG(nota) AS promedio FROM inscripciones GROUP BY materia", S),
    vista(S, _),
    relacion(notas, Clase, relaciones:notas(M, P), Cs).

test(vista_de_vista, [ setup(estado(E)), cleanup(restaurar(E)),
                       true(Fs == [[am1, 6.25]]) ]) :-
    analizar("CREATE VIEW notas AS SELECT materia, AVG(nota) AS promedio FROM inscripciones GROUP BY materia", S),
    vista(S, _),
    filas("SELECT materia, promedio FROM notas WHERE promedio > 6 AND promedio < 7", _, Fs).

test(no_recursiva, [ setup(estado(E)), cleanup(restaurar(E)),
                     throws(error(sql(tabla_desconocida(r)), _)) ]) :-
    analizar("CREATE VIEW r AS SELECT materia FROM r", S),
    vista(S, _).

test(nombres_repetidos, [ setup(estado(E)), cleanup(restaurar(E)),
                          throws(error(sql(columna_repetida(nombre)), _)) ]) :-
    analizar("CREATE VIEW v AS SELECT a.nombre, m.nombre FROM alumnos a, materias m", S),
    vista(S, _).

test(borrar, [ setup(estado(E)), cleanup(restaurar(E)),
               true(R-Ns == borrada(v)-[alumnos, correlativas, inscripciones, materias]) ]) :-
    analizar("CREATE VIEW v AS SELECT nombre FROM alumnos", S),
    vista(S, _),
    vista(borrar_vista(v), R),
    relaciones(Ns),
    \+ catch(relaciones:v(_), _, fail).

test(borrar_tabla_no, [ throws(error(sql(no_es_vista(alumnos)), _)) ]) :-
    vista(borrar_vista(alumnos), _).

:- end_tests(vistas).
