:- encoding(utf8).

% Capítulo 6 - Los números naturales, escritos como términos.
%
% Cero es un natural, y el sucesor de un natural también lo es. Con esas dos
% afirmaciones, sin usar los números predefinidos de Prolog, se pueden definir
% la suma y la comparación. El ejemplo aísla la recursión de cualquier otro
% mecanismo.
%
%?- natural(s(s(cero))).
%?- suma(s(cero), s(s(cero)), Cuanto).

%!  natural(+N) is semidet.
%!  natural(-N) is multi.
%
%   N es un número natural.
natural(cero).
natural(s(N)) :-
    natural(N).

%!  suma(?A, ?B, ?C) is nondet.
%
%   C es A más B.
suma(cero, B, B).
suma(s(A), B, s(C)) :-
    suma(A, B, C).

%!  menor(?A, ?B) is nondet.
%
%   A es menor que B.
menor(cero, s(_)).
menor(s(A), s(B)) :-
    menor(A, B).

%!  valor(+N, -V) is det.
%
%   V es el entero predefinido que corresponde al natural N.
valor(cero, 0).
valor(s(N), V) :-
    valor(N, Anterior),
    V is Anterior + 1.
