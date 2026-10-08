:- encoding(utf8).

% Pruebas del módulo datos (capítulo 24): los datos: cada inscripción es de
% un alumno y una materia existentes, y los estados son válidos.

:- begin_tests(datos).

% --- Datos ---------------------------------------------------------------

test(toda_inscripcion_es_de_un_alumno, [fail]) :-
    inscripcion(Legajo, _, _),
    \+ alumno(Legajo, _, _, _).

test(toda_inscripcion_es_a_una_materia, [fail]) :-
    inscripcion(_, Materia, _),
    \+ materia(Materia, _, _).

test(toda_correlativa_une_materias, [fail]) :-
    correlativa(Materia, Requisito),
    (   \+ materia(Materia, _, _)
    ;   \+ materia(Requisito, _, _)
    ).

% Un estado es cursando o nota(N) con N entero de 1 a 10.
test(los_estados_son_validos, [fail]) :-
    inscripcion(_, _, Estado),
    Estado \== cursando,
    \+ ( Estado = nota(N),
         integer(N),
         between(1, 10, N) ).

:- end_tests(datos).
