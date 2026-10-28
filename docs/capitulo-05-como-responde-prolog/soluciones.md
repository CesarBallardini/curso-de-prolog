# Soluciones del capítulo 5 — Cómo responde Prolog

El código de esta página está en `ejemplos/capitulo-05/soluciones.pl`, salvo el
del ejercicio 16, que está en `hermana_politica.pl`, y pasa sus pruebas.

## 1

Con las cláusulas numeradas como en 5.2:

```mermaid
flowchart TD
    A["abuelo(Quien, luis)"] -- "R4. θ₁ = {&nbsp;A/Quien,<br/>N/luis&nbsp;}" --> B["padre(Quien, P),<br/>padre(P, luis)"]
    B -- "R1. θ₂ = {&nbsp;Quien/juan,<br/>P/ana&nbsp;}" --> C["padre(ana, luis)"]
    B -- "R2. θ₃ = {&nbsp;Quien/juan,<br/>P/pedro&nbsp;}" --> D["padre(pedro, luis)"]
    B -- "R3. θ₅ = {&nbsp;Quien/pedro,<br/>P/luis&nbsp;}" --> E["padre(luis, luis)"]
    C --> F(["falla"])
    D -- "R3. θ₄ = {&nbsp;}" --> G(["consulta vacía<br/>Quien = juan"])
    E --> H(["falla"])
```

**Tres hojas, de las cuales una sola es de éxito.**

Hay más ramas que en el árbol del capítulo porque el primer objetivo es ahora
`padre(Quien, P)`, con **las dos variables libres**: unifica con los tres hechos. En
`abuelo(juan, Quien)` el primer objetivo era `padre(juan, P)`, con `juan` ya
instanciado, y unificaba solo con dos.

## 2

Una sola respuesta, `Quien = luis`.

Con las cláusulas numeradas como en 5.4 —R1 a R3 para los hechos de `padre/2`,
R4 para el caso base de `antepasado/2` y R5 para el recursivo—:

```mermaid
flowchart TD
    A["antepasado(pedro, Quien)"] -- "R4. θ₁ = {&nbsp;A/pedro,<br/>D/Quien&nbsp;}" --> B["padre(pedro, Quien)"]
    A -- "R5. θ₃ = {&nbsp;A/pedro,<br/>D/Quien&nbsp;}" --> C["padre(pedro, Hijo),<br/>antepasado(Hijo, Quien)"]
    B -- "R3. θ₂ = {&nbsp;Quien/luis&nbsp;}" --> D(["consulta vacía<br/>Quien = luis"])
    C -- "R3. θ₄ = {&nbsp;Hijo/luis&nbsp;}" --> E["antepasado(luis, Quien)"]
    E -- "R4. θ₅ = {&nbsp;A₂/luis,<br/>D₂/Quien&nbsp;}" --> E1["padre(luis, Quien)"]
    E -- "R5. θ₆ = {&nbsp;A₂/luis,<br/>D₂/Quien&nbsp;}" --> E2["padre(luis, Hijo₂),<br/>antepasado(Hijo₂, Quien)"]
    E1 --> F1(["falla"])
    E2 --> F2(["falla"])
```

La segunda cláusula genera una rama que desciende una generación hasta `luis`,
donde la familia termina: `luis` no es padre de nadie, y las dos cláusulas de
`antepasado(luis, Quien)` fallan.

## 3

```text
Fail: (11) padre(ana, _8106)
```

Ese `Fail` es el momento en que se abandona la rama de `ana`. La línea
siguiente, `Redo: (11) padre(juan, _8960)`, corresponde ya al paso posterior:
Prolog retrocede al objetivo anterior para intentar la alternativa pendiente.

Son dos eventos distintos, y por eso ocupan dos líneas: el primero indica que la
rama falla; el segundo, que se retrocede para intentar otra alternativa.

## 4

La respuesta **no cambia**: es `Quien = luis`. El conjunto de respuestas no
depende del orden de los hechos; solo depende de él el orden en que aparecen, y
en este caso hay una sola.

El árbol **sí cambia**. Con `padre(juan, pedro)` escrito primero, la rama de
`pedro` pasa a ser la de la izquierda, de modo que Prolog encuentra la respuesta
en el primer intento, antes de recorrer la rama de `ana`. La primera respuesta
es la misma, y se obtiene con la mitad del trabajo.

Con los hechos invertidos, R1 pasa a ser `padre(juan, pedro).` y R2
`padre(juan, ana).`:

```mermaid
flowchart TD
    A["abuelo(juan, Quien)"] -- "R4. θ₁ = {&nbsp;A/juan,<br/>N/Quien&nbsp;}" --> B["padre(juan, P),<br/>padre(P, Quien)"]
    B -- "R1. θ₂ = {&nbsp;P/pedro&nbsp;}" --> C["padre(pedro, Quien)"]
    B -- "R2. θ₄ = {&nbsp;P/ana&nbsp;}" --> D["padre(ana, Quien)"]
    C -- "R3. θ₃ = {&nbsp;Quien/luis&nbsp;}" --> E(["consulta vacía<br/>Quien = luis"])
    D --> F(["falla"])
```

Es el árbol de 5.2 con sus dos ramas intercambiadas: la hoja de éxito, que
antes estaba a la derecha, queda ahora a la izquierda.

## 5

<!-- ejemplo: capitulo-05/soluciones.pl predicado: nieto/2 nieto_al_reves/2 consulta: nieto_al_reves(Quien, juan). -->
```prolog
%!  nieto(?N, ?A) is nondet.
%
%   N es nieto de A, con el objetivo que menos ramas abre primero.
nieto(N, A) :-
    padre(A, P),
    padre(P, N).

%!  nieto_al_reves(?N, ?A) is nondet.
%
%   N es nieto de A: la misma regla, con los objetivos en orden inverso.
nieto_al_reves(N, A) :-
    padre(P, N),
    padre(A, P).
```

`nieto/2` genera menos ramas. En la consulta `nieto(Quien, juan)`, su primer
objetivo es `padre(juan, P)`, con `juan` instanciado: dos ramas. El primer
objetivo de `nieto_al_reves/2` es `padre(P, Quien)`, con las dos variables
libres: cuatro ramas, de las cuales tres fallan después.

Es la misma diferencia de la [sección 5.5](index.md#55-el-orden-de-los-objetivos-determina-el-trabajo), y la misma regla práctica: se escribe
primero el objetivo que llega con más argumentos instanciados.

## 6

Sí: se obtienen las mismas respuestas en distinto orden.

```prolog
?- antepasado(juan, Quien).
Quien = ana ;
Quien = pedro ;
Quien = luis ;
Quien = sofia ;
false.

?- primero_lejos(juan, Quien).
Quien = sofia ;
Quien = luis ;
Quien = ana ;
Quien = pedro.
```

Con una generación más, el comportamiento de cada predicado se aprecia mejor: el
primero entrega las respuestas a medida que desciende por el árbol; el segundo
desciende hasta la última generación y entrega las respuestas durante el
retroceso, comenzando por la bisnieta.

## 7

El problema está en la primera cláusula:

```prolog
hermano(A, B) :-
    hermano(B, A).
```

Con R1 a R3 para los hechos de `padre/2`, R4 para esa cláusula y R5 para la
segunda, el árbol de `?- hermano(luis, Quien).` es:

```mermaid
flowchart TD
    A["hermano(luis, Quien)"] -- "R4. θ₁ = {&nbsp;A/luis,<br/>B/Quien&nbsp;}" --> B["hermano(Quien, luis)"]
    B -- "R4. θ₂ = {&nbsp;A₂/Quien,<br/>B₂/luis&nbsp;}" --> C["hermano(luis, Quien)"]
    C -- "R4. θ₃ = {&nbsp;A₃/luis,<br/>B₃/Quien&nbsp;}" --> D["⋮<br/>la rama no termina"]
    A -- "R5" --- pA@{ shape: sm-circ } -.- nA["nunca llega<br/>a pasar por aquí"]
    B -- "R5" --- pB@{ shape: sm-circ } -.- nB["nunca llega<br/>a pasar por aquí"]
    C -- "R5" --- pC@{ shape: sm-circ } -.- nC["nunca llega<br/>a pasar por aquí"]
    classDef abierto fill:none,stroke:none;
    class D,nA,nB,nC abierto;
```

`hermano(luis, Quien)` se reemplaza por `hermano(Quien, luis)`, que se
reemplaza por `hermano(luis, Quien)`, y así indefinidamente: el tercer nodo
repite la raíz, salvo los nombres de las variables. Es la rama infinita de la
[sección 5.6](index.md#56-ramas-infinitas), y como R4 está escrita **en primer lugar**, impide alcanzar R5, que
es la que produce las respuestas.

La afirmación que esa cláusula pretendía expresar —si A es hermano de B,
entonces B es hermano de A— es cierta, pero no es necesario escribirla: la
segunda cláusula ya es simétrica, porque `padre(P, A), padre(P, B)` no distingue
el orden de A y B.

<!-- ejemplo: capitulo-05/soluciones.pl predicado: hermano/2 consulta: hermano(ana, Quien). -->
```prolog
%!  hermano(?A, ?B) is nondet.
%
%   A es hermano de B: sin la cláusula recursiva que no reducía el
%   problema.
hermano(A, B) :-
    padre(P, A),
    padre(P, B),
    A \== B.
```

Los dos argumentos son `?`: `padre(P, A)` y `padre(P, B)` los generan si llegan
libres, y los verifican si llegan ligados. Cuando se llega a `A \== B`, los dos
ya tienen valor. La cantidad de respuestas es `nondet`: una persona puede tener
varios hermanos, o ninguno, como `luis`. La versión original no admitía ningún
modo, porque ninguna consulta sobre ella terminaba.

## 8

Sí, y el capítulo ya contiene un ejemplo: `primero_lejos/2`, de la [sección 5.4](index.md#54-el-orden-de-las-clausulas-determina-el-orden-de-las-respuestas),
tiene el caso recursivo en primer lugar y termina correctamente.

La conclusión es que **la no terminación no se debe al orden de las cláusulas**,
sino al orden de los objetivos dentro de la cláusula recursiva.
`primero_lejos/2` escribe `padre(A, Hijo)` antes de la llamada recursiva, de modo
que cada llamada comienza una generación más abajo. La versión defectuosa de la
[sección 5.6](index.md#56-ramas-infinitas) realiza la llamada recursiva **antes** de avanzar ese paso, y por eso
el problema no se reduce nunca.

Escribir el caso base en primer lugar sigue siendo una buena práctica, pero por
otro motivo: mejora la legibilidad y permite detectar si el caso base falta.

## 9

a. La consulta es `?- abuelo(juan, luis).` Se deduce del primer arco: la
   sustitución `θ₁ = { A/juan, N/luis }` indica con qué se unificaron los dos
   argumentos de la cabeza de R4, y esos valores estaban en la consulta.
b. Una sola respuesta, y es `true`: el árbol tiene una única hoja de éxito, y la
   consulta no tiene variables, de modo que no hay nada que informar. Ejecutada,
   responde `true ;` y después `false.`, porque la rama de la izquierda dejó
   pendiente una alternativa que todavía no se descartó.
c. `θ₄` está vacía porque en ese punto el objetivo es
   `padre(pedro, luis)` y la cláusula es `padre(pedro, luis)`: los dos términos
   ya son idénticos, y no hace falta darle valor a ninguna variable para que
   unifiquen. Una sustitución vacía es un caso normal, y no significa que no
   haya habido unificación.

## 10

Con las cláusulas de `orden.pl` numeradas R1 a R3 para los hechos de `padre/2`,
R4 para el caso base de `antepasado/2` y R5 para el caso recursivo:

```mermaid
flowchart TD
    A["antepasado(juan, luis)"] -- "R4. θ₁ = {&nbsp;A/juan, D/luis&nbsp;}" --> B["padre(juan, luis)"]
    A -- "R5. θ₂ = {&nbsp;A/juan, D/luis&nbsp;}" --> C["padre(juan, Hijo),<br/>antepasado(Hijo, luis)"]
    B --> F0(["falla"])
    C -- "R1. θ₃ = {&nbsp;Hijo/ana&nbsp;}" --> E["antepasado(ana, luis)"]
    C -- "R2. θ₆ = {&nbsp;Hijo/pedro&nbsp;}" --> F["antepasado(pedro, luis)"]
    E -- "R4. θ₄ = {&nbsp;A₂/ana,<br/>D₂/luis&nbsp;}" --> E1["padre(ana, luis)"]
    E -- "R5. θ₅ = {&nbsp;A₂/ana,<br/>D₂/luis&nbsp;}" --> E2["padre(ana, Hijo₂),<br/>antepasado(Hijo₂, luis)"]
    E1 --> F1(["falla"])
    E2 --> F2(["falla"])
    F -- "R4. θ₇ = {&nbsp;A₃/pedro,<br/>D₃/luis&nbsp;}" --> G1["padre(pedro, luis)"]
    F -- "R5. θ₉ = {&nbsp;A₃/pedro,<br/>D₃/luis&nbsp;}" --> G2["padre(pedro, Hijo₃),<br/>antepasado(Hijo₃, luis)"]
    G1 -- "R3. θ₈ = {&nbsp;}" --> S(["consulta vacía"])
    G2 -- "R3. θ₁₀ = {&nbsp;Hijo₃/luis&nbsp;}" --> H["antepasado(luis, luis)"]
    H -- "R4. θ₁₁ = {&nbsp;A₄/luis,<br/>D₄/luis&nbsp;}" --> H1["padre(luis, luis)"]
    H -- "R5. θ₁₂ = {&nbsp;A₄/luis,<br/>D₄/luis&nbsp;}" --> H2["padre(luis, Hijo₄),<br/>antepasado(Hijo₄, luis)"]
    H1 --> F3(["falla"])
    H2 --> F4(["falla"])
```

Una hoja de éxito y cinco de falla. `padre(juan, luis)` falla porque `luis` no
es hijo directo de `juan`; las ramas de `ana` y de `luis` fallan porque ninguno
de los dos es padre de nadie.

```prolog
?- antepasado(juan, luis).
true ;
false.
```

El `false.` final corresponde a la rama que quedó abierta a la derecha de la
hoja de éxito: después de encontrar la respuesta por `pedro`, todavía resta
recorrer el subárbol de `antepasado(luis, luis)`, que falla.

## 11

`?- padre(juan, Quien).` tiene **dos** hojas de éxito y ninguna de falla: el
objetivo unifica con R1 y con R2, y cada una produce de inmediato la consulta
vacía.

`?- padre(Quien, juan).` tiene **cero** hojas de éxito. Ninguna de las tres
cláusulas tiene a `juan` en la segunda posición, de modo que el objetivo no
unifica con ninguna cabeza y la única rama posible falla.

La diferencia no está en la cantidad de variables sino en **qué posición** ocupa
el dato conocido: `juan` aparece como primer argumento en dos hechos y como
segundo en ninguno.

## 12

Con las cláusulas numeradas como en 5.2:

```mermaid
flowchart TD
    A["padre(juan, P),<br/>padre(P, luis)"] -- "R1. θ₁ = {&nbsp;P/ana&nbsp;}" --> B["padre(ana, luis)"]
    A -- "R2. θ₂ = {&nbsp;P/pedro&nbsp;}" --> C["padre(pedro, luis)"]
    B --> F(["falla"])
    C -- "R3. θ₃ = {&nbsp;}" --> S(["consulta vacía<br/>P = pedro"])
```

```mermaid
flowchart TD
    A["padre(P, luis),<br/>padre(juan, P)"] -- "R3. θ₁ = {&nbsp;P/pedro&nbsp;}" --> B["padre(juan, pedro)"]
    B -- "R2. θ₂ = {&nbsp;}" --> S(["consulta vacía<br/>P = pedro"])
```

El primer árbol tiene cinco nodos, contando las hojas, y el segundo tres.
`padre(juan, P)` unifica con dos cláusulas, de modo que abre dos ramas, y una de
ellas —la de `ana`— falla después. `padre(P, luis)` unifica con una sola, de
modo que abre una rama, y esa rama tiene éxito.

Conviene la segunda: hace menos trabajo para llegar a la misma respuesta.

Lo que el ejercicio quiere mostrar es que esa conveniencia **no se puede decidir
mirando la regla**. Depende de cuántos hechos unifican con cada objetivo, es
decir de los datos, y puede invertirse si el programa cambia: con una familia en
la que `luis` tuviera varios padres registrados y `juan` un solo hijo, la mejor
sería la primera. El [capítulo 17](../capitulo-17-rendimiento/index.md) retoma el tema.

## 13

Cuatro respuestas, en este orden: `ana`, `pedro`, `luis`, `eva`.

Se determina sin ejecutar nada, leyendo el árbol. La primera cláusula de
`antepasado/2` agota los hijos directos de `juan` antes de que la segunda
descienda una generación, de modo que `ana` y `pedro` aparecen primero, en el
orden en que están escritos los hechos. Después, la cláusula recursiva desciende
por `ana` —que no tiene hijos— y por `pedro`, cuyos hijos `luis` y `eva`
aparecen en el orden de los hechos.

El hecho agregado no altera el orden de los anteriores: se suma al final, porque
`padre(pedro, eva)` se escribe después de `padre(pedro, luis)`.

## 14

Con R1 a R3 para los hechos de `padre/2`, R4 para el caso base de
`descendiente/2` y R5 para el recursivo, el árbol de
`?- descendiente(luis, juan).` es:

```mermaid
flowchart TD
    A["descendiente(luis, juan)"] -- "R4. θ₁ = {&nbsp;D/luis, A/juan&nbsp;}" --> B["padre(juan, luis)"]
    A -- "R5. θ₂ = {&nbsp;D/luis, A/juan&nbsp;}" --> C["padre(juan, X),<br/>descendiente(luis, X)"]
    B --> F0(["falla"])
    C -- "R1. θ₃ = {&nbsp;X/ana&nbsp;}" --> E["descendiente(luis, ana)"]
    C -- "R2. θ₆ = {&nbsp;X/pedro&nbsp;}" --> F["descendiente(luis, pedro)"]
    E -- "R4. θ₄ = {&nbsp;D₂/luis,<br/>A₂/ana&nbsp;}" --> E1["padre(ana, luis)"]
    E -- "R5. θ₅ = {&nbsp;D₂/luis,<br/>A₂/ana&nbsp;}" --> E2["padre(ana, X₂),<br/>descendiente(luis, X₂)"]
    E1 --> F1(["falla"])
    E2 --> F2(["falla"])
    F -- "R4. θ₇ = {&nbsp;D₃/luis,<br/>A₃/pedro&nbsp;}" --> G1["padre(pedro, luis)"]
    F -- "R5. θ₉ = {&nbsp;D₃/luis,<br/>A₃/pedro&nbsp;}" --> G2["padre(pedro, X₃),<br/>descendiente(luis, X₃)"]
    G1 -- "R3. θ₈ = {&nbsp;}" --> S(["consulta vacía"])
    G2 -- "R3. θ₁₀ = {&nbsp;X₃/luis&nbsp;}" --> H["descendiente(luis, luis)"]
    H -- "R4. θ₁₁ = {&nbsp;D₄/luis,<br/>A₄/luis&nbsp;}" --> H1["padre(luis, luis)"]
    H -- "R5. θ₁₂ = {&nbsp;D₄/luis,<br/>A₄/luis&nbsp;}" --> H2["padre(luis, X₄),<br/>descendiente(luis, X₄)"]
    H1 --> F3(["falla"])
    H2 --> F4(["falla"])
```

La rama inútil es la de la **primera** cláusula, `padre(juan, luis)`, que falla:
`juan` no es padre de `luis` de manera directa. Se recorre cada vez, antes de
llegar a la cláusula recursiva que sí produce la respuesta.

No conviene resolverlo reordenando las cláusulas. Poner primero la recursiva
hace que el predicado no termine cuando se le pide la respuesta siguiente, que
es exactamente el problema de la [sección 5.6](index.md#56-ramas-infinitas).

Lo que sí se puede hacer es reordenar los **objetivos** de la cláusula
recursiva, y en este programa no hay nada que reordenar: `padre(A, X)` ya está
antes de la llamada recursiva, que es lo correcto.

La conclusión del ejercicio es esa: no toda rama que falla se puede evitar. La
primera cláusula tiene que intentarse, porque en otros casos es la que responde.
El [capítulo 9](../capitulo-09-backtracking-y-corte/index.md) presenta el corte, que es la construcción que permite descartar
alternativas de manera explícita.

## 15

Sí, y `natural/1` del [capítulo 6](../capitulo-06-recursion/index.md) es el ejemplo. Su árbol para `natural(X)` tiene
infinitas hojas de éxito, una por cada natural, y la primera está de inmediato a
la izquierda: `natural(cero)` se resuelve con el caso base sin descender nada.

Con R1 para `natural(cero).` y R2 para `natural(s(N)) :- natural(N).`:

```mermaid
flowchart TD
    A["natural(X)"] -- "R1. θ₁ = {&nbsp;X/cero&nbsp;}" --> S1(["1.ª respuesta<br/>X = cero"])
    A -- "R2. θ₂ = {&nbsp;X/s(N)&nbsp;}" --> B["natural(N)"]
    B -- "R1. θ₃ = {&nbsp;N/cero&nbsp;}" --> S2(["2.ª respuesta<br/>X = s(cero)"])
    B -- "R2. θ₄ = {&nbsp;N/s(N₂)&nbsp;}" --> C["natural(N₂)"]
    C -- "R1. θ₅ = {&nbsp;N₂/cero&nbsp;}" --> S3(["3.ª respuesta<br/>X = s(s(cero))"])
    C -- "R2. θ₆ = {&nbsp;N₂/s(N₃)&nbsp;}" --> D["⋮<br/>la rama no termina"]
    classDef abierto fill:none,stroke:none;
    class D abierto;
```

La rama de la derecha es infinita, pero en cada nivel hay una hoja de éxito a
su izquierda, y Prolog la alcanza antes de seguir descendiendo.

La clave es **dónde** están las hojas. Un árbol infinito no impide responder si
la primera hoja de éxito se alcanza recorriendo de izquierda a derecha una
cantidad finita de nodos. Lo que impide responder es una **rama** infinita
ubicada a la izquierda de la respuesta, que es el caso de la [sección 5.6](index.md#56-ramas-infinitas): ahí el
recorrido se pierde antes de llegar.

Infinitas respuestas y no terminar no son lo mismo.

## 16

El programa está en `ejemplos/capitulo-05/hermana_politica.pl`:

<!-- ejemplo: capitulo-05/hermana_politica.pl predicado: hijo/2 mujer/2 distinto/2 hermana_politica/2 hermano/2 consulta: hermana_politica(C, X). -->
```prolog
% hijo(H, P): H es hijo de P.
hijo(antonio, juan).
hijo(enrique, juan).

% mujer(M, E): M es la mujer, la esposa, de E.
mujer(belen, enrique).

% distinto(A, B): A y B son dos personas distintas.
distinto(enrique, antonio).

%!  hermana_politica(?X, ?Y) is nondet.
%
%   X es hermana política (cuñada) de Y: es la mujer de un hermano de Y.
hermana_politica(X, Y) :-
    mujer(X, Z),
    hermano(Z, Y).

%!  hermano(?X, ?Y) is nondet.
%
%   X es hermano de Y: son hijos del mismo padre y distintos entre sí.
hermano(X, Y) :-
    hijo(X, Z),
    hijo(Y, Z),
    distinto(X, Y).
```

Con las cláusulas numeradas en el orden en que están escritas:

| | |
|---|---|
| R1 | `hijo(antonio, juan).` |
| R2 | `hijo(enrique, juan).` |
| R3 | `mujer(belen, enrique).` |
| R4 | `distinto(enrique, antonio).` |
| R5 | `hermana_politica(X, Y) :- mujer(X, Z), hermano(Z, Y).` |
| R6 | `hermano(X, Y) :- hijo(X, Z), hijo(Y, Z), distinto(X, Y).` |

La consulta usa la variable `X`, y R5 y R6 también. Son variables distintas:
cada uso de una regla toma una copia con variables nuevas, como dice la nota de
la [sección 5.2](index.md#52-el-arbol-de-derivacion). Para que el árbol no las
confunda, la copia de R5 se escribe con subíndice 1 (`X₁`, `Y₁`, `Z₁`) y la de
R6 con subíndice 2 (`X₂`, `Y₂`, `Z₂`); `C` y `X`, sin subíndice, son las de la
consulta.

```mermaid
flowchart TD
    A["hermana_politica(C, X)"] -- "R5. θ₁ = {&nbsp;X₁/C, Y₁/X&nbsp;}" --> B["mujer(C, Z₁),<br/>hermano(Z₁, X)"]
    B -- "R3. θ₂ = {&nbsp;C/belen,<br/>Z₁/enrique&nbsp;}" --> D["hermano(enrique, X)"]
    D -- "R6. θ₃ = {&nbsp;X₂/enrique,<br/>Y₂/X&nbsp;}" --> E["hijo(enrique, Z₂),<br/>hijo(X, Z₂),<br/>distinto(enrique, X)"]
    E -- "R2. θ₄ = {&nbsp;Z₂/juan&nbsp;}" --> F["hijo(X, juan),<br/>distinto(enrique, X)"]
    F -- "R1. θ₅ = {&nbsp;X/antonio&nbsp;}" --> G["distinto(enrique, antonio)"]
    F -- "R2. θ₇ = {&nbsp;X/enrique&nbsp;}" --> H["distinto(enrique, enrique)"]
    G -- "R4. θ₆ = {&nbsp;}" --> S(["consulta vacía<br/>C = belen, X = antonio"])
    H --> K(["falla"])
```

**Una sola respuesta**: `C = belen, X = antonio`. El árbol tiene dos hojas, una
de éxito y una de falla.

- `θ₁` liga las variables de la copia de R5 con las de la consulta, y no al
  revés. Por eso `C` y `X` siguen en las consultas que quedan, y la respuesta se
  lee en la hoja: `C` recibe su valor en `θ₂` y `X` en `θ₅`.
- `hijo(enrique, Z₂)` tiene un solo arco. R1 no está en el árbol porque su
  cabeza, `hijo(antonio, juan)`, no unifica con el objetivo: `antonio` y
  `enrique` son constantes distintas. Un arco corresponde a una cláusula cuya
  cabeza unifica.
- `hijo(X, juan)` unifica con R1 y con R2: dos ramas. La de R2 llega a
  `distinto(enrique, enrique)`, que no unifica con R4, la única cláusula de
  `distinto/2`, y falla: `distinto/2` es lo que impide que `enrique` resulte
  hermano de sí mismo.
- `θ₆` está vacía: `distinto(enrique, antonio)` ya es idéntico a R4.

La traza recorre las mismas ramas en el mismo orden. La primera parte llega a
la hoja de éxito; la que sigue a la respuesta es el retroceso a
`hijo(_, juan)`, la rama de R2:

```text
   Call: (12) hermana_politica(_10204, _10206)
   Call: (13) mujer(_10204, _11340)
   Exit: (13) mujer(belen, enrique)
   Call: (13) hermano(enrique, _10206)
   Call: (14) hijo(enrique, _13178)
   Exit: (14) hijo(enrique, juan)
   Call: (14) hijo(_10206, juan)
   Exit: (14) hijo(antonio, juan)
   Call: (14) distinto(enrique, antonio)
   Exit: (14) distinto(enrique, antonio)
   Exit: (13) hermano(enrique, antonio)
   Exit: (12) hermana_politica(belen, antonio)
   Redo: (14) hijo(_10206, juan)
   Exit: (14) hijo(enrique, juan)
   Call: (14) distinto(enrique, enrique)
   Fail: (14) distinto(enrique, enrique)
   Fail: (13) hermano(enrique, _10206)
   Fail: (12) hermana_politica(_10204, _10206)
```

La línea `Exit: (14) hijo(enrique, juan)` sigue directamente a su `Call`: como
en el árbol, R1, cuya cabeza no unifica, no aparece. La consulta responde:

```prolog
?- hermana_politica(C, X).
C = belen,
X = antonio ;
false.
```

El `false.` corresponde a la rama de R2, que quedaba pendiente a la derecha de
la hoja de éxito. `distinto/2` enumera pares en un solo orden: con
`distinto(antonio, enrique)` agregado, `hermano(antonio, enrique)` también se
probaría, pero la consulta seguiría teniendo una sola respuesta, porque `belen`
es la mujer de `enrique` y no de `antonio`.
