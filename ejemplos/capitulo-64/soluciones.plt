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

% cargar_con/5 con el orden de propagar/6 reúne el mismo conjunto que
% reconocer_rete/3.
test(cargar_con) :-
    red_de(pares, Red),
    cargar_con(@>=, activar_derecha(mas), Red, [p(1), p(2)], Rete),
    conjunto_rete(Rete, Is),
    reconocer_rete(pares, [p(1), p(2)], Is1),
    Is =@= Is1.

% entrar_con/6 da al hecho el sello S0 y devuelve el siguiente.
test(entrar_con, [S, Is] == [2, [instanciacion(par, [1, 1], 2,
                                               [agregar(par(1, 1))])]]) :-
    red_de(pares, Red),
    rete_vacio(Red, R0),
    entrar_con(@>=, activar_derecha(mas), Red, p(1), R0-1, R-S),
    conjunto_rete(R, Is).

% siempre_derecha/5 activa el nodo aunque el padre no tenga tokens; sin
% tokens en el padre, no produce ninguno.
test(siempre_derecha, T == []) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> []], Red),
    rete_vacio(Red, R0),
    siempre_derecha(1, Red, 2-alfa(q(a), []), R0, R),
    tokens(2, R, T).

% sin_registro/7 se detiene en el límite.
test(sin_registro_limite, R == limite(3)) :-
    red_de(reingreso, Red),
    cargar(Red, [], Mt, Rete),
    sin_registro(Red, orden, 3, 0, Mt-Rete, _, R).

% con_cambios/6 escribe una línea por ciclo hasta nada_aplicable.
test(con_cambios, [R, N] == [nada_aplicable, 2]) :-
    red_de(familia, Red),
    cargar(Red, [padre(juan, ana)], Mt, Rete),
    with_output_to(string(S),
                   con_cambios(Red, orden, 1, [], Mt-Rete, R)),
    aggregate_all(count, sub_string(S, _, _, _, "entran"), N).

% forzar/2 lleva cada prueba al patrón anterior, aunque mire otro hecho.
test(forzar, Ps == [alfa(p(X), []), alfa(q(Y), [X < Y])]) :-
    forzar([p(X), q(Y), {X < Y}], Ps).

% pasos_forzados/2 separa antes la conjunción.
test(pasos_forzados, Ps == [alfa(q(X, Y), [Y > 2, X \== Y]), no(r(X))]) :-
    pasos_forzados([q(X, Y), {Y > 2, X \== Y}, no(r(X))], Ps).

:- end_tests(soluciones).
