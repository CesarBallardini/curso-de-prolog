:- encoding(utf8).

% Capítulo 77 - Versión 2: el mundo del Wumpus de Russell y Norvig.
%
% Una cueva de N x N celdas, X-Y con X e Y de 1 a N, tiene pozos, un wumpus
% y oro. El agente entra por (1, 1). En cada celda percibe hedor si el
% wumpus está en una celda vecina, brisa si hay un pozo en una vecina,
% brillo si el oro está en la celda, un golpe si la acción anterior lo
% llevó contra una pared y un grito si su flecha acaba de matar al wumpus.
% Las acciones son ir a una celda vecina, tomar el oro, disparar la única
% flecha hacia el norte, el sur, el este o el oeste, y salir de la cueva
% desde (1, 1). Russell y Norvig hacen girar al agente antes de avanzar;
% aquí el agente va directamente a una de las cuatro vecinas.
%
% El puntaje es el de Russell y Norvig: 1 punto menos por acción, 10 más
% por disparar, 1000 por salir con el oro y 1000 menos por morir. Un mundo
% es un término mundo(N, Pozos, Wumpus, Oro); figura_7_2 es la cueva del
% capítulo 20, leída de sus hechos, y mundo_sembrado/2 construye uno al
% azar: un pozo en cada celda, salvo (1, 1), con probabilidad 1/5, y el
% wumpus y el oro en celdas distintas de (1, 1).
%
% simular/5 juega una partida con un agente dado como un predicado: el
% agente recibe las percepciones y su conocimiento, y devuelve una acción
% y el conocimiento nuevo. El simulador no le muestra nada más.
%
% solo-local: es un módulo que carga otros.
%
%?- mundo(figura_7_2, M), mostrar(M).
%?- mundo_sembrado(3, M), mostrar(M).

:- module(grilla,
          [ mundo/2,
            mundo_sembrado/2,
            vecina/3,
            linea/4,
            mostrar/1,
            percepciones/3,
            actuar/6,
            simular/5,
            estado_inicial/1
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(azar).
:- use_module(capitulo20).

% --- Los mundos -------------------------------------------------------------

%!  mundo(+Nombre, -M) is semidet.
%
%   M es el mundo llamado Nombre: figura_7_2, la cueva del capítulo 20.
mundo(figura_7_2, mundo(4, Pozos, Wumpus, Oro)) :-
    cueva_20(Pozos, Wumpus, Oro).

%!  mundo_sembrado(+Semilla:integer, -M) is det.
%
%   M es un mundo de 4 x 4 construido al azar a partir de Semilla.
mundo_sembrado(Semilla, mundo(4, Pozos, Wumpus, Oro)) :-
    findall(X-Y, ( between(1, 4, X), between(1, 4, Y), X-Y \== 1-1 ),
            Celdas),
    foldl(tal_vez_pozo, Celdas, Pozos0, Semilla, S1),
    exclude(==(sin_pozo), Pozos0, Pozos),
    elegir(Celdas, Wumpus, S1, S2),
    elegir(Celdas, Oro, S2, _).

%!  tal_vez_pozo(+C, -P, +S0:integer, -S:integer) is det.
%
%   P es C con probabilidad 1/5, y sin_pozo en otro caso.
tal_vez_pozo(C, P, S0, S) :-
    azar(5, K, S0, S),
    (   K =:= 0
    ->  P = C
    ;   P = sin_pozo
    ).

%!  vecina(+N:integer, +C, -V) is nondet.
%
%   V es una celda vecina de C dentro de la cueva de N x N: al este, al
%   oeste, al norte o al sur, en ese orden.
vecina(N, X-Y, VX-VY) :-
    member(DX-DY, [1-0, -1-0, 0-1, 0-(-1)]),
    VX is X + DX,
    VY is Y + DY,
    between(1, N, VX),
    between(1, N, VY).

%!  mostrar(+M) is det.
%
%   Escribe el mundo M, una fila por línea, la de arriba primero: P es un
%   pozo, W el wumpus, O el oro y . una celda vacía.
mostrar(mundo(N, Pozos, Wumpus, Oro)) :-
    forall(( between(1, N, I), Y is N + 1 - I ),
           ( findall(L,
                     ( between(1, N, X),
                       letra(X-Y, Pozos, Wumpus, Oro, L) ),
                     Ls),
             atomic_list_concat(Ls, ' ', Fila),
             format("~w~n", [Fila]) )).

%!  letra(+C, +Pozos:list, +Wumpus, +Oro, -L) is det.
%
%   L es la letra con que se muestra la celda C.
letra(C, Pozos, Wumpus, Oro, L) :-
    (   memberchk(C, Pozos)
    ->  L = 'P'
    ;   C == Wumpus
    ->  L = 'W'
    ;   C == Oro
    ->  L = 'O'
    ;   L = '.'
    ).

% --- Las percepciones y las acciones ----------------------------------------

% El estado de la partida es e(Celda, Oro, Flecha, Wumpus): la celda del
% agente, si lleva el oro (si o no), si le queda la flecha (si o no) y si
% el wumpus vive (vivo o muerto).

%!  estado_inicial(-E) is det.
%
%   E es el estado al empezar: el agente en (1, 1), sin el oro, con la
%   flecha, y el wumpus vivo.
estado_inicial(e(1-1, no, si, vivo)).

%!  percepciones(+M, +E, -Ps:list) is det.
%
%   Ps son las percepciones de la celda del agente en el estado E del mundo
%   M, sin el golpe ni el grito, que dependen de la acción anterior: hedor,
%   brisa y brillo, en ese orden, las que haya.
percepciones(mundo(N, Pozos, Wumpus, Oro), e(C, TieneOro, _, _), Ps) :-
    findall(P,
            ( member(P, [hedor, brisa, brillo]),
              percibe(P, N, C, Pozos, Wumpus, Oro, TieneOro) ),
            Ps).

%!  percibe(+P, +N, +C, +Pozos, +Wumpus, +Oro, +TieneOro) is semidet.
%
%   En la celda C se percibe P.
percibe(hedor, N, C, _, Wumpus, _, _) :-
    once(vecina(N, C, Wumpus)).
percibe(brisa, N, C, Pozos, _, _, _) :-
    once(( vecina(N, C, V), memberchk(V, Pozos) )).
percibe(brillo, _, C, _, _, C, no).

%!  actuar(+M, +Accion, +E0, -E, -Extras:list, -Fin) is det.
%
%   Accion lleva el estado E0 del mundo M a E. Extras son las percepciones
%   que produce la acción: golpe o grito. Fin es sigue, salio(Oro) o
%   murio(Causa). Una acción ir(C) hacia una celda que no es vecina de la
%   del agente produce un error de dominio.
actuar(mundo(N, Pozos, Wumpus, _), ir(C), e(C0, O, F, W), E, Extras, Fin) :-
    (   \+ adyacente(C0, C)
    ->  domain_error(celda_vecina, C)
    ;   C = X-Y,
        \+ ( between(1, N, X), between(1, N, Y) )
    ->  E = e(C0, O, F, W),
        Extras = [golpe],
        Fin = sigue
    ;   E = e(C, O, F, W),
        Extras = [],
        (   memberchk(C, Pozos)
        ->  Fin = murio(pozo)
        ;   C == Wumpus,
            W == vivo
        ->  Fin = murio(wumpus)
        ;   Fin = sigue
        )
    ).
actuar(mundo(_, _, _, Oro), tomar, e(C, O0, F, W), e(C, O, F, W), [],
       sigue) :-
    (   C == Oro
    ->  O = si
    ;   O = O0
    ).
actuar(mundo(N, _, Wumpus, _), disparar(Dir), e(C, O, F0, W0),
       e(C, O, no, W), Extras, sigue) :-
    (   F0 == si,
        W0 == vivo,
        linea(N, C, Dir, Linea),
        memberchk(Wumpus, Linea)
    ->  W = muerto,
        Extras = [grito]
    ;   W = W0,
        Extras = []
    ).
actuar(_, salir, E, E, [], Fin) :-
    E = e(C, O, _, _),
    (   C == 1-1
    ->  Fin = salio(O)
    ;   Fin = sigue
    ).

%!  adyacente(+C0, +C) is semidet.
%
%   C está al lado de C0, dentro o fuera de la cueva.
adyacente(X0-Y0, X-Y) :-
    1 =:= abs(X - X0) + abs(Y - Y0).

%!  linea(+N:integer, +C, +Dir, -Celdas:list) is semidet.
%
%   Celdas son las celdas que recorre una flecha que sale de C hacia Dir
%   en una cueva de N x N, como lista ordenada. Falla si Dir no es una de
%   las cuatro direcciones.
linea(N, X-Y, Dir, Celdas) :-
    direccion(Dir, DX, DY),
    findall(CX-CY,
            ( between(1, N, K),
              CX is X + K * DX,
              CY is Y + K * DY,
              between(1, N, CX),
              between(1, N, CY) ),
            Celdas0),
    sort(Celdas0, Celdas).

% direccion(Dir, DX, DY): el paso de una celda a la siguiente hacia Dir.
direccion(este, 1, 0).
direccion(oeste, -1, 0).
direccion(norte, 0, 1).
direccion(sur, 0, -1).

% --- La partida -------------------------------------------------------------

:- meta_predicate simular(+, 4, +, +, -).

%!  simular(+M, :Agente, +K0, +Max:integer, -Final) is det.
%
%   Juega una partida en el mundo M con Agente, que se llama como
%   call(Agente, Percepciones, K, Accion, K1) con el conocimiento K y
%   devuelve la Accion y el conocimiento K1. Empieza con K0 y termina al
%   salir, al morir o después de Max acciones. Final es
%   final(Fin, Puntaje, Acciones), con las acciones en orden.
simular(M, Agente, K0, Max, final(Fin, Puntaje, Acciones)) :-
    estado_inicial(E0),
    partida(M, Agente, K0, E0, [], Max, 0, Fin, Puntaje, Acciones).

%!  partida(+M, :Agente, +K, +E, +Extras:list, +Max:integer, +P0:integer,
%!          -Fin, -Puntaje:integer, -Acciones:list) is det.
%
%   Una jugada y el resto de la partida desde el estado E, con Extras las
%   percepciones que dejó la acción anterior y P0 el puntaje acumulado.
partida(_, _, _, _, _, 0, P, limite, P, []) :-
    !.
partida(M, Agente, K0, E0, Extras, Max, P0, Fin, Puntaje, [A|Acciones]) :-
    percepciones(M, E0, Ps0),
    append(Ps0, Extras, Ps),
    call(Agente, Ps, K0, A, K),
    actuar(M, A, E0, E, Extras1, Fin1),
    costo(A, Fin1, Costo),
    P1 is P0 + Costo,
    (   Fin1 == sigue
    ->  Max1 is Max - 1,
        partida(M, Agente, K, E, Extras1, Max1, P1, Fin, Puntaje,
                Acciones)
    ;   Fin = Fin1,
        Puntaje = P1,
        Acciones = []
    ).

%!  costo(+Accion, +Fin, -Costo:integer) is det.
%
%   Costo es lo que suma al puntaje la Accion que terminó en Fin.
costo(Accion, Fin, Costo) :-
    (   Accion = disparar(_)
    ->  C0 = -11
    ;   C0 = -1
    ),
    (   Fin == salio(si)
    ->  Costo is C0 + 1000
    ;   Fin = murio(_)
    ->  Costo is C0 - 1000
    ;   Costo = C0
    ).
