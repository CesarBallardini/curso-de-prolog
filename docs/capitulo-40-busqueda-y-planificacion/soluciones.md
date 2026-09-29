# Soluciones del capítulo 40 — Búsqueda y planificación

El código de esta página está en `ejemplos/capitulo-40/`: `soluciones.pl`
para los ejercicios 3, 4, 5, 7 y 8, que repite el bucle con visitados y el
problema de las jarras y corre en SWISH; `soluciones_strips.pl` para el 10,
que también corre en SWISH; y cuatro archivos que cargan uno del capítulo y
por eso no corren en SWISH: `soluciones_puzzle.pl` (ejercicios 5 y 9, sobre
`puzzle8.pl`), `soluciones_agenda.pl` (6, sobre `agenda_dinamica.pl`),
`soluciones_torre.pl` (11, sobre `strips.pl`) y `soluciones_buscaminas.pl`
(13 y 14, sobre `buscaminas.pl`). Cada uno tiene sus pruebas. Los
ejercicios 1, 2 y 12 se resuelven con los archivos del capítulo.

## 1

Con `visitados.pl` cargado:

<!-- ejemplo: capitulo-40/visitados.pl predicado: meta/2 -->
```prolog
%!  meta(+Problema, +Estado) is semidet.
%
%   Estado es un estado buscado de Problema: una de las jarras tiene la
%   cantidad pedida.
meta(jarras(_, _, M), j(A, B)) :-
    (   A =:= M
    ->  true
    ;   B =:= M
    ).
```

```prolog
?- buscar(anchura, jarras(4, 3, 4), P, C, K).
P = [llenar(1)],
C = 4,
K = 1.

?- buscar(profundidad, jarras(4, 3, 1), P, C, K).
P = [llenar(1), pasar(1, 2)],
C = 7,
K = 3.

?- buscar(mejor(costo), jarras(6, 4, 3), P, C, K).
false.
```

La primera se resuelve con una acción: se expande solo el estado inicial, y
el primer hijo que se extrae de la cola, `j(4, 0)`, es una meta. En la segunda,
la profundidad sigue la primera acción, `llenar(1)`, y después `pasar(1,
2)` deja 1 litro en la jarra grande: tres expansiones, porque después de
`llenar(1)` la pila tiene arriba `j(4, 3)`, el hijo de `llenar(2)`, que se
expande sin hijos nuevos antes de que se extraiga `j(1, 3)`. La tercera falla: con jarras de 6 y 4 litros,
todas las cantidades que se pueden medir son múltiplos de 2, el máximo común
divisor de las capacidades; con visitados, la búsqueda recorre los estados
alcanzables y la frontera se vacía.

## 2

```prolog
?- buscar(anchura, jarras(5, 3, 4), P, C, K).
P = [llenar(1), pasar(1, 2), vaciar(2), pasar(1, 2), llenar(1), pasar(1, 2)],
C = 19,
K = 12.

?- buscar(profundidad, jarras(5, 3, 4), P, C, K).
P = [llenar(1), pasar(1, 2), vaciar(2), pasar(1, 2), llenar(1), pasar(1, 2)],
C = 19,
K = 7.

?- buscar(mejor(costo), jarras(5, 3, 4), P, C, K).
P = [llenar(1), pasar(1, 2), vaciar(2), pasar(1, 2), llenar(1), pasar(1, 2)],
C = 19,
K = 13.
```

Las tres estrategias dan el mismo plan, y `iterativo/2` de
`profundizacion.pl` también: el plan más corto es también el que mueve
menos agua, y la búsqueda en profundidad lo encuentra primero porque la
primera acción que prueba, `llenar(1)`, es la buena. Lo que cambia es el
trabajo: 7, 12 y 13 nodos expandidos.

## 3

El estado es `r(G, L, C, K)`, la orilla de cada uno. Las cláusulas del
problema, en `soluciones.pl`:

<!-- ejemplo: capitulo-40/soluciones.pl fragmento: sucesor(rio, r(G, L, C, K), cruzar(Quien), Siguiente, 1) :- .. segura(Siguiente). -->
```prolog
sucesor(rio, r(G, L, C, K), cruzar(Quien), Siguiente, 1) :-
    otra(G, G1),
    pasajero(Quien, r(G, L, C, K), G1, Siguiente),
    segura(Siguiente).
```

<!-- ejemplo: capitulo-40/soluciones.pl predicado: otra/2 pasajero/4 segura/1 consulta: buscar(anchura, rio, Plan, Costo, Expandidos). -->
```prolog
% otra(O1, O2): O2 es la orilla opuesta a O1.
otra(i, d).
otra(d, i).

%!  pasajero(?Quien, +Estado, +Orilla, -Siguiente) is nondet.
%
%   El granjero cruza a Orilla, solo o con Quien, que estaba en su misma
%   orilla, y el río queda en Siguiente.
pasajero(solo, r(_, L, C, K), G1, r(G1, L, C, K)).
pasajero(lobo, r(G, G, C, K), G1, r(G1, G1, C, K)).
pasajero(cabra, r(G, L, G, K), G1, r(G1, L, G1, K)).
pasajero(col, r(G, L, C, G), G1, r(G1, L, C, G1)).

%!  segura(+Estado) is semidet.
%
%   En Estado, la cabra no queda sin el granjero con el lobo ni con la col.
segura(r(G, L, C, K)) :-
    \+ ( C == L, C \== G ),
    \+ ( C == K, C \== G ).
```

`pasajero/4` exige, con la misma variable en dos lugares, que el pasajero
esté en la orilla del granjero, y `segura/1` descarta los estados en que la
cabra queda sin el granjero junto al lobo o a la col.

```prolog
?- buscar(anchura, rio, Plan, Costo, Expandidos).
Plan = [cruzar(cabra), cruzar(solo), cruzar(lobo), cruzar(cabra), cruzar(col), cruzar(solo), cruzar(cabra)],
Costo = 7,
Expandidos = 9.
```

El granjero lleva la cabra, vuelve, lleva el lobo, **trae de vuelta la
cabra**, lleva la col, vuelve y lleva la cabra. `mas_cortos/2` del
ejercicio 8 muestra que hay otro plan de siete cruces, con la col antes que
el lobo.

## 4

<!-- ejemplo: capitulo-40/soluciones.pl fragmento: sucesor(misioneros, m(M, C, B), cruzan(DM, DC), m(M1, C1, B1), 1) :- .. a_salvo(M2, C2). -->
```prolog
sucesor(misioneros, m(M, C, B), cruzan(DM, DC), m(M1, C1, B1), 1) :-
    member(DM-DC, [1-0, 2-0, 0-1, 0-2, 1-1]),
    (   B == i
    ->  M1 is M - DM,
        C1 is C - DC,
        B1 = d
    ;   M1 is M + DM,
        C1 is C + DC,
        B1 = i
    ),
    between(0, 3, M1),
    between(0, 3, C1),
    a_salvo(M1, C1),
    M2 is 3 - M1,
    C2 is 3 - C1,
    a_salvo(M2, C2).
```

<!-- ejemplo: capitulo-40/soluciones.pl predicado: a_salvo/2 consulta: buscar(anchura, misioneros, Plan, Costo, Expandidos). -->
```prolog
%!  a_salvo(+M:integer, +C:integer) is semidet.
%
%   En una orilla con M misioneros y C caníbales, los caníbales no superan
%   a los misioneros, o no hay misioneros.
a_salvo(M, C) :-
    (   M =:= 0
    ->  true
    ;   M >= C
    ).
```

El estado `m(M, C, B)` guarda solo la orilla de partida; la otra se calcula
como 3 − M y 3 − C, y las dos tienen que estar a salvo.

```prolog
?- buscar(anchura, misioneros, Plan, Costo, Expandidos).
Plan = [cruzan(0, 2), cruzan(0, 1), cruzan(0, 2), cruzan(0, 1), cruzan(2, 0), cruzan(1, 1), cruzan(2, 0), cruzan(0, 1), cruzan(0, 2), cruzan(1, 0), cruzan(1, 1)],
Costo = 11,
Expandidos = 14.
```

Once cruces: la búsqueda en anchura asegura que no hay un plan más corto.

## 5

`soluciones.pl` agrega las tres cláusulas al bucle de las jarras, y
`soluciones_puzzle.pl` las mismas al de `puzzle8.pl`:

<!-- ejemplo: capitulo-40/soluciones_puzzle.pl fragmento: %!  vacia(+Estrategia, -Frontera) is det. .. append(Cola0, Nodos, Cola). -->
```prolog
%!  vacia(+Estrategia, -Frontera) is det.
%
%   Para anchura_lista, la frontera es una lista cerrada, vacía al empezar.
vacia(anchura_lista, []).

%!  sacar(+Estrategia, +Frontera0, -Nodo, -Frontera) is semidet.
%
%   Para anchura_lista, Nodo es el primero de la lista.
sacar(anchura_lista, [Nodo|Cola], Nodo, Cola).

%!  agregar(+Estrategia, +Problema, +Nodos:list, +Frontera0, -Frontera)
%!      is det.
%
%   Para anchura_lista, Nodos van al final de la lista, con append/3.
agregar(anchura_lista, _, Nodos, Cola0, Cola) :-
    append(Cola0, Nodos, Cola).
```

Medido en esta máquina, con las bibliotecas ya cargadas:

```text
?- time(buscar(anchura, jarras(3001, 2999, 1), P, _, K)).
% 1,704,599 inferences, 0.344 CPU in 0.356 seconds (96% CPU, 4958833 Lips)
?- time(buscar(anchura_lista, jarras(3001, 2999, 1), P, _, K)).
% 1,632,772 inferences, 0.297 CPU in 0.328 seconds (90% CPU, 5499864 Lips)

?- ejemplo(medio, E), time(buscar(anchura, puzzle(E, cero), _, C, K)).
% 13,304,121 inferences, 2.797 CPU in 2.881 seconds (97% CPU, 4756781 Lips)
?- ejemplo(medio, E), time(buscar(anchura_lista, puzzle(E, cero), _, C, K)).
% 535,204,547 inferences, 54.500 CPU in 55.088 seconds (99% CPU, 9820267 Lips)
```

`append/3` recorre la cola entera en cada agregado, y cuesta lo que la
cola mide. En las jarras, el espacio de estados es casi una línea: cada
estado tiene uno o dos sucesores nuevos, y la cola nunca guarda más que
unos pocos nodos, así que recorrerla no cuesta nada. En el rompecabezas, la
cola guarda un nivel entero del árbol, miles de nodos, y cada una de las
48 820 expansiones la recorre: cuarenta veces más inferencias y veinte veces
más tiempo. Es la medición de la
[sección 34.6](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#346-cuanto-se-gana), y la razón para usar la cola
diferencia aunque en un problema chico no se note.

## 6

<!-- ejemplo: capitulo-40/soluciones_agenda.pl predicado: buscar_limpio/2 inicial/2 meta/2 sucesor/5 consulta: buscar_limpio(jarras(4, 3, 2), _), buscar_limpio(jarras(4, 3, 1), P). -->
```prolog
%!  buscar_limpio(+Problema, -Plan:list) is semidet.
%
%   Como buscar_con_agenda/2, con la agenda vacía al empezar y al terminar.
buscar_limpio(Problema, Plan) :-
    setup_call_cleanup(limpiar_agenda,
                       buscar_con_agenda(Problema, Plan),
                       limpiar_agenda).

%!  inicial(+Problema, -Estado) is det.
%
%   Estado es el estado de partida de Problema. desde(E, J) es el problema
%   J con E como estado inicial.
inicial(desde(Estado, _), Estado).
% prudente(J): el problema J, sin los estados desde los que no hay plan.
inicial(prudente(J), Estado) :-
    inicial(J, Estado).

%!  meta(+Problema, +Estado) is semidet.
%
%   Estado es un estado buscado de Problema: en desde(E, J), uno de J.
meta(desde(_, J), Estado) :-
    meta(J, Estado).
meta(prudente(J), Estado) :-
    meta(J, Estado).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   Accion lleva de Estado a Siguiente con Costo: en desde(E, J), como en J.
sucesor(desde(_, J), Estado, Accion, Siguiente, Costo) :-
    sucesor(J, Estado, Accion, Siguiente, Costo).
sucesor(prudente(J), Estado, Accion, Siguiente, Costo) :-
    sucesor(J, Estado, Accion, Siguiente, Costo),
    buscar_limpio(desde(Siguiente, J), _).
```

`setup_call_cleanup/3` borra la agenda antes de la búsqueda y después,
cuando la búsqueda termina, falla o lanza una excepción. Las pruebas de
`agenda_dinamica.plt` que mostraban la segunda búsqueda equivocada tienen
su versión correcta en `soluciones_agenda.plt`:

```prolog
?- buscar_limpio(jarras(4, 3, 2), _), buscar_limpio(jarras(4, 3, 1), P).
P = [llenar(1), pasar(1, 2)].

?- call_with_inference_limit(buscar_limpio(prudente(jarras(4, 3, 2)), P), 1000000, R).
R = inference_limit_exceeded.
```

La segunda consulta sigue respondiendo mal. `prudente(J)` es el problema J
sin los estados desde los que no se llega a una meta, y para saberlo
`sucesor/5` hace otra búsqueda, desde el estado nuevo. Esa búsqueda de
adentro borra, al empezar y al terminar, la agenda y los visitados de la
de afuera, que pierde sus nodos pendientes y vuelve a visitar estados sin
fin. El estado global no se arregla con disciplina en los bordes: dos
búsquedas que comparten una base de datos se estorban, y la única
corrección es que la agenda sea un argumento, como en `visitados.pl`.

## 7

<!-- ejemplo: capitulo-40/soluciones.pl predicado: recorrido_caballo/2 saltar/3 salto/2 consulta: recorrido_caballo(5, R). -->
```prolog
%!  recorrido_caballo(+N:integer, -Recorrido:list) is nondet.
%
%   Recorrido es un recorrido del caballo por un tablero de N x N que
%   empieza en 1-1 y pasa una vez por cada casilla.
recorrido_caballo(N, [1-1|Recorrido]) :-
    findall(F-C, ( between(1, N, F), between(1, N, C) ), Casillas),
    selectchk(1-1, Casillas, Libres),
    saltar(1-1, Libres, Recorrido).

%!  saltar(+Casilla, +Libres:list, -Recorrido:list) is nondet.
%
%   Recorrido pasa una vez por cada casilla de Libres, empezando con un
%   salto desde Casilla.
saltar(_, [], []).
saltar(Casilla, Libres, [Siguiente|Recorrido]) :-
    salto(Casilla, Siguiente),
    select(Siguiente, Libres, Libres1),
    saltar(Siguiente, Libres1, Recorrido).

%!  salto(+Casilla, -Destino) is nondet.
%
%   Destino está a un salto de caballo de Casilla, dentro o fuera del
%   tablero; select/3 descarta las que no están libres.
salto(F-C, F1-C1) :-
    member(DF-DC, [1-2, 2-1, 2-(-1), 1-(-2), -1-(-2), -2-(-1), -2-1, -1-2]),
    F1 is F + DF,
    C1 is C + DC.
```

```prolog
?- once(recorrido_caballo(5, R)).
R = [1-1, 2-3, 3-5, 5-4, 4-2, 2-1, 3-3, 1-4, 2-2, 4-1, 5-3, 4-5, 2-4, 1-2, 3-1, 5-2, 4-4, 2-5, 1-3, 3-2, 5-1, 4-3, 5-5, 3-4, 1-5].
```

`salto/2` genera los ocho destinos sin examinar el tablero, y
`select(Siguiente, Libres, Libres1)`, con `Siguiente` ya ligado, hace las
dos pruebas a la vez: que la casilla esté en el tablero y que no se haya
visitado. La lista `Libres` se reduce en cada salto, y la recursión
termina cuando se vacía. En un tablero de 4 × 4 no hay recorrido: la
búsqueda termina y falla. La casilla de partida se quita con `selectchk/3`,
la versión determinista de `select/3`: quita la primera aparición del
elemento y no deja alternativas.

## 8

<!-- ejemplo: capitulo-40/soluciones.pl predicado: mas_cortos/2 consulta: mas_cortos(jarras(4, 3, 2), Planes). -->
```prolog
%!  mas_cortos(+Problema, -Planes:list) is det.
%
%   Planes son todos los planes de longitud mínima de Problema. Como
%   iterativo/2, no termina si Problema no tiene solución.
mas_cortos(Problema, Planes) :-
    inicial(Problema, Estado),
    length(Plan0, _),
    desde(Problema, Estado, Plan0),
    !,
    length(Plan0, Longitud),
    length(Plan, Longitud),
    findall(Plan, desde(Problema, Estado, Plan), Planes).
```

```prolog
?- mas_cortos(jarras(4, 3, 2), Planes).
Planes = [[llenar(2), pasar(2, 1), llenar(2), pasar(2, 1)]].

?- mas_cortos(rio, Planes), length(Planes, N).
Planes = [[cruzar(cabra), cruzar(solo), cruzar(lobo), cruzar(cabra), cruzar(col), cruzar(solo), cruzar(cabra)], [cruzar(cabra), cruzar(solo), cruzar(col), cruzar(cabra), cruzar(lobo), cruzar(solo), cruzar(cabra)]],
N = 2.
```

El encabezado declara `mas_cortos(+Problema, -Planes:list) is det`: el
problema tiene que llegar instanciado, porque `inicial/2` y `sucesor/5` lo
reciben como primer argumento, y el predicado da una sola respuesta, la
lista, gracias al corte después del primer plan. La determinación describe
las respuestas, no la terminación: con un problema sin solución, como
`jarras(4, 2, 1)`, `length(Plan0, _)` propone longitudes sin fin y el
predicado no responde nunca. Como con `iterativo/2`, el encabezado lo dice
en la descripción; el modo no puede expresarlo.

## 9

<!-- ejemplo: capitulo-40/soluciones_puzzle.pl predicado: estimacion/3 consulta: ejemplo(dificil, E), buscar(mejor(a_estrella), puzzle(E, doble), _, C, K). -->
```prolog
%!  estimacion(+Nombre, +Estado, -H:integer) is det.
%
%   La heurística doble estima el doble que manhattan, y por eso estima de
%   más.
estimacion(doble, Estado, H) :-
    estimacion(manhattan, Estado, H0),
    H is 2 * H0.
```

```prolog
?- ejemplo(medio, E), buscar(mejor(a_estrella), puzzle(E, doble), _, C, K).
E = [1, 6, 3, 7, 5, 4, 0, 8, 2],
C = 24,
K = 619.

?- ejemplo(dificil, E), buscar(mejor(a_estrella), puzzle(E, doble), _, C, K).
E = [0, 7, 5, 4, 8, 2, 3, 6, 1],
C = 30,
K = 245.
```

Los planes dejan de ser los más cortos: 24 acciones donde alcanzan 20, y
30 donde alcanzan 26. Una heurística que estima de más hace que A\* prefiera
nodos que parecen cercanos a la meta aunque el camino hasta ellos haya sido
largo: el peso de g en f = g + h baja, y la búsqueda se parece a la voraz.
En `dificil` expande 245 nodos en lugar de 1 852; en `medio`, 619 en lugar
de 530. La cantidad de nodos no tiene por qué bajar: la heurística exagerada
también puede llevar la búsqueda por ramas equivocadas. Lo único que se
pierde con seguridad es la garantía del plan mínimo. Csenki estudia la
versión controlada de esta idea, IDA\*-ε, que acepta planes a lo sumo ε
más largos que el mínimo.

## 10

<!-- ejemplo: capitulo-40/soluciones_strips.pl predicado: sussman/1 operador/4 consulta: sussman(E), once(planificar(E, [sobre(a, b), sobre(b, c)], Plan)). -->
```prolog
%!  sussman(-Estado:list) is det.
%
%   Estado es el de la anomalía de Sussman, sin pinza.
sussman(Estado) :-
    list_to_ord_set([sobre(c, a), sobre(a, mesa), sobre(b, mesa), libre(c),
                     libre(b)],
                    Estado).

%!  operador(?Accion, -Precondiciones:list, -Agrega:list, -Borra:list)
%!      is nondet.
%
%   Los operadores de mover/3, sin variables.
operador(mover(B, X, Y), [libre(B), sobre(B, X), libre(Y)],
         [sobre(B, Y), libre(X)], [sobre(B, X), libre(Y)]) :-
    bloque(B),
    bloque(X),
    bloque(Y),
    B \== X,
    B \== Y,
    X \== Y.
operador(mover(B, X, mesa), [libre(B), sobre(B, X)],
         [sobre(B, mesa), libre(X)], [sobre(B, X)]) :-
    bloque(B),
    bloque(X),
    B \== X.
operador(mover(B, mesa, Y), [libre(B), sobre(B, mesa), libre(Y)],
         [sobre(B, Y)], [sobre(B, mesa), libre(Y)]) :-
    bloque(B),
    bloque(Y),
    B \== Y.
```

`aplicar/3`, `planificar/3` y `lograr/4` son los de `strips.pl`, repetidos
en el archivo. El operador que lleva un bloque a la mesa no exige ni borra
`libre(mesa)`: la mesa siempre tiene lugar.

```prolog
?- sussman(E), once(planificar(E, [sobre(a, b), sobre(b, c)], Plan)).
E = [libre(b), libre(c), sobre(a, mesa), sobre(b, mesa), sobre(c, a)],
Plan = [mover(c, a, mesa), mover(b, mesa, a), mover(b, a, c), mover(a, mesa, b)].
```

Cuatro acciones, cuando alcanza con tres: `mover(c, a, mesa)`,
`mover(b, mesa, c)`, `mover(a, mesa, b)`. La prueba `sin_plan_de_tres`
comprueba que el método no tiene ningún plan de tres acciones. Para
lograr `sobre(b, c)` primero, `mover(b, mesa, c)` ya es aplicable, y el
planificador no agrega antes `mover(c, a, mesa)`, que no logra ninguna
precondición pendiente; y si empieza por `sobre(a, b)`, después tiene
que volver a mover a para poner b sobre c. Con la pinza, el mismo método encuentra el plan
óptimo por un efecto lateral de `apilar/2`, que vacía la pinza
([Planificación](planificacion.md#planificacion-operadores-strips-y-analisis-de-medios-y-fines)).
Aquí ese efecto no existe, y la anomalía de Sussman se ve entera: el
análisis de medios y fines no intercala las metas.

## 11

<!-- ejemplo: capitulo-40/soluciones_torre.pl predicado: bloque/1 torre/1 -->
```prolog
% bloque(B): B es un bloque; d se agrega a los tres de strips.pl.
bloque(d).

%!  torre(-Estado:list) is det.
%
%   Estado es la torre de d sobre c sobre b sobre a, con a sobre la mesa.
torre(Estado) :-
    list_to_ord_set([sobre(d, c), sobre(c, b), sobre(b, a), sobre(a, mesa),
                     libre(d), mano_vacia],
                    Estado).
```

Con `torre(E)`, la consulta `once(planificar(E, [sobre(a, b), sobre(b,
c), sobre(c, d)], P))` da el plan `[desapilar(d, c), soltar(d),
desapilar(c, b), apilar(c, d), desapilar(b, a), apilar(b, c), tomar(a),
apilar(a, b)]`, medida con `time/1` en esta máquina: 55 652 705
inferencias y 9,9 segundos. `plan/3` del [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#2210-un-estado-como-termino-el-mundo-de-bloques), con
`estado([[d, c, b, a]], vacia)` y `estado([[a, b, c, d]], vacia)`, da en
94 533 inferencias y 0,031 segundos el plan `[tomar(d), soltar(d),
tomar(c), apilar(c, d), tomar(b), apilar(b, c), tomar(a), apilar(a, b)]`.
Los dos planes tienen ocho acciones —la misma secuencia, con `tomar/1`
donde aquí dice `desapilar/2`—, pero el análisis de medios y fines hace casi
seiscientas veces más inferencias. La profundización iterativa sobre la
longitud repite en cada longitud todas las formas de repartir el plan
entre las precondiciones y las metas, y ese reparto crece muy rápido con
la longitud; la búsqueda en anchura con visitados recorre cada estado una
vez, y el mundo de cuatro bloques con la pinza tiene pocos estados.

## 12

Con `wumpus.pl` cargado:

```prolog
?- seguras(grande, S), buscar(mejor(a_estrella), vuelta(5-5, S), _, C, KA), buscar(anchura, vuelta(5-5, S), _, _, KB).
S = [1-1, 1-2, 1-3, 1-4, 1-5, 2-1, 2-5, 3-1, 3-2, 3-3, 3-4, 3-5, 4-1, 4-4, 4-5, 5-1, 5-2, 5-3, 5-4, 5-5],
C = 8,
KA = 8,
KB = 19.

?- seguras(grande, S), buscar(mejor(a_estrella), vuelta(3-3, S), P, C, KA), buscar(anchura, vuelta(3-3, S), _, _, KB).
S = [1-1, 1-2, 1-3, 1-4, 1-5, 2-1, 2-5, 3-1, 3-2, 3-3, 3-4, 3-5, 4-1, 4-4, 4-5, 5-1, 5-2, 5-3, 5-4, 5-5],
P = [ir(3-2), ir(3-1), ir(2-1), ir(1-1)],
C = 4,
KA = 4,
KB = 15.

?- buscar(mejor(a_estrella), vuelta(3-3, [1-1, 1-2, 3-3, 3-4]), P, C, K).
false.
```

Desde (5, 5) y desde (3, 3) la distancia de Manhattan a la entrada es 8 y
4, y en los dos casos hay un camino seguro de esa longitud: la heurística
es exacta en todo el camino, y A\* expande solo sus celdas. La anchura
expande todas las celdas más cercanas que el destino, 19 y 15. En la última
consulta, (3, 3) no tiene ninguna vecina segura que lleve a la entrada: la
frontera se vacía y `buscar/5` falla, que es la respuesta correcta —el
agente no puede volver sin arriesgarse—.

## 13

<!-- ejemplo: capitulo-40/soluciones_buscaminas.pl predicado: deducir/4 con_total/4 minas_de/2 ocultas/2 consulta: tablero(chico, T), deducir(T, 2, Seguras, Minas). -->
```prolog
%!  deducir(+Lineas:list(string), +Total:integer, -Seguras:list,
%!          -Minas:list) is semidet.
%
%   Como deducir/3, sabiendo además que el tablero tiene Total minas.
%   Seguras y Minas incluyen las celdas ocultas que no tocan ningún número.
%   Falla si ninguna configuración es compatible con Total.
deducir(Lineas, Total, Seguras, Minas) :-
    leer(Lineas, Ocultas, _),
    ocultas(Lineas, Todas),
    subtract(Todas, Ocultas, Libres),
    length(Libres, K),
    \+ \+ con_total(Lineas, Total, K, []),
    findall(C, ( member(C, Ocultas),
                 \+ con_total(Lineas, Total, K, [C-1]) ),
            Seguras0),
    findall(C, ( member(C, Ocultas),
                 \+ con_total(Lineas, Total, K, [C-0]) ),
            Minas0),
    (   Libres == []
    ->  Seguras = Seguras0,
        Minas = Minas0
    ;   \+ ( configuracion(Lineas, [], A), minas_de(A, M), M < Total,
             Total =< M + K )
    ->  append(Seguras0, Libres, Seguras1),
        sort(Seguras1, Seguras),
        Minas = Minas0
    ;   \+ ( configuracion(Lineas, [], A), minas_de(A, M), M > Total - K,
             M =< Total )
    ->  Seguras = Seguras0,
        append(Minas0, Libres, Minas1),
        sort(Minas1, Minas)
    ;   Seguras = Seguras0,
        Minas = Minas0
    ).

%!  con_total(+Lineas, +Total:integer, +K:integer, +Fijas:list) is semidet.
%
%   Hay una configuración con Fijas cuyas minas M cumplen
%   M =< Total =< M + K: las K celdas libres completan el total.
con_total(Lineas, Total, K, Fijas) :-
    configuracion(Lineas, Fijas, A),
    minas_de(A, M),
    M =< Total,
    Total =< M + K,
    !.

%!  minas_de(+Asignacion, -M:integer) is det.
%
%   M es la cantidad de celdas con mina en Asignacion.
minas_de(Asignacion, M) :-
    assoc_to_values(Asignacion, Bs),
    sum_list(Bs, M).

%!  ocultas(+Lineas:list(string), -Celdas:list) is det.
%
%   Celdas son todas las celdas ocultas de Lineas, en orden.
ocultas(Lineas, Celdas) :-
    findall(F-C, ( nth1(F, Lineas, Linea),
                   string_chars(Linea, Xs),
                   nth1(C, Xs, '#') ),
            Celdas).
```

```prolog
?- tablero(chico, T), deducir(T, 2, Seguras, Minas).
T = ["#100", "1211", "01##", "01##"],
Seguras = [3-4, 4-3, 4-4],
Minas = [1-1, 3-3].
```

Las K celdas ocultas que no tocan ningún número, aquí solo (4, 4), pueden
tener cualquier cantidad de minas entre 0 y K: una configuración de las
demás sirve si sus M minas cumplen M ≤ Total ≤ M + K. Esas K celdas son
todas seguras si ninguna configuración deja minas para ellas (M < Total), y
todas minas si ninguna deja lugar para menos. Con 2 minas, (1, 1) y (3, 3)
las completan, y (4, 4) es segura, como en el
[capítulo 23](../capitulo-23-programacion-con-restricciones/index.md#2314-buscaminas-deducir-donde-estan-las-minas); con 3, es una
mina.

## 14

<!-- ejemplo: capitulo-40/soluciones_buscaminas.pl predicado: partidas_ganadas/4 minas_al_azar/4 consulta: partidas_ganadas(6, 5, 20, N). -->
```prolog
%!  partidas_ganadas(+Lado:integer, +Cantidad:integer, +Semillas:integer,
%!                   -Ganadas:integer) is det.
%
%   Ganadas es la cantidad de partidas que jugar/6 gana sin adivinar, en
%   tableros de Lado x Lado con Cantidad minas elegidas al azar con las
%   semillas 1 a Semillas, empezando en la primera celda sin mina.
partidas_ganadas(Lado, Cantidad, Semillas, Ganadas) :-
    aggregate_all(count,
                  ( between(1, Semillas, Semilla),
                    minas_al_azar(Lado, Cantidad, Semilla, Minas),
                    findall(F-C, ( between(1, Lado, F),
                                   between(1, Lado, C) ),
                            Celdas),
                    once(( member(Inicio, Celdas),
                           \+ memberchk(Inicio, Minas) )),
                    jugar(Lado, Lado, Minas, Inicio, _, ganada) ),
                  Ganadas).

%!  minas_al_azar(+Lado:integer, +Cantidad:integer, +Semilla:integer,
%!                -Minas:list) is det.
%
%   Minas son Cantidad celdas distintas de un tablero de Lado x Lado,
%   elegidas al azar con Semilla.
minas_al_azar(Lado, Cantidad, Semilla, Minas) :-
    set_random(seed(Semilla)),
    findall(F-C, ( between(1, Lado, F), between(1, Lado, C) ), Celdas),
    random_permutation(Celdas, Mezcladas),
    length(Minas0, Cantidad),
    append(Minas0, _, Mezcladas),
    msort(Minas0, Minas).
```

```prolog
?- partidas_ganadas(6, 5, 20, N).
N = 5.
```

Cinco de veinte. Casi todas las partidas empiezan en (1, 1), la primera
celda sin mina, y cuando esa celda muestra un número distinto de 0, sus
vecinas ocultas no se pueden deducir y la partida queda trabada en la
primera jugada. El Buscaminas de los programas de escritorio garantiza que
la primera celda descubierta tiene un 0, y así la partida arranca con una
región abierta. `once/1` elige la celda de partida dentro de
`aggregate_all/3`: un corte en ese lugar cortaría también el `between/3` de
las semillas, y la cuenta daría 0.
