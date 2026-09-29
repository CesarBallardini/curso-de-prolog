:- encoding(utf8).

% Capítulo 72 - Versión 5: el planificador terminado.
%
% A* con la heurística combinada halla el calendario óptimo de los
% proyectos chicos, pero la cantidad de estados crece muy rápido con la
% cantidad de tareas. El planificador empieza por lo barato: el mejor de
% tres calendarios por lista (por el orden del proyecto, por la duración y
% por la cola de cada tarea) y la estimación de la heurística en el estado
% inicial, que es una cota inferior. Si el calendario llega a la cota, es
% óptimo y no hace falta buscar. Si no, A* busca con un límite de
% inferencias, con call_with_inference_limit/3; si lo pasa, el
% planificador devuelve el calendario por lista con la garantía de que la
% duración óptima está entre la cota y la de ese calendario.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- informe_de(coffman, 1000000).
%?- informe_de(casa, 10000).
%?- planificar_ejemplo(taller(13), 1000000, D, G).

:- module(planificador,
          [ planificar/4,
            informe/2,
            informe_de/2,
            planificar_ejemplo/4,
            cota_inferior/2,
            mejor_por_lista/2
          ]).

:- reexport(camino).
:- use_module(lista).

%!  planificar(+Proyecto, +Limite:integer, -Calendario:list, -Garantia)
%!      is semidet.
%
%   Calendario es un calendario de Proyecto. Garantia es optima(Metodo)
%   si es óptimo, con Metodo por_lista cuando el mejor calendario por
%   lista llega a la cota inferior y a_estrella cuando lo halló A* sin
%   pasar de Limite inferencias. Si A* pasa del límite, Garantia es
%   entre(Cota, D): Calendario es el mejor calendario por lista, dura D, y
%   ningún calendario dura menos que Cota. Falla si las precedencias
%   forman un ciclo.
planificar(Proyecto, Limite, Calendario, Garantia) :-
    orden_topologico(Proyecto, _),
    mejor_por_lista(Proyecto, PorLista),
    duracion(PorLista, D),
    cota_inferior(Proyecto, Cota),
    (   D =:= Cota
    ->  Calendario = PorLista,
        Garantia = optima(por_lista)
    ;   call_with_inference_limit(optimo(Proyecto, combinada, Optimo, _),
                                  Limite, Resultado),
        Resultado \== inference_limit_exceeded
    ->  Calendario = Optimo,
        Garantia = optima(a_estrella)
    ;   Calendario = PorLista,
        Garantia = entre(Cota, D)
    ).

%!  mejor_por_lista(+Proyecto, -Calendario:list) is semidet.
%
%   Calendario es el más corto de los calendarios por lista de Proyecto
%   con las prioridades orden, larga y la de mayor cola primero.
mejor_por_lista(Proyecto, Calendario) :-
    por_cola(Proyecto, Criticas),
    findall(D-C,
            ( member(Prioridad, [orden, larga, ordenadas(Criticas)]),
              por_lista(Proyecto, Prioridad, C),
              duracion(C, D) ),
            Pares),
    keysort(Pares, [_-Calendario|_]).

%!  por_cola(+Proyecto, -Tareas:list) is det.
%
%   Tareas son las tareas de Proyecto, de la de mayor cola a la de menor.
por_cola(Proyecto, Tareas) :-
    findall(C-T,
            ( tarea(Proyecto, T, _),
              cola(Proyecto, T, C) ),
            Pares0),
    sort(1, @>=, Pares0, Pares),
    pairs_values(Pares, Tareas).

%!  cota_inferior(+Proyecto, -Cota:integer) is det.
%
%   Cota es lo que estima la heurística combinada en el estado inicial:
%   ningún calendario de Proyecto dura menos.
cota_inferior(Proyecto, Cota) :-
    inicial(datos(Proyecto, combinada), Estado),
    combinada(Proyecto, Estado, Cota).

%!  informe(+Proyecto, +Limite:integer) is semidet.
%
%   Escribe el calendario que da planificar/4, su duración y su garantía.
informe(Proyecto, Limite) :-
    planificar(Proyecto, Limite, Calendario, Garantia),
    mostrar(Proyecto, Calendario),
    garantia(Garantia).

%!  informe_de(+Nombre, +Limite:integer) is semidet.
%
%   Escribe el informe de planificar/4 para el proyecto de ejemplo Nombre.
informe_de(Nombre, Limite) :-
    ejemplo(Nombre, Proyecto),
    informe(Proyecto, Limite).

%!  planificar_ejemplo(+Nombre, +Limite:integer, -D:integer, -Garantia)
%!      is semidet.
%
%   D es la duración del calendario que da planificar/4 para el proyecto
%   de ejemplo Nombre, y Garantia lo que asegura sobre ella.
planificar_ejemplo(Nombre, Limite, D, Garantia) :-
    ejemplo(Nombre, Proyecto),
    planificar(Proyecto, Limite, Calendario, Garantia),
    duracion(Calendario, D).

%!  garantia(+Garantia) is det.
%
%   Escribe lo que asegura Garantia sobre la duración.
garantia(optima(Metodo)) :-
    format("es la duración óptima (~w)~n", [Metodo]).
garantia(entre(Cota, D)) :-
    format("la duración óptima está entre ~w y ~w~n", [Cota, D]).
