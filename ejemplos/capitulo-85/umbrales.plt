:- encoding(utf8).

% Pruebas de umbrales.pl: la media y el desvío, la mediana y la MAD, el
% ajuste de los dos modelos y las anomalías del último día con los
% umbrales ajustados.

:- begin_tests(umbrales).

% cerca(X, Y): X e Y difieren en menos de una millonésima.
cerca(X, Y) :-
    abs(X - Y) < 1.0e-6.

% sin_cpu(R, S): la anomalía R sin los números del tiempo de CPU.
sin_cpu(anomalia(H, cpu, _, _)-_, cpu(H)) :-
    !.
sin_cpu(anomalia(H, M, V, _)-C, a(H, M, V, C)).

% anomalias_con(Modelo, Horas, Lista): las anomalías del último día con
% los umbrales ajustados con Modelo a Horas.
anomalias_con(Modelo, Horas, Lista) :-
    umbrales(Modelo, Horas, U),
    leer_registro(registros('2026-10-01.log'), Ps),
    anomalias(Ps, U, R),
    maplist(sin_cpu, R, Lista).

test(media_desvio) :-
    media_desvio([2, 4, 4, 4, 5, 5, 7, 9], M, D),
    assertion(cerca(M, 5)),
    assertion(cerca(D, 2)).

test(mediana_impar, [true(M == 3)]) :-
    mediana([5, 1, 3], M).

test(mediana_par, [true(M =:= 2.5)]) :-
    mediana([4, 1, 3, 2], M).

test(mad, [true(Me-Ma == 2-1)]) :-
    mad([1, 1, 2, 2, 4, 6, 9], Me, Ma).

test(mad_resiste, [true(Me-Ma == 2-1)]) :-
    mad([1, 1, 2, 2, 4, 6, 900], Me, Ma).

test(ajustar_media_desvio) :-
    ajustar(media_desvio(3), [2, 4, 4, 4, 5, 5, 7, 9], entre(I, S)),
    assertion(cerca(I, -1)),
    assertion(cerca(S, 11)).

test(ajustar_mediana_mad) :-
    ajustar(mediana_mad(3.5), [1, 1, 2, 2, 4, 6, 9], entre(I, S)),
    assertion(cerca(S, 2 + 3.5 / 0.6745)),
    assertion(cerca(I, 2 - 3.5 / 0.6745)).

test(valores, [true(Vs == [3, 7])]) :-
    valores(fallos, [hora(8, m(10, 3, 0, 0)), hora(9, m(12, 7, 0, 0))], Vs).

test(referencia, [true(N-Suma == 36-166)]) :-
    referencia(Horas),
    length(Horas, N),
    valores(fallos, Horas, Vs),
    sum_list(Vs, Suma).

test(umbrales_de_referencia) :-
    referencia(Horas),
    umbrales(media_desvio(3), Horas, U),
    memberchk(fallos-mayor(F), U),
    assertion(cerca(F, 19.107279187154138)).

test(media_desvio_de_referencia,
     [true(L == [a(10, pedidos, 98, cliente(ip(203, 0, 113, 7), 60)),
                 a(10, fallos, 62, cliente(ip(203, 0, 113, 7), 60)),
                 cpu(10), cpu(12),
                 a(14, fallos, 24, cliente(ip(198, 51, 100, 61), 17)),
                 cpu(14),
                 a(17, pedidos, 0, sin_trafico),
                 a(18, pedidos, 0, sin_trafico)])]) :-
    referencia(Horas),
    anomalias_con(media_desvio(3), Horas, L).

test(mediana_mad_de_referencia,
     [true(L == [a(10, pedidos, 98, cliente(ip(203, 0, 113, 7), 60)),
                 a(10, fallos, 62, cliente(ip(203, 0, 113, 7), 60)),
                 cpu(10), cpu(12),
                 a(14, fallos, 24, cliente(ip(198, 51, 100, 61), 17)),
                 cpu(14),
                 a(17, pedidos, 0, sin_trafico),
                 a(18, pedidos, 0, sin_trafico)])]) :-
    referencia(Horas),
    anomalias_con(mediana_mad(3.5), Horas, L).

test(media_desvio_enmascarada,
     [true(L == [a(10, fallos, 62, cliente(ip(203, 0, 113, 7), 60))])]) :-
    leer_registro(registros('2026-10-01.log'), Ps),
    metricas(Ps, Horas),
    anomalias_con(media_desvio(3), Horas, L).

test(mediana_mad_resiste,
     [true(L == [a(10, pedidos, 98, cliente(ip(203, 0, 113, 7), 60)),
                 a(10, fallos, 62, cliente(ip(203, 0, 113, 7), 60)),
                 cpu(10), cpu(12),
                 a(14, fallos, 24, cliente(ip(198, 51, 100, 61), 17))])]) :-
    leer_registro(registros('2026-10-01.log'), Ps),
    metricas(Ps, Horas),
    anomalias_con(mediana_mad(3.5), Horas, L).

test(umbrales_de_referencia) :-
    umbrales_de_referencia(mediana_mad(3.5), U),
    memberchk(fallos-mayor(F), U),
    assertion(cerca(F, 4 + 3.5 * 2 / 0.6745)).

test(umbrales_del_dia) :-
    umbrales_del_dia(media_desvio(3), registros('2026-10-01.log'), U),
    memberchk(fallos-mayor(F), U),
    assertion(F > 60),
    assertion(F < 62).

test(valores_de_referencia, [true(N-S == 36-166)]) :-
    valores_de_referencia(fallos, Vs),
    length(Vs, N),
    sum_list(Vs, S).

:- end_tests(umbrales).
