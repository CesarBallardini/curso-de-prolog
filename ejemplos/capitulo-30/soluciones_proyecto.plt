:- encoding(utf8).

:- begin_tests(soluciones_proyecto).

test(inscriptos_py, true(A =@= [ _{legajo: 101, nombre: ana},
                                 _{legajo: 102, nombre: bruno},
                                 _{legajo: 104, nombre: diego},
                                 _{legajo: 106, nombre: facundo} ])) :-
    inscriptos_py(log, A).

test(sin_inscriptos, true(A == [])) :-
    inscriptos_py(ssl, A).

:- end_tests(soluciones_proyecto).
