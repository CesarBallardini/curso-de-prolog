:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 5: un meta-predicado en un módulo.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- contar_cumplen(integer, [1, a, 2], N).

:- module(utiles, [contar_cumplen/3]).

:- meta_predicate
    contar_cumplen(1, +, -).

%!  contar_cumplen(:Condicion, +L:list, -N:integer) is det.
%
%   N es la cantidad de elementos de L que cumplen Condicion. Condicion se
%   llama en el módulo que llama a contar_cumplen/3.
contar_cumplen(Condicion, L, N) :-
    include(Condicion, L, Cumplen),
    length(Cumplen, N).
