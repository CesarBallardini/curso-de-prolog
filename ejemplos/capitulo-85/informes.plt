:- encoding(utf8).

% Pruebas de informes.pl: las métricas por hora, las anomalías con los
% umbrales fijos y sus causas.

:- begin_tests(informes).

% dia(F, Pedidos): los pedidos del registro F, de archivos/.
dia(F, Pedidos) :-
    leer_registro(registros(F), Pedidos).

test(hora, [true(H == 10)]) :-
    date_time_stamp(date(2026, 10, 1, 10, 59, 59, 10800, -, -), T),
    hora(T, H).

test(medir_vacio, [true(M == m(0, 0, 0, 0))]) :-
    medir([], M).

test(medir, [true(M == m(3, 1, 1, 0.5))]) :-
    medir([ pedido(1, a, post, '/sesion', 401, 0.25),
            pedido(2, a, get, '/x', 404, 0.25),
            pedido(3, b, get, '/y', 200, sin_medir) ], M).

test(metricas_dia_4,
     [true(L == [8-30-3-0, 9-30-0-0, 10-98-62-0, 11-29-5-0, 12-25-2-0,
                 13-43-6-0, 14-46-24-0, 15-59-8-0, 16-36-5-0, 17-0-0-0,
                 18-0-0-0, 19-23-1-0])]) :-
    dia('2026-10-01.log', Ps),
    metricas(Ps, Hs),
    findall(H-N-F-X, member(hora(H, m(N, F, X, _)), Hs), L).

test(metricas_doce_horas, [true(N == 12)]) :-
    metricas([], Hs),
    length(Hs, N).

test(metrica, [all(N-V == [pedidos-1, fallos-2, no_encontradas-3, cpu-4])]) :-
    metrica(N, m(1, 2, 3, 4), V).

test(anomalia_mayor, [true(As == [anomalia(9, fallos, 12, mayor(10))])]) :-
    findall(A, anomalia([fallos-mayor(10)],
                        [hora(8, m(5, 10, 0, 0)), hora(9, m(20, 12, 0, 0))],
                        A),
            As).

test(anomalia_menor, [true(As == [anomalia(8, pedidos, 2, menor(5))])]) :-
    findall(A, anomalia([pedidos-menor(5)],
                        [hora(8, m(2, 0, 0, 0)), hora(9, m(20, 0, 0, 0))],
                        A),
            As).

test(anomalias_dia_4,
     [true(As == [ anomalia(10, fallos, 62, mayor(10))-cliente(ip(203, 0, 113, 7), 60),
                   anomalia(10, cpu)-ruta('/sesion'),
                   anomalia(12, cpu)-ruta('/sesion'),
                   anomalia(14, fallos, 24, mayor(10))-cliente(ip(198, 51, 100, 61), 17),
                   anomalia(17, pedidos, 0, menor(5))-sin_trafico,
                   anomalia(18, pedidos, 0, menor(5))-sin_trafico ])]) :-
    dia('2026-10-01.log', Ps),
    umbrales_fijos(U),
    anomalias(Ps, U, R),
    maplist(sin_numeros, R, As).

% sin_numeros(R, S): R sin los números de punto flotante del tiempo de CPU.
sin_numeros(anomalia(H, cpu, _, _)-ruta(Ruta, _), anomalia(H, cpu)-ruta(Ruta)) :-
    !.
sin_numeros(R, R).

test(anomalias_dia_3, [true(R == [anomalia(11, no_encontradas, 10, mayor(5))-
                                  cliente(ip(203, 0, 113, 50), 10)])]) :-
    dia('2026-09-30.log', Ps),
    umbrales_fijos(U),
    anomalias(Ps, U, R).

test(atacante_lento_no_se_ve, [fail]) :-
    dia('2026-09-30.log', Ps),
    umbrales_fijos(U),
    anomalias(Ps, U, R),
    member(anomalia(_, fallos, _, _)-_, R).

test(causa_fallos, [true(C == cliente(b, 2))]) :-
    date_time_stamp(date(2026, 10, 1, 9, 0, 0, 10800, -, -), T),
    Ps = [ pedido(T, a, post, '/sesion', 401, 0.1),
           pedido(T, b, post, '/sesion', 401, 0.1),
           pedido(T, b, post, '/sesion', 401, 0.1),
           pedido(T, a, get, '/x', 200, 0.1) ],
    causa(Ps, anomalia(9, fallos, 3, mayor(1)), C).

test(causa_sin_trafico, [true(C == sin_trafico)]) :-
    causa([], anomalia(9, pedidos, 0, menor(5)), C).

test(escribir_anomalias, [true(S == " 9 h  fallos 12 > 10          1.2.3.4, 12 pedidos\n")]) :-
    with_output_to(string(S),
                   escribir_anomalias([anomalia(9, fallos, 12, mayor(10))-
                                       cliente(ip(1, 2, 3, 4), 12)])).

test(escribir_metricas, [true(S == "hora  pedidos  fallos  404    cpu\n 9 h       20      12    0   0.50\n")]) :-
    with_output_to(string(S),
                   escribir_metricas([hora(9, m(20, 12, 0, 0.5))])).

test(hora_del_dia, [true(N-F-X == 98-62-0)]) :-
    hora_del_dia(registros('2026-10-01.log'), 10, m(N, F, X, _)).

test(hora_del_dia_fuera, [fail]) :-
    hora_del_dia(registros('2026-10-01.log'), 7, _).

test(informe, [true(Lineas == 13)]) :-
    with_output_to(string(S), informe(registros('2026-10-01.log'))),
    split_string(S, "\n", "", Partes),
    length(Partes, N),
    Lineas is N - 1.

test(informe_anomalias, [true(Lineas == 6)]) :-
    umbrales_fijos(U),
    with_output_to(string(S),
                   informe_anomalias(registros('2026-10-01.log'), U)),
    split_string(S, "\n", "", Partes),
    length(Partes, N),
    Lineas is N - 1.

:- end_tests(informes).
