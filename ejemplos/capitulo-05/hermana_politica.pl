:- encoding(utf8).

% Capítulo 5 - Soluciones de los ejercicios.
%
% El programa del ejercicio 16: seis cláusulas, con los nombres de variables
% de la consulta repetidos en las reglas, para dibujar el árbol de derivación
% con variables nuevas.
%
%?- hermana_politica(C, X).

% hijo(H, P): H es hijo de P.
hijo(antonio, juan).
hijo(enrique, juan).

% mujer(M, E): M es la mujer, la esposa, de E.
mujer(belen, enrique).

% distinto(A, B): A y B son dos personas distintas.
distinto(enrique, antonio).

%!  hermana_politica(?X, ?Y) is nondet.
%
%   X es hermana política (cuñada) de Y: es la mujer de un hermano de Y.
hermana_politica(X, Y) :-
    mujer(X, Z),
    hermano(Z, Y).

%!  hermano(?X, ?Y) is nondet.
%
%   X es hermano de Y: son hijos del mismo padre y distintos entre sí.
hermano(X, Y) :-
    hijo(X, Z),
    hijo(Y, Z),
    distinto(X, Y).
