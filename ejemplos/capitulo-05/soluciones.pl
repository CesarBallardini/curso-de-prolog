:- encoding(utf8).

% Capítulo 5 - Soluciones de los ejercicios.
%
% El programa del capítulo con los predicados que piden los ejercicios 5, 6 y 7.
%
%?- nieto_al_reves(Quien, juan).
%?- hermano(luis, Quien).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
% Ejercicio 6: una generación más.
padre(luis, sofia).

abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

% --- Ejercicio 5 -----------------------------------------------------------

% nieto(N, A): con el objetivo que menos ramas abre primero.
nieto(N, A) :-
    padre(A, P),
    padre(P, N).

% nieto_al_reves(N, A): la misma regla, con los objetivos en orden inverso.
nieto_al_reves(N, A) :-
    padre(P, N),
    padre(A, P).

% --- Ejercicio 6 -----------------------------------------------------------

antepasado(A, D) :-
    padre(A, D).
antepasado(A, D) :-
    padre(A, Hijo),
    antepasado(Hijo, D).

primero_lejos(A, D) :-
    padre(A, Hijo),
    primero_lejos(Hijo, D).
primero_lejos(A, D) :-
    padre(A, D).

% --- Ejercicio 7 -----------------------------------------------------------

% hermano(A, B): sin la cláusula recursiva que no reducía el problema.
hermano(A, B) :-
    padre(P, A),
    padre(P, B),
    A \== B.
