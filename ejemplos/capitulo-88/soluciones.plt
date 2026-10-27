:- encoding(utf8).

:- use_module(claves, [responder_claves/2]).

:- begin_tests(soluciones).

% Ejercicio 1.
test(quienes, [true(R == lista([101, 103]))]) :-
    analizar("¿Quiénes cursan análisis 2?", F),
    evaluar(F, R).

test(cuantas, [true(R == numero(3))]) :-
    analizar("¿Cuántas materias cursa carla?", F),
    evaluar(F, R).

% Ejercicio 2.
test(no_cursa_claves, [true(R == lista(["ana", "bruno", "diego", "facundo"]))]) :-
    responder_claves("¿Quién no cursa lógica?", R).

test(no_cursa, [true(R == lista([103, 105, 107]))]) :-
    analizar("¿Quién no cursa lógica?", F),
    evaluar(F, R).

% Ejercicio 3.
test(sin_analisis, [all(T == ["¿Qué nota tiene ana en lógica?",
                              "¿Aprobó ana lógica?",
                              "¿Cuántas materias de primer año aprobó ana?"])]) :-
    member(T, ["¿Qué nota tiene ana en lógica?",
               "¿Aprobó ana lógica?",
               "¿Cuántas materias de primer año aprobó ana?"]),
    lecturas(T, []).

% Ejercicio 4.
test(desaprobar, [true(R == lista([102, 103]))]) :-
    analizar("¿Quién desaprobó álgebra?", F),
    evaluar(F, R).

test(desaprobar_sql, [true(sub_string(S, _, _, _, "t2.nota < 6"))]) :-
    analizar("¿Quién desaprobó álgebra?", F),
    sql(F, S).

% Ejercicio 5.
test(simplificar, [true(S =@= cual(X, y(carrera(X, sistemas), cursar(X, pp))))]) :-
    analizar("¿Qué alumnos de sistemas cursan paradigmas?", F),
    simplificar(F, S).

test(simplificar_igual, [true(R1 == R2)]) :-
    analizar("¿Qué alumnos de sistemas cursan paradigmas?", F),
    simplificar(F, S),
    evaluar(F, R1),
    evaluar(S, R2).

test(simplificar_sql, [true(SQL == "SELECT DISTINCT t1.legajo, t1.nombre\nFROM \c
                                    alumnos t1, inscripciones t2\nWHERE \c
                                    t1.carrera = 'sistemas'\n  AND \c
                                    t2.legajo = t1.legajo\n  AND \c
                                    t2.materia = 'pp'\nORDER BY t1.legajo")]) :-
    analizar("¿Qué alumnos de sistemas cursan paradigmas?", F),
    simplificar(F, S),
    sql(S, SQL).

% Ejercicio 6.
test(elena, [true(M == sin_nota(inscripcion(105, am1, null)))]) :-
    por_que_no_esta("¿Quién aprobó análisis 1?", "elena", M).

test(ana, [true(M == se_prueba(prueba(aprobar(101, log),
                                      [inscripcion(101, log, 10),
                                       10 >= 6])))]) :-
    por_que_no_esta("¿Quién no aprobó lógica?", "ana", M).

test(esta, [fail]) :-
    por_que_no_esta("¿Quién aprobó lógica?", "ana", _).

% Ejercicio 7.
test(sin_tabla, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(findall(Q-N, pasos_sin_tabla(bd, Q, N), _),
                              1000000, R).

test(ciclo, [true(Ps == [alg-2, bd-3, log-2, pp-1, ssl-1])]) :-
    snapshot(( assertz(base:correlativa(log, bd)),
               abolish_all_tables,
               setof(Q-N, pasos(bd, Q, N), Ps) )),
    abolish_all_tables.

% Ejercicio 8.
test(lecturas, [true(Rs == [lista([alg, log, pp, ssl]), lista([])])]) :-
    responder_lecturas("¿Qué necesita bases de datos?", Ps),
    pairs_values(Ps, Rs).

% Ejercicio 9.
test(por_que, [true(S == "> Sí\n>   inscripcion(101, log, 10), 10 >= 6\n\c
                          > No hay una pregunta anterior.\n> ")]) :-
    open_string("¿Ana aprobó lógica?\n¿por qué?\n", E1),
    with_output_to(string(S1), conversar_por_que(E1, current_output)),
    open_string("¿por qué?\n", E2),
    with_output_to(string(S2), conversar_por_que(E2, current_output)),
    sub_string(S1, 0, _, 2, Primera),
    string_concat(Primera, S2, S).

% Ejercicio 10.
test(presuposicion, [true(sub_string(S, 0, _, _, "SELECT CASE WHEN"))]) :-
    ejemplo(14, T),
    analizar(T, F),
    sql_presuposicion(F, S).

test(presuposicion_otra, [true(S == S0)]) :-
    analizar("¿Ana aprobó lógica?", F),
    sql_presuposicion(F, S),
    sql(F, S0).

% Ejercicio 11.
test(coordinacion, [true(R == lista([101, 102, 104]))]) :-
    analizar("¿Quién cursa lógica y álgebra?", F),
    evaluar(F, R).

test(coordinacion_sujeto, [true(R == lista([alg, log, pp]))]) :-
    analizar("¿Qué materias cursan ana y diego?", F),
    evaluar(F, R).

test(aplicar, [true(F =@= cursar(101, M))]) :-
    aplicar(Y^cursar(Y, M), 101, F).

test(aplicar_mal, [true(F \== cursar(101, M))]) :-
    aplicar_mal(Y^cursar(Y, M), 101, F).

% Antes del verbo la propiedad no está construida: no se analiza.
test(antes_del_verbo, [fail]) :-
    analizar("¿Ana y diego cursan lógica?", _).

:- end_tests(soluciones).
