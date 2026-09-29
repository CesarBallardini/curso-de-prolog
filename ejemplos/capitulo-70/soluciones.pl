:- encoding(utf8).

% Capítulo 70 - Soluciones de los ejercicios 6, 8 y 10.
%
% planificar_techo/5 hace una sola búsqueda en profundidad con la cota
% como techo, sin profundización. estado_final/4 calcula por regresión
% todos los hechos que valen después de un plan. Los mundos de los otros
% ejercicios están en soluciones_cubos.pl, soluciones_robot.pl y
% soluciones_pinza.pl; este archivo los carga.
%
% solo-local: carga warplan.pl y los mundos de las soluciones.
%
%?- planificar_techo(cubos, sussman, [sobre(b, c), sobre(a, b)], 6, Plan).
%?- estado_final(cubos, sussman, [mover(c, a, mesa)], Estado).

:- module(soluciones,
          [ planificar_techo/5,
            estado_final/4
          ]).

:- reexport(warplan).
:- reexport(regresion).
:- use_module(soluciones_cubos, []).
:- use_module(soluciones_robot, []).
:- use_module(soluciones_pinza, []).
:- use_module(library(lists)).

%!  planificar_techo(+Mundo, +Inicio, +Metas:list, +Maximo:integer,
%!                   -Plan:list) is nondet.
%
%   Plan tiene a lo sumo Maximo acciones y logra las Metas. La búsqueda es
%   una sola, en profundidad, con Maximo como techo: termina, pero el
%   primer plan no es necesariamente el más corto.
planificar_techo(Mundo, Inicio, Metas, Maximo, Plan) :-
    planear(Mundo, Inicio, Metas, [], _, [], Hechas, Maximo, _),
    reverse(Hechas, Plan).

%!  estado_final(+Mundo, +Inicio, +Plan:list, -Estado:list) is det.
%
%   Estado es el conjunto ordenado de los hechos que valen después de
%   ejecutar Plan, en el orden en que se ejecuta, desde Inicio.
estado_final(Mundo, Inicio, Plan, Estado) :-
    reverse(Plan, Hechas),
    findall(H, vale(Mundo, Inicio, H, Hechas), Hs),
    sort(Hs, Estado).
