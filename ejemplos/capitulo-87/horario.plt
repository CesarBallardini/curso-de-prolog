:- encoding(utf8).

:- begin_tests(horario).

test(clases, [true(Cs == [clase(2, 2, a2), clase(4, 2, a2)])]) :-
    clases_de(log, Cs).

test(sin_materia, [true(Cs == [])]) :-
    clases_de(quimica, Cs).

test(forma, [true(F == cuando(log))]) :-
    gramatica:analizar("¿Cuándo se cursa lógica?", F).

test(dictar, [true(F == cuando(am1))]) :-
    gramatica:analizar("¿Cuándo se dicta análisis 1?", F).

test(preguntar, [true(S == "martes, franja 2, aula a2; jueves, franja 2, \c
                            aula a2\n  asignada(log-1, 2, 5, 6)\n  \c
                            asignada(log-2, 2, 13, 14)\n")]) :-
    with_output_to(string(S), preguntar("¿Cuándo se cursa lógica?")).

% El horario no es una tabla de la base: no hay sentencia SQL.
test(sin_sql, [fail]) :-
    sql("¿Cuándo se cursa lógica?").

% Las demás preguntas siguen igual.
test(otras, [true(R == numero(2))]) :-
    responder("¿Cuántos aprobaron álgebra?", R, _).

:- end_tests(horario).
