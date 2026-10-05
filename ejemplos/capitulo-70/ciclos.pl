:- encoding(utf8).

% Capítulo 70 - WARPLAN con control de ciclos.
%
% Es una de las mejoras que Warren propone en la sección «Deficiencies of
% the system» de su memo de 1974: una meta que ya se está logrando más
% arriba en la cadena de precondiciones no se vuelve a intentar con una
% acción. La cadena «liberar c, poner algo sobre c, liberar c» se corta en
% la segunda aparición de libre(c), y la búsqueda sin cota termina en los
% dos órdenes de la anomalía.
%
% solo-local: carga warplan.pl.
%
%?- planificar_sin_ciclos(cubos, sussman, [sobre(b, c), sobre(a, b)], Plan).

:- module(ciclos,
          [ planificar_sin_ciclos/4
          ]).

:- use_module(warplan, [regresar/4]).
:- use_module(regresion, [vale/4, preservada/3, es_prueba/2]).
:- use_module(extension, [proteger/3, no_borra_ninguna/3, inconsistente/3]).
:- use_module(library(lists)).

%!  planificar_sin_ciclos(+Mundo, +Inicio, +Metas:list, -Plan:list) is nondet.
%
%   Plan lleva desde el estado inicial Inicio del Mundo a un estado donde
%   valen todas las Metas. La búsqueda es en profundidad y sin cota, como
%   la de planificar_sin_cota/4, pero no intenta lograr con una acción una
%   meta que ya se está logrando en la cadena de precondiciones.
planificar_sin_ciclos(Mundo, Inicio, Metas, Plan) :-
    \+ inconsistente(Mundo, Metas, []),
    planear(Mundo, Inicio, Metas, [], [], _, [], Hechas),
    reverse(Hechas, Plan).

%!  planear(+Mundo, +Inicio, +Metas:list, +Cadena:list, +Protegidas0:list,
%!          -Protegidas:list, +Hechas0:list, -Hechas:list) is nondet.
%
%   Como planear/9 de warplan.pl, sin cota y con la Cadena de metas que se
%   están logrando por encima de estas.
planear(_, _, [], _, Ps, Ps, Hechas, Hechas).
planear(Mundo, Inicio, [Meta|Metas], Cadena, Ps0, Ps, Hechas0, Hechas) :-
    resolver(Mundo, Inicio, Meta, Cadena, Ps0, Ps1, Hechas0, Hechas1),
    planear(Mundo, Inicio, Metas, Cadena, Ps1, Ps, Hechas1, Hechas).

%!  resolver(+Mundo, +Inicio, +Meta, +Cadena:list, +Protegidas0:list,
%!           -Protegidas:list, +Hechas0:list, -Hechas:list) is nondet.
%
%   Como resolver/9 de warplan.pl. La última cláusula, la que elige una
%   acción, no se aplica si Meta es una variante de una meta de la Cadena.
resolver(Mundo, _, Meta, _, Ps, Ps, Hechas, Hechas) :-
    Mundo:siempre(Meta).
resolver(Mundo, _, Meta, _, Ps, Ps, Hechas, Hechas) :-
    es_prueba(Mundo, Meta),
    call(Mundo:Meta).
resolver(Mundo, Inicio, Meta, _, Ps0, Ps, Hechas, Hechas) :-
    \+ es_prueba(Mundo, Meta),
    vale(Mundo, Inicio, Meta, Hechas),
    proteger(Meta, Ps0, Ps).
resolver(Mundo, Inicio, Meta, Cadena, Ps, [Meta|Ps], Hechas0, Hechas) :-
    \+ es_prueba(Mundo, Meta),
    \+ ( member(M, Cadena), M =@= Meta ),
    Mundo:agrega(Meta, Accion),
    lograr(Mundo, Inicio, Meta, Accion, [Meta|Cadena], Ps, Hechas0, Hechas).

%!  lograr(+Mundo, +Inicio, +Meta, +Accion, +Cadena:list, +Protegidas:list,
%!         +Hechas0:list, -Hechas:list) is nondet.
%
%   Como lograr/9 de warplan.pl: Accion al final del plan, o antes de la
%   última acción si esa acción no borra Meta.
lograr(Mundo, Inicio, _, Accion, Cadena, Ps, Hechas0, [Accion|Hechas1]) :-
    no_borra_ninguna(Mundo, Accion, Ps),
    Mundo:puede(Accion, Pre),
    \+ inconsistente(Mundo, Pre, Ps),
    planear(Mundo, Inicio, Pre, Cadena, Ps, _, Hechas0, Hechas1),
    no_borra_ninguna(Mundo, Accion, Ps).
lograr(Mundo, Inicio, Meta, Accion, Cadena, Ps, [Ultima|Hechas0],
       [Ultima|Hechas1]) :-
    preservada(Mundo, Meta, Ultima),
    regresar(Mundo, Ps, Ultima, Ps1),
    lograr(Mundo, Inicio, Meta, Accion, Cadena, Ps1, Hechas0, Hechas1),
    preservada(Mundo, Meta, Ultima).
