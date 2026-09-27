:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 3: un módulo con una interfaz mínima.
%
% El módulo exporta abuelo/2; padre/2 es privado.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- abuelo(juan, N).

:- module(familia, [abuelo/2]).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).
