:- encoding(utf8).

% Capítulo 72 - Versión 3: una heurística que reparte el trabajo.
%
% Se relaja el problema de dos maneras: se olvidan las precedencias, y una
% tarea se puede partir en pedazos que corren en procesadores distintos.
% En el problema relajado, lo que falta hacer, más lo que los procesadores
% ya tienen asignado, se reparte en partes iguales entre los N
% procesadores. Ningún calendario del problema verdadero termina antes que
% ese reparto, así que la heurística nunca estima de más. Como las
% duraciones son enteras, el reparto se redondea hacia arriba.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- estimacion_inicial(coffman, reparto, H).
%?- medir(coffman, reparto, D, K).

:- module(reparto,
          [ reparto/3
          ]).

:- reexport(espacio).

%!  reparto(+Proyecto, +Estado, -H:integer) is det.
%
%   H es cuánto le falta al calendario de Estado para llegar al reparto en
%   partes iguales de todo el trabajo, o 0 si ya lo pasó.
reparto(Proyecto, e(Pendientes, Libres, _), H) :-
    foldl(sumar_duracion(Proyecto), Pendientes, 0, Falta),
    sum_list(Libres, Asignado),
    length(Libres, N),
    max_list(Libres, D),
    Reparto is (Asignado + Falta + N - 1) // N,
    H is max(0, Reparto - D).

%!  sumar_duracion(+Proyecto, +Tarea, +S0:integer, -S:integer) is det.
%
%   S es S0 más la duración de Tarea.
sumar_duracion(Proyecto, Tarea, S0, S) :-
    tarea(Proyecto, Tarea, Duracion),
    S is S0 + Duracion.
