:- encoding(utf8).

% Capítulo 77 - Versión 3: el agente basado en conocimiento.
%
% El agente solo conoce las celdas que visitó y lo que percibió en cada
% una. Un mundo es consistente con ese conocimiento si explica todas las
% percepciones: una celda visitada tiene brisa si y solo si alguna vecina
% tiene un pozo, y hedor si y solo si el wumpus está en una vecina. Una
% celda es segura si en ningún mundo consistente tiene un pozo ni el
% wumpus: es lo que se sigue del conocimiento, sin reglas escritas para
% cada caso. Los pozos y el wumpus se examinan por separado, porque la
% brisa depende solo de los pozos y el hedor solo del wumpus; y de los
% pozos alcanza con la frontera, las celdas sin visitar vecinas de una
% visitada, porque un pozo más lejos no cambia ninguna percepción.
%
% El agente sigue el orden del agente híbrido de Russell y Norvig: si
% percibe el brillo, toma el oro, vuelve a (1, 1) y sale; si no, va a la
% celda segura sin visitar más cercana; si no queda ninguna, vuelve y sale
% sin el oro. Los caminos los da el A* del capítulo 40, que solo sabe ir a
% (1, 1): para ir a otra celda, las coordenadas se trasladan de modo que
% la meta quede en (1, 1).
%
% El conocimiento es un término c(N, Celda, Visitadas, Oro, Flecha,
% Wumpus, Plan): el tamaño de la cueva, la celda del agente, la lista de
% pares Celda-Percepciones visitadas, si lleva el oro, si le queda la
% flecha, si el wumpus vive y las acciones que faltan del plan en curso.
%
% solo-local: es un módulo que carga otros.
%
%?- conocer(4, [1-1-[], 2-1-[brisa], 1-2-[hedor]], K), seguras(K, S).
%?- mundo(figura_7_2, M), jugar(M, Final).

:- module(agente,
          [ conocimiento_inicial/2,
            conocer/3,
            mundos_pozos/2,
            posiciones_wumpus/2,
            clasificar/3,
            seguras/2,
            frontera/2,
            ruta/4,
            volver/2,
            siguiente/3,
            decidir/4,
            registrar/3,
            de_la_celda/1,
            explorar/3,
            jugar/2
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(ordsets)).
:- reexport(grilla).
:- use_module(capitulo40).

% --- El conocimiento --------------------------------------------------------

%!  conocimiento_inicial(+N:integer, -K) is det.
%
%   K es el conocimiento del agente al entrar en una cueva de N x N: está
%   en (1, 1), no visitó nada, no tiene el oro, tiene la flecha y el wumpus
%   vive.
conocimiento_inicial(N, c(N, 1-1, [], no, si, vivo([]), [])).

%!  conocer(+N:integer, +Visitadas:list, -K) is det.
%
%   K es el conocimiento de un agente que visitó las celdas de Visitadas,
%   pares Celda-Percepciones, y está en la última.
conocer(N, Visitadas, c(N, C, Visitadas, no, si, vivo([]), [])) :-
    last(Visitadas, C-_).

%!  registrar(+Ps:list, +K0, -K) is det.
%
%   K agrega a K0 las percepciones Ps de la celda del agente: la celda
%   queda visitada con su hedor y su brisa. Después de un disparo, un grito
%   marca al wumpus como muerto, y el silencio descarta las celdas por
%   las que pasó la flecha.
registrar(Ps, c(N, C, Vs0, O, F, W0, Plan), c(N, C, Vs, O, F, W, Plan)) :-
    (   memberchk(C-_, Vs0)
    ->  Vs = Vs0
    ;   include(de_la_celda, Ps, Ps1),
        msort(Ps1, Propias),
        append(Vs0, [C-Propias], Vs)
    ),
    (   memberchk(grito, Ps)
    ->  W = muerto
    ;   W0 = apuntado(Descartadas0, Linea)
    ->  ord_union(Descartadas0, Linea, Descartadas),
        W = vivo(Descartadas)
    ;   W = W0
    ).

% de_la_celda(P): P es una percepción que depende solo de la celda: brisa
% o hedor.
de_la_celda(brisa).
de_la_celda(hedor).

% --- Los mundos consistentes ------------------------------------------------

%!  frontera(+K, -Frontera:list) is det.
%
%   Frontera son las celdas sin visitar vecinas de alguna visitada, en
%   orden.
frontera(c(N, _, Vs, _, _, _, _), Frontera) :-
    findall(F,
            ( member(C-_, Vs),
              vecina(N, C, F),
              \+ memberchk(F-_, Vs) ),
            Fs),
    sort(Fs, Frontera).

%!  mundos_pozos(+K, -Mundos:list) is det.
%
%   Mundos son los conjuntos de celdas de la frontera con pozos que
%   explican la brisa percibida en cada celda visitada, cada uno como una
%   lista ordenada.
mundos_pozos(K, Mundos) :-
    frontera(K, Frontera),
    K = c(N, _, Vs, _, _, _, _),
    findall(Pozos,
            ( subconjunto(Frontera, Pozos),
              explica(Vs, N, brisa, Pozos) ),
            Mundos).

%!  subconjunto(+Xs:list, -Ys:list) is multi.
%
%   Ys es un subconjunto de Xs, en el mismo orden.
subconjunto([], []).
subconjunto([X|Xs], [X|Ys]) :-
    subconjunto(Xs, Ys).
subconjunto([_|Xs], Ys) :-
    subconjunto(Xs, Ys).

%!  explica(+Visitadas:list, +N:integer, +P, +Celdas:list) is semidet.
%
%   Con peligros en las Celdas, cada celda visitada percibe P si y solo si
%   tiene una vecina entre ellas.
explica(Vs, N, P, Celdas) :-
    forall(member(C-Ps, Vs),
           (   memberchk(P, Ps)
           ->  once(( vecina(N, C, V), memberchk(V, Celdas) ))
           ;   \+ ( vecina(N, C, V), memberchk(V, Celdas) )
           )).

%!  posiciones_wumpus(+K, -Celdas:list) is det.
%
%   Celdas son las celdas sin visitar donde puede estar el wumpus vivo:
%   las que explican el hedor percibido en cada celda visitada, salvo las
%   que una flecha recorrió sin matarlo. Si el wumpus murió, la lista es
%   vacía.
posiciones_wumpus(c(_, _, _, _, _, muerto, _), []) :-
    !.
posiciones_wumpus(c(N, _, Vs, _, _, vivo(Descartadas), _), Celdas) :-
    findall(W,
            ( between(1, N, X),
              between(1, N, Y),
              W = X-Y,
              \+ memberchk(W-_, Vs),
              \+ memberchk(W, Descartadas),
              explica(Vs, N, hedor, [W]) ),
            Celdas).

%!  clasificar(+K, +C, -Clase) is det.
%
%   Clase es lo que el conocimiento K dice de la celda C: visitada, segura,
%   pozo o wumpus si está probado que lo tiene, o desconocida.
clasificar(K, C, Clase) :-
    mundos_pozos(K, Mundos),
    posiciones_wumpus(K, Ws),
    clasificar(K, Mundos, Ws, C, Clase).

%!  clasificar(+K, +Mundos:list, +Ws:list, +C, -Clase) is det.
%
%   clasificar/3 con los mundos de pozos y las posiciones del wumpus ya
%   calculados.
clasificar(K, Mundos, Ws, C, Clase) :-
    K = c(_, _, Vs, _, _, _, _),
    frontera(K, Frontera),
    (   memberchk(C-_, Vs)
    ->  Clase = visitada
    ;   Ws == [C]
    ->  Clase = wumpus
    ;   memberchk(C, Frontera),
        Mundos \== [],
        forall(member(Pozos, Mundos), memberchk(C, Pozos))
    ->  Clase = pozo
    ;   memberchk(C, Frontera),
        \+ ( member(Pozos, Mundos), memberchk(C, Pozos) ),
        \+ memberchk(C, Ws)
    ->  Clase = segura
    ;   Clase = desconocida
    ).

%!  seguras(+K, -Seguras:list) is det.
%
%   Seguras son las celdas sin visitar que el conocimiento K prueba
%   seguras, en orden.
seguras(K, Seguras) :-
    mundos_pozos(K, Mundos),
    posiciones_wumpus(K, Ws),
    frontera(K, Frontera),
    include(segura_en(K, Mundos, Ws), Frontera, Seguras).

%!  segura_en(+K, +Mundos:list, +Ws:list, +C) is semidet.
%
%   clasificar/5 prueba que C es segura.
segura_en(K, Mundos, Ws, C) :-
    clasificar(K, Mundos, Ws, C, segura).

% --- Los caminos ------------------------------------------------------------

%!  ruta(+Desde, +Hasta, +Permitidas:list, -Plan:list) is semidet.
%
%   Plan es el camino más corto de Desde a Hasta que pasa solo por celdas
%   de Permitidas, una lista de acciones ir(Celda), hallado con el A* del
%   capítulo 40. Ese A* va siempre a (1, 1): las celdas se trasladan para
%   que Hasta quede en (1, 1), y el plan se traslada de vuelta. Falla si no
%   hay camino.
ruta(Desde, Hasta, Permitidas, Plan) :-
    Hasta = HX-HY,
    DX is 1 - HX,
    DY is 1 - HY,
    maplist(trasladar(DX, DY), [Desde|Permitidas], [Desde1|Permitidas1]),
    vuelta(Desde1, Permitidas1, Plan1, _, _),
    NX is -DX,
    NY is -DY,
    maplist(trasladar_accion(NX, NY), Plan1, Plan).

%!  trasladar(+DX:integer, +DY:integer, +C0, -C) is det.
%
%   C es la celda C0 desplazada DX columnas y DY filas.
trasladar(DX, DY, X0-Y0, X-Y) :-
    X is X0 + DX,
    Y is Y0 + DY.

%!  trasladar_accion(+DX:integer, +DY:integer, +A0, -A) is det.
%
%   A es la acción ir(C0) con la celda desplazada.
trasladar_accion(DX, DY, ir(C0), ir(C)) :-
    trasladar(DX, DY, C0, C).

% --- Las decisiones ---------------------------------------------------------

%!  decidir(+Ps:list, +K0, -Accion, -K) is det.
%
%   El agente registra las percepciones Ps y elige la Accion: sigue el plan
%   en curso; si percibe el brillo, toma el oro y planea la vuelta; si no,
%   planea ir a la celda segura más cercana, o volver a (1, 1) y salir.
decidir(Ps, K0, Accion, K) :-
    registrar(Ps, K0, K1),
    planear(Ps, K1, K2),
    siguiente(K2, Accion, K).

%!  planear(+Ps:list, +K0, -K) is det.
%
%   K es K0 con un plan: el que tenía, si no está vacío; si no, el que
%   corresponde a la situación.
planear(Ps, K0, K) :-
    K0 = c(N, C, Vs, O, F, W, Plan0),
    (   Plan0 \== []
    ->  K = K0
    ;   memberchk(brillo, Ps),
        O == no
    ->  volver(K0, Vuelta),
        append([tomar|Vuelta], [salir], Plan),
        K = c(N, C, Vs, O, F, W, Plan)
    ;   explorar(K0, _, Plan)
    ->  K = c(N, C, Vs, O, F, W, Plan)
    ;   volver(K0, Vuelta),
        append(Vuelta, [salir], Plan),
        K = c(N, C, Vs, O, F, W, Plan)
    ).

%!  explorar(+K, -Destino, -Plan:list) is semidet.
%
%   Plan lleva al agente a Destino, la celda segura sin visitar a la que
%   llega con menos pasos; entre dos a la misma distancia, la primera en
%   orden. Falla si no hay ninguna.
explorar(K, Destino, Plan) :-
    seguras(K, Seguras),
    Seguras \== [],
    K = c(_, C, Vs, _, _, _, _),
    pairs_keys(Vs, Visitadas),
    append(Visitadas, Seguras, Permitidas),
    findall(L-(S-P),
            ( member(S, Seguras),
              ruta(C, S, Permitidas, P),
              length(P, L) ),
            Opciones),
    keysort(Opciones, [_-(Destino-Plan)|_]).

%!  volver(+K, -Plan:list) is det.
%
%   Plan lleva al agente a (1, 1) por celdas visitadas.
volver(c(_, C, Vs, _, _, _, _), Plan) :-
    pairs_keys(Vs, Visitadas),
    once(ruta(C, 1-1, Visitadas, Plan)).

%!  siguiente(+K0, -Accion, -K) is det.
%
%   Accion es la primera del plan de K0, y K el conocimiento después de
%   ella: la celda nueva, el oro tomado o la flecha disparada, con las
%   celdas que recorre a la espera del grito.
siguiente(c(N, C, Vs, O, F, W0, [Accion|Plan]), Accion,
          c(N, C1, Vs, O1, F1, W, Plan)) :-
    (   Accion = ir(C1)
    ->  O1 = O,
        F1 = F
    ;   Accion == tomar
    ->  C1 = C,
        O1 = si,
        F1 = F
    ;   Accion = disparar(_)
    ->  C1 = C,
        O1 = O,
        F1 = no
    ;   C1 = C,
        O1 = O,
        F1 = F
    ),
    (   Accion = disparar(Dir),
        W0 = vivo(Descartadas)
    ->  linea(N, C, Dir, Linea),
        W = apuntado(Descartadas, Linea)
    ;   W = W0
    ).

%!  jugar(+M, -Final) is det.
%
%   Final es el resultado de una partida del agente en el mundo M, con un
%   límite de 200 acciones.
jugar(M, Final) :-
    M = mundo(N, _, _, _),
    conocimiento_inicial(N, K0),
    simular(M, decidir, K0, 200, Final).
