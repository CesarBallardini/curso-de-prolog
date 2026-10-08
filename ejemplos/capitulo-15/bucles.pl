:- encoding(utf8).

% Capítulo 15 - Bucles por falla.
%
% Un bucle por falla recorre las respuestas de un objetivo por sus efectos
% laterales: escribe cada una y fuerza la siguiente con fail. La disyunción
% final con true hace que el predicado se cumpla cuando las respuestas se
% agotan.
%
%?- listar_edades.
%?- tabla_de_multiplicar(7).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 45).
edad(luis, 12).
edad(eva, 8).
edad(sofia, 3).

%!  listar_edades is det.
%
%   Escribe una línea por cada persona de la base, con su edad.
listar_edades :-
    (   edad(P, A),
        format("~w: ~d~n", [P, A]),
        fail
    ;   true
    ).

%!  tabla_de_multiplicar(+N:integer) is det.
%
%   Escribe la tabla de multiplicar de N, del 1 al 10.
tabla_de_multiplicar(N) :-
    (   between(1, 10, I),
        P is N * I,
        format("~d x ~d = ~d~n", [N, I, P]),
        fail
    ;   true
    ).
