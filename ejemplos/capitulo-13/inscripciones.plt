:- encoding(utf8).

% Pruebas de los datos de Inscripciones. Todavía no hay reglas que probar:
% estas pruebas verifican que los hechos sean coherentes entre sí, y son las
% que el gancho de git ejecuta antes de cada commit (sección 13.7).

:- begin_tests(inscripciones).

test(las_materias_de_ana, all(M == [am1, alg, log, am2, pp])) :-
    inscripcion(101, M, _).

test(requisitos_de_bases_de_datos, all(R == [pp, ssl])) :-
    correlativa(bd, R).

% Ninguna inscripción nombra un legajo que no existe.
test(toda_inscripcion_es_de_un_alumno, [fail]) :-
    inscripcion(Legajo, _, _),
    \+ alumno(Legajo, _, _, _).

% Ninguna inscripción ni correlativa nombra una materia que no existe.
test(toda_inscripcion_es_a_una_materia, [fail]) :-
    inscripcion(_, Materia, _),
    \+ materia(Materia, _, _).

test(toda_correlativa_une_materias, [fail]) :-
    correlativa(Materia, Requisito),
    (   \+ materia(Materia, _, _)
    ;   \+ materia(Requisito, _, _)
    ).

% Una nota es un entero de 1 a 10, o null mientras se cursa.
test(las_notas_son_validas, [fail]) :-
    inscripcion(_, _, Nota),
    Nota \== null,
    \+ between(1, 10, Nota).

:- end_tests(inscripciones).
