:- encoding(utf8).

% Capítulo 10 - Los seis operadores de igualdad y desigualdad.
%
% =  y \=   preguntan si dos términos pueden unificar.
% == y \==  preguntan si dos términos son idénticos, sin unificar.
% =:= y =\= evalúan las expresiones de ambos lados y comparan los valores.
%
%?- mismo_termino(2 + 1, 3).
%?- mismo_valor(2 + 1, 3).

% mismo_termino(A, B): A y B son el mismo término, en su estado actual.
mismo_termino(A, B) :-
    A == B.

% distinto_termino(A, B): A y B no son el mismo término.
distinto_termino(A, B) :-
    A \== B.

% mismo_valor(A, B): las expresiones A y B tienen el mismo valor.
mismo_valor(A, B) :-
    A =:= B.

% pueden_ser_el_mismo(A, B): A y B unifican.
pueden_ser_el_mismo(A, B) :-
    A = B.
