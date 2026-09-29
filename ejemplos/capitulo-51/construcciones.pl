:- encoding(utf8).

% Capítulo 51 - Versión 3: construcciones sobre autómatas.
%
% Cada construcción es un nombre de autómata hecho con otros nombres, y
% sus cinco relaciones se definen con reglas, sin copiar ni generar hechos:
%
%   det(M)                el determinista equivalente a M, por la
%                         construcción de subconjuntos: sus estados son
%                         conjuntos de estados de M cerrados por ε, y
%                         el conjunto vacío es el estado sumidero;
%   complemento(M)        acepta las palabras sobre el alfabeto de M que
%                         M rechaza;
%   interseccion(M1, M2)  acepta las palabras que aceptan los dos;
%   union(M1, M2)         acepta las que acepta alguno de los dos.
%
% Sobre ellas, la inclusión y la equivalencia de lenguajes se deciden
% preguntando si un autómata acepta alguna palabra, y la palabra más corta
% que distingue dos autómatas es un contraejemplo.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- tabla(det(termina_ab), T).
%?- equivalentes(termina_ab, det(termina_ab)).
%?- contraejemplo(termina_ab, termina_b, W).

:- module(construcciones,
          [ vacio/1,
            palabra_mas_corta/2,
            incluido/2,
            equivalentes/2,
            contraejemplo/3
          ]).

:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- reexport(automatas).

:- multifile automatas:alfabeto/2, automatas:inicial/2, automatas:final/2,
             automatas:delta/4, automatas:epsilon/3.

% Un autómata más para comparar: las palabras sobre {a, b} que terminan
% en b.
automatas:alfabeto(termina_b, [a, b]).
automatas:inicial(termina_b, p0).
automatas:final(termina_b, p1).
automatas:delta(termina_b, p0, a, p0).
automatas:delta(termina_b, p0, b, p1).
automatas:delta(termina_b, p1, a, p0).
automatas:delta(termina_b, p1, b, p1).

% det(M): la construcción de subconjuntos.

automatas:alfabeto(det(M), Sigma) :-
    alfabeto(M, Sigma).
automatas:inicial(det(M), D0) :-
    inicial(M, Q0),
    clausura_conjunto(M, [Q0], D0).
automatas:final(det(M), D) :-
    alcanzable(det(M), D),
    once(( member(Q, D), final(M, Q) )).
automatas:delta(det(M), D, S, D1) :-
    alfabeto(M, Sigma),
    member(S, Sigma),
    mover(M, S, D, D1).

% complemento(M): el determinista de M, con los finales intercambiados.

automatas:alfabeto(complemento(M), Sigma) :-
    alfabeto(M, Sigma).
automatas:inicial(complemento(M), D0) :-
    inicial(det(M), D0).
automatas:final(complemento(M), D) :-
    alcanzable(det(M), D),
    \+ final(det(M), D).
automatas:delta(complemento(M), D, S, D1) :-
    delta(det(M), D, S, D1).

% interseccion(M1, M2) y union(M1, M2): el producto de los deterministas.

automatas:alfabeto(interseccion(M1, M2), Sigma) :-
    alfabeto_producto(M1, M2, Sigma).
automatas:inicial(interseccion(M1, M2), D1-D2) :-
    inicial_producto(M1, M2, D1-D2).
automatas:final(interseccion(M1, M2), D1-D2) :-
    alcanzable(interseccion(M1, M2), D1-D2),
    acepta_conjunto(M1, D1),
    acepta_conjunto(M2, D2).
automatas:delta(interseccion(M1, M2), P, S, P1) :-
    alfabeto_producto(M1, M2, Sigma),
    member(S, Sigma),
    paso_producto(M1, M2, P, S, P1).

automatas:alfabeto(union(M1, M2), Sigma) :-
    alfabeto_producto(M1, M2, Sigma).
automatas:inicial(union(M1, M2), D1-D2) :-
    inicial_producto(M1, M2, D1-D2).
automatas:final(union(M1, M2), D1-D2) :-
    alcanzable(union(M1, M2), D1-D2),
    (   acepta_conjunto(M1, D1)
    ->  true
    ;   acepta_conjunto(M2, D2)
    ).
automatas:delta(union(M1, M2), P, S, P1) :-
    alfabeto_producto(M1, M2, Sigma),
    member(S, Sigma),
    paso_producto(M1, M2, P, S, P1).

%!  alfabeto_producto(+M1, +M2, -Sigma:list) is det.
%
%   Sigma es la unión de los alfabetos de M1 y M2.
alfabeto_producto(M1, M2, Sigma) :-
    alfabeto(M1, Sigma1),
    alfabeto(M2, Sigma2),
    ord_union(Sigma1, Sigma2, Sigma).

%!  inicial_producto(+M1, +M2, -P) is det.
%
%   P es el par de los estados iniciales de los deterministas de M1 y M2.
inicial_producto(M1, M2, D1-D2) :-
    inicial(det(M1), D1),
    inicial(det(M2), D2).

%!  paso_producto(+M1, +M2, +P, +S, -P1) is det.
%
%   Leyendo S, el par de conjuntos de estados P pasa al par P1: cada
%   componente avanza en su autómata. Un símbolo que no está en el
%   alfabeto de uno lleva esa componente al conjunto vacío.
paso_producto(M1, M2, D1-D2, S, E1-E2) :-
    mover(M1, S, D1, E1),
    mover(M2, S, D2, E2).

%!  acepta_conjunto(+M, +D:list) is semidet.
%
%   El conjunto de estados D de M contiene un estado final.
acepta_conjunto(M, D) :-
    member(Q, D),
    final(M, Q),
    !.

%!  vacio(+M) is semidet.
%
%   M no acepta ninguna palabra: ningún estado alcanzable es final.
vacio(M) :-
    \+ ( alcanzable(M, Q),
         final(M, Q) ).

%!  palabra_mas_corta(+M, -W:list) is semidet.
%
%   W es la primera, en orden estándar, de las palabras más cortas que
%   acepta M. Falla si M no acepta ninguna.
palabra_mas_corta(M, W) :-
    \+ vacio(M),
    length(_, N),
    palabras(M, N, [W|_]),
    !.

%!  incluido(+M1, +M2) is semidet.
%
%   Toda palabra que acepta M1 la acepta M2.
incluido(M1, M2) :-
    vacio(interseccion(M1, complemento(M2))).

%!  equivalentes(+M1, +M2) is semidet.
%
%   M1 y M2 aceptan el mismo lenguaje.
equivalentes(M1, M2) :-
    incluido(M1, M2),
    incluido(M2, M1).

%!  contraejemplo(+M1, +M2, -W:list) is semidet.
%
%   W es una de las palabras más cortas que acepta uno solo de M1 y M2.
%   Falla si son equivalentes.
contraejemplo(M1, M2, W) :-
    palabra_mas_corta(union(interseccion(M1, complemento(M2)),
                            interseccion(M2, complemento(M1))),
                      W).
