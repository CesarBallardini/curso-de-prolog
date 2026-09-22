:- encoding(utf8).

% Capítulo 6 - Los números naturales, escritos como términos.
%
% Cero es un natural, y el sucesor de un natural también lo es. Con esas dos
% afirmaciones, sin usar los números predefinidos de Prolog, se pueden definir
% la suma y la comparación. El ejemplo aísla la recursión de cualquier otro
% mecanismo.
%
%?- natural(s(s(0))).
%?- suma(s(0), s(s(0)), Cuanto).

% natural(N): N es un número natural.
natural(0).
natural(s(N)) :-
    natural(N).

% suma(A, B, C): C es A más B.
suma(0, B, B).
suma(s(A), B, s(C)) :-
    suma(A, B, C).

% menor(A, B): A es menor que B.
menor(0, s(_)).
menor(s(A), s(B)) :-
    menor(A, B).

% valor(N, V): V es el entero predefinido que corresponde al natural N.
valor(0, 0).
valor(s(N), V) :-
    valor(N, Anterior),
    V is Anterior + 1.
