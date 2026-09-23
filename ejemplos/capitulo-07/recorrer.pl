:- encoding(utf8).

% Capítulo 7 - Recorrer una lista.
%
% Las tres operaciones básicas sobre listas, definidas desde cero. Prolog ya las
% provee; definirlas una vez muestra cómo se recorre una lista.
%
%?- esta_en(luis, [ana, luis, eva]).
%?- pegar([ana, luis], [eva], Todos).

%!  esta_en(?X, +L) is nondet.
%
%   X es uno de los elementos de L.
%   X es el primer elemento, o es un elemento del resto.
esta_en(X, [X|_]).
esta_en(X, [_|Resto]) :-
    esta_en(X, Resto).

%!  largo(+L, -N) is det.
%
%   N es la cantidad de elementos de L.
largo([], 0).
largo([_|Resto], N) :-
    largo(Resto, Faltan),
    N is Faltan + 1.

%!  pegar(+A, ?B, -C) is det.
%!  pegar(?A, ?B, +C) is nondet.
%
%   C es la lista A seguida de la lista B.
pegar([], B, B).
pegar([X|RestoA], B, [X|RestoC]) :-
    pegar(RestoA, B, RestoC).

%!  ultimo(+L, -X) is semidet.
%
%   X es el último elemento de L.
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
    esta_en(X, L),
    todos_estan(Resto, L).
