:- encoding(utf8).

% Pruebas de registro.pl: la carga como programa, con sus pares de más, y
% la lectura como datos, término por término.

:- begin_tests(registro).

test(hechos_un_dia, [true(N-Is == 413-[])]) :-
    cargar_hechos(registros('2026-09-28.log'), M),
    aggregate_all(count, par_hechos(M, _, _), N),
    findall(I, sin_respuesta_hechos(M, I), Is).

test(hechos_con_rearranque, [true(N-Is == 465-[397])]) :-
    cargar_hechos(registros('2026-10-01.log'), M),
    aggregate_all(count, par_hechos(M, _, _), N),
    findall(I, sin_respuesta_hechos(M, I), Is).

test(hechos_modulo, [true(M == '2026-10-01')]) :-
    cargar_hechos(registros('2026-10-01.log'), M).

test(leer_un_dia, [true(N-Pendientes == 413-[])]) :-
    leer_registro(registros('2026-09-28.log'), Pedidos, Pendientes),
    length(Pedidos, N).

test(leer_con_rearranque, [true(N == 419)]) :-
    leer_registro(registros('2026-10-01.log'), Pedidos, Pendientes),
    length(Pedidos, N),
    assertion(Pendientes = [pendiente(_, ip(10, 1, 0, 58), get, '/ranking')]).

test(leer_ordenado) :-
    leer_registro(registros('2026-10-01.log'), Pedidos),
    msort(Pedidos, Pedidos),
    length(Pedidos, 419).

test(paso_request, [true(Ps == [])]) :-
    empty_assoc(A0),
    paso(request(7, 10.5, [peer(ip(1, 2, 3, 4)), method(get), path('/a')]),
         A0, A, Ps),
    assertion(get_assoc(7, A, abierto(10.5, ip(1, 2, 3, 4), get, '/a'))).

test(paso_completed,
     [true(Ps == [pedido(10.5, ip(1, 2, 3, 4), get, '/a', 200, 0.25)])]) :-
    list_to_assoc([7-abierto(10.5, ip(1, 2, 3, 4), get, '/a')], A0),
    paso(completed(7, 0.25, 12, 200, ok), A0, A, Ps),
    assertion(empty_assoc(A)).

test(paso_completed_sin_pedido, [true(Ps == [])]) :-
    empty_assoc(A0),
    paso(completed(7, 0.25, 12, 200, ok), A0, A, Ps),
    assertion(A == A0).

test(paso_server,
     [true(Ps == [pendiente(10.5, ip(1, 2, 3, 4), get, '/a')])]) :-
    list_to_assoc([7-abierto(10.5, ip(1, 2, 3, 4), get, '/a')], A0),
    paso(server(started, 11), A0, A, Ps),
    assertion(empty_assoc(A)).

test(cerrar_en_orden, [true(Ps == [pendiente(1, x, get, '/b'),
                                  pendiente(2, y, get, '/a')])]) :-
    list_to_assoc([2-abierto(2, y, get, '/a'), 1-abierto(1, x, get, '/b')],
                  A),
    cerrar(A, Ps).

test(rearranque_con_numeros_repetidos,
     [true(Ps == [pedido(1.0, a, get, '/x', 200, 0.1),
                  pedido(5.0, b, get, '/y', 404, 0.2)])]) :-
    empty_assoc(A0),
    foldl(paso_acumulado,
          [ request(1, 1.0, [peer(a), method(get), path('/x')]),
            completed(1, 0.1, 1, 200, ok),
            server(started, 4),
            request(1, 5.0, [peer(b), method(get), path('/y')]),
            completed(1, 0.2, 1, 404, ok) ],
          A0-[], _-Inv),
    reverse(Inv, Ps).

% paso_acumulado(T, A0-Ps0, A-Ps): paso/4 con los pedidos acumulados en
% orden inverso.
paso_acumulado(T, A0-Ps0, A-Ps) :-
    paso(T, A0, A, Nuevos),
    reverse(Nuevos, NI),
    append(NI, Ps0, Ps).

test(contar_registro, [true(N == 419)]) :-
    contar_registro(registros('2026-10-01.log'), N, Pendientes),
    assertion(Pendientes = [pendiente(_, ip(10, 1, 0, 58), get, '/ranking')]).

:- end_tests(registro).
