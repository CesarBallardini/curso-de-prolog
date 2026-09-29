# Soluciones del capítulo 34 — Estructuras incompletas y listas diferencia

El código de esta página está en `ejemplos/capitulo-34/soluciones.pl` y
`soluciones_simbolos.pl`, en el mismo directorio, y pasa sus pruebas.
`soluciones.pl` repite las definiciones de los ejemplos que usan los
ejercicios 1 a 12 —`conocidos/2`, las listas diferencia, la cola con contador y
los dos diccionarios—; `soluciones_simbolos.pl` contiene el ensamblador de
`simbolos.pl` con los cambios de los ejercicios 13 y 14, para que cada archivo
se cargue solo.

## 1

```prolog
?- L = [a, b|F], F = [c|G], conocidos(L, C).
L = [a, b, c|G],
F = [c|G],
C = [a, b, c].

?- length([a|T], 2).
T = [_].

?- concatenar_dif([a|X]-X, [b|Y]-Y, D).
X = [b|Y],
D = [a, b|Y]-Y.

?- vacia_dif([a]-[]).
false.

?- inorden_dif(vacio, D).
D = _A-_A.
```

Ligar F a `[c|G]` agrega un elemento a la lista abierta, que sigue abierta en
G; `conocidos/2` da los tres elementos sin ligar G. `length/2` con la longitud
instanciada completa la lista con un elemento libre, y termina: hay una sola
lista de dos elementos que empieza con `a`. La concatenación liga X, el final
de la primera lista, al comienzo de la segunda, y el resultado conserva el
final Y: sigue siendo una lista diferencia. `[a]-[]` representa `[a]`, que no
está vacía, y la unificación de `[a]` con `[]` falla sin crear ningún ciclo.
El árbol vacío da la lista diferencia vacía: el comienzo y el final son la
misma variable.

## 2

<!-- ejemplo: capitulo-34/soluciones.pl predicado: longitud_abierta/2 longitud_abierta/3 consulta: longitud_abierta([a, b|_], N). -->
```prolog
%!  longitud_abierta(+Abierta:list, -N:integer) is det.
%
%   N es la cantidad de elementos ya presentes en la lista abierta Abierta,
%   que no cambia.
longitud_abierta(Abierta, N) :-
    longitud_abierta(Abierta, 0, N).

%!  longitud_abierta(+Abierta:list, +N0:integer, -N:integer) is det.
%
%   N es N0 más la cantidad de elementos presentes en Abierta.
longitud_abierta(Final, N, N) :-
    var(Final),
    !.
longitud_abierta([_|Resto], N0, N) :-
    N1 is N0 + 1,
    longitud_abierta(Resto, N1, N).
```

```prolog
?- longitud_abierta([a, b|_], N).
N = 2.
```

`length/2` trata el final libre como un resto que puede ser cualquier lista:
con una lista abierta, genera las longitudes 1, 2, 3… y liga el final en cada
una ([sección 34.1](index.md#341-listas-abiertas)). `longitud_abierta/2` se detiene en la variable con
`var/1` y no la liga, así que la lista sigue abierta. El acumulador hace la
recursión final, como en el [capítulo 16](../capitulo-16-rendimiento/index.md).

## 3

<!-- ejemplo: capitulo-34/soluciones.pl predicado: a_dif/2 de_dif/2 consulta: a_dif([a, b], D). -->
```prolog
%!  a_dif(+Lista:list, -Dif) is det.
%
%   Dif es la lista diferencia L-F con los elementos de Lista. Copia la
%   lista: recorre todos sus elementos.
a_dif(Lista, L-F) :-
    append(Lista, F, L).

%!  de_dif(+Dif, -Lista:list) is det.
%
%   Lista es la lista cerrada que representa la lista diferencia Dif. Liga
%   el final de Dif a [], en un paso: Dif ya no admite agregados.
de_dif(Lista-[], Lista).
```

```prolog
?- a_dif([a, b], D).
D = [a, b|_A]-_A.

?- de_dif([a, b|F]-F, L).
F = [],
L = [a, b].
```

`a_dif/2` recorre la lista: `append/3` con el segundo argumento libre copia
los elementos y termina la copia en esa variable. `de_dif/2` se hace en un
paso, con una unificación en la cabeza: liga el final a `[]`. Después de
`de_dif/2`, la lista diferencia ya no tiene el final libre, y no admite más
agregados: una concatenación posterior con ella falla. Por eso la conversión
a lista cerrada se hace una vez, en el borde, cuando la construcción terminó.

## 4

<!-- ejemplo: capitulo-34/soluciones.pl predicado: bandera/2 distribuir/4 consulta: bandera([azul, rojo, blanco, rojo, azul], B). -->
```prolog
%!  bandera(+Bolitas:list, -Ordenadas:list) is det.
%
%   Ordenadas tiene las bolitas rojas, después las blancas y después las
%   azules de Bolitas, cada color en su orden original. Recorre Bolitas una
%   sola vez.
bandera(Bolitas, Ordenadas) :-
    distribuir(Bolitas, Ordenadas-Blancas, Blancas-Azules, Azules-[]).

%!  distribuir(+Bolitas:list, ?Rojas, ?Blancas, ?Azules) is det.
%
%   Rojas, Blancas y Azules son las listas diferencia de las bolitas de cada
%   color de Bolitas.
distribuir([], R-R, B-B, A-A).
distribuir([rojo|Xs], [rojo|R]-R0, B, A) :-
    distribuir(Xs, R-R0, B, A).
distribuir([blanco|Xs], R, [blanco|B]-B0, A) :-
    distribuir(Xs, R, B-B0, A).
distribuir([azul|Xs], R, B, [azul|A]-A0) :-
    distribuir(Xs, R, B, A-A0).
```

```prolog
?- bandera([azul, rojo, blanco, rojo, azul], B).
B = [rojo, rojo, blanco, azul, azul].
```

Cada color tiene su lista diferencia, y cada bolita se agrega en un paso al
final de la de su color. La concatenación de las tres no está en ningún
predicado: está en la llamada de `bandera/2`, donde el final de las rojas es
el comienzo de las blancas, `Ordenadas-Blancas` y `Blancas-Azules`, y el final
de las azules es `[]`. Cuando la lista de bolitas se termina, la cláusula de
`[]` cierra cada lista diferencia sobre la siguiente, y Ordenadas queda
completa, sin ningún recorrido adicional. Cada color conserva el orden
original de sus bolitas.

## 5

<!-- ejemplo: capitulo-34/soluciones.pl predicado: preorden//1 postorden//1 consulta: phrase(preorden(n(n(vacio, 1, vacio), 2, n(vacio, 3, vacio))), L). -->
```prolog
%!  preorden(+Arbol)// is det.
%
%   Los elementos de Arbol en preorden: la raíz, los del subárbol izquierdo
%   y los del derecho.
preorden(vacio) -->
    [].
preorden(n(Izq, X, Der)) -->
    [X],
    preorden(Izq),
    preorden(Der).

%!  postorden(+Arbol)// is det.
%
%   Los elementos de Arbol en postorden: los del subárbol izquierdo, los del
%   derecho y la raíz.
postorden(vacio) -->
    [].
postorden(n(Izq, X, Der)) -->
    postorden(Izq),
    postorden(Der),
    [X].
```

```prolog
?- phrase(preorden(n(n(vacio, 1, vacio), 2, n(vacio, 3, vacio))), L).
L = [2, 1, 3].

?- phrase(postorden(n(n(vacio, 1, vacio), 2, n(vacio, 3, vacio))), L).
L = [1, 3, 2].
```

Con `append/3`, el preorden sería `[X|L]` con L la concatenación de la lista
izquierda y la derecha: el `append/3` recorre la izquierda, y el árbol
degenerado hacia la izquierda, el de `degenerado/2`, lo vuelve cuadrático. El
postorden concatena las dos listas y agrega la raíz al final, con un segundo
`append/3` que recorre todo el subárbol: es cuadrático con cualquiera de los
dos árboles degenerados. Las gramáticas no tienen ninguno de los dos costos.

## 6

```prolog
?- D = [a|X]-X, concatenar_dif(D, [b|Y]-Y, R1), concatenar_dif(D, [c|Z]-Z, R2).
false.
```

La primera concatenación liga X, el final de D, a `[b|Y]`. La segunda unifica
ese mismo final con `[c|Z]`, y `[b|Y]` no unifica con `[c|Z]`. Una lista
diferencia se usa una sola vez. Para usarla dos veces se copia **antes** de
usarla, cuando su final todavía está libre:

```prolog
?- D = [a|X]-X, copy_term(D, D2), concatenar_dif(D, [b|Y]-Y, R1-[]), concatenar_dif(D2, [c|Z]-Z, R2-[]).
D = [a, b]-[b],
X = [b],
D2 = [a, c]-[c],
Y = Z, Z = [],
R1 = [a, b],
R2 = [a, c].
```

Copiarla después de la primera concatenación no sirve: la copia de
`[a, b|Y]-[b|Y]` todavía representa `[a]`, pero su final ya es `[b|_]`, y
tampoco unifica con `[c|Z]`. La copia recorre la lista, así que usar dos veces
una lista diferencia cuesta lo mismo que una lista cerrada.

## 7

<!-- ejemplo: capitulo-34/soluciones.pl predicado: elementos_cola/2 consulta: cola_vacia(C0), encolar(a, C0, C1), encolar(b, C1, C2), elementos_cola(C2, L). -->
```prolog
%!  elementos_cola(+Cola, -Lista:list) is det.
%
%   Lista tiene los elementos de Cola, del primero al último, como lista
%   cerrada. Cola no cambia.
elementos_cola(cola(N, Frente, _), Lista) :-
    length(Lista, N),
    append(Lista, _, Frente).
```

```prolog
?- cola_vacia(C0), encolar(a, C0, C1), encolar(b, C1, C2), elementos_cola(C2, L).
C0 = cola(0, [a, b|_A], [a, b|_A]),
C1 = cola(1, [a, b|_A], [b|_A]),
C2 = cola(2, [a, b|_A], _A),
L = [a, b].
```

El frente de la cola tiene los N elementos seguidos del fondo libre.
`length/2` con N instanciado construye una lista cerrada de N variables, y
`append/3` la unifica con el comienzo del frente sin tocar el resto: el fondo
queda libre y la cola admite más agregados. Recorrer el frente hasta el fondo
con `var/1` también serviría, pero el contador ya dice dónde parar.

## 8

```prolog
?- es_vacia_dif([a|X]-X).
X = [a|X].
```

La cola `[a|X]-X` tiene un elemento, y la prueba de vacía debería fallar. Para
unificarla con `F-F`, F se liga a `[a|X]` y después X a F, es decir, a
`[a|X]`: X queda ligada a un término que la contiene. Sin la verificación de
ocurrencias, la unificación lo acepta, y la respuesta es un término cíclico
([sección 34.2](index.md#342-de-append3-a-la-lista-diferencia)). Con `unify_with_occurs_check/2` la prueba falla, como
corresponde:

```prolog
?- unify_with_occurs_check([a|X]-X, F-F).
false.
```

`cola_vacia/1` también unifica el frente con el fondo, pero la cola con
contador tiene otro argumento que distingue los casos: con una cola de un
elemento, 0 no unifica con 1, la unificación de la cabeza falla, y las
ligaduras que hubiera hecho se deshacen, el ciclo incluido. La cantidad de
elementos es la prueba de vacía; la forma de la lista diferencia, no.

## 9

<!-- ejemplo: capitulo-34/soluciones.pl predicado: claves/2 consulta: claves([a-1, b-_|_], C). -->
```prolog
%!  claves(+Dic:list, -Claves:list) is det.
%
%   Claves tiene las claves del diccionario incompleto Dic, en su orden,
%   sin ligar el final de Dic.
claves(Final, []) :-
    var(Final),
    !.
claves([Clave-_|Resto], [Clave|Claves]) :-
    claves(Resto, Claves).
```

```prolog
?- claves([a-1, b-_|_], C).
C = [a, b].
```

Es `conocidos/2` con cada par reducido a su clave. Los valores libres no
importan: `claves/2` no los examina.

## 10

<!-- ejemplo: capitulo-34/soluciones.pl predicado: pares//1 consulta: buscar_arbol(b, A, 2), buscar_arbol(a, A, 1), phrase(pares(A), P). -->
```prolog
%!  pares(+Arbol)// is det.
%
%   Los pares Clave-Valor del diccionario incompleto Arbol, en el orden de
%   las claves. Un subárbol libre no tiene pares, y queda libre.
pares(Arbol) -->
    { var(Arbol) },
    !.
pares(t(Clave, Valor, Izq, Der)) -->
    pares(Izq),
    [Clave-Valor],
    pares(Der).
```

```prolog
?- buscar_arbol(b, A, 2), buscar_arbol(a, A, 1), phrase(pares(A), P).
A = t(b, 2, t(a, 1, _, _), _),
P = [a-1, b-2].
```

Un recorrido en orden de un árbol de búsqueda da las claves ordenadas, como
`en_orden//1` de la [sección 34.5](index.md#345-las-gramaticas-como-listas-diferencia). La primera regla detecta el
subárbol libre con `var/1` y no produce nada. Sin el corte, al pedir otra
respuesta la segunda regla unificaría el subárbol libre con
`t(Clave, Valor, Izq, Der)`: agregaría al diccionario una entrada de clave
libre, y cada nueva respuesta, otra más, sin terminar. La
prueba `var/1` tiene que ir antes de cualquier unificación con el
subárbol, por la misma razón que en `buscar_arbol/3`.

## 11

<!-- ejemplo: capitulo-34/soluciones.pl predicado: hojas//1 hojas_lista//1 consulta: phrase(hojas(n([h(a), n([h(b), h(c)])])), L). -->
```prolog
%!  hojas(+Arbol)// is det.
%
%   Las hojas del árbol limpio Arbol, de izquierda a derecha: h(X) es una
%   hoja y n(Hijos) un nodo con la lista de sus hijos.
hojas(h(X)) -->
    [X].
hojas(n(Hijos)) -->
    hojas_lista(Hijos).

%!  hojas_lista(+Arboles:list)// is det.
%
%   Las hojas de cada árbol de Arboles, en orden.
hojas_lista([]) -->
    [].
hojas_lista([A|As]) -->
    hojas(A),
    hojas_lista(As).
```

```prolog
?- phrase(hojas(n([h(a), n([h(b), h(c)])])), L).
L = [a, b, c].

?- listing(hojas//1).
hojas(h(A), [A|B], B).
hojas(n(Hijos), A, B) :-
    hojas_lista(Hijos, A, B).

true.
```

La regla de `h(X)` tiene como cuerpo un único terminal, y la traducción lo
pasó a la cabeza: `hojas(h(A), [A|B], B)` es un hecho. En `en_orden//1` el
terminal está entre dos no terminales, y la traducción lo deja en el cuerpo
como `C=[X|D]`, después de la llamada que liga C. Las dos formas describen la
misma lista diferencia: una hoja aporta un elemento, y el final queda libre
para lo que sigue.

## 12

| n | `invertir_app/2` | razón | `invertir/2` | razón |
|---|---|---|---|---|
| 1000 | 501 642 | | 1 001 | |
| 2000 | 2 003 142 | 3,99 | 2 001 | 2,00 |
| 4000 | 8 006 142 | 4,00 | 4 001 | 2,00 |

Las inferencias se midieron con `time/1`, por ejemplo con
`numlist(1, 1000, L), time(invertir_app(L, _))`. `invertir_app/2` hace un
`append/3` por elemento, y el del elemento k recorre las k − 1 anteriores ya
invertidas: en total, alrededor de n²/2 inferencias. Duplicar n cuadruplica
ese número. `invertir/2` hace una inferencia por elemento, más la de su
llamada: duplicar n duplica el trabajo.

## 13

<!-- ejemplo: capitulo-34/soluciones_simbolos.pl predicado: marcar/3 consulta: ensamblar([etiqueta(a), sumar, etiqueta(a)], C). -->
```prolog
%!  marcar(+E, ?Tabla, +Dir:integer) is det.
%
%   Registra en Tabla que la etiqueta E está en la dirección Dir. Produce
%   un error de permiso si E ya estaba marcada.
marcar(E, Tabla, Dir) :-
    buscar(E, Tabla, D),
    (   var(D)
    ->  D = Dir
    ;   permission_error(marcar, etiqueta, E)
    ).
```

La cláusula de la marca en `instruccion//4` llama a `marcar/3` en lugar de a
`buscar/3`:

<!-- ejemplo: capitulo-34/soluciones_simbolos.pl fragmento: instruccion(etiqueta(E) .. marcar(E, Tabla, Dir) }. -->
```prolog
instruccion(etiqueta(E), Dir, Dir, Tabla) -->
    { marcar(E, Tabla, Dir) }.
```

```prolog
?- ensamblar([etiqueta(a), sumar, etiqueta(a)], C).
ERROR: No permission to marcar etiqueta `a'
```

Que la etiqueta esté en la tabla no alcanza para decir que ya se marcó: un
salto hacia adelante la agrega con la dirección libre. Lo que distingue una
marca anterior es que la dirección está ligada. Por eso `marcar/3` busca la
etiqueta, que la agrega si no estaba, y liga la dirección solo si está libre.
Comparar la dirección con la actual no bastaría: dos marcas seguidas de la
misma etiqueta tienen la misma dirección, y la segunda pasaría (prueba
`repetida_seguida`).

## 14

<!-- ejemplo: capitulo-34/soluciones_simbolos.pl predicado: asignar/3 direccion/3 numerar/3 consulta: asignar([cargar(x), cargar(y), sumar, guardar(x)], C, N). -->
```prolog
%!  asignar(+Codigo:list, -Codigo1:list, -N:integer) is det.
%
%   Codigo1 es Codigo con el nombre de cada variable de cargar/1 y
%   guardar/1 reemplazado por una dirección de memoria: 0 para la primera
%   variable que aparece, 1 para la segunda, y así. N es la cantidad de
%   variables.
asignar(Codigo, Codigo1, N) :-
    maplist(direccion(Tabla), Codigo, Codigo1),
    numerar(Tabla, 0, N).

%!  direccion(?Tabla, +I, -I1) is det.
%
%   I1 es la instrucción I con la variable, si la tiene, reemplazada por su
%   valor en el diccionario incompleto Tabla. I1 debe llegar libre.
direccion(Tabla, cargar(V), cargar(D)) :-
    !,
    buscar(V, Tabla, D).
direccion(Tabla, guardar(V), guardar(D)) :-
    !,
    buscar(V, Tabla, D).
direccion(_, I, I).

%!  numerar(+Tabla:list, +N0:integer, -N:integer) is det.
%
%   Liga los valores de Tabla a N0, N0+1, …, en orden, hasta el final
%   abierto; N es el siguiente número sin usar.
numerar(Final, N, N) :-
    var(Final),
    !.
numerar([_-N0|Resto], N0, N) :-
    N1 is N0 + 1,
    numerar(Resto, N1, N).
```

```prolog
?- asignar([cargar(x), cargar(y), sumar, guardar(x)], C, N).
C = [cargar(0), cargar(1), sumar, guardar(0)],
N = 2.
```

Es el esquema de `codificar/2` de la [sección 34.4](index.md#344-diccionarios-incompletos): `maplist/3` reemplaza cada
nombre por el valor, todavía libre, de su entrada en la tabla, y
`numerar/3` liga los valores a 0, 1, … en el orden de las entradas, que es el
de la primera aparición de cada variable. N sale del mismo recorrido: es el
primer número que no se usó. Los cortes de `direccion/3` separan las
instrucciones con una variable del caso general, y son correctos porque la
instrucción de salida llega libre, como dice el encabezado.

## 15

<!-- ejemplo: capitulo-34/soluciones.pl predicado: nivelar/2 nivelar/5 consulta: nivelar(n(n(vacio, 4, vacio), 3, n(vacio, 9, vacio)), N). -->
```prolog
%!  nivelar(+Arbol, -Nivelado) is det.
%
%   Nivelado tiene la forma de Arbol, vacio o n(Izq, X, Der), con el máximo
%   de los elementos de Arbol en cada nodo. Un solo recorrido: los nodos
%   nuevos comparten la variable Max, que se liga al terminar.
nivelar(vacio, vacio).
nivelar(n(Izq, X, Der), Nivelado) :-
    nivelar(n(Izq, X, Der), Max, Nivelado, X, Max).

%!  nivelar(+Arbol, ?M, -Nivelado, +Max0:number, -Max:number) is det.
%
%   Nivelado tiene la forma de Arbol con M en cada nodo, y Max es el mayor
%   entre Max0 y los elementos de Arbol. M puede estar libre: se liga
%   después, cuando se conoce el máximo de todo el árbol.
nivelar(vacio, _, vacio, Max, Max).
nivelar(n(Izq, X, Der), M, n(Izq1, M, Der1), Max0, Max) :-
    Max1 is max(Max0, X),
    nivelar(Izq, M, Izq1, Max1, Max2),
    nivelar(Der, M, Der1, Max2, Max).
```

```prolog
?- nivelar(n(n(vacio, 4, vacio), 3, n(vacio, 9, vacio)), N).
N = n(n(vacio, 9, vacio), 9, n(vacio, 9, vacio)).

?- nivelar(vacio, N).
N = vacio.
```

Cada nodo nuevo recibe la variable `M`, todavía libre: el máximo no se
conoce hasta terminar el recorrido, pero el lugar donde va sí. `nivelar/5`
lleva además un acumulador, el máximo hasta el momento, que empieza en la raíz
y se compara con cada elemento. La cláusula de `nivelar/2` pasa **la misma
variable** `Max` como `M` y como máximo final: cuando el recorrido termina y
el acumulado se unifica con el último argumento, `M` queda ligada, y todos
los nodos, que la comparten, muestran el máximo a la vez. No hay un segundo
recorrido para escribir el valor.

Es la tabla de símbolos de la [sección 34.7](index.md#347-la-tabla-de-simbolos-del-compilador): un salto hacia adelante escribe en
la instrucción la variable de la dirección de su etiqueta, y la marca, más
abajo, la liga. En los dos casos el valor se usa antes de conocerse, porque
lo que se escribe es una variable compartida y no el valor. El árbol vacío es
un caso aparte: no tiene elementos, y no hay máximo con el que empezar.

## 16

La primera versión reúne los sumandos en una lista diferencia, como
`inorden_dif/2` en la [sección 34.2](index.md#342-de-append3-a-la-lista-diferencia), y la recorre de nuevo con `foldl/4`:

<!-- ejemplo: capitulo-34/soluciones.pl predicado: sumandos/2 asociar_izquierda_2/2 agregar_sumando/3 consulta: asociar_izquierda_2((a + b) + (c + d), S). -->
```prolog
%!  sumandos(+Suma, -Dif) is det.
%
%   Dif, un par L-F, es la lista diferencia de los sumandos de Suma, de
%   izquierda a derecha. Un sumando es todo término que no es una suma con
%   +; Suma es un término cerrado.
sumandos(Suma, L-F) :-
    (   Suma = A + B
    ->  sumandos(A, L-M),
        sumandos(B, M-F)
    ;   L = [Suma|F]
    ).

%!  asociar_izquierda_2(+Suma, -Normal) is det.
%
%   Normal tiene los sumandos de Suma, en el mismo orden, asociados a
%   izquierda. Dos recorridos: uno reúne los sumandos y otro construye la
%   suma.
asociar_izquierda_2(Suma, Normal) :-
    sumandos(Suma, [Primero|Resto]-[]),
    foldl(agregar_sumando, Resto, Primero, Normal).

% agregar_sumando(X, Suma0, Suma): Suma es Suma0 con X sumado a la derecha.
agregar_sumando(X, Suma0, Suma0 + X).
```

La segunda lo hace en una pasada. El acumulador es la suma asociada a
izquierda construida hasta el momento, y cada sumando nuevo se agrega a su
derecha:

<!-- ejemplo: capitulo-34/soluciones.pl predicado: asociar_izquierda/2 agregar/3 consulta: asociar_izquierda((a + b) + (c + d), S). -->
```prolog
%!  asociar_izquierda(+Suma, -Normal) is det.
%
%   Normal tiene los sumandos de Suma, en el mismo orden, asociados a
%   izquierda. Una sola pasada: el sumando de más a la izquierda es el valor
%   inicial del acumulador, y agregar/3 suma los demás.
asociar_izquierda(Suma, Normal) :-
    (   Suma = A + B
    ->  asociar_izquierda(A, Normal0),
        agregar(B, Normal0, Normal)
    ;   Normal = Suma
    ).

%!  agregar(+Suma, +Normal0, -Normal) is det.
%
%   Normal es la suma asociada a izquierda Normal0 con los sumandos de Suma
%   agregados a la derecha, en orden.
agregar(Suma, Normal0, Normal) :-
    (   Suma = A + B
    ->  agregar(A, Normal0, Normal1),
        agregar(B, Normal1, Normal)
    ;   Normal = Normal0 + Suma
    ).
```

```prolog
?- asociar_izquierda((a + b) + (c + d), S).
S = a+b+c+d.

?- asociar_izquierda(a + (b + (c + d)), S), write_canonical(S), nl.
+(+(+(a,b),c),d)
S = a+b+c+d.
```

El acumulador empieza con el sumando de más a la izquierda: `asociar_izquierda/2`
baja por los primeros argumentos hasta encontrarlo, y en cada nivel, al
volver, agrega con `agregar/3` los sumandos del segundo argumento. Cada nodo
de la suma se visita una vez. Un valor inicial como `ninguno` forma parte del
resultado, porque el acumulador es el resultado en construcción:
`agregar((a + b) + (c + d), ninguno, S)` da `S = ninguno+a+b+c+d`, una suma
con un sumando de más. Quitarlo exigiría un segundo recorrido o una
comparación con `ninguno` en cada paso, y un sumando que se llamara `ninguno`
se confundiría con el valor inicial. Tampoco sirve `0`, que da
`0+a+b+c+d`: el término no es el mismo, aunque el valor sea igual.

Las dos versiones distinguen un sumando de una suma con la unificación
`Suma = A + B` dentro de un condicional, no con una cláusula por clase de
nodo: un sumando es cualquier término que no es una suma. El
[Patrón 44](../patrones.md#44-representacion-limpia) aconseja un functor por clase de nodo, y exceptúa este caso: las
sumas son términos cerrados que escriben personas, con la sintaxis de la
aritmética, y sobre un término cerrado la prueba es segura. Con una variable
como sumando, la prueba la ligaría a `A + B` y la recursión no terminaría;
por eso el encabezado exige un término cerrado.
