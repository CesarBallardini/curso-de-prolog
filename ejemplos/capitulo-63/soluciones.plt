:- encoding(utf8).

:- begin_tests(soluciones).

test(ejercicio_1, [N, M] == [4, [sobre(a, b), sobre(b, piso)]]) :-
    H = [sobre(a, piso), sobre(b, a), meta(apilar([b, a]))],
    cantidad_de_ciclos(cajas, orden, H, N),
    encadenar(cajas, orden, H, M, nada_aplicable).

test(ejercicio_2, [M, R] == [[progenitor(juan, ana), madre(ana, sofia),
                              padre(juan, ana)], limite(50)]) :-
    encadenar_vigilado(familia, orden, no, 50,
                       [padre(juan, ana), madre(ana, sofia)], M, R).

test(ejercicio_2_con_refraccion, [N, R] == [34, nada_aplicable]) :-
    familia(H),
    encadenar_vigilado(familia, orden, si, 50, H, M, R),
    length(M, N).

test(ejercicio_3, [E1, E2] == [r2, r2]) :-
    L = [instanciacion(r1, [4, 9], 2, []),
         instanciacion(r2, [9, 2, 7], 3, []),
         instanciacion(r3, [9, 7], 3, [])],
    preferida(lex, L, instanciacion(E1, _, _, _)),
    preferida(mea, L, instanciacion(E2, _, _, _)).

test(ejercicio_4, N == 4) :-
    cantidad_de_ciclos(cajas, prioridad,
                       [sobre(a, piso), sobre(b, piso), sobre(c, a),
                        sobre(d, piso), meta(apilar([b, c])),
                        meta(apilar([a, d]))], N).

test(ejercicio_5, [O, L, M] == [5, 5, 5]) :-
    H = [sobre(a, piso), sobre(b, a), sobre(c, b), meta(apilar([c, b, a]))],
    cantidad_de_ciclos(cajas, orden, H, O),
    cantidad_de_ciclos(cajas, lex, H, L),
    cantidad_de_ciclos(cajas, mea, H, M).

test(ejercicio_6, [P, C] == [0, 8]) :-
    valor_ranura(fuente, [], precio, P),
    valor_ranura(memoria, [consumo-8], consumo, C).

test(ejercicio_6_disipador, [fail]) :-
    valor_ranura(disipador, [], necesita_disipador, _).

test(ejercicio_7, [C1, D1, C2, D2] == [65, si, 200, si]) :-
    valor_ranura(apu, [], consumo, C1),
    valor_ranura(apu, [], necesita_disipador, D1),
    valor_ranura(apu_invertida, [], consumo, C2),
    valor_ranura(apu_invertida, [], necesita_disipador, D2).

test(ejercicio_8_mea, [F, W] == [fuente-fuente_a, 0]) :-
    configurar_sumando(mea, C, W, configurada),
    last(C, F).

test(ejercicio_8_orden, R == limite(200)) :-
    configurar_sumando(orden, _, _, R).

test(ejercicio_9, C == [procesador-cpu_c, placa-placa_c, memoria-mem_c,
                        disipador-dis_a, fuente-fuente_a, gabinete-gab_a]) :-
    configurar_gabinete([pedido(nucleos, 6), pedido(memoria, 16),
                         pedido(video, no)], C).

test(ejercicio_9_atx, G == gabinete-gab_b) :-
    configurar_gabinete([pedido(nucleos, 8), pedido(memoria, 32),
                         pedido(video, si)], C),
    last(C, G).

test(ejercicio_10, [P1, P2] == [1125, 415]) :-
    mas_barata([pedido(nucleos, 8), pedido(memoria, 32), pedido(video, si)],
               _, P1),
    mas_barata([pedido(nucleos, 6), pedido(memoria, 16), pedido(video, no)],
               _, P2).

test(ejercicio_10_imposible, [fail]) :-
    mas_barata([pedido(nucleos, 6), pedido(memoria, 64), pedido(video, no)],
               _, _).

test(ejercicio_10_difieren, [PO, PE] == [480, 490]) :-
    comparar_disipador_caro(_, PO, _, PE).

test(ejercicio_11, Is == [651, 2640, 10632]) :-
    findall(I, ( member(K, [1, 2, 4]),
                 familias(K, H),
                 medir(familia, orden, H, _, I, _, _) ),
            Is).

test(ejercicio_12, [nondet], A == por(antepasado(juan, sofia), antepasado_2,
                     [por(progenitor(juan, ana), progenitor_p,
                          [inicial(padre(juan, ana))]),
                      por(antepasado(ana, sofia), antepasado_1,
                          [por(progenitor(ana, sofia), progenitor_m,
                               [inicial(madre(ana, sofia))])])])) :-
    explicar(antepasado(juan, sofia), A).

:- end_tests(soluciones).
