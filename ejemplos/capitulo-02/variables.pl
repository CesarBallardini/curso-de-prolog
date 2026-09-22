:- encoding(utf8).

% Capítulo 2 - Variables.
%
% La misma familia del ejemplo anterior, con los gustos de cada integrante. Con
% una variable se puede consultar por la persona, por el gusto, o por ambos.
%
%?- gusta(Quien, prolog).
%?- gusta(ana, Que).

% varon(P): P es varón.
varon(juan).
varon(pedro).
varon(luis).

% mujer(P): P es mujer.
mujer(marta).
mujer(ana).
mujer(eva).
mujer(sofia).

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
gusta(luis, futbol).
gusta(eva, prolog).
gusta(sofia, dibujar).
