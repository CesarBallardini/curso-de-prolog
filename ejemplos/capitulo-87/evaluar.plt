:- encoding(utf8).

:- begin_tests(evaluar).

test(cual, [true(R == lista([101, 102, 104, 106]))]) :-
    evaluar(cual(X, y(alumno(X), cursar(X, log))), R).

test(cuantos, [true(R == numero(2))]) :-
    evaluar(cuantos(X, y(alumno(X), aprobar(X, alg))), R).

test(negacion, [true(R == lista([102, 103, 105, 106, 107]))]) :-
    evaluar(cual(X, y(alumno(X), no(aprobar(X, alg)))), R).

test(si, [true(R == si)]) :-
    evaluar(si_no(aprobar(101, log)), R).

test(no, [true(R == no)]) :-
    evaluar(si_no(aprobar(102, alg)), R).

test(todos_si, [true(R == si)]) :-
    evaluar(si_no(todo(X, y(alumno(X), carrera(X, civil)), cursar(X, am1))),
            R).

test(todos_no, [true(R == no)]) :-
    evaluar(si_no(todo(X, y(alumno(X), carrera(X, sistemas)),
                       aprobar(X, alg))), R).

test(presuposicion, [true(R = presupone(_))]) :-
    evaluar(si_no(todo(X, y(alumno(X), cursar(X, bd)), aprobar(X, log))), R).

test(necesitar, [true(R == lista([alg, log, pp, ssl]))]) :-
    evaluar(cual(X, y(materia(X), necesitar(bd, X))), R).

test(explicar_cuantos,
     [true(E == [101-y(prueba(alumno(101), [alumno(101, ana, sistemas, 2023)]),
                       prueba(aprobar(101, alg),
                              [inscripcion(101, alg, 9), 9 >= 6])),
                 104-y(prueba(alumno(104), [alumno(104, diego, sistemas, 2024)]),
                       prueba(aprobar(104, alg),
                              [inscripcion(104, alg, 7), 7 >= 6]))])]) :-
    explicar(cuantos(X, y(alumno(X), aprobar(X, alg))), E).

test(explicar_no,
     [true(E == falla(no_alcanza(inscripcion(102, alg, 2), 2 < 6)))]) :-
    explicar(si_no(aprobar(102, alg)), E).

test(sin_nota, [true(M == sin_nota(inscripcion(105, am1, null)))]) :-
    por_que_no(aprobar(105, am1), M).

test(sin_hechos, [true(M == sin_hechos(cursar(107, log)))]) :-
    por_que_no(cursar(107, log), M).

test(contraejemplo,
     [true(M == contraejemplo(102, no_alcanza(inscripcion(102, alg, 2),
                                              2 < 6)))]) :-
    por_que_no(todo(X, y(alumno(X), carrera(X, sistemas)), aprobar(X, alg)),
               M).

test(ninguno,
     [true(M == ninguno([106-no_alcanza(inscripcion(106, log, 3), 3 < 6),
                         107-sin_hechos(aprobar(107, log))]))]) :-
    por_que_no(alguno(X, y(alumno(X), carrera(X, industrial)),
                       aprobar(X, log)), M).

test(explicar_presuposicion, [true(E = sin_casos(_))]) :-
    explicar(si_no(todo(X, y(alumno(X), cursar(X, bd)), aprobar(X, log))), E).

test(hojas_negacion,
     [true(Hs == [alumno(102, bruno, sistemas, 2024),
                  no_alcanza(inscripcion(102, alg, 2), 2 < 6)])]) :-
    once(probar(y(alumno(102), no(aprobar(102, alg))), T)),
    hojas(T, Hs).

% Las correlativas: la menor cantidad de pasos y la cadena más corta.
test(pasos, [true(Ps == [alg-2, log-2, pp-1, ssl-1])]) :-
    findall(R-N, pasos(bd, R, N), Ps0),
    sort(Ps0, Ps).

test(cadena, [true(C == [correlativa(bd, pp), correlativa(pp, log)])]) :-
    cadena(bd, log, C).

test(sin_cadena, [fail]) :-
    cadena(log, bd, _).

:- end_tests(evaluar).
