:- encoding(utf8).

% Pruebas de Inscripciones (capítulo 14): las de datos del capítulo 13, con el
% estado nuevo, y una prueba por modo de cada regla (Patrón 2).

:- begin_tests(inscripciones).

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

% --- aprobada/3 ------------------------------------------------------------

% Todo libre: la consulta más general enumera todas las aprobadas.
test(todas_las_aprobadas, all(L-M-N == [101-am1-8, 101-alg-9, 101-log-10,
                                         101-am2-7, 102-log-6, 103-am1-7,
                                         104-log-9, 104-alg-7, 104-pp-8,
                                         106-am1-6])) :-
    aprobada(L, M, N).

% Legajo y materia ligados, nota libre: una respuesta.
test(nota_de_ana_en_logica, all(N == [10])) :-
    aprobada(101, log, N).

% Todo ligado: comprueba, y con una nota falsa falla (estabilidad).
test(ana_aprobo_logica_con_10) :-
    aprobada(101, log, 10).

test(ana_no_aprobo_logica_con_9, [fail]) :-
    aprobada(101, log, 9).

% Con nota menor que la mínima, la materia no está aprobada.
test(bruno_no_aprobo_algebra, [fail]) :-
    aprobada(102, alg, _).

% --- cursa/2 ---------------------------------------------------------------

test(quienes_cursan, all(L-M == [101-pp, 103-am2, 105-am1])) :-
    cursa(L, M).

test(ana_cursa_paradigmas) :-
    cursa(101, pp).

:- end_tests(inscripciones).
