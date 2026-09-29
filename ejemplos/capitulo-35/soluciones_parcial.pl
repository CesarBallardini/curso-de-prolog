:- encoding(utf8).

% Capítulo 35 - Soluciones de los ejercicios 9 y 10: evaluación parcial con
% parcial/3 de parcial.pl.
%
% resolver_cuerpo/1 es el intérprete con representación limpia del
% capítulo 33 (limpio.pl). especializar_vainilla/2 lo evalúa parcialmente
% sobre una cláusula del programa, y devuelve la cláusula original.
% es_letra/2 construye, con los residuos de pertenece/2 sobre una lista
% conocida, las cláusulas de un predicado que la enumera.
%
% solo-local: carga parcial.pl con ensure_loaded/1, y SWISH no permite
% cargar otro archivo.
%
%?- especializar_vainilla((abuelo(A, N) :- padre(A, P), padre(P, N)), C).
%?- es_letra([a, b, c], Cs).

:- ensure_loaded(parcial).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(ana, luis).

% edad(P, E): P tiene E años.
edad(juan, 68).
edad(ana, 41).

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

% predefinido(G): el intérprete ejecuta G con ejecutar/1.
predefinido(_ = _).
predefinido(_ is _).
predefinido(_ < _).
predefinido(_ > _).

%!  ejecutar(+G) is semidet.
%
%   Ejecuta el objetivo predefinido G.
ejecutar(X = Y) :-
    X = Y.
ejecutar(X is E) :-
    X is E.
ejecutar(X < Y) :-
    X < Y.
ejecutar(X > Y) :-
    X > Y.

%!  limpiar(+Cuerpo0, -Cuerpo) is det.
%
%   Cuerpo es el cuerpo Cuerpo0 con cada objetivo marcado.
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
    clause(G, Cuerpo0),
    limpiar(Cuerpo0, Cuerpo),
    resolver_cuerpo(Cuerpo).

% Ejercicio 9

%!  especializar_vainilla(+Clausula, -Especializada) is nondet.
%
%   Especializada es Clausula con el cuerpo reemplazado por el residuo de
%   resolver_cuerpo/1 sobre él.
especializar_vainilla((Cabeza :- Cuerpo0), (Cabeza :- Residuo)) :-
    limpiar(Cuerpo0, Cuerpo),
    parcial(resolver_cuerpo(Cuerpo), control_vainilla, Residuo).

%!  control_vainilla(+Meta, -Accion) is semidet.
%
%   Se despliegan resolver_cuerpo/1 y ejecutar/1; un objetivo del programa
%   queda como la llamada misma.
control_vainilla(resolver_cuerpo(prog(G)), dejar(G)).
control_vainilla(resolver_cuerpo(Cuerpo), desplegar) :-
    Cuerpo \= prog(_).
control_vainilla(ejecutar(_), desplegar).

% Ejercicio 10

%!  pertenece(?X, ?L:list) is nondet.
%
%   X es un elemento de L.
pertenece(X, [X|_]).
pertenece(X, [_|Ys]) :-
    pertenece(X, Ys).

%!  control_pertenece(+Meta, -Accion) is semidet.
%
%   pertenece/2 se despliega si su lista es conocida.
control_pertenece(pertenece(_, L), desplegar) :-
    nonvar(L).

%!  es_letra(+Letras:list, -Clausulas:list) is det.
%
%   Clausulas son las cláusulas de es_letra/1 para las Letras: una por cada
%   residuo de pertenece(X, Letras).
es_letra(Letras, Clausulas) :-
    findall((es_letra(X) :- Residuo),
            parcial(pertenece(X, Letras), control_pertenece, Residuo),
            Clausulas).
