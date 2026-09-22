:- encoding(utf8).

% Capítulo 3 - Una regla que produce respuestas de más.
%
% hermana/2 parece correcta y produce una respuesta de más: cada mujer resulta
% hermana de sí misma. hermana_de_verdad/2 es la misma regla con la condición
% faltante.
%
%?- hermana(ana, Quien).
%?- hermana_de_verdad(ana, Quien).

% mujer(P): P es mujer.
mujer(marta).
mujer(ana).
mujer(eva).
mujer(sofia).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

% hermana(A, B): A es hermana de B. La regla es incompleta: ver la sección 3.5.
hermana(A, B) :-
    mujer(A),
    padre(P, A),
    padre(P, B).

% hermana_de_verdad(A, B): A es hermana de B, y no son la misma persona.
hermana_de_verdad(A, B) :-
    mujer(A),
    padre(P, A),
    padre(P, B),
    A \== B.
