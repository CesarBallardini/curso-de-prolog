:- encoding(utf8).

:- begin_tests(soluciones).

test(tienda, [A, B] == [2, 4]) :-
    programa(tienda, Reglas),
    compilar_red(pasos, Reglas, Red),
    medidas_red(Red, A, B, _).

test(variantes, [A, B, C] == [1, 6, 10]) :-
    tamano_red(hermanos_variantes, A, B, C).

test(ascendente, [S1, S2] == [[1], [3]]) :-
    H = [padre(juan, ana), madre(ana, sofia), padre(juan, pedro)],
    primera_ascendente(familia, H, instanciacion(_, S1, _, _)),
    primera_descendente(familia, H, instanciacion(_, S2, _, _)).

test(invertido, S == [[2, 2], [2, 2], [2, 1], [1, 2], [1, 1], [1, 1]]) :-
    conjunto_invertido(pares, [p(1), p(2)], S).

test(normal, S == [[2, 2], [2, 1], [1, 2], [1, 1]]) :-
    reconocer_rete(pares, [p(1), p(2)], Is),
    findall(X, member(instanciacion(_, X, _, _), Is), S).

test(cuentas, C == [[1]-1, [2]-1]) :-
    cuentas(cajas, [meta(despejar(a)), meta(despejar(b)), sobre(b, a),
                    sobre(c, b)], 11, C).

test(cambio_cuentas, L == [despejar_encima-[2, 4], despejada-[1]]) :-
    cambios_rete(cajas, [meta(despejar(a)), meta(despejar(b)), sobre(b, a),
                         sobre(c, b)], [menos(sobre(b, a))], Is),
    findall(N-X, member(instanciacion(N, X, _, _), Is), L).

test(sin_registro, [M, R] == [[ocupado, aviso], limite(20)]) :-
    ciclo_sin_registro(reingreso, orden, 20, [], M, R).

test(sin_registro_familia) :-
    familia(H),
    ciclo_sin_registro(familia, orden, 100, H, M, R),
    encadenar(familia, orden, H, M1, R1),
    M-R == M1-R1.

test(sin_registro_configurador) :-
    memoria_del_pedido([pedido(nucleos, 8), pedido(memoria, 32),
                        pedido(video, si)], H),
    ciclo_sin_registro(configurador, mea, 100, H, M, R),
    encadenar(configurador, mea, H, M1, R1),
    M-R == M1-R1.

test(carga, Mayor == true) :-
    carga_normal(400, A),
    carga_siempre(400, B),
    (   B > A
    ->  Mayor = true
    ;   Mayor = false
    ).

test(cambios, R == nada_aplicable) :-
    with_output_to(string(S),
                   rastrear_cambios(cajas, orden,
                                    [meta(apilar([a, b])), sobre(a, piso),
                                     sobre(b, piso), sobre(c, a)], R)),
    once(sub_string(S, _, _, _,
                    "entran [apilar-[1,3]], salen [despejada-[5]]")).

test(tokens, [T, A] == [270, 210]) :-
    tokens_al_final(20, T, A).

test(forzado, E = error(instantiation_error, _)) :-
    configurar_forzado([pedido(nucleos, 8), pedido(memoria, 32),
                        pedido(video, si)], error(E)).

test(ganar, [C0, C8] == [nunca, 49]) :-
    ciclos_para_ganar(0, C0),
    ciclos_para_ganar(800, C8).

:- end_tests(soluciones).
