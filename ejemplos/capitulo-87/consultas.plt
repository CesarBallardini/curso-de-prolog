:- encoding(utf8).

:- begin_tests(consultas).

% filas/3 y las correcciones al compilador de Toy-Sequel

test(o, [true(Fs == [[carla], [elena], [facundo], [gabriela]])]) :-
    filas("SELECT nombre FROM alumnos WHERE carrera = 'civil' OR carrera = 'industrial'", _, Fs).

test(no, [true(Fs == [[ana], [bruno], [diego], [facundo], [gabriela]])]) :-
    filas("SELECT nombre FROM alumnos WHERE NOT carrera = 'civil'", _, Fs).

test(reunion, [true(Ns-Fs == [nombre, nota]-[[ana, 8], [bruno, 4], [carla, 7],
                                              [elena, null], [facundo, 6]])]) :-
    filas("SELECT a.nombre, i.nota FROM alumnos a, inscripciones i WHERE a.legajo = i.legajo AND i.materia = 'am1'", Ns, Fs).

% La lógica de tres valores: las tres inscripciones sin nota no están en
% ninguno de los dos grupos.
test(tres_valores, [true(K1-K2-K3 == 10-4-3)]) :-
    filas("SELECT COUNT(*) FROM inscripciones WHERE nota >= 6", _, [[K1]]),
    filas("SELECT COUNT(*) FROM inscripciones WHERE NOT (nota >= 6)", _, [[K2]]),
    filas("SELECT COUNT(*) FROM inscripciones WHERE nota IS NULL", _, [[K3]]).

test(no_de_una_disyuncion, [true(K == 3)]) :-
    filas("SELECT COUNT(*) FROM inscripciones WHERE NOT (nota >= 6 OR materia = 'am1')", _, [[K]]).

test(igual_null, [true(Fs == [])]) :-
    filas("SELECT legajo FROM inscripciones WHERE nota = NULL", _, Fs).

test(en_lista, [true(Fs == [[am1], [am2], [pp]])]) :-
    filas("SELECT codigo FROM materias WHERE codigo IN ('am1', 'am2', 'pp', 'xx')", _, Fs).

test(no_en_lista_con_null, [true(Fs == [])]) :-
    filas("SELECT codigo FROM materias WHERE NOT codigo IN ('am1', NULL)", _, Fs).

test(en_subconsulta, [true(Fs == [[ana], [diego]])]) :-
    filas("SELECT nombre FROM alumnos WHERE legajo IN (SELECT legajo FROM inscripciones WHERE materia = 'pp')", _, Fs).

test(no_existe_correlacionada, [true(Fs == [[107, gabriela]])]) :-
    filas("SELECT a.legajo, a.nombre FROM alumnos a WHERE NOT EXISTS (SELECT * FROM inscripciones i WHERE i.legajo = a.legajo)", _, Fs).

test(escalar, [true(Fs == [[ana, 10]])]) :-
    filas("SELECT a.nombre, i.nota FROM inscripciones i JOIN alumnos a ON a.legajo = i.legajo WHERE i.materia = 'log' AND i.nota = (SELECT MAX(nota) FROM inscripciones WHERE materia = 'log')", _, Fs).

test(aritmetica, [true(Ns-Fs == [nombre, sig, expresion]-[[carla, 2024, 1011],
                                                         [elena, 2026, 1012]])]) :-
    filas("SELECT nombre, ingreso + 1 AS sig, ingreso / 2 FROM alumnos WHERE carrera = 'civil'", Ns, Fs).

% La versión 6: agregados, orden, límite y conjuntos

test(agrupar, [true(Fs == [[sistemas, 3], [civil, 2], [industrial, 2]])]) :-
    filas("SELECT carrera, COUNT(*) AS n FROM alumnos GROUP BY carrera HAVING COUNT(*) >= 2 ORDER BY n DESC, carrera", _, Fs).

test(promedio, [true(Fs == [[101, 8.5], [102, 4.0], [103, 6.0], [104, 8.0],
                            [106, 4.5]])]) :-
    filas("SELECT legajo, AVG(nota) FROM inscripciones WHERE nota IS NOT NULL GROUP BY legajo", _, Fs).

test(sin_filas, [true(Fs == [[0, null, null]])]) :-
    filas("SELECT COUNT(*), SUM(ingreso), MAX(nombre) FROM alumnos WHERE carrera = 'quimica'", _, Fs).

test(sin_filas_agrupadas, [true(Fs == [])]) :-
    filas("SELECT carrera, COUNT(*) FROM alumnos WHERE carrera = 'quimica' GROUP BY carrera", _, Fs).

test(contar_distintos, [true(Fs == [[7, 3]])]) :-
    filas("SELECT COUNT(carrera), COUNT(DISTINCT carrera) FROM alumnos", _, Fs).

test(distinto_y_orden, [true(Fs == [[civil], [industrial], [sistemas]])]) :-
    filas("SELECT DISTINCT carrera FROM alumnos ORDER BY carrera", _, Fs).

test(orden_null_primero, [true(Fs == [[null], [null], [null], [2], [3]])]) :-
    filas("SELECT nota FROM inscripciones WHERE nota IS NULL OR nota < 4 ORDER BY nota", _, Fs).

test(limite, [true(Fs == [[am2], [pp]])]) :-
    filas("SELECT codigo FROM materias WHERE anio > 1 LIMIT 2", _, Fs).

test(union, [true(Fs == [[101], [102], [103], [104], [105], [106]])]) :-
    filas("SELECT legajo FROM inscripciones WHERE materia = 'am1' UNION SELECT legajo FROM inscripciones WHERE materia = 'log' ORDER BY legajo", _, Fs).

test(interseccion_y_diferencia,
     [true(I-D == [[101], [102], [103]]-[[105], [106]])]) :-
    filas("SELECT legajo FROM inscripciones WHERE materia = 'am1' INTERSECT SELECT legajo FROM inscripciones WHERE materia = 'alg'", _, I),
    filas("SELECT legajo FROM inscripciones WHERE materia = 'am1' EXCEPT SELECT legajo FROM inscripciones WHERE materia = 'alg'", _, D).

% Los errores que se detectan al compilar

test(tipos, [throws(error(sql(tipos(texto, entero)), _))]) :-
    filas("SELECT nombre FROM alumnos WHERE nombre = 3", _, _).

test(no_agrupada, [throws(error(sql(no_agrupada(nombre)), _))]) :-
    filas("SELECT nombre, carrera FROM alumnos GROUP BY carrera", _, _).

test(agregado_en_where,
     [throws(error(sql(agregado_fuera_de_lugar(count)), _))]) :-
    filas("SELECT nombre FROM alumnos WHERE COUNT(*) > 1", _, _).

test(varias_filas, [throws(error(sql(subconsulta_de_varias_filas), _))]) :-
    filas("SELECT nombre FROM alumnos WHERE legajo = (SELECT legajo FROM inscripciones)", _, _).

test(no_es_consulta, [throws(error(sql(no_es_consulta), _))]) :-
    filas("DROP TABLE alumnos", _, _).

% traducir/3 y mostrar_traduccion/1: las metas que el capítulo muestra

test(traducir_igualdades,
     [true(F-M =@= [A, N]-(base:alumno(L, A, _, _),
                            base:inscripcion(L, am1, N)))]) :-
    traducir("SELECT a.nombre, i.nota FROM alumnos a, inscripciones i WHERE a.legajo = i.legajo AND i.materia = 'am1'",
             _, F-M).

test(traducir_no,
     [true(Cs-M =@= [col(legajo, entero, no_nulo), col(materia, texto, no_nulo)]-
                    (base:inscripcion(L, Ma, N), N \== null, N < 6))]) :-
    traducir("SELECT legajo, materia FROM inscripciones WHERE NOT (nota >= 6)",
             Cs, [L, Ma]-M).

test(traducir_no_existe,
     [true(M =@= (base:alumno(L, N, _, _), \+ base:inscripcion(L, _, _)))]) :-
    traducir("SELECT a.legajo, a.nombre FROM alumnos a WHERE NOT EXISTS (SELECT * FROM inscripciones i WHERE i.legajo = a.legajo)",
             _, [L, N]-M).

test(mostrar,
     [true(S == "consulta([A]) :-\n    base:alumno(_, A, civil, _).\n")]) :-
    with_output_to(string(S),
                   mostrar_traduccion("SELECT nombre FROM alumnos WHERE carrera = 'civil'")).

% Los predicados del compilador, uno por uno

test(compilar_consulta, [true(Fs == [[am1], [alg], [log]])]) :-
    sintaxis:analizar("SELECT codigo FROM materias WHERE anio = 1", Q),
    compilar_consulta(Q, [], M, Vs, [col(codigo, texto, no_nulo)]),
    findall(Vs, M, Fs).

test(condicion_dos_polaridades,
     [true(V-F =@= (X \== null, X > 5)-(X \== null, X =< 5))]) :-
    Pila = [[marco(i, [col(nota, entero, nulo, X)])]],
    condicion(comparar(>, columna(nota), ent(5)), fila, Pila, verdadera, V),
    condicion(comparar(>, columna(nota), ent(5)), fila, Pila, falsa, F).

test(expresion_constante, [true(V-T-N-M == 7-entero-no_nulo-true)]) :-
    expresion(ent(1) + ent(2) * ent(3), fila, [], V, T, N, M).

test(igualdades, [true(R-G =@= prueba(Y \== null)-g(Y, Y, am1))]) :-
    Marcos = [ marco(a, [col(x, entero, nulo, X)]),
               marco(b, [col(y, entero, nulo, Y), col(z, texto, nulo, Z)]) ],
    igualdades(y(comparar(=, columna(x), columna(y)),
                 comparar(=, columna(z), cad(am1))),
               [Marcos], R),
    G = g(X, Y, Z).

test(igualdad_bajo_o_no_se_resuelve, [true(R =@= C)]) :-
    C = o(comparar(=, columna(x), ent(1)), comparar(=, columna(x), ent(2))),
    igualdades(C, [[marco(a, [col(x, entero, nulo, _)])]], R).

test(operar, [true(L == [5, null, null, -3, 7.5])]) :-
    operar(+, 2, 3, A),
    operar(*, null, 3, B),
    operar(/, 7, 0, C),
    operar(/, -7, 2, D),
    operar(*, 2.5, 3, E),
    L = [A, B, C, D, E].

test(escalar, [true(V-W == null-3)]) :-
    escalar(fail, _, V),
    escalar(member(X, [3]), X, W).

test(grupos, [true(G1-G2 == ([[]-[[1], [2]]])-[[a]-[[1], [3]], [b]-[[2]]])]) :-
    grupos(si, [[]-[1], []-[2]], G1),
    grupos(no, [[b]-[2], [a]-[1], [a]-[3]], G2).

% Cada fila tiene un valor por agregado; null no cuenta.
test(agregados, [true(R == [4, 3, 11, 2.75, 0, 5])]) :-
    agregados([count-no, count-si, sum-no, avg-no, min-no, max-no],
              [ [1, 1, 1, 1, 1, 1],
                [5, 5, 5, 5, 5, 5],
                [null, null, null, null, null, null],
                [0, 0, 0, 0, 0, 0],
                [5, 5, 5, 5, 5, 5] ],
              R).

test(agregados_sin_valores, [true(R == [0, null, null, null])]) :-
    agregados([count-no, sum-no, avg-no, max-no],
              [[null, null, null, null]], R).

test(procesar, [true(Fs == [[null], [a], [b]])]) :-
    procesar([distinto, ordenar([1-asc]), limite(3)],
             [[b], [a], [null], [b], [c]], Fs).

test(procesar_desc, [true(Fs == [[c], [b], [a], [null]])]) :-
    procesar([ordenar([1-desc])], [[a], [null], [c], [b]], Fs).

test(combinar, [true(L == [[[1], [2], [1], [1], [3]], [[1], [2], [3]],
                           [[1]], [[2]]])]) :-
    findall(F, ( member(Op, [union_todo, union, interseccion, diferencia]),
                 combinar(Op, [[1], [2], [1]], [[1], [3]], F) ),
            L).

:- end_tests(consultas).
