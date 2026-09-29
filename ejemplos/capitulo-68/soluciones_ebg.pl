:- encoding(utf8).

% Capítulo 68 - Solución del ejercicio 9: is/2 como predefinido.
%
% Copias de explicar/4 y ebg/5 con is/2 entre los predefinidos, y una
% teoría pesado con su ejemplo. Las copias usan la teoría de este archivo
% y los predicados operacionales que se les pasan.
%
% solo-local: carga ebg.pl, que carga archivos de otros capítulos.
%
%?- aprender_is(bloque1, pesado(bloque1), R), mostrar(R).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(ebg, [mostrar/1]).

% regla_is(R): R es una regla de la teoría pesado.
regla_is((pesado(X) :- peso(X, P), volumen(X, V), D is P / V, D > 1)).

% hechos_is(E, Hs): Hs es la descripción del ejemplo E.
hechos_is(bloque1, [peso(bloque1, 3000), volumen(bloque1, 1000),
                    color(bloque1, gris)]).
hechos_is(corcho1, [peso(corcho1, 240), volumen(corcho1, 1000)]).

% operacionales_is(Ps): los predicados operacionales de la teoría pesado.
operacionales_is([peso/2, volumen/2, color/2]).

% predefinido_is(G): el intérprete ejecuta G con ejecutar_is/1.
predefinido_is(_ is _).
predefinido_is(_ < _).
predefinido_is(_ > _).

%!  ejecutar_is(+G) is semidet.
%
%   Ejecuta el objetivo predefinido G.
ejecutar_is(X is E) :-
    X is E.
ejecutar_is(X < Y) :-
    X < Y.
ejecutar_is(X > Y) :-
    X > Y.

%!  explicar_is(+Hs:list, +G) is nondet.
%
%   G se prueba con la teoría pesado y los hechos Hs.
explicar_is(Hs, G) :-
    (   predefinido_is(G)
    ->  ejecutar_is(G)
    ;   operacionales_is(Ops),
        functor(G, Nombre, Aridad),
        memberchk(Nombre/Aridad, Ops)
    ->  member(G, Hs)
    ;   regla_is(R),
        copy_term(R, (G :- Cuerpo)),
        explicar_cuerpo_is(Hs, Cuerpo)
    ).

%!  explicar_cuerpo_is(+Hs:list, +C) is nondet.
%
%   Cada objetivo de la conjunción C se prueba con explicar_is/2.
explicar_cuerpo_is(Hs, C) :-
    (   C = (A, B)
    ->  explicar_cuerpo_is(Hs, A),
        explicar_cuerpo_is(Hs, B)
    ;   explicar_is(Hs, C)
    ).

%!  generalizar_is(+Hs:list, +G, ?GG)// is nondet.
%
%   Como generalizar//5 de ebg.pl, con la teoría pesado.
generalizar_is(Hs, G, GG) -->
    (   { predefinido_is(G) }
    ->  { ejecutar_is(G) },
        [GG]
    ;   { operacionales_is(Ops),
          functor(G, Nombre, Aridad),
          memberchk(Nombre/Aridad, Ops) }
    ->  { explicar_is(Hs, G) },
        [GG]
    ;   { regla_is(R),
          copy_term(R, (G :- Cuerpo)),
          copy_term(R, (GG :- CuerpoG)) },
        generalizar_cuerpo_is(Hs, Cuerpo, CuerpoG)
    ).

%!  generalizar_cuerpo_is(+Hs:list, +C, ?CG)// is nondet.
%
%   Generaliza cada objetivo de C junto con el de la misma posición en CG.
generalizar_cuerpo_is(Hs, C, CG) -->
    (   { C = (A, B) }
    ->  { CG = (AG, BG) },
        generalizar_cuerpo_is(Hs, A, AG),
        generalizar_cuerpo_is(Hs, B, BG)
    ;   generalizar_is(Hs, C, CG)
    ).

%!  aprender_is(+E, +Meta, -Regla) is semidet.
%
%   Regla es la regla que se aprende de la primera prueba de Meta con la
%   teoría pesado y la descripción del ejemplo E.
aprender_is(E, Meta, (General :- Condiciones)) :-
    hechos_is(E, Hs),
    functor(Meta, Nombre, Aridad),
    functor(General, Nombre, Aridad),
    once(phrase(generalizar_is(Hs, Meta, General), Condiciones)).
