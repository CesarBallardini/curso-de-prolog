# Capítulo 63 — Proyecto: un sistema de producción

Un **sistema de producción** es un programa hecho de reglas de condición y
acción que trabajan sobre una **memoria de trabajo**, la colección de hechos
que describe la situación actual. Cada regla es una *producción*: cuando sus
condiciones se cumplen en la memoria, sus acciones agregan, quitan o
reemplazan hechos. El intérprete repite un ciclo —reunir las instanciaciones
aplicables, elegir una, ejecutarla— hasta que ninguna regla tiene nada nuevo
que hacer. Es el **encadenamiento hacia adelante**: se parte de los datos y
se avanza hacia las conclusiones, sin una pregunta que guíe la búsqueda.
Los sistemas de producción se usaron para configurar equipos a partir de un
pedido, una tarea con muchas soluciones posibles que no conviene enumerar
hacia atrás.

El [capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md)
construyó la arquitectura: módulos `Nombre :: Condiciones ---> Acciones`, la
memoria como argumento y el conjunto de conflicto ordenado por una clave.
Este capítulo da el paso siguiente con el mismo lenguaje de reglas, en cinco
versiones. La primera trata la memoria como un **conjunto** de hechos con
**sellos de tiempo** y aplica la **refracción**: la misma regla con los
mismos hechos se dispara una sola vez. La segunda agrega las estrategias de
resolución de conflictos **LEX** y **MEA**, que eligen por la recencia de
los hechos y por la especificidad de las reglas. La tercera agrega
**marcos**: clases con valores por omisión y herencia, cuyos objetos viven en
la memoria. La cuarta es un **configurador** de computadoras, y la quinta
mide lo que cuesta, en cada ciclo, volver a comparar todas las reglas con
toda la memoria.

El proyecto parte de tres fuentes. De *Building Expert Systems in Prolog* de
Dennis Merritt vienen el sistema *Oops* —la memoria con sellos de tiempo, el
conjunto de conflicto, la refracción y las estrategias LEX y MEA de OPS5— y
*Foops*, su integración con marcos, con un configurador que ubica muebles en
una habitación. De *Prolog Programming in Depth* de Covington, Nute y
Vellino viene la separación entre hechos y metas en la memoria, con un robot
que apila cajas. De *Artificial Intelligence through Prolog* de Neil Rowe
vienen el foco de atención —preferir el hecho más reciente— y la
especificidad como criterio de orden entre reglas. La lista completa está en
[Referencias](#referencias); el código es propio.

El capítulo reutiliza las reglas como datos del
[capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md), el
encadenamiento hacia adelante del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#206-un-sistema-experto-con-encadenamiento-hacia-adelante),
el orden estándar y los conjuntos ordenados del
[capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md),
y carga los archivos del
[capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md):
sus operadores, su `bien_formado/1` y sus intérpretes, para ejecutar el
mismo programa con los dos. El
[capítulo 64](../capitulo-64-proyecto-algoritmo-rete/index.md) compila las
reglas de este capítulo en una red Rete. Los archivos se ejecutan en una
instalación local, porque cargan otros archivos; solo `memoria.pl` se puede
ejecutar en SWISH.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- representar la memoria de trabajo como un conjunto de hechos con sellos de
  tiempo, y explicar por qué el encadenamiento hacia adelante necesita
  además la refracción para terminar;
- reunir el conjunto de conflicto con reglas cuyas variables unen varias
  condiciones, y quitar las instanciaciones ya disparadas;
- escribir las estrategias LEX y MEA como claves de orden, y predecir cuál
  instanciación elige cada una;
- representar clases con marcos, con valores por omisión y herencia
  múltiple, y traducir condiciones sobre objetos a condiciones comunes;
- escribir un configurador como un sistema de producción controlado por
  fases, y comprobar que no depende del orden en que se escriben las reglas;
- medir el costo del reconocimiento en cada ciclo, y explicar qué parte de
  ese trabajo se repite.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:30 h**.
    Resolver los 5 ejercicios marcados con ★: **1:35 h**.
    Resolver los 12 ejercicios del final: **3:50 h**.

## 63.1 El programa terminado

El programa terminado se carga con `swipl ejemplos/capitulo-63/costo.pl`, o
con `configurador.pl` si no interesan las mediciones. `configurar/4` recibe
un pedido y devuelve los componentes elegidos, el precio total y el consumo
en vatios:

```prolog
?- configurar([pedido(nucleos, 8), pedido(memoria, 32), pedido(video, si)], C, P, W).
C = [procesador-cpu_b, placa-placa_a, memoria-mem_b, disipador-dis_a, placa_de_video-gpu_a, fuente-fuente_b],
P = 1125,
W = 378.
```

La memoria empieza con el catálogo de la tienda, un objeto por componente,
y el pedido. Las reglas eligen un procesador de ocho núcleos, una placa con
su zócalo, una memoria del tipo que la placa admite, un disipador porque el
procesador no trae uno, la placa de video pedida y una fuente con un margen
del 30 % sobre el consumo total; de los candidatos de cada tipo queda el más
barato. Ninguna regla llama a otra, y ninguna dice cuál se aplica después:
lo deciden la memoria y la estrategia.

| Versión | Archivo | Agrega | Lo que no puede hacer todavía |
|---|---|---|---|
| 1 | `memoria.pl`, `produccion.pl` | la memoria como conjunto con sellos, la refracción | elegir por otra cosa que el orden del programa |
| 2 | `estrategias.pl` | LEX y MEA como claves de orden | describir objetos con valores heredados |
| 3 | `marcos.pl` | clases, herencia, objetos en la memoria | — (es la base de la versión 4) |
| 4 | `configurador.pl` | el configurador de computadoras | reconocer sin repetir el trabajo de cada ciclo |
| 5 | `costo.pl` | la medición del reconocimiento | — ([capítulo 64](../capitulo-64-proyecto-algoritmo-rete/index.md)) |

## 63.2 Versión 1: la memoria como conjunto y la refracción

**El problema.** El programa `familia` es el sistema experto hacia adelante
del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#206-un-sistema-experto-con-encadenamiento-hacia-adelante),
escrito en el lenguaje de reglas del
[capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md#602-modulos-dirigidos-por-patrones).
Las reglas tienen variables que unen varias condiciones: `abuelo` pide un
padre `A` de `P` y un progenitor `P` de `N`. A diferencia del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md),
ninguna regla pregunta si su conclusión ya está en la memoria:

<!-- ejemplo: capitulo-63/produccion.pl fragmento: programa(familia, .. ]). -->
```prolog
programa(familia,
    [ progenitor_p :: [padre(P, H)] ---> [agregar(progenitor(P, H))],
      progenitor_m :: [madre(M, H)] ---> [agregar(progenitor(M, H))],
      abuelo :: [padre(A, P), progenitor(P, N)] ---> [agregar(abuelo(A, N))],
      hermanos :: [progenitor(P, A), progenitor(P, B), {A \== B}]
           ---> [agregar(hermanos(A, B))],
      antepasado_1 :: [progenitor(A, D)] ---> [agregar(antepasado(A, D))],
      antepasado_2 :: [progenitor(A, H), antepasado(H, D)]
           ---> [agregar(antepasado(A, D))]
    ]).
```

Con el intérprete del [capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md), la primera regla se aplica en cada ciclo
al mismo hecho y agrega otra copia de su conclusión. `contar_hechos/6`
ejecuta el programa con cada intérprete y cuenta los hechos de la memoria
final:

```prolog
?- familia(H), contar_hechos(capitulo_60, familia, H, R, N, D).
H = [padre(juan, ana), padre(juan, pedro), padre(pedro, luis), padre(pedro, eva), madre(marta, ana), madre(marta, pedro), madre(ana, sofia)],
R = limite(100),
N = 107,
D = 8.
```

Después de 100 ciclos la memoria tiene 107 hechos y solo 8 distintos: los 7
iniciales y `progenitor(juan, ana)`, repetido cien veces. Hacen falta dos
cambios. Si la memoria es un conjunto, agregar un hecho que ya está no la
cambia; pero la regla sigue aplicable y el ciclo la elige otra vez, sin fin.
La **refracción** completa el arreglo: una instanciación que ya se disparó
no vuelve a dispararse.

**La memoria.** `memoria.pl` guarda la memoria en un término
`mt(Reloj, Elementos)`: una lista de pares `Sello-Hecho`, del más reciente
al más antiguo, y el último sello asignado. Cada hecho nuevo recibe el valor
siguiente del reloj; un hecho que ya está conserva su sello:

<!-- ejemplo: capitulo-63/memoria.pl predicado: afirmar/3 retirar/3 elemento/3 -->
```prolog
%!  afirmar(+Hecho, +Memoria0, -Memoria) is det.
%
%   Memoria es Memoria0 con Hecho, que recibe el sello siguiente del reloj.
%   Si Hecho ya estaba, Memoria es Memoria0: ni el hecho ni el reloj
%   cambian.
afirmar(Hecho, mt(Reloj0, Elementos), Memoria) :-
    (   memberchk(_-Hecho, Elementos)
    ->  Memoria = mt(Reloj0, Elementos)
    ;   Reloj is Reloj0 + 1,
        Memoria = mt(Reloj, [Reloj-Hecho|Elementos])
    ).

%!  retirar(+Hecho, +Memoria0, -Memoria) is semidet.
%
%   Memoria es Memoria0 sin el hecho que unifica con Hecho. Falla si no hay
%   ninguno.
retirar(Hecho, mt(Reloj, Elementos0), mt(Reloj, Elementos)) :-
    selectchk(_-Hecho, Elementos0, Elementos).

%!  elemento(?Sello, ?Hecho, +Memoria) is nondet.
%
%   Hecho está en Memoria con el Sello. Enumera los hechos del más reciente
%   al más antiguo.
elemento(Sello, Hecho, mt(_, Elementos)) :-
    member(Sello-Hecho, Elementos).
```

```prolog
?- memoria_con([a, b], M0), afirmar(c, M0, M1), retirar(a, M1, M2), afirmar(a, M2, M).
M0 = mt(2, [2-b, 1-a]),
M1 = mt(3, [3-c, 2-b, 1-a]),
M2 = mt(3, [3-c, 2-b]),
M = mt(4, [4-a, 3-c, 2-b]).
```

Un hecho que se quita y vuelve a entrar es, para el intérprete, un hecho
nuevo: tiene otro sello. Los hechos no tienen variables, como en el
[capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md).

**El reconocimiento.** Una **instanciación** es una regla con los hechos que
cumplen sus condiciones. `conjunto_conflicto/3` las reúne todas en términos
`instanciacion(Nombre, Sellos, Condiciones, Acciones)`: los sellos de los
hechos usados, en el orden de las condiciones, la cantidad de condiciones y
las acciones con las variables ya ligadas:

<!-- ejemplo: capitulo-63/produccion.pl predicado: conjunto_conflicto/3 cumple_condicion/4 -->
```prolog
%!  conjunto_conflicto(+Reglas:list, +Memoria, -Instanciaciones:list) is det.
%
%   Instanciaciones tiene un término
%   instanciacion(Nombre, Sellos, Condiciones, Acciones) por cada regla y
%   cada manera de cumplir sus condiciones en Memoria: Sellos son los de
%   los hechos que cumplen sus patrones, en el orden de las condiciones, y
%   Condiciones, la cantidad de condiciones de la regla. Están en el orden
%   del programa y, dentro de una regla, del hecho más reciente al más
%   antiguo.
conjunto_conflicto(Reglas, Memoria, Instanciaciones) :-
    findall(instanciacion(Nombre, Sellos, N, Acciones),
            ( member(Nombre :: Condiciones ---> Acciones, Reglas),
              length(Condiciones, N),
              cumple(Condiciones, Memoria, Sellos)
            ),
            Instanciaciones).

%!  cumple_condicion(+Condicion, +Memoria, -Sellos:list, ?Resto:list)
%!      is nondet.
%
%   Memoria cumple Condicion. Sellos es Resto precedida por el sello del
%   hecho que cumple un patrón; una prueba {Meta} y una negación no(F) no
%   agregan ninguno.
cumple_condicion({Meta}, _, Resto, Resto) :-
    call(Meta).
cumple_condicion(no(F), Memoria, Resto, Resto) :-
    \+ elemento(_, F, Memoria).
cumple_condicion(F, Memoria, [Sello|Resto], Resto) :-
    patron(F),
    elemento(Sello, F, Memoria).
```

`findall/3` recorre las reglas del programa y cada manera de cumplir sus
condiciones; como las variables de cada regla quedan libres al retroceder,
no hace falta renombrarlas con `copy_term/2`. Una condición es un patrón que
unifica con un hecho de la memoria, `no(F)` o una prueba `{Meta}`, las
mismas del [capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md).

**La refracción.** Dos instanciaciones son la misma si tienen la misma regla
y los mismos sellos: los sellos identifican los hechos, y los hechos
determinan las variables, mientras las pruebas `{Meta}` solo comprueben o
calculen un único valor. El ciclo guarda el conjunto ordenado de los pares
`Regla-Sellos` ya disparados, con `ord_add_element/3` del
[capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#226-libraryordsets-y-librarynb_set),
y descarta las instanciaciones que están en él antes de elegir:

<!-- ejemplo: capitulo-63/produccion.pl predicado: reconocer_actuar/9 refractar/3 -->
```prolog
%!  reconocer_actuar(+Reglas:list, +Estrategia, +Traza, +N0:integer,
%!                   -N:integer, +Disparadas:list, +Memoria0, -Memoria,
%!                   -Resultado) is det.
%
%   Repite el ciclo desde Memoria0. N0 es la cantidad de ciclos hechos
%   antes, y N la cantidad al terminar. Traza es sin_traza, con_traza o
%   breve. Disparadas es el conjunto ordenado de las instanciaciones ya
%   disparadas, como pares Regla-Sellos.
reconocer_actuar(Reglas, Estrategia, Traza, N0, N, Disparadas, Memoria0,
                 Memoria, Resultado) :-
    conjunto_conflicto(Reglas, Memoria0, Todas),
    refractar(Todas, Disparadas, Nuevas),
    (   Nuevas == []
    ->  N = N0,
        Memoria = Memoria0,
        Resultado = nada_aplicable
    ;   preferida(Estrategia, Nuevas, Elegida),
        N1 is N0 + 1,
        informar(Traza, N1, Nuevas, Elegida, Memoria0),
        Elegida = instanciacion(Nombre, Sellos, _, Acciones),
        ord_add_element(Disparadas, Nombre-Sellos, Disparadas1),
        aplicar_acciones(Acciones, Memoria0, Memoria1, Fin),
        (   Fin = parar(R)
        ->  N = N1,
            Memoria = Memoria1,
            Resultado = R
        ;   reconocer_actuar(Reglas, Estrategia, Traza, N1, N, Disparadas1,
                             Memoria1, Memoria, Resultado)
        )
    ).

%!  refractar(+Instanciaciones:list, +Disparadas:list, -Nuevas:list) is det.
%
%   Nuevas son las Instanciaciones que no están en el conjunto ordenado
%   Disparadas, comparadas por su regla y sus sellos.
refractar(Instanciaciones, Disparadas, Nuevas) :-
    exclude(disparada(Disparadas), Instanciaciones, Nuevas).
```

La **estrategia** es una clave de orden, como en la
[sección 60.5](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md#605-version-3-el-conjunto-de-conflicto),
pero ahora se prefiere la **mayor**: `preferida/3` ordena con
`sort(1, @>=, Pares, Ordenados)`, que conserva el orden de los empates. La
estrategia `orden` da a todas la misma clave, y gana la primera del
conjunto de conflicto: la primera regla del programa y, dentro de ella, la
que usa los hechos más recientes.

```prolog
?- rastrear(familia, orden, [padre(juan, ana), madre(ana, sofia)], M, R).
1: progenitor_p de 2, con [1-padre(juan,ana)]
2: progenitor_m de 2, con [2-madre(ana,sofia)]
3: abuelo de 3, con [1-padre(juan,ana),4-progenitor(ana,sofia)]
4: antepasado_1 de 2, con [4-progenitor(ana,sofia)]
5: antepasado_1 de 2, con [3-progenitor(juan,ana)]
6: antepasado_2 de 1, con [3-progenitor(juan,ana),6-antepasado(ana,sofia)]
M = [antepasado(juan, sofia), antepasado(juan, ana), antepasado(ana, sofia), abuelo(juan, sofia), progenitor(ana, sofia), progenitor(juan, ana), madre(ana, sofia), padre(juan, ana)],
R = nada_aplicable.
```

Cada línea dice el ciclo, la regla, cuántas instanciaciones **nuevas**
había y los hechos usados con sus sellos. En el ciclo 2 el conjunto de
conflicto tiene tres instanciaciones, pero `progenitor_p` con el hecho 1 ya
se disparó: quedan dos. Con la familia completa, el programa llega al mismo
punto fijo que el [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md):

```prolog
?- familia(H), contar_hechos(capitulo_63, familia, H, R, N, D).
H = [padre(juan, ana), padre(juan, pedro), padre(pedro, luis), padre(pedro, eva), madre(marta, ana), madre(marta, pedro), madre(ana, sofia)],
R = nada_aplicable,
N = D, D = 34.
```

Son 29 ciclos para 27 hechos nuevos: `hermanos` se dispara una vez por cada
progenitor común, y `ana` y `pedro` tienen dos; la segunda instanciación
agrega un hecho que ya está, y la memoria no cambia. La condición
`\+ hecho(Conclusion)` del
[Patrón 18](../capitulo-20-base-de-datos-dinamica/index.md#206-un-sistema-experto-con-encadenamiento-hacia-adelante)
ya no hace falta en cada regla: la memoria como conjunto y la refracción la
cumplen para todas.

!!! question "Actividad"
    Predecir cuántos hechos tiene la memoria final y cuántos ciclos hace
    `familia` desde `[padre(juan, ana), padre(juan, pedro)]`. Comprobarlo con
    `encadenar/5` y `cantidad_de_ciclos/4`, y explicar la diferencia entre
    las dos cantidades.

**Lo que falta.** Con `orden`, el resultado depende de cómo se escribieron
las reglas: el primer programa que ordene mal sus reglas elige mal, como el
`mcd_invertido` del [capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md).

## 63.3 Versión 2: las estrategias LEX y MEA

OPS5, el lenguaje de sistemas de producción más difundido, ofrece dos
estrategias. **LEX**, después de la refracción, prefiere la instanciación
que usa los hechos más **recientes**, y entre dos igual de recientes, la de
la regla más **específica**, la que tiene más condiciones. **MEA** compara
antes el sello del **primer** patrón de cada regla, y después sigue como LEX.

La recencia se compara con listas. Los sellos de una instanciación,
ordenados de mayor a menor, forman una lista; dos listas se comparan
elemento por elemento, y la que tiene el primer sello mayor es más reciente.
Si una es prefijo de la otra, la más larga es mayor en el
[orden estándar](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#222-el-orden-estandar),
porque `[]` precede a toda lista no vacía: con los mismos hechos recientes,
gana la regla que usa más hechos. Así, una clave `lex(Sellos, N)` ordena por
recencia primero y por especificidad después, con una sola comparación:

<!-- ejemplo: capitulo-63/estrategias.pl predicado: clave_estrategia/3 -->
```prolog
%!  clave_estrategia(+Estrategia, +Instanciacion, -Clave) is det.
%
%   Con lex, Clave es lex(Sellos, N): los sellos de mayor a menor y la
%   cantidad de condiciones. Con mea, Clave es mea(Primero, Sellos, N), con
%   el sello del primer patrón, o 0 si la regla no tiene patrones.
clave_estrategia(lex, instanciacion(_, Sellos, N, _), lex(Recientes, N)) :-
    sort(0, @>=, Sellos, Recientes).
clave_estrategia(mea, instanciacion(_, Sellos, N, _),
                 mea(Primero, Recientes, N)) :-
    primer_sello(Sellos, Primero),
    sort(0, @>=, Sellos, Recientes).
```

`clave_estrategia/3` es `multifile`: `estrategias.pl` le agrega dos
cláusulas sin cambiar `produccion.pl`.

**Metas en la memoria.** El programa `cajas` es un robot que apila cajas,
como el de Covington. Las metas son hechos de la memoria: `apilar(Lista)`
pide una torre con las cajas de la lista, de abajo hacia arriba, y
`despejar(Caja)` pide que no haya nada encima de una caja. Todas las reglas
tienen la meta como primer patrón:

<!-- ejemplo: capitulo-63/estrategias.pl fragmento: programa(cajas, .. ]). -->
```prolog
programa(cajas,
    [ apilada :: [meta(apilar([X, Y|R])), sobre(Y, X)]
           ---> [reemplazar(meta(apilar([X, Y|R])), meta(apilar([Y|R])))],
      apilar :: [meta(apilar([X, Y|R])), no(sobre(_, X)), no(sobre(_, Y)),
                 sobre(Y, Z)]
           ---> [reemplazar(sobre(Y, Z), sobre(Y, X)),
                 reemplazar(meta(apilar([X, Y|R])), meta(apilar([Y|R])))],
      despejar_base :: [meta(apilar([X, Y|_])), sobre(Z, X), {Z \== Y}]
           ---> [agregar(meta(despejar(Z)))],
      despejar_segunda :: [meta(apilar([_, Y|_])), sobre(Z, Y)]
           ---> [agregar(meta(despejar(Z)))],
      despejar_encima :: [meta(despejar(X)), sobre(Y, X)]
           ---> [agregar(meta(despejar(Y)))],
      bajar :: [meta(despejar(X)), no(sobre(_, X)), sobre(X, Y),
                {Y \== piso}]
           ---> [reemplazar(sobre(X, Y), sobre(X, piso)),
                 quitar(meta(despejar(X)))],
      despejada :: [meta(despejar(X)), no(sobre(_, X))]
           ---> [quitar(meta(despejar(X)))],
      terminada :: [meta(apilar([_]))]
           ---> [quitar(meta(apilar([_])))]
    ]).
```

La memoria siguiente tiene dos metas: una torre con `c` sobre `b`, y otra
con `d` sobre `a`, pedida después; `c` está sobre `a`, de modo que la
segunda meta necesita despejar `a`. Con LEX:

```prolog
?- rastrear(cajas, lex, [sobre(a, piso), sobre(b, piso), sobre(c, a), sobre(d, piso), meta(apilar([b, c])), meta(apilar([a, d]))], M, R).
1: despejar_base de 2, con [6-meta(apilar([a,d])),3-sobre(c,a)]
2: bajar de 3, con [7-meta(despejar(c)),3-sobre(c,a)]
3: apilar de 2, con [5-meta(apilar([b,c])),8-sobre(c,piso)]
4: terminada de 2, con [10-meta(apilar([c]))]
5: apilar de 1, con [6-meta(apilar([a,d])),4-sobre(d,piso)]
6: terminada de 1, con [12-meta(apilar([d]))]
M = [sobre(d, a), sobre(c, b), sobre(b, piso), sobre(a, piso)],
R = nada_aplicable.
```

En el ciclo 3 la caja `c` acaba de llegar al piso, con el sello 8, el
mayor de la memoria. LEX elige la instanciación que lo usa, la de la meta
**antigua**, y deja la meta que motivó el despeje para después. MEA mira
primero la meta:

```prolog
?- rastrear(cajas, mea, [sobre(a, piso), sobre(b, piso), sobre(c, a), sobre(d, piso), meta(apilar([b, c])), meta(apilar([a, d]))], M, R).
1: despejar_base de 2, con [6-meta(apilar([a,d])),3-sobre(c,a)]
2: bajar de 3, con [7-meta(despejar(c)),3-sobre(c,a)]
3: apilar de 2, con [6-meta(apilar([a,d])),4-sobre(d,piso)]
4: terminada de 2, con [10-meta(apilar([d]))]
5: apilar de 1, con [5-meta(apilar([b,c])),8-sobre(c,piso)]
6: terminada de 1, con [12-meta(apilar([c]))]
M = [sobre(c, b), sobre(d, a), sobre(b, piso), sobre(a, piso)],
R = nada_aplicable.
```

Las claves de las dos instanciaciones del ciclo 3 lo explican. Con una
memoria que tiene los mismos hechos en el mismo orden, y por eso sellos del
1 al 6 en lugar de los del ciclo 3:

```prolog
?- claves(lex, cajas, [sobre(a, piso), sobre(b, piso), sobre(d, piso), meta(apilar([b, c])), meta(apilar([a, d])), sobre(c, piso)], L).
L = [apilar-lex([5, 3], 4), apilar-lex([6, 4], 4)].

?- claves(mea, cajas, [sobre(a, piso), sobre(b, piso), sobre(d, piso), meta(apilar([b, c])), meta(apilar([a, d])), sobre(c, piso)], L).
L = [apilar-mea(5, [5, 3], 4), apilar-mea(4, [6, 4], 4)].
```

`[6, 4]` es mayor que `[5, 3]`: LEX prefiere la segunda, la de la meta
`apilar([b, c])`, sello 4, con `sobre(c, piso)`, sello 6. MEA compara
primero el sello de la meta, 5 contra 4, y prefiere la primera. Con MEA las
metas se atienden como una pila: la más reciente, y las submetas que crea,
primero. Es el uso que Merritt señala para MEA: poner la meta en el primer
patrón de cada regla da al programador el control del orden.

Ninguna estrategia es mejor en todos los casos. Con `orden` el robot
resuelve las dos torres en cuatro ciclos, porque `apilar` está escrita antes
que `despejar_base` y lleva `c` directamente de `a` a `b`; con LEX y MEA,
la meta más reciente pide despejar `a` antes, y hacen seis ciclos.

!!! question "Actividad"
    Antes de ejecutarlo, escribir las claves LEX de las instanciaciones de
    `familia` en la memoria `[padre(juan, ana), madre(marta, ana),
    progenitor(juan, ana)]`, y predecir cuál elige LEX. Comprobarlo con
    `claves/4`.

**Lo que falta.** Los hechos son términos planos: cada propiedad de una cosa
es un hecho aparte, y lo que comparten todas las cosas de una clase se
repite en cada una.

## 63.4 Versión 3: marcos

Un **marco** describe una clase con **ranuras**: los atributos de sus
objetos, con valores por omisión. Una clase hereda de otras, y un valor que
la clase no define se busca en sus padres. `marcos.pl` escribe cada clase
como un hecho `marco(Clase, Padres, Ranuras)`, con los componentes de una
computadora:

<!-- ejemplo: capitulo-63/marcos.pl fragmento: marco(componente, .. marco(fuente, [componente], []). -->
```prolog
marco(componente, [], [precio-0, consumo-0]).
marco(refrigerado, [], [necesita_disipador-si]).
marco(procesador, [componente, refrigerado], [consumo-65]).
marco(placa, [componente], [consumo-30]).
marco(memoria, [componente], [consumo-5]).
marco(placa_de_video, [componente], [consumo-200]).
marco(disipador, [componente], [consumo-3]).
marco(fuente, [componente], []).
```

`procesador` hereda de dos clases: de `componente`, el precio, y de
`refrigerado`, la necesidad de un disipador. `es_un/2` recorre la jerarquía
en profundidad, en el orden de los padres, y `valor_ranura/4` busca el valor
propio del objeto, y si no lo tiene, el de la primera clase que lo define:

<!-- ejemplo: capitulo-63/marcos.pl predicado: es_un/2 valor_ranura/4 -->
```prolog
%!  es_un(+Clase, ?Superclase) is nondet.
%
%   Superclase es la Clase misma o una clase de la que hereda, en
%   profundidad y en el orden de los padres.
es_un(Clase, Clase).
es_un(Clase, Superclase) :-
    marco(Clase, Padres, _),
    member(Padre, Padres),
    es_un(Padre, Superclase).

%!  valor_ranura(+Clase, +Ranuras:list, +Ranura, -Valor) is semidet.
%
%   Valor es el de la Ranura en un objeto de la Clase con los valores
%   propios Ranuras: el propio si lo tiene, o el primero que define una de
%   sus clases. Falla si ninguna lo define.
valor_ranura(_, Ranuras, Ranura, Valor) :-
    memberchk(Ranura-Propio, Ranuras),
    !,
    Valor = Propio.
valor_ranura(Clase, _, Ranura, Valor) :-
    once(( es_un(Clase, Superclase),
           marco(Superclase, _, PorOmision),
           memberchk(Ranura-Heredado, PorOmision)
         )),
    Valor = Heredado.
```

```prolog
?- es_un(procesador, C).
C = procesador ;
C = componente ;
C = refrigerado ;
false.

?- valor_ranura(procesador, [consumo-120], consumo, V).
V = 120.

?- valor_ranura(procesador, [], consumo, V).
V = 65.

?- valor_ranura(procesador, [], necesita_disipador, V).
V = si.

?- valor_ranura(placa, [], necesita_disipador, V).
false.
```

Las clases son fijas, parte del programa; los **objetos** están en la
memoria de trabajo, como hechos `objeto(Nombre, Clase, Ranuras)` con los
valores propios de cada uno. Así la memoria sigue siendo una colección de
hechos sin variables, y el intérprete no cambia.

**Condiciones sobre objetos.** Una regla puede pedir
`es(Objeto, Clase, Consultas)`: un objeto de la clase o de una subclase suya,
con los valores pedidos en sus ranuras, propios o heredados. `con_marcos/2`
traduce esa condición a un patrón `objeto/3` y una prueba, y traduce las
acciones `crear/3` y `poner/3` a `agregar/1` y `reemplazar/2`:

<!-- ejemplo: capitulo-63/marcos.pl predicado: condicion_con_marcos/4 -->
```prolog
%!  condicion_con_marcos(+Condicion, -Traduccion:list, +Objetos0:list,
%!                       -Objetos:list) is det.
%
%   Traduccion son las condiciones que reemplazan a Condicion. Objetos
%   tiene un término obj(Objeto, Clase, Ranuras) por cada objeto ya
%   buscado, con las variables de su clase y de sus ranuras.
condicion_con_marcos(Condicion, Traduccion, Objetos0, Objetos) :-
    (   Condicion = es(Objeto, Clase, Consultas)
    ->  (   buscado(Objeto, Objetos0, ClaseReal, Ranuras)
        ->  Traduccion = [Prueba],
            Objetos = Objetos0
        ;   Traduccion = [objeto(Objeto, ClaseReal, Ranuras), Prueba],
            Objetos = [obj(Objeto, ClaseReal, Ranuras)|Objetos0]
        ),
        Prueba = {es_de_clase(ClaseReal, Clase),
                  consultar(ClaseReal, Ranuras, Consultas)}
    ;   Traduccion = [Condicion],
        Objetos = Objetos0
    ).
```

Si el mismo objeto aparece en otra condición `es/3`, la segunda solo agrega
la prueba: el objeto ya está ligado a un hecho. El programa `disipadores`
marca los componentes que necesitan un disipador:

```prolog
?- programa(disipadores, [R]).
R = (marcar::[objeto(_A, _B, _C), {es_de_clase(_B, componente), consultar(_B, _C, [necesita_disipador-si])}]--->[agregar(requiere_disipador(_A))]).

?- encadenar(disipadores, lex, [objeto(cpu_a, procesador, [necesita_disipador-no]), objeto(cpu_b, procesador, []), objeto(gpu_a, placa_de_video, [])], M, R).
M = [requiere_disipador(cpu_b), objeto(gpu_a, placa_de_video, []), objeto(cpu_b, procesador, []), objeto(cpu_a, procesador, [necesita_disipador-no])],
R = nada_aplicable.
```

`cpu_a` trae su disipador y lo dice en una ranura propia; `cpu_b` hereda el
`si` de `refrigerado`; `gpu_a` no hereda de `refrigerado`, y la consulta
falla. La traducción deja las reglas en el lenguaje del [capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md), con
patrones y pruebas: es lo que el
[capítulo 64](../capitulo-64-proyecto-algoritmo-rete/index.md) necesita para
compilarlas.

## 63.5 Versión 4: un configurador

`configurador.pl` elige los componentes de una computadora para un pedido.
La memoria empieza con el catálogo, un objeto por componente, el pedido y
el orden de las fases. Cada tipo de componente pasa por dos fases: en
`buscar(Tipo)` una regla agrega un candidato por cada componente
compatible con lo ya elegido, y en `elegir(Tipo)` se descartan los más
caros y se elige el que queda. Ninguna regla dice cuándo termina una fase:
lo decide la estrategia, por los sellos y la cantidad de condiciones. Un
pedido imposible no detiene la configuración:

```prolog
?- configurar([pedido(nucleos, 6), pedido(memoria, 64), pedido(video, no)], C, P, W).
C = [procesador-cpu_c, placa-placa_b, falta(memoria), disipador-dis_a, fuente-fuente_a],
P = 375,
W = 98.
```

La página [Un configurador](configurador.md#un-configurador) desarrolla la
versión: el catálogo, las reglas de cada fase, por qué las fases se
suceden en el orden correcto, la traza de una configuración y el mismo
programa con las reglas en el orden inverso.

!!! question "Actividad"
    `configurador_invertido` tiene las mismas reglas en el orden inverso.
    Antes de leer lo que sigue, predecir qué componentes elige para el
    pedido de 6 núcleos, 16 GB y sin placa de video con `orden`, con `lex`
    y con `mea`. Comprobarlo con `configuracion/5`.

**Lo que falta.** El configurador elige por fases y, en cada una, lo más
barato: no vuelve atrás si una elección temprana encarece las siguientes.
Y cada ciclo vuelve a comparar todas las reglas con todo el catálogo.

## 63.6 Versión 5: el costo del reconocimiento

`costo.pl` ejecuta el mismo ciclo y registra, en cada uno, el tamaño del
conjunto de conflicto, cuántas de sus instanciaciones ya estaban en el del
ciclo anterior —la misma regla con los mismos sellos— y cuántas inferencias
costó reunirlo, medidas con `statistics/2` como en el
[capítulo 16](../capitulo-16-rendimiento/index.md#161-medir):

<!-- ejemplo: capitulo-63/costo.pl predicado: medir_ciclos/7 -->
```prolog
%!  medir_ciclos(+Reglas:list, +Estrategia, +N:integer, +Anteriores:list,
%!               +Disparadas:list, +Memoria, -Filas:list) is det.
%
%   Como reconocer_actuar/9, y devuelve la fila de cada ciclo. Anteriores
%   es el conjunto ordenado de las instanciaciones del ciclo anterior, como
%   pares Regla-Sellos.
medir_ciclos(Reglas, Estrategia, N, Anteriores, Disparadas, Memoria0,
             Filas) :-
    statistics(inferences, I0),
    conjunto_conflicto(Reglas, Memoria0, Todas),
    statistics(inferences, I1),
    Inferencias is I1 - I0,
    maplist(identidad, Todas, Identidades0),
    sort(Identidades0, Identidades),
    ord_intersection(Identidades, Anteriores, Comunes),
    length(Todas, Tamano),
    length(Comunes, Repetidas),
    refractar(Todas, Disparadas, Nuevas),
    (   Nuevas == []
    ->  Filas = []
    ;   preferida(Estrategia, Nuevas, Elegida),
        Elegida = instanciacion(Nombre, Sellos, _, Acciones),
        ord_add_element(Disparadas, Nombre-Sellos, Disparadas1),
        aplicar_acciones(Acciones, Memoria0, Memoria1, Fin),
        Filas = [ciclo(N, Tamano, Repetidas, Inferencias)|Filas1],
        (   Fin = parar(_)
        ->  Filas1 = []
        ;   N1 is N + 1,
            medir_ciclos(Reglas, Estrategia, N1, Identidades, Disparadas1,
                         Memoria1, Filas1)
        )
    ).
```

```prolog
?- familia(H), medir(familia, orden, H, C, I, R, Inf).
H = [padre(juan, ana), padre(juan, pedro), padre(pedro, luis), padre(pedro, eva), madre(marta, ana), madre(marta, pedro), madre(ana, sofia)],
C = 29,
I = 651,
R = 622,
Inf = 21606.
```

En 29 ciclos se reunieron 651 instanciaciones, y 622 de ellas, el 96 %,
estaban ya en el ciclo anterior. En un programa que solo agrega hechos, el
conjunto de conflicto crece en cada ciclo: la refracción descarta las
instanciaciones viejas, pero el reconocimiento las vuelve a calcular.

El configurador muestra el otro factor, el tamaño de la memoria.
`pedido_ampliado/2` agrega al catálogo memorias que ninguna placa admite:
no cambian la configuración ni el conjunto de conflicto, pero cada patrón
`objeto/3` se compara con ellas en cada ciclo:

```prolog
?- medir_ampliado(100, H, C, I, Inf).
H = 128,
C = 21,
I = 46,
Inf = 72689.
```

| Hechos iniciales | Ciclos | Instanciaciones | Inferencias | Por ciclo |
|---|---|---|---|---|
| 28 | 21 | 46 | 18 789 | 895 |
| 128 | 21 | 46 | 72 689 | 3 461 |
| 228 | 21 | 46 | 126 589 | 6 028 |
| 428 | 21 | 46 | 234 389 | 11 161 |

El costo por ciclo crece con la memoria, en unas 26 inferencias por cada
hecho agregado al catálogo, aunque cada ciclo quita y agrega a lo sumo seis
hechos y el conjunto de conflicto nunca pasa de cuatro instanciaciones. El trabajo útil de un ciclo
es proporcional a lo que cambió; el reconocimiento de este capítulo es
proporcional a todo lo que hay. El
[capítulo 64](../capitulo-64-proyecto-algoritmo-rete/index.md) conserva
entre ciclos las comparaciones ya hechas y procesa solo los hechos que
entran y salen.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `cumple/3` y `es_un/2` son `nondet`, `retirar/3` y `aplicar_acciones/4` son `semidet` porque fallan si se quita un hecho ausente, y los ciclos son `det` |
    | C2 | las reglas son datos del lenguaje del [capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md), verificadas con su `bien_formado/1`; los marcos se traducen a ese lenguaje en lugar de extender el intérprete |
    | C4 | los ciclos eligen con un si-entonces y `valor_ranura/4` corta después del valor propio; las pruebas, que fallan si queda una alternativa pendiente, lo confirman |
    | C6 | la memoria viaja en argumentos como un término `mt/2`; la traza es la única salida, y las estrategias se agregan con cláusulas `multifile` sin tocar el intérprete |
    | C7 | 52 pruebas en seis archivos: la memoria como conjunto, el punto fijo del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md), la comparación con el [capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md), las claves y sus empates, la herencia, la traducción de reglas, las tres configuraciones, el programa invertido y las mediciones |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios extienden los programas: cada solución es un
archivo que carga los del capítulo, sin modificarlos.

1. ★ **(1)** Predecir la traza de `rastrear(cajas, orden, [sobre(a, piso),
   sobre(b, a), meta(apilar([b, a]))], M, R)`: qué reglas se disparan, en qué
   orden, y cómo queda la memoria. Comprobarlo.
2. ★ **(2)** Escribir `encadenar_vigilado/7`, que ejecuta un programa con un
   límite de ciclos y con la refracción activada o no. Predecir qué ocurre
   con `familia` sin refracción, comprobarlo con un límite de 50 ciclos y
   explicar por qué la memoria como conjunto no basta para terminar.
3. **(1)** Escribir a mano las claves LEX y MEA de las instanciaciones con
   sellos `[4, 9]`, `[9, 2, 7]` y `[9, 7]`, de reglas con 2, 3 y 3
   condiciones, y decir cuál elige cada estrategia. Comprobarlo con
   `clave_estrategia/3` y `preferida/3`.
4. **(2)** Agregar, desde otro archivo, la estrategia `prioridad`: cada
   regla puede tener una prioridad en un hecho `prioridad(Regla, P)`, que
   se compara antes que la clave LEX; una regla sin prioridad tiene 0.
   Usarla para que `cajas` con `prioridad` resuelva las dos torres de la
   [sección 63.3](#633-version-2-las-estrategias-lex-y-mea) en cuatro ciclos.
5. ★ **(2)** Predecir qué hacen `orden`, `lex` y `mea` con el programa
   `cajas` desde una torre `c` sobre `b` sobre `a` y la meta
   `apilar([c, b, a])`, que la invierte. Comprobarlo con `rastrear/5`, y
   explicar el resultado a partir del tamaño del conjunto de conflicto en
   cada ciclo.
6. **(1)** Predecir `valor_ranura/4` para la ranura `precio` de una fuente
   sin valor propio, para `consumo` de una memoria con `consumo-8`, y para
   `necesita_disipador` de un disipador. Comprobarlo.
7. **(2)** Agregar la clase `apu`, un procesador con video integrado, que
   hereda de `procesador` y de `placa_de_video`. Predecir su consumo y si
   necesita disipador; cambiar el orden de los padres y volver a
   predecirlo.
8. ★ **(2)** Una alternativa para el consumo es una regla aparte,
   `sumar :: [elegido(T, X), es(X, componente, [consumo-C]), consumo(W)]
   ---> [...]`, que suma el consumo de cada componente elegido. Predecir
   qué hace el configurador con esa regla en lugar de la suma de `elegir`,
   comprobarlo con el `encadenar_vigilado/7` del ejercicio 2 y explicar por
   qué la refracción no lo evita.
9. ★ **(3)** Agregar al configurador el gabinete: una clase `gabinete` con
   la ranura `formatos`, la lista de formatos de placa que admite, una
   ranura `formato` en las placas con `atx` por omisión, y una fase
   `gabinete` después de la fuente. Escribirlo como un programa nuevo y una
   memoria inicial nueva, sin cambiar `configurador.pl`.
10. **(3)** Escribir con Prolog, sin reglas de producción, la búsqueda de la
    configuración compatible más barata para un pedido, y compararla con la
    del configurador en los tres pedidos del capítulo. Construir un catálogo
    en que las dos difieran, y explicar por qué.
11. **(2)** Medir con `medir/7` el programa `familia` con dos, cuatro y ocho
    copias de la familia, con nombres distintos. Explicar cómo crecen los
    ciclos, las instanciaciones reunidas y las repetidas.
12. **(3)** Escribir `con_origen/2`, que transforma las reglas de un programa
    para que cada `agregar(F)` agregue también `origen(F, Regla, Hechos)`,
    con los hechos que cumplieron los patrones de la regla. Usarlo para
    explicar cómo se obtuvo `antepasado(juan, sofia)` en `familia`.

## Resumen

| | |
|---|---|
| **sistema de producción** | reglas de condición y acción sobre una memoria de trabajo, repetidas hasta que ninguna tiene nada nuevo que hacer |
| **encadenamiento hacia adelante** | de los datos a las conclusiones, sin una pregunta que guíe la búsqueda |
| **memoria como conjunto** | un hecho que ya está no se agrega; cada hecho nuevo recibe un sello del reloj |
| **instanciación** | una regla con los hechos que cumplen sus condiciones, identificada por la regla y los sellos |
| **refracción** | una instanciación se dispara una sola vez |
| **LEX** | los sellos de mayor a menor, comparados como listas; con los mismos sellos, más condiciones |
| **MEA** | el sello del primer patrón antes que LEX: las metas se atienden como una pila |
| **marco** | una clase con ranuras y valores por omisión que hereda de otras clases |
| **objeto** | un hecho `objeto(Nombre, Clase, Ranuras)` de la memoria, con los valores propios |
| **costo del reconocimiento** | cada ciclo compara todas las reglas con toda la memoria, aunque cambie pocos hechos |
| `memoria.pl`, `produccion.pl` | la memoria con sellos, el conjunto de conflicto, la refracción y el ciclo |
| `estrategias.pl`, `marcos.pl` | LEX, MEA, el robot de las cajas; las clases y la traducción de `es/3` |
| `configurador.pl`, `costo.pl` | el configurador de computadoras y la medición del reconocimiento |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Las reglas de este capítulo compiladas en una red que conserva las comparaciones entre ciclos: memorias alfa por patrón, memorias beta por condiciones unidas, y solo los hechos que cambian recorren la red | [capítulo 64](../capitulo-64-proyecto-algoritmo-rete/index.md) |

## Referencias

- Dennis Merritt, *Building Expert Systems in Prolog*, Springer-Verlag,
  1989 — capítulos «Forward Chaining» (el sistema *Oops*, el conjunto de
  conflicto, los sellos de tiempo, LEX y MEA), «Frames» e «Integration»
  (*Foops* y el configurador de muebles).
  [Edición en línea](https://www.amzi.com/ExpertSystemsInProlog/), de
  Amzi!. El capítulo toma de allí la memoria con sellos de tiempo, la
  refracción como instanciación ya disparada, LEX con listas de sellos
  ordenadas y comparadas elemento por elemento, MEA como filtro por el
  primer patrón, las metas de control en la memoria, la regla sin
  condiciones que se dispara al final por especificidad, los marcos con
  valores por omisión y herencia múltiple, los objetos de marco en la
  memoria con reglas que los consultan, y la idea de un configurador como
  caso de estudio.
- Michael A. Covington, Donald Nute y André Vellino, *Prolog Programming in
  Depth*, Prentice Hall, 1997 — apartados «A Simple Forward Chainer» y
  «Production Rules in Prolog».
  [Edición en línea](https://www.covingtoninnovations.com/books/PPID.pdf),
  del autor. El capítulo toma de allí la separación entre hechos y metas
  en la memoria, el robot que apila cajas con metas intermedias, y la
  observación de que la resolución de conflictos importa solo cuando el
  conjunto tiene más de un miembro.
- Neil C. Rowe, *Artificial Intelligence through Prolog*, Prentice-Hall,
  1988 — capítulos «Control structures for rule-based systems» e
  «Implementation of rule-based systems».
  [Edición en línea](https://hdl.handle.net/10945/36984), del archivo de la
  Naval Postgraduate School. El capítulo toma de allí el foco de atención
  —el hecho más reciente primero—, la especificidad como criterio de orden
  entre reglas, las meta-reglas que eligen entre reglas, que aquí son las
  claves de orden, y las reglas parciales con condiciones ya cumplidas, que
  anticipan la red del [capítulo 64](../capitulo-64-proyecto-algoritmo-rete/index.md).

El código del capítulo es propio, escrito para el curso: la memoria, el
intérprete, las claves, la traducción de los marcos, el robot, el
configurador y la medición son nuevos, y de los libros se toman las ideas y
los ejemplos, no el código.
