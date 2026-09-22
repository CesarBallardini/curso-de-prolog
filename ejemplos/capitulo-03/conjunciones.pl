:- encoding(utf8).

% Capítulo 3 - Conjunciones.
%
% Una coma entre dos objetivos significa "y": ambos deben cumplirse, y si
% comparten una variable, esta debe tener el mismo valor en los dos.
%
%?- gusta(ana, Que), gusta(luis, Que).
%?- padre(juan, Quien), gusta(Quien, prolog).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

% madre(M, H): M es la madre de H.
madre(marta, ana).
madre(marta, pedro).
madre(eva, sofia).

% gusta(P, C): a P le gusta C.
gusta(juan, futbol).
gusta(ana, prolog).
gusta(ana, futbol).
gusta(luis, futbol).
gusta(eva, prolog).
gusta(sofia, dibujar).
