:- encoding(utf8).

:- begin_tests(soluciones_negacion).

test(ejercicio_12, all(S == [[gorrion(piolin)-verdadero,
                              pinguino(piolin)-falso, muerto(piolin)-falso,
                              herido(piolin)-falso]])) :-
    suponer(vuela(piolin), S),
    cerrar(S).

test(ejercicio_12_no_vuela, [true(N == 6)]) :-
    aggregate_all(count, ( suponer((no(vuela(piolin)), ave(piolin)), S),
                           cerrar(S) ), N).

:- end_tests(soluciones_negacion).
