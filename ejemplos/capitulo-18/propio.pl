:- encoding(utf8).

% Capítulo 18 - Escribir un predicado de orden superior.
%
% cada_uno/2 y relacionar/3 son maplist/2 y maplist/3 escritos de manera
% explícita: la plantilla de recorrido del capítulo 7 con la condición como
% argumento, y la lista primero en el predicado que recorre.
% cuantos_cumplen/3 combina un predicado de la biblioteca con length/2. La
% directiva meta_predicate declara qué argumentos son objetivos.
%
%?- cada_uno(mayor_de_edad, [juan, ana]).
%?- relacionar(edad, [juan, eva], Edades).
%?- cuantos_cumplen(menor_de_edad, [juan, luis, eva], N).

:- meta_predicate
    cada_uno_1(1, ?),
    cada_uno(1, ?),
    cada_uno_(?, 1),
    relacionar(2, ?, ?),
    relacionar_(?, ?, 2),
    cuantos_cumplen(1, +, -).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

%!  mayor_de_edad(?P) is nondet.
%
%   P tiene 18 años o más.
mayor_de_edad(P) :-
    edad(P, E),
    E >= 18.

%!  menor_de_edad(?P) is nondet.
%
%   P tiene menos de 18 años.
menor_de_edad(P) :-
    edad(P, E),
    E < 18.

%!  cada_uno_1(:Condicion, +L:list) is semidet.
%
%   Primera versión de cada_uno/2, con la condición como primer argumento.
%   Es correcta, pero en las dos cláusulas el primer argumento es una
%   variable: la indexación no las distingue, y al terminar la lista queda
%   pendiente la segunda cláusula.
cada_uno_1(_, []).
cada_uno_1(Condicion, [X|Resto]) :-
    call(Condicion, X),
    cada_uno_1(Condicion, Resto).

%!  cada_uno(:Condicion, +L:list) is semidet.
%
%   Todos los elementos de L cumplen Condicion, un predicado de un argumento.
%   Se cumple con la lista vacía.
cada_uno(Condicion, L) :-
    cada_uno_(L, Condicion).

%!  cada_uno_(+L:list, :Condicion) is semidet.
%
%   El recorrido de cada_uno/2, con la lista como primer argumento para que
%   la indexación elija la cláusula.
cada_uno_([], _).
cada_uno_([X|Resto], Condicion) :-
    call(Condicion, X),
    cada_uno_(Resto, Condicion).

%!  relacionar(:Relacion, ?L1:list, ?L2:list) is nondet.
%
%   Cada elemento de L1 está en Relacion con el que ocupa su lugar en L2.
relacionar(Relacion, L1, L2) :-
    relacionar_(L1, L2, Relacion).

%!  relacionar_(?L1:list, ?L2:list, :Relacion) is nondet.
%
%   El recorrido de relacionar/3, con las listas primero.
relacionar_([], [], _).
relacionar_([X|Xs], [Y|Ys], Relacion) :-
    call(Relacion, X, Y),
    relacionar_(Xs, Ys, Relacion).

%!  cuantos_cumplen(:Condicion, +L:list, -N:integer) is det.
%
%   N es la cantidad de elementos de L que cumplen Condicion.
cuantos_cumplen(Condicion, L, N) :-
    include(Condicion, L, Cumplen),
    length(Cumplen, N).
