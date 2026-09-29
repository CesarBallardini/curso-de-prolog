:- encoding(utf8).

:- use_module('../capitulo-31/inscripciones/reglas', [ requisitos_de/2 ]).

:- begin_tests(soluciones_inscripciones).

test(habilita_log, [true(Ms == [bd, pp, ssl])]) :-
    findall(M, habilita(log, M), Ms0),
    msort(Ms0, Ms).

% habilita/2 es la relación inversa de los requisitos del capítulo 31.
test(inversa, [forall(datos:materia(M, _, _)), true(Rs == Rs31)]) :-
    findall(R, habilita(R, M), Rs0),
    sort(Rs0, Rs),
    requisitos_de(M, Rs31).

test(ana, [true(Ms == [ssl])]) :-
    materias_habilitadas(101, Ms).

test(bruno, [true(Ms == [alg, am1, pp])]) :-
    materias_habilitadas(102, Ms).

test(legajo_libre, [error(instantiation_error)]) :-
    materias_habilitadas(_, _).

:- end_tests(soluciones_inscripciones).
