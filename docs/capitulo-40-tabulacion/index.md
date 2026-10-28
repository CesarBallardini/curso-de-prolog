# Capítulo 40 — Tabulación

Una relación recursiva escrita con la recursión a la izquierda no termina en
Prolog, y tampoco una que recorre un grafo con ciclos
([sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas)). Una recurrencia como la de Fibonacci termina, pero
resuelve los mismos subproblemas una cantidad exponencial de veces, y la
memorización del [capítulo 21](../capitulo-21-base-de-datos-dinamica/index.md#215-memorizacion) lo evita al precio de un estado escrito
a mano. La **tabulación** resuelve las dos cosas con una directiva:
`:- table p/N` hace que cada llamada a `p/N` guarde sus respuestas en una
tabla, y que una llamada igual a otra que ya está en curso consuma las
respuestas de esa tabla en lugar de volver a resolverse. Las cláusulas no
cambian; cambia la forma de ejecutarlas.

El [capítulo 39](../capitulo-39-semantica-de-los-programas-logicos/index.md) definió lo que un programa significa: el modelo mínimo,
que la evaluación de abajo hacia arriba calcula siempre en un programa sin
functores, y el modelo bien fundado, con tres valores de verdad. La
tabulación de SWI-Prolog calcula exactamente eso, pero parte de la consulta,
como Prolog, y solo calcula lo que la consulta necesita. El capítulo sigue una
escalera: la recursión que no termina y la directiva que la hace terminar; la
memorización sin estado; las tablas que guardan solo la mejor respuesta; la
negación a través de la recursión, con respuestas indefinidas; las tablas que
siguen a los datos dinámicos; lo que cuesta todo eso, medido; y dos
aplicaciones, el intérprete del sistema experto y la cadena de correlativas
de *Inscripciones*.

Las fuentes son *Programming in Tabled Prolog* de David S. Warren, escrito
para XSB, el sistema en el que nació la técnica (capítulos «Tabling and
Datalog Programming», «Dynamic Programming in XSB», «Aggregation» y
«Negation in XSB»); el capítulo «Memoization» de *The Power of Prolog* de
Markus Triska; y la sección «Tabled execution» del manual de SWI-Prolog.
Las [referencias](#referencias) del final dan los enlaces. El capítulo cumple
los anuncios de los capítulos [17](../capitulo-17-rendimiento/index.md) y [18](../capitulo-18-todas-las-soluciones/index.md) (recordar resultados y
reunir las respuestas de una relación recursiva sin repetirlas), del
[capítulo 21](../capitulo-21-base-de-datos-dinamica/index.md) (la memorización sin estado escrito a mano), del
[capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md) (la recursión a la izquierda que termina sin perder
respuestas), del [capítulo 36](../capitulo-36-transformacion-de-programas-y-compilacion/index.md) (una directiva que cambia al cargar cómo
se ejecuta un predicado), del [capítulo 38](../capitulo-38-concurrencia-y-paralelismo/index.md) (las tablas y los hilos) y
del [capítulo 39](../capitulo-39-semantica-de-los-programas-logicos/index.md) (`tnot/1`, las respuestas indefinidas y el intérprete del
sistema experto con tablas). SWISH admite `:- table`, `tnot/1`, las tablas
incrementales y `abolish_all_tables/0`: salvo los que cargan otro archivo o
crean hilos, los ejemplos corren allí.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- tabular una relación recursiva con `:- table` para que termine con la
  recursión a la izquierda y con ciclos, y explicar por qué termina;
- reemplazar una memorización escrita con `assertz/1` por una tabla, y
  borrar las tablas con `abolish_all_tables/0` cuando hace falta;
- declarar un modo de subsunción de respuestas, `min`, `max` o `lattice`,
  para guardar solo la mejor respuesta, y reconocer cuándo sin él la tabla
  no se completa;
- usar `tnot/1` para la negación a través de la recursión, e interpretar una
  respuesta indefinida y su programa residual con `call_delays/2`;
- declarar tablas incrementales que siguen los cambios de un predicado
  dinámico, y tablas compartidas entre hilos;
- medir lo que cuesta una tabla, en inferencias y en memoria, y elegir la
  dirección de la recursión según la consulta;
- aplicar la tabulación a un intérprete de reglas y a una relación de
  *Inscripciones*.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **2:10 h**.
    Resolver los 6 ejercicios marcados con ★: **1:35 h**.
    Resolver los 15 ejercicios del capítulo: **4:00 h**.

## 40.1 `:- table`: recursión a la izquierda y ciclos

`camino.pl` tiene el grafo del [capítulo 39](../capitulo-39-semantica-de-los-programas-logicos/index.md#391-modelos-y-consecuencia-logica), con un ciclo entre a, b y c,
y la definición de camino con la recursión a la izquierda:

<!-- ejemplo: capitulo-40/camino.pl predicado: arco/2 camino_prolog/2 -->
```prolog
% arco(X, Y): hay un arco de X a Y.
arco(a, b).
arco(b, c).
arco(c, a).
arco(c, d).

%!  camino_prolog(?X, ?Y) is nondet.
%
%   Hay un camino de X a Y. Con la recursión a la izquierda y el ciclo de
%   a, b y c, Prolog repite las respuestas sin fin y no termina después de
%   la última.
camino_prolog(X, Y) :-
    arco(X, Y).
camino_prolog(X, Y) :-
    camino_prolog(X, Z),
    arco(Z, Y).
```

Prolog no termina. Desde `a` repite las respuestas sin fin, porque cada
vuelta al ciclo es otra demostración de los mismos caminos, y desde `d`,
que no tiene arcos, no responde nada: la segunda cláusula se llama a sí
misma con la misma consulta hasta agotar la pila.

```prolog
?- findall(Y, limit(8, camino_prolog(a, Y)), Ys).
Ys = [b, c, a, d, b, c, a, d].
```

```text
?- camino_prolog(d, Y).
ERROR: Stack limit (1.0Gb) exceeded
```

La misma definición con la directiva `table` delante:

<!-- ejemplo: capitulo-40/camino.pl fragmento: :- table camino/2. .. arco(Z, Y). -->
```prolog
:- table camino/2.

%!  camino(?X, ?Y) is nondet.
%
%   Hay un camino de X a Y. Las mismas cláusulas que camino_prolog/2,
%   tabuladas: cada respuesta aparece una vez y la consulta termina.
camino(X, Y) :-
    arco(X, Y).
camino(X, Y) :-
    camino(X, Z),
    arco(Z, Y).
```

```prolog
?- findall(Y, camino(a, Y), Ys), msort(Ys, Ordenadas).
Ys = [b, a, d, c],
Ordenadas = [a, b, c, d].

?- camino(d, Y).
false.
```

Cada respuesta aparece una vez, y las dos consultas terminan. La ejecución
es la de Warren (*Programming in Tabled Prolog*, capítulo «Tabling and
Datalog Programming»), en la forma que SWI-Prolog implementa, la
**resolución SLG**:

- la primera llamada a `camino(a, Y)` crea una **tabla** para esa llamada,
  vacía, y empieza a resolverla con las cláusulas, como Prolog;
- la primera cláusula agrega a la tabla la respuesta `camino(a, b)`;
- la segunda cláusula llama a `camino(a, Z)`, una **variante** de la llamada
  en curso: la misma salvo el nombre de las variables. En lugar de
  resolverla de nuevo, que es lo que hace no terminar a Prolog, la llamada
  **consume** las respuestas de la tabla: con Z = b, `arco(b, Y)` agrega
  `camino(a, c)`; con Z = c, agrega a y d; con Z = a, agrega b, que ya
  está, y la tabla no cambia;
- cuando ninguna llamada consumidora tiene respuestas nuevas para usar, la
  tabla está **completa**, y la consulta devuelve sus respuestas.

Una tabla guarda cada respuesta una sola vez, y una llamada consumidora
recibe cada respuesta una sola vez: como el grafo tiene cuatro nodos, hay a
lo sumo cuatro respuestas y la tabla se completa. Es la evaluación
semi-ingenua de la [sección 39.6](../capitulo-39-semantica-de-los-programas-logicos/negacion.md#396-evaluacion-de-abajo-hacia-arriba), aplicada solo a lo que la consulta
pide: `camino(a, Y)` no calcula los caminos que salen de b.

El orden de las respuestas, el de `Ys`, es el de la tabla, no el de las
cláusulas, y puede cambiar de una ejecución a otra y de un sistema a otro:
en esta máquina, la misma consulta dio d, b, c, a en otro proceso. Por eso
la consulta reúne las respuestas con `findall/3` y las ordena con
`msort/2`, que conserva las repetidas: `Ordenadas` es la misma en cualquier
ejecución, y muestra cada respuesta una vez. Consultada sola,
`camino(a, Y)` da las respuestas una por una, y que la última deje o no una
alternativa pendiente también depende del sistema. Las pruebas de
`camino.plt` comparan las respuestas ordenadas con `msort/2`.

La recursión a la izquierda del [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md#343-variar-el-interprete) tiene la misma solución.
Allí, `antepasado_izq(A, eva)` daba sus tres respuestas y agotaba la pila, y
el intérprete que abandonaba las variantes terminaba pero perdía a juan,
que estaba a tres generaciones. Con la tabla, la variante no se abandona:
espera las respuestas de la llamada en curso.

<!-- ejemplo: capitulo-40/camino.pl fragmento: :- table antepasado_izq/2. .. padre(H, D). -->
```prolog
:- table antepasado_izq/2.

%!  antepasado_izq(?A, ?D) is nondet.
%
%   A es un antepasado de D, con la recursión a la izquierda y tabulado.
antepasado_izq(A, D) :-
    padre(A, D).
antepasado_izq(A, D) :-
    antepasado_izq(A, H),
    padre(H, D).
```

```prolog
?- findall(A, antepasado_izq(A, eva), As), msort(As, Ordenadas).
As = [ana, luis, juan],
Ordenadas = [ana, juan, luis].
```

La directiva se aplica al cargar el archivo, como las expansiones del
[capítulo 36](../capitulo-36-transformacion-de-programas-y-compilacion/index.md): SWI-Prolog pone delante de las cláusulas un predicado
envoltorio que administra la tabla, y `listing(camino/2)` muestra la
directiva como `:- table camino/2 as variant.`, porque las tablas se
distinguen por variantes. El programa no llama a nada distinto: la decisión de
tabular es independiente de las cláusulas, y se puede tomar después de
escribirlas.

!!! question "Actividad"
    Predecir, sin ejecutarlas, cuántas respuestas dan `camino(c, Y)`,
    `camino(X, a)` y `camino(X, Y)`, y cuáles de las tres terminarían sin
    la tabla. Comprobar las tres con la tabla y con
    `aggregate_all(count, …, N)`.

## 40.2 Memorización sin estado escrito a mano

La memorización de la [sección 21.5](../capitulo-21-base-de-datos-dinamica/index.md#215-memorizacion) guarda cada valor de
`fib_memo/2` en un predicado dinámico, lo busca antes de calcularlo, y
necesita un predicado que borre lo guardado ([Patrón 17](../patrones.md#17-memorizacion-con-assertz)). Con la tabla,
la definición recursiva directa basta:

<!-- ejemplo: capitulo-40/fibonacci.pl fragmento: :- table fib_tabla/2. .. F is F1 + F2 -->
```prolog
:- table fib_tabla/2.

%!  fib_tabla(+N:integer, -F:integer) is det.
%
%   La misma relación que fib/2, tabulada.
fib_tabla(N, F) :-
    (   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib_tabla(N1, F1),
        fib_tabla(N2, F2),
        F is F1 + F2
```

```text
?- time(fib(25, F)).
% 728,353 inferences, 0.063 CPU in 0.062 seconds (101% CPU, 11653648 Lips)
F = 75025.

?- time(fib_tabla(25, F)).
% 1,031 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
F = 75025.
```

`fib/2`, la misma definición sin la tabla, recalcula `fib(1, _)` decenas de
miles de veces; `fib_tabla/2` resuelve cada llamada una vez, y una segunda
consulta encuentra la tabla completa:

```text
?- time(fib_tabla(1000, _)), time(fib_tabla(1000, _)).
% 40,031 inferences, 0.016 CPU in 0.016 seconds (97% CPU, 2561984 Lips)
% 3 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
true.
```

Las tablas duran lo que dura el proceso, o hasta que se borran:
`abolish_all_tables/0` las borra todas, y la llamada siguiente recalcula. Es
lo que hace `fibonacci.plt` para medir, y lo que hay que hacer si cambian
los datos de los que dependen las respuestas, salvo con las tablas
incrementales de la [sección 40.5](incremental.md#405-tabulacion-incremental).

La tabla no es solo una memoria de valores: `fib_tabla/2` es una función,
pero la directiva se aplica igual a una relación con varias respuestas por
llamada, que un `->` como el de `fib_memo/2` no guardaría. La programación
dinámica, en la que cada subproblema se resuelve una vez y su resultado se
reutiliza, se escribe como la recursión que define el problema, más la
directiva (Warren, capítulo «Dynamic Programming in XSB»). `caminos_grilla/3`
cuenta los recorridos de una grilla que solo avanzan hacia abajo o hacia la
derecha: los que llegan a una celda son los que llegan a la de arriba más
los que llegan a la de la izquierda.

<!-- ejemplo: capitulo-40/fibonacci.pl fragmento: :- table caminos_grilla/3. .. N is N1 + N2. -->
```prolog
:- table caminos_grilla/3.

%!  caminos_grilla(+F:integer, +C:integer, -N:integer) is det.
%
%   N es la cantidad de recorridos desde la celda (0, 0) hasta la celda
%   (F, C) que en cada paso avanzan una fila o una columna. F y C son
%   naturales.
caminos_grilla(F, C, N) :-
    (   ( F =:= 0 ; C =:= 0 )
    ->  N = 1
    ;   camino_interior(F, C, N)
    ).

%!  camino_interior(+F:integer, +C:integer, -N:integer) is det.
%
%   N es la cantidad de recorridos hasta (F, C), con F y C positivos: los
%   que llegan desde la fila anterior más los que llegan desde la columna
%   anterior.
camino_interior(F, C, N) :-
    F1 is F - 1,
    C1 is C - 1,
    caminos_grilla(F1, C, N1),
    caminos_grilla(F, C1, N2),
    N is N1 + N2.
```

```prolog
?- caminos_grilla(16, 16, N).
N = 601080390.
```

Sin la tabla, la consulta recorre cada uno de esos seiscientos millones de
caminos; con ella, resuelve las 289 celdas de la grilla una vez cada una.

!!! example "Patrón 53 — Tabular la relación recursiva"
    **Problema.** Una relación recursiva no termina —recursión a la
    izquierda, un grafo con ciclos, una negación a través de la recursión— o
    resuelve los mismos subproblemas muchas veces.

    **Versión ingenua.** Reordenar las cláusulas y los objetivos hasta que
    la consulta de las pruebas termine, llevar una lista de nodos visitados,
    o guardar los resultados con `assertz/1` ([Patrón 17](../patrones.md#17-memorizacion-con-assertz)): cada una
    cambia la definición, deja estado que mantener o pierde respuestas, y
    ninguna hace terminar una recursión a la izquierda.

    **Patrón.** Dejar las cláusulas como la definición del problema y
    declarar `:- table p/N`. Si solo interesa la mejor respuesta, declarar
    el modo del argumento (`min`, `max`, `lattice(P/3)`); si la recursión
    pasa por una negación, escribirla con `tnot/1`; si las respuestas
    dependen de un predicado dinámico, declarar los dos `incremental`. Las
    pruebas comparan las respuestas ordenadas, porque la tabla no tiene un
    orden fijo.

    **Cuándo no usarlo.** Cuando la relación tiene infinitas respuestas
    distintas —un recorrido guardado como lista sobre un grafo con ciclos, un
    contador que crece—: la tabla no se completa nunca. Cuando el predicado
    tiene efectos, que se ejecutarían una vez por tabla y no por llamada.
    Cuando hace falta la primera respuesta pronto: una tabla entrega sus
    respuestas al completarse. Y en un predicado barato y sin repeticiones,
    donde la tabla solo agrega costo ([sección 40.6](incremental.md#406-lo-que-cuesta)).

El capítulo continúa en la página
[Subsunción de respuestas y negación tabulada](subsuncion.md#403-subsuncion-de-respuestas), con
las tablas que guardan solo la mejor respuesta de cada llamada y con la
negación tabulada.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir, con `camino.pl` cargado, si cada consulta termina y
   cuántas respuestas da, y comprobarlo: `camino(c, Y).` ·
   `camino(X, d).` · `camino(X, Y).` · `camino_prolog(c, d).` ·
   `camino_prolog(d, a).`
2. ★ **(2)** El intérprete `resolver_sin_ciclos/1` del
   [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md) abandona una rama cuando encuentra una variante de un
   objetivo antepasado, y pierde a juan en `antepasado_izq(A, eva)`. La
   tabla también detecta variantes. Explicar, paso por paso, qué hace la
   tabla con la variante que el intérprete abandona, y por qué eso no
   pierde respuestas.
3. **(1)** Escribir `suma_hasta/2`, la suma de 1 a N del
   [capítulo 21](../capitulo-21-base-de-datos-dinamica/index.md), tabulada, sin `suma_guardada/2`. ¿Cuántas tablas deja
   `suma_hasta(100, S)`?
4. **(2)** Escribir `formas(Monto, Monedas, N)`: N es la cantidad de formas
   de pagar Monto con monedas de los valores de la lista Monedas, sin
   importar el orden. Tabularlo, y calcular `formas(100, [1, 5, 10, 25, 50],
   N)`. Medir con `time/1` la consulta con y sin la tabla.

## Referencias

- David S. Warren, *Programming in Tabled Prolog*, borrador, Stony Brook
  University, 1999 — capítulos «Tabling and Datalog Programming» y
  «Dynamic Programming in XSB».
  [Edición en línea del autor, en el archivo web](https://web.archive.org/web/20240628211257/https://www3.cs.stonybrook.edu/~warren/xsbbook/book.html).
  Esta página toma de allí la ejecución con tablas descrita por variantes,
  llamadas consumidoras y tablas completas, y la programación dinámica
  escrita como la recursión del problema más la directiva. Warren escribe
  para XSB; los programas del capítulo usan la sintaxis y las primitivas de
  SWI-Prolog.
- Markus Triska, *The Power of Prolog*, capítulo «Memoization».
  [En línea](https://www.metalevel.at/prolog/memoization). De allí viene la
  presentación de la tabla como memorización sin estado escrito a mano y
  como forma de hacer terminar la recursión a la izquierda.
- Jan Wielemaker y otros, *SWI-Prolog Reference Manual*, sección «Tabled
  execution (SLG resolution)».
  [En línea](https://www.swi-prolog.org/pldoc/man?section=tabling). Es la
  referencia de la directiva `table` y de `abolish_all_tables/0`.
