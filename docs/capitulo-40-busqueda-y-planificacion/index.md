# Capítulo 40 — Búsqueda y planificación

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
búsqueda de costo uniforme el algoritmo A\*, medido sobre el rompecabezas de
8. Dos páginas más aplican lo anterior: la
[planificación con operadores STRIPS](planificacion.md#planificacion-operadores-strips-y-analisis-de-medios-y-fines)
y el análisis de medios y fines, sobre el mundo de bloques del
[capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md); y
[la vuelta a casa del Wumpus y el Buscaminas](aplicaciones.md#la-vuelta-a-casa-del-wumpus)
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
camino del [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md), la vuelta del Wumpus del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md), las heurísticas y el mundo de bloques del
[capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md), las reinas del
[capítulo 23](../capitulo-23-programacion-con-restricciones/index.md), el Buscaminas de los capítulos
[31](../capitulo-31-ejecutables-y-distribucion/index.md) y [36](../capitulo-36-interfaces-de-usuario/index.md), la profundización
iterativa del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md), la cola diferencia del
[capítulo 34](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md) y los conjuntos de visitados del
[capítulo 39](../capitulo-39-tabulacion/index.md). Todos los ejemplos corren en SWISH.

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
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:25 h**.
    Resolver los 6 ejercicios marcados con ★: **1:35 h**.
    Resolver los 14 ejercicios del final: **4:05 h**.

## 40.1 El problema como interfaz

El problema de las **jarras** tiene dos jarras sin marcas, de 4 y 3 litros,
una canilla y un desagüe; se busca que una de las jarras tenga exactamente
2 litros. Un estado es `j(A, B)`, los litros de cada jarra. Tres predicados
describen el problema, y los tres reciben como primer argumento el
problema mismo, un término: `jarras(4, 3, 2)` son las capacidades y la
cantidad buscada.

<!-- ejemplo: capitulo-40/jarras.pl predicado: inicial/2 meta/2 sucesor/5 consulta: inicial(jarras(4, 3, 2), E), sucesor(jarras(4, 3, 2), E, A, E1, C). -->
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
[sección 40.7](aplicaciones.md#la-vuelta-a-casa-del-wumpus) pasa en él la lista
de celdas seguras de la cueva.

La primera búsqueda es la recursión de Prolog: un plan vacío si el estado es
una meta, o una acción seguida de un plan desde el estado siguiente.

<!-- ejemplo: capitulo-40/jarras.pl predicado: resolver_ingenuo/2 desde/3 consulta: call_with_inference_limit(resolver_ingenuo(jarras(4, 3, 2), P), 100000, R). -->
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
([capítulo 26](../capitulo-26-pruebas-y-depuracion/index.md)) corta la consulta:

```prolog
?- call_with_inference_limit(resolver_ingenuo(jarras(4, 3, 2), P), 100000, R).
R = inference_limit_exceeded.

?- length(P, 4), resolver_ingenuo(jarras(4, 3, 2), P).
P = [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1)] ;
false.
```

Con la longitud del plan fijada de antemano, en cambio, la misma búsqueda
termina: cada rama del árbol se corta a las cuatro acciones. Es la semilla
de la [sección 40.4](#404-profundidad-limitada-y-profundizacion-iterativa). En
SWISH, la primera consulta sin límite agota en unos segundos la pila de
0,2 GB que el servidor asigna a cada consulta.

## 40.2 Una sola búsqueda, varias estrategias

La búsqueda recursiva guarda las alternativas pendientes en los puntos de
elección de Prolog, y por eso las recorre en el único orden que Prolog
conoce. Para elegir el orden, las alternativas pendientes se guardan en una
estructura de datos, la **frontera**: los nodos generados y todavía no
expandidos. Un nodo es `nodo(Estado, Camino, G)`: el estado, las acciones
que llevaron a él, la última primero, y su costo acumulado. El bucle es
siempre el mismo: sacar un nodo; si su estado es una meta, terminar; si no,
**expandirlo**, agregando a la frontera los nodos de sus sucesores.

<!-- ejemplo: capitulo-40/frontera.pl predicado: buscar/5 bucle/6 hijos/3 hijo/4 consulta: buscar(anchura, jarras(4, 3, 2), Plan, Costo, Expandidos). -->
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

<!-- ejemplo: capitulo-40/frontera.pl predicado: frontera_inicial/4 vacia/2 sacar/4 agregar/5 al_monticulo/5 prioridad/4 -->
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
  [sección 34.3](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#343-colas), una lista diferencia que agrega
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
    restricciones ([capítulo 23](../capitulo-23-programacion-con-restricciones/index.md)). Y cuando la frontera no
    cabe en memoria: la profundización iterativa guarda un solo camino.

### Antipatrón: la agenda en la base de datos

La frontera también se puede guardar como hechos dinámicos: `assertz/1`
agrega un nodo al final, que es lo que hace una cola, y `retract/1` saca el
primero. `agenda_dinamica.pl` escribe así la búsqueda en anchura con
visitados, y encuentra el mismo plan:

<!-- ejemplo: capitulo-40/agenda_dinamica.pl predicado: buscar_con_agenda/2 bucle_con_agenda/2 consulta: buscar_con_agenda(jarras(4, 3, 2), Plan). -->
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
consulta ([sección 20.8](../capitulo-20-base-de-datos-dinamica/index.md#208-cuando-no-usarla)); una frontera dura lo que dura
la búsqueda, y es un argumento.

## 40.3 Ciclos y visitados

La búsqueda en profundidad del bucle no termina en un espacio con ciclos, y
la de anchura expande muchas veces los mismos estados. La página
[Ciclos y visitados](visitados.md#ciclos-y-visitados) agrega al bucle un
registro de los estados vistos con su mejor costo, en `library(assoc)`, con
el que las tres estrategias terminan y el problema sin solución falla; y
presenta las otras dos formas de no repetir estados: el rastro del camino
actual y la lista de lo que queda por usar, con `select/3`, aplicada a las
N reinas y medida contra las restricciones del
[capítulo 23](../capitulo-23-programacion-con-restricciones/index.md#239-las-n-reinas). Las secciones que siguen usan
el bucle con visitados, `visitados.pl`.

## 40.4 Profundidad limitada y profundización iterativa

La búsqueda en anchura encuentra el plan más corto, pero su frontera guarda
un nivel entero del árbol, que crece exponencialmente con la profundidad. La
de profundidad guarda un solo camino, pero no termina o no da el plan más
corto. La **profundidad limitada** corta cada rama a una longitud fija, y la
**profundización iterativa** repite la búsqueda con límites 0, 1, 2… hasta
encontrar un plan. `profundizacion.pl` escribe las dos con la recursión de
Prolog, sin frontera:

<!-- ejemplo: capitulo-40/profundizacion.pl predicado: con_limite/3 hasta/4 iterativo/2 desde/3 consulta: iterativo(jarras(4, 3, 2), Plan). -->
```prolog
%!  con_limite(+Problema, +Limite:integer, -Plan:list) is nondet.
%
%   Plan lleva del estado inicial de Problema a un estado meta con a lo sumo
%   Limite acciones.
con_limite(Problema, Limite, Plan) :-
    inicial(Problema, Estado),
    hasta(Problema, Estado, Limite, Plan).

%!  hasta(+Problema, +Estado, +Limite:integer, -Plan:list) is nondet.
%
%   Plan lleva de Estado a un estado meta con a lo sumo Limite acciones.
hasta(Problema, Estado, _, []) :-
    meta(Problema, Estado).
hasta(Problema, Estado, Limite, [Accion|Plan]) :-
    Limite > 0,
    Limite1 is Limite - 1,
    sucesor(Problema, Estado, Accion, Siguiente, _),
    hasta(Problema, Siguiente, Limite1, Plan).

%!  iterativo(+Problema, -Plan:list) is nondet.
%
%   Plan lleva del estado inicial de Problema a un estado meta. Los planes
%   se obtienen de menor a mayor longitud, y el primero es uno de los más
%   cortos. Si Problema no tiene solución, no termina; después de la última
%   respuesta, tampoco.
iterativo(Problema, Plan) :-
    inicial(Problema, Estado),
    length(Plan, _),
    desde(Problema, Estado, Plan).

%!  desde(+Problema, +Estado, ?Plan:list) is nondet.
%
%   Plan lleva de Estado a un estado meta de Problema. Con la longitud de
%   Plan fijada, termina.
desde(Problema, Estado, []) :-
    meta(Problema, Estado).
desde(Problema, Estado, [Accion|Plan]) :-
    sucesor(Problema, Estado, Accion, Siguiente, _),
    desde(Problema, Siguiente, Plan).
```

`iterativo/2` no lleva un límite: `length(Plan, _)` con la lista libre da
listas de longitud 0, 1, 2…, y `desde/3` con la longitud del plan fijada
termina en cada una. Es la forma que *The Power of Prolog* de Markus Triska
recomienda para la profundización iterativa, y la misma técnica que la
[sección 33.5](../capitulo-33-introspeccion-y-metainterpretes/index.md#335-limites-de-profundidad-y-profundizacion-iterativa) aplicó al
intérprete.

```prolog
?- con_limite(jarras(4, 3, 2), 5, Plan).
Plan = [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1)] ;
Plan = [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1), vaciar(1)] ;
false.

?- con_limite(jarras(4, 3, 2), 3, Plan).
false.

?- limit(3, iterativo(jarras(4, 3, 2), Plan)).
Plan = [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1)] ;
Plan = [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1), vaciar(1)] ;
Plan = [llenar(1), llenar(2), vaciar(1), pasar(2, 1), llenar(2), pasar(2, 1)].
```

`iterativo/2` tiene infinitos planes, porque los ciclos alargan cualquier
plan tanto como se quiera; `limit/2`
([capítulo 17](../capitulo-17-todas-las-soluciones/index.md#177-librarysolution_sequences)) toma los tres primeros.

La profundidad limitada termina siempre, aun en un espacio con ciclos, y no
encuentra lo que está más allá del límite. La profundización iterativa da
los planes de menor a mayor longitud, como la anchura, con la memoria de un
camino, como la profundidad. Tiene dos límites. Si el problema no tiene
solución, no termina: prueba longitudes sin fin (Csenki lo señala en el
apartado «Iterative Deepening»). Y repite el trabajo de las iteraciones anteriores; con un
factor de ramificación b, la última iteración cuesta b veces la anterior, y
la suma de todas es del orden de la última. Sin registro de visitados, lo
que crece con la longitud es el número de caminos, no el de estados:

```text
jarras(11, 4, 1), plan de 6 acciones:     6,457 inferences
jarras(9, 2, 1),  plan de 8 acciones:    36,485 inferences
jarras(8, 3, 4),  plan de 10 acciones:  305,613 inferences
jarras(13, 5, 1), plan de 12 acciones: 2,570,372 inferences
```

Cada dos acciones más, el costo se multiplica por un factor de seis a
ocho; la búsqueda en
anchura con visitados resuelve las cuatro con unas 43 000 inferencias, casi
todas de la carga de `library(assoc)`, porque cada una recorre menos de
treinta estados. La profundización iterativa conviene cuando el espacio es
enorme y el plan corto, o cuando la memoria es el límite; y su versión con
una cota sobre el costo estimado, IDA\*, es la que resuelve el rompecabezas
de la sección siguiente con poca memoria.

!!! question "Actividad"
    Predecir, sin ejecutarlas, si terminan `con_limite(jarras(4, 2, 1), 10,
    P)` e `iterativo(jarras(4, 2, 1), P)`, y cuántas respuestas da
    `con_limite(jarras(4, 3, 2), 4, P)`. Comprobarlo, la segunda con
    `call_with_inference_limit/3`.

## 40.5 Heurísticas: A\* e IDA\*

Una **heurística** estima cuántas acciones faltan desde un estado. Con ella,
la prioridad del montículo pasa a ser lo estimado (la búsqueda voraz) o el
costo del camino más lo estimado (A\*), y la profundización iterativa pone
la cota sobre esa suma (IDA\*). La página
[Heurísticas](heuristicas.md#heuristicas-a-e-ida) escribe las tres sobre el
rompecabezas de 8, con dos heurísticas admisibles, y compara todas las
estrategias del capítulo por nodos expandidos, inferencias y tiempo: sobre
un estado a 26 acciones de la meta, la anchura expande 162 401 nodos y A\*
con la distancia de Manhattan 1 852.

## 40.6 Planificación: operadores STRIPS y análisis de medios y fines

Un planificador describe las acciones por lo que exigen y lo que cambian, y
elige las acciones según las metas. La página
[Planificación](planificacion.md#planificacion-operadores-strips-y-analisis-de-medios-y-fines) escribe
el mundo de bloques del [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#2210-un-estado-como-termino-el-mundo-de-bloques)
con operadores STRIPS —precondiciones, hechos que agregan y hechos que
borran—, un planificador por análisis de medios y fines, y la anomalía de
Sussman: sin una cota sobre la longitud, el plan logra una meta, la deshace
para lograr la otra y vuelve a lograrla.

## 40.7 La vuelta a casa del Wumpus

El agente del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#207-el-agente-del-mundo-del-wumpus) encuentra el oro y
tiene que volver a la entrada pasando solo por celdas seguras. La página
[Aplicaciones](aplicaciones.md#la-vuelta-a-casa-del-wumpus) lo plantea como
un problema con las celdas seguras dentro del término, y lo resuelve con
A\* y la distancia de Manhattan, comparado con el primer camino en
profundidad.

## 40.8 El Buscaminas como búsqueda

La misma página plantea [el Buscaminas](aplicaciones.md#el-buscaminas-como-busqueda)
como búsqueda: las configuraciones de minas consistentes con los números
visibles, buscadas en profundidad con poda y comparadas con el resolvedor
con restricciones del [capítulo 23](../capitulo-23-programacion-con-restricciones/index.md#2314-buscaminas-deducir-donde-estan-las-minas);
y una partida entera como una secuencia de jugadas seguras, que termina
ganada o trabada.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; los que no terminan en algún caso lo dicen en el encabezado (`resolver_ingenuo/2`, `iterativo/2` sin solución, `planificar/3`) |
    | C3 | la búsqueda no conoce el problema: `buscar/5` recibe el problema como término y solo llama a `inicial/2`, `meta/2`, `sucesor/5` y `heuristica/3`; el mismo bucle resuelve jarras, el rompecabezas de 8 y la cueva del Wumpus |
    | C4 | `buscar/5`, `ida_estrella/4` y `deducir/3` no dejan alternativas; `heuristica/3` despacha por el nombre de la heurística, con el primer argumento indexado, para no dejar un punto de elección |
    | C6 | la frontera y los visitados son argumentos; el único estado global es el del antipatrón, `agenda_dinamica.pl`, cuyas pruebas muestran lo que deja entre una búsqueda y otra |
    | C7 | 83 pruebas en diez archivos, y 33 más en las soluciones; lo que no termina se prueba con `call_with_inference_limit/3`, y los planes se comprueban aplicándolos, además de compararlos |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir, con `visitados.pl` cargado, el plan, el costo y la
   cantidad de nodos expandidos, o la falla, de cada consulta, y
   comprobarlo: `buscar(anchura, jarras(4, 3, 4), P, C, K).` ·
   `buscar(profundidad, jarras(4, 3, 1), P, C, K).` ·
   `buscar(mejor(costo), jarras(6, 4, 3), P, C, K).`
2. **(1)** Resolver `jarras(5, 3, 4)` con las tres estrategias de
   `visitados.pl` y con `iterativo/2`. ¿Cuáles dan el mismo plan? ¿Cuál
   mueve menos agua?
3. ★ **(2)** Un granjero cruza un río con un lobo, una cabra y una col; el
   bote lleva al granjero y a lo sumo a uno de los tres. El lobo no puede
   quedar solo con la cabra, ni la cabra con la col. Describir el problema
   `rio` con `inicial/2`, `meta/2` y `sucesor/5`, y resolverlo con el bucle
   de `visitados.pl` en anchura (Luger y Stubblefield, «Depth-, Breadth-, and Best-First Search»).
4. **(2)** Tres misioneros y tres caníbales cruzan un río en un bote de dos
   lugares; en ninguna orilla los caníbales pueden superar a los misioneros
   si hay alguno. Describir el problema y encontrar el plan más corto.
5. ★ **(2)** Agregar al bucle con visitados la estrategia `anchura_lista`,
   con la frontera como una lista cerrada a la que los hijos se agregan con
   `append/3`, y medir con `time/1` las dos anchuras en
   `jarras(3001, 2999, 1)` y en el rompecabezas de 8 desde
   `ejemplo(medio, E)`, con la heurística `cero`. Explicar por qué la
   diferencia aparece en un problema y no en el otro, con la
   [sección 34.6](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#346-cuanto-se-gana).
6. ★ **(2)** Reescribir `buscar_con_agenda/2` para que borre la agenda al
   empezar y al terminar, también si la búsqueda falla o lanza una
   excepción, con `setup_call_cleanup/3`
   ([capítulo 25](../capitulo-25-errores-y-excepciones/index.md)). Mostrar que las pruebas de la
   segunda búsqueda dejan de fallar, y dar una consulta en la que el
   programa corregido todavía responde mal.
7. **(2)** Escribir `recorrido_caballo(N, Recorrido)`: un recorrido del
   caballo de ajedrez por un tablero de N × N desde la casilla 1-1, que pasa
   una vez por cada casilla. Usar la lista de las casillas que quedan, con
   `select/3`, y encontrar uno para N = 5.
8. **(2)** Escribir `mas_cortos(Problema, Planes)`: la lista de todos los
   planes de longitud mínima de un problema, con la idea de `iterativo/2`.
   Escribir el encabezado con el modo y la determinación, y explicar qué
   hace el predicado con un problema sin solución.
9. ★ **(2)** Agregar la heurística `doble`, el doble de `manhattan`, que no
   es admisible. Predecir si A\* con `doble` sobre `ejemplo(dificil, E)`
   expande más o menos nodos que con `manhattan`, y si el plan sigue siendo
   de 26 acciones; comprobarlo y explicar el resultado.
10. **(2)** En otra versión del mundo de bloques no hay pinza: la acción
    `mover(B, De, A)` lleva el bloque libre B desde De a A, un bloque libre
    o la mesa. Escribir los operadores STRIPS de esa versión y el plan de
    la anomalía de Sussman con `planificar/3`. ¿Cuántas acciones tiene?
11. **(2)** Con cuatro bloques, invertir una torre: de d sobre c sobre b
    sobre a, a a sobre b sobre c sobre d. Comparar la longitud del plan y
    las inferencias de `planificar/3` con las de `plan/3` del
    [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md).
12. ★ **(2)** En la cueva `grande` de `wumpus.pl`, predecir cuántos pasos
    tiene la vuelta desde 5-5 y desde 3-3, y cuántos nodos expande A\* en
    cada caso comparado con la anchura. Dar además una lista de celdas
    seguras desde la que la entrada no se alcance, y la respuesta de
    `buscar/5`.
13. **(2)** Escribir `deducir/4`, como el del
    [capítulo 23](../capitulo-23-programacion-con-restricciones/index.md), que además usa la cantidad de minas del
    tablero en total, y aplicarlo a `tablero(chico, T)` con 2 minas.
14. **(3)** Con `jugar/6`, contar en cuántos de 20 tableros de 6 × 6 con 5
    minas elegidas al azar, con las semillas 1 a 20 y la partida empezada
    en una celda sin mina, se gana sin adivinar ninguna jugada.

## Resumen

| | |
|---|---|
| **espacio de estados** | un estado inicial, acciones con su costo y una condición de meta; un **plan** es una secuencia de acciones |
| **frontera** | los nodos generados y todavía no expandidos; su estructura de datos decide la estrategia |
| **en profundidad, en anchura, costo uniforme** | la frontera como pila, como cola o como montículo ordenado por el costo |
| **visitados** | el registro de los estados vistos con su mejor costo: la búsqueda termina en un espacio finito con ciclos |
| **rastro** | los estados del camino actual, que no se repiten |
| **profundización iterativa** | búsquedas en profundidad con límites crecientes; el plan más corto con la memoria de un camino |
| **heurística admisible** | una estimación de lo que falta que nunca estima de más |
| **búsqueda voraz, A\*, IDA\*** | prioridad h, prioridad g + h, y la profundización iterativa con la cota sobre g + h |
| `library(heaps)` | `empty_heap/1`, `add_to_heap/4`, `get_from_heap/4`, `list_to_heap/2`, `heap_size/2`: un montículo de prioridades |
| `inicial/2`, `meta/2`, `sucesor/5`, `heuristica/3` | la interfaz de un problema, con el problema como primer argumento |
| `resolver_ingenuo/2` | la búsqueda recursiva de Prolog, que no termina con ciclos |
| `buscar/5`, `bucle/6`, `bucle/7`, `hijos/3` | el bucle único, sin y con visitados |
| `frontera_inicial/4`, `vacia/2`, `sacar/4`, `agregar/5`, `prioridad/4` | las tres fronteras y las prioridades |
| `buscar_con_agenda/2`, `limpiar_agenda/0` | el antipatrón: la agenda en la base de datos dinámica |
| `resolver_sin_ciclos/2`, `reinas/2` | el rastro del camino y la lista de lo que queda |
| `con_limite/3`, `iterativo/2` | la profundidad limitada y la profundización iterativa |
| `ida_estrella/4` | IDA\* |
| `nth0/4` | `nth0(I, L, X, R)`: X en la posición I de L, contando desde 0, y R el resto; en sentido inverso, inserta ([Heurísticas](heuristicas.md#heuristicas-a-e-ida)) |
| `selectchk/3` | como `select/3`, quita la primera aparición de un elemento, sin alternativas; en las soluciones |
| `operador/4`, `aplicar/3`, `planificar/3`, `lograr/4` | operadores STRIPS y análisis de medios y fines ([Planificación](planificacion.md#planificacion-operadores-strips-y-analisis-de-medios-y-fines)) |
| `seguras/2`, `primer_camino/2` | la vuelta del Wumpus ([Aplicaciones](aplicaciones.md#la-vuelta-a-casa-del-wumpus)) |
| `configuracion/3`, `deducir/3`, `jugar/6`, `visible/5` | el Buscaminas como búsqueda ([Aplicaciones](aplicaciones.md#el-buscaminas-como-busqueda)) |
| **[Patrón 54](../patrones.md#54-la-frontera-decide-la-estrategia)** | la frontera decide la estrategia |
| `random_permutation/2` | una permutación al azar de una lista (en las soluciones) |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Búsqueda en juegos de dos jugadores: minimax y la poda alfa-beta | [capítulo 41](../capitulo-41-juegos/index.md) |
| La planificación por regresión de metas (WARPLAN) y la anomalía de Sussman | [capítulo 70](../capitulo-70-proyecto-planificacion-regresion/index.md) |
| La búsqueda mejor primero en grafos Y/O | [capítulo 71](../capitulo-71-proyecto-grafos-o/index.md) |
| A\* aplicado a la planificación de tareas | [capítulo 72](../capitulo-72-proyecto-planificacion-tareas/index.md) |
| El cubo de Rubik como espacio de estados | [capítulo 74](../capitulo-74-proyecto-cubo-rubik/index.md) |
| A\* e IDA\* en grillas: robots, laberintos y el caballo | [capítulo 76](../capitulo-76-proyecto-robots-laberintos-caballo/index.md) |
| La vuelta del Wumpus dentro de un agente completo, con el A\* de este capítulo reutilizado para ir a cualquier celda | [capítulo 77](../capitulo-77-proyecto-mundo-wumpus/index.md) |

## Referencias

- Attila Csenki, *Applications of Prolog*, Ventus Publishing (Bookboon),
  2009 — capítulos «Blind Search» (con los apartados «Depth First Search»,
  «Breadth First Search», «Bounded Depth First Search», «Iterative
  Deepening» y «Application: The Eight Puzzle») e «Informed Search» (con
  «Iterative Deepening A\* and its ε-Admissible Version» y «Case Study:
  The Eight Puzzle Revisited»). Sin edición en línea de acceso libre
  verificada. El capítulo toma la escalera de búsquedas a ciegas e
  informadas, el rompecabezas de 8 como caso de estudio, IDA\* y la
  observación de que la profundización iterativa no termina sin solución.
- Ivan Bratko, *Prolog Programming for Artificial Intelligence*,
  Addison-Wesley, 1986 — capítulos «Basic Problem-Solving Strategies» y
  «Best-first: A Heuristic Search Principle»; y la 4.ª edición, Pearson,
  2012, capítulo «Planning». Sin edición en línea de acceso libre. De allí
  vienen el espacio de estados con sucesores y costos, la admisibilidad de
  A\* y su demostración, y el reparto de la longitud del plan entre el plan
  previo y el posterior en el análisis de medios y fines.
- George F. Luger y William A. Stubblefield, *AI Algorithms, Data
  Structures, and Idioms in Prolog, Lisp, and Java*, Pearson
  Addison-Wesley, 2009 — capítulo «Depth- Breadth-, and Best-First
  Search», apartado «Designing Alternative Search Strategies». Sin edición
  en línea de acceso libre verificada. Es el origen de la idea de un solo
  programa de búsqueda en el que solo cambia el manejo de la lista de
  estados abiertos, y del problema del granjero, el lobo, la cabra y la col
  del ejercicio 3.
- Neil C. Rowe, *Artificial Intelligence through Prolog*, Prentice-Hall,
  1988 — capítulos «Implementing search»
  ([en línea](https://faculty.nps.edu/ncrowe/book/chap10.html)) y
  «Abstraction in search»
  ([en línea](https://faculty.nps.edu/ncrowe/book/chap11.html)). El
  capítulo toma el problema descrito por sus estados y sucesores, separado
  de la búsqueda, y el análisis de medios y fines.
- Feliks Kluźniak y Stanisław Szpakowicz, *Prolog for Programmers*,
  Academic Press, 1985 — apartado 8.1, «Planning».
  [Edición en línea](https://www.site.uottawa.ca/~szpak/pub/P4P/Prolog_for_Programmers_neat.pdf).
  Presenta WARPLAN, de David Warren, y la planificación por regresión de
  metas que la [sección 40.6](#406-planificacion-operadores-strips-y-analisis-de-medios-y-fines)
  menciona y el [capítulo 70](../capitulo-70-proyecto-planificacion-regresion/index.md)
  construye.
- William F. Clocksin, *Clause and Effect: Prolog Programming for the
  Working Programmer*, Springer, 1997 — hojas de trabajo «Searching a
  Cyclic Graph» y «Partial Maps with a Parameter». Sin edición en línea de
  acceso libre. De allí vienen el rastro de los nodos del camino actual y
  la lista de los nodos que quedan, reducida con `select/3`.
- Markus Triska, *The Power of Prolog*.
  [En línea](https://www.metalevel.at/prolog). El capítulo toma la
  profundización iterativa escrita con `length/2` sobre la lista del plan.
- Richard E. Fikes y Nils J. Nilsson, «STRIPS: A New Approach to the
  Application of Theorem Proving to Problem Solving», *Artificial
  Intelligence* 2(3–4), 1971, y Gerald J. Sussman, *A Computational Model
  of Skill Acquisition*, tesis doctoral, MIT, 1973: el origen de los
  operadores STRIPS y de la anomalía de Sussman, citados a través de los
  libros anteriores.

Los programas del capítulo son propios, escritos para el curso: las
fuentes aportan los algoritmos, los problemas y los análisis de costo, no
código; el bucle con la frontera como argumento, los caminos compartidos
entre los nodos, el registro de visitados en `library(assoc)` y todas las
mediciones son del curso.
