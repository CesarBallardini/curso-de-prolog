# Índices y metarreglas

Esta página continúa la página [La terminación](terminacion.md#617-version-5-la-terminacion)
del [capítulo 61](index.md), con la [sección 61.8](#618-version-6-indices-y-metarreglas): la
versión 6, `indices.pl`, que indexa la memoria y parte el programa en fases.
El archivo está en `ejemplos/capitulo-61/`, con sus pruebas, y carga la
versión 3, `conflictos.pl`.

## 61.8 Versión 6: índices y metarreglas

Bratko cierra su capítulo con tres propuestas para que el emparejamiento no
recorra toda la memoria en cada ciclo: **indexar** la información de la base,
**partirla** en sub-bases, y partir los **módulos** en subconjuntos que se
activan y desactivan con un mecanismo de control más elaborado, «una especie
de metarreglas». La versión 6 escribe la primera y la tercera; la segunda es
la primera llevada a varias bases.

### La memoria indexada

En las versiones 2 y 3, `condicion/4` busca cada patrón con `nth0/3`, que
recorre la lista entera: un hecho que ningún patrón puede usar cuesta lo mismo
que uno útil. La memoria indexada guarda los hechos en un `library(assoc)` por
su **clave**, el nombre y la aridad, como hace SWI-Prolog con las cláusulas de
un predicado. Un patrón calcula su clave y recorre solo la lista de esa clave:

<!-- ejemplo: capitulo-61/indices.pl predicado: agregar_hecho/3 hecho_en/3 -->
```prolog
%!  agregar_hecho(+F, +Memoria0, -Memoria) is det.
%
%   Memoria es Memoria0 con el hecho F agregado como el más reciente.
agregar_hecho(F, m(Indice0, T), m(Indice, T1)) :-
    clave(F, K),
    (   get_assoc(K, Indice0, Lista)
    ->  true
    ;   Lista = []
    ),
    put_assoc(K, Indice0, [T-F|Lista], Indice),
    T1 is T + 1.

%!  hecho_en(?F, +Memoria, -T:integer) is nondet.
%
%   F unifica con un hecho de Memoria que tiene la marca T. Solo se recorren
%   los hechos de la clave de F, del más reciente al más antiguo.
hecho_en(F, m(Indice, _), T) :-
    clave(F, K),
    get_assoc(K, Indice, Lista),
    member(T-F, Lista).
```

Cada hecho lleva una **marca de tiempo**, un entero que crece con cada hecho
agregado. Es la forma en que los sistemas OPS, para los que McDermott y Forgy
describieron la estrategia de la recencia, saben qué hecho es más reciente:
en la lista de la versión 3 lo decía la posición, y en el índice ya no hay una
posición única. `reciente` prefiere la instancia con la mayor marca, que se
cambia de signo para que la menor clave gane, como en `elegir/4`:

<!-- ejemplo: capitulo-61/indices.pl predicado: elegir_i/3 -->
```prolog
%!  elegir_i(+Estrategia, +Instancias:list, -Elegida) is det.
%
%   Como elegir/4 de la versión 3. Con reciente, la clave es la mayor marca
%   de la instancia, cambiada de signo, o 0 si no usa ningún hecho.
elegir_i(Estrategia, Instancias, Elegida) :-
    map_list_to_pairs(clave_i(Estrategia), Instancias, Pares),
    keysort(Pares, [_-Elegida|_]).
```

`ejecutar_indexado/5` recibe y devuelve listas, del hecho más reciente al más
antiguo, como `ejecutar/5`, y como ella falla si falla una acción de la
instancia elegida; las pruebas de `indices.plt` comparan las dos
versiones con los programas `mcd`, `mcd_invertido` y `ordenar` y las tres
estrategias, y dan la misma memoria y el mismo resultado:

```prolog
?- ejecutar_indexado(mcd, primera, [numero(25), numero(10), numero(15), numero(30)], M, R).
M = [numero(5), numero(5), numero(5), numero(5)],
R = 5.
```

### Fases y una metarregla

La tercera propuesta parte el programa. Un **programa por fases** es una lista
de pares `Fase-Modulos`, y en cada ciclo solo compiten los módulos de la fase
activa. Una **metarregla** es una regla sobre las reglas: no cambia la
memoria, sino qué módulos pueden actuar. La de `ejecutar_fases/5` es la más
simple: cuando ningún módulo de la fase activa se puede aplicar, se pasa a la
siguiente:

<!-- ejemplo: capitulo-61/indices.pl fragmento: programa_fases(mcd_fases, .. ]). -->
```prolog
programa_fases(mcd_fases,
    [ calcular - [ resta :: [numero(X), numero(Y), {X > Y}]
                        ---> [{Z is X - Y},
                              reemplazar(numero(X), numero(Z))] ],
      informar - [ resultado :: [numero(X)]
                        ---> [parar(X)] ]
    ]).
```

<!-- ejemplo: capitulo-61/indices.pl predicado: fases/5 -->
```prolog
%!  fases(+Fases:list, +Estrategia, +Memoria0, -Memoria, -Resultado) is semidet.
%
%   Ejecuta cada fase de Fases hasta que ninguno de sus módulos se aplica,
%   y sigue con la siguiente: la metarregla de las transiciones. Falla si
%   falla una acción de la instancia elegida.
fases([], _, Memoria, Memoria, nada_aplicable).
fases([_-Modulos|Fases], Estrategia, Memoria0, Memoria, Resultado) :-
    ciclo_i(Modulos, Estrategia, 0, _, Memoria0, Memoria1, R),
    (   R == nada_aplicable
    ->  fases(Fases, Estrategia, Memoria1, Memoria, Resultado)
    ;   Memoria = Memoria1,
        Resultado = R
    ).
```

`fases/5` es `semidet`, como `ciclo_i/7`: falla si falla una acción de la
instancia elegida en cualquiera de las fases.

En el máximo común divisor de la
[sección 61.2](index.md#612-modulos-dirigidos-por-patrones), `resultado` se
puede aplicar siempre, y el programa depende de que la resolución de
conflictos prefiera `resta`: con `mcd_invertido` y la estrategia `primera`
responde el primer número. Con fases, la fase `calcular` solo tiene `resta`,
y `resultado` no se considera hasta que `resta` no se puede aplicar. El orden
de los módulos y la estrategia dejan de importar:

```prolog
?- ejecutar(mcd_invertido, primera, [numero(25), numero(10)], M, R).
M = [numero(25), numero(10)],
R = 25.

?- ejecutar_fases_de(mcd_fases, primera, [numero(25), numero(10)], M, R).
M = [numero(5), numero(5)],
R = 5.
```

`ejecutar_fases_de/5` recibe el nombre del programa por fases:

```prolog
?- ejecutar_fases_de(mcd_fases, especifica, [numero(25), numero(10), numero(15)], M, R).
M = [numero(5), numero(5), numero(5)],
R = 5.
```

### Lo que cuesta

Con los números 60, 120, …, 720 del ejercicio 8, con y sin los 100 hechos
`ruido(I)` que ningún módulo usa, las inferencias de cada ejecución, medidas
con `statistics/2` después de una primera ejecución, son:

| Versión | Sin ruido | Con ruido |
|---|---|---|
| 3, `ejecutar/5` | 80 536 | 174 336 |
| 6, `ejecutar_indexado/5` | 87 546 | 89 626 |
| 6, `ejecutar_fases/5` | 82 542 | 84 622 |

Sin ruido, el índice cuesta algo más que la lista, porque cada búsqueda pasa
por el árbol del `library(assoc)`. Con ruido, la lista recorre los 112 hechos
para cada patrón en cada ciclo y el costo se duplica; el índice no mira los
hechos `ruido(I)`, y solo paga un árbol un poco más profundo. Las fases
ahorran además las instancias de `resultado` en cada ciclo de la fase
`calcular`. Las dos mejoras siguen comparando toda la memoria con todos los
patrones en cada ciclo, aunque una acción haya cambiado un solo hecho: no
repetir esa comparación es la idea del algoritmo Rete, que desarrolla el
[capítulo 65](../capitulo-65-proyecto-algoritmo-rete/index.md).

!!! question "Actividad"
    Predecir cuántos ciclos hace `ordenar` sobre `[4, 5, 1, 3, 2]` con la
    memoria indexada y las tres estrategias, comparados con los de
    `ciclos/4` de la versión 3. Comprobarlo con `ciclo_i/7`, que devuelve la
    cantidad de ciclos, sobre la memoria que da `indexar/2` para la lista de
    `posiciones/2`.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; los ciclos son `semidet`, porque fallan si falla una acción, `satisface/3` y `ejecucion/4` son `nondet`, y `bien_formado/1` es `semidet` |
    | C2 | los programas son datos: `bien_formado/1` los examina antes de ejecutarlos, y los hechos de la memoria no pueden ser variables ni términos `{_}` o `no(_)`, que tienen otro significado |
    | C4 | los ciclos eligen con un si-entonces, `acciones/4` distingue `parar/1` con otro, y las cláusulas de `fnn/2` y `fnc/2` empiezan por el átomo para que la indexación no deje alternativas; las pruebas, que fallan si queda una alternativa pendiente, lo confirman |
    | C6 | desde la versión 2 la memoria viaja en argumentos; la versión 1 usa la base dinámica para mostrar lo que se pierde, y la traza es la única salida |
    | C7 | 103 pruebas en siete archivos: cada programa en cada versión, una acción que falla, las tres estrategias con sus empates, la cantidad de ejecuciones, la traza como texto, los teoremas y los no teoremas, y los tres modos de no terminar; la versión 6 se compara con la 3 en todos los programas y estrategias, y una prueba mide que el índice no paga los hechos que ningún módulo usa |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios extienden los programas: cada solución es un
archivo que carga los del capítulo, sin modificarlos.

13. **(2)** La metarregla de `ejecutar_fases/5` trata las fases como
    etapas: una fase terminada no vuelve a activarse. Escribir
    `ejecutar_prioridades/5`, con la metarregla que en cada ciclo activa la
    primera fase que tiene algún módulo aplicable, y un programa por fases,
    `contador_fases`, en el que las dos metarreglas dejan memorias
    distintas. Comprobar que con `mcd_fases` dan el mismo resultado.

## Resumen

| | |
|---|---|
| **módulo dirigido por patrones** | `Nombre :: Condiciones ---> Acciones`; ningún módulo llama a otro, la memoria decide cuál se aplica |
| **memoria de trabajo** | la colección de hechos sin variables que las condiciones examinan y las acciones cambian |
| **condiciones** | un patrón (algún hecho unifica), `no(F)` (ninguno unifica) y `{Meta}` (una prueba de Prolog) |
| **acciones** | `agregar/1`, `quitar/1`, `reemplazar/2`, `{Meta}` y `parar/1` |
| **ciclo** | reconocimiento, resolución del conflicto y ejecución, hasta `parar/1` o hasta que ningún módulo se aplica; es `semidet`: falla si falla una acción |
| **conjunto de conflicto** | todas las instancias aplicables: cada módulo con cada manera de cumplir sus condiciones |
| **estrategia** | una clave de orden sobre el conjunto de conflicto: `primera`, `reciente`, `especifica` |
| **memoria como argumento** | recupera el retroceso: `ejecucion/4` enumera todas las ejecuciones |
| **resolución** | combinar dos cláusulas con literales opuestos; la cláusula vacía prueba que la negación es contradictoria |
| **terminación** | una medida que decrece en cada ciclo; el límite y las memorias repetidas detectan los programas que no terminan |
| **memoria indexada** | los hechos agrupados por nombre y aridad, con marcas de tiempo; cada patrón examina solo los de su clave |
| **metarregla** | una regla sobre las reglas: decide qué fase del programa está activa |
| `programas.pl` | el lenguaje de los módulos y los programas de ejemplo |
| `dinamico.pl`, `ciclo.pl` | el ciclo con la base dinámica y con la memoria como argumento |
| `conflictos.pl` | el conjunto de conflicto, las estrategias y la traza |
| `resolucion.pl`, `terminacion.pl` | el demostrador y la vigilancia de la terminación |
| `indices.pl` | la memoria indexada y los programas por fases |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| La resolución general, con la lógica de predicados, la forma clausal completa y refutaciones que se verifican | [capítulo 63](../capitulo-63-proyecto-demostrador-teoremas/index.md) |
| Un sistema de producción sobre una memoria de trabajo: encadenamiento hacia adelante, resolución de conflictos por recencia y especificidad, marcos | [capítulo 64](../capitulo-64-proyecto-sistema-produccion/index.md) |
| La comparación incremental de los patrones con la memoria, sin repetirla en cada ciclo | [capítulo 65](../capitulo-65-proyecto-algoritmo-rete/index.md) |

## Referencias

- Ivan Bratko, *Prolog Programming for Artificial Intelligence*, Addison-Wesley,
  1986 — capítulo «Pattern-directed Programming», apartado «Concluding remarks».
  No tiene una edición en línea de acceso libre. El capítulo toma de allí el
  índice de la base y los grupos de módulos activados por metarreglas, que son
  la versión 6.

El código del capítulo es propio, escrito para el curso: el lenguaje de los
módulos, los intérpretes, las estrategias, el ordenamiento, la vigilancia de
la terminación, el demostrador, la memoria indexada y las fases son nuevos,
y del libro se toman las ideas y los ejemplos, no el código.
