:- encoding(utf8).

% Capítulo 77 - Versión 4: la flecha y el riesgo.
%
% Cuando ninguna celda es segura, el agente de la versión 3 vuelve sin el
% oro. Este agente tiene dos recursos más, en el orden del agente híbrido
% de Russell y Norvig. Primero, la flecha: si el wumpus puede estar en
% alguna celda, dispara desde una celda visitada en la dirección que
% cubre más posiciones posibles; el grito dice que murió, y el silencio
% descarta las celdas por las que pasó la flecha. Segundo, el riesgo: los
% mismos mundos consistentes de la versión 3, cada uno con su
% probabilidad, dan la probabilidad de que una celda tenga un pozo o el
% wumpus, y el agente entra en la celda menos riesgosa si el riesgo es
% menor que un umbral.
%
% Cada celda, salvo (1, 1), tiene un pozo con probabilidad 1/5, sin
% depender de las demás: un mundo con k pozos en una frontera de n celdas
% pesa (1/5)^k (4/5)^(n-k). El wumpus está con la misma probabilidad en
% cualquiera de sus posiciones posibles. Es el cálculo de la sección «The
% Wumpus World Revisited» de Russell y Norvig.
%
% solo-local: es un módulo que carga otros.
%
%?- conocer(4, [1-1-[], 1-2-[brisa], 2-1-[brisa]], K), riesgo(K, 2-2, R).
%?- mundo_sembrado(2, M), jugar_con_riesgo(M, 0.5, Final).

:- module(riesgo,
          [ probabilidad_pozo/3,
            probabilidad_wumpus/3,
            riesgo/3,
            disparo/3,
            decidir_con_riesgo/5,
            jugar_con_riesgo/3,
            medir/3
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(aggregate)).
:- reexport(agente).

% --- Las probabilidades -----------------------------------------------------

%!  probabilidad_pozo(+K, +C, -P:float) is det.
%
%   P es la probabilidad de que la celda C tenga un pozo, según el
%   conocimiento K: 0 si está visitada; en la frontera, la suma de los
%   pesos de los mundos consistentes con un pozo en C sobre la suma de
%   todos; fuera de la frontera, 1/5.
probabilidad_pozo(K, C, P) :-
    K = c(_, _, Vs, _, _, _, _),
    frontera(K, Frontera),
    (   memberchk(C-_, Vs)
    ->  P = 0.0
    ;   memberchk(C, Frontera)
    ->  mundos_pozos(K, Mundos),
        length(Frontera, N),
        maplist(peso(N), Mundos, Pesos),
        sum_list(Pesos, Total),
        pares_con(Mundos, Pesos, C, ConC),
        sum_list(ConC, Parcial),
        P is Parcial / Total
    ;   P = 0.2
    ).

%!  peso(+N:integer, +Pozos:list, -W:float) is det.
%
%   W es la probabilidad de que una frontera de N celdas tenga pozos
%   exactamente en las celdas de Pozos.
peso(N, Pozos, W) :-
    length(Pozos, K),
    W is 0.2 ** K * 0.8 ** (N - K).

%!  pares_con(+Mundos:list, +Pesos:list, +C, -ConC:list) is det.
%
%   ConC son los pesos de los mundos de Mundos que tienen un pozo en C.
pares_con([], [], _, []).
pares_con([Pozos|Mundos], [W|Pesos], C, ConC) :-
    (   memberchk(C, Pozos)
    ->  ConC = [W|ConC1]
    ;   ConC = ConC1
    ),
    pares_con(Mundos, Pesos, C, ConC1).

%!  probabilidad_wumpus(+K, +C, -P:float) is det.
%
%   P es la probabilidad de que el wumpus vivo esté en la celda C: la misma
%   para cada una de sus posiciones posibles, y 0 para las demás.
probabilidad_wumpus(K, C, P) :-
    posiciones_wumpus(K, Ws),
    (   memberchk(C, Ws)
    ->  length(Ws, N),
        P is 1 / N
    ;   P = 0.0
    ).

%!  riesgo(+K, +C, -R:float) is det.
%
%   R es la probabilidad de morir al entrar en C: que tenga un pozo o el
%   wumpus. Las dos se toman como independientes.
riesgo(K, C, R) :-
    probabilidad_pozo(K, C, PP),
    probabilidad_wumpus(K, C, PW),
    R is 1 - (1 - PP) * (1 - PW).

% --- La flecha --------------------------------------------------------------

%!  disparo(+K, -Desde, -Dir) is semidet.
%
%   Desde una celda visitada Desde, la flecha que sale hacia Dir pasa por
%   la mayor cantidad de posiciones posibles del wumpus; entre dos con la
%   misma cantidad, la de la celda visitada antes. Falla si ya no hay
%   flecha, si el wumpus murió o si ninguna dirección pasa por una
%   posición posible.
disparo(K, Desde, Dir) :-
    K = c(N, _, Vs, _, si, vivo(_), _),
    posiciones_wumpus(K, Ws),
    findall(Menos-(C-D),
            ( member(C-_, Vs),
              member(D, [este, oeste, norte, sur]),
              linea(N, C, D, Linea),
              aggregate_all(count, ( member(W, Ws), memberchk(W, Linea) ),
                            Cubre),
              Cubre > 0,
              Menos is -Cubre ),
            Opciones),
    keysort(Opciones, [_-(Desde-Dir)|_]).

% --- Las decisiones ---------------------------------------------------------

%!  decidir_con_riesgo(+Umbral:number, +Ps:list, +K0, -Accion, -K) is det.
%
%   Como decidir/4 de la versión 3, pero, si no queda ninguna celda segura,
%   dispara la flecha si puede alcanzar al wumpus, y si no entra en la celda
%   menos riesgosa de la frontera cuando su riesgo es menor que Umbral.
decidir_con_riesgo(Umbral, Ps, K0, Accion, K) :-
    registrar(Ps, K0, K1),
    planear(Umbral, Ps, K1, K2),
    siguiente(K2, Accion, K).

%!  planear(+Umbral:number, +Ps:list, +K0, -K) is det.
%
%   K es K0 con un plan, elegido en el orden del agente híbrido.
planear(Umbral, Ps, K0, K) :-
    K0 = c(N, C, Vs, O, F, W, Plan0),
    (   Plan0 \== []
    ->  Plan = Plan0
    ;   memberchk(brillo, Ps),
        O == no
    ->  volver(K0, Vuelta),
        append([tomar|Vuelta], [salir], Plan)
    ;   explorar(K0, _, Plan)
    ->  true
    ;   disparo(K0, Desde, Dir)
    ->  pairs_keys(Vs, Visitadas),
        once(ruta(C, Desde, Visitadas, Ida)),
        append(Ida, [disparar(Dir)], Plan)
    ;   arriesgar(K0, Umbral, Plan)
    ->  true
    ;   volver(K0, Vuelta),
        append(Vuelta, [salir], Plan)
    ),
    K = c(N, C, Vs, O, F, W, Plan).

%!  arriesgar(+K, +Umbral:number, -Plan:list) is semidet.
%
%   Plan lleva al agente a la celda de la frontera con menos riesgo, si ese
%   riesgo es menor que Umbral. Falla si no la hay.
arriesgar(K, Umbral, Plan) :-
    frontera(K, Frontera),
    findall(R-C, ( member(C, Frontera), riesgo(K, C, R) ), Riesgos),
    keysort(Riesgos, [R-Destino|_]),
    R < Umbral,
    K = c(_, C0, Vs, _, _, _, _),
    pairs_keys(Vs, Visitadas),
    once(ruta(C0, Destino, [Destino|Visitadas], Plan)).

%!  jugar_con_riesgo(+M, +Umbral:number, -Final) is det.
%
%   Final es el resultado de una partida del agente con riesgo en el mundo
%   M, con un límite de 200 acciones.
jugar_con_riesgo(M, Umbral, Final) :-
    M = mundo(N, _, _, _),
    conocimiento_inicial(N, K0),
    simular(M, decidir_con_riesgo(Umbral), K0, 200, Final).

% --- La medición ------------------------------------------------------------

%!  medir(+Agente, +Semillas:list, -Resumen) is det.
%
%   Resumen es r(Oro, Muertes, SinOro, Puntaje) para las partidas de Agente
%   en los mundos sembrados con Semillas: cuántas salieron con el oro,
%   cuántas terminaron con el agente muerto, cuántas salieron sin el oro, y
%   el puntaje medio. Agente es prudente, el de la versión 3, o
%   riesgo(Umbral).
medir(Agente, Semillas, r(Oro, Muertes, SinOro, Media)) :-
    findall(Fin-P,
            ( member(S, Semillas),
              mundo_sembrado(S, M),
              partida_de(Agente, M, final(Fin, P, _)) ),
            Finales),
    aggregate_all(count, member(salio(si)-_, Finales), Oro),
    aggregate_all(count, member(murio(_)-_, Finales), Muertes),
    aggregate_all(count, member(salio(no)-_, Finales), SinOro),
    pairs_values(Finales, Puntajes),
    sum_list(Puntajes, Suma),
    length(Puntajes, L),
    Media is round(Suma / L).

%!  partida_de(+Agente, +M, -Final) is det.
%
%   Final es el resultado de la partida de Agente en el mundo M.
partida_de(prudente, M, Final) :-
    jugar(M, Final).
partida_de(riesgo(Umbral), M, Final) :-
    jugar_con_riesgo(M, Umbral, Final).
