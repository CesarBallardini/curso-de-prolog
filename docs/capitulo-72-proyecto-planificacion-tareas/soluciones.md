# Soluciones del capítulo 72 — Proyecto: planificación de tareas

El código de esta página está en `ejemplos/capitulo-72/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `planificador.pl` (que
reexporta `camino.pl`, `reparto.pl`, `espacio.pl` y la representación,
`tareas.pl`), `lista.pl` y `busqueda.pl`, sin modificarlos. La solución
del ejercicio 8 está en `soluciones_estados.pl`, porque define otro
espacio de estados. Los dos
archivos son `% solo-local`, porque cargan otros archivos. Las consultas
reúnen los resultados con `findall/3` para no mostrar los proyectos
completos.

## 1

Con tres cuadrillas, las 36 unidades de trabajo divididas por tres dan 12:
el reparto queda muy por debajo del camino crítico de la obra, que suma
27 (cimientos, paredes, techo, revoque y pintura). La cota inferior es el
máximo, 27. La tercera cuadrilla permite hacer el agua, la luz y las
aberturas al mismo tiempo que el techo, así que la duración óptima es 27,
y el mejor calendario por lista ya la alcanza: el planificador no busca y
responde `optima(por_lista)`.

<!-- ejemplo: capitulo-72/soluciones.pl predicado: con_procesadores/3 -->
```prolog
%!  con_procesadores(+Proyecto0, +N:integer, -Proyecto) is det.
%
%   Proyecto tiene las tareas y las precedencias de Proyecto0, con N
%   procesadores.
con_procesadores(proyecto(Tareas, Precedencias, _), N,
                 proyecto(Tareas, Precedencias, N)).
```

<!-- contexto: capitulo-72/soluciones.pl -->
```prolog
?- findall(H-B-G, (ejemplo(casa, P0), con_procesadores(P0, 3, P), inicial(datos(P, combinada), E), member(H0, [reparto, camino]), call(H0, P, E, H), cota_inferior(P, B), planificar(P, 1000000, _, G)), L).
L = [12-27-optima(por_lista), 27-27-optima(por_lista)].
```

## 2

Una prioridad es una permutación de las tareas, y `permutation/2` las
genera todas; `aggregate_all/3` se queda con la menor duración.

<!-- ejemplo: capitulo-72/soluciones.pl predicado: mejor_de_todas/2 -->
```prolog
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
```

```prolog
?- findall(D, (ejemplo(coffman, P), mejor_de_todas(P, D)), L).
L = [33].
```

Ninguna de las 5 040 prioridades baja de 33. En el momento 2 terminan
`t2` y `t3`; las únicas tareas listas son `t6` y `t7`, porque `t4` y `t5`
esperan a `t1`, que termina en 4. La planificación por lista nunca deja
ocioso un procesador si hay una tarea lista, sea cual sea la prioridad,
así que `t6` y `t7` ocupan los dos procesadores libres hasta 13, y una de
las tareas de 20 unidades no puede empezar antes de 13: el final llega a
33. El calendario de 24 necesita dejar un procesador ocioso entre 2 y 4.

## 3

La cabeza es la simétrica de la cola: se calcula hacia atrás, por las
predecesoras. Una tarea es crítica si su cabeza más su cola es la mayor
cola: el camino más largo del proyecto pasa por ella, de modo que
demorarla demora el final aunque sobren procesadores. Las dos cabeceras
declaran `det`: con el proyecto y la tarea instanciados hay exactamente
una respuesta, y `findall/3` con `max_list/2` no dejan alternativas. El
modo exige el proyecto instanciado (`+`); la tarea de `cabeza/3` también,
porque sin ella `precede/3` enumeraría pares de cualquier tarea.

<!-- ejemplo: capitulo-72/soluciones.pl predicado: cabeza/3 criticas/2 -->
```prolog
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
```

```prolog
?- findall(N-Ts, (member(N, [coffman, casa]), ejemplo(N, P), criticas(P, Ts)), L).
L = [coffman-[t1, t4, t5], casa-[cimientos, paredes, techo, revoque, pintura]].
```

En `coffman` hay dos caminos críticos de 24, `t1`–`t4` y `t1`–`t5`, y la
lista reúne sus tareas.

## 4

<!-- ejemplo: capitulo-72/soluciones.pl predicado: suma/3 sumar/4 -->
```prolog
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
```

```prolog
?- medir(coffman, suma, D, K).
D = 33,
K = 7.

?- medir(casa, suma, D, K).
D = 28,
K = 11.
```

En el estado inicial de `coffman`, `suma/3` estima 70, cuando el
calendario completo dura 24: la heurística estima de más, porque ignora
que tres procesadores trabajan al mismo tiempo. Una heurística que estima
de más no es admisible, y A\* deja de asegurar el óptimo. La estimación
pesa mucho más que el costo acumulado, y la búsqueda se comporta casi como
la voraz: expande solo 7 estados y termina con un calendario de 33. En `casa` llega a 28, el óptimo, pero por
casualidad: nada en la búsqueda lo prueba.

## 5

<!-- ejemplo: capitulo-72/soluciones.pl predicado: comparar_voraz/2 fila_voraz/2 -->
```prolog
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
```

```prolog
?- comparar_voraz([6, 12], F).
F = [6-voraz(16, 23)-optimo(15, 29), 12-voraz(30, 15)-optimo(26, 43)].
```

La búsqueda voraz expande menos estados en `taller(12)` (15 contra 43),
pero su calendario dura 30 contra 26; en `taller(6)` expande 23 contra
29 y termina en 16 en lugar de 15. La
búsqueda voraz no garantiza el óptimo con ninguna heurística; A\* sí, si
la heurística nunca estima de más.

## 6

`ida_estrella/4` recibe el mismo término `problema(espacio, Datos)` que
`buscar/5`. La heurística se califica con el módulo `soluciones`, porque
el espacio de estados la llama con `call/4` desde su propio módulo.

<!-- ejemplo: capitulo-72/soluciones.pl predicado: optimo_ida/4 -->
```prolog
%!  optimo_ida(+Proyecto, +Heuristica, -D:integer, -Expandidos:integer)
%!      is semidet.
%
%   D es la duración óptima de Proyecto según IDA* del capítulo 40, con
%   Heuristica, el nombre de un predicado visible en este módulo;
%   Expandidos cuenta los estados expandidos en todas las iteraciones.
optimo_ida(Proyecto, Heuristica, D, Expandidos) :-
    ida_estrella(problema(espacio, datos(Proyecto, soluciones:Heuristica)),
                 _, D, Expandidos).
```

```prolog
?- findall(N-D-K, (member(N, [coffman, casa]), member(H, [reparto, combinada]), ejemplo(N, P), optimo_ida(P, H, D, K)), L).
L = [coffman-24-11, coffman-24-9, casa-28-1022, casa-28-24].
```

En `coffman` con el reparto, IDA\* expande 11 estados contra 21 de A\*:
la estimación inicial, 24, ya es el óptimo, y la primera iteración
recorre en profundidad un solo camino hasta un calendario que la
alcanza. En `casa` con el reparto la estimación inicial es 18 y el óptimo
28: IDA\* repite la búsqueda con cotas crecientes y, sin conjunto de
visitados, vuelve a expandir los mismos estados en cada iteración y por
cada camino que lleva a ellos: 1 022 contra 231. Con la combinada, que
empieza en 27 en `casa`, la diferencia se reduce a 24 contra 16.

## 7

<!-- ejemplo: capitulo-72/soluciones.pl predicado: curva/3 duracion_con/3 -->
```prolog
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
```

```prolog
?- findall(N-L, (member(N, [casa, coffman]), ejemplo(N, P), curva(P, [1, 2, 3, 4], L)), Ls).
Ls = [casa-[1-36, 2-28, 3-27, 4-27], coffman-[1-70, 2-35, 3-24, 4-24]].
```

Con un procesador la duración es la suma de todas las tareas: 36 y 70.
Cada procesador que se agrega reparte mejor el trabajo, hasta que la
duración llega al camino crítico, que ningún procesador acorta: 27 en
`casa`, a partir de tres cuadrillas, y 24 en `coffman`, a partir de tres
procesadores. Con dos, `coffman` dura 35, la mitad de 70: el reparto es
la cota que manda.

## 8

<!-- ejemplo: capitulo-72/soluciones_estados.pl predicado: sucesor/5 normalizar/3 sirve/3 -->
```prolog
%!  sucesor(+Datos, +Estado, -Accion, -Siguiente, -Costo:integer)
%!      is nondet.
%
%   Un sucesor de la versión 2, con su estado normalizado.
sucesor(Datos, Estado, Accion, Siguiente, Costo) :-
    espacio:sucesor(Datos, Estado, Accion, Siguiente0, Costo),
    normalizar(Datos, Siguiente0, Siguiente).

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
```

<!-- contexto: capitulo-72/soluciones_estados.pl -->
```prolog
?- findall(N-K, (member(N, [coffman, casa]), ejemplo(N, P), optimo_normalizado(P, cero, _, K)), L).
L = [coffman-653, casa-341].
```

La búsqueda de costo uniforme expande 653 estados en lugar de 803 en
`coffman`, y 341 en lugar de 381 en `casa`. Borrar un fin que ya no sirve
es seguro: la disponibilidad de una tarea solo consulta los fines de sus
predecesoras, y las heurísticas de las versiones 3 y 4 solo los de las
predecesoras de las tareas pendientes. La mejora es modesta porque la
mayor parte de los estados distintos difieren en los momentos en que se
liberan los procesadores, no en fines viejos.

## 9

<!-- ejemplo: capitulo-72/soluciones.pl predicado: regla/2 multiplo_de_5/1 marca/3 mostrar_con_regla/2 -->
```prolog
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
```

```prolog
?- forall(ejemplo(casa, P), (planificar(P, 1000000, C, _), mostrar_con_regla(P, C))).
   0         5         10        15        20        25
P1 cimientos-paredes---------techo-------..revoque---pintura
P2 ..........................agua----luz---..........aberturas
duración: 28
true.
```

## 10

Cada clase de error se reúne con su propio `findall/3`, y la lista final
los concatena en el orden del enunciado. El ciclo solo se busca cuando
todas las tareas de las precedencias existen, porque `orden_topologico/2`
supone un grafo cuyos vértices son las tareas.

<!-- ejemplo: capitulo-72/soluciones.pl predicado: errores/2 -->
```prolog
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
```

```prolog
?- errores(proyecto([tarea(a, 1), tarea(a, 2), tarea(b, 0)], [antes(a, x)], 0), E).
E = [repetida(a), duracion(b, 0), desconocida(x), procesadores(0)].

?- errores(proyecto([tarea(a, 1), tarea(b, 2)], [antes(a, b), antes(b, a)], 2), E).
E = [ciclo].
```

## 11

El mejor calendario por lista dura 28 y la cota es 27, así que el
planificador tiene que buscar. A\* con la combinada necesita unas 18 600
inferencias para `casa`: con 1 000 y con 10 000 no termina y la respuesta
es `entre(27, 28)`; con 100 000 termina y prueba que 28 es el óptimo.

<!-- contexto: capitulo-72/planificador.pl -->
```prolog
?- planificar_ejemplo(casa, 1000, D, G).
D = 28,
G = entre(27, 28).

?- planificar_ejemplo(casa, 100000, D, G).
D = 28,
G = optima(a_estrella).
```

## 12

La prioridad de mayor cola primero ordena las tareas por la longitud de
la cadena que empieza en cada una, el dato que
[`holguras.pl`](extensiones.md#fechas-tempranas-fechas-tardias-y-holguras)
traduce en fechas tardías. `soluciones.pl` reexporta `variante/3` de
`anomalias.pl`:

<!-- ejemplo: capitulo-72/soluciones.pl predicado: por_colas/2 -->
```prolog
%!  por_colas(+Proyecto, -D:integer) is semidet.
%
%   D es la duración del calendario por lista de Proyecto con la prioridad
%   de mayor cola primero. Falla si las precedencias forman un ciclo.
por_colas(Proyecto, D) :-
    orden_topologico(Proyecto, _),
    findall(C-T,
            ( tarea(Proyecto, T, _),
              cola(Proyecto, T, C) ),
            Pares0),
    sort(1, @>=, Pares0, Pares),
    pairs_values(Pares, Lista),
    por_lista(Proyecto, ordenadas(Lista), Calendario),
    duracion(Calendario, D).
```

<!-- contexto: capitulo-72/soluciones.pl -->
```prolog
?- forall(variante(N, P, _), (por_colas(P, D), writeln(N-D))).
base-12
otra_lista-12
sin_dos_precedencias-12
mas_cortas-10
cuatro_procesadores-12
true.

?- forall(ejemplo(coffman, P), (por_colas(P, D), writeln(D))).
33
true.
```

Con esa prioridad, las cinco variantes llegan a su duración óptima. En
todas ellas la cadena `t1`, `t9` tiene la mayor cola (12, o 10 con las
tareas más cortas), de modo que `t1` es la primera tarea de la lista y
`t9` la segunda: `t1` empieza en el momento 0 y `t9` apenas termina
`t1`, antes que cualquiera de las sucesoras de `t4`. Las demás tareas
ocupan los otros procesadores mientras corre `t9`, y el calendario dura
lo mismo que la cadena, que es una cota inferior. Las anomalías del
ejemplo aparecían porque la lista t1, …, t9 dejaba `t9` para el final, y
un cambio que adelantaba las sucesoras de `t4` le quitaba el procesador.

La prioridad no evita las anomalías en general. En `coffman` da 33, como
cualquier otra lista: en el momento 2 las únicas tareas listas son `t6`
y `t7`, y la planificación por lista no deja un procesador ocioso para
esperar a `t1`, cualquiera sea el orden de la lista. La cota de Graham
vale para toda lista, incluida esta.
