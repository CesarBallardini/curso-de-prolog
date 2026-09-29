:- encoding(utf8).

% Capítulo 77 - Versión 5: un agente que juega «Hunt the Wumpus».
%
% El agente juega la cueva de la versión 1 con las mismas órdenes que un
% jugador, y solo ve lo que el juego le muestra: la sala, sus túneles, los
% avisos y los mensajes de cada jugada. Razona como el de la versión 3,
% con mundos consistentes, pero la cueva es otra: los peligros están en
% salas unidas por túneles, y su cantidad se conoce, dos pozos, dos salas
% con murciélagos y un wumpus. Un mundo de pozos es un par de salas sin
% visitar que explica cada corriente de aire percibida, y lo mismo los
% murciélagos y el wumpus. Como la cantidad es fija, todos los mundos
% consistentes son igual de probables.
%
% El wumpus se mueve cuando despierta. Lo que se percibió de él antes de
% que despertara ya no vale: el agente lo olvida y empieza a reunir avisos
% otra vez. Dispara cuando el wumpus solo puede estar en una sala, por el
% camino más corto; si no, va a la sala segura sin visitar más cercana, y
% si no hay ninguna, a la sala sin visitar con menos riesgo.
%
% solo-local: es un módulo que carga otros.
%
%?- cazar(7, Resultado, Ordenes).
%?- narrar(7).

:- module(cazador,
          [ cazar/3,
            narrar/1,
            mundos/4,
            medir_caza/2
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(aggregate)).
:- use_module(library(ordsets)).
:- use_module(cueva).

% El conocimiento es k(Sala, Visitadas, Recientes, Murcielagos, Flechas):
% la sala del agente; los pares Sala-Avisos de todas las salas donde
% observó; los de las salas donde observó desde que el wumpus despertó por
% última vez; las salas donde lo alzaron los murciélagos, y las flechas.

% --- Los mundos consistentes ------------------------------------------------

%!  mundos(+K, +Peligro, +Cantidad:integer, -Mundos:list) is det.
%
%   Mundos son los conjuntos de Cantidad salas donde puede estar Peligro
%   (corriente, murcielagos o wumpus) según el conocimiento K: salas
%   candidatas que explican el aviso de Peligro en cada sala observada.
mundos(K, Peligro, Cantidad, Mundos) :-
    observadas(K, Peligro, Obs),
    candidatas(K, Peligro, Obs, Candidatas, Fijas),
    length(Fijas, NF),
    Resto is Cantidad - NF,
    findall(Mundo,
            ( combinacion(Resto, Candidatas, Otras),
              ord_union(Fijas, Otras, Mundo),
              explican(Obs, Peligro, Mundo) ),
            Mundos).

%!  observadas(+K, +Peligro, -Obs:list) is det.
%
%   Obs son las observaciones que valen para Peligro: todas, salvo para el
%   wumpus, que usa solo las posteriores a su último despertar.
observadas(k(_, Visitadas, Recientes, _, _), Peligro, Obs) :-
    (   Peligro == wumpus
    ->  Obs = Recientes
    ;   Obs = Visitadas
    ).

%!  candidatas(+K, +Peligro, +Obs:list, -Candidatas:list, -Fijas:list)
%!      is det.
%
%   Candidatas son las salas donde Peligro puede estar y no se sabe;
%   Fijas, las salas donde se sabe que está: para los murciélagos, las
%   salas donde alzaron al agente. Ninguna es una sala observada.
candidatas(k(_, _, _, Murcielagos, _), Peligro, Obs, Candidatas, Fijas) :-
    pairs_keys(Obs, Vistas),
    (   Peligro == murcielagos
    ->  sort(Murcielagos, Fijas)
    ;   Fijas = []
    ),
    findall(S,
            ( sala(S),
              \+ memberchk(S, Vistas),
              \+ memberchk(S, Murcielagos) ),
            Candidatas).

%!  combinacion(+N:integer, +Xs:list, -Ys:list) is nondet.
%
%   Ys son N elementos de Xs, en el mismo orden.
combinacion(0, _, []) :-
    !.
combinacion(N, [X|Xs], [X|Ys]) :-
    N1 is N - 1,
    combinacion(N1, Xs, Ys).
combinacion(N, [_|Xs], Ys) :-
    N > 0,
    combinacion(N, Xs, Ys).

%!  explican(+Obs:list, +Peligro, +Mundo:list) is semidet.
%
%   Con Peligro en las salas de Mundo, cada sala observada tiene el aviso
%   de Peligro si y solo si una vecina está en Mundo.
explican(Obs, Peligro, Mundo) :-
    forall(member(S-Avisos, Obs),
           (   memberchk(Peligro, Avisos)
           ->  once(( tunel(S, V), memberchk(V, Mundo) ))
           ;   \+ ( tunel(S, V), memberchk(V, Mundo) )
           )).

%!  probabilidad(+Mundos:list, +S, -P:float) is det.
%
%   P es la fracción de los Mundos que ponen el peligro en la sala S.
probabilidad(Mundos, S, P) :-
    length(Mundos, N),
    aggregate_all(count, ( member(M, Mundos), memberchk(S, M) ), C),
    (   N =:= 0
    ->  P = 0.0
    ;   P is C / N
    ).

% --- Las decisiones ---------------------------------------------------------

%!  decidir(+K, -Orden) is det.
%
%   Orden es la jugada del agente con el conocimiento K: disparar si el
%   wumpus solo puede estar en una sala; si no, moverse hacia la sala
%   segura sin visitar más cercana, o hacia la sala sin visitar con menos
%   riesgo. El camino pasa solo por salas visitadas donde el wumpus no
%   puede estar.
decidir(K, Orden) :-
    K = k(Sala, Visitadas, _, _, Flechas),
    mundos(K, corriente, 2, Pozos),
    mundos(K, murcielagos, 2, Murcielagos),
    mundos(K, wumpus, 1, Wumpus),
    append(Wumpus, Ws0),
    sort(Ws0, Ws),
    pairs_keys(Visitadas, Vistas),
    subtract(Vistas, Ws, Transitables),
    findall(S,
            ( member(V, [Sala|Transitables]),
              tunel(V, S),
              \+ memberchk(S, Vistas) ),
            Frontera0),
    sort(Frontera0, Frontera),
    (   Flechas > 0,
        Ws = [Blanco]
    ->  once(camino(Sala, Blanco, _, Ruta)),
        Orden = disparar(Ruta)
    ;   include(segura(Pozos, Murcielagos, Ws), Frontera, Seguras),
        mas_cercana(Sala, Seguras, Transitables, Paso)
    ->  Orden = mover(Paso)
    ;   findall(R-S,
                ( member(S, Frontera),
                  riesgo(S, Pozos, Murcielagos, Wumpus, R) ),
                Riesgos),
        keysort(Riesgos, [_-Destino|_]),
        mas_cercana(Sala, [Destino], Transitables, Paso)
    ->  Orden = mover(Paso)
    ;   tunel(Sala, Paso)
    ->  Orden = mover(Paso)
    ).

%!  segura(+Pozos:list, +Murcielagos:list, +Ws:list, +S) is semidet.
%
%   Ningún mundo consistente pone en S un pozo, murciélagos ni el wumpus.
segura(Pozos, Murcielagos, Ws, S) :-
    \+ memberchk(S, Ws),
    \+ ( member(M, Pozos), memberchk(S, M) ),
    \+ ( member(M, Murcielagos), memberchk(S, M) ).

%!  riesgo(+S, +Pozos:list, +Murcielagos:list, +Wumpus:list, -R:float)
%!      is det.
%
%   R es el riesgo de entrar en S: la probabilidad de un pozo o del
%   wumpus, más una décima parte de la de los murciélagos, que no matan
%   pero llevan a una sala cualquiera.
riesgo(S, Pozos, Murcielagos, Wumpus, R) :-
    probabilidad(Pozos, S, PP),
    probabilidad(Wumpus, S, PW),
    probabilidad(Murcielagos, S, PM),
    R is 1 - (1 - PP) * (1 - PW) + PM / 10.

%!  mas_cercana(+Desde, +Destinos:list, +Transitables:list, -Paso)
%!      is semidet.
%
%   Paso es la primera sala del camino más corto de Desde a alguna sala de
%   Destinos que pasa solo por salas de Transitables. Falla si no hay
%   ninguno.
mas_cercana(Desde, Destinos, Transitables, Paso) :-
    Destinos \== [],
    anchura([[Desde]], [Desde], Destinos, Transitables, Camino),
    reverse(Camino, [_, Paso|_]).

%!  anchura(+Caminos:list, +Vistas:list, +Destinos:list,
%!          +Transitables:list, -Camino:list) is semidet.
%
%   Búsqueda en anchura: Caminos es la frontera, cada camino con la última
%   sala primero. Camino es el primero que llega a una sala de Destinos.
anchura([[S|Resto]|_], _, Destinos, _, [S|Resto]) :-
    memberchk(S, Destinos),
    Resto \== [],
    !.
anchura([[S|Resto]|Caminos], Vistas, Destinos, Transitables, Camino) :-
    findall([V, S|Resto],
            ( tunel(S, V),
              \+ memberchk(V, Vistas),
              (   memberchk(V, Destinos)
              ;   memberchk(V, Transitables)
              ) ),
            Nuevos),
    findall(V, member([V|_], Nuevos), Vs),
    append(Vistas, Vs, Vistas1),
    append(Caminos, Nuevos, Caminos1),
    anchura(Caminos1, Vistas1, Destinos, Transitables, Camino).

%!  camino(+Desde, +Hasta, -Salas:list, -Ruta:list) is nondet.
%
%   Ruta es un camino de túneles de Desde a Hasta, de a lo sumo cinco salas,
%   sin volver a Desde, con Hasta al final; los más cortos primero. Salas
%   es Ruta con Desde adelante.
camino(Desde, Hasta, [Desde|Ruta], Ruta) :-
    between(1, 5, L),
    length(Ruta, L),
    last(Ruta, Hasta),
    recorrido(Desde, Ruta, [Desde]).

%!  recorrido(+S, ?Ruta:list, +Vistas:list) is nondet.
%
%   Ruta es una sucesión de salas unidas por túneles desde S, sin repetir
%   ninguna de Vistas.
recorrido(_, [], _).
recorrido(S, [V|Ruta], Vistas) :-
    tunel(S, V),
    \+ memberchk(V, Vistas),
    recorrido(V, Ruta, [V|Vistas]).

% --- La partida -------------------------------------------------------------

%!  cazar(+Semilla:integer, -Resultado, -Ordenes:list) is det.
%
%   El agente juega la partida de Semilla. Resultado es gana, pierde(Causa)
%   o limite, si no termina en 100 jugadas; Ordenes son sus jugadas.
cazar(Semilla, Resultado, Ordenes) :-
    nueva_partida(Semilla, E),
    observacion(E, obs(S, _, Avisos, Flechas)),
    K = k(S, [S-Avisos], [S-Avisos], [], Flechas),
    turno(100, E, K, Resultado, Ordenes, _).

%!  turno(+N:integer, +E, +K, -Resultado, -Ordenes:list, -Mensajes:list)
%!      is det.
%
%   Juega a lo sumo N jugadas desde el estado E con el conocimiento K.
%   Mensajes son los mensajes de cada jugada, uno por orden.
turno(0, _, _, limite, [], []) :-
    !.
turno(N, E0, K0, Resultado, [Orden|Ordenes], [Ms|Mensajes]) :-
    decidir(K0, Orden),
    jugada(Orden, E0, E, R, Ms),
    (   R == sigue
    ->  observacion(E, Obs),
        aprender(Orden, Ms, Obs, K0, K),
        N1 is N - 1,
        turno(N1, E, K, Resultado, Ordenes, Mensajes)
    ;   Resultado = R,
        Ordenes = [],
        Mensajes = []
    ).

%!  aprender(+Orden, +Ms:list, +Obs, +K0, -K) is det.
%
%   K agrega a K0 lo que dicen la Orden jugada, los mensajes Ms que
%   produjo y la observación Obs de la sala nueva: las salas con
%   murciélagos, si alzaron al agente, y el olvido de los avisos del
%   wumpus, si despertó.
aprender(Orden, Ms, obs(S, _, Avisos, Flechas), k(_, Vs0, Rs0, Mu0, _),
         k(S, Vs, Rs, Mu, Flechas)) :-
    salas_con_murcielagos(Orden, Ms, Nuevas),
    append(Mu0, Nuevas, Mu1),
    sort(Mu1, Mu),
    (   ( memberchk(fallaste, Ms) ; memberchk(despiertas_wumpus, Ms) )
    ->  Rs1 = []
    ;   Rs1 = Rs0
    ),
    agregar(S-Avisos, Vs0, Vs),
    agregar(S-Avisos, Rs1, Rs).

%!  salas_con_murcielagos(+Orden, +Ms:list, -Salas:list) is det.
%
%   Salas son las salas donde los murciélagos alzaron al agente: la sala a
%   la que se movió y cada sala adonde lo llevaron, salvo la última.
salas_con_murcielagos(Orden, Ms, Salas) :-
    findall(D, member(murcielagos(D), Ms), Destinos),
    (   Orden = mover(S),
        append(Intermedias, [_], Destinos)
    ->  Salas = [S|Intermedias]
    ;   Salas = []
    ).

%!  agregar(+Par, +Ps0:list, -Ps:list) is det.
%
%   Ps es Ps0 con Par, un par Sala-Avisos, al final, si la sala no estaba.
agregar(S-A, Ps0, Ps) :-
    (   memberchk(S-_, Ps0)
    ->  Ps = Ps0
    ;   append(Ps0, [S-A], Ps)
    ).

%!  narrar(+Semilla:integer) is det.
%
%   Escribe la partida del agente con Semilla como la vería un jugador: la
%   observación, la orden y los mensajes de cada jugada.
narrar(Semilla) :-
    cazar(Semilla, _, Ordenes),
    nueva_partida(Semilla, E),
    narrar(Ordenes, E).

%!  narrar(+Ordenes:list, +E) is det.
%
%   Escribe las jugadas de Ordenes desde el estado E.
narrar([], _).
narrar([Orden|Ordenes], E0) :-
    observacion(E0, Obs),
    mensaje_texto(Obs, Texto),
    orden_texto(Orden, OT),
    format("~s~n> ~s~n", [Texto, OT]),
    jugada(Orden, E0, E, _, Ms),
    forall(member(M, Ms),
           ( mensaje_texto(M, T), format("~s~n", [T]) )),
    narrar(Ordenes, E).

%!  orden_texto(+Orden, -Texto:string) is det.
%
%   Texto es Orden escrita como la escribiría un jugador.
orden_texto(mover(S), Texto) :-
    format(string(Texto), "m ~w", [S]).
orden_texto(disparar(Ruta), Texto) :-
    atomic_list_concat([d|Ruta], ' ', A),
    atom_string(A, Texto).

%!  medir_caza(+Semillas:list, -Resultados:list) is det.
%
%   Resultados son pares Resultado-Cantidad: cuántas partidas de Semillas
%   terminó el agente con cada resultado, ordenados por resultado.
medir_caza(Semillas, Resultados) :-
    findall(R, ( member(S, Semillas), cazar(S, R, _) ), Rs),
    msort(Rs, Ordenados),
    clumped(Ordenados, Resultados).
