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

% un_ciclo/9 con la memoria vacía: no hay instanciaciones nuevas.
test(un_ciclo_vacio, [Fin, D] == [nada_aplicable, []]) :-
    red_de(familia, Red),
    cargar(Red, [], M, R),
    un_ciclo(Red, orden, sin_traza, 1, [], D, M-R, _, Fin).

% Un ciclo de familia dispara progenitor_p y registra sus sellos; hechos/2
% da la memoria del hecho más reciente al más antiguo.
test(un_ciclo, [Fin, D, H] == [seguir, [progenitor_p-[1]],
                               [progenitor(juan, ana), padre(juan, ana)]]) :-
    red_de(familia, Red),
    cargar(Red, [padre(juan, ana)], M, R),
    un_ciclo(Red, orden, sin_traza, 1, [], D, M-R, M1-_, Fin),
    hechos(M1, H).

% ciclo_rete/9 cuenta los ciclos que disparan una regla.
test(ciclo_rete, [N, Resultado] == [2, nada_aplicable]) :-
    red_de(familia, Red),
    cargar(Red, [padre(juan, ana)], M, R),
    ciclo_rete(Red, orden, sin_traza, 0, N, [], M-R, _, Resultado).

% acciones_rete/5 se detiene en parar/1 sin ejecutar lo que sigue.
test(acciones_parar, [Fin, H] == [parar(listo), [p]]) :-
    red_de(familia, Red),
    cargar(Red, [], M0, R0),
    acciones_rete([agregar(p), parar(listo), agregar(q)], Red, M0-R0,
                  M-_, Fin),
    hechos(M, H).

test(acciones_quitar_ausente, fail) :-
    red_de(familia, Red),
    cargar(Red, [], M0, R0),
    acciones_rete([quitar(p)], Red, M0-R0, _, _).

% quitar_elegida/4 saca la instanciación del conjunto de conflicto.
test(quitar_elegida, [Antes, Despues] == [1, []]) :-
    red_de(familia, Red),
    cargar(Red, [padre(juan, ana)], _, R0),
    conjunto_rete(R0, Is0),
    length(Is0, Antes),
    Is0 = [I],
    quitar_elegida(Red, I, R0, R),
    conjunto_rete(R, Despues).

:- end_tests(rete).
