:- encoding(utf8).

% Capítulo 25 - Solución del ejercicio 12: importar con otro nombre.
%
% append/3 se importa como concatenar/3, el nombre del capítulo 7.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- concatenar([a], [b], L).

:- module(renombrar, [concatenar/3]).

:- use_module(library(lists), [append/3 as concatenar]).
