:- encoding(utf8).

:- begin_tests(preguntas).

test(responder, [true(R-E = numero(2)-[101-_, 104-_])]) :-
    responder("¿Cuántos aprobaron álgebra?", R, E).

test(sin_analisis, [true(R-E == sin_analisis-[])]) :-
    responder("¿Quién enseña lógica?", R, E).

test(lista, [true(S == "ana, bruno, diego y facundo\n  \c
                        ana: inscripcion(101, log, 10)\n  \c
                        bruno: inscripcion(102, log, 6)\n  \c
                        diego: inscripcion(104, log, 9)\n  \c
                        facundo: inscripcion(106, log, 3)\n")]) :-
    with_output_to(string(S), preguntar("¿Quién cursa lógica?")).

test(no, [true(S == "No\n  inscripcion(102, alg, 2), y 2 < 6\n")]) :-
    with_output_to(string(S), preguntar("¿Bruno aprueba álgebra?")).

test(si, [true(S == "Sí\n  inscripcion(101, log, 10), 10 >= 6\n")]) :-
    with_output_to(string(S), preguntar("¿Ana aprobó lógica?")).

test(negacion, [true(S == "bruno, carla, elena, facundo y gabriela\n  \c
                           bruno: inscripcion(102, alg, 2), y 2 < 6\n  \c
                           carla: inscripcion(103, alg, 5), y 5 < 6\n  \c
                           elena: ningún hecho prueba aprobar(105, alg)\n  \c
                           facundo: ningún hecho prueba aprobar(106, alg)\n  \c
                           gabriela: ningún hecho prueba aprobar(107, alg)\n")]) :-
    with_output_to(string(S), preguntar("¿Quién no aprobó álgebra?")).

test(todos, [true(S == "Sí\n  carla: inscripcion(103, am1, 7)\n  \c
                        elena: inscripcion(105, am1, null)\n")]) :-
    with_output_to(string(S),
                   preguntar("¿Todos los alumnos de civil cursan análisis 1?")).

test(contraejemplo, [true(S == "No\n  bruno: inscripcion(102, alg, 2), \c
                                y 2 < 6\n")]) :-
    with_output_to(string(S),
                   preguntar("¿Todos los alumnos de sistemas aprobaron álgebra?")).

test(ninguno_no, [true(S == "No\n  facundo: inscripcion(106, log, 3), y 3 < 6\n  \c
                             gabriela: ningún hecho prueba aprobar(107, log)\n")]) :-
    with_output_to(string(S),
                   preguntar("¿Algún alumno de industrial aprobó lógica?")).

test(ninguno_si, [true(S == "Sí\n  ninguno de los 7 casos\n")]) :-
    with_output_to(string(S), preguntar("¿Ningún alumno aprobó sintaxis?")).

test(cadena, [true(S == "álgebra, lógica, paradigmas y sintaxis\n  \c
                         álgebra: correlativa(bd, ssl), correlativa(ssl, alg)\n  \c
                         lógica: correlativa(bd, pp), correlativa(pp, log)\n  \c
                         paradigmas: correlativa(bd, pp)\n  \c
                         sintaxis: correlativa(bd, ssl)\n")]) :-
    with_output_to(string(S), preguntar("¿Qué necesita bases de datos?")).

test(presuposicion,
     [true(S == "La pregunta supone que hay casos, y no hay ninguno\n")]) :-
    with_output_to(string(S),
                   preguntar("¿Todos los alumnos que cursan bases de datos \c
                              aprobaron lógica?")).

test(no_analiza, [true(S == "La pregunta no se puede analizar\n")]) :-
    with_output_to(string(S), preguntar("¿Quién enseña lógica?")).

test(ninguno_lista, [true(S == "Ninguno\n")]) :-
    with_output_to(string(S), preguntar("¿Quién aprobó bases de datos?")).

test(sql, [true(S == "SELECT EXISTS (SELECT 1 FROM inscripciones t1 WHERE \c
                     t1.legajo = 101 AND t1.materia = 'log' AND \c
                     t1.nota >= 6)\n")]) :-
    with_output_to(string(S), sql("¿Ana aprobó lógica?")).

% Cada pregunta del capítulo se analiza.
test(ejemplos, [true(K == 16)]) :-
    aggregate_all(count, ( ejemplo(_, T), gramatica:analizar(T, _) ), K).

% El bucle: dos preguntas y una línea vacía.
test(conversar, [true(S == "> Sí\n  inscripcion(101, log, 10), 10 >= 6\n\c
                            > 2\n  ana: inscripcion(101, alg, 9), 9 >= 6\n  \c
                            diego: inscripcion(104, alg, 7), 7 >= 6\n> ")]) :-
    open_string("¿Ana aprobó lógica?\n¿Cuántos aprobaron álgebra?\n\nnada\n",
                Entrada),
    with_output_to(string(S), conversar(Entrada, current_output)).

% Sin línea vacía, hasta el fin de la entrada.
test(fin_de_entrada, [true(S == "> La pregunta no se puede analizar\n> ")]) :-
    open_string("hola", Entrada),
    with_output_to(string(S), conversar(Entrada, current_output)).

:- end_tests(preguntas).
