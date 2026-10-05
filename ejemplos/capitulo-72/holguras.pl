:- encoding(utf8).

% Capítulo 72 - Fechas tempranas, fechas tardías y holguras.
%
% El método del camino crítico supone procesadores de sobra y calcula, en
% dos pasadas sobre el orden topológico de las tareas, la fecha temprana
% de cada una (lo antes que puede empezar), la duración mínima del
% proyecto y la fecha tardía (lo más tarde que puede empezar sin demorar
% ese final). La diferencia es la holgura: cuánto puede demorarse una
% tarea sin demorar el proyecto. Las tareas de holgura 0 forman el camino
% crítico. Cada pasada examina cada tarea y cada precedencia una sola vez.
%
% solo-local: carga tareas.pl, y SWISH no permite cargar otro archivo.
%
%?- fechas_de(casa, Fechas, Largo).
%?- holguras_de(coffman, Holguras).

:- module(holguras,
          [ fechas/3,
            holguras/2,
            camino_critico/2,
            fechas_de/3,
            holguras_de/2
          ]).

:- reexport(tareas).
:- use_module(library(assoc)).

%!  fechas(+Proyecto, -Fechas:list, -Largo:integer) is semidet.
%
%   Fechas tiene un término fechas(Tarea, Temprana, Tardia) por cada tarea
%   de Proyecto, en orden topológico, y Largo es la duración mínima del
%   proyecto con procesadores de sobra. Falla si las precedencias forman
%   un ciclo.
fechas(Proyecto, Fechas, Largo) :-
    orden_topologico(Proyecto, Orden),
    empty_assoc(Vacio),
    foldl(temprana(Proyecto), Orden, Vacio, Tempranas),
    foldl(mayor_fin(Proyecto, Tempranas), Orden, 0, Largo),
    reverse(Orden, Inverso),
    foldl(tardia(Proyecto, Largo), Inverso, Vacio, Tardias),
    findall(fechas(T, I, J),
            ( member(T, Orden),
              get_assoc(T, Tempranas, I),
              get_assoc(T, Tardias, J) ),
            Fechas).

%!  temprana(+Proyecto, +Tarea, +Tempranas0, -Tempranas) is det.
%
%   Tempranas es Tempranas0 con la fecha temprana de Tarea: el mayor fin
%   temprano de sus predecesoras, o 0 si no tiene. Tempranas0 ya tiene la
%   fecha de cada predecesora.
temprana(Proyecto, Tarea, Tempranas0, Tempranas) :-
    findall(F,
            ( precede(Proyecto, Antes, Tarea),
              get_assoc(Antes, Tempranas0, I),
              tarea(Proyecto, Antes, D),
              F is I + D ),
            Fines),
    max_list([0|Fines], Inicio),
    put_assoc(Tarea, Tempranas0, Inicio, Tempranas).

%!  mayor_fin(+Proyecto, +Tempranas, +Tarea, +L0:integer, -L:integer)
%!      is det.
%
%   L es el mayor entre L0 y el fin temprano de Tarea.
mayor_fin(Proyecto, Tempranas, Tarea, L0, L) :-
    get_assoc(Tarea, Tempranas, I),
    tarea(Proyecto, Tarea, D),
    L is max(L0, I + D).

%!  tardia(+Proyecto, +Largo:integer, +Tarea, +Tardias0, -Tardias) is det.
%
%   Tardias es Tardias0 con la fecha tardía de Tarea: la menor fecha
%   tardía de sus sucesoras, o Largo si no tiene, menos su duración.
%   Tardias0 ya tiene la fecha de cada sucesora.
tardia(Proyecto, Largo, Tarea, Tardias0, Tardias) :-
    findall(J,
            ( precede(Proyecto, Tarea, Despues),
              get_assoc(Despues, Tardias0, J) ),
            Inicios),
    min_list([Largo|Inicios], Fin),
    tarea(Proyecto, Tarea, D),
    Inicio is Fin - D,
    put_assoc(Tarea, Tardias0, Inicio, Tardias).

%!  holguras(+Proyecto, -Holguras:list) is semidet.
%
%   Holguras tiene un par Tarea-Holgura por cada tarea de Proyecto, en
%   orden topológico: cuánto puede demorarse la tarea sin demorar el final
%   del proyecto, con procesadores de sobra.
holguras(Proyecto, Holguras) :-
    fechas(Proyecto, Fechas, _),
    findall(T-H,
            ( member(fechas(T, I, J), Fechas),
              H is J - I ),
            Holguras).

%!  camino_critico(+Proyecto, -Tareas:list) is semidet.
%
%   Tareas son las tareas de Proyecto con holgura 0, en orden topológico.
camino_critico(Proyecto, Tareas) :-
    holguras(Proyecto, Holguras),
    findall(T, member(T-0, Holguras), Tareas).

%!  fechas_de(+Nombre, -Fechas:list, -Largo:integer) is semidet.
%
%   Como fechas/3, para el proyecto de ejemplo Nombre.
fechas_de(Nombre, Fechas, Largo) :-
    ejemplo(Nombre, Proyecto),
    fechas(Proyecto, Fechas, Largo).

%!  holguras_de(+Nombre, -Holguras:list) is semidet.
%
%   Como holguras/2, para el proyecto de ejemplo Nombre.
holguras_de(Nombre, Holguras) :-
    ejemplo(Nombre, Proyecto),
    holguras(Proyecto, Holguras).
