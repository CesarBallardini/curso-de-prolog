# Capítulo 6 — Recursión

La recursión es el único mecanismo de repetición de Prolog. No existe otra
construcción con ese propósito, por lo que conviene estudiarla en detalle: los
temas posteriores —las listas del [capítulo 7](../capitulo-07-listas/index.md), la aritmética del [capítulo 8](../capitulo-08-aritmetica/index.md), los
árboles del [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md)— son aplicaciones de la recursión a distintas estructuras.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- escribir un predicado recursivo, separando el caso base del caso recursivo;
- determinar, a partir de una regla recursiva, si termina y por qué;
- definir estructuras nuevas, como los números naturales, usando solo términos;
- escribir una recursión que produzca un resultado, además de verificar una
  relación.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:10 h**.
    Resolver los 6 ejercicios marcados con ★: **1:35 h**.
    Resolver los 14 ejercicios del final: **4:40 h**.

## 6.1 Una regla que se invoca a sí misma

Con las reglas del [capítulo 3](../capitulo-03-reglas-y-conjunciones/index.md) se puede definir "abuelo" —dos generaciones— y
también "bisabuelo" —tres—, escribiendo una regla para cada relación. No se
puede definir **antepasado**, porque la cantidad de generaciones no se conoce de
antemano: habría que escribir una regla para cada profundidad posible.

La recursión resuelve exactamente ese problema. Una regla puede usar en su
cuerpo el mismo predicado que está definiendo.

Retomaremos el ejemplo es el del [capítulo 1](../capitulo-01-la-primera-hora/index.md):

<!-- ejemplo: capitulo-06/antepasados.pl predicado: antepasado/2 consulta: antepasado(tare, isaac). -->
```prolog
%!  antepasado(?A, ?D) is nondet.
%
%   A es antepasado de D.
%   Caso base: un progenitor es un antepasado. Caso recursivo: se desciende
%   una generación y se plantea la misma pregunta desde ese punto.
antepasado(A, D) :-
    progenitor(A, D).
antepasado(A, D) :-
    progenitor(A, Hijo),
    antepasado(Hijo, D).
```

¿Cuál es la función de cada cláusula?

- la primera resuelve el caso más simple: si A es
  progenitor de D, ya es su antepasado;
- la segunda desciende una generación —`progenitor(A, Hijo)`— y vuelve a plantear la misma pregunta desde ahí.

El programa completo está en `antepasados.pl`, con el árbol de Taré del
[capítulo 1](../capitulo-01-la-primera-hora/index.md). Sobre él:

```prolog
?- antepasado(tare, isaac).
true ;
false.
```

Taré no es progenitor de Isaac, de modo que la primera cláusula no alcanza. La
segunda desciende a Abraham y pregunta si Abraham es antepasado de Isaac; ahora
sí, responde la primer cláusula.

El árbol de derivación de la [sección 5.2](../capitulo-05-como-responde-prolog/index.md#52-el-arbol-de-derivacion)
muestra ese recorrido, y también de dónde salen el `;` y el `false.`. Con los
siete hechos de `padre/2` numerados R1 a R7 en el orden del programa
—`padre(tare, abraham).` es R1, `padre(abraham, isaac).` es R4— y las cláusulas
restantes a continuación:

| | |
|---|---|
| R8 | `madre(sara, isaac).` |
| R9 | `progenitor(P, H) :- padre(P, H).` |
| R10 | `progenitor(P, H) :- madre(P, H).` |
| R11 | `antepasado(A, D) :- progenitor(A, D).` |
| R12 | `antepasado(A, D) :- progenitor(A, Hijo), antepasado(Hijo, D).` |

El árbol completo tiene más de cincuenta arcos, porque cada llamada a
`progenitor/2` abre dos ramas y la familia de Taré es grande. Se parte en tres
diagramas: el primero muestra las dos cláusulas de `antepasado/2` sobre Taré;
el segundo, los tres hijos de Taré; el tercero, la rama de Abraham, que alcanza
la hoja de éxito. Además, un nodo «⋯ todas sus ramas fallan» **resume un subárbol**
que el recorrido agotó sin encontrar ninguna hoja de éxito: su segunda línea
indica qué sustituciones consumió, y la leyenda que sigue a los diagramas dice
por qué falla.

```mermaid
flowchart TD
    A["antepasado(tare, isaac)"] -- "R11. θ₁ = {&nbsp;A/tare, D/isaac&nbsp;}" --> B["progenitor(tare, isaac)"]
    A -- "R12. θ₄ = {&nbsp;A/tare, D/isaac&nbsp;}" --> C["progenitor(tare, Hijo),<br/>antepasado(Hijo, isaac)"]
    B -- "R9. θ₂ = {&nbsp;P/tare, H/isaac&nbsp;}" --> B1["padre(tare, isaac)"]
    B -- "R10. θ₃ = {&nbsp;P/tare, H/isaac&nbsp;}" --> B2["madre(tare, isaac)"]
    B1 --> F1(["falla"])
    B2 --> F2(["falla"])
    C -- "R9. θ₅ = {&nbsp;P₂/tare, H₂/Hijo&nbsp;}" --> C1["padre(tare, Hijo),<br/>antepasado(Hijo, isaac)"]
    C -- "R10. θ₅₆ =<br/>{&nbsp;P₂/tare, H₂/Hijo&nbsp;}" --> C2["madre(tare, Hijo),<br/>antepasado(Hijo, isaac)"]
    C2 --> F3(["falla"])
    C1 --> V["⋮<br/>sigue en el árbol siguiente"]
    classDef abierto fill:none,stroke:none;
    class V abierto;
```

El segundo diagrama continúa desde `padre(tare, Hijo), antepasado(Hijo, isaac)`:
los tres hechos R1, R2 y R3 unifican con `padre(tare, Hijo)`, y abren una rama
por hijo.

```mermaid
flowchart TD
    C1["padre(tare, Hijo),<br/>antepasado(Hijo, isaac)"]
    C1 -- "R1. θ₆ = {&nbsp;Hijo/abraham&nbsp;}" --> D["antepasado(abraham, isaac)"]
    C1 -- "R2. θ₂₁ = {&nbsp;Hijo/nacor&nbsp;}" --> Dn["antepasado(nacor, isaac)"]
    C1 -- "R3. θ₂₈ = {&nbsp;Hijo/haran&nbsp;}" --> Dh["antepasado(haran, isaac)"]
    D --> V["⋮<br/>sigue en el árbol siguiente"]
    Dn --> R2(["⋯ todas sus ramas fallan<br/>θ₂₂ a θ₂₇"])
    Dh --> R3(["⋯ todas sus ramas fallan<br/>θ₂₉ a θ₅₅"])
    classDef abierto fill:none,stroke:none;
    class V abierto;
```

El tercero continúa desde `antepasado(abraham, isaac)`, el nodo que alcanza la
hoja de éxito:

```mermaid
flowchart TD
    D["antepasado(abraham, isaac)"]
    D -- "R11. θ₇ = {&nbsp;A₂/abraham, D₂/isaac&nbsp;}" --> E["progenitor(abraham, isaac)"]
    D -- "R12. θ₁₁ = {&nbsp;A₂/abraham, D₂/isaac&nbsp;}" --> D2["progenitor(abraham, Hijo₂),<br/>antepasado(Hijo₂, isaac)"]
    E -- "R9. θ₈ = {&nbsp;P₃/abraham, H₃/isaac&nbsp;}" --> F["padre(abraham, isaac)"]
    E -- "R10. θ₁₀ = {&nbsp;P₃/abraham, H₃/isaac&nbsp;}" --> E2["madre(abraham, isaac)"]
    F -- "R4. θ₉ = {&nbsp;}" --> S(["consulta vacía"])
    E2 --> F4(["falla"])
    D2 --> R1(["⋯ todas sus ramas fallan<br/>θ₁₂ a θ₂₀"])
```

La hoja de éxito está en `θ₉`: es el `true`. Después del `;`, Prolog retrocede
y recorre, en este orden, todo lo que quedó pendiente a la derecha de esa rama
en los tres diagramas:
`madre(abraham, isaac)` falla; el caso recursivo sobre Abraham (`θ₁₂` a `θ₂₀`)
falla porque su único hijo es Isaac, e Isaac no tiene hijos; la rama de Nacor
(`θ₂₂` a `θ₂₇`) falla porque Nacor no tiene hijos; la de Harán (`θ₂₉` a `θ₅₅`)
recorre a Lot, Milca e Isca sin encontrar a Isaac; y `madre(tare, Hijo)` falla.
Agotado el árbol, la respuesta es `false.`. Las cuarenta y siete sustituciones
posteriores al `true` son el costo de las ramas que fallan, señalado en la
[sección 5.2](../capitulo-05-como-responde-prolog/index.md#52-el-arbol-de-derivacion).

### Por qué termina

Toda recursión plantea las mismas preguntas: **¿qué se reduce en cada llamada?**, y
**¿dónde se detiene?**

En este caso la respuesta se ve en el árbol genealógico. Cada llamada recursiva empieza
una generación más abajo que la anterior, y la familia tiene una cantidad finita
de generaciones: al llegar a alguien que no tiene hijos, `progenitor(A, Hijo)`
falla y esa rama se agota. No hay manera de descender para siempre.

Ese es el requisito fundamental para que el programa termine: **el caso recursivo debe avanzar hacia el caso base**. La [sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas) mostró qué ocurre cuando esto no es así.

La recursión funciona porque el problema tiene una estructura recurrente.  Tomemos el caso de una babushka, esas muñecas rusas huecas que se anidan una dentro de otra: desarmar una babushka puede pensarse como un procedimiento recurrente que toma un muñeca como argumento; cuando quitamos la muñeca hueca externa, nos queda una babushka todavía.  Como el objeto resultante tiene la misma forma que el argumento, una babushka, podemos a su vez aplicarle el procedimiento desarmar. Así seguiremos aplicando el procedimiento hasta que nos encontremos con una muñeca que ya no es hueca, en ese caso hemos llegado al final de la tarea de desarme.

![Una babushka a medio desarmar: las dos muñecas exteriores ya están abiertas, y la que queda es todavía una babushka](babushka.svg)

Vemos que el procedimiento de desarme debe considerar dos casos: la muñeca externa es hueca, la muñeca externa es maciza.

## 6.2 Caso base y caso recursivo

La forma de `antepasado/2` no es particular de las familias. Todo predicado
recursivo tiene esas dos partes, y ambas son obligatorias:

- el **caso base**, que resuelve la instancia más simple del problema sin
  invocarse nuevamente;
- el **caso recursivo**, que resuelve una instancia mayor reduciéndola a una
  menor pero de la "misma forma" e invocándose a sí mismo.

La babushka de la sección anterior muestra las dos partes con claridad. Una
babushka se escribe con dos clases de términos: `babushka_hueca(Interior)` es
una muñeca hueca que tiene otra babushka adentro, y `babushka_maciza` es la
muñeca maciza del centro, que ya no se abre. Una babushka de cuatro muñecas
—tres huecas y la maciza— es este término:

```prolog
babushka_hueca(babushka_hueca(babushka_hueca(babushka_maciza)))
```

Desarmarla es un predicado de dos cláusulas, una por cada caso:

<!-- ejemplo: capitulo-06/babushka.pl predicado: desarma/1 consulta: desarma(babushka_hueca(babushka_hueca(babushka_hueca(babushka_maciza)))). -->
```prolog
%!  desarma(?B) is nondet.
%
%   La babushka B se puede desarmar por completo.
% Caso base: la muñeca maciza no tiene nada adentro.
desarma(babushka_maciza).
% Caso recursivo: se quita la muñeca hueca exterior y se desarma lo que queda.
desarma(babushka_hueca(Interior)) :-
    desarma(Interior).
```

- el **caso base** es `desarma(babushka_maciza)`: la muñeca maciza es la
  instancia más simple del problema. No hay nada que quitar, y la cláusula es
  un hecho, sin ninguna invocación a `desarma/1`;
- el **caso recursivo** es la segunda cláusula. Su cabeza separa la muñeca
  exterior de su contenido, `Interior`, y su cuerpo plantea el mismo problema
  sobre ese contenido. `Interior` es otra babushka, de la "misma forma" que la
  original, y más chica: tiene un `babushka_hueca` menos.

Cada llamada quita un nivel del término, hasta que lo que queda es la muñeca
maciza:

| Llamada | La resuelve |
|---|---|
| `desarma(babushka_hueca(babushka_hueca(babushka_hueca(babushka_maciza))))` | el caso recursivo |
| `desarma(babushka_hueca(babushka_hueca(babushka_maciza)))` | el caso recursivo |
| `desarma(babushka_hueca(babushka_maciza))` | el caso recursivo |
| `desarma(babushka_maciza)` | el caso base |

Tres muñecas huecas producen tres usos del caso recursivo, y la maciza, uno del
caso base, que es el que termina la recursión:

```prolog
?- desarma(babushka_hueca(babushka_hueca(babushka_hueca(babushka_maciza)))).
true.
```

El árbol de derivación es la tabla anterior escrita en nodos, con las
sustituciones agregadas. Con el caso base numerado R1 y el recursivo R2, es una
sola rama: R1 no unifica con ninguna babushka hueca, y R2 no unifica con la
maciza, de modo que en cada nodo hay una única cláusula aplicable.

```mermaid
flowchart TD
    A["desarma(babushka_hueca(babushka_hueca(babushka_hueca(babushka_maciza))))"] -- "R2. θ₁ = {&nbsp;Interior/babushka_hueca(babushka_hueca(babushka_maciza))&nbsp;}" --> B["desarma(babushka_hueca(babushka_hueca(babushka_maciza)))"]
    B -- "R2. θ₂ = {&nbsp;Interior₂/babushka_hueca(babushka_maciza)&nbsp;}" --> C["desarma(babushka_hueca(babushka_maciza))"]
    C -- "R2. θ₃ = {&nbsp;Interior₃/babushka_maciza&nbsp;}" --> D["desarma(babushka_maciza)"]
    D -- "R1. θ₄ = {&nbsp;}" --> S(["consulta vacía"])
```

Los tres arcos de R2 llevan variables distintas: `Interior`, `Interior₂` e
`Interior₃`. Es lo que la [sección 5.2](../capitulo-05-como-responde-prolog/index.md#52-el-arbol-de-derivacion)
anticipó: cada vez que Prolog emplea una cláusula toma una **copia con
variables nuevas**, y la `Interior` del primer uso no es la del segundo. El
árbol distingue las copias con un subíndice. `trace` las muestra con
identificadores como `_8106` ([sección 5.3](../capitulo-05-como-responde-prolog/index.md#53-el-mismo-recorrido-registrado-por-trace)):
cada uso de una cláusula crea los suyos, y por eso esos números cambian de una
llamada a la siguiente. En este árbol cada copia queda ligada en el mismo arco
que la crea, y la traza ya la muestra con su valor; en los árboles de las
secciones siguientes, con variables libres en la consulta, las copias quedan a
la vista.

Si falta el caso base, la recursión no tiene condición de finalización. Si el
caso recursivo no reduce el problema, tampoco. En ambos casos la
consecuencia es que el programa no termina.

Extraída de `antepasado/2`, la forma queda así:

!!! abstract "Plantilla 8 — Caso base y caso recursivo"
    **Cuándo**: se debe repetir una operación una cantidad de veces que no se
    conoce de antemano.

    ```prolog
    p(CasoMinimo) :-
        solucion_directa.
    p(CasoGeneral) :-
        un_paso(CasoGeneral, CasoMenor),
        p(CasoMenor).
    ```

    En `antepasado/2`, `solucion_directa` es `progenitor(A, D)` y `un_paso` es
    `progenitor(A, Hijo)`, el objetivo que desciende una generación.

    El caso base se escribe primero. Mejora la legibilidad, obliga a verificar
    que existe, y además evita un problema concreto: con el caso base escrito
    último, el predicado puede responder bien la primera vez y no terminar al
    solicitar las respuestas siguientes, o al usarlo para generar. En el caso
    recursivo, el objetivo que reduce el problema se escribe **antes** de la
    llamada recursiva; de lo contrario, el programa no termina ([capítulo 5](../capitulo-05-como-responde-prolog/index.md),
    [sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas)).

    **En este capítulo se usa en**: `antepasado/2` (6.1), `desarma/1` (6.2), `natural/1` y `suma/3`
    (6.3 y 6.4), `generaciones/3` (6.6). Las demás plantillas están en
    [esta página](../plantillas.md).

!!! question "Actividad"
    Sobre `antepasados.pl`, ejecutar `antepasado(tare, Quien).` y solicitar
    todas las respuestas. Aparecen primero los hijos y después los nietos.
    Determinar, antes de ejecutarla, qué orden se obtendría si las dos cláusulas
    estuvieran escritas al revés, y verificarlo.

## 6.3 Los números naturales, definidos con términos

En `antepasado/2` la estructura que se recorre ya existía: el árbol genealógico
lo daban los hechos. Esta sección hace algo distinto y más ambicioso: **define
una estructura propia**, los números naturales, usando solo términos y sin
recurrir a los números predefinidos de Prolog. Sirve además para estudiar la
recursión de manera aislada, sin ningún otro mecanismo alrededor.

Son suficientes dos afirmaciones: cero es un número natural; y si N es un número
natural, su sucesor también lo es.

<!-- ejemplo: capitulo-06/naturales.pl predicado: natural/1 consulta: natural(s(s(cero))). -->
```prolog
%!  natural(+N) is semidet.
%!  natural(-N) is multi.
%
%   N es un número natural.
natural(cero).
natural(s(N)) :-
    natural(N).
```

`s(N)` se lee "el sucesor de N", y es un término compuesto como los del
[capítulo 4](../capitulo-04-terminos-y-unificacion/index.md): nombre `s`, un argumento. De este modo, `s(cero)` representa el uno, `s(s(cero))`
el dos y `s(s(s(cero)))` el tres. `cero` es un átomo, elegido a propósito en lugar
del número `0`: así queda a la vista que ninguno de estos términos es un número
para Prolog —no se pueden operar con `is`—, aunque es posible definir relaciones
sobre ellos, que es el propósito de esta sección.

La definición corresponde exactamente a la plantilla: el caso base es `cero`, que
no realiza ninguna llamada; el caso recursivo elimina un nivel de `s` y consulta
por el argumento, que es un término menor.

El predicado opera en dos modos. Con un argumento instanciado, verifica:

```prolog
?- natural(s(s(cero))).
true.
```

Con `natural(cero).` numerada R1 y la cláusula recursiva R2, el árbol es una
rama que se acorta en cada arco, como el de `desarma/1`:

```mermaid
flowchart TD
    A["natural(s(s(cero)))"] -- "R2. θ₁ = {&nbsp;N/s(cero)&nbsp;}" --> B["natural(s(cero))"]
    B -- "R2. θ₂ = {&nbsp;N₂/cero&nbsp;}" --> C["natural(cero)"]
    C -- "R1. θ₃ = {&nbsp;}" --> S(["consulta vacía"])
```

Con una variable libre, **genera** los naturales, uno tras otro, de manera
indefinida:

```prolog
?- natural(N).
N = cero ;
N = s(cero) ;
N = s(s(cero)) ;
N = s(s(s(cero))) ;
...
```

Esta consulta no termina, y ese comportamiento es correcto: el conjunto de los
naturales es infinito. Es el primer ejemplo del curso de una rama infinita que
no constituye un error. El árbol muestra la diferencia con la [sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas).
La consulta usa la variable `N`, el mismo nombre que la cláusula R2; como la
copia de la cláusula tiene variables nuevas, el árbol la escribe `N₁` para que
no se confundan:

```mermaid
flowchart TD
    A["natural(N)"] -- "R1. θ₁ = {&nbsp;N/cero&nbsp;}" --> S1(["1.ª respuesta<br/>N = cero"])
    A -- "R2. θ₂ = {&nbsp;N/s(N₁)&nbsp;}" --> B["natural(N₁)"]
    B -- "R1. θ₃ = {&nbsp;N₁/cero&nbsp;}" --> S2(["2.ª respuesta<br/>N = s(cero)"])
    B -- "R2. θ₄ = {&nbsp;N₁/s(N₂)&nbsp;}" --> C["natural(N₂)"]
    C -- "R1. θ₅ = {&nbsp;N₂/cero&nbsp;}" --> S3(["3.ª respuesta<br/>N = s(s(cero))"])
    C -- "R2. θ₆ = {&nbsp;N₂/s(N₃)&nbsp;}" --> D["⋮<br/>la rama no termina"]
    classDef abierto fill:none,stroke:none;
    class D abierto;
```

En la [sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas) la rama infinita estaba a la **izquierda**, y Prolog
no llegaba nunca a las ramas que producían las respuestas. Aquí está a la
**derecha**: en cada nivel, la rama de R1 cierra con una hoja de éxito antes de
que el recorrido descienda por la de R2, y por eso las respuestas aparecen una
por una, en el orden de las hojas. La rama infinita no es un error porque no
bloquea ninguna respuesta; solo impide que la enumeración termine.

El encabezado de `natural/1` registra los dos modos con la notación de la
[sección 2.8](../capitulo-02-hechos-consultas-y-variables/index.md#28-como-se-documenta-el-uso-de-un-predicado), una línea `%!` para cada uno: `natural(+N) is semidet` verifica, y
`natural(-N) is multi` genera.

## 6.4 La suma

Sobre los naturales así definidos se puede definir la suma. El método es el
mismo: se establece el resultado para la instancia más simple, y se indica cómo
reducir las demás instancias a ella.

Caso base: la suma de cero y B es B. Caso recursivo: la suma del sucesor de A y
B es el sucesor de la suma de A y B.

<!-- ejemplo: capitulo-06/naturales.pl predicado: suma/3 consulta: suma(s(cero), s(s(cero)), Cuanto). -->
```prolog
%!  suma(?A, ?B, ?C) is nondet.
%
%   C es A más B.
suma(cero, B, B).
suma(s(A), B, s(C)) :-
    suma(A, B, C).
```

```prolog
?- suma(s(cero), s(s(cero)), Cuanto).
Cuanto = s(s(s(cero))).
```

Uno más dos es tres. En cada llamada se elimina un nivel de `s` del primer
argumento y se agrega uno al resultado, hasta que el primer argumento es `cero`.

El árbol muestra dónde se arma el resultado. Con el caso base de `suma/3`
numerado R1 y el recursivo R2, la primera sustitución liga `Cuanto` a `s(C)`,
un término con una variable adentro, y la última liga esa `C`. La hoja de éxito
muestra la **composición** de las dos: cómo la variable de la consulta queda
armada a partir de las sustituciones de la rama, que es lo que la
[sección 5.2](../capitulo-05-como-responde-prolog/index.md#52-el-arbol-de-derivacion) dejó para más adelante.

```mermaid
flowchart TD
    A["suma(s(cero), s(s(cero)), Cuanto)"] -- "R2. θ₁ = {&nbsp;A/cero, B/s(s(cero)), Cuanto/s(C)&nbsp;}" --> B["suma(cero, s(s(cero)), C)"]
    B -- "R1. θ₂ = {&nbsp;B₂/s(s(cero)), C/s(s(cero))&nbsp;}" --> S(["consulta vacía<br/>Cuanto = s(C) = s(s(s(cero)))"])
```

La consulta siguiente muestra la propiedad más importante del capítulo:

```prolog
?- suma(A, s(s(cero)), s(s(s(cero)))).
A = s(cero) ;
false.
```

La consulta pregunta **qué número sumado a dos da tres**, y la respuesta es uno.
La misma definición que suma, consultada en otro sentido, resta. No existe una
regla para sumar y otra para restar: existe una relación entre tres números, y
la consulta determina cuáles son los datos y cuál es la incógnita.

En el árbol, la consulta usa la variable `A`, igual que la cláusula R2. Son
variables distintas: la de la consulta es `A`, y la copia de la cláusula se
escribe `A₁`, como `N₁` en la [sección 6.3](#63-los-numeros-naturales-definidos-con-terminos). La rama
de R2 quita una `s` del primer y del tercer argumento a la vez; termina porque
el **tercero** llega a `cero`, donde ninguna de las dos cabezas unifica.

```mermaid
flowchart TD
    A["suma(A, s(s(cero)), s(s(s(cero))))"] -- "R2. θ₁ = {&nbsp;A/s(A₁),<br/>B₁/s(s(cero)),<br/>C₁/s(s(cero))&nbsp;}" --> B["suma(A₁, s(s(cero)), s(s(cero)))"]
    B -- "R1. θ₂ = {&nbsp;A₁/cero, B₂/s(s(cero))&nbsp;}" --> S(["consulta vacía<br/>A = s(A₁) = s(cero)"])
    B -- "R2. θ₃ = {&nbsp;A₁/s(A₂), B₂/s(s(cero)), C₂/s(cero)&nbsp;}" --> C["suma(A₂, s(s(cero)), s(cero))"]
    C -- "R2. θ₄ = {&nbsp;A₂/s(A₃), B₃/s(s(cero)), C₃/cero&nbsp;}" --> D["suma(A₃, s(s(cero)), cero)"]
    D --> F(["falla"])
```

En la raíz y en el nodo `suma(A₂, s(s(cero)), s(cero))`, R1 no abre arco:
su cabeza `suma(cero, B, B)` exige que el segundo y el tercer argumento sean
iguales, y no lo son. El `;` de la respuesta es la rama de R2 que queda
pendiente debajo de la hoja de éxito, y el `false.` es su final.

`is` no tiene esta propiedad, y por eso conviene observarla antes del
[capítulo 8](../capitulo-08-aritmetica/index.md): `X is 1 + 2` evalúa en un único sentido, mientras que `suma/3` define una
relación.

## 6.5 Por qué termina

La pregunta de la [sección 6.1](#61-una-regla-que-se-invoca-a-si-misma) —**¿qué se reduce en cada llamada?**, y **¿en qué punto se detiene?**— se responde ahora sobre los dos predicados construidos con términos, donde aparece un matiz que en `antepasado/2` no se notaba.

En `suma/3` la respuesta es directa. Cada llamada elimina un nivel de `s` del
primer argumento, y el caso base espera `cero`. Como el primer argumento tiene una
cantidad finita de niveles, después de eliminarlos todos se alcanza `cero`, y la
recursión termina. Con `s(s(cero))` como primer argumento se realizan exactamente
dos llamadas recursivas.

En `natural/1` el análisis es distinto. En la consulta `natural(s(s(cero)))`, el
argumento se reduce en cada llamada, y la recursión termina. En la consulta
`natural(N)`, con `N` libre, **ninguna magnitud se reduce**: Prolog construye
términos cada vez mayores. Por eso el predicado verifica en un caso y genera de
manera indefinida en el otro. El mismo predicado, con dos comportamientos,
según qué argumentos estén instanciados. Los dos árboles de la
[sección 6.3](#63-los-numeros-naturales-definidos-con-terminos) lo muestran: el primero es una rama que
se acorta y termina; el segundo, una rama que crece sin fin con una hoja de
éxito en cada nivel.

De aquí se desprende un principio general: la terminación de un predicado puede
depender de **cómo se lo invoca**, y no solo de cómo está escrito.

## 6.6 Recursión que produce un resultado

Las recursiones anteriores solo verifican una relación. Una recursión también
puede construir un resultado, siempre con el mismo esquema: el caso base
establece el resultado de la instancia más simple, y el caso recursivo toma el
resultado de la llamada recursiva y le agrega su contribución.

El ejemplo usa otra familia, más simple que las de las secciones anteriores. En
`generaciones.pl` cada persona tiene un solo hijo: `juan` es padre de `ana`,
`ana` de `luis` y `luis` de `eva`. Los hechos forman así una **cadena**, sin
hermanos ni ramas, de modo que entre dos personas cualesquiera hay un único
camino, y la cantidad de generaciones que las separa está bien definida.

<!-- ejemplo: capitulo-06/generaciones.pl predicado: generaciones/3 consulta: generaciones(juan, eva, Cuantas). -->
```prolog
%!  generaciones(?A, ?D, -N) is nondet.
%
%   D está N generaciones por debajo de A.
% Caso base: una generación, cuando A es el padre de D.
generaciones(A, D, 1) :-
    padre(A, D).
% Caso recursivo: una generación, más las que resten desde el hijo.
generaciones(A, D, N) :-
    padre(A, Hijo),
    generaciones(Hijo, D, Faltan),
    N is Faltan + 1.
```

```prolog
?- generaciones(juan, eva, Cuantas).
Cuantas = 3 ;
false.
```

El orden de los objetivos del caso recursivo es el de la mayoría de las
recursiones que producen un resultado:

1. `padre(A, Hijo)` avanza un paso y reduce el problema;
2. `generaciones(Hijo, D, Faltan)` resuelve el problema reducido y produce un
   número;
3. `N is Faltan + 1` agrega la contribución de esta generación.

El tercer objetivo se escribe después de la llamada recursiva: `Faltan` no tiene valor hasta que la llamada termina. Si `is` se
escribiera antes, se produciría el error de argumentos sin instanciar del
[capítulo 1](../capitulo-01-la-primera-hora/index.md).

El árbol de derivación muestra esa espera. Con los hechos y las cláusulas
numerados en el orden del programa:

| | |
|---|---|
| R1 | `padre(juan, ana).` |
| R2 | `padre(ana, luis).` |
| R3 | `padre(luis, eva).` |
| R4 | `generaciones(A, D, 1) :- padre(A, D).` |
| R5 | `generaciones(A, D, N) :- padre(A, Hijo), generaciones(Hijo, D, Faltan), N is Faltan + 1.` |

Cada uso de R5 deja un `… is … + 1` pendiente **a la derecha** de la consulta,
con su variable todavía libre. El árbol es alto, y se parte en dos: el primero
baja hasta la llamada sobre `luis`, y el segundo continúa desde ese nodo.

```mermaid
%%{init: {"flowchart": {"rankSpacing": 30}}}%%
flowchart TD
    A["generaciones(juan, eva, Cuantas)"] -- "R4. θ₁ = {&nbsp;A/juan, D/eva, Cuantas/1&nbsp;}" --> B["padre(juan, eva)"]
    B --> F1(["falla"])
    A -- "R5. θ₂ = {&nbsp;A/juan, D/eva, N/Cuantas&nbsp;}" --> C["padre(juan, Hijo),<br/>generaciones(Hijo, eva, Faltan),<br/>Cuantas is Faltan + 1"]
    C -- "R1. θ₃ = {&nbsp;Hijo/ana&nbsp;}" --> D["generaciones(ana, eva, Faltan),<br/>Cuantas is Faltan + 1"]
    D -- "R4. θ₄ = {&nbsp;A₂/ana, D₂/eva, Faltan/1&nbsp;}" --> E["padre(ana, eva),<br/>Cuantas is 1 + 1"]
    E --> F2(["falla"])
    D -- "R5. θ₅ = {&nbsp;A₂/ana, D₂/eva, N₂/Faltan&nbsp;}" --> F["padre(ana, Hijo₂),<br/>generaciones(Hijo₂, eva, Faltan₂),<br/>Faltan is Faltan₂ + 1,<br/>Cuantas is Faltan + 1"]
    F -- "R2. θ₆ = {&nbsp;Hijo₂/luis&nbsp;}" --> G["generaciones(luis, eva, Faltan₂),<br/>Faltan is Faltan₂ + 1,<br/>Cuantas is Faltan + 1"]
    G --> V["⋮<br/>sigue en el árbol siguiente"]
    classDef abierto fill:none,stroke:none;
    class V abierto;
```

En el segundo árbol aparecen los arcos de `is`. Es un **objetivo predefinido**,
como el `\==` de la [sección 3.5](../capitulo-03-reglas-y-conjunciones/index.md#35-una-regla-que-produce-respuestas-de-mas):
no emplea ninguna cláusula, y su arco no lleva número. Cuando evalúa la
expresión y liga la variable de la izquierda, el arco lleva la sustitución con
el valor que produce; cuando la variable de la izquierda ya tiene valor, `is`
actúa como una prueba, y si la igualdad no se cumple la rama falla.

```mermaid
%%{init: {"flowchart": {"rankSpacing": 30}}}%%
flowchart TD
    G["generaciones(luis, eva, Faltan₂),<br/>Faltan is Faltan₂ + 1,<br/>Cuantas is Faltan + 1"]
    G -- "R4. θ₇ = {&nbsp;A₃/luis, D₃/eva, Faltan₂/1&nbsp;}" --> H["padre(luis, eva),<br/>Faltan is 1 + 1,<br/>Cuantas is Faltan + 1"]
    H -- "R3. θ₈ = {&nbsp;}" --> I["Faltan is 1 + 1,<br/>Cuantas is Faltan + 1"]
    I -- "is. θ₉ = {&nbsp;Faltan/2&nbsp;}" --> J["Cuantas is 2 + 1"]
    J -- "is. θ₁₀ = {&nbsp;Cuantas/3&nbsp;}" --> S(["consulta vacía<br/>Cuantas = 3"])
    G -- "R5. θ₁₁ = {&nbsp;A₃/luis, D₃/eva, N₃/Faltan₂&nbsp;}" --> K["padre(luis, Hijo₃),<br/>generaciones(Hijo₃, eva, Faltan₃),<br/>Faltan₂ is Faltan₃ + 1,<br/>Faltan is Faltan₂ + 1,<br/>Cuantas is Faltan + 1"]
    K -- "R3. θ₁₂ = {&nbsp;Hijo₃/eva&nbsp;}" --> L["generaciones(eva, eva, Faltan₃),<br/>Faltan₂ is Faltan₃ + 1,<br/>Faltan is Faltan₂ + 1,<br/>Cuantas is Faltan + 1"]
    L -- "R4. θ₁₃ = {&nbsp;A₄/eva, D₄/eva, Faltan₃/1&nbsp;}" --> M["padre(eva, eva),<br/>Faltan₂ is 1 + 1,<br/>Faltan is Faltan₂ + 1,<br/>Cuantas is Faltan + 1"]
    M --> F3(["falla"])
    L -- "R5. θ₁₄ = {&nbsp;A₄/eva, D₄/eva, N₄/Faltan₃&nbsp;}" --> N["padre(eva, Hijo₄),<br/>generaciones(Hijo₄, eva, Faltan₄),<br/>Faltan₃ is Faltan₄ + 1,<br/>Faltan₂ is Faltan₃ + 1,<br/>Faltan is Faltan₂ + 1,<br/>Cuantas is Faltan + 1"]
    N --> F4(["falla"])
```

Los dos `is` se resuelven **de abajo hacia arriba**, recién cuando el caso
base cierra en `padre(luis, eva)`: `θ₇` liga `Faltan₂` a 1, `θ₉` calcula
`Faltan` y `θ₁₀` calcula `Cuantas`. Hasta ese momento, `Faltan` no tenía
valor, y un `is` que lo hubiera necesitado antes habría producido el error
de argumentos sin instanciar. El `false.` final es la rama de R5 que queda
pendiente debajo de `generaciones(luis, eva, Faltan₂)`: desciende hasta `eva`,
que no tiene hijos, y falla con sus `is` todavía sin evaluar.

Como en los casos anteriores, la relación se puede consultar en el otro sentido:

```prolog
?- generaciones(juan, Quien, 2).
Quien = luis ;
false.
```

## 6.7 Las cuatro causas de no terminación

La mayoría de las recursiones que no terminan corresponden a uno de los cuatro
casos siguientes.

**Falta el caso base.** Solo existe la cláusula recursiva, de modo que no hay
condición de finalización.

**El caso recursivo no reduce el problema.** Se invoca a sí mismo con los mismos
argumentos que recibió, o con argumentos del mismo tamaño. Es el error del
[capítulo 5](../capitulo-05-como-responde-prolog/index.md): la regla que comenzaba por `antepasado(A, X)` antes de avanzar por algún paso reductor.

**El objetivo que reduce el problema está después de la llamada recursiva.** Es
el caso más difícil de detectar, porque el programa *parece* correcto: tiene su
caso base y tiene su objetivo de reducción. Sin embargo, Prolog ejecuta los
objetivos de izquierda a derecha, y alcanza la llamada recursiva antes de haber
reducido el problema. Con frecuencia el programa produce la primera respuesta y
no termina al solicitar la siguiente, como en la actividad del final de la
sección.

```prolog
%!  generaciones(?A, ?D, -N) is nondet.
%
%   D está N generaciones por debajo de A. Produce la primera respuesta y
%   después no termina: la llamada recursiva precede al objetivo que reduce
%   el problema.
generaciones(A, D, N) :-
    generaciones(Hijo, D, Faltan),
    padre(A, Hijo),
    N is Faltan + 1.
```

**Dos predicados que se llaman mutuamente.** Ninguno de los dos es recursivo por
sí solo, y sin embargo el ciclo existe. También difícil de detectar,
porque cada predicado examinado por separado parece correcto:

```prolog
% No termina: cada uno se define en términos del otro, y ninguno avanza.

%!  hijo(?H, ?P) is nondet.
%
%   H es hijo de P.
hijo(H, P) :-
    progenitor(P, H).

%!  progenitor(?P, ?H) is nondet.
%
%   P es el padre o la madre de H.
progenitor(P, H) :-
    hijo(H, P).
```

Cada cláusula es una afirmación verdadera, y aun así el par no sirve como
programa: para probar `hijo/2` hay que probar `progenitor/2`, y para probar
`progenitor/2` hay que probar `hijo/2`. La situación se repite sin que ningún
objetivo se acerque a un hecho. Basta con que uno de los dos predicados esté
definido por hechos para que el problema desaparezca.

El árbol de `hijo(H, P)` lo muestra con el criterio de la [sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas):
con la cláusula de `hijo/2` numerada R1 y la de `progenitor/2` R2, el tercer
nodo repite la raíz, salvo los nombres de las variables, sin que en el camino
se haya avanzado nada.

```mermaid
flowchart TD
    A["hijo(H, P)"] -- "R1. θ₁ = {&nbsp;H₁/H, P₁/P&nbsp;}" --> B["progenitor(P, H)"]
    B -- "R2. θ₂ = {&nbsp;P₂/P, H₂/H&nbsp;}" --> C["hijo(H, P)"]
    C -- "R1. θ₃ = {&nbsp;H₃/H, P₃/P&nbsp;}" --> D["⋮<br/>la rama no termina"]
    classDef abierto fill:none,stroke:none;
    class D abierto;
```

Ante un programa que no termina, se recomienda verificar en ese orden: primero,
si existe el caso base; después, si el caso recursivo reduce el problema;
después, si el objetivo de reducción está antes de la llamada recursiva; por
último, si el predicado forma un ciclo con algún otro.

!!! question "Actividad"
    En `generaciones.pl`, intercambiar los dos primeros objetivos del caso
    recursivo, como en el bloque anterior, y ejecutar
    `generaciones(juan, eva, N).` La consulta responde `N = 3`; al solicitar
    otra respuesta con `;`, la ejecución no termina y se debe interrumpir de
    manera manual. Explicar, con el criterio de la [sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas),
    por qué la primera respuesta se encuentra y la búsqueda de la segunda no
    termina.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. **(1)** Escribir `dos/1`, `tres/1` y `cuatro/1` como hechos, con la notación
   `s(...)`. ¿Cuántas `s` tiene cada uno?
2. ★ **(1)** ¿Qué responde `natural(s(s(s(cero)))).`? ¿Y `natural(s(perro)).`?
   Explicar la segunda respuesta.
3. ★ **(2)** Escribir `mayor/2` para los naturales de `naturales.pl`, con el
   encabezado `%! mayor(?A, ?B) is nondet.` (A es mayor que B), sin usar
   `menor/2`.
4. **(2)** Escribir `doble_natural/2`, con el encabezado
   `%! doble_natural(?N, ?D) is nondet.`: D es la suma de N consigo mismo. Se
   puede usar `suma/3`.
5. **(2)** Escribir `desde(V, N)`: N es el natural en notación `s` que
   corresponde al entero predefinido V. Es la relación inversa de `valor/2`.
   Escribir también su encabezado: qué argumentos deben llegar ligados y
   cuántas respuestas produce.
6. ★ **(2)** Con `generaciones.pl`, ¿qué responde `generaciones(A, eva, 2).`?
   Seguir el árbol de derivación.
7. **(2)** Escribir `tatarabuelo/2`, con el encabezado
   `%! tatarabuelo(?A, ?D) is nondet.`, a partir de `generaciones/3`.
8. **(3)** Escribir `cuantos_hijos(P, N)`: N es la cantidad de hijos de P. El
   ejercicio presenta una dificultad; explicar cuál es. (Sugerencia: los hijos
   no forman una cadena.)
9. **(3)** Escribir `par/1`, con el encabezado `%! par(?N) is nondet.`, para
   los naturales de `naturales.pl`: se cumple cuando N tiene una cantidad par
   de `s`. Según el planteo, requiere uno o dos casos base.
10. ★ **(2)** Los tres predicados siguientes presentan cada uno una causa
    distinta de la [sección 6.7](#67-las-cuatro-causas-de-no-terminacion). Dos de ellos no terminan con cualquier
    consulta; el otro responde `false.` cuando el primer argumento está
    instanciado y no termina cuando está libre. Identificar la causa en cada
    caso y corregirlo:

    ```prolog
    % a
    %!  cuenta_s(?N, ?C) is nondet.
    %
    %   C tiene tantas s como N.
    cuenta_s(s(N), C) :-
        cuenta_s(N, Menos),
        C = s(Menos).

    % b
    %!  antes_de(?A, ?B) is nondet.
    %
    %   A está antes que B.
    antes_de(A, B) :-
        despues_de(B, A).

    %!  despues_de(?B, ?A) is nondet.
    %
    %   B está después que A.
    despues_de(B, A) :-
        antes_de(A, B).

    % c
    %!  baja(?N, ?Cero) is nondet.
    %
    %   Cero es el cero al que se llega quitando todas las s de N.
    baja(N, Cero) :-
        baja(s(N), Cero).
    baja(cero, cero).
    ```

11. ★ **(2)** Sobre `suma/3` de la [sección 6.4](#64-la-suma), en tres partes:

    a. Ejecutar `suma(s(cero), s(s(cero)), R).` y explicar qué hace cada cláusula.
    b. Ejecutar `suma(s(cero), B, s(s(s(cero)))).` El mismo predicado ahora resta.
       Explicar por qué, con el árbol de derivación.
    c. Ejecutar `suma(A, B, s(s(cero))).` y solicitar todas las respuestas.
       ¿Cuántas hay, y por qué termina?
12. ★ **(2)** `valor/2` traduce un natural en notación `s` a un entero
    predefinido. Determinar, sin ejecutarlas, cuáles de estas consultas
    funcionan y cuáles no, y por qué: `valor(s(s(cero)), V).` ·
    `valor(N, 2).` · `valor(s(N), 3).`
13. **(2)** Escribir `menor_o_igual/2`, con el encabezado
    `%! menor_o_igual(?A, ?B) is nondet.`, sobre los naturales de
    `naturales.pl`, sin usar `menor/2`. Después ejecutar
    `menor_o_igual(A, s(cero)).` y `menor_o_igual(s(cero), B).` La segunda produce una
    sola respuesta, y esa respuesta **contiene una variable**: explicar qué
    afirma, y por qué es correcta.
14. **(3)** A partir de `par/1` del ejercicio 9, escribir `impar/1`, con el
    encabezado `%! impar(?N) is nondet.`, y después `paridad/2`, con el
    encabezado `%! paridad(?N, ?P) is nondet.`, que se cumple con `P = par`
    o con `P = impar` según corresponda. ¿Cuántas cláusulas requiere `paridad/2`? ¿Qué responde
    `paridad(s(cero), par).`, y qué trabajo hace Prolog antes de responderlo?

## Resumen

| | |
|---|---|
| **caso base** | la instancia más simple, que se resuelve sin una nueva invocación |
| **caso recursivo** | reduce el problema y se invoca a sí mismo |
| `s(N)` | "el sucesor de N"; un término, no un número |
| terminación | una magnitud debe reducirse en cada llamada, y el caso base debe ser alcanzable |
| generar y verificar | el mismo predicado realiza ambas operaciones, según qué argumentos estén instanciados |
| orden dentro del cuerpo | el objetivo que reduce el problema precede a la llamada recursiva |
| **variables nuevas** | cada uso de una cláusula toma una copia con variables nuevas: en el árbol llevan subíndice (`Interior₂`, `A₁`), en `trace` son los identificadores como `_8106` |
| **arco de `is`** | objetivo predefinido: sin número de cláusula; con la sustitución del valor que produce, o «falla» si la variable ya tenía valor y la igualdad no se cumple |
| **composición en la hoja** | la hoja de éxito muestra cómo la variable de la consulta se arma con las sustituciones de la rama (`Cuanto = s(C) = s(s(s(cero)))`) |
| **subárbol resumido** | un nodo «⋯ todas sus ramas fallan» en lugar de un subárbol que el recorrido agotó sin hojas de éxito; indica qué sustituciones consumió |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Recursión sobre listas, el mismo esquema con `[Primero\|Resto]` | [capítulo 7](../capitulo-07-listas/index.md) |
| `is`, y por qué es menos general que la relación `suma/3` | [capítulo 8](../capitulo-08-aritmetica/index.md) |
| Acumuladores, otra forma de escribir una recursión que produce un resultado | [capítulo 8](../capitulo-08-aritmetica/index.md) |
| Recursión con poda mediante el corte | [capítulo 9](../capitulo-09-backtracking-y-corte/index.md) |
| Recursión sobre estructuras que no son cadenas, como los árboles | [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) |
