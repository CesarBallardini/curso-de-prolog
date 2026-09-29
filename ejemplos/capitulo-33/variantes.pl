:- encoding(utf8).

% Capítulo 33 - Cuatro maneras de variar el intérprete: otra estrategia de
% búsqueda, otro procedimiento de prueba, más clases de objetivos e
% información adicional sobre la prueba.
%
% resolver_der/1 prueba las conjunciones de derecha a izquierda.
% resolver_lista/1 trabaja sobre la resolvente completa, una lista de
% objetivos pendientes. resolver_cuerpo/1 admite la negación \+ G.
% resolver_pasos/2 cuenta las cláusulas que usa la prueba.
%
%?- resolver_der(antepasado_izq(A, eva)).
%?- resolver_lista([antepasado(juan, D)]).
%?- resolver(sin_hijos(P)).
%?- resolver_pasos(antepasado(juan, eva), N).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(ana, luis).
padre(luis, eva).

% persona(P): P es una de las personas del programa.
persona(juan).
persona(ana).
persona(pedro).
persona(luis).
persona(eva).

%!  antepasado(?A, ?D) is nondet.
%
%   A es un antepasado de D: su padre, o un antepasado de su padre.
antepasado(A, D) :-
    padre(A, D).
antepasado(A, D) :-
    padre(A, H),
    antepasado(H, D).

%!  antepasado_izq(?A, ?D) is nondet.
%
%   A es un antepasado de D, con la recursión a la izquierda: Prolog no
%   termina después de la última respuesta.
antepasado_izq(A, D) :-
    padre(A, D).
antepasado_izq(A, D) :-
    antepasado_izq(A, H),
    padre(H, D).

%!  sin_hijos(?P) is nondet.
%
%   P es una persona que no es padre de nadie.
sin_hijos(P) :-
    persona(P),
    \+ padre(P, _).

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

%!  clausula(+Meta, -Cuerpo) is nondet.
%
%   Meta :- Cuerpo es una cláusula del programa, con el cuerpo en la
%   representación limpia: true, (A, B), no(C), prog(G) o sis(G).
clausula(Meta, Cuerpo) :-
    clause(Meta, Cuerpo0),
    limpiar(Cuerpo0, Cuerpo).

%!  limpiar(+Cuerpo0, -Cuerpo) is det.
%
%   Cuerpo es el cuerpo Cuerpo0 con cada objetivo marcado.
limpiar(true, true) :-
    !.
limpiar((A0, B0), (A, B)) :-
    !,
    limpiar(A0, A),
    limpiar(B0, B).
limpiar(\+ G0, no(G)) :-
    !,
    limpiar(G0, G).
limpiar(G, sis(G)) :-
    predefinido(G),
    !.
limpiar(G, prog(G)).

%!  resolver(+Meta) is nondet.
%
%   Meta, un objetivo del programa, se prueba con sus cláusulas.
resolver(Meta) :-
    resolver_cuerpo(prog(Meta)).

%!  resolver_cuerpo(+Cuerpo) is nondet.
%
%   Cuerpo se prueba de izquierda a derecha. no(C) se cumple si C no se
%   puede probar: la negación como falla, con \+.
resolver_cuerpo(true).
resolver_cuerpo((A, B)) :-
    resolver_cuerpo(A),
    resolver_cuerpo(B).
resolver_cuerpo(no(C)) :-
    \+ resolver_cuerpo(C).
resolver_cuerpo(sis(G)) :-
    ejecutar(G).
resolver_cuerpo(prog(G)) :-
    clausula(G, Cuerpo),
    resolver_cuerpo(Cuerpo).

%!  resolver_der(+Meta) is nondet.
%
%   Como resolver/1, pero cada conjunción se prueba de derecha a izquierda.
resolver_der(Meta) :-
    der(prog(Meta)).

%!  der(+Cuerpo) is nondet.
%
%   Cuerpo se prueba empezando por el último objetivo de cada conjunción.
der(true).
der((A, B)) :-
    der(B),
    der(A).
der(no(C)) :-
    \+ der(C).
der(sis(G)) :-
    ejecutar(G).
der(prog(G)) :-
    clausula(G, Cuerpo),
    der(Cuerpo).

%!  resolver_lista(+Metas:list) is nondet.
%
%   Las Metas, objetivos del programa, se prueban todas. La resolvente es
%   la lista de objetivos pendientes: el primero se reemplaza por el cuerpo
%   de una de sus cláusulas, puesto delante del resto.
resolver_lista(Metas) :-
    maplist([G, prog(G)]>>true, Metas, Resolvente),
    resolvente(Resolvente).

%!  resolvente(+Objetivos:list) is nondet.
%
%   Los Objetivos, en la representación limpia, se prueban en orden.
resolvente([]).
resolvente([true|Gs]) :-
    resolvente(Gs).
resolvente([(A, B)|Gs]) :-
    resolvente([A, B|Gs]).
resolvente([no(C)|Gs]) :-
    \+ resolvente([C]),
    resolvente(Gs).
resolvente([sis(G)|Gs]) :-
    ejecutar(G),
    resolvente(Gs).
resolvente([prog(G)|Gs]) :-
    clausula(G, Cuerpo),
    resolvente([Cuerpo|Gs]).

%!  resolver_pasos(+Meta, -N:integer) is nondet.
%
%   Meta se prueba con N usos de cláusulas: una respuesta por cada prueba.
resolver_pasos(Meta, N) :-
    pasos(prog(Meta), 0, N).

%!  pasos(+Cuerpo, +N0:integer, -N:integer) is nondet.
%
%   Cuerpo se prueba, y N es N0 más la cantidad de cláusulas usadas.
pasos(true, N, N).
pasos((A, B), N0, N) :-
    pasos(A, N0, N1),
    pasos(B, N1, N).
pasos(no(C), N, N) :-
    \+ pasos(C, 0, _).
pasos(sis(G), N, N) :-
    ejecutar(G).
pasos(prog(G), N0, N) :-
    clausula(G, Cuerpo),
    N1 is N0 + 1,
    pasos(Cuerpo, N1, N).
