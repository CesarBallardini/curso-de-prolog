:- encoding(utf8).

:- begin_tests(soluciones_proyecto).

% Ejercicio 12: la prueba que protege el orden de aprobada_por_nombre/2. Con
% el orden invertido, la consulta usaría unas 7 500 inferencias.
test(aprobada_por_nombre_no_recorre_todo, true(I < 50)) :-
    generar(5000),
    inferencias(aprobada_por_nombre(alumno_2500, _), I).

:- end_tests(soluciones_proyecto).
