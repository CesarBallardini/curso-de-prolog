:- encoding(utf8).

% Capítulo 72 - Versión 2: la planificación como búsqueda en un espacio de
% estados.
%
% Un estado es e(Pendientes, Libres, Fines): Pendientes, las tareas que
% todavía no empezaron, en orden; Libres, desde cuándo está libre cada
% procesador, de menor a mayor (los procesadores son idénticos, así que
% no importa cuál es cuál); y Fines, un par Tarea-Fin por cada tarea
% empezada. El procesador que se libera primero, en el momento T, decide
% la acción: empezar(Tarea, T, Fin) con una tarea pendiente cuyas
% predecesoras terminaron a más tardar en T, o esperar hasta el próximo
% momento en que se libera otro procesador. El costo de una acción es lo
% que aumenta la duración del calendario, el mayor de Libres, de modo que
% el costo de un plan es la duración del calendario que describe.
%
% La búsqueda es buscar/5 del capítulo 40, a través de busqueda.pl, con la
% heurística como parámetro: un predicado H(Proyecto, Estado, Estimacion).
% Esta versión trae solo cero/3, que convierte A* en la búsqueda de costo
% uniforme.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- medir(coffman, cero, D, K).
%?- ver_optimo(coffman, cero).
%?- estimacion_inicial(coffman, cero, H).

:- module(espacio,
          [ optimo/4,
            voraz/4,
            medir/4,
            medir_voraz/4,
            ver_optimo/2,
            estimacion_inicial/3,
            inicial/2,
            meta/2,
            sucesor/5,
            heuristica/3,
            cero/3
          ]).

:- reexport(tareas).
:- use_module(busqueda).
:- use_module(lista, [lista/4]).

:- meta_predicate
    optimo(+, 3, -, -),
    voraz(+, 3, -, -),
    medir(+, 3, -, -),
    medir_voraz(+, 3, -, -),
    ver_optimo(+, 3),
    estimacion_inicial(+, 3, -).

%!  optimo(+Proyecto, :Heuristica, -Calendario:list, -Expandidos:integer)
%!      is semidet.
%
%   Calendario es un calendario de duración mínima de Proyecto, hallado
%   con A* y Heuristica, si Heuristica nunca estima de más; Expandidos es
%   la cantidad de estados que expandió la búsqueda. Falla si las
%   precedencias forman un ciclo.
optimo(Proyecto, Heuristica, Calendario, Expandidos) :-
    planificar(mejor(a_estrella), Proyecto, Heuristica, Calendario,
               Expandidos).

%!  voraz(+Proyecto, :Heuristica, -Calendario:list, -Expandidos:integer)
%!      is semidet.
%
%   Calendario es el calendario de Proyecto que halla la búsqueda voraz
%   del capítulo 40: la que sigue siempre el estado de menor estimación,
%   sin mirar el costo acumulado. No tiene por qué ser óptimo.
voraz(Proyecto, Heuristica, Calendario, Expandidos) :-
    planificar(mejor(heuristica), Proyecto, Heuristica, Calendario,
               Expandidos).

%!  planificar(+Estrategia, +Proyecto, +Heuristica, -Calendario:list,
%!             -Expandidos:integer) is semidet.
%
%   Calendario es el calendario de Proyecto que halla buscar/5 con
%   Estrategia y Heuristica.
planificar(Estrategia, Proyecto, Heuristica, Calendario, Expandidos) :-
    buscar(Estrategia, problema(espacio, datos(Proyecto, Heuristica)),
           Plan, _, Expandidos),
    findall(tramo(T, I, F), member(empezar(T, I, F), Plan), Tramos),
    procesadores(Proyecto, N),
    repartir(N, Tramos, Calendario).

%!  medir(+Nombre, :Heuristica, -D:integer, -Expandidos:integer)
%!      is semidet.
%
%   D es la duración del calendario que da optimo/4 con Heuristica para
%   el proyecto de ejemplo Nombre, y Expandidos los estados expandidos.
medir(Nombre, Heuristica, D, Expandidos) :-
    ejemplo(Nombre, Proyecto),
    optimo(Proyecto, Heuristica, Calendario, Expandidos),
    duracion(Calendario, D).

%!  medir_voraz(+Nombre, :Heuristica, -D:integer, -Expandidos:integer)
%!      is semidet.
%
%   Como medir/4, con la búsqueda voraz de voraz/4.
medir_voraz(Nombre, Heuristica, D, Expandidos) :-
    ejemplo(Nombre, Proyecto),
    voraz(Proyecto, Heuristica, Calendario, Expandidos),
    duracion(Calendario, D).

%!  ver_optimo(+Nombre, :Heuristica) is semidet.
%
%   Escribe el diagrama del calendario que da optimo/4 con Heuristica
%   para el proyecto de ejemplo Nombre.
ver_optimo(Nombre, Heuristica) :-
    ejemplo(Nombre, Proyecto),
    optimo(Proyecto, Heuristica, Calendario, _),
    mostrar(Proyecto, Calendario).

%!  estimacion_inicial(+Nombre, :Heuristica, -H:integer) is semidet.
%
%   H es lo que estima Heuristica en el estado inicial del proyecto de
%   ejemplo Nombre.
estimacion_inicial(Nombre, Heuristica, H) :-
    ejemplo(Nombre, Proyecto),
    inicial(datos(Proyecto, Heuristica), Estado),
    call(Heuristica, Proyecto, Estado, H).

% --- El espacio de estados ----------------------------------------------------

%!  inicial(+Datos, -Estado) is det.
%
%   Estado tiene todas las tareas pendientes y los procesadores libres
%   desde el momento 0.
inicial(datos(Proyecto, _), e(Pendientes, Libres, [])) :-
    findall(T, tarea(Proyecto, T, _), Tareas),
    sort(Tareas, Pendientes),
    procesadores(Proyecto, N),
    length(Libres, N),
    maplist(=(0), Libres).

%!  meta(+Datos, +Estado) is semidet.
%
%   En Estado ya empezaron todas las tareas.
meta(datos(_, _), e([], _, _)).

%!  sucesor(+Datos, +Estado, -Accion, -Siguiente, -Costo:integer)
%!      is nondet.
%
%   El primer procesador libre de Estado hace Accion, que lleva a
%   Siguiente; Costo es lo que aumenta la duración del calendario.
sucesor(datos(Proyecto, _), e(Pendientes, [T|Libres], Fines), Accion,
        e(Pendientes1, Libres1, Fines1), Costo) :-
    accion(Proyecto, Pendientes, T, Libres, Fines, Accion, Pendientes1,
           Libre, Fines1),
    msort([Libre|Libres], Libres1),
    max_list([T|Libres], D0),
    max_list(Libres1, D),
    Costo is D - D0.

%!  accion(+Proyecto, +Pendientes:list, +T:integer, +Libres:list,
%!         +Fines:list, -Accion, -Pendientes1:list, -Libre:integer,
%!         -Fines1:list) is nondet.
%
%   Accion es lo que hace el procesador libre desde T; Libre es desde
%   cuándo queda libre después. Empezar una tarea lista la quita de
%   Pendientes y agrega su fin a Fines; esperar lo lleva al primer momento
%   posterior a T en que se libera otro procesador.
accion(Proyecto, Pendientes, T, _, Fines, empezar(Tarea, T, F),
       Pendientes1, F, Fines1) :-
    select(Tarea, Pendientes, Pendientes1),
    lista(Proyecto, Tarea, T, Fines),
    tarea(Proyecto, Tarea, Duracion),
    F is T + Duracion,
    msort([Tarea-F|Fines], Fines1).
accion(_, Pendientes, T, Libres, Fines, esperar(T, Hasta), Pendientes,
       Hasta, Fines) :-
    member(Hasta, Libres),
    Hasta > T,
    !.

%!  heuristica(+Datos, +Estado, -H:integer) is det.
%
%   H es lo que estima la heurística de Datos que falta desde Estado.
heuristica(datos(Proyecto, Heuristica), Estado, H) :-
    call(Heuristica, Proyecto, Estado, H).

%!  cero(+Proyecto, +Estado, -H:integer) is det.
%
%   H es 0: la heurística que no estima nada.
cero(_, _, 0).
