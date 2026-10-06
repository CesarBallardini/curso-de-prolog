:- encoding(utf8).

% Pruebas de soluciones.pl.

:- begin_tests(soluciones).

% cerca(X, Y): X e Y difieren en menos de una millonésima.
cerca(X, Y) :-
    abs(X - Y) < 1.0e-6.

test(ej1_hechos, [true(Cs-R == [200, 200, 200, 200]-si)]) :-
    cargar_hechos(registros('2026-10-01.log'), M),
    findall(C, par_hechos(M, 5, C), Cs),
    (   sin_respuesta_hechos(M, 397)
    ->  R = si
    ;   R = no
    ).

test(ej1_pendientes, [true(P == [pendiente(1.0, a, get, '/x')])]) :-
    registro_enganoso(Ts),
    pendientes_de(Ts, P).

test(ej1_hechos_no_lo_ven, [fail]) :-
    registro_enganoso(Ts),
    member(request(Id, _, _), Ts),
    \+ member(completed(Id, _, _, _, _), Ts).

test(ej2_recurso, [true(R == '/alumnos')]) :-
    recurso('/alumnos/123', R).

test(ej2_por_recurso,
     [true(Rs-Ns == ['/sesion', '/materias', '/mis-inscripciones',
                     '/alumnos', '/ranking']-[158, 122, 59, 46, 34])]) :-
    por_recurso(registros('2026-10-01.log'), Filas),
    findall(R, member(fila(R, _, _), Filas), Rs),
    findall(N, member(fila(_, N, _), Filas), Ns).

test(ej2_escribir, [true(S == "recurso              pedidos  cpu (ms)\n/sesion                    2     50.00\n")]) :-
    with_output_to(string(S), escribir_por_recurso([fila('/sesion', 2, 0.05)])).

test(ej3_combinada,
     [true(P = pedido(_, ip(1, 2, 3, 4), get, '/a', 200, sin_medir))]) :-
    phrase(linea_combinada(P),
           `1.2.3.4 - - [01/Oct/2026:08:00:00 -0300] "GET /a HTTP/1.1" 200 9 "-" "curl/8.0"`).

test(ej3_comun) :-
    phrase(linea_combinada(pedido(_, _, post, '/s', 401, sin_medir)),
           `1.2.3.4 - - [01/Oct/2026:08:00:00 -0300] "POST /s HTTP/1.1" 401 36`).

test(ej3_un_solo_agregado, [fail]) :-
    phrase(linea_combinada(_),
           `1.2.3.4 - - [01/Oct/2026:08:00:00 -0300] "GET /a HTTP/1.1" 200 9 "-"`).

test(ej4_presentes, [true(Hs == [8, 9, 10, 11, 12, 13, 14, 15, 16, 19])]) :-
    leer_registro(registros('2026-10-01.log'), Ps),
    metricas_presentes(Ps, Horas),
    findall(H, member(hora(H, _), Horas), Hs).

test(ej4_sin_caida, [true(N == 6)]) :-
    umbrales_de_referencia(mediana_mad(3.5), U),
    anomalias_presentes(registros('2026-10-01.log'), U, As),
    length(As, N),
    assertion(\+ member(anomalia(_, pedidos, 0, _), As)).

test(ej5_mad_cero, [true(I == entre(0.0, 0.0))]) :-
    valores_de_referencia(no_encontradas, Vs),
    ajustar(mediana_mad(3.5), Vs, I).

test(ej5_minimo) :-
    valores_de_referencia(no_encontradas, Vs),
    ajustar_con_minimo(3.5, 1, Vs, entre(_, S)),
    assertion(cerca(S, 3.5 / 0.6745)),
    assertion(S < 10).

test(ej6_cuantil, [true(L == 5)]) :-
    ajustar_cuantil(0.5, [9, 1, 5, 3, 7], L).

test(ej6_umbrales, [true(P-F == 20-10)]) :-
    umbrales_cuantil(0.95, [pedidos-menor(P), fallos-mayor(F), cpu-mayor(_)]).

test(ej7, [true(Cs == [-1, 1, 1, -1])]) :-
    maplist([X, C]>>salida([-18, -56, 70], X, C),
            [[1, 1], [4, 4], [12, 10], [40, 31]], Cs).

test(ej8_perfiles_diarios, [true(Ps == [perfil(a, dia, 3, 1),
                                        perfil(b, dia, 1, 1)])]) :-
    date_time_stamp(date(2026, 10, 1, 9, 30, 0, 10800, -, -), T9),
    date_time_stamp(date(2026, 10, 1, 10, 5, 0, 10800, -, -), T10),
    perfiles_diarios([ pedido(T9, b, post, '/sesion', 401, 0.1),
                       pedido(T9, a, post, '/sesion', 401, 0.1),
                       pedido(T9, a, post, '/sesion', 200, 0.1),
                       pedido(T10, a, get, '/materias', 200, 0.1) ], Ps).

test(ej8_entrenar, [true(N-P-C == 108-[-6, -50, 78]-[6, 2, 1, 0])]) :-
    ejemplos_diarios(Es),
    length(Es, N),
    entrenar(1, Es, [0, 0, 0], P, C).

test(ej8_sospechosos,
     [true(S3-S4 == [perfil(ip(198, 51, 100, 40), dia, 8, 8)]-
                    [perfil(ip(198, 51, 100, 61), dia, 17, 17),
                     perfil(ip(203, 0, 113, 7), dia, 60, 60)])]) :-
    sospechosos_diarios([-6, -50, 78], registros('2026-09-30.log'), S3),
    sospechosos_diarios([-6, -50, 78], registros('2026-10-01.log'), S4).

test(ej9_repetidos, [true(N == 40)]) :-
    repetidos(10, As),
    length(As, N).

test(ej9_resumen, [true(N == 480)]) :-
    repetidos(10, As),
    resumir_en_paralelo(fallos, As, r(N, _, _, _)).

test(ej10_limites) :-
    valores_de_referencia(fallos, Vs),
    limites_ponderados(3, 0.1, Vs, Ls),
    nth1(19, Ls, Antes),
    nth1(20, Ls, Despues),
    last(Ls, Ultimo),
    assertion(Antes < 11),
    assertion(Despues > 28),
    assertion(Ultimo > 18),
    assertion(Ultimo < 19).

test(ej10_ajustar) :-
    valores_de_referencia(fallos, Vs),
    ajustar_ponderado(3, 0.1, Vs, entre(_, S)),
    limites_ponderados(3, 0.1, Vs, Ls),
    last(Ls, L),
    assertion(cerca(S, L)).

test(ej10_constantes, [true(I == entre(4.0, 4.0))]) :-
    ajustar_ponderado(3, 0.5, [4, 4, 4], I0),
    I0 = entre(A, B),
    I = entre(A, B).

test(ej4_metricas_anomalas,
     [true(P == [10-pedidos, 10-fallos, 10-cpu, 12-cpu, 14-fallos, 14-cpu])]) :-
    metricas_anomalas(mediana_mad(3.5), registros('2026-10-01.log'), P).

test(ej8_entrenamiento_diario, [true(N-P-C == 108-[-6, -50, 78]-[6, 2, 1, 0])]) :-
    entrenamiento_diario(N, P, C).

:- end_tests(soluciones).
