:- encoding(utf8).

:- begin_tests(soluciones_inscripciones).

test(excepciones, [true(Rs == [am1, alg])]) :-
    excepciones(105, am2, Rs).

test(excepcion_de_ana, [true(Rs-Ss == [pp]-[])]) :-
    excepciones(101, bd, Rs),
    excepciones(104, bd, Ss).

test(decisiones, [true(A-D == [E-C, DE-C]-[E-a_revisar(alg), DE-C])]) :-
    E = [especificidad],
    DE = [declarada, especificidad],
    C = condicional([alg]),
    decisiones(A, D).

test(datos_intactos, [true(R == rechazada(falta(alg)))]) :-
    decisiones(_, _),
    inscripcion_rebatible(102, ssl, R).

:- end_tests(soluciones_inscripciones).
