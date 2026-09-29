:- encoding(utf8).

% Capítulo 49 - Versión 4: modelos de falla y conducta desconocida.
%
% El modelo débil no dice qué hace una compuerta que falla: su estado es
% desconocida, y su salida puede ser cualquier bit. Se agrega a la teoría de
% la versión 2 con una regla más, sin tocar el intérprete. sospechosas/5 da
% los conjuntos de compuertas de los diagnósticos mínimos, sin los estados,
% para comparar los dos modelos.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- minimos(debil, sumador, [[0, 0, 1]-[0, 1]], 2, Ds).
%?- sospechosas(fuerte, sumador, [[0, 0, 1]-[0, 1], [1, 1, 0]-[1, 1]], 2, Rs).
%?- mas_simples(fuerte, sumador, [[0, 0, 1]-[0, 1], [0, 0, 1]-[1, 0]], Ds).

:- module(modelos,
          [ sospechosas/5
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(fallas).
:- use_module(abduccion).
:- reexport(minimos).

:- multifile abduccion:regla/2.

% En el modelo débil, una compuerta que falla da cualquier bit.
abduccion:regla(salida(debil, Ruta, _, _, S),
                (estado(Ruta, desconocida), bit(S))).

%!  sospechosas(+Modelo, +Circuito, +Observaciones:list(pair), +K:integer,
%!      -Conjuntos:list(list)) is det.
%
%   Conjuntos son los conjuntos de rutas de los diagnósticos mínimos con a
%   lo sumo K fallas, sin repetidos: las compuertas sospechosas, sin sus
%   estados.
sospechosas(Modelo, Circuito, Observaciones, K, Conjuntos) :-
    minimos(Modelo, Circuito, Observaciones, K, Minimos),
    maplist(rutas, Minimos, Conjuntos0),
    sort(Conjuntos0, Conjuntos).
