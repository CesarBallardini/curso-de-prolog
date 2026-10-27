:- encoding(utf8).

% Las cuentas de cada trabajador dependen del reparto de los pedidos; su
% suma no: es la cantidad de pedidos atendidos desde que el servidor
% arrancó.

:- begin_tests(soluciones_servidor).

test(por_hilo, [true(S1-S2 == 30-60)]) :-
    iniciar(P, 3),
    call_cleanup(( visitas_por_hilo(P, 30, C1),
                   visitas_por_hilo(P, 30, C2) ),
                 detener(P)),
    aggregate_all(sum(V), member(_-V, C1), S1),
    aggregate_all(sum(V), member(_-V, C2), S2),
    length(C2, N),
    assertion(N =< 3).

:- end_tests(soluciones_servidor).
