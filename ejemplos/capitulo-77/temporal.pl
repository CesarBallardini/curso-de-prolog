:- encoding(utf8).

% Capítulo 77 - El agente con historia: axiomas de estado sucesor.
%
% En el apartado «Agents Based on Propositional Logic», Russell y Norvig
% no le dicen al agente dónde está: el agente lo deduce de lo que hizo y
% de lo que percibió. Sus acciones son las del libro: avanzar, girar a la
% izquierda o a la derecha, disparar hacia donde mira, tomar y salir. Una
% historia es un término h(N, Percepciones, Acciones): el tamaño de la
% cueva, la lista de percepciones de los momentos 0, 1, ..., T y la lista
% de acciones de los momentos 0, ..., T - 1.
%
% Un fluente es una propiedad que cambia con el tiempo: en(Celda),
% mira(Direccion), tiene_flecha y wumpus_vivo. vale/3 los define con un
% axioma de estado sucesor por fluente: el fluente vale en T + 1 si la
% acción de T lo produjo, o si valía en T y la acción no lo deshizo. La
% ubicación, por ejemplo, cambia solo si el agente avanzó y no percibió un
% golpe. Con la ubicación de cada momento, conocimiento_en/3 arma el
% conocimiento de la versión 3, y ok/3 decide, como el OK de Russell y
% Norvig, si una celda no tiene pozo ni un wumpus vivo.
%
% traducir/4 convierte un plan de la versión 3, una lista de ir(Celda), en
% giros y avances, e historia/3 lo ejecuta en un mundo de la versión 2 y
% registra lo que percibe el agente.
%
% solo-local: es un módulo que carga otros.
%
%?- ejemplo_historia(figura_7_4, H), trayectoria(H, Cs).
%?- ejemplo_historia(disparo, H), celdas_ok(H, 7, Cs).

:- module(temporal,
          [ vale/3,
            percibio/3,
            hizo/3,
            adelante/3,
            girar/3,
            conocimiento_en/3,
            ok/3,
            celdas_ok/3,
            trayectoria/2,
            giros/3,
            traducir/4,
            historia/3,
            ejemplo_historia/2
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- reexport(agente).

% --- La historia --------------------------------------------------------------

%!  percibio(+H, ?P, +T:integer) is nondet.
%
%   En el momento T de la historia H el agente percibió P.
percibio(h(_, Percepciones, _), P, T) :-
    nth0(T, Percepciones, Ps),
    member(P, Ps).

%!  hizo(+H, ?A, +T:integer) is semidet.
%
%   En el momento T de la historia H el agente hizo la acción A.
hizo(h(_, _, Acciones), A, T) :-
    nth0(T, Acciones, A).

% --- Los axiomas de estado sucesor --------------------------------------------

%!  vale(+H, ?Fluente, +T:integer) is nondet.
%
%   Fluente vale en el momento T de la historia H. En el momento 0 el
%   agente está en (1, 1), mira al este, tiene la flecha y el wumpus vive;
%   en cada momento posterior, cada fluente sigue su axioma de estado
%   sucesor.
vale(_, Fluente, 0) :-
    inicial(Fluente).
vale(H, Fluente, T) :-
    T > 0,
    T0 is T - 1,
    sucesor(Fluente, H, T0, T).

% inicial(F): el fluente F vale en el momento 0.
inicial(en(1-1)).
inicial(mira(este)).
inicial(tiene_flecha).
inicial(wumpus_vivo).

%!  sucesor(?Fluente, +H, +T0:integer, +T:integer) is nondet.
%
%   Fluente vale en T = T0 + 1, según lo que valía en T0, la acción de T0
%   y lo que se percibió en T.
sucesor(en(C), H, T0, T) :-
    vale(H, en(C0), T0),
    (   hizo(H, avanzar, T0),
        \+ percibio(H, golpe, T)
    ->  vale(H, mira(D), T0),
        adelante(C0, D, C)
    ;   C = C0
    ).
sucesor(mira(D), H, T0, _) :-
    vale(H, mira(D0), T0),
    (   hizo(H, girar(Lado), T0)
    ->  girar(Lado, D0, D)
    ;   D = D0
    ).
sucesor(tiene_flecha, H, T0, _) :-
    vale(H, tiene_flecha, T0),
    \+ hizo(H, disparar, T0).
sucesor(wumpus_vivo, H, T0, T) :-
    vale(H, wumpus_vivo, T0),
    \+ percibio(H, grito, T).

%!  adelante(+C0, ?D, ?C) is nondet.
%
%   C es la celda vecina de C0 hacia la dirección D. Con D instanciada
%   hay una sola respuesta.
adelante(X-Y, D, X1-Y1) :-
    desplazamiento(D, DX, DY),
    X1 is X + DX,
    Y1 is Y + DY.

% desplazamiento(D, DX, DY): un paso hacia la dirección D suma DX a la
% columna y DY a la fila.
desplazamiento(este, 1, 0).
desplazamiento(norte, 0, 1).
desplazamiento(oeste, -1, 0).
desplazamiento(sur, 0, -1).

%!  girar(?Lado, ?D0, ?D) is nondet.
%
%   Girar hacia Lado, izquierda o derecha, cambia la dirección D0 por D.
girar(izquierda, D0, D) :-
    izquierda(D0, D).
girar(derecha, D0, D) :-
    izquierda(D, D0).

% izquierda(D0, D): D es la dirección a la izquierda de D0.
izquierda(este, norte).
izquierda(norte, oeste).
izquierda(oeste, sur).
izquierda(sur, este).

% --- El conocimiento en cada momento ------------------------------------------

%!  conocimiento_en(+H, +T:integer, -K) is det.
%
%   K es el conocimiento de la versión 3 que se sigue de la historia H
%   hasta el momento T: la celda del agente en T, las celdas visitadas en
%   orden, con la brisa y el hedor percibidos en cada una, si tiene la
%   flecha y si el wumpus vive.
conocimiento_en(H, T, c(N, C, Visitadas, no, Flecha, Wumpus, [])) :-
    H = h(N, _, _),
    once(vale(H, en(C), T)),
    numlist(0, T, Momentos),
    foldl(visitar(H), Momentos, [], Visitadas),
    (   vale(H, tiene_flecha, T)
    ->  Flecha = si
    ;   Flecha = no
    ),
    (   vale(H, wumpus_vivo, T)
    ->  Wumpus = vivo([])
    ;   Wumpus = muerto
    ).

%!  visitar(+H, +T:integer, +Vs0:list, -Vs:list) is det.
%
%   Vs agrega a Vs0 la celda del agente en el momento T, con su brisa y su
%   hedor, si no estaba.
visitar(H, T, Vs0, Vs) :-
    once(vale(H, en(C), T)),
    (   memberchk(C-_, Vs0)
    ->  Vs = Vs0
    ;   findall(P, ( percibio(H, P, T), de_la_celda(P) ), Ps0),
        msort(Ps0, Ps),
        append(Vs0, [C-Ps], Vs)
    ).

%!  ok(+H, +C, +T:integer) is semidet.
%
%   En el momento T de la historia H se sabe que la celda C no tiene pozo
%   ni un wumpus vivo: es una celda visitada o una celda segura de la
%   frontera.
ok(H, C, T) :-
    conocimiento_en(H, T, K),
    clasificar(K, C, Clase),
    memberchk(Clase, [visitada, segura]).

%!  celdas_ok(+H, +T:integer, -Celdas:list) is det.
%
%   Celdas son las celdas de la cueva de H para las que vale ok/3 en el
%   momento T, en orden.
celdas_ok(H, T, Celdas) :-
    H = h(N, _, _),
    conocimiento_en(H, T, K),
    findall(X-Y,
            ( between(1, N, X),
              between(1, N, Y),
              clasificar(K, X-Y, Clase),
              memberchk(Clase, [visitada, segura]) ),
            Celdas).

%!  trayectoria(+H, -Celdas:list) is det.
%
%   Celdas tiene la celda del agente en cada momento de la historia H.
trayectoria(H, Celdas) :-
    H = h(_, Percepciones, _),
    length(Percepciones, L),
    T is L - 1,
    numlist(0, T, Momentos),
    maplist(celda_en(H), Momentos, Celdas).

%!  celda_en(+H, +T:integer, -C) is det.
%
%   C es la celda del agente en el momento T de la historia H.
celda_en(H, T, C) :-
    once(vale(H, en(C), T)).

% --- De los planes de la versión 3 a las acciones del libro -------------------

%!  giros(+D0, +D, -Giros:list) is det.
%
%   Giros son los giros que llevan de mirar hacia D0 a mirar hacia D: ninguno,
%   uno a cada lado o dos a la izquierda.
giros(D, D, []) :-
    !.
giros(D0, D, [girar(izquierda)]) :-
    izquierda(D0, D),
    !.
giros(D0, D, [girar(derecha)]) :-
    izquierda(D, D0),
    !.
giros(_, _, [girar(izquierda), girar(izquierda)]).

%!  traducir(+Plan:list, +Inicio, -Acciones:list, -Fin) is semidet.
%
%   Acciones son las acciones del libro que ejecutan Plan, una lista de
%   acciones de la versión 3, desde Inicio, un término p(Celda, Direccion);
%   Fin es la posición en que termina. Falla si Plan va a una celda que no
%   es vecina.
traducir([], P, [], P).
traducir([A|Plan], P0, Acciones, Fin) :-
    paso(A, P0, Acciones, Resto, P),
    traducir(Plan, P, Resto, Fin).

%!  paso(+A, +P0, -Acciones:list, ?Resto:list, -P) is semidet.
%
%   Acciones son las acciones del libro que ejecutan la acción A de la
%   versión 3 desde la posición P0, seguidas de Resto, y P es la posición
%   final. ir(C) gira hacia C y avanza; disparar(D) gira hacia D y
%   dispara; tomar y salir no cambian.
paso(ir(C), p(C0, D0), Acciones, Resto, p(C, D)) :-
    once(adelante(C0, D, C)),
    giros(D0, D, Giros),
    append(Giros, [avanzar|Resto], Acciones).
paso(disparar(D), p(C, D0), Acciones, Resto, p(C, D)) :-
    giros(D0, D, Giros),
    append(Giros, [disparar|Resto], Acciones).
paso(tomar, P, [tomar|Resto], Resto, P).
paso(salir, P, [salir|Resto], Resto, P).

% --- La historia de una partida -----------------------------------------------

%!  historia(+M, +Acciones:list, -H) is det.
%
%   H es la historia del agente que ejecuta Acciones, acciones del libro,
%   en el mundo M de la versión 2, desde (1, 1) mirando al este: lo que
%   percibe en cada momento, con el golpe y el grito que deja cada acción.
%   La historia se corta si el agente muere o sale.
historia(M, Acciones, h(N, [Ps0|Percepciones], Hechas)) :-
    M = mundo(N, _, _, _),
    E0 = s(1-1, este, no, si, vivo),
    percibir(M, E0, [], Ps0),
    pasos(Acciones, M, E0, Percepciones, Hechas).

%!  pasos(+Acciones:list, +M, +E, -Percepciones:list, -Hechas:list) is det.
%
%   Percepciones son las percepciones que siguen a cada acción de
%   Acciones desde el estado E, y Hechas las acciones ejecutadas.
pasos([], _, _, [], []).
pasos([A|Acciones], M, E0, [Ps|Percepciones], [A|Hechas]) :-
    ejecutar(A, M, E0, E, Extras, Fin),
    percibir(M, E, Extras, Ps),
    (   Fin == sigue
    ->  pasos(Acciones, M, E, Percepciones, Hechas)
    ;   Percepciones = [],
        Hechas = []
    ).

%!  percibir(+M, +E, +Extras:list, -Ps:list) is det.
%
%   Ps son las percepciones de la celda del estado E, más Extras.
percibir(M, s(C, _, Oro, Flecha, Wumpus), Extras, Ps) :-
    percepciones(M, e(C, Oro, Flecha, Wumpus), Ps0),
    append(Ps0, Extras, Ps).

%!  ejecutar(+A, +M, +E0, -E, -Extras:list, -Fin) is det.
%
%   La acción A del libro lleva del estado E0 al E en el mundo M, con las
%   percepciones Extras que deja; Fin es sigue, murio(Causa) o salio(Oro).
%   Avanzar y disparar se ejecutan con actuar/6 de la versión 2.
ejecutar(avanzar, M, s(C0, D, O, F, W), s(C, D, O1, F1, W1), Extras,
         Fin) :-
    adelante(C0, D, C1),
    actuar(M, ir(C1), e(C0, O, F, W), e(C, O1, F1, W1), Extras, Fin).
ejecutar(girar(Lado), _, s(C, D0, O, F, W), s(C, D, O, F, W), [],
         sigue) :-
    girar(Lado, D0, D).
ejecutar(disparar, M, s(C, D, O0, F0, W0), s(C, D, O, F, W), Extras, Fin) :-
    actuar(M, disparar(D), e(C, O0, F0, W0), e(C, O, F, W), Extras, Fin).
ejecutar(tomar, M, s(C, D, O0, F0, W0), s(C, D, O, F, W), Extras, Fin) :-
    actuar(M, tomar, e(C, O0, F0, W0), e(C, O, F, W), Extras, Fin).
ejecutar(salir, M, s(C, D, O0, F0, W0), s(C, D, O, F, W), Extras, Fin) :-
    actuar(M, salir, e(C, O0, F0, W0), e(C, O, F, W), Extras, Fin).

% ejemplo_historia(Nombre, H): H es una historia de ejemplo en la cueva de
% la figura 7.2. figura_7_4 es la situación de la figura 7.4 de Russell y
% Norvig con las acciones del libro: en (1, 1) nada; avanza a (2, 1) y
% percibe brisa; gira dos veces, vuelve a (1, 1), gira a la derecha,
% avanza a (1, 2) y percibe hedor. disparo agrega un disparo hacia el
% norte desde (1, 2), que mata al wumpus.
ejemplo_historia(figura_7_4,
                 h(4, [[], [brisa], [brisa], [brisa], [], [], [hedor]],
                   [ avanzar, girar(izquierda), girar(izquierda), avanzar,
                     girar(derecha), avanzar ])).
ejemplo_historia(disparo,
                 h(4, [ [], [brisa], [brisa], [brisa], [], [], [hedor],
                        [hedor, grito] ],
                   [ avanzar, girar(izquierda), girar(izquierda), avanzar,
                     girar(derecha), avanzar, disparar ])).
