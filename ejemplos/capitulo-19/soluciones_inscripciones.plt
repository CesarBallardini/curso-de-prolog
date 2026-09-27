:- encoding(utf8).

:- begin_tests(soluciones_inscripciones).

% Ejercicio 10: una prueba por motivo, con la negación explicada.
test(por_que_bruno_no_cursa_am2,
     true(S == "rechazada(falta(am1)): por v3\n  requisito(am1): \c
                observado\n  no aprobada(am1): no se prueba\n\c
                rechazada(falta(alg)): por v3\n  requisito(alg): \c
                observado\n  no aprobada(alg): no se prueba\n")) :-
    with_output_to(string(S), por_que(102, am2)).

test(por_que_sin_motivos, true(S == "")) :-
    with_output_to(string(S), por_que(104, ssl)).

% Ejercicio 11
test(se_acepta) :-
    se_acepta(104, ssl).

test(no_se_acepta, [fail]) :-
    se_acepta(102, am2).

% El árbol de la aceptación es la negación de cualquier rechazo.
test(arbol_de_la_aceptacion, [nondet, true(Regla == v5)]) :-
    situacion(104, ssl, Obs),
    prueba(aceptada, Obs, deducido(aceptada, Regla, no rechazada(_))).

:- end_tests(soluciones_inscripciones).
