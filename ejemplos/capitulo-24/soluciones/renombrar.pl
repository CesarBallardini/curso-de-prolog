:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 12: importar con otro nombre.
%
% append/3 se importa como pegar/3, el nombre del capítulo 7.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- pegar([a], [b], L).

:- module(renombrar, [pegar/3]).

:- use_module(library(lists), [append/3 as pegar]).
