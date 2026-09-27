:- encoding(utf8).

% Capítulo 24 - Un módulo que usa el módulo meta con un predicado propio.
%
% mayor_de_edad/1 es privado del módulo usa_meta. todos_mayores/1 lo pasa a
% cada_uno_meta/2, que lo encuentra; todos_mayores_sin_declarar/1 lo pasa a
% cada_uno_sin_declarar/2, que lo busca en el módulo meta y no lo encuentra.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- todos_mayores([juan, ana]).
%?- catch(todos_mayores_sin_declarar([juan]), E, true).

:- module(usa_meta, [todos_mayores/1, todos_mayores_sin_declarar/1]).

:- use_module(meta).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(eva, 8).

%!  mayor_de_edad(?P) is nondet.
%
%   P tiene 18 años o más.
mayor_de_edad(P) :-
    edad(P, E),
    E >= 18.

%!  todos_mayores(+Personas:list) is semidet.
%
%   Todas las Personas son mayores de edad.
todos_mayores(Personas) :-
    cada_uno_meta(mayor_de_edad, Personas).

%!  todos_mayores_sin_declarar(+Personas:list) is semidet.
%
%   Lo mismo, con cada_uno_sin_declarar/2: produce un error de existencia,
%   porque mayor_de_edad/1 se busca en el módulo meta.
todos_mayores_sin_declarar(Personas) :-
    cada_uno_sin_declarar(mayor_de_edad, Personas).
