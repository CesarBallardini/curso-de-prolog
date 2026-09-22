:- encoding(utf8).

% Capítulo 6 - El primer predicado recursivo.
%
% El mismo árbol de Taré del capítulo 1. Se lo retoma acá porque antepasado/2 es
% el ejemplo más claro de recursión: el problema se reduce de manera visible
% —se desciende una generación— y el caso base está a la vista.
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
