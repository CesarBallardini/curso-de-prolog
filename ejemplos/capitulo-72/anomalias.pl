:- encoding(utf8).

% Capítulo 72 - Las anomalías de la planificación por lista.
%
% Ronald Graham (1969) presenta un proyecto de nueve tareas y tres
% procesadores que la planificación por lista, con la lista t1, ..., t9,
% resuelve en 12 unidades, y cuatro cambios que parecen favorables y sin
% embargo alargan el calendario: otra lista, quitar dos precedencias,
% acortar todas las tareas una unidad y agregar un cuarto procesador.
% variante/3 da cada versión del proyecto con su lista, y anomalias/1
% compara la duración por lista con la óptima que halla A* con la
% heurística combinada. La anomalía es del método, no del problema: la
% duración óptima nunca crece con esos cambios.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- anomalias(Filas).
%?- ver_variante(cuatro_procesadores).

:- module(anomalias,
          [ variante/3,
            anomalias/1,
            ver_variante/1
          ]).

:- reexport(lista).
:- use_module(camino).

% duracion_graham(T, D): la tarea T del ejemplo de Graham dura D.
duracion_graham(t1, 3).
duracion_graham(t2, 2).
duracion_graham(t3, 2).
duracion_graham(t4, 2).
duracion_graham(t5, 4).
duracion_graham(t6, 4).
duracion_graham(t7, 4).
duracion_graham(t8, 4).
duracion_graham(t9, 9).

% precedencia_graham(A, B): en el ejemplo de Graham, A precede a B.
precedencia_graham(t1, t9).
precedencia_graham(t4, t5).
precedencia_graham(t4, t6).
precedencia_graham(t4, t7).
precedencia_graham(t4, t8).

%!  variante(?Nombre, -Proyecto, -Lista:list) is nondet.
%
%   Proyecto es la variante Nombre del ejemplo de Graham y Lista la
%   prioridad con que se planifica: base, el original; otra_lista, con
%   otra prioridad; sin_dos_precedencias, sin t4 antes de t5 ni t4 antes
%   de t6; mas_cortas, con cada tarea una unidad más corta; y
%   cuatro_procesadores, con un procesador más.
variante(base, proyecto(Tareas, Precedencias, 3), Lista) :-
    tareas_graham(0, Tareas),
    precedencias_graham([], Precedencias),
    lista_graham(Lista).
variante(otra_lista, proyecto(Tareas, Precedencias, 3),
         [t1, t2, t4, t5, t6, t3, t9, t7, t8]) :-
    tareas_graham(0, Tareas),
    precedencias_graham([], Precedencias).
variante(sin_dos_precedencias, proyecto(Tareas, Precedencias, 3), Lista) :-
    tareas_graham(0, Tareas),
    precedencias_graham([antes(t4, t5), antes(t4, t6)], Precedencias),
    lista_graham(Lista).
variante(mas_cortas, proyecto(Tareas, Precedencias, 3), Lista) :-
    tareas_graham(1, Tareas),
    precedencias_graham([], Precedencias),
    lista_graham(Lista).
variante(cuatro_procesadores, proyecto(Tareas, Precedencias, 4), Lista) :-
    tareas_graham(0, Tareas),
    precedencias_graham([], Precedencias),
    lista_graham(Lista).

%!  tareas_graham(+Menos:integer, -Tareas:list) is det.
%
%   Tareas son las tareas del ejemplo de Graham, cada una Menos unidades
%   más corta.
tareas_graham(Menos, Tareas) :-
    findall(tarea(T, D),
            ( duracion_graham(T, D0),
              D is D0 - Menos ),
            Tareas).

%!  precedencias_graham(+Quitar:list, -Precedencias:list) is det.
%
%   Precedencias son las del ejemplo de Graham, menos las de Quitar.
precedencias_graham(Quitar, Precedencias) :-
    findall(antes(A, B),
            ( precedencia_graham(A, B),
              \+ memberchk(antes(A, B), Quitar) ),
            Precedencias).

%!  lista_graham(-Lista:list) is det.
%
%   Lista es la prioridad original de Graham: las tareas por su número.
lista_graham(Lista) :-
    findall(T, duracion_graham(T, _), Lista).

%!  anomalias(-Filas:list) is det.
%
%   Filas tiene un término fila(Nombre, PorLista, Optima) por cada
%   variante: la duración del calendario por lista y la duración óptima.
anomalias(Filas) :-
    findall(fila(Nombre, PorLista, Optima),
            ( variante(Nombre, Proyecto, Lista),
              por_lista(Proyecto, ordenadas(Lista), C1),
              duracion(C1, PorLista),
              optimo(Proyecto, combinada, C2, _),
              duracion(C2, Optima) ),
            Filas).

%!  ver_variante(+Nombre) is semidet.
%
%   Escribe el diagrama del calendario por lista de la variante Nombre.
ver_variante(Nombre) :-
    variante(Nombre, Proyecto, Lista),
    por_lista(Proyecto, ordenadas(Lista), Calendario),
    mostrar(Proyecto, Calendario).
