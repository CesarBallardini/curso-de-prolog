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

% propagar/6 sobre una red de una regla: el segundo hecho completa la
% regla, y la salida del primero la quita y vacía la memoria del nodo 2.
test(propagar, [Is2, Is3, T3] == [[instanciacion(r, [1, 2], 2,
                                                 [agregar(s(a))])],
                                  [], []]) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> [agregar(s(X))]], Red),
    rete_vacio(Red, R0),
    propagar(mas, 1, p(a), Red, R0, R1),
    propagar(mas, 2, q(a), Red, R1, R2),
    conjunto_rete(R2, Is2),
    propagar(menos, 1, p(a), Red, R2, R3),
    conjunto_rete(R3, Is3),
    tokens(2, R3, T3).

% El padre del nodo 2 no tiene tokens: activar_derecha/6 no cambia nada.
test(activar_derecha_sin_padre) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> []], Red),
    rete_vacio(Red, R0),
    activar_derecha(mas, 1, Red, 2-alfa(q(a), []), R0, R),
    R == R0.

% derecha/8 une el hecho que entra con cada token del padre que unifica.
test(derecha, T == [[1, 2]-[alfa(p(a), []), alfa(q(a), [])]]) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> []], Red),
    Red = red(_, _, Nodos, _),
    get_assoc(2, Nodos, beta(Tipo, _, Prefijo, _, _)),
    rete_vacio(Red, R0),
    propagar(mas, 1, p(a), Red, R0, R1),
    propagar(mas, 3, p(b), Red, R1, R2),
    derecha(Tipo, mas, 2-alfa(q(a), []), 1-2, Prefijo, Red, R2, R),
    tokens(2, R, T).

% izquierda/8 con una prueba: el token pasa solo si la meta se cumple.
test(izquierda_prueba, [T1, T0] == [[[1]-[alfa(p(2), []), {2 > 1}]], []]) :-
    compilar_red(pasos, [r :: [p(X), {X > 1}] ---> []], Red),
    Red = red(_, _, Nodos, _),
    get_assoc(2, Nodos, beta(prueba, _, Prefijo, _, _)),
    rete_vacio(Red, R0),
    izquierda(prueba, mas, [1]-[alfa(p(2), [])], 2, Prefijo, Red, R0, R1),
    tokens(2, R1, T1),
    izquierda(prueba, mas, [1]-[alfa(p(0), [])], 2, Prefijo, Red, R0, R2),
    tokens(2, R2, T0).

% terminal/6 agrega la instanciación al conjunto, y con menos la quita.
test(terminal, [Is1, Is2] == [[instanciacion(r, [1, 2], 2,
                                             [agregar(s(a))])], []]) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> [agregar(s(X))]], Red),
    rete_vacio(Red, R0),
    Token = [1, 2]-[alfa(p(a), []), alfa(q(a), [])],
    terminal(mas, Token, Red, 1, R0, R1),
    conjunto_rete(R1, Is1),
    terminal(menos, Token, Red, 1, R1, R2),
    conjunto_rete(R2, Is2).

% retirar_rete/4 falla si el hecho no está en la memoria de trabajo.
test(retirar_ausente, fail) :-
    red_de(familia, Red),
    cargar(Red, [padre(juan, ana)], Memoria, Rete),
    retirar_rete(Red, padre(ana, sofia), Memoria-Rete, _).

test(retirar_rete, Is == []) :-
    red_de(familia, Red),
    cargar(Red, [padre(juan, ana)], Memoria, Rete0),
    retirar_rete(Red, padre(juan, ana), Memoria-Rete0, _-Rete),
    conjunto_rete(Rete, Is).

:- end_tests(tokens).
