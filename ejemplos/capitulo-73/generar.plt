:- encoding(utf8).

:- begin_tests(generar).

test(candidatos, [true(K == 1889568)]) :-
    candidatos(materias([am1, alg], 3, 2), K).

test(primero_valido, [true(H == [ asignada(am1-1, 1, 0, 1),
                                  asignada(am1-2, 1, 2, 3),
                                  asignada(am1-3, 1, 4, 5),
                                  asignada(alg-1, 1, 1, 2),
                                  asignada(alg-2, 1, 3, 4) ])]) :-
    oferta(materias([am1, alg], 3, 2), O),
    once(generar_y_probar(O, H)).

test(validos_chicos, [true(N == 2)]) :-
    oferta(materias([alg], 2, 1), O),
    aggregate_all(count, generar_y_probar(O, _), N).

test(sin_horario, [fail]) :-
    oferta(materias([am1], 2, 2), O),
    generar_y_probar(O, _).

test(ensayos, [true(K == 2119)]) :-
    ensayos(materias([alg, log], 3, 2), K).

:- end_tests(generar).
