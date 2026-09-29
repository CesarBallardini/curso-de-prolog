# Heurísticas: A\* e IDA\*

Esta página contiene la sección [40.5](index.md#405-heuristicas-a-e-ida) del
[capítulo 40](index.md): la búsqueda voraz, A\* e IDA\* sobre el rompecabezas
de 8, y la comparación medida de las estrategias del capítulo. El ejemplo
está en `puzzle8.pl`, en `ejemplos/capitulo-40/`, con sus pruebas, y corre
en SWISH.

## Heurísticas: A\* e IDA\*

El **rompecabezas de 8** tiene ocho fichas numeradas y un hueco en un marco
de 3 × 3; cada acción desliza al hueco una ficha vecina. Un estado es la
lista de las nueve casillas por filas, con 0 en el hueco; la meta es
`[1, 2, 3, 4, 5, 6, 7, 8, 0]`. El problema `puzzle(Inicial, Heuristica)`
lleva en el término el estado inicial y el nombre de una **heurística**, una
función que estima cuántas acciones faltan:

<!-- ejemplo: capitulo-40/puzzle8.pl predicado: inicial/2 meta/2 sucesor/5 movimiento/3 intercambiar/5 heuristica/3 estimacion/3 distancia/3 consulta: ejemplo(facil, E), sucesor(puzzle(E, cero), E, A, S, C). -->
```prolog
%!  inicial(+Problema, -Estado) is det.
%
%   Estado es el estado de partida de Problema.
inicial(puzzle(Inicial, _), Inicial).

%!  meta(+Problema, +Estado) is semidet.
%
%   Estado es la disposición buscada: las fichas en orden y el hueco al
%   final.
meta(puzzle(_, _), [1, 2, 3, 4, 5, 6, 7, 8, 0]).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   Accion mueve el hueco de Estado en una dirección y lleva a Siguiente,
%   con costo 1.
sucesor(puzzle(_, _), Estado, Accion, Siguiente, 1) :-
    nth0(Hueco, Estado, 0),
    movimiento(Accion, Hueco, Destino),
    nth0(Destino, Estado, Ficha),
    intercambiar(Estado, Hueco, Destino, Ficha, Siguiente).

%!  movimiento(?Accion, +Hueco:integer, -Destino:integer) is nondet.
%
%   Mover el hueco con Accion lo lleva de la casilla Hueco a Destino, en un
%   marco de 3 x 3 con las casillas numeradas de 0 a 8 por filas.
movimiento(arriba, H, D) :-
    H >= 3,
    D is H - 3.
movimiento(abajo, H, D) :-
    H < 6,
    D is H + 3.
movimiento(izquierda, H, D) :-
    H mod 3 > 0,
    D is H - 1.
movimiento(derecha, H, D) :-
    H mod 3 < 2,
    D is H + 1.

%!  intercambiar(+Estado, +Hueco:integer, +Destino:integer, +Ficha,
%!               -Siguiente) is det.
%
%   Siguiente es Estado con Ficha en la casilla Hueco y el hueco en Destino.
intercambiar(Estado, Hueco, Destino, Ficha, Siguiente) :-
    nth0(Hueco, Estado, 0, Resto0),
    nth0(Hueco, Estado1, Ficha, Resto0),
    nth0(Destino, Estado1, Ficha, Resto1),
    nth0(Destino, Siguiente, 0, Resto1).

%!  heuristica(+Problema, +Estado, -H:integer) is det.
%
%   H estima cuántas acciones faltan desde Estado, con la heurística de
%   Problema. Las tres nunca estiman de más.
heuristica(puzzle(_, Nombre), Estado, H) :-
    estimacion(Nombre, Estado, H).

%!  estimacion(+Nombre, +Estado, -H:integer) is det.
%
%   H es lo que estima la heurística Nombre desde Estado: cero, fuera o
%   manhattan.
estimacion(cero, _, 0).
estimacion(fuera, Estado, H) :-
    aggregate_all(count,
                  ( nth1(I, Estado, Ficha),
                    Ficha =\= 0,
                    Ficha =\= I ),
                  H).
estimacion(manhattan, Estado, H) :-
    aggregate_all(sum(D),
                  ( nth0(I, Estado, Ficha),
                    Ficha =\= 0,
                    distancia(I, Ficha, D) ),
                  H).

%!  distancia(+I:integer, +Ficha:integer, -D:integer) is det.
%
%   D es la cantidad de movimientos en línea recta entre la casilla I y la
%   casilla de Ficha en la meta, la Ficha-1.
distancia(I, Ficha, D) :-
    J is Ficha - 1,
    D is abs(I // 3 - J // 3) + abs(I mod 3 - J mod 3).
```

`intercambiar/5` usa `nth0/4`, la forma de cuatro argumentos de `nth0/3`
([capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#221-el-resto-de-librarylists)): `nth0(I, L, X, R)` se cumple si X
está en la posición I de L, contando desde 0, y R es L sin él. Con el
índice dado, saca un elemento y deja el resto, y en sentido inverso lo
inserta: `intercambiar/5` quita el hueco, pone la ficha en su lugar, y hace lo mismo en la casilla de
destino. Las heurísticas son `fuera`, la cantidad de fichas fuera de su
lugar, y `manhattan`, la suma de las distancias de cada ficha a su casilla
contando solo movimientos horizontales y verticales. Ninguna **estima de
más**: cada ficha fuera de lugar necesita al menos un movimiento, y al menos
tantos como su distancia. Una heurística con esa propiedad se llama
**admisible**.

```prolog
?- ejemplo(facil, E), heuristica(puzzle(E, fuera), E, F), heuristica(puzzle(E, manhattan), E, M).
E = [2, 4, 3, 7, 1, 5, 0, 8, 6],
F = 6,
M = 8.
```

El bucle de `visitados.pl` no cambia. Cambia la prioridad del montículo: dos
cláusulas más de `prioridad/4`.

<!-- ejemplo: capitulo-40/puzzle8.pl predicado: prioridad/4 -->
```prolog
%!  prioridad(+Criterio, +Problema, +Nodo, -Prioridad:number) is det.
%
%   Prioridad es el valor de Nodo según Criterio; se extrae primero el menor.
%   Con costo, es el costo del camino: la búsqueda de costo uniforme; con
%   heuristica, lo que la heurística estima que falta: la búsqueda voraz;
%   con a_estrella, la suma de los dos: A*.
prioridad(costo, _, nodo(_, _, G), G).
prioridad(heuristica, Problema, nodo(Estado, _, _), H) :-
    heuristica(Problema, Estado, H).
prioridad(a_estrella, Problema, nodo(Estado, _, G), F) :-
    heuristica(Problema, Estado, H),
    F is G + H.
```

`mejor(heuristica)` es la búsqueda **voraz**: saca el nodo que parece más
cerca de la meta, sin considerar lo que costó llegar. `mejor(a_estrella)` es
**A\***: la prioridad es f = g + h, el costo del camino más lo que la
heurística estima que falta. Con una heurística admisible, A\* devuelve un
plan de costo mínimo (Bratko lo demuestra en el apartado «Best-first
search»); con h = 0 es la búsqueda de costo uniforme.

```prolog
?- ejemplo(facil, E), buscar(mejor(a_estrella), puzzle(E, manhattan), Plan, Costo, K).
E = [2, 4, 3, 7, 1, 5, 0, 8, 6],
Plan = [arriba, derecha, arriba, izquierda, abajo, derecha, derecha, abajo],
Costo = 8,
K = 10.

?- ejemplo(medio, E), buscar(mejor(heuristica), puzzle(E, manhattan), _, Costo, K).
E = [1, 6, 3, 7, 5, 4, 0, 8, 2],
Costo = 72,
K = 182.

?- ejemplo(medio, E), buscar(mejor(a_estrella), puzzle(E, manhattan), _, Costo, K).
E = [1, 6, 3, 7, 5, 4, 0, 8, 2],
Costo = 20,
K = 530.
```

La búsqueda voraz expande pocos nodos y devuelve un plan de 72 acciones
donde alcanza con 20. A\* devuelve el de 20.

**IDA\*** es la profundización iterativa con la cota puesta sobre f en lugar
de sobre la longitud (Csenki, apartado «Iterative Deepening A\* and its
ε-Admissible Version», después de Korf). Cada iteración busca en
profundidad, con el rastro del camino actual, y abandona una rama
en cuanto su f pasa la cota; si no encuentra un plan, la cota siguiente es
el menor f que la pasó. La memoria es la de un camino.

<!-- ejemplo: capitulo-40/puzzle8.pl predicado: ida_estrella/4 iteracion/7 acotada/8 probar/9 menor/3 consulta: ejemplo(medio, E), ida_estrella(puzzle(E, manhattan), P, C, K). -->
```prolog
%!  ida_estrella(+Problema, -Plan:list, -Costo:number, -Expandidos:integer)
%!      is semidet.
%
%   Plan es un plan de costo mínimo de Problema, si su heurística nunca
%   estima de más. Busca en profundidad los caminos cuyo costo más la
%   heurística no pasa de una cota; si no hay plan dentro de la cota, la
%   siguiente es el menor valor que la pasó. Expandidos cuenta los nodos
%   expandidos en todas las iteraciones. Falla si no hay plan.
ida_estrella(Problema, Plan, Costo, Expandidos) :-
    inicial(Problema, Estado),
    heuristica(Problema, Estado, Cota),
    iteracion(Problema, Estado, Cota, 0, Plan, Costo, Expandidos).

%!  iteracion(+Problema, +Estado, +Cota:number, +K0:integer, -Plan:list,
%!            -Costo:number, -K:integer) is semidet.
%
%   Busca con Cota, y si no encuentra un plan, con la cota siguiente.
iteracion(Problema, Estado, Cota, K0, Plan, Costo, K) :-
    acotada(Problema, Estado, 0, Cota, [Estado], Resultado, K0, K1),
    (   Resultado = plan(Plan, Costo)
    ->  K = K1
    ;   Resultado = cota(Siguiente),
        Siguiente \== infinito,
        iteracion(Problema, Estado, Siguiente, K1, Plan, Costo, K)
    ).

%!  acotada(+Problema, +Estado, +G:number, +Cota:number, +Rastro:list,
%!          -Resultado, +K0:integer, -K:integer) is det.
%
%   Resultado es plan(Plan, Costo) si hay un plan desde Estado, al que se
%   llegó con costo G, sin pasar de Cota ni repetir los estados de Rastro;
%   si no, es cota(C), con C el menor costo más heurística que pasó de Cota,
%   o infinito si ninguno pasó.
acotada(Problema, Estado, G, Cota, Rastro, Resultado, K0, K) :-
    heuristica(Problema, Estado, H),
    F is G + H,
    (   F > Cota
    ->  Resultado = cota(F),
        K = K0
    ;   meta(Problema, Estado)
    ->  Resultado = plan([], G),
        K = K0
    ;   K1 is K0 + 1,
        findall(t(Accion, Siguiente, C),
                ( sucesor(Problema, Estado, Accion, Siguiente, C),
                  \+ memberchk(Siguiente, Rastro) ),
                Transiciones),
        probar(Transiciones, Problema, G, Cota, Rastro, infinito,
               Resultado, K1, K)
    ).

%!  probar(+Transiciones:list, +Problema, +G:number, +Cota:number,
%!         +Rastro:list, +Menor, -Resultado, +K0:integer, -K:integer) is det.
%
%   Prueba las transiciones en orden hasta que una lleva a un plan; Menor es
%   la menor cota que pasaron las ya probadas.
probar([], _, _, _, _, Menor, cota(Menor), K, K).
probar([t(Accion, Siguiente, C)|Ts], Problema, G, Cota, Rastro, Menor0,
       Resultado, K0, K) :-
    G1 is G + C,
    acotada(Problema, Siguiente, G1, Cota, [Siguiente|Rastro], R, K0, K1),
    (   R = plan(Plan, Costo)
    ->  Resultado = plan([Accion|Plan], Costo),
        K = K1
    ;   R = cota(F),
        menor(F, Menor0, Menor),
        probar(Ts, Problema, G, Cota, Rastro, Menor, Resultado, K1, K)
    ).

%!  menor(+A, +B, -Menor) is det.
%
%   Menor es el menor de A y B, números o infinito.
menor(infinito, B, B) :-
    !.
menor(A, infinito, A) :-
    !.
menor(A, B, M) :-
    M is min(A, B).
```

`acotada/8` no deja alternativas: devuelve un plan o la cota siguiente como
un término, `plan(Plan, Costo)` o `cota(C)`, y `probar/9` recorre los hijos
llevando la menor cota vista, con `infinito` para ninguna. El contador de
nodos expandidos pasa por todas las llamadas como un par de argumentos.

```prolog
?- ejemplo(medio, E), ida_estrella(puzzle(E, manhattan), _, Costo, K).
E = [1, 6, 3, 7, 5, 4, 0, 8, 2],
Costo = 20,
K = 1394.
```

Las estrategias, medidas en esta máquina sobre los estados `medio`, a 20
acciones de la meta, y `dificil`, a 26 (acciones del plan, nodos
expandidos, inferencias y segundos, con las bibliotecas ya cargadas):

| Estrategia | `medio` | `dificil` |
|---|---|---|
| anchura | 20 · 48 820 · 13 304 124 · 2,70 | 26 · 162 401 · 41 997 056 · 9,28 |
| costo uniforme | 20 · 38 937 · 11 918 359 · 2,44 | 26 · 166 383 · 46 357 972 · 10,27 |
| voraz, `manhattan` | 72 · 182 · 63 335 · 0,02 | 82 · 366 · 134 429 · 0,02 |
| A\*, `fuera` | 20 · 2 992 · 1 097 852 · 0,25 | 26 · 32 760 · 12 036 437 · 2,66 |
| A\*, `manhattan` | 20 · 530 · 188 376 · 0,03 | 26 · 1 852 · 666 455 · 0,14 |
| IDA\*, `fuera` | 20 · 12 972 · 3 061 411 · 0,52 | 26 · 182 803 · 43 029 938 · 7,33 |
| IDA\*, `manhattan` | 20 · 1 394 · 351 408 · 0,05 | 26 · 2 078 · 508 218 · 0,08 |

Tres lecturas. La heurística mejor informada —`manhattan` es siempre mayor
o igual que `fuera`, y las dos admisibles— expande muchos menos nodos: de
32 760 a 1 852 en `dificil`. IDA\* expande más nodos que A\*, porque repite
las iteraciones y no recuerda los estados de otras ramas, pero no guarda
frontera, y con `manhattan` resulta incluso más rápido. Y la búsqueda a
ciegas llega en `dificil` a 162 401 expansiones, cerca de las 181 440
disposiciones alcanzables desde cualquier estado. En SWISH, la anchura
sobre `dificil` tarda unos 6,5 segundos y A\* con `manhattan` sobre `medio`
algo más de un segundo.

!!! question "Actividad"
    Con `ejemplo(dificil, E)`, predecir si la búsqueda voraz con `fuera`
    devuelve un plan más largo o más corto que con `manhattan`, y si A\*
    con la heurística `cero` expande más o menos nodos que la anchura.
    Comprobarlo con `buscar/5`.
