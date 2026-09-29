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

:- end_tests(negacion).
