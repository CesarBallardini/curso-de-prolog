# Soluciones del capítulo 75 — Proyecto: rompecabezas con simetrías

El código de esta página está en `ejemplos/capitulo-75/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `tablero.pl` (y con él
`vista.pl`, `unico.pl`, `lazo.pl` y `tramos.pl`) y `representantes.pl` (y
con él `tipos.pl` y `enigma.pl`), sin modificarlos. Es `% solo-local`,
porque carga otros archivos.

## 1

`chico` tiene tres marcas y un solo lazo. Desde cada marca, la búsqueda
encuentra el lazo en los dos sentidos: 3 × 2 = 6 escrituras. Con la
semilla fija quedan las dos de una marca, y con el sentido fijo, una:

<!-- contexto: capitulo-75/soluciones.pl -->
```prolog
?- findall(M-N, ( member(M, [todas, semilla, sentido]), escrituras(M, chico, Ls), length(Ls, N) ), R).
R = [todas-6, semilla-2, sentido-1].
```

En general, un tablero con M marcas y L lazos da 2ML, 2L y L escrituras:
`csenki1` (9 marcas, 1 lazo) da 18, 2 y 1, y `cruz` (4 marcas, 5 lazos),
40, 10 y 5, como muestra la
[sección 75.4](index.md#754-version-3-cada-lazo-una-sola-vez).

## 2

`costo_por_semilla/2` cuenta los tramos que salen de cada marca y mide
las inferencias de buscar los lazos desde ella:

<!-- ejemplo: capitulo-75/soluciones.pl predicado: costo_por_semilla/2 -->
```prolog
%!  costo_por_semilla(+Nombre, -Filas:list) is det.
%
%   Filas tiene un término s(Marca, Tramos, Inferencias) por cada marca
%   del tablero Nombre: Tramos es la cantidad de tramos que salen de ella
%   e Inferencias, lo que cuesta buscar los lazos desde ella.
costo_por_semilla(Nombre, Filas) :-
    findall(s(M, T, I),
            ( marca(Nombre, M, _),
              aggregate_all(count, tramo(Nombre, M, _, _), T),
              statistics(inferences, I0),
              lazos_desde(Nombre, M, _),
              statistics(inferences, I1),
              I is I1 - I0 ),
            Filas).
```

Las mediciones, en miles de inferencias:

| `csenki1` | 1-4 | 3-5 | 4-2 | 6-6 | 1-6 | 2-1 | 2-2 | 4-1 | 5-5 |
|---|---|---|---|---|---|---|---|---|---|
| tramos | 4 | 6 | 3 | 4 | 3 | 4 | 6 | 3 | 5 |
| inferencias | 13,7 | 12,2 | 12,6 | 12,7 | 12,5 | 12,2 | 12,3 | 12,3 | 12,1 |

| `csenki2` | tramos | millones de inferencias |
|---|---|---|
| 1-1 | 7 | 23,0 |
| 1-6 | 7 | 16,3 |
| 1-8 | 4 | 22,4 |
| 2-7 | 12 | 14,7 |
| 3-6 | 12 | 15,2 |
| 3-8 | 9 | 13,3 |
| 4-2 | 12 | 18,0 |
| 5-3 | 11 | 19,1 |
| 5-7 | 12 | 14,8 |
| 6-4 | 12 | 16,2 |
| 6-5 | 10 | 16,9 |
| 7-6 | 13 | 17,9 |
| 8-2 | 8 | 20,0 |
| 8-7 | 8 | 17,7 |
| 9-1 | 7 | 20,1 |

La marca con menos tramos, `1-8`, está entre las más caras, y la más
barata, `3-8`, tiene nueve. La cantidad de tramos de la semilla solo
decide cuántas ramas tiene el primer nivel; el costo lo deciden los
callejones sin salida de los niveles siguientes, que dependen del orden
en que se visitan las demás marcas. Entre la mejor semilla y la peor hay
menos de un factor 2, mientras que fijar una semilla, cualquiera, evita
las otras catorce búsquedas: las quince juntas cuestan 265 millones. La primera marca de la lista, `1-1`, resulta ser la
más cara de `csenki2`; elegir otra no cambia el orden de magnitud.

## 3

Las simetrías propias de un tablero son las que dejan su imagen igual a
la imagen por la identidad. La órbita de un lazo son las formas
canónicas de sus imágenes por esas simetrías:

<!-- ejemplo: capitulo-75/soluciones.pl predicado: simetrias_propias/2 orbitas/2 orbita/5 imagen_de_lazo/5 -->
```prolog
%!  simetrias_propias(+Nombre, -Ss:list) is det.
%
%   Ss son las simetrías que llevan el tablero Nombre a sí mismo.
simetrias_propias(Nombre, Ss) :-
    imagen(identidad, Nombre, Propia),
    findall(S, ( simetria(S, _), imagen(S, Nombre, Propia) ), Ss).

%!  orbitas(+Nombre, -Orbitas:list) is det.
%
%   Orbitas agrupa las formas canónicas de los lazos del tablero Nombre:
%   dos lazos están en la misma órbita si una simetría propia del tablero
%   lleva uno al otro. Cada órbita es una lista ordenada.
orbitas(Nombre, Orbitas) :-
    problema(Nombre, Fs, Cs, _),
    simetrias_propias(Nombre, Ss),
    distintos(Nombre, Lazos),
    maplist(orbita(Ss, Fs, Cs), Lazos, Orbitas0),
    sort(Orbitas0, Orbitas).

%!  orbita(+Ss:list, +Fs:integer, +Cs:integer, +Lazo:list, -Orbita:list)
%!      is det.
%
%   Orbita son las formas canónicas de las imágenes de Lazo por las
%   simetrías Ss, sin repetir.
orbita(Ss, Fs, Cs, Lazo, Orbita) :-
    maplist(imagen_de_lazo(Fs, Cs, Lazo), Ss, Imagenes),
    sort(Imagenes, Orbita).

%!  imagen_de_lazo(+Fs:integer, +Cs:integer, +Lazo:list, +S, -Forma:list)
%!      is det.
%
%   Forma es la forma canónica de la imagen de Lazo por S.
imagen_de_lazo(Fs, Cs, Lazo, S, Forma) :-
    lazo_imagen(S, Fs, Cs, Lazo, Forma).
```

```prolog
?- simetrias_propias(cruz, Ss), orbitas(cruz, Os), maplist(length, Os, Ls).
Ss = [identidad, giro180, espejo_filas, espejo_columnas],
Os = [[[1-1, 1-2, 1-3, 2-3, 2-2, 3-2, ... - ...|...], [1-1, 1-2, 1-3, 2-3, 3-3, ... - ...|...], [1-1, 1-2, 2-2, 2-3, ... - ...|...], [1-2, 1-3, 2-3, ... - ...|...]], [[1-1, 1-2, 1-3, 2-3, 3-3, ... - ...|...]]],
Ls = [4, 1].
```

Los cinco lazos de `cruz` forman dos clases: los cuatro que giran hacia
adentro, que las simetrías propias llevan uno al otro, y el lazo del
borde, que todas dejan igual. Salvo simetría, `cruz` tiene dos
soluciones.

## 4

`leer_tablero/4` descarta las líneas vacías (las de los trazos
verticales, que en un tablero sin lazo no tienen nada), separa cada
línea en sus símbolos y lee la clase de cada uno con `simbolo/2` de
`vista.pl` en sentido inverso:

<!-- ejemplo: capitulo-75/soluciones.pl predicado: leer_tablero/4 marcas_de_fila/4 -->
```prolog
%!  leer_tablero(+Lineas:list(string), -Filas:integer, -Columnas:integer,
%!               -Marcas:list) is det.
%
%   Lineas es el dibujo de un tablero sin lazo, como el de
%   mostrar(Nombre, []): una línea de casillas por fila y una línea vacía
%   entre fila y fila. Filas y Columnas son sus dimensiones y Marcas sus
%   marcas, en el orden de lectura.
leer_tablero(Lineas, Filas, Columnas, Marcas) :-
    exclude(==(""), Lineas, DeCasillas),
    length(DeCasillas, Filas),
    DeCasillas = [Primera|_],
    split_string(Primera, " ", "", Simbolos),
    length(Simbolos, Columnas),
    foldl(marcas_de_fila, DeCasillas, Listas, 1, _),
    append(Listas, Marcas).

%!  marcas_de_fila(+Linea:string, -Marcas:list, +F:integer, -F1:integer)
%!      is det.
%
%   Marcas son las marcas de la fila F, cuyas casillas dibuja Linea; F1 es
%   F + 1.
marcas_de_fila(Linea, Marcas, F, F1) :-
    F1 is F + 1,
    split_string(Linea, " ", "", Simbolos),
    findall(Marca,
            ( nth1(C, Simbolos, Simbolo),
              atom_string(Caracter, Simbolo),
              simbolo(Clase, Caracter),
              clase(Marca, Clase, F-C) ),
            Marcas).
```

```prolog
?- lineas(chico, [], Ls), leer_tablero(Ls, F, C, Ms).
Ls = ["O · O", "", "· · ·", "", "· # ·"],
F = C, C = 3,
Ms = [circulo(1-1), circulo(1-3), numeral(3-2)].
```

La prueba `leer_tablero` de `soluciones.plt` lee de vuelta los cuatro
tableros del capítulo y compara las marcas ordenadas.

## 5

En esta variante el lazo pasa por todas las casillas, así que se arma
casilla por casilla y no tramo por tramo. Ninguna marca puede estar en
una esquina, porque en una esquina el lazo gira; en particular, el lazo
gira en `1-1`. Empezar allí, salir hacia `1-2` y exigir que el último
paso llegue desde `2-1` fija la semilla y el sentido, con lo que cada
lazo aparece una sola vez:

<!-- ejemplo: capitulo-75/soluciones.pl predicado: lazo_recto/2 camino_recto/6 vecina/4 recta_si_marca/4 -->
```prolog
%!  lazo_recto(+Nombre, -Lazos:list) is det.
%
%   Lazos son los lazos del tablero recto Nombre que pasan por todas las
%   casillas y atraviesan cada marca sin girar. Como ninguna marca puede
%   estar en una esquina, el lazo gira en 1-1: empieza allí, sigue por
%   1-2 y termina en 2-1, con lo que cada lazo aparece una sola vez.
lazo_recto(Nombre, Lazos) :-
    call(Nombre, Filas, Columnas, Marcas),
    Total is Filas * Columnas,
    findall([1-1|Camino],
            camino_recto(t(Filas, Columnas, Marcas, Total), 1-1, 1-2,
                         [1-2, 1-1], 2, Camino),
            Lazos).

%!  camino_recto(+T, +Anterior, +Actual, +Visitadas:list, +K:integer,
%!               -Camino:list) is nondet.
%
%   Camino sigue desde Actual, a la que se llegó desde Anterior, por
%   casillas no visitadas hasta completar las del tablero y terminar en
%   2-1, vecina de 1-1. K es la cantidad de casillas visitadas. En una
%   marca, la casilla siguiente sigue la línea de Anterior y Actual.
camino_recto(t(_, _, Marcas, Total), Anterior, Actual, _, Total, [Actual]) :-
    Actual == 2-1,
    recta_si_marca(Marcas, Anterior, Actual, 1-1).
camino_recto(T, Anterior, Actual, Visitadas, K, [Actual|Camino]) :-
    T = t(Filas, Columnas, Marcas, Total),
    K < Total,
    vecina(Filas, Columnas, Actual, Siguiente),
    \+ memberchk(Siguiente, Visitadas),
    recta_si_marca(Marcas, Anterior, Actual, Siguiente),
    K1 is K + 1,
    camino_recto(T, Actual, Siguiente, [Siguiente|Visitadas], K1, Camino).

%!  vecina(+Filas:integer, +Columnas:integer, +Pos, -Vecina) is nondet.
%
%   Vecina es una casilla del tablero que comparte un lado con Pos.
vecina(Filas, Columnas, F-C, F1-C1) :-
    member(DF-DC, [0-1, 1-0, 0-(-1), (-1)-0]),
    F1 is F + DF,
    C1 is C + DC,
    between(1, Filas, F1),
    between(1, Columnas, C1).

%!  recta_si_marca(+Marcas:list, +A, +B, +C) is semidet.
%
%   Si B es una marca, A, B y C están alineadas.
recta_si_marca(Marcas, F0-C0, B, F2-C2) :-
    (   memberchk(B, Marcas)
    ->  B = F1-C1,
        F1 - F0 =:= F2 - F1,
        C1 - C0 =:= C2 - C1
    ;   true
    ).
```

```prolog
?- lazo_recto(recto, Lazos), length(Lazos, N).
Lazos = [[1-1, 1-2, 2-2, 3-2, 3-3, 3-4, 3-5, ... - ...|...]],
N = 1.
```

El tablero tiene un solo lazo, el que muestra Csenki, hallado en 3,3
millones de inferencias. El archivo agrega el tablero como
`problema(recto6, …)`, con las marcas como círculos, para dibujarlo con
`mostrar/2`:

```text
┌─┐ ┌─────┐
│ │ │     │
│ O └─O─┐ │
│ │     │ │
O └───O─┘ │
│         │
│ ┌─O─────┘
│ │
│ └─O───O─┐
│         │
└─────O───┘
```

## 6

Para N = 2 el único desarreglo es `[2, 1]`, y su patrón tiene una sola
variable: la columna 1 es la fila 2 y la columna 2 es la fila 1, lo que
obliga a que las cuatro casillas sean iguales. Las dos filas son
idénticas y no hay tablero.

```prolog
?- matriz_patron([2, 1], M).
M = [[_A, _A], [_A, _A]].
```

## 7

<!-- ejemplo: capitulo-75/soluciones.pl predicado: cantidad_desarreglos/2 cantidad_desarreglos/3 -->
```prolog
%!  cantidad_desarreglos(+N:integer, -D:integer) is det.
%
%   D es la cantidad de desarreglos de 1..N, por la recurrencia
%   D(N) = (N - 1)(D(N - 1) + D(N - 2)), con D(1) = 0 y D(2) = 1. N
%   debe ser al menos 1.
cantidad_desarreglos(N, D) :-
    cantidad_desarreglos(N, D, _).

%!  cantidad_desarreglos(+N:integer, -D:integer, -DAnterior:integer) is det.
%
%   D es la cantidad de desarreglos de 1..N y DAnterior la de 1..N-1 (1
%   para N = 1: la permutación vacía). N debe ser al menos 1.
cantidad_desarreglos(N, D, D1) :-
    (   N =:= 1
    ->  D = 0,
        D1 = 1
    ;   N1 is N - 1,
        cantidad_desarreglos(N1, D1, D2),
        D is N1 * (D1 + D2)
    ).
```

La recursión lleva dos valores, D(N) y D(N − 1), para no calcular dos
veces los mismos términos:

```prolog
?- cantidad_desarreglos(8, D), desarreglos(8, Ps), length(Ps, D).
D = 14833,
Ps = [[2, 1, 4, 3, 6, 5, 8, 7], [2, 1, 4, 3, 6, 7, 8|...], [2, 1, 4, 3, 6, 8|...], [2, 1, 4, 3, 7|...], [2, 1, 4, 3|...], [2, 1, 4|...], [2, 1|...], [2|...], [...|...]|...].
```

La prueba `cantidad_desarreglos` compara las dos cuentas de N = 1 a 8, y
`cantidad_desarreglos_20` calcula D(20) = 895 014 631 192 902 121, que
`desarreglos/2` no podría enumerar.

## 8

`particion/3` de `representantes.pl` ya admite una parte mínima; con
mínimo 1 da las particiones en partes cualesquiera:

<!-- ejemplo: capitulo-75/soluciones.pl predicado: particion_libre/2 -->
```prolog
%!  particion_libre(+N:integer, -Partes:list(integer)) is nondet.
%
%   Partes es una partición de N en partes cualesquiera, de menor a mayor.
particion_libre(N, Partes) :-
    particion(N, 1, Partes).
```

```prolog
?- aggregate_all(count, particion_libre(8, _), N).
N = 22.
```

Son los 22 tipos de las permutaciones de 8 elementos que menciona
Csenki. Un 1 en el tipo es un punto fijo: un número I con P(I) = I. El
patrón de P tiene entonces la columna I igual a la fila I, que es
justamente lo que el enunciado prohíbe. Por eso solo cuentan los 7 tipos
sin partes iguales a 1.

## 9

<!-- ejemplo: capitulo-75/soluciones.pl predicado: conjugacion_verificada/1 -->
```prolog
%!  conjugacion_verificada(+N:integer) is semidet.
%
%   Para cada desarreglo de 1..N cuyo patrón tiene filas distintas, su
%   total es el del representante de su tipo.
conjugacion_verificada(N) :-
    forall(tablero(N, P, _, T),
           ( tipo(P, Tipo), total_de_tipo(Tipo, T) )).
```

```prolog
?- conjugacion_verificada(6).
true.
```

Los 265 desarreglos de 6 elementos tienen filas distintas, y cada uno da
el total del representante de su tipo: 180 para `[2, 2, 2]`, 159 para
`[3, 3]`, 116 para `[2, 4]` y 72 para `[6]`.

## 10

Los máximos para N par:

```prolog
?- findall(N-T, ( between(2, 10, K), N is 2 * K, maximo_representantes(N, T, _) ), Ts).
Ts = [4-40, 6-180, 8-544, 10-1300, 12-2664, 14-4900, 16-8320, 18-13284, ... - ...].
```

El último par es `20-20200`. Las cuartas diferencias de la sucesión
40, 180, 544, 1 300, 2 664, … son constantes, así que el máximo es un
polinomio de grado 4 en N. Ajustarlo con los cinco primeros valores da
T(N) = N⁴/8 + N²/2 = N²(N² + 4)/8. `conjetura/1` lo verifica para todos
los N pares hasta 20, y verifica también que el tipo de N/2 ciclos de
longitud 2 alcanza el máximo:

<!-- ejemplo: capitulo-75/soluciones.pl predicado: polinomio/2 conjetura/1 -->
```prolog
%!  polinomio(+N:integer, -T:integer) is det.
%
%   T es N²(N² + 4)/8, la conjetura para el máximo con N par.
polinomio(N, T) :-
    T is N * N * (N * N + 4) // 8.

%!  conjetura(+Hasta:integer) is semidet.
%
%   Para cada N par de 4 a Hasta, el máximo de maximo_representantes/3 es
%   el de polinomio/2 y lo alcanza el tipo de N/2 ciclos de longitud 2.
conjetura(Hasta) :-
    forall(( between(2, Hasta, N), N mod 2 =:= 0, N >= 4 ),
           ( maximo_representantes(N, T, _),
             polinomio(N, T),
             K is N // 2,
             length(Doses, K),
             maplist(=(2), Doses),
             total_de_tipo(Doses, T) )).
```

```prolog
?- conjetura(20).
true.

?- maximo_representantes(8, _, Tipo).
Tipo = [2, 2, 2, 2].
```

La verificación hasta 20 no es una demostración: es la evidencia que
sostiene la conjetura.

## 11

La parte pura arma cada línea con `format/3` y la columna de tabulación
`~t~d~*|`, que alinea el número a la derecha dentro de un ancho dado; el
ancho sale del número más largo de la matriz:

<!-- ejemplo: capitulo-75/soluciones.pl predicado: lineas_matriz/2 linea_matriz/3 celda_matriz/4 mostrar_matriz/1 -->
```prolog
%!  lineas_matriz(+M:list(list(integer)), -Lineas:list(string)) is det.
%
%   Lineas son las filas de M con cada número alineado a la derecha en una
%   columna del ancho del número más largo, más un espacio.
lineas_matriz(M, Lineas) :-
    append(M, Todos),
    max_list(Todos, Mayor),
    format(string(Texto), "~d", [Mayor]),
    string_length(Texto, Ancho0),
    Ancho is Ancho0 + 1,
    maplist(linea_matriz(Ancho), M, Lineas).

%!  linea_matriz(+Ancho:integer, +Fila:list(integer), -Linea:string) is det.
%
%   Linea es Fila con cada número alineado a la derecha en Ancho columnas.
linea_matriz(Ancho, Fila, Linea) :-
    foldl(celda_matriz(Ancho), Fila, "", Linea).

%!  celda_matriz(+Ancho:integer, +X:integer, +L0:string, -L:string) is det.
%
%   L es L0 seguido de X alineado a la derecha en Ancho columnas.
celda_matriz(Ancho, X, L0, L) :-
    format(string(Celda), "~t~d~*|", [X, Ancho]),
    string_concat(L0, Celda, L).

%!  mostrar_matriz(+M:list(list(integer))) is det.
%
%   Escribe las líneas de lineas_matriz/2, una por renglón.
mostrar_matriz(M) :-
    lineas_matriz(M, Lineas),
    forall(member(L, Lineas), writeln(L)).
```

```prolog
?- once(tablero(4, [2, 1, 4, 3], M, _)), mostrar_matriz(M).
 1 1 2 3
 1 1 3 2
 3 2 4 4
 2 3 4 4
M = [[1, 1, 2, 3], [1, 1, 3, 2], [3, 2, 4, 4], [2, 3, 4, 4]].
```

Es el primer tablero de 4 × 4 que muestra Csenki, con suma 40.
