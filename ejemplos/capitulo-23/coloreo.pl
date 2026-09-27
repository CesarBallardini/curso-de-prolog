:- encoding(utf8).

% Capítulo 23 - Coloreo de un mapa: provincias vecinas con colores distintos.
%
% Ocho provincias del centro y el oeste de la Argentina. Cada provincia tiene
% una variable, su color, con dominio 1..K; cada límite exige colores
% distintos. San Luis está rodeada por un anillo de cinco provincias, y por
% eso tres colores no alcanzan.
%
%?- colorear(4, Colores).
%?- colorear(3, Colores).

:- use_module(library(clpfd)).

% provincia(P): P es una de las provincias del mapa.
provincia(san_juan).
provincia(mendoza).
provincia(san_luis).
provincia(la_rioja).
provincia(cordoba).
provincia(la_pampa).
provincia(neuquen).
provincia(rio_negro).

% limita(A, B): las provincias A y B tienen un límite en común.
limita(san_juan, la_rioja).
limita(san_juan, mendoza).
limita(san_juan, san_luis).
limita(mendoza, san_luis).
limita(mendoza, la_pampa).
limita(mendoza, neuquen).
limita(san_luis, la_rioja).
limita(san_luis, cordoba).
limita(san_luis, la_pampa).
limita(la_rioja, cordoba).
limita(cordoba, la_pampa).
limita(la_pampa, neuquen).
limita(la_pampa, rio_negro).
limita(neuquen, rio_negro).

%!  colorear(+K:integer, -Colores:list(pair)) is nondet.
%
%   Colores son pares Provincia-Color, con colores de 1 a K, tales que dos
%   provincias limítrofes tienen colores distintos. Falla si K colores no
%   alcanzan.
colorear(K, Colores) :-
    findall(P-_, provincia(P), Colores),
    pairs_values(Colores, Vs),
    Vs ins 1..K,
    findall(A-B, limita(A, B), Limites),
    maplist(distinto_color(Colores), Limites),
    label(Vs).

%!  distinto_color(+Colores:list(pair), +Limite:pair) is det.
%
%   Las dos provincias de Limite, A-B, tienen colores distintos en Colores.
distinto_color(Colores, A-B) :-
    memberchk(A-CA, Colores),
    memberchk(B-CB, Colores),
    CA #\= CB.
