:- encoding(utf8).

% Capítulo 1 - Hechos y reglas.
%
% Un árbol genealógico mínimo: cuatro hechos sobre quién es padre de quién, y una
% regla que dice qué significa ser abuelo. Cargalo y probá las consultas.
%
%?- abuelo(juan, Quien).
%?- padre(Quien, ana).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(ana, luis).
padre(pedro, eva).

% abuelo(A, N): A es abuelo de N cuando es el padre de alguno de sus padres.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).
