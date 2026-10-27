:- encoding(utf8).

:- begin_tests(configurador).

test(bien_formado, [nondet]) :-
    programa(configurador, Reglas),
    maplist(bien_formado, Reglas).

test(juegos, [C, P, W] == [[procesador-cpu_b, placa-placa_a, memoria-mem_b,
                            disipador-dis_a, placa_de_video-gpu_a,
                            fuente-fuente_b], 1125, 378]) :-
    configurar([pedido(nucleos, 8), pedido(memoria, 32), pedido(video, si)],
               C, P, W).

% El procesador más barato necesita disipador.
test(oficina, [C, P, W] == [[procesador-cpu_c, placa-placa_b, memoria-mem_c,
                             disipador-dis_a, fuente-fuente_a], 415, 103]) :-
    configurar([pedido(nucleos, 6), pedido(memoria, 16), pedido(video, no)],
               C, P, W).

test(falta_memoria, C == [procesador-cpu_c, placa-placa_b, falta(memoria),
                          disipador-dis_a, fuente-fuente_a]) :-
    configurar([pedido(nucleos, 6), pedido(memoria, 64), pedido(video, no)],
               C, _, _).

test(ciclos, N == 21) :-
    memoria_del_pedido([pedido(nucleos, 8), pedido(memoria, 32),
                        pedido(video, si)], H),
    cantidad_de_ciclos(configurador, mea, H, N).

% Con las reglas invertidas, orden pasa de fase antes de buscar candidatos.
test(invertido_orden, C == [falta(procesador), falta(placa), falta(memoria),
                            falta(fuente)]) :-
    configuracion(configurador_invertido, orden,
                  [pedido(nucleos, 6), pedido(memoria, 16),
                   pedido(video, no)], C, configurada).

test(invertido_lex_mea, [L, M] == [C, C]) :-
    Pedido = [pedido(nucleos, 6), pedido(memoria, 16), pedido(video, no)],
    configuracion(configurador, mea, Pedido, C, configurada),
    configuracion(configurador_invertido, lex, Pedido, L, configurada),
    configuracion(configurador_invertido, mea, Pedido, M, configurada).

:- end_tests(configurador).
