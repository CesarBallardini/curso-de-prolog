:- encoding(utf8).

:- begin_tests(soluciones_agenda, [cleanup(limpiar_agenda)]).

test(seguidas, [true(P == [llenar(1), pasar(1, 2)])]) :-
    buscar_limpio(jarras(4, 3, 2), _),
    buscar_limpio(jarras(4, 3, 1), P).

test(nada_queda, [true(N-V == 0-0)]) :-
    buscar_limpio(jarras(4, 3, 2), _),
    aggregate_all(count, pendiente(_), N),
    aggregate_all(count, visto(_), V).

test(nada_queda_si_falla, [true(N-V == 0-0)]) :-
    \+ buscar_limpio(jarras(4, 2, 1), _),
    aggregate_all(count, pendiente(_), N),
    aggregate_all(count, visto(_), V).

% Una búsqueda dentro de otra borra la agenda de la de afuera.
test(anidada, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(buscar_limpio(prudente(jarras(4, 3, 2)), _),
                              1000000, R).

:- end_tests(soluciones_agenda).
