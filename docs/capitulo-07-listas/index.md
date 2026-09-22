# Capítulo 7 — Listas

Una lista es una secuencia ordenada de elementos, cuya cantidad no se conoce de
antemano: los invitados a una fiesta, las materias de un cuatrimestre, las
letras de una palabra.

El capítulo 6 mostró cómo recorrer una estructura que se reduce en cada llamada.
Una lista es exactamente una estructura de ese tipo, de modo que este capítulo
es, en lo esencial, una aplicación del capítulo 6. Los elementos nuevos son la
notación y un conjunto de predicados predefinidos de uso frecuente.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- escribir listas y descomponerlas en primer elemento y resto;
- recorrer una lista mediante una recursión de estructura fija;
- construir una lista nueva durante el recorrido de otra;
- usar una misma relación en varios sentidos, que es la propiedad que les da
  generalidad;
- usar los predicados de listas predefinidos de Prolog, y explicar cómo están
  definidos.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **0:40 h**.
    Resolver los 7 ejercicios marcados con ★: **2:00 h**.
    Resolver los 16 ejercicios del final: **5:20 h**.

## 7.1 Una lista es un término

Una lista se escribe entre corchetes, con los elementos separados por comas:

```prolog
[ana, luis, eva]
```

Sus elementos pueden ser términos de cualquier clase: átomos, números, términos
compuestos y otras listas. La lista vacía se escribe `[]`, y es una constante:
no tiene componentes.

La propiedad fundamental, que explica todo el resto del capítulo, es que **una
lista no es una clase de dato distinta**. Es un término compuesto como los del
capítulo 4, con dos argumentos: un primer elemento, y una lista con los
elementos restantes. Los corchetes son una notación que evita escribir los
paréntesis anidados.

## 7.2 Primer elemento y resto

La barra vertical descompone una lista en sus dos componentes:

```prolog
?- [ana, luis, eva] = [Primero|Resto].
Primero = ana,
Resto = [luis, eva].
```

`Primero` es el primer elemento; `Resto` es **una lista** con todos los demás.
Este último punto es el central: el resto de una lista es otra lista, y por eso
se le puede aplicar nuevamente la misma regla.

Cuando la lista tiene un solo elemento, el resto es la lista vacía:

```prolog
?- [ana] = [Primero|Resto].
Primero = ana,
Resto = [].
```

La lista vacía no se puede descomponer, porque no tiene primer elemento:

```prolog
?- [] = [_|_].
false.
```

Estos dos resultados son la base de todas las recursiones del capítulo: `[]`
corresponde al caso base, y `[X|Resto]`, al caso recursivo.

Se puede extraer más de un elemento del comienzo de la lista:

```prolog
?- [Primero, Segundo|Resto] = [ana, luis, eva, sofia].
Primero = ana,
Segundo = luis,
Resto = [eva, sofia].
```

!!! question "Actividad"
    Antes de ejecutarlas, determinar qué responden estas cuatro consultas:
    `[a, b, c] = [X|Y].` · `[a, b, c] = [X, Y|Z].` · `[a] = [X|Y].` ·
    `[] = [X|Y].` Ejecutarlas y explicar por qué la última es la única que
    responde `false.`. Conviene observar que `[X|Y]` es un patrón de término,
    como los de la plantilla 7 del capítulo 4, y no una operación sobre listas.

## 7.3 Recorrer una lista

Esta sección presenta la plantilla que se usa en todo el resto del curso.
Determinar si un elemento pertenece a una lista tiene dos casos: el elemento es
el primero de la lista, o pertenece al resto.

<!-- ejemplo: capitulo-07/recorrer.pl predicado: esta_en/2 consulta: esta_en(luis, [ana, luis, eva]). -->
```prolog
% esta_en(X, L): X es uno de los elementos de L.
% X es el primer elemento, o es un elemento del resto.
esta_en(X, [X|_]).
esta_en(X, [_|Resto]) :-
    esta_en(X, Resto).
```

La primera cláusula es un hecho, y no requiere cuerpo: se cumple cuando el
elemento buscado y el primer elemento de la lista son el mismo. Esa condición la
resuelve la unificación, porque `X` aparece en las dos posiciones.

Vale la pena registrar esto como un recurso general: **una condición entre dos
argumentos se puede expresar de dos maneras**. Repitiendo el mismo nombre de
variable en la cabeza, y entonces la igualdad la impone la unificación sin
escribir ningún objetivo; o como un objetivo en el cuerpo. Que dos cosas sean
iguales se expresa de la primera manera; que sean distintas hay que escribirlo,
porque no hay forma de exigirlo con la unificación.

Además, la forma de este predicado no es arbitraria: **se copia de la forma del
dato**. En 7.1 se estableció que hay dos maneras de ser una lista —la lista
vacía, o un primer elemento seguido de una lista—, y por eso un predicado que
recorre una lista tiene dos cláusulas, una por cada manera. Es también la razón
por la que este capítulo y el 6 comparten plantilla: en los dos casos la
estructura del programa reproduce la estructura de aquello que recorre.

La segunda cláusula no examina el primer elemento —por eso se escribe `_`— y
plantea la misma consulta sobre el resto, que es una lista más corta. Como cada
llamada reduce la lista y la lista es finita, la recursión termina.

**No existe un caso base explícito para `[]`**, y no es necesario: ninguna de las
dos cláusulas unifica con la lista vacía, de modo que la búsqueda termina por
falta de cláusulas aplicables. En algunos predicados el caso base es un hecho;
en otros, como en este, es la ausencia de una cláusula aplicable.

Como en los capítulos anteriores, el mismo predicado permite verificar y
enumerar:

```prolog
?- esta_en(X, [ana, luis, eva]).
X = ana ;
X = luis ;
X = eva ;
false.
```

La enumeración termina en `false.` y no en punto: después de `eva` queda
pendiente el recorrido del resto, que es `[]`, y ahí ninguna cláusula unifica.
No indica que algo haya fallado, sino que se agotaron las alternativas.

Conviene además observar que el predicado responde **una vez por cada aparición**
del elemento en la lista, y no una sola vez:

```prolog
?- esta_en(ana, [ana, ana]).
true ;
true ;
false.
```

Hay dos demostraciones, una por cada `ana`, y por eso hay dos respuestas. No es
un defecto del predicado: cada respuesta corresponde a una manera distinta de
satisfacer la consulta.

!!! abstract "Plantilla 9 — Recorrer una lista"
    **Cuándo**: se deben examinar los elementos de una lista, de a uno por vez.

    ```prolog
    p([]) :-
        caso_de_la_lista_vacia.
    p([Primero|Resto]) :-
        procesar(Primero),
        p(Resto).
    ```

    El caso base es la lista vacía; el caso recursivo extrae el primer elemento
    y continúa con el resto. En algunos predicados el caso base se escribe como
    hecho; en otros no es necesario escribirlo.

    **En este capítulo se usa en**: `largo/2` (7.4), `pegar/3` (7.5). Las demás
    plantillas están en [esta página](../plantillas.md).

`esta_en/2` no responde a esa plantilla, y conviene distinguirlas, porque son
las dos siluetas que más se repiten al recorrer una lista. La diferencia está en
el caso base y en qué se hace con cada elemento.

!!! abstract "Plantilla 10 — Buscar un elemento que cumple una condición"
    **Cuándo**: alcanza con que **alguno** de los elementos cumpla la
    condición, y no hace falta examinarlos todos.

    ```prolog
    p([Primero|_]) :-
        cumple(Primero).
    p([_|Resto]) :-
        p(Resto).
    ```

    Acá el caso base **no** es la lista vacía: la primera cláusula tiene éxito
    sin recursión en cuanto encuentra un elemento que cumple. Sobre la lista
    vacía no hay cláusula aplicable, y la búsqueda fracasa, que es lo correcto:
    ninguno cumplió.

    **En este capítulo se usa en**: `esta_en/2` (7.3).

La condición opuesta —que **todos** los elementos cumplan— tiene su propia
silueta, y es la imagen invertida de la anterior:

<!-- ejemplo: capitulo-07/recorrer.pl predicado: todos_estan/2 consulta: todos_estan([ana, eva], [ana, luis, eva]). -->
```prolog
% todos_estan(Buscados, L): todos los elementos de Buscados son elementos de L.
% Todos los elementos cumplen una condición: el caso base es la lista vacía y
% tiene éxito, y el recorrido fracasa en cuanto uno no cumple.
todos_estan([], _).
todos_estan([X|Resto], L) :-
    esta_en(X, L),
    todos_estan(Resto, L).
```

```prolog
?- todos_estan([ana, eva], [ana, luis, eva]).
true ;
false.
```

!!! abstract "Plantilla 11 — Todos los elementos cumplen"
    **Cuándo**: la condición se debe verificar sobre **todos** los elementos.

    ```prolog
    p([]).
    p([Primero|Resto]) :-
        cumple(Primero),
        p(Resto).
    ```

    El caso base es la lista vacía y **tiene éxito**: sobre una lista sin
    elementos, "todos cumplen" es cierto. El fracaso se produce en cuanto un
    elemento no cumple, y el recorrido se detiene ahí.

    Se distingue de la plantilla 9 en que no procesa cada elemento: lo somete a
    una prueba, y no produce ningún resultado más allá de cumplirse o no.

    **En este capítulo se usa en**: `todos_estan/2` (7.3).

!!! question "Actividad"
    Ejecutar `esta_en(X, [a, b, c]).` y solicitar todas las respuestas con `;`.
    Después ejecutar `esta_en(c, [a, b, c]).` con `trace` y contar cuántas veces
    se usa la segunda cláusula. La misma definición sirve para **preguntar** si
    un elemento está y para **enumerar** los que están; no son dos operaciones
    distintas, sino la misma relación consultada de dos maneras.

## 7.4 Contar durante el recorrido

Es la misma plantilla, con un resultado numérico. Corresponde a
`generaciones/3` del capítulo 6, con una lista en lugar de una familia:

<!-- ejemplo: capitulo-07/recorrer.pl predicado: largo/2 consulta: largo([ana, luis, eva], Cuantos). -->
```prolog
% largo(L, N): N es la cantidad de elementos de L.
largo([], 0).
largo([_|Resto], N) :-
    largo(Resto, Faltan),
    N is Faltan + 1.
```

La lista vacía tiene cero elementos: es el caso base. Una lista con primer
elemento y resto tiene un elemento más que su resto.

`is` se escribe **después** de la llamada recursiva, por la misma razón que en
el capítulo 6: `Faltan` no tiene valor hasta que la llamada termina.

## 7.5 Construir una lista durante el recorrido de otra

En los predicados anteriores, las listas eran datos de entrada. En el siguiente,
una lista es el resultado: la concatenación de dos listas.

<!-- ejemplo: capitulo-07/recorrer.pl predicado: pegar/3 consulta: pegar([ana, luis], [eva], Todos). -->
```prolog
% pegar(A, B, C): C es la lista A seguida de la lista B.
pegar([], B, B).
pegar([X|RestoA], B, [X|RestoC]) :-
    pegar(RestoA, B, RestoC).
```

Este predicado requiere una lectura detenida, porque es el primero en el que la
lista **se construye en la cabeza de la regla**.

El caso base establece que la concatenación de la lista vacía y `B` es `B`, sin
modificaciones. El caso recursivo establece lo siguiente: si el primer elemento
de `A` es `X`, el primer elemento del resultado también es `X`, y el resto del
resultado es la concatenación del resto de `A` con `B`.

Ninguna cláusula construye la lista mediante un predicado: la lista está
**escrita en la cabeza**, `[X|RestoC]`, y se completa a medida que las llamadas
recursivas terminan.

Conviene detenerse en cómo queda la lista mientras tanto. Durante todo el
recorrido, el resultado es una lista **incompleta**: cada llamada fija su primer
elemento y deja el resto sin determinar, y recién el caso base cierra la
estructura. De esto se sigue una limitación que importa en el capítulo
siguiente: en cada paso ya hay un resultado parcial construido, pero **la
recursión no puede consultarlo**. Lo construido queda por encima de la llamada
actual, y la llamada actual no tiene manera de mirarlo.

Cuando un predicado necesita saber qué lleva hecho para decidir el paso
siguiente, esta forma no alcanza, y hay que construir el resultado en el otro
sentido: llevándolo en un argumento que viaje hacia adelante. Eso es un
acumulador, y es el tema de las secciones 8.5 y 8.6.

```prolog
?- pegar([ana, luis], [eva], Todos).
Todos = [ana, luis, eva].
```

!!! abstract "Plantilla 12 — Construir una lista durante el recorrido de otra"
    **Cuándo**: el resultado es una lista que se obtiene al recorrer otra.

    ```prolog
    p([], CasoBase).
    p([X|Resto], [Y|RestoNuevo]) :-
        relacionar(X, Y),
        p(Resto, RestoNuevo).
    ```

    La lista resultante se escribe en la **cabeza**; no se construye en el
    cuerpo. Cada llamada aporta el primer elemento del resultado, y la recursión
    completa el resto.

    Las dos partes que cambian de un predicado a otro son el caso base —qué
    resultado corresponde a la lista vacía— y la relación entre cada elemento y
    el que ocupa su lugar en el resultado.

    **En este capítulo se usa en**: `pegar/3` (7.5), que es el caso más simple
    de la plantilla. Cada elemento pasa al resultado sin modificarse, de modo
    que no se requiere ningún `relacionar/2` y en la cabeza se escribe dos veces
    la misma variable; y el caso base no entrega la lista vacía sino la segunda
    lista. El capítulo 8 la retoma con acumuladores.

## 7.6 Una relación, varios sentidos

Esta sección muestra la ventaja de haber definido `pegar/3` como una relación y
no como un procedimiento.

Con las dos primeras listas instanciadas, el predicado concatena. Con la
**tercera** instanciada y las otras dos libres, el resultado es distinto:

```prolog
?- pegar(A, B, [ana, luis, eva]).
A = [],
B = [ana, luis, eva] ;
A = [ana],
B = [luis, eva] ;
A = [ana, luis],
B = [eva] ;
A = [ana, luis, eva],
B = [] ;
false.
```

Se obtienen **todas las particiones de la lista en dos partes**. No se escribió
ningún predicado para particionar listas: es el mismo `pegar/3`, consultado en
otro sentido.

De esta propiedad se derivan otras operaciones sin código adicional. Para
determinar si una lista comienza con otra, se consulta si existe una lista que,
concatenada a continuación de la segunda, produce la primera. Para obtener el
último elemento, se consulta por una partición cuya segunda parte tenga un solo
elemento.

Esta es la idea más importante del capítulo, y la razón por la que en Prolog
conviene modelar un problema mediante relaciones antes que mediante secuencias
de pasos.

!!! warning "Usar una relación en varios sentidos tiene un límite"
    Que un predicado admita varios sentidos no significa que todos terminen. La
    condición, para los dos predicados de este capítulo, es que haya una lista
    **completa** por la cual recorrer:

    - `pegar/3` termina si la primera o la tercera lista está completa. Si las
      dos están sin determinar, produce particiones sin fin.
    - `esta_en/2` termina si la lista está completa. Con la lista sin
      determinar, produce listas cada vez más largas, sin fin.

    Antes de consultar un predicado en un sentido nuevo, conviene preguntarse
    qué recorre y si eso que recorre es finito.

## 7.7 Predicados predefinidos

Todos los predicados anteriores existen en Prolog con nombres estándar. En
adelante, el curso usa los predefinidos, y no las versiones de este capítulo:

| | |
|---|---|
| `member(X, L)` | X es un elemento de L. Equivale a `esta_en/2` |
| `length(L, N)` | N es la cantidad de elementos de L. Equivale a `largo/2` |
| `append(A, B, C)` | C es A seguida de B. Equivale a `pegar/3` |
| `reverse(L, R)` | R es L en orden inverso |
| `last(L, X)` | X es el último elemento de L |
| `nth1(N, L, X)` | X es el elemento en la posición N de L, contando desde 1 |

<!-- ejemplo: capitulo-07/invitados.pl predicado: esta_invitado/1 cuantos/1 en_el_puesto/2 consulta: en_el_puesto(2, Quien). -->
```prolog
% esta_invitado(P): P está en la lista.
esta_invitado(P) :-
    invitados(Lista),
    member(P, Lista).

% cuantos(N): N es la cantidad de invitados.
cuantos(N) :-
    invitados(Lista),
    length(Lista, N).

% en_el_puesto(N, P): P es quien llegó en la posición N, contando desde 1.
en_el_puesto(N, P) :-
    invitados(Lista),
    nth1(N, Lista, P).
```

`nth1/3` también admite la consulta inversa, igual que `append/3`: con la
posición libre, determina en qué posición se encuentra un elemento.

```prolog
?- en_el_puesto(N, eva).
N = 3 ;
false.
```

La existencia de estos predicados no vuelve innecesario el trabajo de las
secciones anteriores. La plantilla 9 se requiere de manera constante, para
recorridos que no corresponden a ninguno de estos seis predicados.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** ¿Qué responde `[a, b, c] = [X|Y].`? ¿Y `[a] = [X, Y].`?
2. **(1)** Escribir una lista con tres materias y una consulta que determine si
   una de ellas pertenece a la lista.
3. **(2)** Escribir `primero_y_ultimo(L, P, U)` con los elementos del capítulo.
4. **(2)** Escribir `sin_el_primero(L, R)`: R es L sin su primer elemento.
   ¿Requiere recursión?
5. ★ **(2)** Escribir `cuantos_gatos(L, N)`, que cuenta las apariciones de `gato`
   en una lista de animales. Es `largo/2` con una condición.
6. **(2)** Escribir `empieza_con(L, Principio)`, que se cumple cuando `L`
   comienza con los elementos de `Principio`. Usar `append/3`, sin recursión.
7. ★ **(2)** Escribir `dar_vuelta(L, R)` sin usar `reverse/2`. Se requiere
   `append/3`.
8. **(3)** Escribir `sacar(X, L, R)`: R es L sin la primera aparición de X.
9. **(3)** Escribir `es_sublista(S, L)`: los elementos de `S` aparecen en `L`,
   contiguos y en el mismo orden. Se puede resolver con dos `append/3` y sin
   recursión.
10. ★ **(3)** Ejecutar `?- length(L, 2).` y explicar la respuesta obtenida y por
    qué es correcta.
11. ★ **(1)** Los tres predicados siguientes recorren una lista, y cada uno
    responde a una plantilla distinta: la 9, la 10 o la 11. Indicar cuál
    corresponde a cada uno, sin ejecutarlos:

    ```prolog
    % a
    p([]).
    p([X|Resto]) :- animal(X), p(Resto).

    % b
    q([X|_]) :- animal(X).
    q([_|Resto]) :- q(Resto).

    % c
    r([], []).
    r([X|Resto], [X|Otros]) :- animal(X), r(Resto, Otros).
    ```
12. **(2)** Escribir `todos_gatos(L)`, que se cumple cuando todos los elementos
    de `L` son `gato`, usando la plantilla 11. Después escribir `algun_gato(L)`
    con la plantilla 10. Comparar qué responde cada uno sobre `[]`, y explicar
    por qué las dos respuestas son correctas.
13. ★ **(2)** El predicado siguiente pretende duplicar cada elemento de una lista,
    pero no funciona. Explicar la causa y corregirlo:

    ```prolog
    duplicar([], []).
    duplicar([X|Resto], Nueva) :-
        duplicar(Resto, Otros),
        append([X, X], Otros, Nueva).
    ```

    La corrección consiste en escribir el resultado donde corresponde, de
    acuerdo con la plantilla 12.
14. ★ **(2)** Explorar los modos de `pegar/3`. Para cada una de estas consultas,
    determinar **antes de ejecutarla** si produce una respuesta, varias,
    ninguna, o no termina:
    `pegar([a], [b], R).` · `pegar(A, [b], [a, b]).` ·
    `pegar([a], B, [a, b]).` · `pegar(A, B, [a, b]).` Verificarlo después.
15. **(2)** Escribir `segundo(L, X)`: `X` es el segundo elemento de `L`. Se
    resuelve con un solo hecho y sin recursión. Después explicar qué responde
    `segundo([ana], X).` y por qué.
16. **(3)** Escribir las pruebas de `sacar/3` del ejercicio 8: una con `all`
    sobre una lista con el elemento repetido, una con `[fail]`, y una que
    verifique qué ocurre cuando el elemento no está en la lista.

## Resumen

| | |
|---|---|
| `[]` | la lista vacía; es una constante |
| `[X, Y, Z]` | una lista de tres elementos |
| `[Primero|Resto]` | descompone una lista en su primer elemento y el resto |
| `[A, B|Resto]` | lo mismo, con los dos primeros elementos |
| `member/2` | pertenencia de un elemento a una lista |
| `length/2` | cantidad de elementos de una lista |
| `append/3` | concatena dos listas, o particiona una en dos |
| `reverse/2` | invierte el orden de una lista |
| `last/2` | el último elemento |
| `nth1/3` | el elemento en la posición N, contando desde 1 |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Acumuladores, otra forma de recorrer una lista | capítulo 8 |
| Recorridos que se interrumpen al encontrar el elemento buscado | capítulo 9 |
| Reunir en una lista todas las respuestas de una consulta | capítulo 15 |
| Recorrer una lista sin escribir la recursión, con `maplist/2` | capítulo 16 |
| El resto de `library(lists)`, y el ordenamiento | capítulo 20 |
| Listas diferencia, que concatenan en un paso sin recorrer | capítulo 26 |
