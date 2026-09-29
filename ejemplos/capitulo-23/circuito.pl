:- encoding(utf8).

% Capítulo 23 - Un circuito de cuatro compuertas NAND, como relación.
%
% Cada compuerta es su tabla de verdad, y el circuito es la conjunción de las
% cuatro. La misma relación calcula la salida y encuentra las entradas que
% dan una salida; library(clpb) demuestra qué función calcula.
%
%?- circuito(X, Y, 1).
%?- es_xor(T).

:- use_module(library(clpb)).

% nand(A, B, S): S es la salida de una compuerta NAND con entradas A y B.
nand(0, 0, 1).
nand(0, 1, 1).
nand(1, 0, 1).
nand(1, 1, 0).

%!  circuito(?X, ?Y, ?Z) is nondet.
%
%   Z es la salida del circuito para las entradas X e Y: la primera
%   compuerta combina las entradas, la segunda y la tercera combinan cada
%   entrada con la salida de la primera, y la cuarta da Z.
circuito(X, Y, Z) :-
    nand(X, Y, A),
    nand(X, A, B),
    nand(Y, A, C),
    nand(B, C, Z).

%!  circuito_b(?X, ?Y, ?Z) is det.
%
%   El mismo circuito como restricciones de library(clpb): ~ es la
%   negación, * la conjunción y =:= la equivalencia.
circuito_b(X, Y, Z) :-
    sat(A =:= ~(X * Y)),
    sat(B =:= ~(X * A)),
    sat(C =:= ~(Y * A)),
    sat(Z =:= ~(B * C)).

%!  es_xor(-T) is det.
%
%   T es 1 si la salida del circuito es equivalente, para toda entrada, a la
%   disyunción exclusiva (#) de las entradas, y 0 si no lo es para ninguna.
es_xor(T) :-
    circuito_b(X, Y, Z),
    taut(Z =:= X # Y, T).
