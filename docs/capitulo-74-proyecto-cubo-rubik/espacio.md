# El cubo como espacio de estados

Esta página contiene la sección [74.4](index.md#744-version-3-el-cubo-como-espacio-de-estados)
del [capítulo 74](index.md): la versión 3 del programa, que aplica al cubo
las búsquedas del [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md)
y mide su costo. Los ejemplos están en `capitulo40.pl` y `espacio.pl`, en
`ejemplos/capitulo-74/`, con sus pruebas; los dos son `% solo-local`,
porque cargan otros archivos.

## El cubo como espacio de estados

El [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md#401-el-problema-como-interfaz)
define un problema con tres predicados, `inicial/2`, `meta/2` y
`sucesor/5`, y lo resuelve con búsquedas que no saben nada del dominio.
El cubo encaja en esa interfaz: el estado es el término `c/54`, la meta es
el cubo resuelto y cada sucesor es uno de los doce cuartos de vuelta. Los
archivos del [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) no son módulos, y los dos que se usan definen los
mismos predicados, así que `capitulo40.pl` carga cada uno en un módulo
propio con `load_files/2` y les agrega las cláusulas del cubo, declaradas
`multifile` antes de la carga:

<!-- ejemplo: capitulo-74/capitulo40.pl fragmento: :- multifile .. user:mover(M, C, C1). -->
```prolog
:- multifile
    anchura40:inicial/2,
    anchura40:meta/2,
    anchura40:sucesor/5,
    iterativa40:inicial/2,
    iterativa40:meta/2,
    iterativa40:sucesor/5.

:- load_files(user:cubo, [if(not_loaded)]).
:- load_files(anchura40:'../capitulo-40/visitados', []).
:- load_files(iterativa40:'../capitulo-40/profundizacion', []).

anchura40:inicial(cubo(C), C).
anchura40:meta(cubo(_), C) :-
    user:resuelto(C).
anchura40:sucesor(cubo(_), C, M, C1, 1) :-
    user:cuarto_de_vuelta(M),
    user:mover(M, C, C1).
```

`en_anchura/3` usa la búsqueda en anchura con registro de estados vistos
de la [sección 40.3](../capitulo-40-busqueda-y-planificacion/index.md#403-ciclos-y-visitados),
y `profundizando/2`, la profundización iterativa de la
[sección 40.4](../capitulo-40-busqueda-y-planificacion/index.md#404-profundidad-limitada-y-profundizacion-iterativa).
Las dos encuentran una de las soluciones más cortas.

## Cuántos estados hay

`capas/2` cuenta los estados a cada distancia del cubo resuelto. Genera
cada capa a partir de la anterior: los sucesores de sus estados que no
están en la misma capa ni en la anterior, porque cada cuarto de vuelta
tiene su inverso y un sucesor está, a lo sumo, una capa más atrás. Cada
capa es una lista ordenada con `sort/2`, y las diferencias salen de
`ord_subtract/3`:

<!-- ejemplo: capitulo-74/espacio.pl predicado: capas/4 -->
```prolog
%!  capas(+D:integer, +Anterior:list, +Actual:list, -Cuantos:list) is det.
%
%   Cuantos cuenta Actual, la capa de una distancia, y las D capas que
%   siguen; Anterior es la capa de la distancia anterior. Un estado de la
%   capa siguiente es sucesor de uno de Actual y no está en Actual ni en
%   Anterior: todo cuarto de vuelta tiene inverso, y un sucesor está a lo
%   sumo una capa más atrás.
capas(0, _, Actual, [N]) :-
    !,
    length(Actual, N).
capas(D, Anterior, Actual, [N|Cuantos]) :-
    length(Actual, N),
    findall(C1, ( member(C, Actual), cuarto_de_vuelta(M), mover(M, C, C1) ),
            Sucesores0),
    sort(Sucesores0, Sucesores),
    ord_subtract(Sucesores, Actual, Sucesores1),
    ord_subtract(Sucesores1, Anterior, Siguiente),
    D1 is D - 1,
    capas(D1, Actual, Siguiente, Cuantos).
```

```prolog
?- capas(4, Cuantos).
Cuantos = [1, 12, 114, 1068, 10011].

?- estados(N).
N = 43252003274489856000.
```

Cada capa multiplica la anterior por casi diez. `estados/1` da el total
de estados del cubo, unos 4,3 × 10¹⁹: las ocho esquinas en cualquier
orden y con cualquier orientación salvo la última, que queda determinada
por las otras; lo mismo con las doce aristas; y la mitad de esas
combinaciones, porque las permutaciones de esquinas y de aristas tienen
siempre la misma paridad.

## Cuánto cuesta buscar

`medir/5` resuelve la mezcla de una semilla con una de las dos búsquedas
y cuenta las inferencias:

```prolog
?- medir(profundizando, 5, 5, Largo, Inferencias).
Largo = 5,
Inferencias = 567572.

?- medir(en_anchura, 4, 4, Largo, Inferencias).
Largo = 4,
Inferencias = 2495902.
```

Con las mezclas de las semillas 3 a 7, cada una de tantos giros como su
semilla, las dos búsquedas miden:

| Giros de la mezcla | Profundización iterativa | Anchura con visitados |
|---|---|---|
| 3 | 5 866 inferencias | 408 796 inferencias, 578 nodos expandidos |
| 4 | 39 183 | 2 495 620, 3 112 nodos, 0,8 s |
| 5 | 567 572, 0,17 s | 32 761 797, 34 994 nodos, 12,3 s |
| 6 | 10 783 026, 3,2 s | — |
| 7 | 131 586 078, 40 s | — |

Cada giro más multiplica el costo de la profundización iterativa por
alrededor de doce, la cantidad de sucesores. Una mezcla de veinte giros,
a ese ritmo, llevaría más de cien millones de años. La búsqueda en
anchura es peor todavía: el registro de visitados compara términos de 54
argumentos en un árbol AVL en cada inserción, y ahorra poco, porque en las
primeras capas casi todos los estados son distintos (10 011 estados a
distancia 4 contra 12⁴ = 20 736 secuencias). Las inferencias de la
anchura cambian en unas centenas de una ejecución a otra; las de la
profundización, no. `capas/2` evita el árbol y recorre las cinco primeras
capas, 93 840 estados en la última, con 1,3 millones de inferencias.

La conclusión es la de Merritt: una búsqueda ciega no resuelve el cubo.
El [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md#405-heuristicas-a-e-ida)
agrega heurísticas a la búsqueda; el cubo, en cambio, se resuelve
cambiando las acciones. Las versiones 4 a 6 del
[capítulo 74](index.md#745-version-4-los-macrooperadores) reemplazan los
doce giros por secuencias que mueven pocas piezas y dividen la meta en
veinte metas parciales.
