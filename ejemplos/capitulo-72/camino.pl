:- encoding(utf8).

% Capítulo 72 - Versión 4: el camino crítico.
%
% La cola de una tarea es su duración más la mayor cola de las tareas que
% la esperan: el tiempo mínimo que pasa desde que la tarea empieza hasta
% que termina la última de sus sucesoras, aunque sobren procesadores. Una
% tarea pendiente no puede empezar antes de que se libere el primer
% procesador ni antes de que terminen sus predecesoras ya empezadas; desde
% ese momento, su cola es una cota inferior de lo que falta. camino/3 es la
% mayor de esas cotas, y combinada/3 el máximo entre ella y el reparto de la
% versión 3: el máximo de dos heurísticas que nunca estiman de más tampoco
% estima de más, y es al menos tan bueno como cada una.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- colas(coffman, Colas).
%?- medir(coffman, combinada, D, K).

:- module(camino,
          [ cola/3,
            colas/2,
            camino/3,
            combinada/3
          ]).

:- reexport(reparto).

%!  cola(+Proyecto, +Tarea, -Cola:integer) is det.
%
%   Cola es la duración de Tarea más la mayor cola de sus sucesoras en
%   Proyecto, o solo su duración si no tiene sucesoras. Las precedencias
%   de Proyecto no pueden formar un ciclo: si lo forman, no termina.
cola(Proyecto, Tarea, Cola) :-
    tarea(Proyecto, Tarea, Duracion),
    findall(C,
            ( precede(Proyecto, Tarea, Siguiente),
              cola(Proyecto, Siguiente, C) ),
            Colas),
    max_list([0|Colas], Mayor),
    Cola is Duracion + Mayor.

%!  colas(+Nombre, -Colas:list) is semidet.
%
%   Colas tiene un par Tarea-Cola por cada tarea del proyecto de ejemplo
%   Nombre, en el orden del proyecto.
colas(Nombre, Colas) :-
    ejemplo(Nombre, Proyecto),
    findall(T-C, ( tarea(Proyecto, T, _), cola(Proyecto, T, C) ), Colas).

%!  camino(+Proyecto, +Estado, -H:integer) is det.
%
%   H es cuánto le falta al calendario de Estado para que termine la tarea
%   pendiente de mayor cola, empezada lo antes posible, o 0 si nada falta.
camino(Proyecto, e(Pendientes, [Primero|Libres], Fines), H) :-
    max_list([Primero|Libres], D),
    findall(Fin,
            ( member(Tarea, Pendientes),
              inicio_minimo(Proyecto, Tarea, Primero, Fines, Inicio),
              cola(Proyecto, Tarea, Cola),
              Fin is Inicio + Cola ),
            Finales),
    max_list([D|Finales], Mayor),
    H is Mayor - D.

%!  inicio_minimo(+Proyecto, +Tarea, +Primero:integer, +Fines:list,
%!                -Inicio:integer) is det.
%
%   Inicio es el mayor entre Primero y el fin de cada predecesora de Tarea
%   que ya empezó.
inicio_minimo(Proyecto, Tarea, Primero, Fines, Inicio) :-
    findall(F,
            ( precede(Proyecto, Antes, Tarea),
              memberchk(Antes-F, Fines) ),
            Fs),
    max_list([Primero|Fs], Inicio).

%!  combinada(+Proyecto, +Estado, -H:integer) is det.
%
%   H es la mayor de las estimaciones de reparto/3 y camino/3.
combinada(Proyecto, Estado, H) :-
    reparto(Proyecto, Estado, H1),
    camino(Proyecto, Estado, H2),
    H is max(H1, H2).
