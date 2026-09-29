:- encoding(utf8).

% Capítulo 33 - El intérprete vainilla: Prolog escrito en Prolog, en tres
% cláusulas.
%
% resolver/1 prueba un objetivo del programa con las cláusulas que obtiene
% de clause/2. Reconoce la conjunción y true por lo que son, y cualquier
% otra cosa por lo que no es: con un objetivo predefinido, como una
% comparación, clause/2 produce un error de permiso.
%
%?- resolver(abuelo(juan, N)).
%?- resolver(antepasado(A, eva)).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(ana, luis).
padre(luis, eva).

% edad(P, E): P tiene E años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 37).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

%!  antepasado(?A, ?D) is nondet.
%
%   A es un antepasado de D: su padre, o un antepasado de su padre.
antepasado(A, D) :-
    padre(A, D).
antepasado(A, D) :-
    padre(A, H),
    antepasado(H, D).

%!  mayor_que(?A, ?B) is nondet.
%
%   A tiene más años que B.
mayor_que(A, B) :-
    edad(A, EA),
    edad(B, EB),
    EA > EB.

%!  resolver(+Meta) is nondet.
%
%   Meta se prueba con las cláusulas del programa: una respuesta por cada
%   prueba. Meta es true, una conjunción o un objetivo de un predicado del
%   programa; con un predicado predefinido, clause/2 produce un error.
resolver(true).
resolver((A, B)) :-
    resolver(A),
    resolver(B).
resolver(Meta) :-
    Meta \= true,
    Meta \= (_, _),
    clause(Meta, Cuerpo),
    resolver(Cuerpo).
