:- encoding(utf8).

% Capítulo 33 - El intérprete con una representación limpia de los cuerpos.
%
% clausula/2 lee una cláusula con clause/2 y marca, una sola vez, cada
% objetivo de su cuerpo: prog(G) para un predicado del programa, sis(G) para
% uno predefinido. resolver_cuerpo/1 elige el caso por unificación en la
% cabeza, sin pruebas de tipo. Los predefinidos que el intérprete conoce son
% los de predefinido/1, y ejecutar/1 los ejecuta, uno por cláusula.
%
%?- resolver(mayor_que(juan, P)).
%?- resolver(maximo(5, 3, M)).
%?- numlist(1, 1000, L), resolver(longitud(L, N)).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(ana, luis).
padre(luis, eva).

% edad(P, E): P tiene E años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 37).

%!  antepasado(?A, ?D) is nondet.
%
%   A es un antepasado de D: su padre, o un antepasado de su padre.
antepasado(A, D) :-
    padre(A, D).
antepasado(A, D) :-
    padre(A, H),
    antepasado(H, D).

%!  mayor_que(?A, ?B) is nondet.
%
%   A tiene más años que B.
mayor_que(A, B) :-
    edad(A, EA),
    edad(B, EB),
    EA > EB.

%!  longitud(+Lista:list, -N:integer) is det.
%
%   N es la cantidad de elementos de Lista.
longitud([], 0).
longitud([_|Xs], N) :-
    longitud(Xs, N0),
    N is N0 + 1.

%!  maximo(+X:number, +Y:number, -M:number) is det.
%
%   M es el mayor de X e Y. El corte es rojo: la segunda cláusula es
%   correcta solo porque la primera cortó cuando X >= Y.
maximo(X, Y, X) :-
    X >= Y,
    !.
maximo(_, Y, Y).

% predefinido(G): el intérprete ejecuta G con ejecutar/1, sin buscar
% cláusulas.
predefinido(_ = _).
predefinido(_ is _).
predefinido(_ < _).
predefinido(_ > _).
predefinido(_ =< _).
predefinido(_ >= _).
predefinido(!).

%!  ejecutar(+G) is semidet.
%
%   Ejecuta el objetivo predefinido G. El corte se ejecuta como true: dentro
%   del intérprete no tiene a qué cláusula cortar.
ejecutar(X = Y) :-
    X = Y.
ejecutar(X is E) :-
    X is E.
ejecutar(X < Y) :-
    X < Y.
ejecutar(X > Y) :-
    X > Y.
ejecutar(X =< Y) :-
    X =< Y.
ejecutar(X >= Y) :-
    X >= Y.
ejecutar(!).

%!  clausula(+Meta, -Cuerpo) is nondet.
%
%   Meta :- Cuerpo es una cláusula del programa, con el cuerpo en la
%   representación limpia: true, (A, B), prog(G) o sis(G).
clausula(Meta, Cuerpo) :-
    clause(Meta, Cuerpo0),
    limpiar(Cuerpo0, Cuerpo).

%!  limpiar(+Cuerpo0, -Cuerpo) is det.
%
%   Cuerpo es el cuerpo Cuerpo0 con cada objetivo marcado: sis(G) si G es
%   predefinido, prog(G) si no lo es.
limpiar(true, true) :-
    !.
limpiar((A0, B0), (A, B)) :-
    !,
    limpiar(A0, A),
    limpiar(B0, B).
limpiar(G, sis(G)) :-
    predefinido(G),
    !.
limpiar(G, prog(G)).

%!  resolver(+Meta) is nondet.
%
%   Meta, un objetivo del programa, se prueba con sus cláusulas: una
%   respuesta por cada prueba.
resolver(Meta) :-
    resolver_cuerpo(prog(Meta)).

%!  resolver_cuerpo(+Cuerpo) is nondet.
%
%   Cuerpo, en la representación limpia, se prueba con las cláusulas del
%   programa y los predefinidos de ejecutar/1.
resolver_cuerpo(true).
resolver_cuerpo((A, B)) :-
    resolver_cuerpo(A),
    resolver_cuerpo(B).
resolver_cuerpo(sis(G)) :-
    ejecutar(G).
resolver_cuerpo(prog(G)) :-
    clausula(G, Cuerpo),
    resolver_cuerpo(Cuerpo).
