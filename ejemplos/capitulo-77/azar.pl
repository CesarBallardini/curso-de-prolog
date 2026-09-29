:- encoding(utf8).

% Capítulo 77 - Números al azar reproducibles.
%
% Un generador congruencial lineal: el estado es un entero, y cada paso lo
% reemplaza por (1103515245 * S + 12345) mod 2^31. El estado pasa de un
% predicado a otro como un argumento más, de modo que una partida queda
% determinada por su semilla, en cualquier instalación y en cualquier
% orden de las pruebas. No es un generador para criptografía: alcanza
% para ubicar peligros y decidir si el wumpus se mueve.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- azar(20, K, 7, S).
%?- elegir_distintos(3, [a, b, c, d, e], Xs, 7, S).

:- module(azar,
          [ azar/4,
            elegir/4,
            elegir_distintos/5
          ]).

:- use_module(library(lists)).

%!  azar(+N:integer, -K:integer, +S0:integer, -S:integer) is det.
%
%   K es un entero entre 0 y N - 1, obtenido del estado S0; S es el estado
%   siguiente. Usa los bits altos del estado, que varían más que los bajos.
azar(N, K, S0, S) :-
    must_be(positive_integer, N),
    S is (1103515245 * S0 + 12345) mod 2147483648,
    K is (S >> 16) mod N.

%!  elegir(+Xs:list, -X, +S0:integer, -S:integer) is semidet.
%
%   X es un elemento de Xs elegido al azar. Falla si Xs está vacía.
elegir(Xs, X, S0, S) :-
    length(Xs, N),
    N > 0,
    azar(N, K, S0, S),
    nth0(K, Xs, X).

%!  elegir_distintos(+N:integer, +Xs:list, -Elegidos:list, +S0:integer,
%!                   -S:integer) is semidet.
%
%   Elegidos son N elementos distintos de Xs, elegidos al azar, en el orden
%   en que se eligieron. Falla si Xs tiene menos de N elementos.
elegir_distintos(0, _, [], S, S) :-
    !.
elegir_distintos(N, Xs, [X|Elegidos], S0, S) :-
    elegir(Xs, X, S0, S1),
    selectchk(X, Xs, Resto),
    N1 is N - 1,
    elegir_distintos(N1, Resto, Elegidos, S1, S).
