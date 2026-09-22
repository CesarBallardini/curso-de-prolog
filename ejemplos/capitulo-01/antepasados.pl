:- encoding(utf8).

% Capítulo 1 - Recursión.
%
% El árbol de Taré, del Génesis, es el ejemplo con el que Sterling y Shapiro
% comienzan "The Art of Prolog". Es adecuado porque tiene varias generaciones:
% entre Taré e Isaac hay dos, y una regla que recorre una sola generación no es
% suficiente.
%
%?- antepasado(tare, isaac).
%?- antepasado(tare, Quien).

% padre(P, H): P es el padre de H.
padre(tare, abraham).
padre(tare, nacor).
padre(tare, haran).
padre(abraham, isaac).
padre(haran, lot).
padre(haran, milca).
padre(haran, isca).

% madre(M, H): M es la madre de H.
madre(sara, isaac).

% progenitor(P, H): P es el padre o la madre de H: una sola generación, y
% no un ascendiente cualquiera. La relación transitiva es antepasado/2.
progenitor(P, H) :-
    padre(P, H).
progenitor(P, H) :-
    madre(P, H).

% antepasado(A, D): A es antepasado de D.
% Caso base: un progenitor es un antepasado. Caso recursivo: se desciende una
% generación y se plantea la misma pregunta desde ese punto.
antepasado(A, D) :-
    progenitor(A, D).
antepasado(A, D) :-
    progenitor(A, Hijo),
    antepasado(Hijo, D).
