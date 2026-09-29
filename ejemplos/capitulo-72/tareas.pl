:- encoding(utf8).

% Capítulo 72 - Proyecto: planificación de tareas. La representación.
%
% Un proyecto es un término proyecto(Tareas, Precedencias, Procesadores):
% Tareas es una lista de tarea(Nombre, Duracion), Precedencias una lista de
% antes(A, B), que exige que la tarea A termine antes de que empiece la B,
% y Procesadores la cantidad de procesadores idénticos. Cada procesador
% ejecuta una tarea por vez, y una tarea empezada no se interrumpe.
%
% Un calendario es una lista de asignada(Tarea, Procesador, Inicio, Fin),
% ordenada por el inicio; su duración es el mayor Fin. valido/2 verifica
% un calendario contra su proyecto sin importar cómo se obtuvo, y
% lineas/3 lo dibuja como un diagrama de Gantt, dos columnas por unidad de
% tiempo. orden_topologico/2 detecta los proyectos imposibles, cuyas
% precedencias forman un ciclo, y repartir/3 numera los procesadores de
% un calendario armado sin numerarlos. El módulo no busca nada: es lo que
% comparten todas las versiones del capítulo y el capítulo 73.
%
%?- ejemplo(coffman, P), calendario_coffman(C), valido(P, C), duracion(C, D).
%?- ejemplo(coffman, P), calendario_coffman(C), mostrar(P, C).

:- module(tareas,
          [ ejemplo/2,
            tarea/3,
            precede/3,
            procesadores/2,
            orden_topologico/2,
            valido/2,
            duracion/2,
            lineas/3,
            mostrar/2,
            repartir/3,
            calendario_coffman/1
          ]).

:- use_module(library(ugraphs)).

% --- Los proyectos ------------------------------------------------------------

%!  ejemplo(+Nombre, -Proyecto) is semidet.
%
%   Proyecto es el proyecto de ejemplo Nombre. coffman es el de Coffman y
%   Denning que usa Bratko: siete tareas y tres procesadores; casa, ocho
%   tareas de una obra con dos cuadrillas; taller(N), con N instanciado,
%   N tareas con pocas precedencias y tres procesadores, para medir cómo
%   crece la búsqueda con el tamaño.
ejemplo(coffman,
        proyecto([ tarea(t1, 4), tarea(t2, 2), tarea(t3, 2), tarea(t4, 20),
                   tarea(t5, 20), tarea(t6, 11), tarea(t7, 11) ],
                 [ antes(t1, t4), antes(t1, t5), antes(t2, t4),
                   antes(t2, t5), antes(t3, t5), antes(t3, t6),
                   antes(t3, t7) ],
                 3)).
ejemplo(casa,
        proyecto([ tarea(cimientos, 5), tarea(paredes, 8), tarea(techo, 6),
                   tarea(agua, 4), tarea(luz, 3), tarea(revoque, 5),
                   tarea(pintura, 3), tarea(aberturas, 2) ],
                 [ antes(cimientos, paredes), antes(paredes, techo),
                   antes(paredes, agua), antes(paredes, luz),
                   antes(agua, revoque), antes(luz, revoque),
                   antes(techo, revoque), antes(revoque, pintura),
                   antes(paredes, aberturas) ],
                 2)).
ejemplo(taller(N), proyecto(Tareas, Precedencias, 3)) :-
    must_be(nonneg, N),
    findall(tarea(T, D),
            ( between(1, N, I),
              atom_concat(t, I, T),
              D is 2 + (7 * I * I + 3 * I) mod 11 ),
            Tareas),
    findall(antes(A, B),
            ( between(4, N, I),
              I mod 4 =:= 0,
              J is I - 2,
              atom_concat(t, J, A),
              atom_concat(t, I, B) ),
            Precedencias).

%!  tarea(+Proyecto, ?Tarea, ?Duracion:integer) is nondet.
%
%   Tarea es una tarea de Proyecto y dura Duracion unidades de tiempo. Como
%   cada tarea aparece una sola vez, con Tarea instanciada hay a lo sumo
%   una respuesta, y memberchk/2 la da sin dejar alternativas pendientes.
tarea(proyecto(Tareas, _, _), Tarea, Duracion) :-
    (   nonvar(Tarea)
    ->  memberchk(tarea(Tarea, Duracion), Tareas)
    ;   member(tarea(Tarea, Duracion), Tareas)
    ).

%!  precede(+Proyecto, ?A, ?B) is nondet.
%
%   La tarea A de Proyecto tiene que terminar antes de que empiece la B.
precede(proyecto(_, Precedencias, _), A, B) :-
    member(antes(A, B), Precedencias).

%!  procesadores(+Proyecto, -N:integer) is det.
%
%   Proyecto dispone de N procesadores.
procesadores(proyecto(_, _, N), N).

%!  orden_topologico(+Proyecto, -Tareas:list) is semidet.
%
%   Tareas son las tareas de Proyecto en un orden en que cada una aparece
%   después de sus predecesoras. Falla si las precedencias forman un
%   ciclo: entonces el proyecto no tiene ningún calendario.
orden_topologico(Proyecto, Tareas) :-
    findall(T, tarea(Proyecto, T, _), Vertices),
    findall(A-B, precede(Proyecto, A, B), Aristas),
    vertices_edges_to_ugraph(Vertices, Aristas, Grafo),
    top_sort(Grafo, Tareas).

% --- Verificar un calendario --------------------------------------------------

%!  valido(+Proyecto, +Calendario:list) is semidet.
%
%   Calendario cumple con Proyecto: cada tarea aparece una sola vez, con su
%   duración, en un procesador que existe; ningún procesador ejecuta dos
%   tareas a la vez; y cada precedencia se respeta.
valido(Proyecto, Calendario) :-
    findall(T, tarea(Proyecto, T, _), Tareas0),
    findall(T, member(asignada(T, _, _, _), Calendario), Tareas1),
    msort(Tareas0, Tareas),
    msort(Tareas1, Tareas),
    procesadores(Proyecto, N),
    forall(member(asignada(T, P, I, F), Calendario),
           ( tarea(Proyecto, T, D),
             between(1, N, P),
             I >= 0,
             F =:= I + D )),
    \+ superpuestas(Calendario),
    forall(precede(Proyecto, A, B),
           ( memberchk(asignada(A, _, _, FinA), Calendario),
             memberchk(asignada(B, _, IniB, _), Calendario),
             FinA =< IniB )).

%!  superpuestas(+Calendario:list) is semidet.
%
%   Dos tareas distintas de Calendario ocupan el mismo procesador al mismo
%   tiempo.
superpuestas(Calendario) :-
    member(asignada(T1, P, I1, F1), Calendario),
    member(asignada(T2, P, I2, F2), Calendario),
    T1 @< T2,
    I1 < F2,
    I2 < F1,
    !.

%!  duracion(+Calendario:list, -D:integer) is det.
%
%   D es el momento en que termina la última tarea de Calendario, o 0 si
%   está vacío.
duracion(Calendario, D) :-
    foldl(mayor_fin, Calendario, 0, D).

%!  mayor_fin(+Asignada, +D0:integer, -D:integer) is det.
%
%   D es el mayor entre D0 y el fin de Asignada.
mayor_fin(asignada(_, _, _, F), D0, D) :-
    D is max(D0, F).

% --- Dibujar un calendario ----------------------------------------------------

%!  lineas(+Proyecto, +Calendario:list, -Lineas:list) is det.
%
%   Lineas son las líneas de texto del diagrama de Gantt de Calendario: una
%   por procesador, con dos columnas por unidad de tiempo. Cada tarea
%   ocupa sus columnas con su nombre seguido de guiones, y un tiempo sin
%   tarea se dibuja con puntos.
lineas(Proyecto, Calendario, Lineas) :-
    procesadores(Proyecto, N),
    numlist(1, N, Ps),
    maplist(linea(Calendario), Ps, Lineas).

%!  linea(+Calendario:list, +P:integer, -Linea:string) is det.
%
%   Linea es la línea del procesador P en el diagrama de Calendario.
linea(Calendario, P, Linea) :-
    findall(I-(T-F), member(asignada(T, P, I, F), Calendario), Tramos0),
    keysort(Tramos0, Tramos),
    tramos(Tramos, 0, Partes),
    atomic_list_concat(Partes, Texto),
    format(string(Linea), "P~w ~w", [P, Texto]).

%!  tramos(+Tramos:list, +Ahora:integer, -Partes:list) is det.
%
%   Partes son los textos de los Tramos de un procesador desde el momento
%   Ahora: puntos por cada espera y el nombre de cada tarea.
tramos([], _, []).
tramos([I-(T-F)|Tramos], Ahora, [Espera, Tarea|Partes]) :-
    Puntos is 2 * (I - Ahora),
    relleno(Puntos, '.', Espera),
    Ancho is 2 * (F - I),
    atom_length(T, Largo),
    Guiones is max(0, Ancho - Largo),
    relleno(Guiones, '-', Resto),
    atom_concat(T, Resto, Tarea),
    tramos(Tramos, F, Partes).

%!  relleno(+N:integer, +Caracter, -Atomo) is det.
%
%   Atomo tiene N veces Caracter.
relleno(N, Caracter, Atomo) :-
    length(Cs, N),
    maplist(=(Caracter), Cs),
    atom_chars(Atomo, Cs).

%!  mostrar(+Proyecto, +Calendario:list) is det.
%
%   Escribe el diagrama de Gantt de Calendario y su duración.
mostrar(Proyecto, Calendario) :-
    lineas(Proyecto, Calendario, Lineas),
    forall(member(L, Lineas), format("~s~n", [L])),
    duracion(Calendario, D),
    format("duración: ~w~n", [D]).

% calendario_coffman(C): un calendario óptimo del proyecto coffman, con
% duración 24, escrito a mano para probar valido/2 y lineas/3.
calendario_coffman([ asignada(t1, 1, 0, 4), asignada(t2, 2, 0, 2),
                     asignada(t3, 3, 0, 2), asignada(t7, 3, 2, 13),
                     asignada(t4, 2, 4, 24), asignada(t5, 1, 4, 24),
                     asignada(t6, 3, 13, 24) ]).

% --- De los tramos al calendario ----------------------------------------------

%!  repartir(+N:integer, +Tramos:list, -Calendario:list) is semidet.
%
%   Calendario asigna a uno de N procesadores cada tramo(Tarea, Inicio,
%   Fin) de Tramos: los tramos se toman por su inicio, y cada uno va al
%   procesador de menor número que está libre en ese momento. Falla si en
%   algún momento hay más de N tramos a la vez.
repartir(N, Tramos, Calendario) :-
    maplist(por_inicio, Tramos, Pares0),
    keysort(Pares0, Pares),
    pairs_values(Pares, Ordenados),
    length(Libres, N),
    maplist(=(0), Libres),
    foldl(ubicar, Ordenados, Calendario, Libres, _).

%!  por_inicio(+Tramo, -Par) is det.
%
%   Par es Tramo con su inicio como clave.
por_inicio(tramo(T, I, F), I-tramo(T, I, F)).

%!  ubicar(+Tramo, -Asignada, +Libres0:list, -Libres:list) is semidet.
%
%   Asignada pone Tramo en el primer procesador libre en su inicio;
%   Libres0 da, para cada procesador, desde cuándo está libre.
ubicar(tramo(T, I, F), asignada(T, P, I, F), Libres0, Libres) :-
    nth1(P, Libres0, Libre, Resto),
    Libre =< I,
    !,
    nth1(P, Libres, F, Resto).
