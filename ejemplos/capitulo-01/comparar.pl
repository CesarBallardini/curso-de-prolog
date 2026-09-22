:- encoding(utf8).

% Capítulo 1 - Igualdad y comparación.
%
% El operador = pregunta si dos términos pueden hacerse idénticos. Los
% operadores <, =<, > y >= comparan números. El operador \+, antepuesto a un
% objetivo, significa "este objetivo no se puede probar".
%
%?- mayor_que(luis, eva).
%?- distintos(ana, ana).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

% mayor_que(A, B): A tiene más años que B.
mayor_que(A, B) :-
    edad(A, EdadA),
    edad(B, EdadB),
    EdadA > EdadB.

% distintos(A, B): A y B no son la misma persona.
distintos(A, B) :-
    \+ A = B.

% comparten_edad(A, B): A y B tienen la misma edad y no son la misma persona.
comparten_edad(A, B) :-
    edad(A, Misma),
    edad(B, Misma),
    distintos(A, B).
