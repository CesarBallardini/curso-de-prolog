:- encoding(utf8).

% Capítulo 1 - Definición por casos.
%
% Para distinguir casos se escribe una cláusula por caso, y cada una establece
% en qué condiciones vale. Prolog las evalúa en orden hasta que una se cumple.
%
%?- etapa(sofia, Etapa).
%?- edad(Quien, 12).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).
edad(sofia, 3).

%!  etapa(?P, ?E) is nondet.
%
%   E es la etapa de la vida en la que está P, según su edad.
etapa(P, bebe) :-
    edad(P, A),
    A < 4.
etapa(P, chico) :-
    edad(P, A),
    A >= 4,
    A < 18.
etapa(P, adulto) :-
    edad(P, A),
    A >= 18.
