:- encoding(utf8).

% Capítulo 5 - Cómo responde Prolog.
%
% Un programa deliberadamente reducido: con tres hechos y una regla, el árbol
% de búsqueda se puede dibujar completo en una página.
%
%?- abuelo(juan, Quien).
%?- abuelo(Quien, luis).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

%!  abuelo_al_reves(?A, ?N) is nondet.
%
%   A es abuelo de N: la misma regla con los dos objetivos en orden inverso.
%   Produce las mismas respuestas; cambia la cantidad de búsqueda.
abuelo_al_reves(A, N) :-
    padre(P, N),
    padre(A, P).
