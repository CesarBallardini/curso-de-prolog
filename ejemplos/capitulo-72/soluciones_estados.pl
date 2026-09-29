:- encoding(utf8).

% Capítulo 72 - Solución del ejercicio 8: estados sin lo que ya no importa.
%
% El estado de la versión 2 guarda el fin de cada tarea empezada, pero ese
% fin solo sirve mientras quede pendiente alguna sucesora de la tarea.
% Dos estados que difieren solo en fines que ya no sirven tienen los
% mismos sucesores y el mismo futuro, y la búsqueda los trata como
% distintos. Este módulo define otro problema para busqueda.pl: delega en
% el espacio de estados de la versión 2 y borra de cada estado los fines
% que ya no sirven, de modo que esos estados coinciden y los visitados
% los descartan.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- ejemplo(coffman, P), optimo_normalizado(P, cero, C, K), duracion(C, D).

:- module(soluciones_estados,
          [ optimo_normalizado/4
          ]).

:- reexport(tareas).
:- use_module(busqueda).
:- reexport(espacio, [cero/3, optimo/4]).
:- reexport(camino, [combinada/3]).

:- meta_predicate optimo_normalizado(+, 3, -, -).

%!  optimo_normalizado(+Proyecto, :Heuristica, -Calendario:list,
%!                     -Expandidos:integer) is semidet.
%
%   Como optimo/4 de la versión 2, sobre los estados normalizados.
optimo_normalizado(Proyecto, Heuristica, Calendario, Expandidos) :-
    buscar(mejor(a_estrella),
           problema(soluciones_estados, datos(Proyecto, Heuristica)),
           Plan, _, Expandidos),
    findall(tramo(T, I, F), member(empezar(T, I, F), Plan), Tramos),
    procesadores(Proyecto, N),
    repartir(N, Tramos, Calendario).

%!  inicial(+Datos, -Estado) is det.
%
%   El estado inicial de la versión 2, que no tiene fines.
inicial(Datos, Estado) :-
    espacio:inicial(Datos, Estado).

%!  meta(+Datos, +Estado) is semidet.
%
%   La meta de la versión 2.
meta(Datos, Estado) :-
    espacio:meta(Datos, Estado).

%!  sucesor(+Datos, +Estado, -Accion, -Siguiente, -Costo:integer)
%!      is nondet.
%
%   Un sucesor de la versión 2, con su estado normalizado.
sucesor(Datos, Estado, Accion, Siguiente, Costo) :-
    espacio:sucesor(Datos, Estado, Accion, Siguiente0, Costo),
    normalizar(Datos, Siguiente0, Siguiente).

%!  heuristica(+Datos, +Estado, -H:integer) is det.
%
%   La heurística de la versión 2.
heuristica(Datos, Estado, H) :-
    espacio:heuristica(Datos, Estado, H).

%!  normalizar(+Datos, +Estado0, -Estado) is det.
%
%   Estado es Estado0 sin los fines de las tareas que no tienen ninguna
%   sucesora pendiente.
normalizar(datos(Proyecto, _), e(Pendientes, Libres, Fines0),
           e(Pendientes, Libres, Fines)) :-
    include(sirve(Proyecto, Pendientes), Fines0, Fines).

%!  sirve(+Proyecto, +Pendientes:list, +Fin) is semidet.
%
%   Fin es un par Tarea-F de una tarea con alguna sucesora en Pendientes.
sirve(Proyecto, Pendientes, Tarea-_) :-
    precede(Proyecto, Tarea, Siguiente),
    memberchk(Siguiente, Pendientes),
    !.
