:- encoding(utf8).

:- begin_tests(soluciones_proyecto).

% Ejercicio 14
test(ranking_de_sistemas, true(R == [101-8.5, 104-8, 102-4])) :-
    ranking_de_carrera(sistemas, R).

test(ranking_de_una_carrera_sin_notas, true(R == [])) :-
    ranking_de_carrera(quimica, R).

% Ejercicio 15
test(en_comun, true(L == [101, 102, 106])) :-
    indice_por_materia(I),
    alumnos_en_comun(I, am1, log, L).

test(materia_sin_inscriptos, true(L == [])) :-
    indice_por_materia(I),
    alumnos_en_comun(I, am1, bd, L).

:- end_tests(soluciones_proyecto).
