:- encoding(utf8).

% Capítulo 7 - Recorrer una lista.
%
% Las tres operaciones básicas sobre listas, definidas desde cero. Prolog ya las
% provee; definirlas una vez muestra cómo se recorre una lista.
%
%?- pertenece(luis, [ana, luis, eva]).
%?- concatenar([ana, luis], [eva], Todos).

%!  pertenece(?X, ?L) is nondet.
%
%   X es uno de los elementos de L.
%   X es el primer elemento, o es un elemento del resto. Con L libre, enumera
%   listas cada vez más largas que contienen a X, sin fin.
pertenece(X, [X|_]).
pertenece(X, [_|Resto]) :-
    pertenece(X, Resto).

%!  longitud(?L, ?N) is nondet.
%
%   N es la cantidad de elementos de L. Con L libre, enumera listas de
%   variables de largo creciente; con L libre y N ligado, da la lista de N
%   variables y después no termina.
longitud([], 0).
longitud([_|Resto], N) :-
    longitud(Resto, Faltan),
    N is Faltan + 1.

%!  concatenar(+A, ?B, -C) is det.
%!  concatenar(?A, ?B, +C) is nondet.
%
%   C es la lista A seguida de la lista B.
concatenar([], B, B).
concatenar([X|RestoA], B, [X|RestoC]) :-
    concatenar(RestoA, B, RestoC).

%!  ultimo(?L, ?X) is nondet.
%
%   X es el último elemento de L. Con L libre, enumera listas cada vez más
%   largas que terminan en X, sin fin.
ultimo([X], X).
ultimo([_|Resto], X) :-
    ultimo(Resto, X).

%!  todos_estan(+Buscados, +L) is nondet.
%
%   Todos los elementos de Buscados son elementos de L.
%   Todos los elementos cumplen una condición: el caso base es la lista vacía y
%   tiene éxito, y el recorrido fracasa en cuanto uno no cumple.
todos_estan([], _).
todos_estan([X|Resto], L) :-
    pertenece(X, L),
    todos_estan(Resto, L).
