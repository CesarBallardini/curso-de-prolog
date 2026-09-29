# Capítulo 39 — Tabulación

Una relación recursiva escrita con la recursión a la izquierda no termina en
Prolog, y tampoco una que recorre un grafo con ciclos
([sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas)). Una recurrencia como la de Fibonacci termina, pero
resuelve los mismos subproblemas una cantidad exponencial de veces, y la
memorización del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#205-memorizacion) lo evita al precio de un estado escrito
a mano. La **tabulación** resuelve las dos cosas con una directiva:
`:- table p/N` hace que cada llamada a `p/N` guarde sus respuestas en una
tabla, y que una llamada igual a otra que ya está en curso consuma las
respuestas de esa tabla en lugar de volver a resolverse. Las cláusulas no
cambian; cambia la forma de ejecutarlas.

El [capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md) definió lo que un programa significa: el modelo mínimo,
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
los anuncios de los capítulos [16](../capitulo-16-rendimiento/index.md) y [17](../capitulo-17-todas-las-soluciones/index.md) (recordar resultados y
reunir las respuestas de una relación recursiva sin repetirlas), del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md) (la memorización sin estado escrito a mano), del
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md) (la recursión a la izquierda que termina sin perder
respuestas), del [capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md) (una directiva que cambia al cargar cómo
se ejecuta un predicado), del [capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md) (las tablas y los hilos) y
del [capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md) (`tnot/1`, las respuestas indefinidas y el intérprete del
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
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:15 h**.
    Resolver los 6 ejercicios marcados con ★: **1:35 h**.
    Resolver los 15 ejercicios del final: **4:00 h**.

## 39.1 `:- table`: recursión a la izquierda y ciclos

`camino.pl` tiene el grafo del [capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md#381-modelos-y-consecuencia-logica), con un ciclo entre a, b y c,
y la definición de camino con la recursión a la izquierda:

<!-- ejemplo: capitulo-39/camino.pl predicado: arco/2 camino_prolog/2 -->
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

<!-- ejemplo: capitulo-39/camino.pl fragmento: :- table camino/2. .. arco(Z, Y). -->
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
?- camino(a, Y).
Y = b ;
Y = a ;
Y = d ;
Y = c.

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
semi-ingenua de la [sección 38.6](../capitulo-38-semantica-de-los-programas-logicos/index.md#386-evaluacion-de-abajo-hacia-arriba), aplicada solo a lo que la consulta
pide: `camino(a, Y)` no calcula los caminos que salen de b.

Dos consecuencias se leen en la respuesta. El orden de las respuestas es el
de la tabla, no el de las cláusulas, y puede cambiar de una ejecución a
otra: en esta máquina, la misma consulta dio d, b, c, a en otro proceso. Y
la respuesta termina en `.`: la tabla completa no deja alternativas. Las
pruebas de `camino.plt` comparan las respuestas ordenadas con `msort/2`.

La recursión a la izquierda del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md#333-variar-el-interprete) tiene la misma solución.
Allí, `antepasado_izq(A, eva)` daba sus tres respuestas y agotaba la pila, y
el intérprete que abandonaba las variantes terminaba pero perdía a juan,
que estaba a tres generaciones. Con la tabla, la variante no se abandona:
espera las respuestas de la llamada en curso.

<!-- ejemplo: capitulo-39/camino.pl fragmento: :- table antepasado_izq/2. .. padre(H, D). -->
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
?- antepasado_izq(A, eva).
A = ana ;
A = luis ;
A = juan.
```

La directiva se aplica al cargar el archivo, como las expansiones del
[capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md): SWI-Prolog pone delante de las cláusulas un predicado
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

## 39.2 Memorización sin estado escrito a mano

La memorización de la [sección 20.5](../capitulo-20-base-de-datos-dinamica/index.md#205-memorizacion) guarda cada valor de
`fib_memo/2` en un predicado dinámico, lo busca antes de calcularlo, y
necesita un predicado que borre lo guardado ([Patrón 17](../patrones.md#17-memorizacion-con-assertz)). Con la tabla,
la definición recursiva directa basta:

<!-- ejemplo: capitulo-39/fibonacci.pl fragmento: :- table fib_tabla/2. .. F is F1 + F2 -->
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
incrementales de la [sección 39.5](#395-tabulacion-incremental).

La tabla no es solo una memoria de valores: `fib_tabla/2` es una función,
pero la directiva se aplica igual a una relación con varias respuestas por
llamada, que un `->` como el de `fib_memo/2` no guardaría. La programación
dinámica, en la que cada subproblema se resuelve una vez y su resultado se
reutiliza, se escribe como la recursión que define el problema, más la
directiva (Warren, capítulo «Dynamic Programming in XSB»). `caminos_grilla/3`
cuenta los recorridos de una grilla que solo avanzan hacia abajo o hacia la
derecha: los que llegan a una celda son los que llegan a la de arriba más
los que llegan a la de la izquierda.

<!-- ejemplo: capitulo-39/fibonacci.pl fragmento: :- table caminos_grilla/3. .. N is N1 + N2. -->
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
    donde la tabla solo agrega costo ([sección 39.6](#396-lo-que-cuesta)).

## 39.3 Subsunción de respuestas

Una relación con infinitas respuestas distintas no completa su tabla: la
suma de las longitudes de los recorridos de un grafo con un ciclo crece con
cada vuelta. Si solo interesa la mejor respuesta, la directiva declara un
**modo** para un argumento, y la tabla guarda solo el mejor valor. La página
[Subsunción de respuestas](subsuncion.md#subsuncion-de-respuestas) calcula la
distancia más corta con `:- table distancia(_, _, min)` y el recorrido más
corto con un reticulado, `lattice(mas_corta/3)`, y presenta los demás modos
y la condición que imponen: el argumento con modo debe llegar libre.

## 39.4 Negación tabulada

El juego de la [sección 38.5](../capitulo-38-semantica-de-los-programas-logicos/index.md#385-la-semantica-bien-fundada) define las posiciones ganadoras con su propia
negación: una posición gana si hay un movimiento a una posición que no gana
para el rival. `juego.pl` tiene los dos juegos de aquel capítulo:

<!-- ejemplo: capitulo-39/juego.pl predicado: mueve/3 gana_prolog/2 -->
```prolog
% mueve(Juego, X, Y): en Juego, un jugador puede pasar de la posición X a
% la posición Y.
mueve(j1, a, b).
mueve(j1, b, a).
mueve(j1, b, c).
mueve(j2, a, b).
mueve(j2, b, a).
mueve(j2, b, c).
mueve(j2, c, d).

%!  gana_prolog(?Juego, ?X) is nondet.
%
%   En Juego, quien mueve desde X gana, con la negación de Prolog. Con los
%   ciclos de a y b, la consulta no termina.
gana_prolog(J, X) :-
    mueve(J, X, Y),
    \+ gana_prolog(J, Y).
```

Con `\+`, Prolog termina solo donde no hay ciclos: `gana_prolog(j2, c)` es
verdadero, porque desde d no hay movimientos, pero `gana_prolog(j1, a)` va de
a a b y de b a a sin fin.

```text
?- gana_prolog(j1, a).
ERROR: Stack limit (1.0Gb) exceeded
```

La tabla no alcanza: `\+` sobre una llamada tabulada en curso no puede
esperar a que se complete. La negación tabulada, `tnot/1`, sí: suspende la
llamada que niega hasta que la tabla del objetivo negado está completa, y
si el objetivo depende a su vez de esa negación, **demora** el literal en
lugar de decidirlo.

<!-- ejemplo: capitulo-39/juego.pl fragmento: :- table gana/2. .. tnot(gana(J, Y)). -->
```prolog
:- table gana/2.

%!  gana(?Juego, ?X) is nondet.
%
%   En Juego, quien mueve desde X gana: puede pasar a una posición desde la
%   que el rival no gana. Las posiciones de empate son respuestas
%   indefinidas.
gana(J, X) :-
    mueve(J, X, Y),
    tnot(gana(J, Y)).
```

```prolog
?- gana(j1, X).
X = b.

?- gana(j2, c).
true.
```

El juego j1 no tiene empates, y la respuesta es la del razonamiento de la
[sección 38.5](../capitulo-38-semantica-de-los-programas-logicos/index.md#385-la-semantica-bien-fundada): b gana, a y c pierden. En j2, las posiciones a y b se
pasan la jugada sin fin, y la semántica bien fundada las deja
**indefinidas**. La consulta `gana(j2, a)` termina, y responde así:

```text
% WFS residual program
    gana(j2, a) :-
        tnot(gana(j2, b)).
    gana(j2, b) :-
        tnot(gana(j2, a)).
gana(j2, a).
```

La respuesta es **condicional**: `gana(j2, a)` se prueba solo si
`gana(j2, b)` no gana, y esa condición depende a su vez de la primera. Las
cláusulas que la preceden son el **programa residual**: lo que queda del
programa después de evaluar todo lo que se pudo decidir. Una respuesta
verdadera no tiene condiciones y se escribe `true.`; una falsa, `false.`; una
indefinida se escribe con su programa residual.

`findall/3` recoge las respuestas condicionales como a las demás, sin
distinguirlas: `findall(X, gana(j2, X), Xs)` da a, b y c. `call_delays/2`
ejecuta una meta y liga su segundo argumento a la condición de cada
respuesta, `true` si no tiene ninguna. `valor/2` lo usa para clasificar una
meta sin variables:

<!-- ejemplo: capitulo-39/juego.pl predicado: valor/2 -->
```prolog
%!  valor(+Meta, -Valor) is det.
%
%   Valor es verdadero, falso o indefinido: el de Meta, tabulada y sin
%   variables, en la semántica bien fundada. Una respuesta sin condiciones
%   hace verdadera la meta; si todas tienen condiciones, es indefinida.
valor(Meta, Valor) :-
    must_be(ground, Meta),
    findall(Condicion, call_delays(Meta, Condicion), Condiciones),
    (   Condiciones == []
    ->  Valor = falso
    ;   memberchk(true, Condiciones)
    ->  Valor = verdadero
    ;   Valor = indefinido
    ).
```

```prolog
?- findall(X-V, (member(X, [a, b, c, d]), valor(gana(j2, X), V)), Vs).
Vs = [a-indefinido, b-indefinido, c-verdadero, d-falso].
```

Son los valores que calcula `bien_fundado/3` en la [sección 38.5](../capitulo-38-semantica-de-los-programas-logicos/index.md#385-la-semantica-bien-fundada), con el
punto fijo alternado sobre el programa entero; la tabulación los obtiene de
arriba hacia abajo, a partir de la consulta. SWI-Prolog implementa la
semántica bien fundada completa, la de XSB (Warren, capítulo «Negation in
XSB»): en un programa estratificado, `tnot/1` da lo mismo que `\+` y no deja
respuestas indefinidas; en uno que no lo es, las respuestas que dependen de
un ciclo negativo quedan indefinidas, y las demás son verdaderas o falsas.
`tnot/1` exige un objetivo tabulado: `tnot(mueve(j1, a, b))` produce un
error de permiso, porque `mueve/3` no tiene tabla. Con variables libres no
produce un error: como `\+` ([capítulo 10](../capitulo-10-negacion-como-falla/index.md)), responde si la meta no tiene
ninguna respuesta, sin ligar las variables, y `tnot(gana(j2, X))` falla
porque alguna posición gana.

!!! question "Actividad"
    Predecir el valor de `gana(j2, X)` para cada posición si se agrega el
    movimiento `mueve(j2, d, a)`, y explicar qué cambia en el empate.
    Comprobarlo con `valor/2` en una copia de `juego.pl` con el hecho
    agregado.

## 39.5 Tabulación incremental

Una tabla común no se actualiza cuando cambian los datos de los que
dependen sus respuestas: después de un `assertz/1` sigue respondiendo con lo que guardó.
La página [Tablas incrementales, hilos y costo](incremental.md#tabulacion-incremental)
declara un predicado dinámico y la tabla que depende de él como
`incremental`, de modo que agregar o quitar un hecho invalida las tablas
afectadas y la próxima consulta las recalcula, y muestra que las tablas son
de cada hilo, salvo las que se declaran `shared`.

## 39.6 Lo que cuesta

Una tabla cuesta inferencias y memoria. La misma página, en
[Lo que cuesta](incremental.md#lo-que-cuesta), mide en esta máquina una
relación sobre una red sin ciclos, con y sin tabla, y con la recursión a
cada lado: la tabla multiplica por más de dos el trabajo de una consulta que
Prolog ya resolvía, y la recursión a la derecha crea una tabla por nodo, con
más de cuarenta veces el trabajo y doscientas cincuenta veces la memoria de la
recursión a la izquierda sobre 500 enlaces.

## 39.7 El intérprete con tablas; las correlativas

### El sistema experto

La [sección 38.7](../capitulo-38-semantica-de-los-programas-logicos/index.md#387-las-reglas-del-sistema-experto) analizó las reglas del sistema experto con la
negación `no`: la base original es estratificada, y la versión que agrega
r13, «un ave que no es pingüino ni avestruz vuela», crea un ciclo positivo
con r4 (`ave`, `vuela`, `ave`) y dos negativos con r11 y r12. El intérprete
del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md#337-el-sistema-experto-explica), que resuelve de arriba hacia abajo, entra en el
ciclo positivo con cualquier caso. Tiene además un costo menos visible:
cada hipótesis vuelve a probar las conclusiones intermedias, y `mamifero` se
prueba una vez para el guepardo, otra para el tigre, otra para la jirafa.
El encadenamiento hacia adelante del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md) evitaba esa repetición
guardando cada conclusión con `assertz/1`.

`experto.pl` tiene las reglas, las versiones de la base y el intérprete sin
tabla, `probar_sin_tabla/3`, con `\+` para `no`. La versión tabulada separa
el intérprete en dos predicados: `probar/3` recorre las condiciones, y
`cierto/3`, tabulado, prueba cada conclusión una vez por conjunto de
observaciones:

<!-- ejemplo: capitulo-39/experto.pl predicado: probar/3 -->
```prolog
%!  probar(+Version:atom, +Observaciones:list, +Condicion) is nondet.
%
%   Condicion se prueba con las reglas de Version y las Observaciones. Cada
%   conclusión se busca en la tabla de cierto/3, y la negación es tnot/1.
probar(Version, Os, A y B) :-
    probar(Version, Os, A),
    probar(Version, Os, B).
probar(_, _, X > Y) :-
    X > Y.
probar(Version, Os, no A) :-
    tnot(cierto(Version, Os, A)).
probar(Version, Os, Meta) :-
    atomica(Meta),
    cierto(Version, Os, Meta).
```

<!-- ejemplo: capitulo-39/experto.pl fragmento: :- table cierto/3. .. probar(Version, Os, Condiciones). -->
```prolog
:- table cierto/3.

%!  cierto(+Version:atom, +Observaciones:list, ?Meta) is nondet.
%
%   Meta es una observación, o la conclusión de una regla de Version cuyas
%   condiciones se prueban. Las respuestas que dependen de un ciclo
%   negativo quedan indefinidas.
cierto(_, Os, Meta) :-
    member(Meta, Os).
cierto(Version, Os, Meta) :-
    regla_de(Version, _, si Condiciones entonces Meta),
    probar(Version, Os, Condiciones).
```

La tabla es la de la memorización a mano y la del encadenamiento hacia
adelante, sin predicados dinámicos que borrar entre dos consultas: las
observaciones son un argumento, y cada conjunto de observaciones tiene sus
propias tablas. La negación `no` es `tnot/1`, y la conclusión negada tiene
que ser un átomo sin variables, como lo son todas las de la base.
`diagnostico/3` clasifica las hipótesis con el `valor/2` de la
[sección 39.4](#394-negacion-tabulada):

<!-- ejemplo: capitulo-39/experto.pl predicado: diagnostico/3 -->
```prolog
%!  diagnostico(+Version:atom, +Observaciones:list, -Resultado) is det.
%
%   Resultado es resultado(Verdaderas, Indefinidas): las hipótesis
%   verdaderas y las indefinidas con las reglas de Version y las
%   Observaciones.
diagnostico(Version, Os, resultado(Verdaderas, Indefinidas)) :-
    must_be(oneof([original, vuela, puede_volar]), Version),
    findall(H-V,
            ( hipotesis(H),
              valor(cierto(Version, Os, H), V) ),
            Valores),
    findall(H, member(H-verdadero, Valores), Verdaderas),
    findall(H, member(H-indefinido, Valores), Indefinidas).
```

```prolog
?- diagnostico(original, [tiene_plumas, nada, peso(30)], R).
R = resultado([pinguino], []).

?- diagnostico(vuela, [tiene_plumas, nada, peso(30)], R).
R = resultado([], [pinguino]).

?- diagnostico(vuela, [tiene_pelo, come_carne, color_leonado, manchas_oscuras], R).
R = resultado([guepardo], []).
```

Son los resultados del modelo bien fundado de la [sección 38.7](../capitulo-38-semantica-de-los-programas-logicos/index.md#387-las-reglas-del-sistema-experto): con la
base original, el ave que nada y pesa 30 es un pingüino; con r13, queda
indefinida. El tercer caso es el que el intérprete sin tabla no podía
responder: para descartar `pinguino`, prueba `ave`, que por r4 necesita
`vuela`, que por r13 necesita `ave`. Con la tabla, la llamada a `ave`
dentro de su propia prueba es una variante en curso, consume las respuestas
que haya —ninguna— y la tabla se completa vacía: `ave` es falsa para un
guepardo, y el ciclo positivo termina.

```prolog
?- call_with_inference_limit(probar_sin_tabla(vuela, [tiene_pelo, come_carne, color_leonado, manchas_oscuras], pinguino), 1000000, R).
R = inference_limit_exceeded.
```

El precio es el árbol de prueba: `cierto/3` responde si una conclusión se
prueba, pero no guarda cómo, y el «¿cómo?» del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md) necesita
reconstruirlo. El [ejercicio 15](#ejercicios) lo hace, usando la tabla para
elegir solo reglas cuyas condiciones son verdaderas.

### *Inscripciones*: la cadena de correlativas

El módulo `reglas` del [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md#318-el-proyecto-inscripciones-se-entrega) calcula los requisitos de una materia
con `requisito/2`, la clausura transitiva de `correlativa/2`, y guarda cada
resultado en el predicado dinámico `requisitos_guardados/2`: es el
[Patrón 17](../patrones.md#17-memorizacion-con-assertz) aplicado a una relación. `requisito/2` da una respuesta por
cada cadena de correlativas, y bases de datos tiene a lógica como requisito
por dos caminos, por paradigmas y por sintaxis; por eso `requisitos_de/2`
ordena el resultado con `sort/2` antes de guardarlo. `requisitos.pl` es un
módulo que usa los datos del [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md) y reemplaza las dos cosas por una
tabla:

<!-- ejemplo: capitulo-39/requisitos.pl fragmento: :- table requisito/2. .. correlativa(Intermedia, Requisito). -->
```prolog
:- table requisito/2.

%!  requisito(?Materia:atom, ?Requisito:atom) is nondet.
%
%   La misma relación, tabulada: una respuesta por requisito.
requisito(Materia, Requisito) :-
    correlativa(Materia, Requisito).
requisito(Materia, Requisito) :-
    requisito(Materia, Intermedia),
    correlativa(Intermedia, Requisito).
```

<!-- ejemplo: capitulo-39/requisitos.pl predicado: requisito_sin_tabla/2 requisitos_de/2 -->
```prolog
%!  requisito_sin_tabla(+Materia:atom, -Requisito:atom) is nondet.
%
%   Requisito es una correlativa de Materia, o una correlativa de una de
%   ellas. Una respuesta por cada camino de correlativas.
requisito_sin_tabla(Materia, Requisito) :-
    correlativa(Materia, Requisito).
requisito_sin_tabla(Materia, Requisito) :-
    correlativa(Materia, Intermedia),
    requisito_sin_tabla(Intermedia, Requisito).

%!  requisitos_de(+Materia:atom, -Requisitos:list(atom)) is det.
%
%   Requisitos son todas las materias que hay que aprobar antes de cursar
%   Materia, directa o indirectamente, en orden y sin repetidos.
requisitos_de(Materia, Requisitos) :-
    must_be(atom, Materia),
    findall(R, requisito(Materia, R), Todos),
    sort(Todos, Requisitos).
```

```prolog
?- findall(R, requisito_sin_tabla(bd, R), Rs).
Rs = [pp, ssl, log, log, alg].

?- requisitos_de(bd, Rs).
Rs = [alg, log, pp, ssl].
```

La tabla da cada requisito una vez, sin el estado de
`requisitos_guardados/2`, y la prueba `como_el_31` de `requisitos.plt`
compara el resultado con el del módulo `reglas` para cada materia. Dos
propiedades se obtienen sin agregar nada: la relación se consulta también en sentido
inverso, `requisito(M, log)` da las materias que exigen lógica, y un plan de
estudios con un ciclo de correlativas, que es un error de los datos, no
impide que la consulta termine. El `sort/2` de `requisitos_de/2` sigue haciendo falta,
pero para el orden, no para quitar repetidos.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; los que tienen un argumento con modo de subsunción dicen que debe llegar libre, y el error de desinstanciación está probado |
    | C3 | las definiciones tabuladas son las cláusulas de la relación sin cambios de orden ni argumentos de control: `camino/2`, `requisito/2` y `cierto/3` se consultan en cualquier modo, incluido el inverso |
    | C6 | ninguna tabla tiene efectos en sus cláusulas; el único estado es el de `incremental.pl` y `costo.pl`, en predicados de borde con nombre propio (`restaurar/0`, `cadena/1`) que también borran las tablas |
    | C7 | 69 pruebas en nueve archivos; comparan las respuestas ordenadas, porque una tabla no tiene orden fijo; cada versión tabulada se compara con la que no lo está donde esta termina (`requisitos_de/2` con el del [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md), `fib_tabla/2` con `fib/2`), y lo que no termina se prueba con `call_with_inference_limit/3`, sin depender del tiempo de la máquina |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir, con `camino.pl` cargado, si cada consulta termina y
   cuántas respuestas da, y comprobarlo: `camino(c, Y).` ·
   `camino(X, d).` · `camino(X, Y).` · `camino_prolog(c, d).` ·
   `camino_prolog(d, a).`
2. **(1)** Escribir `camino_der/2`, la relación de camino con la
   recursión a la derecha, tabulada. ¿Da las mismas respuestas que
   `camino/2`? Contar con `current_table/2` cuántas tablas deja
   `camino_der(a, Y)` y cuántas `camino(a, Y)`, y explicar la diferencia.
3. ★ **(2)** El intérprete `resolver_sin_ciclos/1` del
   [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md) abandona una rama cuando encuentra una variante de un
   objetivo antepasado, y pierde a juan en `antepasado_izq(A, eva)`. La
   tabla también detecta variantes. Explicar, paso por paso, qué hace la
   tabla con la variante que el intérprete abandona, y por qué eso no
   pierde respuestas.
4. **(1)** Escribir `suma_hasta/2`, la suma de 1 a N del
   [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md), tabulada, sin `suma_guardada/2`. ¿Cuántas tablas deja
   `suma_hasta(100, S)`?
5. **(2)** Escribir `formas(Monto, Monedas, N)`: N es la cantidad de formas
   de pagar Monto con monedas de los valores de la lista Monedas, sin
   importar el orden. Tabularlo, y calcular `formas(100, [1, 5, 10, 25, 50],
   N)`. Medir con `time/1` la consulta con y sin la tabla.
6. ★ **(2)** Predecir las respuestas de `distancia(b, Y, D)` y de
   `ruta(b, a, R)`, y comprobarlas. Después, reemplazar `min` por `max` en
   una copia de `distancia/3`: ¿termina la consulta? Explicar por qué `min`
   termina en un grafo con ciclos y longitudes positivas y `max` no.
7. **(2)** Escribir `saltos(X, Y, N)`: N es la menor cantidad de tramos de
   un recorrido de X a Y en el grafo de `distancias.pl`, con el modo `min`.
   ¿Es el recorrido de menos tramos el más corto? Dar un par de nodos donde
   no lo sea.
8. **(2)** Escribir `ruta_mas_larga/3` con `lattice` sobre un grafo **sin**
   ciclos, `dag/3`, y explicar por qué la misma definición no terminaría en
   el grafo de `tramo/3`.
9. ★ **(2)** Agregar a `juego.pl` un juego j3, igual a j2 más el
   movimiento `mueve(j3, a, e)`, sin movimientos desde e. Predecir el valor
   de `gana(j3, X)` para cada posición y comprobarlo con `valor/2`. ¿Queda
   algún empate?
10. **(2)** Predecir el valor de p, q y r en el programa `p :- tnot(q).`,
    `q :- tnot(p).`, `r :- tnot(r).`, con los tres predicados tabulados, y
    comprobarlo con `valor/2`. ¿Qué hace la consulta `r` si se escribe con
    `\+` y sin tabla?
11. **(1)** Explicar el error de `tnot(mueve(j1, a, b))` y el de
    `valor(gana(j2, X), V)`, y la respuesta de `tnot(gana(j2, X))`. ¿Por qué
    `tnot/1` no admite un objetivo sin tabla, y por qué `valor/2` exige una
    meta sin variables?
12. ★ **(2)** Con `incremental.pl` cargado, predecir las respuestas de
    `alcanza(c, Y)` y de `alcanza_fijo(c, Y)` después de
    `assertz(enlace(c, a))`, y después de un `retract(enlace(a, b))`.
    Comprobarlo, y decir qué hace falta para que `alcanza_fijo/2` quede al
    día.
13. **(2)** Con `costo.pl` y `cadena(500)`, medir con `time/1`
    `aggregate_all(count, alcanza_izq(_, 500), N)` y lo mismo con
    `alcanza_der/2` y con `alcanza_sin_tabla/2`, y contar las tablas.
    Explicar por qué el resultado se invierte respecto de la consulta
    `alcanza_*(0, _)` de la [sección 39.6](#396-lo-que-cuesta).
14. ★ **(2)** Escribir, en un módulo que use los del
    [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md), `habilita(Materia, Otra)`, tabulado: aprobar Materia
    es necesario, directa o indirectamente, para cursar Otra. Escribir
    después `materias_habilitadas(Legajo, Ms)`: las materias que el alumno
    todavía no aprobó ni cursa y cuyos requisitos aprobó todos.
15. **(3)** Escribir `como_tabulado(Version, Observaciones, Meta, Arbol)`,
    que construye el árbol de prueba de una conclusión verdadera con las
    formas `observado(M)`, `deducido(M, Regla, Arbol)`, `A y B` y `X > Y`
    del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md). Usar `cierto/3` para elegir solo reglas cuyas
    condiciones son verdaderas, y evitar que el ciclo de r4 y r13 dé un
    árbol infinito.

## Resumen

| | |
|---|---|
| **tabulación** | cada llamada guarda sus respuestas en una tabla; una variante de una llamada en curso consume la tabla en lugar de resolverse de nuevo |
| **variante** | una llamada igual a otra salvo el nombre de sus variables |
| **tabla completa** | ninguna llamada consumidora tiene respuestas nuevas que usar; recién entonces se entregan las respuestas |
| **resolución SLG** | la resolución con tablas y negación tabulada que implementa SWI-Prolog |
| **subsunción de respuestas** | un modo en un argumento guarda solo la mejor respuesta: `min`, `max`, `first`, `last`, `sum`, `lattice(P/3)`, `po(P/2)` |
| **respuesta condicional** | una respuesta indefinida, con el programa residual que la condiciona |
| **tabla incremental** | se invalida cuando cambia un predicado dinámico declarado `incremental` del que depende |
| `:- table p/N` | tabular un predicado; `:- table p(_, _, min)` con modos; `as incremental`, `as shared` |
| `:- dynamic p/N as incremental` | un predicado dinámico que invalida las tablas incrementales que dependen de él |
| `tnot/1` | la negación de un objetivo tabulado y sin variables, con la semántica bien fundada |
| `call_delays/2` | ejecuta una meta y da la condición de cada respuesta, `true` si no tiene |
| `abolish_all_tables/0` | borra todas las tablas |
| `current_table/2` | enumera las tablas existentes |
| bandera `table_space_used` de `statistics/2` | los bytes que ocupan las tablas |
| `camino/2`, `antepasado_izq/2` | la recursión a la izquierda tabulada |
| `fib_tabla/2`, `caminos_grilla/3` | memorización y programación dinámica con tablas |
| `distancia/3`, `ruta/3`, `mas_corta/3` | la distancia mínima con `min` y el recorrido más corto con `lattice` |
| `gana/2`, `valor/2` | el juego con `tnot/1`, y el valor de una meta en la semántica bien fundada |
| `alcanza/2`, `fib_compartida/2`, `cadena/1`, `tablas/1` | una tabla incremental, una compartida, y la medición del costo |
| `cierto/3`, `probar/3`, `diagnostico/3` | el intérprete del sistema experto con tablas |
| `requisito/2`, `requisitos_de/2` | la cadena de correlativas de *Inscripciones*, tabulada |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Conjuntos de visitados y búsqueda en grafos de estados | [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) |
| Tablas de transposición con tabulación | [capítulo 41](../capitulo-41-juegos/index.md) |
| `WITH RECURSIVE` frente a la tabulación | [capítulo 42](../capitulo-42-prolog-y-sql/index.md) |
| La clausura ε de un autómata, tabulada | [capítulo 51](../capitulo-51-proyecto-automatas-expresiones-regulares/index.md) |
| Análisis estático con tablas | [capítulo 58](../capitulo-58-proyecto-interpretacion-abstracta/index.md) |
| Un motor Datalog, de abajo hacia arriba, comparado con las tablas | [capítulo 85](../capitulo-85-proyecto-motor-datalog/index.md) |
| Preguntas en castellano evaluadas con tablas | [capítulo 87](../capitulo-87-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- David S. Warren, *Programming in Tabled Prolog*, borrador, Stony Brook
  University, 1999 — capítulos «Tabling and Datalog Programming»,
  «Dynamic Programming in XSB», «Aggregation» y «Negation in XSB».
  [Edición en línea del autor, en el archivo web](https://web.archive.org/web/20240628211257/https://www3.cs.stonybrook.edu/~warren/xsbbook/book.html).
  El capítulo toma de allí la ejecución con tablas descrita por variantes,
  llamadas consumidoras y tablas completas; la programación dinámica
  escrita como la recursión del problema más la directiva; la agregación
  por subsunción de respuestas; la negación tabulada con la semántica bien
  fundada; y el análisis de la cantidad de tablas según la dirección de la
  recursión. Warren escribe para XSB; los programas del capítulo usan la
  sintaxis y las primitivas de SWI-Prolog.
- Markus Triska, *The Power of Prolog*, capítulo «Memoization».
  [En línea](https://www.metalevel.at/prolog/memoization). De allí viene la
  presentación de la tabla como memorización sin estado escrito a mano y
  como forma de hacer terminar la recursión a la izquierda.
- Jan Wielemaker y otros, *SWI-Prolog Reference Manual*, sección «Tabled
  execution (SLG resolution)», con sus apartados sobre la subsunción de
  respuestas, la semántica bien fundada, la tabulación incremental y las
  tablas compartidas.
  [En línea](https://www.swi-prolog.org/pldoc/man?section=tabling). Es la
  referencia de las directivas, de `tnot/1`, `call_delays/2`,
  `abolish_all_tables/0` y `current_table/2`, y de los modos `min`, `max`,
  `lattice` y `po`.

Los programas del capítulo son propios, escritos para el curso: el grafo,
el juego y las reglas del sistema experto vienen de los capítulos
[33](../capitulo-33-introspeccion-y-metainterpretes/index.md) y
[38](../capitulo-38-semantica-de-los-programas-logicos/index.md), las
correlativas del [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md),
y las mediciones se hicieron en esta máquina con SWI-Prolog 9.2.9.
