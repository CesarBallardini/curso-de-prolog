:- encoding(utf8).

:- begin_tests(rete).

test(familia, forall(member(E, [orden, lex, mea]))) :-
    familia(H),
    iguales(familia, E, H).

test(configurador, forall(( member(P, [configurador,
                                       configurador_invertido]),
                            member(E, [orden, lex, mea]),
                            member(Pedido,
                                   [[pedido(nucleos, 8), pedido(memoria, 32),
                                     pedido(video, si)],
                                    [pedido(nucleos, 6), pedido(memoria, 16),
                                     pedido(video, no)],
                                    [pedido(nucleos, 6), pedido(memoria, 64),
                                     pedido(video, no)]]) ))) :-
    memoria_del_pedido(Pedido, H),
    iguales(P, E, H).

test(cajas, forall(( member(E, [orden, lex, mea]),
                     member(H, [[meta(apilar([a, b, c])), sobre(a, piso),
                                 sobre(b, piso), sobre(c, a)],
                                [meta(apilar([b, c])), meta(apilar([a, d])),
                                 sobre(a, piso), sobre(b, piso),
                                 sobre(c, a), sobre(d, piso)]]) ))) :-
    iguales(cajas, E, H).

test(mcd) :-
    iguales(mcd, orden, [numero(60), numero(84), numero(36)]).

test(ordenar) :-
    posiciones([3, 1, 4, 2], H),
    iguales(ordenar, orden, H).

% La negación devuelve avisar y ocupar al conjunto con los mismos sellos;
% la refracción las descarta, como en el capítulo 63.
test(reingreso, [M, R] == [[aviso], nada_aplicable]) :-
    iguales(reingreso, orden, []),
    encadenar_rete(reingreso, orden, [], M, R).

test(configurar, [C, P, W] == [[procesador-cpu_b, placa-placa_a,
                                memoria-mem_b, disipador-dis_a,
                                placa_de_video-gpu_a, fuente-fuente_b],
                               1125, 378]) :-
    configurar_rete([pedido(nucleos, 8), pedido(memoria, 32),
                     pedido(video, si)], C, P, W).

:- end_tests(rete).
