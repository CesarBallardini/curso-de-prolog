:- encoding(utf8).

:- begin_tests(generar_datos).

% aggregate_all/3, que agrega las soluciones de un objetivo,
% se presenta en el capítulo 17.
test(cinco_mil_alumnos, true(N == 5000)) :-
    generar(5000),
    aggregate_all(count, alumno(_, _, _, _), N).

% findall/3, que reúne las soluciones en una lista,
% se presenta en el capítulo 17.
test(las_dos_versiones_responden_lo_mismo, true(M1 == M2)) :-
    generar(500),
    findall(M, aprobada_lenta(alumno_250, M), M1),
    findall(M, aprobada_rapida(alumno_250, M), M2).

% El costo de la versión lenta crece con la cantidad de alumnos; el de la
% rápida, no. Con 5 000 alumnos, unas 7 500 inferencias contra menos de 20.
test(costo_de_la_lenta_crece, true(L5000 > 5 * L500)) :-
    generar(500),
    inferencias(aprobada_lenta(alumno_250, bd), L500),
    generar(5000),
    inferencias(aprobada_lenta(alumno_2500, bd), L5000).

test(costo_de_la_rapida_no_crece, true(R5000 =< R500 + 5)) :-
    generar(500),
    inferencias(aprobada_rapida(alumno_250, bd), R500),
    generar(5000),
    inferencias(aprobada_rapida(alumno_2500, bd), R5000).

test(la_rapida_cuesta_menos, true(R * 100 < L)) :-
    generar(5000),
    inferencias(aprobada_lenta(alumno_2500, bd), L),
    inferencias(aprobada_rapida(alumno_2500, bd), R).

:- end_tests(generar_datos).
