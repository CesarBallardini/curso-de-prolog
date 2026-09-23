:- encoding(utf8).

% Capítulo 5 - El orden de las cláusulas.
%
% Dos predicados con exactamente las mismas dos cláusulas, escritas en distinto
% orden. Producen las mismas respuestas, pero en distinto orden.
%
%?- antepasado(juan, Quien).
%?- primero_lejos(juan, Quien).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).

%!  antepasado(?A, ?D) is nondet.
%
%   A es antepasado de D, con el caso base escrito primero.
antepasado(A, D) :-
    padre(A, D).
antepasado(A, D) :-
    padre(A, Hijo),
    antepasado(Hijo, D).

%!  primero_lejos(?A, ?D) is nondet.
%
%   A es antepasado de D: las mismas dos cláusulas, en orden inverso.
primero_lejos(A, D) :-
    padre(A, Hijo),
    primero_lejos(Hijo, D).
primero_lejos(A, D) :-
    padre(A, D).
