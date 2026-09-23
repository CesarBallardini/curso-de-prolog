:- encoding(utf8).

% Capítulo 3 - Reglas.
%
% Los hechos enuncian lo que se cumple; las reglas indican cómo deducir
% afirmaciones nuevas. Con los hechos del capítulo 2 y tres reglas se puede
% consultar por abuelos, que no figuran en ningún hecho.
%
%?- abuelo(juan, Quien).
%?- progenitor(Quien, sofia).

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

%!  es_padre(?P) is nondet.
%
%   P es padre de alguien. Una regla de una sola condición.
es_padre(P) :-
    padre(P, _).

%!  progenitor(?P, ?H) is nondet.
%
%   P es el padre o la madre de H, y no un ascendiente cualquiera: nombra una
%   sola generación.
%   Dos cláusulas del mismo predicado son dos alternativas: se cumple una o se
%   cumple la otra.
progenitor(P, H) :-
    padre(P, H).
progenitor(P, H) :-
    madre(P, H).

%!  abuelo(?A, ?N) is nondet.
%
%   A es el abuelo de N.
abuelo(A, N) :-
    varon(A),
    progenitor(A, P),
    progenitor(P, N).

%!  abuela(?A, ?N) is nondet.
%
%   A es la abuela de N.
abuela(A, N) :-
    mujer(A),
    progenitor(A, P),
    progenitor(P, N).
