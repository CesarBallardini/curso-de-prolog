# Capítulo 41 — Búsqueda y planificación

Muchos problemas se enuncian como un **espacio de estados**: un estado de
partida, unas acciones que llevan de un estado a otro, y una condición que
reconoce los estados buscados. Resolverlos es encontrar una secuencia de
acciones, un **plan**, que lleve del primero a uno de los últimos. Prolog ya
busca: la resolución recorre en profundidad el árbol de las alternativas
([sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas)), y la
[plantilla 15](../plantillas.md#15-generar-y-probar) genera candidatos y los prueba
([sección 9.6](../capitulo-09-backtracking-y-corte/index.md#96-generar-y-probar)). Pero esa búsqueda
tiene un orden fijo, no registra los estados por los que pasó, y no estima
cuál de las alternativas acerca más a la meta. Este capítulo escribe la
búsqueda como un programa, con esas tres decisiones a la vista.

El capítulo sigue una escalera. El problema se describe con tres predicados
que la búsqueda no conoce por dentro; una búsqueda recursiva ingenua no
termina; un solo bucle con una **frontera** de nodos pendientes da tres
estrategias según la estructura de datos de esa frontera; un registro de
estados visitados hace terminar a las tres; la profundidad limitada y la
profundización iterativa encuentran el plan más corto con la memoria de un
solo camino; y una **heurística** que estima lo que falta hace de la
búsqueda de costo uniforme el algoritmo A\*, medido sobre el rompecabezas
de 8. Las últimas secciones aplican lo anterior: la
[planificación con operadores STRIPS](planificacion.md#416-planificacion-operadores-strips-y-analisis-de-medios-y-fines)
y el análisis de medios y fines, sobre el mundo de bloques del
[capítulo 23](../capitulo-23-estructuras-de-datos-de-la-biblioteca/index.md); y
[la vuelta a casa del Wumpus y el Buscaminas](aplicaciones.md#417-la-vuelta-a-casa-del-wumpus)
como problemas de búsqueda.

Las fuentes son los capítulos «Blind Search» e «Informed Search» de
*Applications of Prolog* de Attila Csenki, que desarrollan las búsquedas a
ciegas, A\* e IDA\* y el rompecabezas de 8; «Basic Problem-Solving
Strategies» y «Best-first: A Heuristic Search Principle» de *Prolog
Programming for Artificial Intelligence* de Ivan Bratko; «Depth-, Breadth-,
and Best-First Search» de *AI Algorithms, Data Structures, and Idioms* de
Luger y Stubblefield, que escribe las tres búsquedas con un solo programa en
el que solo cambia el manejo de la lista de estados abiertos; «Implementing
search» y «Abstraction in search» de *Artificial Intelligence through
Prolog* de Neil Rowe (los problemas como sucesores y el análisis de medios y
fines); el apartado «Planning» de *Prolog for Programmers* de Kluźniak y
Szpakowicz (WARPLAN); y las hojas de trabajo «Searching a Cyclic Graph» y
«Partial Maps with a Parameter» de *Clause and Effect* de William Clocksin
(el rastro de los nodos visitados y la lista de los que quedan). Los
programas del capítulo están escritos para el curso; las
[referencias](#referencias) del final dan cada fuente con su enlace.

El capítulo cumple anuncios de muchos capítulos anteriores: los árboles del
[capítulo 6](../capitulo-06-recursion/index.md), las búsquedas de mayor escala del
[capítulo 9](../capitulo-09-backtracking-y-corte/index.md), el espacio de estados con el árbol como
camino del [capítulo 20](../capitulo-20-operadores-y-reglas-como-datos/index.md), la vuelta del Wumpus del
[capítulo 21](../capitulo-21-base-de-datos-dinamica/index.md), las heurísticas y el mundo de bloques del
[capítulo 23](../capitulo-23-estructuras-de-datos-de-la-biblioteca/index.md), las reinas del
[capítulo 24](../capitulo-24-programacion-con-restricciones/index.md), el Buscaminas de los capítulos
[32](../capitulo-32-ejecutables-y-distribucion/index.md) y [37](../capitulo-37-interfaces-de-usuario/index.md), la profundización
iterativa del [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md), la cola diferencia del
[capítulo 35](../capitulo-35-estructuras-incompletas-y-listas-diferencia/index.md) y los conjuntos de visitados del
[capítulo 40](../capitulo-40-tabulacion/index.md). Todos los ejemplos corren en SWISH.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- describir un problema de búsqueda con `inicial/2`, `meta/2` y
  `sucesor/5`, con el problema como un término que la búsqueda recibe;
- escribir un solo bucle de búsqueda cuya estrategia es la estructura de
  datos de la frontera: una pila, una cola o un montículo de
  `library(heaps)`;
- hacer terminar una búsqueda en un espacio con ciclos con un registro de
  visitados en `library(assoc)`, con el rastro del camino actual o con la
  lista de lo que queda por usar;
- usar la profundidad limitada y la profundización iterativa con
  `length/2`, y explicar qué cuestan;
- escribir A\* e IDA\* con una heurística que no estima de más, y comparar
  las estrategias por nodos expandidos e inferencias;
- planificar con operadores STRIPS y análisis de medios y fines, y
  reconocer la anomalía de Sussman;
- plantear como búsqueda problemas de capítulos anteriores: la vuelta del
  Wumpus y las jugadas seguras del Buscaminas.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **3:50 h**.
    Resolver los 6 ejercicios marcados con ★: **1:35 h**.
    Resolver los 14 ejercicios del capítulo: **4:05 h**.

## 41.1 El problema como interfaz

El problema de las **jarras** tiene dos jarras sin marcas, de 4 y 3 litros,
una canilla y un desagüe; se busca que una de las jarras tenga exactamente
2 litros. Un estado es `j(A, B)`, los litros de cada jarra. Tres predicados
describen el problema, y los tres reciben como primer argumento el
problema mismo, un término: `jarras(4, 3, 2)` son las capacidades y la
cantidad buscada.

<!-- ejemplo: capitulo-41/jarras.pl predicado: inicial/2 meta/2 sucesor/5 consulta: inicial(jarras(4, 3, 2), E), sucesor(jarras(4, 3, 2), E, A, E1, C). -->
```prolog
%!  inicial(+Problema, -Estado) is det.
%
%   Estado es el estado de partida de Problema: las dos jarras vacías.
inicial(jarras(_, _, _), j(0, 0)).

%!  meta(+Problema, +Estado) is semidet.
%
%   Estado es un estado buscado de Problema: una de las jarras tiene la
%   cantidad pedida.
meta(jarras(_, _, M), j(A, B)) :-
    (   A =:= M
    ->  true
    ;   B =:= M
    ).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   Accion lleva de Estado a Siguiente y mueve Costo litros de agua. Solo
%   se consideran las acciones que cambian el estado: llenar una jarra que
%   no está llena, vaciar una que no está vacía, o pasar agua de una a la
%   otra hasta que la primera se vacíe o la segunda se llene.
sucesor(jarras(C1, _, _), j(A, B), llenar(1), j(C1, B), Costo) :-
    A < C1,
    Costo is C1 - A.
sucesor(jarras(_, C2, _), j(A, B), llenar(2), j(A, C2), Costo) :-
    B < C2,
    Costo is C2 - B.
sucesor(jarras(_, _, _), j(A, B), vaciar(1), j(0, B), A) :-
    A > 0.
sucesor(jarras(_, _, _), j(A, B), vaciar(2), j(A, 0), B) :-
    B > 0.
sucesor(jarras(_, C2, _), j(A, B), pasar(1, 2), j(A1, B1), Costo) :-
    Costo is min(A, C2 - B),
    Costo > 0,
    A1 is A - Costo,
    B1 is B + Costo.
sucesor(jarras(C1, _, _), j(A, B), pasar(2, 1), j(A1, B1), Costo) :-
    Costo is min(B, C1 - A),
    Costo > 0,
    A1 is A + Costo,
    B1 is B - Costo.
```

`sucesor/5` da cada acción con el estado al que lleva y su **costo**: aquí,
los litros de agua que mueve. Solo se consideran las acciones que cambian el
estado. Las consultas se leen como la definición del problema:

```prolog
?- inicial(jarras(4, 3, 2), E), sucesor(jarras(4, 3, 2), E, A, E1, C).
E = j(0, 0),
A = llenar(1),
E1 = j(4, 0),
C = 4 ;
E = j(0, 0),
A = llenar(2),
E1 = j(0, 3),
C = 3 ;
false.

?- sucesor(jarras(4, 3, 2), j(4, 0), A, E, C).
A = llenar(2),
E = j(4, 3),
C = 3 ;
A = vaciar(1),
E = j(0, 0),
C = 4 ;
A = pasar(1, 2),
E = j(1, 3),
C = 3 ;
false.
```

La separación es lo que importa: la búsqueda llama a estos tres predicados y
no contiene nada propio de las jarras, y el problema no depende de cómo se
lo recorra. Otro problema es otro término y otras cláusulas:
`jarras(7, 2, 1)` es otra instancia del mismo; el rompecabezas de 8 y la
vuelta del Wumpus de las secciones siguientes son otros problemas con los
mismos tres predicados. Que el problema sea un argumento, y no un conjunto
de hechos globales, permite además llevar datos dentro del término: la
[sección 41.7](aplicaciones.md#417-la-vuelta-a-casa-del-wumpus) pasa en él la lista
de celdas seguras de la cueva.

La primera búsqueda es la recursión de Prolog: un plan vacío si el estado es
una meta, o una acción seguida de un plan desde el estado siguiente.

<!-- ejemplo: capitulo-41/jarras.pl predicado: resolver_ingenuo/2 desde/3 consulta: call_with_inference_limit(resolver_ingenuo(jarras(4, 3, 2), P), 100000, R). -->
```prolog
%!  resolver_ingenuo(+Problema, -Plan:list) is nondet.
%
%   Plan es una secuencia de acciones que lleva del estado inicial de
%   Problema a un estado meta. Busca en profundidad sin recordar los estados
%   por los que pasó: en un problema con ciclos, como las jarras, no
%   termina.
resolver_ingenuo(Problema, Plan) :-
    inicial(Problema, Estado),
    desde(Problema, Estado, Plan).

%!  desde(+Problema, +Estado, -Plan:list) is nondet.
%
%   Plan lleva de Estado a un estado meta de Problema.
desde(Problema, Estado, []) :-
    meta(Problema, Estado).
desde(Problema, Estado, [Accion|Plan]) :-
    sucesor(Problema, Estado, Accion, Siguiente, _),
    desde(Problema, Siguiente, Plan).
```

No termina. La primera acción es `llenar(1)`; desde `j(4, 0)`, `llenar(2)`
lleva a `j(4, 3)`; `vaciar(1)` a `j(0, 3)`; `llenar(1)` de vuelta a
`j(4, 3)`, y así sin fin. Cada vuelta del ciclo es una rama nueva del árbol
de búsqueda, que es infinito aunque el espacio de estados tenga solo
catorce estados alcanzables. `call_with_inference_limit/3`
([capítulo 27](../capitulo-27-pruebas-y-depuracion/index.md)) corta la consulta:

```prolog
?- call_with_inference_limit(resolver_ingenuo(jarras(4, 3, 2), P), 100000, R).
R = inference_limit_exceeded.

?- length(P, 4), resolver_ingenuo(jarras(4, 3, 2), P).
P = [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1)] ;
false.
```

Con la longitud del plan fijada de antemano, en cambio, la misma búsqueda
termina: cada rama del árbol se corta a las cuatro acciones. Es la semilla
de la [sección 41.4](heuristicas.md#414-profundidad-limitada-y-profundizacion-iterativa). En
SWISH, la primera consulta sin límite agota en unos segundos la pila de
0,2 GB que el servidor asigna a cada consulta.

## 41.2 Una sola búsqueda, varias estrategias

La búsqueda recursiva guarda las alternativas pendientes en los puntos de
elección de Prolog, y por eso las recorre en el único orden que Prolog
conoce. Para elegir el orden, las alternativas pendientes se guardan en una
estructura de datos, la **frontera**: los nodos generados y todavía no
expandidos. Un nodo es `nodo(Estado, Camino, G)`: el estado, las acciones
que llevaron a él, la última primero, y su costo acumulado. El bucle es
siempre el mismo: sacar un nodo; si su estado es una meta, terminar; si no,
**expandirlo**, agregando a la frontera los nodos de sus sucesores.

<!-- ejemplo: capitulo-41/frontera.pl predicado: buscar/5 bucle/6 hijos/3 hijo/4 consulta: buscar(anchura, jarras(4, 3, 2), Plan, Costo, Expandidos). -->
```prolog
%!  buscar(+Estrategia, +Problema, -Plan:list, -Costo:number,
%!         -Expandidos:integer) is semidet.
%
%   Plan lleva del estado inicial de Problema a un estado meta con costo
%   Costo; Expandidos es la cantidad de nodos que la búsqueda expandió.
%   Estrategia es profundidad, anchura o mejor(costo). Falla si la
%   frontera se vacía sin llegar a una meta.
buscar(Estrategia, Problema, Plan, Costo, Expandidos) :-
    inicial(Problema, Estado),
    frontera_inicial(Estrategia, Problema, nodo(Estado, [], 0), Frontera),
    bucle(Estrategia, Problema, Frontera, 0, nodo(_, Camino, Costo),
          Expandidos),
    reverse(Camino, Plan).

%!  bucle(+Estrategia, +Problema, +Frontera, +K0:integer, -Solucion,
%!        -K:integer) is semidet.
%
%   Solucion es el primer nodo meta que se extrae de Frontera; K es K0 más la
%   cantidad de nodos expandidos hasta sacarlo.
bucle(Estrategia, Problema, Frontera0, K0, Solucion, K) :-
    sacar(Estrategia, Frontera0, Nodo, Frontera1),
    Nodo = nodo(Estado, _, _),
    (   meta(Problema, Estado)
    ->  Solucion = Nodo,
        K = K0
    ;   K1 is K0 + 1,
        hijos(Problema, Nodo, Hijos),
        agregar(Estrategia, Problema, Hijos, Frontera1, Frontera2),
        bucle(Estrategia, Problema, Frontera2, K1, Solucion, K)
    ).

%!  hijos(+Problema, +Nodo, -Hijos:list) is det.
%
%   Hijos son los nodos de los estados que siguen al de Nodo, cada uno con
%   su camino y su costo. findall/3 reúne solo las transiciones: el camino
%   de cada hijo se arma afuera, y comparte el de Nodo en lugar de copiarlo.
hijos(Problema, nodo(Estado, Camino, G), Hijos) :-
    findall(t(Accion, Siguiente, Costo),
            sucesor(Problema, Estado, Accion, Siguiente, Costo),
            Transiciones),
    maplist(hijo(Camino, G), Transiciones, Hijos).

%!  hijo(+Camino:list, +G:number, +Transicion, -Hijo) is det.
%
%   Hijo es el nodo al que lleva Transicion desde un nodo con Camino y G.
hijo(Camino, G, t(Accion, Siguiente, Costo),
     nodo(Siguiente, [Accion|Camino], G1)) :-
    G1 is G + Costo.
```

`hijos/3` reúne con `findall/3` solo las transiciones, y arma los nodos
afuera, con `maplist/3`. La primera versión construía los nodos dentro de
`findall/3`, y la búsqueda en profundidad agotó 1 GB de pila en 5 565
expansiones: `findall/3` **copia** cada solución, y cada hijo recibía una
copia del camino entero de su padre. Armado afuera, el camino de cada hijo
es `[Accion|Camino]` con el `Camino` del padre compartido, no copiado. Los
caminos de todos los nodos forman así un árbol, con la raíz en la lista
vacía: la frontera guarda el **árbol de búsqueda** explorado, y el camino de
cada nodo es su rama.

La estrategia está en tres predicados sobre la frontera: cómo es la vacía,
cómo se saca un nodo, y cómo se agregan los nuevos.

<!-- ejemplo: capitulo-41/frontera.pl predicado: frontera_inicial/4 vacia/2 sacar/4 agregar/5 al_monticulo/5 prioridad/4 -->
```prolog
%!  frontera_inicial(+Estrategia, +Problema, +Nodo, -Frontera) is det.
%
%   Frontera tiene solo a Nodo, con la estructura de datos de Estrategia.
frontera_inicial(Estrategia, Problema, Nodo, Frontera) :-
    vacia(Estrategia, Vacia),
    agregar(Estrategia, Problema, [Nodo], Vacia, Frontera).

%!  vacia(+Estrategia, -Frontera) is det.
%
%   Frontera es la frontera vacía de Estrategia: una pila, una cola o un
%   montículo.
vacia(profundidad, []).
vacia(anchura, cola(0, F, F)).
vacia(mejor(_), Monticulo) :-
    empty_heap(Monticulo).

%!  sacar(+Estrategia, +Frontera0, -Nodo, -Frontera) is semidet.
%
%   Nodo es el próximo nodo de Frontera0 según Estrategia, y Frontera lo
%   que queda. Falla si Frontera0 está vacía.
sacar(profundidad, [Nodo|Pila], Nodo, Pila).
sacar(anchura, Cola0, Nodo, Cola) :-
    desencolar(Nodo, Cola0, Cola).
sacar(mejor(_), Monticulo0, Nodo, Monticulo) :-
    get_from_heap(Monticulo0, _, Nodo, Monticulo).

%!  agregar(+Estrategia, +Problema, +Nodos:list, +Frontera0, -Frontera)
%!      is det.
%
%   Frontera es Frontera0 con Nodos agregados según Estrategia.
agregar(profundidad, _, Nodos, Pila0, Pila) :-
    append(Nodos, Pila0, Pila).
agregar(anchura, _, Nodos, Cola0, Cola) :-
    foldl(encolar, Nodos, Cola0, Cola).
agregar(mejor(Criterio), Problema, Nodos, Monticulo0, Monticulo) :-
    foldl(al_monticulo(Criterio, Problema), Nodos, Monticulo0, Monticulo).

%!  al_monticulo(+Criterio, +Problema, +Nodo, +Monticulo0, -Monticulo)
%!      is det.
%
%   Monticulo es Monticulo0 con Nodo, con la prioridad que le da Criterio.
al_monticulo(Criterio, Problema, Nodo, Monticulo0, Monticulo) :-
    prioridad(Criterio, Problema, Nodo, Prioridad),
    add_to_heap(Monticulo0, Prioridad, Nodo, Monticulo).

%!  prioridad(+Criterio, +Problema, +Nodo, -Prioridad:number) is det.
%
%   Prioridad es el valor de Nodo según Criterio; se extrae primero el menor.
%   Con costo, es el costo del camino: la búsqueda de costo uniforme.
prioridad(costo, _, nodo(_, _, G), G).
```

- **En profundidad**, la frontera es una **pila**, una lista a la que los
  hijos se agregan adelante: se extrae primero el último generado.
- **En anchura**, es una **cola**: los hijos se agregan al final y se
  extrae primero el más antiguo. Es la cola con contador de la
  [sección 35.3](../capitulo-35-estructuras-incompletas-y-listas-diferencia/index.md#353-colas), una lista diferencia que agrega
  al final en un paso; `encolar/3` y `desencolar/3` son los de aquel
  capítulo.
- **Mejor primero** es un **montículo** (*heap*) de `library(heaps)`: cada
  nodo entra con una prioridad, y se extrae primero el de menor prioridad. Con
  `mejor(costo)` la prioridad es el costo acumulado, y la búsqueda es la de
  **costo uniforme**.

`library(heaps)` se presenta aquí. `empty_heap/1` crea un montículo vacío,
`add_to_heap/4` agrega un elemento con su prioridad, y
`get_from_heap/4` saca el de menor prioridad y falla si el montículo está
vacío; las dos operaciones cuestan un tiempo proporcional al logaritmo de
la cantidad de elementos. `list_to_heap/2` arma un montículo a partir de
pares `Prioridad-Elemento`, y `heap_size/2` da su tamaño.

```prolog
?- buscar(anchura, jarras(4, 3, 2), Plan, Costo, Expandidos).
Plan = [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1)],
Costo = 10,
Expandidos = 67.

?- buscar(mejor(costo), jarras(4, 3, 2), Plan, Costo, Expandidos).
Plan = [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1)],
Costo = 10,
Expandidos = 24.

?- call_with_inference_limit(buscar(profundidad, jarras(4, 3, 2), Plan, _, _), 1000000, R).
R = inference_limit_exceeded.
```

En anchura, la búsqueda examina todos los planes de una acción, después
todos los de dos, y así: el primer plan que encuentra es uno de los más
cortos, y termina aunque el espacio tenga ciclos, porque los ciclos solo
agregan ramas más largas. Pero expande 67 nodos para un plan de cuatro
acciones, porque vuelve a expandir los estados a los que llega por
distintos caminos. La búsqueda de costo uniforme expande los nodos en orden
de costo, y por eso comprueba la meta al **sacar** el nodo y no al
generarlo: un nodo meta recién generado puede tener un costo mayor que otro
todavía en la frontera. En profundidad, sin registro de lo visitado, la
búsqueda repite el ciclo de la sección anterior, ahora con la pila.

!!! question "Actividad"
    En `jarras(7, 2, 1)` hay un plan de seis acciones que mueve 17 litros y
    otro de ocho acciones que mueve 15. Predecir cuál devuelve
    `buscar(anchura, jarras(7, 2, 1), P, C, K)` y cuál
    `buscar(mejor(costo), jarras(7, 2, 1), P, C, K)`, y comprobarlo con el
    archivo `visitados.pl` de la sección siguiente.

!!! example "Patrón 54 — La frontera decide la estrategia"
    **Problema.** Es necesario buscar un plan en un espacio de estados, y
    probar más de un orden de búsqueda sin reescribir la búsqueda.

    **Versión ingenua.** Una búsqueda recursiva por cada estrategia —la de
    Prolog en profundidad, otra para la anchura, otra más para el costo—,
    con el problema mezclado en cada una; o una sola búsqueda con la agenda
    guardada en la base de datos dinámica.

    **Patrón.** El problema como término, descrito por `inicial/2`,
    `meta/2` y `sucesor/5`. Un solo bucle que saca un nodo, comprueba la
    meta y agrega los hijos; la estrategia es la estructura de datos de la
    frontera, que el bucle recibe como argumento: una pila, una cola o un
    montículo con la prioridad que corresponda. Los hijos comparten el
    camino de su padre.

    **Cuándo no usarlo.** Cuando la búsqueda en profundidad de Prolog basta
    —un espacio sin ciclos o con la longitud acotada—: la recursión es más
    corta y no guarda nada. Cuando el problema se modela mejor con
    restricciones ([capítulo 24](../capitulo-24-programacion-con-restricciones/index.md)). Y cuando la frontera no
    cabe en memoria: la profundización iterativa guarda un solo camino.

### Antipatrón: la agenda en la base de datos

La frontera también se puede guardar como hechos dinámicos: `assertz/1`
agrega un nodo al final, que es lo que hace una cola, y `retract/1` saca el
primero. `agenda_dinamica.pl` escribe así la búsqueda en anchura con
visitados, y encuentra el mismo plan:

<!-- ejemplo: capitulo-41/agenda_dinamica.pl predicado: buscar_con_agenda/2 bucle_con_agenda/2 consulta: buscar_con_agenda(jarras(4, 3, 2), Plan). -->
```prolog
%!  buscar_con_agenda(+Problema, -Plan:list) is semidet.
%
%   Plan es una de las secuencias de acciones más cortas que llevan del
%   estado inicial de Problema a un estado meta. Deja en la base de datos
%   los hechos pendiente/1 y visto/1 de la búsqueda, y parte de los que dejó
%   la búsqueda anterior.
buscar_con_agenda(Problema, Plan) :-
    inicial(Problema, Estado),
    assertz(visto(Estado)),
    assertz(pendiente(nodo(Estado, []))),
    bucle_con_agenda(Problema, Camino),
    reverse(Camino, Plan).

%!  bucle_con_agenda(+Problema, -Camino:list) is semidet.
%
%   Saca el primer nodo de la agenda; si su estado es una meta, Camino es su
%   camino, y si no, agrega a la agenda sus hijos no vistos y sigue.
bucle_con_agenda(Problema, Camino) :-
    retract(pendiente(nodo(Estado, Camino0))),
    !,
    (   meta(Problema, Estado)
    ->  Camino = Camino0
    ;   forall(( sucesor(Problema, Estado, Accion, Siguiente, _),
                 \+ visto(Siguiente) ),
               ( assertz(visto(Siguiente)),
                 assertz(pendiente(nodo(Siguiente, [Accion|Camino0]))) )),
        bucle_con_agenda(Problema, Camino)
    ).
```

El costo aparece en la segunda búsqueda. La agenda y los visitados son
estado global: la búsqueda que termina deja en la base de datos los nodos
que no llegó a sacar, y la siguiente empieza por ellos.

```prolog
?- buscar_con_agenda(jarras(4, 3, 2), _), findall(N, pendiente(N), Ns).
Ns = [nodo(j(4, 1), [llenar(1), pasar(1, 2), vaciar(2), pasar(1, 2), llenar(1)])].

?- buscar_con_agenda(jarras(4, 3, 2), P1), buscar_con_agenda(jarras(4, 3, 1), P2).
P1 = [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1)],
P2 = [llenar(1), pasar(1, 2), vaciar(2), pasar(1, 2), llenar(1)].
```

El plan más corto para 1 litro tiene dos acciones, `[llenar(1),
pasar(1, 2)]`; la segunda búsqueda saca primero el nodo que dejó la primera,
que por coincidencia es una meta, y lo devuelve. Después de dos búsquedas, una
tercera para 1 litro falla: todos los estados figuran como visitados. Un
predicado que borre la agenda, `limpiar_agenda/0`, lo corrige solo si cada
llamador se acuerda de usarlo; y dos búsquedas no pueden estar en curso a la
vez, ni en dos hilos ni una dentro de otra.

El otro costo es el tiempo. En `jarras(2001, 1999, 1)`, con un plan de
3 996 acciones, medido en esta máquina:

```text
?- time(buscar_con_agenda(jarras(2001, 1999, 1), P)).    % agenda_dinamica.pl
% 254,677 inferences, 4.625 CPU in 4.851 seconds (95% CPU, 55065 Lips)

?- time(buscar(anchura, jarras(2001, 1999, 1), P, _, K)). % visitados.pl
% 1,117,645 inferences, 0.219 CPU in 0.259 seconds (84% CPU, 5109234 Lips)
```

Con menos inferencias, la agenda tarda veinte veces más. Las inferencias
no cuentan la copia: `assertz/1` guarda una copia del nodo, camino incluido,
y `retract/1` lo copia de vuelta, de modo que cada paso copia un camino de
miles de acciones que en la versión pura se comparte. Medido aparte, 6 000
pares `assertz/1`–`retract/1` de una lista de 6 000 elementos tardan 3,4
segundos; la búsqueda de un estado en `visto/1` está indexada y no pesa. La
base de datos dinámica es para el conocimiento que dura más que una
consulta ([sección 21.8](../capitulo-21-base-de-datos-dinamica/index.md#218-cuando-no-usarla)); una frontera dura lo que dura
la búsqueda, y es un argumento.

El capítulo continúa en la página
[Ciclos y visitados](visitados.md#413-ciclos-y-visitados), con el registro
de los estados visitados que hace terminar a las tres estrategias.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(2)** Reescribir `buscar_con_agenda/2` para que borre la agenda al
   empezar y al terminar, también si la búsqueda falla o lanza una
   excepción, con `setup_call_cleanup/3`
   ([capítulo 26](../capitulo-26-errores-y-excepciones/index.md)). Mostrar que las pruebas de la
   segunda búsqueda dejan de fallar, y dar una consulta en la que el
   programa corregido todavía responde mal.

## Referencias

- Attila Csenki, *Applications of Prolog*, Ventus Publishing (Bookboon),
  2009 — capítulo «Blind Search», apartados «Depth First Search» y
  «Breadth First Search».
  [Página de la editorial, copia de archivo](https://web.archive.org/web/20260216182045/https://bookboon.com/en/applications-of-prolog-ebook).
  La editorial ya no ofrece el libro;
  [Google Libros](https://books.google.com/books?id=copBGLD4LKwC) muestra
  páginas seleccionadas.
  Esta página toma de allí el punto de partida de la escalera de búsquedas
  a ciegas: las búsquedas en profundidad y en anchura.
- Ivan Bratko, *Prolog Programming for Artificial Intelligence*,
  Addison-Wesley, 1986 — capítulo «Basic Problem-Solving Strategies». Sin
  edición en línea de acceso libre. De allí viene el espacio de estados
  con sucesores y costos.
- George F. Luger y William A. Stubblefield, *AI Algorithms, Data
  Structures, and Idioms in Prolog, Lisp, and Java*, Pearson
  Addison-Wesley, 2009 — capítulo «Depth- Breadth-, and Best-First
  Search», apartado «Designing Alternative Search Strategies». Sin edición
  en línea de acceso libre verificada. Es el origen de la idea de un solo
  programa de búsqueda en el que solo cambia el manejo de la lista de
  estados abiertos.
- Neil C. Rowe, *Artificial Intelligence through Prolog*, Prentice-Hall,
  1988 — capítulo «Implementing search»
  ([en línea](https://faculty.nps.edu/ncrowe/book/chap10.html)). Esta
  página toma de allí el problema descrito por sus estados y sucesores,
  separado de la búsqueda.
