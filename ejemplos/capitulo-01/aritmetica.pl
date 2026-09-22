:- encoding(utf8).

% Capítulo 1 - Aritmética.
%
% Una expresión aritmética no se evalúa de manera automática: la evaluación se
% solicita con is. A la izquierda va la variable que recibe el resultado; a la
% derecha, la expresión.
%
%?- doble(21, X).
%?- edad_en_meses(eva, Meses).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(luis, 12).
edad(eva, 8).

% doble(N, D): D es el doble de N.
doble(N, D) :-
    D is N * 2.

% edad_en_meses(P, M): M es la edad de P expresada en meses.
edad_en_meses(P, M) :-
    edad(P, A),
    M is A * 12.

% resto(N, R): R es el resto de dividir N por 2. Permite determinar si N es par.
resto(N, R) :-
    R is N mod 2.

% el_mayor(A, B, M): M es el mayor de los dos números.
el_mayor(A, B, M) :-
    M is max(A, B).
