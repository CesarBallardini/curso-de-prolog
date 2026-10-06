:- encoding(utf8).

% Capítulo 44 - Un laberinto de pasadizos retorcidos.
%
% En Colossal Cave Adventure hay un laberinto de salas que se describen
% todas con la misma frase, y cuyos pasadizos no siempre vuelven por la
% dirección opuesta: salir hacia el norte y después hacia el sur no lleva
% de vuelta al lugar de partida. El jugador las distingue dejando un objeto
% en cada una. Aquí el laberinto es una relación pasaje/3 entre salas y
% direcciones; andar/3 sigue una lista de direcciones, camino/3 busca la
% más corta, explorar/2 marca las salas como lo haría el jugador y
% retorcido/2 encuentra los pasadizos que no vuelven.
%
% solo-local: SWISH no admite módulos propios.
%
%?- andar(entrada, [abajo, norte, sur], S).
%?- camino(entrada, tesoro, Ds).
%?- explorar(entrada, Salas).

:- module(laberinto,
          [ pasaje/3,
            opuesta/2,
            andar/3,
            salas/1,
            camino/3,
            retorcido/2,
            explorar/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).

% pasaje(S1, D, S2): desde la sala S1, la dirección D lleva a la sala S2.
pasaje(entrada, abajo, l1).
pasaje(l1, norte, l2).
pasaje(l1, este, l1).
pasaje(l1, arriba, entrada).
pasaje(l2, sur, l3).
pasaje(l2, este, l4).
pasaje(l2, oeste, l1).
pasaje(l3, norte, l2).
pasaje(l3, oeste, l1).
pasaje(l3, abajo, l5).
pasaje(l4, oeste, l2).
pasaje(l4, sur, l1).
pasaje(l4, abajo, pozo).
pasaje(l5, arriba, l3).
pasaje(l5, este, tesoro).
pasaje(tesoro, oeste, l5).

% opuesta(D1, D2): D2 es la dirección opuesta a D1.
opuesta(norte, sur).
opuesta(sur, norte).
opuesta(este, oeste).
opuesta(oeste, este).
opuesta(arriba, abajo).
opuesta(abajo, arriba).

%!  andar(+S0, ?Ds:list, ?S) is nondet.
%
%   Siguiendo las direcciones Ds desde la sala S0 se llega a la sala S.
andar(S, [], S).
andar(S0, [D|Ds], S) :-
    pasaje(S0, D, S1),
    andar(S1, Ds, S).

%!  salas(-Salas:list) is det.
%
%   Salas es la lista ordenada de las salas del laberinto.
salas(Salas) :-
    setof(S, D^S2^( pasaje(S, D, S2) ; pasaje(S2, D, S) ), Salas).

%!  camino(+Desde, +Hasta, -Ds:list) is semidet.
%
%   Ds es la lista de direcciones más corta que lleva de Desde a Hasta. La
%   búsqueda es una profundización iterativa: prueba con 0, 1, 2…
%   direcciones, sin pasar de la cantidad de salas, porque un camino más
%   corto que eso no repite salas. Falla si Hasta no se alcanza.
camino(Desde, Hasta, Ds) :-
    salas(Salas),
    length(Salas, N),
    between(0, N, L),
    length(Ds0, L),
    andar(Desde, Ds0, Hasta),
    !,
    Ds = Ds0.

%!  retorcido(?S, ?D) is nondet.
%
%   El pasadizo que sale de S en la dirección D no vuelve a S por la
%   dirección opuesta.
retorcido(S, D) :-
    pasaje(S, D, S2),
    opuesta(D, O),
    \+ pasaje(S2, O, S).

%!  explorar(+Desde, -Salas:list) is det.
%
%   Salas son las salas que se alcanzan desde Desde, en el orden en que las
%   marca un jugador que deja un objeto en cada sala nueva, prueba las
%   salidas en el orden de pasaje/3 y no entra en una sala ya marcada.
explorar(Desde, Salas) :-
    marcar(Desde, [], Marcadas),
    reverse(Marcadas, Salas).

%!  marcar(+S, +Marcadas0:list, -Marcadas:list) is det.
%
%   Marcadas agrega a Marcadas0, en orden inverso, las salas alcanzadas
%   desde S que no estaban marcadas.
marcar(S, Marcadas0, Marcadas) :-
    memberchk(S, Marcadas0),
    !,
    Marcadas = Marcadas0.
marcar(S, Marcadas0, Marcadas) :-
    findall(S2, pasaje(S, _, S2), Vecinas),
    foldl(marcar, Vecinas, [S|Marcadas0], Marcadas).
