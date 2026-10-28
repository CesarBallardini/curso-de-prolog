# Subsunción de respuestas y negación tabulada

Esta página continúa el [capítulo 40](index.md) después de la
[sección 40.2](index.md#402-memorizacion-sin-estado-escrito-a-mano), con las
secciones [40.3](#403-subsuncion-de-respuestas) y
[40.4](#404-negacion-tabulada): las tablas que guardan, para cada llamada,
solo la mejor respuesta según un modo declarado en la directiva, y la
negación tabulada, que deja indefinidas las posiciones de empate de un
juego. Los ejemplos están en `distancias.pl` y `juego.pl`, en
`ejemplos/capitulo-40/`, con sus pruebas, y corren en SWISH.

## 40.3 Subsunción de respuestas

`distancias.pl` tiene un grafo con longitudes y un ciclo, de d a a:

<!-- ejemplo: capitulo-40/distancias.pl predicado: tramo/3 -->
```prolog
% tramo(X, Y, D): hay un tramo de X a Y de longitud D.
tramo(a, b, 4).
tramo(a, c, 1).
tramo(c, b, 2).
tramo(b, d, 5).
tramo(d, a, 3).
```

La suma de las longitudes de un recorrido, tabulada como en la
[sección 40.1](index.md#401-table-recursion-a-la-izquierda-y-ciclos), no termina:

<!-- ejemplo: capitulo-40/distancias.pl fragmento: :- table suma_tramos/3. .. D is D0 + D1. -->
```prolog
:- table suma_tramos/3.

%!  suma_tramos(?X, ?Y, -D:integer) is nondet.
%
%   Hay un recorrido de X a Y de longitud D. Con el ciclo, hay infinitas
%   respuestas y la consulta no termina.
suma_tramos(X, Y, D) :-
    tramo(X, Y, D).
suma_tramos(X, Y, D) :-
    suma_tramos(X, Z, D0),
    tramo(Z, Y, D1),
    D is D0 + D1.
```

Cada vuelta al ciclo da un recorrido más largo, con una longitud que no está
en la tabla: `suma_tramos(a, b, D)` tiene las respuestas 3, 4, 14, 15, 16, 25, …
y la tabla nunca se completa. Como SWI-Prolog entrega las respuestas de una
tabla cuando la completa, ni siquiera `limit/2` obtiene las primeras:

```prolog
?- call_with_inference_limit(suma_tramos(a, b, _), 1000000, R).
R = inference_limit_exceeded.
```

Para la distancia más corta alcanza con guardar, para cada par de nodos, la
menor longitud. Es la **subsunción de respuestas**: la directiva declara un
**modo** para un argumento, y una respuesta nueva reemplaza a la guardada
solo si es mejor según ese modo (Warren, capítulo «Aggregation»):

<!-- ejemplo: capitulo-40/distancias.pl fragmento: :- table distancia(_, _, min). .. D is D0 + D1. -->
```prolog
:- table distancia(_, _, min).

%!  distancia(?X, ?Y, -D:integer) is nondet.
%
%   D es la longitud del recorrido más corto de X a Y. D debe llegar libre.
distancia(X, Y, D) :-
    tramo(X, Y, D).
distancia(X, Y, D) :-
    distancia(X, Z, D0),
    tramo(Z, Y, D1),
    D is D0 + D1.
```

Los argumentos marcados `_` son los que distinguen una tabla de otra, y el
tercero, `min`, guarda el menor valor. Una longitud mayor que la guardada
no es una respuesta nueva, y el ciclo deja de producir respuestas:

```prolog
?- findall(Y-D, distancia(a, Y, D), Ps), msort(Ps, Ordenadas).
Ps = [b-3, a-11, c-1, d-8],
Ordenadas = [a-11, b-3, c-1, d-8].
```

De a a b hay un tramo de 4, pero el recorrido por c mide 3. Los modos de
SWI-Prolog son `min`, `max`, `first`, `last`, `sum`, `lattice(P/3)` y
`po(P/2)`. El argumento con modo debe llegar **libre**: la consulta
`distancia(a, b, 3)` produce un error de desinstanciación, porque una tabla
con el mínimo no puede decidir si 3 es una respuesta antes de completarse.

`lattice(P/3)` elige con un predicado propio: P recibe dos respuestas y da
la que se guarda. `ruta/3` guarda la longitud y los nodos del recorrido, y
`mas_corta/3` elige:

<!-- ejemplo: capitulo-40/distancias.pl fragmento: :- table ruta(_, _, lattice(mas_corta/3)). .. append(Nodos0, [Y], Nodos). -->
```prolog
:- table ruta(_, _, lattice(mas_corta/3)).

%!  ruta(?X, ?Y, -R) is nondet.
%
%   R es D-Nodos: el recorrido más corto de X a Y, con su longitud D y la
%   lista de sus nodos. R debe llegar libre.
ruta(X, Y, D-[X, Y]) :-
    tramo(X, Y, D).
ruta(X, Y, D-Nodos) :-
    ruta(X, Z, R0),
    R0 = D0-Nodos0,
    tramo(Z, Y, D1),
    D is D0 + D1,
    append(Nodos0, [Y], Nodos).
```

<!-- ejemplo: capitulo-40/distancias.pl predicado: mas_corta/3 -->
```prolog
%!  mas_corta(+R1, +R2, -R) is det.
%
%   R es la más corta de las rutas R1 y R2, de la forma D-Nodos; con
%   longitudes iguales, R1.
mas_corta(D1-N1, D2-N2, R) :-
    (   D1 =< D2
    ->  R = D1-N1
    ;   R = D2-N2
    ).
```

```prolog
?- ruta(a, d, R).
R = 8-[a, c, b, d].
```

La segunda cláusula llama a `ruta(X, Z, R0)` con R0 libre y lo descompone
después: por la misma razón que antes, la llamada tabulada no puede recibir
el argumento con modo a medio instanciar, `D0-Nodos0`. Con la lista de nodos
en la respuesta, la tabla sin modo tampoco terminaría, porque cada vuelta al
ciclo es una lista distinta; con el reticulado, termina.

!!! question "Actividad"
    Predecir las respuestas de `distancia(b, Y, D)` y la de `ruta(b, a,
    R)`, siguiendo los tramos a mano. Comprobarlas, y explicar por qué
    `distancia(b, b, D)` tiene respuesta aunque no haya un tramo de b a b.

## 40.4 Negación tabulada

El juego de la [sección 39.5](../capitulo-39-semantica-de-los-programas-logicos/negacion.md#395-la-semantica-bien-fundada) define las posiciones ganadoras con su propia
negación: una posición gana si hay un movimiento a una posición que no gana
para el rival. `juego.pl` tiene los dos juegos de aquel capítulo:

<!-- ejemplo: capitulo-40/juego.pl predicado: mueve/3 gana_prolog/2 -->
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

<!-- ejemplo: capitulo-40/juego.pl fragmento: :- table gana/2. .. tnot(gana(J, Y)). -->
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
[sección 39.5](../capitulo-39-semantica-de-los-programas-logicos/negacion.md#395-la-semantica-bien-fundada): b gana, a y c pierden. En j2, las posiciones a y b se
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

<!-- ejemplo: capitulo-40/juego.pl predicado: valor/2 -->
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

Son los valores que calcula `bien_fundado/3` en la [sección 39.5](../capitulo-39-semantica-de-los-programas-logicos/negacion.md#395-la-semantica-bien-fundada), con el
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

El capítulo continúa en la página
[Tablas incrementales, hilos, costo y el intérprete con tablas](incremental.md#405-tabulacion-incremental),
con las tablas que siguen los cambios de un predicado dinámico, lo que
cuesta una tabla y dos aplicaciones de la tabulación.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

5. ★ **(2)** Predecir las respuestas de `distancia(b, Y, D)` y de
   `ruta(b, a, R)`, y comprobarlas. Después, reemplazar `min` por `max` en
   una copia de `distancia/3`: ¿termina la consulta? Explicar por qué `min`
   termina en un grafo con ciclos y longitudes positivas y `max` no.
6. **(2)** Escribir `saltos(X, Y, N)`: N es la menor cantidad de tramos de
   un recorrido de X a Y en el grafo de `distancias.pl`, con el modo `min`.
   ¿Es el recorrido de menos tramos el más corto? Dar un par de nodos donde
   no lo sea.
7. **(2)** Escribir `ruta_mas_larga/3` con `lattice` sobre un grafo **sin**
   ciclos, `dag/3`, y explicar por qué la misma definición no terminaría en
   el grafo de `tramo/3`.
8. ★ **(2)** Agregar a `juego.pl` un juego j3, igual a j2 más el
   movimiento `mueve(j3, a, e)`, sin movimientos desde e. Predecir el valor
   de `gana(j3, X)` para cada posición y comprobarlo con `valor/2`. ¿Queda
   algún empate?
9. **(2)** Predecir el valor de p, q y r en el programa `p :- tnot(q).`,
    `q :- tnot(p).`, `r :- tnot(r).`, con los tres predicados tabulados, y
    comprobarlo con `valor/2`. ¿Qué hace la consulta `r` si se escribe con
    `\+` y sin tabla?
10. **(1)** Explicar el error de `tnot(mueve(j1, a, b))` y el de
    `valor(gana(j2, X), V)`, y la respuesta de `tnot(gana(j2, X))`. ¿Por qué
    `tnot/1` no admite un objetivo sin tabla, y por qué `valor/2` exige una
    meta sin variables?

## Referencias

- David S. Warren, *Programming in Tabled Prolog*, borrador, Stony Brook
  University, 1999 — capítulos «Aggregation» y «Negation in XSB».
  [Edición en línea del autor, en el archivo web](https://web.archive.org/web/20240628211257/https://www3.cs.stonybrook.edu/~warren/xsbbook/book.html).
  Esta página toma de allí la agregación por subsunción de respuestas y la
  negación tabulada con la semántica bien fundada. Warren escribe para XSB;
  los programas del capítulo usan la sintaxis y las primitivas de
  SWI-Prolog.
- Jan Wielemaker y otros, *SWI-Prolog Reference Manual*, sección «Tabled
  execution (SLG resolution)», con sus apartados sobre la subsunción de
  respuestas y la semántica bien fundada.
  [En línea](https://www.swi-prolog.org/pldoc/man?section=tabling). Es la
  referencia de `tnot/1` y `call_delays/2`, y de los modos `min`, `max`,
  `lattice` y `po`.
