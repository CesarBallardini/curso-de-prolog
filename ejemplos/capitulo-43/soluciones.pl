:- encoding(utf8).

% Capítulo 43 - Solución del ejercicio 11: un sistema de dos ecuaciones
% por sustitución.
%
% sistema/5 despeja X de la primera ecuación, con Y como una constante
% más; reemplaza X por lo despejado en la segunda, que queda con Y como
% única incógnita; la resuelve, y calcula X con evaluar/3 del
% capítulo 32.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- sistema(x + y = 3, x - y = 1, x, y, S).
%?- sistema(x + y = 5, x * y = 6, x, y, S).

:- module(soluciones,
          [ sistema/5
          ]).

:- use_module(library(terms)).
:- use_module(capitulo32, [evaluar/3]).
:- use_module(ecuaciones, [resolver/3]).

%!  sistema(+E1, +E2, +X:atom, +Y:atom, -Solucion:list) is nondet.
%
%   Solucion es [X = VX, Y = VY], con VX y VY números que cumplen las
%   ecuaciones cerradas E1 y E2 en las incógnitas X e Y, si X puede
%   despejarse de E1. Hay una respuesta por solución.
sistema(E1, E2, X, Y, [X = VX, Y = VY]) :-
    resolver(E1, X, X = EX),
    mapsubterms(reemplazo(X, EX), E2, E2Y),
    resolver(E2Y, Y, Y = EY),
    VY is EY,
    evaluar(EX, [Y-VY], VX).

%!  reemplazo(+X:atom, +E, +T0, -T) is semidet.
%
%   T es E si T0 es la incógnita X; falla si no, y entonces mapsubterms/3
%   sigue por los argumentos de T0.
reemplazo(X, E, T0, E) :-
    T0 == X.
