:- encoding(utf8).

:- begin_tests(negacion).

% El token de meta(despejar(a)) está bloqueado por sobre(b, a).
test(cuenta, C == [[1]-1]) :-
    cuentas(cajas, [meta(despejar(a)), sobre(b, a)], 11, C).

test(dos_cuentas, C == [[1]-2, [2]-0]) :-
    cuentas(cajas, [meta(despejar(a)), meta(despejar(b)), sobre(b, a),
                    sobre(c, a)], 11, C).

test(despejada, Is == [instanciacion(despejada, [1], 2,
                                     [quitar(meta(despejar(a)))])]) :-
    reconocer_rete(cajas, [meta(despejar(a)), sobre(a, piso)], Is).

% Quitar un hecho agrega una instanciación: sin sobre(b, a), la caja a
% queda despejada.
test(quitar_agrega, Is == [instanciacion(despejada, [1], 2,
                                         [quitar(meta(despejar(a)))])]) :-
    cambios_rete(cajas, [meta(despejar(a)), sobre(b, a)],
                 [menos(sobre(b, a))], Is).

test(cajas) :-
    mismo_conjunto(cajas, [meta(apilar([a, b, c])), sobre(a, piso),
                           sobre(b, piso), sobre(c, a)],
                   [menos(sobre(c, a)), mas(sobre(c, piso)),
                    mas(meta(despejar(c))), menos(sobre(b, piso)),
                    mas(sobre(b, a))]).

test(configurador) :-
    pedido_ampliado(0, H),
    mismo_conjunto(configurador, H, []).

test(reingreso) :-
    mismo_conjunto(reingreso, [], [mas(aviso), mas(ocupado),
                                   menos(ocupado)]).

% paso_cuenta/6: de cero a uno el token deja de pasar; de uno a cero
% vuelve a pasar; entre otros valores no hay cambio.
test(paso_cuenta, [N1, C1, N2, C2, N3, C3] ==
                  [1, [menos-t], 0, [mas-t], 2, []]) :-
    paso_cuenta(mas, 0, N1, t, [], C1),
    paso_cuenta(menos, 1, N2, t, [], C2),
    paso_cuenta(mas, 1, N3, t, [], C3).

% recontar/7 cambia la cuenta solo si el hecho bloquea el token.
test(recontar, [C1, Cs1, C2, Cs2] ==
               [[1]-([alfa(p(a), [])]-1), [menos-([1]-[alfa(p(a), [])])],
                [1]-([alfa(p(a), [])]-0), []]) :-
    Prefijo = [alfa(p(X), []), no(q(X))],
    I = [alfa(p(a), [])],
    recontar(mas, Prefijo, q(a), [1]-(I-0), C1, [], Cs1),
    recontar(mas, Prefijo, q(b), [1]-(I-0), C2, [], Cs2).

% llega_a_negacion/8: un token sin hechos que lo bloqueen se guarda con
% cuenta cero y pasa; cuando se va, sale de la salida y de las cuentas.
test(llega_a_negacion, [K1, T1, K2, T2] == [[[1]-([alfa(p(a), [])]-0)],
                                            [[1]-[alfa(p(a), []), no(q(a))]],
                                            [], []]) :-
    compilar_red(pasos, [r :: [p(X), no(q(X))] ---> []], Red),
    Red = red(_, _, Nodos, _),
    get_assoc(2, Nodos, beta(negacion(A), _, Prefijo, _, _)),
    rete_vacio(Red, R0),
    Token = [1]-[alfa(p(a), [])],
    llega_a_negacion(mas, A, Token, 2, Prefijo, Red, R0, R1),
    tokens(cuentas(2), R1, K1),
    tokens(2, R1, T1),
    llega_a_negacion(menos, A, Token, 2, Prefijo, Red, R1, R2),
    tokens(cuentas(2), R2, K2),
    tokens(2, R2, T2).

:- end_tests(negacion).
