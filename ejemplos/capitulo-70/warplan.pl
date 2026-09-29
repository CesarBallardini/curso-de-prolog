:- encoding(utf8).

% Capítulo 70 - Versión 2: WARPLAN, que inserta la acción antes.
%
% La versión 1 solo pone la acción nueva al final del plan. Si allí no
% puede ir, porque borraría un hecho protegido o porque sus precondiciones
% no se pueden lograr, esta versión la prueba antes de la última acción
% del plan, después antes de la penúltima, y así hasta el principio. Para
% pasar una acción hacia atrás, la meta tiene que sobrevivir a esa acción,
% y los hechos protegidos se regresan a través de ella: lo que la acción
% agrega ya no hace falta protegerlo antes, y sus precondiciones sí. Es el
% planificador de David Warren (1974), con la cota de la versión 1;
% planificar_sin_cota/4 es el original, que busca en profundidad.
%
% solo-local: carga extension.pl.
%
%?- planificar(cubos, sussman, [sobre(a, b), sobre(b, c)], 6, Plan).
%?- planificar_sin_cota(cubos, sussman, [sobre(c, a), sobre(a, b)], Plan).

:- module(warplan,
          [ planificar/5,
            planificar_sin_cota/4,
            regresar/4,
            planear/9
          ]).

% Los dos mundos del capítulo se cargan con el planificador.
:- use_module(cubos, []).
:- use_module(robot, []).
:- reexport(regresion).
:- use_module(extension, [gastar/2, proteger/3, no_borra_ninguna/3,
                          inconsistente/3]).
:- use_module(library(apply)).
:- use_module(library(lists)).

%!  planificar(+Mundo, +Inicio, +Metas:list, +Maximo:integer, -Plan:list)
%!      is nondet.
%
%   Plan, en el orden en que se ejecuta, tiene a lo sumo Maximo acciones y
%   lleva desde el estado inicial Inicio del Mundo a un estado donde valen
%   todas las Metas. Los planes se dan de menor a mayor longitud.
planificar(Mundo, Inicio, Metas, Maximo, Plan) :-
    \+ inconsistente(Mundo, Metas, []),
    between(0, Maximo, N),
    planear(Mundo, Inicio, Metas, [], _, [], Hechas, N, 0),
    reverse(Hechas, Plan).

%!  planificar_sin_cota(+Mundo, +Inicio, +Metas:list, -Plan:list) is nondet.
%
%   Como planificar/5, sin cota y en profundidad, como el WARPLAN
%   original: el primer plan no es necesariamente el más corto, y la
%   búsqueda puede no terminar.
planificar_sin_cota(Mundo, Inicio, Metas, Plan) :-
    \+ inconsistente(Mundo, Metas, []),
    planear(Mundo, Inicio, Metas, [], _, [], Hechas, sin_cota, _),
    reverse(Hechas, Plan).

%!  planear(+Mundo, +Inicio, +Metas:list, +Protegidas0:list,
%!          -Protegidas:list, +Hechas0:list, -Hechas:list, +Cota0,
%!          -Cota) is nondet.
%
%   Como en la versión 1, con el lograr/9 de esta versión.
planear(_, _, [], Protegidas, Protegidas, Hechas, Hechas, Cota, Cota).
planear(Mundo, Inicio, [Meta|Metas], Protegidas0, Protegidas, Hechas0,
        Hechas, Cota0, Cota) :-
    resolver(Mundo, Inicio, Meta, Protegidas0, Protegidas1, Hechas0, Hechas1,
             Cota0, Cota1),
    planear(Mundo, Inicio, Metas, Protegidas1, Protegidas, Hechas1, Hechas,
            Cota1, Cota).

%!  resolver(+Mundo, +Inicio, +Meta, +Protegidas0:list, -Protegidas:list,
%!           +Hechas0:list, -Hechas:list, +Cota0, -Cota) is nondet.
%
%   Como en la versión 1; la acción que logra Meta se inserta con
%   lograr/9.
resolver(Mundo, _, Meta, Ps, Ps, Hechas, Hechas, Cota, Cota) :-
    Mundo:siempre(Meta).
resolver(Mundo, _, Meta, Ps, Ps, Hechas, Hechas, Cota, Cota) :-
    es_prueba(Mundo, Meta),
    call(Mundo:Meta).
resolver(Mundo, Inicio, Meta, Ps0, Ps, Hechas, Hechas, Cota, Cota) :-
    \+ es_prueba(Mundo, Meta),
    vale(Mundo, Inicio, Meta, Hechas),
    proteger(Meta, Ps0, Ps).
resolver(Mundo, Inicio, Meta, Ps, [Meta|Ps], Hechas0, Hechas, Cota0,
         Cota) :-
    \+ es_prueba(Mundo, Meta),
    gastar(Cota0, Cota1),
    Mundo:agrega(Meta, Accion),
    lograr(Mundo, Inicio, Meta, Accion, Ps, Hechas0, Hechas, Cota1, Cota).

%!  lograr(+Mundo, +Inicio, +Meta, +Accion, +Protegidas:list,
%!         +Hechas0:list, -Hechas:list, +Cota0, -Cota) is nondet.
%
%   Hechas es Hechas0 con Accion insertada, y con las acciones que logran
%   sus precondiciones antes de ella: al final del plan, o antes de la
%   última acción si esa acción no borra Meta. Accion no borra ningún
%   hecho protegido en el lugar donde queda.
lograr(Mundo, Inicio, _, Accion, Ps, Hechas0, [Accion|Hechas1], Cota0,
       Cota) :-
    no_borra_ninguna(Mundo, Accion, Ps),
    Mundo:puede(Accion, Pre),
    \+ inconsistente(Mundo, Pre, Ps),
    planear(Mundo, Inicio, Pre, Ps, _, Hechas0, Hechas1, Cota0, Cota),
    no_borra_ninguna(Mundo, Accion, Ps).
lograr(Mundo, Inicio, Meta, Accion, Ps, [Ultima|Hechas0], [Ultima|Hechas1],
       Cota0, Cota) :-
    preservada(Mundo, Meta, Ultima),
    regresar(Mundo, Ps, Ultima, Ps1),
    lograr(Mundo, Inicio, Meta, Accion, Ps1, Hechas0, Hechas1, Cota0, Cota),
    preservada(Mundo, Meta, Ultima).

%!  regresar(+Mundo, +Protegidas:list, +Accion, -Antes:list) is det.
%
%   Antes son los hechos que deben valer antes de Accion para que después
%   valgan los Protegidas: las precondiciones de Accion y los protegidos
%   que Accion no agrega.
regresar(Mundo, Ps, Accion, Antes) :-
    once(Mundo:puede(Accion, Pre)),
    exclude(agregado_o_previo(Mundo, Accion, Pre), Ps, Resto),
    append(Pre, Resto, Antes).

%!  agregado_o_previo(+Mundo, +Accion, +Pre:list, +Hecho) is semidet.
%
%   Accion agrega Hecho, o Hecho ya está entre las precondiciones Pre.
agregado_o_previo(Mundo, Accion, Pre, Hecho) :-
    (   Mundo:agrega(H, Accion),
        H == Hecho
    ->  true
    ;   member(H, Pre),
        H == Hecho
    ->  true
    ).
