:- encoding(utf8).

:- begin_tests(soluciones_proyecto).

% Ejercicio 14
test(horario_minimo, true(D == 5)) :-
    horario_minimo(20, D, _).

% Ejercicio 15: con dos días de separación, hacen falta nueve.
test(separado, true(H == [am1-1, alg-3, log-5, am2-7, pp-9, ssl-1,
                           bd-1])) :-
    once(horario_separado(9, 20, H)).

test(separado_ocho_dias, [fail]) :-
    horario_separado(8, 20, _).

% Ejercicio 16
test(con_aulas, true(H == [examen(am1, 1, 2), examen(alg, 2, 1),
                           examen(log, 3, 1), examen(am2, 4, 1),
                           examen(pp, 5, 1), examen(ssl, 1, 1),
                           examen(bd, 2, 2)])) :-
    once(horario_con_aulas([4, 6], 5, H)).

% am1 tiene cinco inscriptos: ningún aula de 4 alcanza.
test(aulas_chicas, [fail]) :-
    horario_con_aulas([4, 4], 5, _).

:- end_tests(soluciones_proyecto).
