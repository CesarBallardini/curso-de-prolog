:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1: con persona/1 definido, nieto/2 responde.
test(los_abuelos_de_luis, all(A == [juan])) :-
    nieto(luis, A).

% Ejercicio 6: la regla corregida usa el mismo padre para los dos.
test(los_hermanos_de_ana, all(H == [pedro])) :-
    hermano(ana, H).

% Ejercicio 8: el requisito de toda correlativa es de un año anterior.
test(requisito_de_un_anio_anterior, [fail]) :-
    correlativa(Materia, Requisito),
    materia(Materia, _, Anio),
    materia(Requisito, _, AnioRequisito),
    AnioRequisito >= Anio.

% Ejercicio 11: nadie está inscripto dos veces en la misma materia, con
% notas distintas. Dos hechos idénticos no se detectan así (ver la solución).
test(sin_inscripciones_repetidas, [fail]) :-
    inscripcion(Legajo, Materia, Nota1),
    inscripcion(Legajo, Materia, Nota2),
    Nota1 \== Nota2.

:- end_tests(soluciones).
