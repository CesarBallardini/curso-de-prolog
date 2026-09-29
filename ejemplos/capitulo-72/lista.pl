:- encoding(utf8).

% Capítulo 72 - Versión 1: la planificación por lista.
%
% Las tareas se ordenan una sola vez según una prioridad, y el calendario
% se arma sin volver atrás: el procesador que se libera primero toma la
% primera tarea de la lista que está lista, es decir, cuyas predecesoras
% ya terminaron; si ninguna lo está, espera hasta que se libere otro
% procesador. Hay dos prioridades: orden, el orden en que el proyecto
% enumera sus tareas, y larga, la de mayor duración primero; con
% ordenadas(Lista), la lista la da quien llama. El resultado
% es un calendario válido, pero nada asegura que sea el más corto.
%
% solo-local: carga tareas.pl, y SWISH no permite cargar otro archivo.
%
%?- medir_lista(coffman, orden, D).
%?- ver_lista(coffman, orden).

:- module(lista,
          [ por_lista/3,
            medir_lista/3,
            ver_lista/2,
            lista/4
          ]).

:- reexport(tareas).

%!  por_lista(+Proyecto, +Prioridad, -Calendario:list) is semidet.
%
%   Calendario es el calendario de Proyecto que arma la planificación por
%   lista con Prioridad: orden, larga u ordenadas(Lista), con Lista una
%   permutación de las tareas. Falla si las precedencias forman un ciclo.
por_lista(Proyecto, Prioridad, Calendario) :-
    prioridad(Prioridad, Proyecto, Lista),
    procesadores(Proyecto, N),
    length(Libres, N),
    maplist(=(0), Libres),
    armar(Proyecto, Lista, Libres, [], Tramos),
    repartir(N, Tramos, Calendario).

%!  medir_lista(+Nombre, +Prioridad, -D:integer) is semidet.
%
%   D es la duración del calendario por lista con Prioridad del proyecto
%   de ejemplo Nombre.
medir_lista(Nombre, Prioridad, D) :-
    ejemplo(Nombre, Proyecto),
    por_lista(Proyecto, Prioridad, Calendario),
    duracion(Calendario, D).

%!  ver_lista(+Nombre, +Prioridad) is semidet.
%
%   Escribe el diagrama del calendario por lista con Prioridad del
%   proyecto de ejemplo Nombre.
ver_lista(Nombre, Prioridad) :-
    ejemplo(Nombre, Proyecto),
    por_lista(Proyecto, Prioridad, Calendario),
    mostrar(Proyecto, Calendario).

%!  prioridad(+Prioridad, +Proyecto, -Lista:list) is det.
%
%   Lista son las tareas de Proyecto en el orden de Prioridad.
prioridad(orden, Proyecto, Lista) :-
    findall(T, tarea(Proyecto, T, _), Lista).
prioridad(larga, Proyecto, Lista) :-
    findall(D-T, tarea(Proyecto, T, D), Pares0),
    sort(1, @>=, Pares0, Pares),
    pairs_values(Pares, Lista).
prioridad(ordenadas(Lista), _, Lista).

%!  armar(+Proyecto, +Pendientes:list, +Libres:list, +Fines:list,
%!        -Tramos:list) is semidet.
%
%   Tramos son los tramos de las tareas Pendientes, cuando cada procesador
%   está libre desde el momento que da Libres, ordenada de menor a mayor,
%   y Fines da el fin de cada tarea ya empezada.
armar(_, [], _, _, []) :-
    !.
armar(Proyecto, Pendientes, [T|Libres], Fines, Tramos) :-
    (   member(Tarea, Pendientes),
        lista(Proyecto, Tarea, T, Fines)
    ->  selectchk(Tarea, Pendientes, Pendientes1),
        tarea(Proyecto, Tarea, Duracion),
        F is T + Duracion,
        Tramos = [tramo(Tarea, T, F)|Tramos1],
        msort([F|Libres], Libres1),
        armar(Proyecto, Pendientes1, Libres1, [Tarea-F|Fines], Tramos1)
    ;   member(Hasta, Libres),
        Hasta > T
    ->  msort([Hasta|Libres], Libres1),
        armar(Proyecto, Pendientes, Libres1, Fines, Tramos)
    ).

%!  lista(+Proyecto, +Tarea, +T:integer, +Fines:list) is semidet.
%
%   Cada predecesora de Tarea empezó y terminó a más tardar en T; Fines
%   tiene un par Tarea-Fin por cada tarea empezada.
lista(Proyecto, Tarea, T, Fines) :-
    forall(precede(Proyecto, Antes, Tarea),
           ( memberchk(Antes-F, Fines),
             F =< T )).
