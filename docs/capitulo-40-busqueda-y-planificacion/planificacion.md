# Planificación

Esta página contiene la sección [40.6](index.md#406-planificacion-operadores-strips-y-analisis-de-medios-y-fines)
del [capítulo 40](index.md): los operadores STRIPS, el análisis de medios y
fines y la anomalía de Sussman, sobre el mundo de bloques del
[capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#2210-un-estado-como-termino-el-mundo-de-bloques). El
ejemplo está en `strips.pl`, en `ejemplos/capitulo-40/`, con sus pruebas, y
corre en SWISH.

## Planificación: operadores STRIPS y análisis de medios y fines

Las búsquedas de las secciones anteriores eligen acciones según el
estado: prueban todas las que se pueden aplicar. Un **planificador** las
elige según las metas: si la meta es que a esté sobre b, las acciones que
interesan son las que ponen a sobre b. Para eso cada acción se describe por
lo que exige y lo que cambia, en la forma que introdujo el sistema STRIPS
(Fikes y Nilsson, 1971): un **operador** tiene sus **precondiciones**, los
hechos que deben valer para aplicarlo, los hechos que **agrega** y los que
**borra**. Todo lo que el operador no menciona sigue igual.

El mundo de bloques es el del [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#2210-un-estado-como-termino-el-mundo-de-bloques),
con una pinza que toma un bloque de la mesa, lo desapila de otro, lo suelta
en la mesa o lo apila. Allí un estado era un término con las pilas; aquí es
un conjunto ordenado de hechos: `sobre(B, X)`, con X otro bloque o `mesa`;
`libre(B)`, que no tiene nada encima; `mano_vacia`; y `sostiene(B)`.

<!-- ejemplo: capitulo-40/strips.pl predicado: bloque/1 sussman/1 operador/4 aplicar/3 consulta: sussman(E), aplicar(E, desapilar(c, a), E1). -->
```prolog
% bloque(B): B es un bloque.
bloque(a).
bloque(b).
bloque(c).

%!  sussman(-Estado:list) is det.
%
%   Estado es el estado inicial de la anomalía de Sussman: c sobre a, y a y
%   b sobre la mesa.
sussman(Estado) :-
    list_to_ord_set([sobre(c, a), sobre(a, mesa), sobre(b, mesa), libre(c),
                     libre(b), mano_vacia],
                    Estado).

%!  operador(?Accion, -Precondiciones:list, -Agrega:list, -Borra:list)
%!      is nondet.
%
%   Accion es aplicable en un estado que cumple Precondiciones; en el
%   estado siguiente, los hechos de Borra dejan de valer y los de Agrega
%   pasan a valer. Las acciones se generan sin variables.
operador(tomar(B), [libre(B), sobre(B, mesa), mano_vacia],
         [sostiene(B)], [libre(B), sobre(B, mesa), mano_vacia]) :-
    bloque(B).
operador(desapilar(B, C), [libre(B), sobre(B, C), mano_vacia],
         [sostiene(B), libre(C)], [libre(B), sobre(B, C), mano_vacia]) :-
    bloque(B),
    bloque(C),
    B \== C.
operador(soltar(B), [sostiene(B)],
         [sobre(B, mesa), libre(B), mano_vacia], [sostiene(B)]) :-
    bloque(B).
operador(apilar(B, C), [sostiene(B), libre(C)],
         [sobre(B, C), libre(B), mano_vacia], [sostiene(B), libre(C)]) :-
    bloque(B),
    bloque(C),
    B \== C.

%!  aplicar(+Estado:list, ?Accion, -Siguiente:list) is nondet.
%
%   Accion se puede aplicar en Estado y lleva a Siguiente: Estado menos lo
%   que Accion borra, más lo que agrega.
aplicar(Estado, Accion, Siguiente) :-
    operador(Accion, Pre, Agrega, Borra),
    list_to_ord_set(Pre, Pre1),
    ord_subset(Pre1, Estado),
    list_to_ord_set(Borra, Borra1),
    list_to_ord_set(Agrega, Agrega1),
    ord_subtract(Estado, Borra1, Estado1),
    ord_union(Estado1, Agrega1, Siguiente).
```

Las cláusulas de `operador/4` generan las acciones sin variables, con
`bloque/1`, y `aplicar/3` comprueba las precondiciones con `ord_subset/2` y
calcula el estado siguiente con `ord_subtract/3` y `ord_union/3`
([capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#226-libraryordsets-y-librarynb_set)). En el estado
inicial de la anomalía de Sussman —c sobre a, y a y b sobre la mesa— se
pueden aplicar dos acciones:

```prolog
?- sussman(E), aplicar(E, Accion, E1).
E = [mano_vacia, libre(b), libre(c), sobre(a, mesa), sobre(b, mesa), sobre(c, a)],
Accion = tomar(b),
E1 = [libre(c), sostiene(b), sobre(a, mesa), sobre(c, a)] ;
E = [mano_vacia, libre(b), libre(c), sobre(a, mesa), sobre(b, mesa), sobre(c, a)],
Accion = desapilar(c, a),
E1 = [libre(a), libre(b), sostiene(c), sobre(a, mesa), sobre(b, mesa)] ;
false.
```

Con `aplicar/3` como `sucesor/5` y costo 1, el bucle de
[`visitados.pl`](visitados.md#ciclos-y-visitados) ya podría buscar planes
hacia adelante. El **análisis de medios y fines** (Rowe, «Abstraction in search») busca
de otra manera: toma una meta que el estado no cumple —una **diferencia**—,
elige un operador que la agrega —el **medio**—, planifica antes sus
precondiciones como si fueran metas, aplica el operador, y sigue con las
metas desde el estado al que llegó.

<!-- ejemplo: capitulo-40/strips.pl predicado: planificar/3 lograr/4 consulta: sussman(E), planificar(E, [sobre(a, b), sobre(b, c)], Plan). -->
```prolog
%!  planificar(+Estado:list, +Metas:list, -Plan:list) is nondet.
%
%   Plan lleva de Estado a un estado donde valen todas las Metas, y se
%   obtiene por medios y fines. Los planes se obtienen de menor a mayor
%   longitud; si no hay ninguno, no termina.
planificar(Estado, Metas, Plan) :-
    length(Plan, _),
    lograr(Estado, Metas, Plan, _).

%!  lograr(+Estado:list, +Metas:list, ?Plan:list, -Final:list) is nondet.
%
%   Plan lleva de Estado a Final, donde valen las Metas: cada acción logra
%   una meta que no valía, después de lograr sus precondiciones. Con la
%   longitud de Plan fijada, termina.
lograr(Estado, Metas, [], Estado) :-
    list_to_ord_set(Metas, Metas1),
    ord_subset(Metas1, Estado).
lograr(Estado, Metas, Plan, Final) :-
    append(Antes, [Accion|Despues], Plan),
    member(Meta, Metas),
    \+ ord_memberchk(Meta, Estado),
    operador(Accion, Pre, Agrega, _),
    memberchk(Meta, Agrega),
    lograr(Estado, Pre, Antes, Intermedio),
    aplicar(Intermedio, Accion, Siguiente),
    lograr(Siguiente, Metas, Despues, Final).
```

`lograr/4` tiene dos recursiones: una para las precondiciones del operador,
antes de aplicarlo, y otra para las metas, después. Las dos pueden elegir
otra vez el mismo operador, y la recursión sobre las precondiciones puede no
terminar. `planificar/3` fija antes la longitud del plan con `length/2`,
como `iterativo/2` en la
[sección 40.4](index.md#404-profundidad-limitada-y-profundizacion-iterativa), y el
`append/3` del principio de `lograr/4` reparte esa longitud entre el plan
previo y el posterior: cada rama termina, y el primer plan es uno de los más
cortos que el método puede construir. Es la organización que usa Bratko en
su planificador de medios y fines.

**La anomalía de Sussman.** Las metas son que a esté sobre b y b sobre c.
Sin la cota, `lograr/4` responde igual, pero con otro plan:

```prolog
?- sussman(E), once(planificar(E, [sobre(a, b), sobre(b, c)], Plan)).
E = [mano_vacia, libre(b), libre(c), sobre(a, mesa), sobre(b, mesa), sobre(c, a)],
Plan = [desapilar(c, a), soltar(c), tomar(b), apilar(b, c), tomar(a), apilar(a, b)].

?- sussman(E), once(lograr(E, [sobre(a, b), sobre(b, c)], Plan, _)), length(Plan, N).
E = [mano_vacia, libre(b), libre(c), sobre(a, mesa), sobre(b, mesa), sobre(c, a)],
Plan = [tomar(b), apilar(b, c), desapilar(b, c), soltar(b), desapilar(c, a), soltar(c), tomar(a), apilar(a, b), desapilar(a, b), soltar(a), tomar(b), apilar(b, c), tomar(a), apilar(a, b)],
N = 14.
```

El plan de catorce acciones muestra la anomalía. Logra `sobre(b, c)` en las
dos primeras acciones y la deshace en la tercera, en el camino hacia
`sobre(a, b)`; logra `sobre(a, b)` en la octava y la deshace en la novena,
para volver a lograr `sobre(b, c)`; y termina logrando otra vez
`sobre(a, b)`. La anomalía, descrita por Gerald Sussman en 1973, es que las dos metas no se
pueden lograr **una después de la otra**: en cualquier orden, lograr la
primera obliga a deshacerla para lograr la segunda. El plan de seis
acciones intercala las dos: desapila c, que es un paso hacia `sobre(a, b)`,
logra `sobre(b, c)` entero, y solo después termina `sobre(a, b)`.

La cota de longitud encuentra ese plan porque ensaya las longitudes de
menor a mayor, pero el plan de seis acciones está al alcance del método por
un efecto lateral. El planificador solo agrega una acción cuando logra una
meta o una precondición pendiente: para `apilar(a, b)` necesita
`sostiene(a)`; para `tomar(a)`, que a esté libre y la pinza vacía; libera a
con `desapilar(c, a)`, y para vaciar la pinza, después de `soltar(c)` y
`tomar(b)`, elige `apilar(b, c)`, que agrega `mano_vacia` y de paso logra
la otra meta. Sin la pinza, en el mundo del [ejercicio 10](soluciones.md#10), ese efecto no
existe, y el plan más corto que el método construye tiene cuatro acciones
donde alcanzan tres: el análisis de medios y fines no **intercala** una
acción que prepara una meta mientras logra otra. Pagarlo cuesta además:
130 809 inferencias para el plan de seis acciones, contra 1 136 de
`plan/3` del [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#2210-un-estado-como-termino-el-mundo-de-bloques), que busca a lo
ancho sobre los mismos estados y encuentra el mismo plan (medidas en esta
máquina, con las bibliotecas ya cargadas). El análisis de
medios y fines gana cuando hay muchas acciones y pocas son relevantes para
las metas, y cuando las metas se pueden lograr por separado; en el mundo de
bloques, donde todo interactúa, no.

En el apartado «Planning» de *Prolog for Programmers*, Kluźniak y
Szpakowicz presentan WARPLAN, de David Warren (1974), que resuelve la anomalía de otra manera: planifica
hacia atrás, **regresando** cada meta a través de las acciones ya
planificadas, y protege las metas logradas. El
[capítulo 70](../capitulo-70-proyecto-planificacion-regresion/index.md) lo construye.
