:- encoding(utf8).

% Capítulo 79 - Versión 8: la tabla corregida.
%
% La verificación encuentra 48 posiciones en que la tabla de krk.pl ahoga
% al rey negro: acercamiento, mantener_espacio o dividir_en_2 alcanzan su
% meta mejor con una jugada que deja a las negras sin jugadas, y ninguna
% meta lo impide. La tabla corregida es la misma con una condición más en
% la meta a mantener de cada consejo: no ahogado. Las reglas y la biblioteca
% de predicados son las de krk.pl, que se carga sin copiarla.
%
% solo-local: carga consejos.pl y krk.pl.
%
%?- consejo(dividir_en_2, B, M, N, S).

:- module(corregida,
          [ regla/2,
            consejo/5
          ]).

:- use_module(consejos).
:- use_module(krk, [mueve/2, meta/3, jugadas/4]).

%!  regla(?Nombre, ?Regla) is nondet.
%
%   Las reglas de la tabla original.
regla(Nombre, Regla) :-
    krk:regla(Nombre, Regla).

%!  consejo(?Nombre, ?Mejor, ?Mantener, ?Nuestras, ?Suyas) is nondet.
%
%   Los consejos de la tabla original, con no ahogado agregado a la meta a
%   mantener.
consejo(Nombre, Mejor, Mantener y no ahogado, Nuestras, Suyas) :-
    krk:consejo(Nombre, Mejor, Mantener, Nuestras, Suyas).
