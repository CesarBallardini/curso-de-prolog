:- encoding(utf8).

% Capítulo 70 - Planes condicionales por casos.
%
% Warren (1976) extendió WARPLAN para generar planes condicionales: planes
% que, en un punto, examinan un hecho del mundo y siguen por una rama u
% otra. Esta versión, mucho más simple, recibe varios estados iniciales
% posibles y construye un plan que sirve para todos: si un mismo plan de
% WARPLAN logra las metas desde cada uno, ese es el plan; si no, elige un
% hecho que vale en algunos estados y no en otros, y arma un plan
% si(Hecho, PlanSi, PlanNo) con un plan para cada grupo. El hecho se
% examina antes de la primera acción.
%
% solo-local: carga warplan.pl.
%
%?- planificar_casos(dudoso, [c_sobre_a, c_sobre_b], [libre(a)], 4, P).

:- module(condicional,
          [ planificar_casos/5,
            ejecutar_casos/4
          ]).

:- use_module(warplan, [planificar/5, logra/4]).
:- use_module(library(lists)).
:- use_module(library(apply)).

%!  planificar_casos(+Mundo, +Inicios:list, +Metas:list, +Maximo:integer,
%!                   -Plan) is semidet.
%
%   Plan logra las Metas desde cada uno de los estados iniciales Inicios
%   del Mundo. Es una lista de acciones, o si(Hecho, PlanSi, PlanNo): un
%   examen de Hecho en el estado inicial, seguido de PlanSi si vale y de
%   PlanNo si no vale. Cada lista tiene a lo sumo Maximo acciones.
planificar_casos(Mundo, [Inicio|Inicios], Metas, Maximo, Plan) :-
    once(planificar(Mundo, Inicio, Metas, Maximo, Plan0)),
    forall(member(I, Inicios), logra(Mundo, I, Plan0, Metas)),
    !,
    Plan = Plan0.
planificar_casos(Mundo, Inicios, Metas, Maximo,
                 si(Hecho, PlanSi, PlanNo)) :-
    distinguidor(Mundo, Inicios, Hecho),
    partition(vale_al_inicio(Mundo, Hecho), Inicios, Si, No),
    planificar_casos(Mundo, Si, Metas, Maximo, PlanSi),
    planificar_casos(Mundo, No, Metas, Maximo, PlanNo).

%!  distinguidor(+Mundo, +Inicios:list, -Hecho) is semidet.
%
%   Hecho vale en algunos de los estados Inicios y no en otros: el primero
%   en el orden estándar de términos.
distinguidor(Mundo, Inicios, Hecho) :-
    findall(H, ( member(I, Inicios), Mundo:dado(I, H) ), Hs0),
    sort(Hs0, Hs),
    member(Hecho, Hs),
    \+ forall(member(I, Inicios), Mundo:dado(I, Hecho)),
    !.

%!  vale_al_inicio(+Mundo, +Hecho, +Inicio) is semidet.
%
%   Hecho vale en el estado inicial Inicio del Mundo.
vale_al_inicio(Mundo, Hecho, Inicio) :-
    once(Mundo:dado(Inicio, Hecho)).

%!  ejecutar_casos(+Mundo, +Inicio, +Plan, -Acciones:list) is det.
%
%   Acciones son las acciones que Plan ejecuta desde el estado inicial
%   Inicio del Mundo: en cada si/3, la rama que corresponde a ese estado.
ejecutar_casos(_, _, Plan, Plan) :-
    is_list(Plan),
    !.
ejecutar_casos(Mundo, Inicio, si(Hecho, PlanSi, PlanNo), Acciones) :-
    (   vale_al_inicio(Mundo, Hecho, Inicio)
    ->  ejecutar_casos(Mundo, Inicio, PlanSi, Acciones)
    ;   ejecutar_casos(Mundo, Inicio, PlanNo, Acciones)
    ).
