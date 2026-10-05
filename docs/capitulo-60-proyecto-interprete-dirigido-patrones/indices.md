# Índices y metarreglas

Esta página contiene la sección
[60.8](index.md#608-version-6-indices-y-metarreglas) del
[capítulo 60](index.md): la versión 6, `indices.pl`, que indexa la memoria y
parte el programa en fases. El archivo está en `ejemplos/capitulo-60/`, con
sus pruebas, y carga la versión 3, `conflictos.pl`.

## Índices y metarreglas

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

<!-- ejemplo: capitulo-60/indices.pl predicado: agregar_hecho/3 hecho_en/3 -->
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

<!-- ejemplo: capitulo-60/indices.pl predicado: elegir_i/3 -->
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

<!-- ejemplo: capitulo-60/indices.pl fragmento: programa_fases(mcd_fases, .. ]). -->
```prolog
programa_fases(mcd_fases,
    [ calcular - [ resta :: [numero(X), numero(Y), {X > Y}]
                        ---> [{Z is X - Y},
                              reemplazar(numero(X), numero(Z))] ],
      informar - [ resultado :: [numero(X)]
                        ---> [parar(X)] ]
    ]).
```

<!-- ejemplo: capitulo-60/indices.pl predicado: fases/5 -->
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
[sección 60.2](index.md#602-modulos-dirigidos-por-patrones), `resultado` se
puede aplicar siempre, y el programa depende de que la resolución de
conflictos prefiera `resta`: con `mcd_invertido` y la estrategia `primera`
responde el primer número. Con fases, la fase `calcular` solo tiene `resta`,
y `resultado` no se considera hasta que `resta` no se puede aplicar. El orden
de los módulos y la estrategia dejan de importar:

`ejecutar_fases_de/5` recibe el nombre del programa por fases:

```prolog
?- ejecutar_fases_de(mcd_fases, especifica, [numero(25), numero(10), numero(15)], M, R).
M = [numero(5), numero(5), numero(5)],
R = 5.
```

### Lo que cuesta

Con los números 60, 120, …, 720 del ejercicio 11, con y sin los 100 hechos
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
[capítulo 64](../capitulo-64-proyecto-algoritmo-rete/index.md).

!!! question "Actividad"
    Predecir cuántos ciclos hace `ordenar` sobre `[4, 5, 1, 3, 2]` con la
    memoria indexada y las tres estrategias, comparados con los de
    `ciclos/4` de la versión 3. Comprobarlo con `ciclo_i/7`, que devuelve la
    cantidad de ciclos, sobre la memoria que da `indexar/2` para la lista de
    `posiciones/2`.
