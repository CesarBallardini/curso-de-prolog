:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 5: el módulo que usa utiles con una
% condición propia, privada.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- cuantos_pares([1, 2, 3, 4], N).

:- module(usa_utiles, [cuantos_pares/2]).

:- use_module(utiles).

%!  par(+N:integer) is semidet.
%
%   N es par.
par(N) :-
    0 =:= N mod 2.

%!  cuantos_pares(+L:list(integer), -N:integer) is det.
%
%   N es la cantidad de números pares de L.
cuantos_pares(L, N) :-
    contar_cumplen(par, L, N).
