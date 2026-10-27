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

test(las_dos, [true(D == [[especificidad]-rechazada(falta(alg)),
                          [declarada, especificidad]-
                              rechazada(falta(alg))])]) :-
    las_dos(D).

% Sin especificidad, las dos reglas rebatibles de cada requisito se
% derrotan entre sí.
test(con_criterio, [true(R-S == a_revisar(am1)-condicional([am1, alg]))]) :-
    con_criterio([], 105, am2, R),
    con_criterio([especificidad], 105, am2, S).

% Con especificidad, coincide con inscripcion_rebatible/3.
test(inscripcion_con_criterio,
     [forall(member(L-M, [101-pp, 105-am2, 102-am2, 101-bd]))]) :-
    inscripcion_con_criterio([especificidad], L, M, R),
    inscripcion_rebatible(L, M, R).

:- end_tests(soluciones_inscripciones).
