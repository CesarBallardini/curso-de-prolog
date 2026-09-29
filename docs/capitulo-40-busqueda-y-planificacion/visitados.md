# Ciclos y visitados

Esta página contiene la sección [40.3](index.md#403-ciclos-y-visitados) del
[capítulo 40](index.md): el registro de los estados visitados, el rastro del
camino actual y la lista de lo que queda. Los ejemplos están en
`visitados.pl` y `reinas.pl`, en `ejemplos/capitulo-40/`, con sus pruebas, y
corren en SWISH.

## Ciclos y visitados

La búsqueda en anchura termina en las jarras, pero expande los mismos
estados muchas veces; la de profundidad no termina. Las dos cosas se
corrigen recordando los estados vistos. `visitados.pl` agrega al bucle un
`assoc` ([sección 22.5](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#225-libraryassoc-y-libraryrbtrees)) de cada estado visto al
menor costo con que se llegó a él:

<!-- ejemplo: capitulo-40/visitados.pl predicado: buscar/5 bucle/7 nuevos/4 consulta: buscar(profundidad, jarras(4, 3, 2), Plan, Costo, Expandidos). -->
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
    list_to_assoc([Estado-0], Vistos),
    bucle(Estrategia, Problema, Frontera, Vistos, 0, nodo(_, Camino, Costo),
          Expandidos),
    reverse(Camino, Plan).

%!  bucle(+Estrategia, +Problema, +Frontera, +Vistos, +K0:integer,
%!        -Solucion, -K:integer) is semidet.
%
%   Solucion es el primer nodo meta que se extrae de Frontera; Vistos da, para
%   cada estado visto, el menor costo con que se llegó a él; K es K0 más la
%   cantidad de nodos expandidos hasta sacar Solucion.
bucle(Estrategia, Problema, Frontera0, Vistos0, K0, Solucion, K) :-
    sacar(Estrategia, Frontera0, Nodo, Frontera1),
    Nodo = nodo(Estado, _, G),
    (   get_assoc(Estado, Vistos0, Mejor),
        G > Mejor
    ->  bucle(Estrategia, Problema, Frontera1, Vistos0, K0, Solucion, K)
    ;   meta(Problema, Estado)
    ->  Solucion = Nodo,
        K = K0
    ;   K1 is K0 + 1,
        hijos(Problema, Nodo, Hijos0),
        nuevos(Hijos0, Vistos0, Hijos, Vistos1),
        agregar(Estrategia, Problema, Hijos, Frontera1, Frontera2),
        bucle(Estrategia, Problema, Frontera2, Vistos1, K1, Solucion, K)
    ).

%!  nuevos(+Hijos0:list, +Vistos0, -Hijos:list, -Vistos) is det.
%
%   Hijos son los nodos de Hijos0 cuyo estado no se vio, o se vio con un
%   costo mayor; Vistos es Vistos0 con el costo de cada uno.
nuevos([], Vistos, [], Vistos).
nuevos([Hijo|Hijos0], Vistos0, Hijos, Vistos) :-
    Hijo = nodo(Estado, _, G),
    (   get_assoc(Estado, Vistos0, G0),
        G0 =< G
    ->  Hijos = Hijos1,
        Vistos1 = Vistos0
    ;   put_assoc(Estado, Vistos0, G, Vistos1),
        Hijos = [Hijo|Hijos1]
    ),
    nuevos(Hijos0, Vistos1, Hijos1, Vistos).
```

Una regla sirve para las tres estrategias: un hijo cuyo estado ya se vio con
un costo igual o menor se descarta, y uno que llega por un camino más barato
se agrega y actualiza el registro. El nodo que quedó en la frontera con el
costo anterior ya no sirve, y cuando se extrae, la primera condición de
`bucle/7` lo saltea. En anchura y en profundidad esa regla casi nunca vuelve
a agregar un estado; en la de costo uniforme es la que asegura que el costo
devuelto es el mínimo.

```prolog
?- buscar(profundidad, jarras(4, 3, 2), Plan, Costo, Expandidos).
Plan = [llenar(1), pasar(1, 2), vaciar(2), pasar(1, 2), llenar(1), pasar(1, 2)],
Costo = 17,
Expandidos = 7.

?- buscar(anchura, jarras(4, 3, 2), Plan, Costo, Expandidos).
Plan = [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1)],
Costo = 10,
Expandidos = 9.

?- buscar(mejor(costo), jarras(4, 3, 2), Plan, Costo, Expandidos).
Plan = [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1)],
Costo = 10,
Expandidos = 7.

?- buscar(anchura, jarras(4, 2, 1), Plan, Costo, Expandidos).
false.
```

La búsqueda en profundidad ahora termina, con un plan de seis acciones que
no es el más corto: sigue la primera acción mientras puede. La de anchura
expande 9 nodos en lugar de 67. Y un problema sin solución —con jarras de 4
y 2 litros solo se miden cantidades pares— falla después de visitar los
estados alcanzables, en lugar de no terminar. En `jarras(7, 2, 1)`, la
anchura da el plan de menos acciones y el costo uniforme el de menos agua:

```prolog
?- buscar(anchura, jarras(7, 2, 1), Plan, Costo, Expandidos).
Plan = [llenar(1), pasar(1, 2), vaciar(2), pasar(1, 2), vaciar(2), pasar(1, 2)],
Costo = 17,
Expandidos = 12.

?- buscar(mejor(costo), jarras(7, 2, 1), Plan, Costo, Expandidos).
Plan = [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1), llenar(2), pasar(2, 1), llenar(2), pasar(2, 1)],
Costo = 15,
Expandidos = 13.
```

El registro de visitados es la solución que el [capítulo 39](../capitulo-39-tabulacion/index.md) daba
con una tabla, escrita a mano: allí la tabla recordaba las llamadas y sus
respuestas, aquí el `assoc` recuerda los estados y su mejor costo. La tabla
no sirve para devolver el plan, porque una relación entre un estado y todos
sus caminos tiene infinitas respuestas en un grafo con ciclos
([sección 39.2](../capitulo-39-tabulacion/index.md#392-memorizacion-sin-estado-escrito-a-mano)).

**El rastro del camino actual.** Una forma más barata de no entrar en ciclos
es no repetir los estados del camino que se está recorriendo, sin recordar
los de otras ramas. Es la búsqueda en profundidad de Prolog con un
acumulador, el **rastro** (Clocksin, *Clause and Effect*, hoja de trabajo
«Searching a Cyclic Graph»):

<!-- ejemplo: capitulo-40/visitados.pl predicado: resolver_sin_ciclos/2 sin_ciclos/4 consulta: resolver_sin_ciclos(jarras(4, 3, 2), Plan). -->
```prolog
%!  resolver_sin_ciclos(+Problema, -Plan:list) is nondet.
%
%   Plan lleva del estado inicial de Problema a un estado meta sin pasar dos
%   veces por el mismo estado. En profundidad, con la recursión de Prolog;
%   en un espacio finito termina, y por reintento da todos esos planes.
resolver_sin_ciclos(Problema, Plan) :-
    inicial(Problema, Estado),
    sin_ciclos(Problema, Estado, [Estado], Plan).

%!  sin_ciclos(+Problema, +Estado, +Rastro:list, -Plan:list) is nondet.
%
%   Plan lleva de Estado a un estado meta sin pasar por los estados de
%   Rastro, los del camino que llevó a Estado.
sin_ciclos(Problema, Estado, _, []) :-
    meta(Problema, Estado).
sin_ciclos(Problema, Estado, Rastro, [Accion|Plan]) :-
    sucesor(Problema, Estado, Accion, Siguiente, _),
    \+ memberchk(Siguiente, Rastro),
    sin_ciclos(Problema, Siguiente, [Siguiente|Rastro], Plan).
```

```prolog
?- resolver_sin_ciclos(jarras(4, 3, 2), Plan).
Plan = [llenar(1), llenar(2), vaciar(1), pasar(2, 1), llenar(2), pasar(2, 1)] ;
Plan = [llenar(1), llenar(2), vaciar(1), pasar(2, 1), llenar(2), pasar(2, 1), vaciar(1)] ;
...

?- aggregate_all(count, resolver_sin_ciclos(jarras(4, 3, 2), _), N).
N = 54.
```

El rastro no crece más que la profundidad y la memoria es la de un camino;
a cambio, un estado al que se llega por varios caminos se vuelve a explorar
desde cada uno, y en un espacio grande los caminos sin repetición son muchos
más que los estados. Sirve cuando el espacio es chico o casi un árbol, y
cuando interesan todos los planes y no solo uno.

**La lista de lo que queda.** Cuando cada elemento se usa una sola vez, hay
una tercera forma: llevar la lista de los elementos todavía disponibles y
sacar cada uno con `select/3` al usarlo (Clocksin, hoja de trabajo «Partial Maps with a
Parameter»). La
lista se reduce en cada paso, y eso mismo prueba que la búsqueda termina.
Las N reinas del [capítulo 23](../capitulo-23-programacion-con-restricciones/index.md#239-las-n-reinas) tienen esa forma: cada
fila recibe una sola reina.

<!-- ejemplo: capitulo-40/reinas.pl predicado: reinas/2 colocar/3 segura/3 consulta: reinas(8, Qs). -->
```prolog
%!  reinas(+N:integer, -Qs:list(integer)) is nondet.
%
%   Qs es una ubicación de N reinas que no se atacan: la reina de la columna
%   i está en la fila i-ésima de Qs.
reinas(N, Qs) :-
    numlist(1, N, Filas),
    colocar(Filas, [], Qs).

%!  colocar(+Libres:list, +Colocadas:list, -Qs:list) is nondet.
%
%   Qs completa Colocadas, las filas de las reinas ya colocadas, la última
%   primero, con una reina en cada fila de Libres.
colocar([], Qs, Qs).
colocar(Libres, Colocadas, Qs) :-
    select(Q, Libres, Resto),
    segura(Q, Colocadas, 1),
    colocar(Resto, [Q|Colocadas], Qs).

%!  segura(+Q:integer, +Colocadas:list, +D:integer) is semidet.
%
%   Una reina en la fila Q no comparte diagonal con las de Colocadas, la
%   primera de las cuales está D columnas antes.
segura(_, [], _).
segura(Q, [Q1|Qs], D) :-
    Q1 - Q =\= D,
    Q - Q1 =\= D,
    D1 is D + 1,
    segura(Q, Qs, D1).
```

```prolog
?- reinas(8, Qs).
Qs = [4, 2, 7, 3, 6, 8, 5, 1] ;
Qs = [5, 2, 4, 7, 3, 8, 6, 1] ;
...

?- aggregate_all(count, reinas(8, _), N).
N = 92.
```

Las filas son distintas por construcción, y cada reina se comprueba contra
las diagonales de las anteriores en cuanto se elige su fila: una rama que
choca se abandona sin generar el resto de la permutación. Es la búsqueda en
profundidad de la [plantilla 15](../plantillas.md#15-generar-y-probar) con la prueba metida
dentro del generador. Contar las 724 soluciones de 10 reinas, en esta
máquina:

```text
% la lista de filas libres (reinas.pl)
% 1,468,863 inferences, 0.172 CPU in 0.182 seconds (94% CPU, 8546112 Lips)
% restringir y etiquetar (capítulo 23)
% 11,037,241 inferences, 1.125 CPU in 1.134 seconds (99% CPU, 9810881 Lips)
% generar y probar (capítulo 23)
% 115,046,367 inferences, 14.281 CPU in 14.353 seconds (99% CPU, 8055763 Lips)
```

Para contar todas las soluciones, la búsqueda con poda temprana gana a las
restricciones; para la primera solución de 20 reinas se invierte: 27
millones de inferencias y 3,6 segundos contra 207 090 inferencias y 0,016
segundos de `labeling([ff], Qs)`, que elige primero la reina con menos
filas posibles. La heurística de elegir la variable más restringida es lo
que la búsqueda a ciegas no tiene.
