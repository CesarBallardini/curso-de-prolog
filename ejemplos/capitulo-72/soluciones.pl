:- encoding(utf8).

% Capítulo 72 - Soluciones de los ejercicios.
%
% Carga el planificador terminado (que reexporta las versiones 2 a 4 y la
% representación), la planificación por lista y la búsqueda del capítulo
% 40, sin modificarlos. La solución del ejercicio 8, que define otro
% espacio de estados, está en soluciones_estados.pl.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- ejemplo(casa, P0), con_procesadores(P0, 3, P), cota_inferior(P, B).
%?- ejemplo(coffman, P), mejor_de_todas(P, D).
%?- ejemplo(coffman, P), criticas(P, Ts).

:- module(soluciones,
          [ con_procesadores/3,
            curva/3,
            mejor_de_todas/2,
            cabeza/3,
            criticas/2,
            suma/3,
            comparar_voraz/2,
            optimo_ida/4,
            regla/2,
            mostrar_con_regla/2,
            errores/2
          ]).

:- reexport(planificador).
:- use_module(lista).
:- use_module(busqueda).

% --- Ejercicios 1 y 7 ---------------------------------------------------------

%!  con_procesadores(+Proyecto0, +N:integer, -Proyecto) is det.
%
%   Proyecto tiene las tareas y las precedencias de Proyecto0, con N
%   procesadores.
con_procesadores(proyecto(Tareas, Precedencias, _), N,
                 proyecto(Tareas, Precedencias, N)).

%!  curva(+Proyecto, +Ns:list, -Duraciones:list) is det.
%
%   Duraciones tiene, para cada cantidad de procesadores N de Ns, un par
%   N-D con la duración óptima D de Proyecto con N procesadores.
curva(Proyecto, Ns, Duraciones) :-
    maplist(duracion_con(Proyecto), Ns, Duraciones).

%!  duracion_con(+Proyecto, +N:integer, -Par) is det.
%
%   Par es N-D, con D la duración óptima de Proyecto con N procesadores.
duracion_con(Proyecto0, N, N-D) :-
    con_procesadores(Proyecto0, N, Proyecto),
    optimo(Proyecto, combinada, C, _),
    duracion(C, D).

% --- Ejercicio 2 --------------------------------------------------------------

%!  mejor_de_todas(+Proyecto, -D:integer) is det.
%
%   D es la menor duración que da la planificación por lista de Proyecto
%   entre todas las prioridades posibles: una por cada permutación de las
%   tareas.
mejor_de_todas(Proyecto, D) :-
    findall(T, tarea(Proyecto, T, _), Tareas),
    aggregate_all(min(D0),
                  ( permutation(Tareas, Lista),
                    por_lista(Proyecto, ordenadas(Lista), C),
                    duracion(C, D0) ),
                  D).

% --- Ejercicio 3 --------------------------------------------------------------

%!  cabeza(+Proyecto, +Tarea, -Cabeza:integer) is det.
%
%   Cabeza es el momento más temprano en que puede empezar Tarea si sobran
%   procesadores: 0 si no tiene predecesoras y, si las tiene, el mayor fin
%   más temprano de ellas.
cabeza(Proyecto, Tarea, Cabeza) :-
    findall(F,
            ( precede(Proyecto, Antes, Tarea),
              cabeza(Proyecto, Antes, C),
              tarea(Proyecto, Antes, D),
              F is C + D ),
            Fines),
    max_list([0|Fines], Cabeza).

%!  criticas(+Proyecto, -Tareas:list) is det.
%
%   Tareas son las tareas críticas de Proyecto: aquellas cuya cabeza más
%   cola es la mayor cola del proyecto, de modo que demorar cualquiera de
%   ellas demora el final aunque sobren procesadores.
criticas(Proyecto, Tareas) :-
    findall(C, ( tarea(Proyecto, T, _), cola(Proyecto, T, C) ), Colas),
    max_list(Colas, Largo),
    findall(T,
            ( tarea(Proyecto, T, _),
              cabeza(Proyecto, T, Cabeza),
              cola(Proyecto, T, Cola),
              Cabeza + Cola =:= Largo ),
            Tareas).

% --- Ejercicio 4 --------------------------------------------------------------

%!  suma(+Proyecto, +Estado, -H:integer) is det.
%
%   H es la suma de las duraciones de las tareas pendientes de Estado: una
%   heurística que estima de más, porque ignora que las tareas corren en
%   paralelo.
suma(Proyecto, e(Pendientes, _, _), H) :-
    foldl(sumar(Proyecto), Pendientes, 0, H).

%!  sumar(+Proyecto, +Tarea, +S0:integer, -S:integer) is det.
%
%   S es S0 más la duración de Tarea.
sumar(Proyecto, Tarea, S0, S) :-
    tarea(Proyecto, Tarea, D),
    S is S0 + D.

% --- Ejercicio 5 --------------------------------------------------------------

%!  comparar_voraz(+Ns:list, -Filas:list) is det.
%
%   Filas tiene, para cada N de Ns, un término
%   N-voraz(D1, K1)-optimo(D2, K2) con la duración y los estados
%   expandidos de la búsqueda voraz y de A* sobre taller(N), las dos con
%   la heurística combinada.
comparar_voraz(Ns, Filas) :-
    maplist(fila_voraz, Ns, Filas).

%!  fila_voraz(+N:integer, -Fila) is det.
%
%   Fila compara la búsqueda voraz con A* sobre taller(N).
fila_voraz(N, N-voraz(D1, K1)-optimo(D2, K2)) :-
    ejemplo(taller(N), P),
    voraz(P, combinada, C1, K1),
    duracion(C1, D1),
    optimo(P, combinada, C2, K2),
    duracion(C2, D2).

% --- Ejercicio 6 --------------------------------------------------------------

%!  optimo_ida(+Proyecto, +Heuristica, -D:integer, -Expandidos:integer)
%!      is semidet.
%
%   D es la duración óptima de Proyecto según IDA* del capítulo 40, con
%   Heuristica, el nombre de un predicado visible en este módulo;
%   Expandidos cuenta los estados expandidos en todas las iteraciones.
optimo_ida(Proyecto, Heuristica, D, Expandidos) :-
    ida_estrella(problema(espacio, datos(Proyecto, soluciones:Heuristica)),
                 _, D, Expandidos).

% --- Ejercicio 9 --------------------------------------------------------------

%!  regla(+D:integer, -Linea:string) is det.
%
%   Linea es la regla de un diagrama de duración D: el número de cada
%   múltiplo de 5 hasta D, en la columna de ese momento. Los diagramas de
%   lineas/3 empiezan después de tres columnas y usan dos por unidad.
regla(D, Linea) :-
    Ultima is D - D mod 5,
    numlist(0, Ultima, Momentos),
    include(multiplo_de_5, Momentos, Marcas),
    foldl(marca, Marcas, "   ", Linea).

%!  multiplo_de_5(+N:integer) is semidet.
%
%   N es múltiplo de 5.
multiplo_de_5(N) :-
    N mod 5 =:= 0.

%!  marca(+T:integer, +Linea0:string, -Linea:string) is det.
%
%   Linea es Linea0 completada con blancos hasta la columna del momento T,
%   seguida del número T.
marca(T, Linea0, Linea) :-
    Columna is 3 + 2 * T,
    string_length(Linea0, Largo),
    Blancos is max(0, Columna - Largo),
    format(string(Linea), "~s~*c~w", [Linea0, Blancos, 0'\s, T]).

%!  mostrar_con_regla(+Proyecto, +Calendario:list) is det.
%
%   Escribe la regla, el diagrama de Gantt de Calendario y su duración.
mostrar_con_regla(Proyecto, Calendario) :-
    duracion(Calendario, D),
    regla(D, Regla),
    format("~s~n", [Regla]),
    mostrar(Proyecto, Calendario).

% --- Ejercicio 10 -------------------------------------------------------------

%!  errores(+Proyecto, -Errores:list) is det.
%
%   Errores son los defectos de la representación de Proyecto, en este
%   orden: repetida(T) por cada tarea que aparece más de una vez,
%   duracion(T, D) por cada duración que no es un entero positivo,
%   desconocida(T) por cada tarea de una precedencia que no está entre las
%   tareas, procesadores(N) si N no es un entero positivo, y ciclo si las
%   precedencias forman uno. Errores es [] si el proyecto es correcto.
errores(Proyecto, Errores) :-
    Proyecto = proyecto(Tareas, Precedencias, N),
    findall(T, member(tarea(T, _), Tareas), Nombres),
    msort(Nombres, Ordenados),
    clumped(Ordenados, Veces),
    findall(repetida(T), ( member(T-K, Veces), K > 1 ), E1),
    findall(duracion(T, D),
            ( member(tarea(T, D), Tareas),
              \+ ( integer(D), D > 0 ) ),
            E2),
    findall(desconocida(T),
            ( member(antes(A, B), Precedencias),
              member(T, [A, B]),
              \+ memberchk(T, Nombres) ),
            E3a),
    sort(E3a, E3),
    (   integer(N),
        N > 0
    ->  E4 = []
    ;   E4 = [procesadores(N)]
    ),
    (   E3 == [],
        \+ orden_topologico(Proyecto, _)
    ->  E5 = [ciclo]
    ;   E5 = []
    ),
    append([E1, E2, E3, E4, E5], Errores).
