:- encoding(utf8).

:- begin_tests(tokens).

test(reconocer, Is == [instanciacion(progenitor_p, [2], 1,
                                     [agregar(progenitor(ana, sofia))]),
                       instanciacion(progenitor_p, [1], 1,
                                     [agregar(progenitor(juan, ana))])]) :-
    reconocer_rete(familia, [padre(juan, ana), padre(ana, sofia)], Is).

% Un hecho que sale quita las instanciaciones que lo usaban.
test(quitar, Is == []) :-
    cambios_rete(familia, [padre(juan, ana)], [menos(padre(juan, ana))],
                 Is).

test(familia) :-
    familia(H),
    mismo_conjunto(familia, H, []).

% hermanos une dos veces el mismo nodo alfa: cada hecho de progenitor/2
% entra por los dos lados de la unión sin duplicar ningún token.
test(cambios) :-
    familia(H),
    mismo_conjunto(familia, H,
                   [mas(progenitor(juan, ana)), mas(progenitor(juan, pedro)),
                    mas(progenitor(pedro, luis)), menos(padre(juan, ana)),
                    mas(antepasado(juan, luis)),
                    menos(progenitor(juan, pedro))]).

test(mcd) :-
    mismo_conjunto(mcd, [numero(9), numero(6), numero(3)],
                   [menos(numero(9)), mas(numero(3))]).

test(disipadores) :-
    pedido_ampliado(0, H),
    mismo_conjunto(disipadores, H, []).

% Esta versión no conoce la negación: la meta llega al nodo de no/1, y
% izquierda/8 no tiene cláusula para él.
test(sin_negacion, fail) :-
    reconocer_rete(cajas, [meta(despejar(a)), sobre(a, piso)], _).

test(ordenar) :-
    posiciones([3, 1, 2], H),
    mismo_conjunto(ordenar, H, [menos(pos(1, 3)), mas(pos(1, 1))]).

:- end_tests(tokens).
