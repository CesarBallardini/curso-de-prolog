# Soluciones del capítulo 80 — Proyecto: el etiquetado de Waltz

El código de esta página está en `ejemplos/capitulo-80/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `comparar.pl`, que carga
las versiones 2 a 5 (`generar.pl`, `restricciones.pl`, `waltz.pl` y
`tablas.pl`, todas sobre `dibujo.pl`), sin modificarlas, y agrega dos dibujos a los de
`figuras.pl`, que declara `punto/4` y `segmento/3` como `multifile`. Es
`% solo-local`, porque carga otros archivos. Las inferencias se midieron
con `call_time/2` después de una primera ejecución.

## 1

La línea de `a` a `b` une el centro, una horquilla, con el astil de la
flecha `b`, y las tres líneas del centro son convexas en las cuatro
interpretaciones: el filtrado deja `[mas]` aunque no haya condición de
borde, porque la deducción sale de las uniones, no del contorno. La línea
de `b` a `e` es una aleta del contorno: sin la condición de borde puede
ser un contorno con el cubo a la derecha o una arista cóncava contra una
pared, `[menos, der]`; con la condición de borde, solo `der`.

<!-- contexto: capitulo-80/soluciones.pl -->
```prolog
?- escribir_posibles(cubo, sin_borde).
ab: [mas]
ac: [mas]
ad: [mas]
be: [menos,der]
bg: [menos,izq]
ce: [menos,izq]
cf: [menos,der]
df: [menos,izq]
dg: [menos,der]
true.
```

## 2

`setof/3` reúne las etiquetas de la posición I en todas las entradas del
tipo, ordenadas y sin repetir; `Ls^` dice que la entrada no forma parte de
la respuesta.

<!-- ejemplo: capitulo-80/soluciones.pl predicado: posibles_en/3 -->
```prolog
%!  posibles_en(?Tipo, ?I:integer, -Es:list) is nondet.
%
%   Es son las etiquetas que la línea I de una unión de Tipo tiene en
%   alguna entrada del catálogo, ordenadas.
posibles_en(Tipo, I, Es) :-
    setof(E, Ls^( union_posible(Tipo, Ls), nth1(I, Ls, E) ), Es).
```

```prolog
?- posibles_en(flecha, 2, Es).
Es = [mas, menos].

?- posibles_en(te, 3, Es).
Es = [der, izq, mas, menos].
```

## 3

El producto de los tamaños de los dominios es la cantidad de
combinaciones que una búsqueda sin filtrado tendría que considerar, una
entrada por unión.

<!-- ejemplo: capitulo-80/soluciones.pl predicado: combinaciones/4 producto/3 -->
```prolog
%!  combinaciones(+F, +Modo, +Momento, -N:integer) is semidet.
%
%   N es el producto de los tamaños de los dominios del dibujo F en el
%   Momento, inicial o filtrado.
combinaciones(F, Modo, Momento, N) :-
    tamanos(F, Modo, Momento, Ts),
    pairs_values(Ts, Ns),
    foldl(producto, Ns, 1, N).

%!  producto(+X:integer, +P0:integer, -P:integer) is det.
%
%   P es P0 multiplicado por X.
producto(X, P0, P) :-
    P is P0 * X.
```

```prolog
?- combinaciones(cubo, sin_borde, inicial, N).
N = 29160.

?- combinaciones(poiuyt, sin_borde, filtrado, N).
N = 2073600.
```

Las cuatro cifras coinciden con las de Norvig: 29 160 y 216 para el cubo,
544 195 584 y 2 073 600 para el poiuyt.

## 4

Las líneas apoyadas se fijan en `menos` antes de elegir, como hace
`fijas/3` con el contorno; una línea que el problema ya fijó con otra
etiqueta hace fallar `apoyar/2`.

<!-- ejemplo: capitulo-80/soluciones.pl predicado: etiquetar_apoyado/3 apoyar/2 -->
```prolog
%!  etiquetar_apoyado(+F, +Apoyadas:list, -Lineas:list) is nondet.
%
%   Lineas es una interpretación del dibujo F, sin la condición de borde,
%   en la que cada línea A-B de Apoyadas es cóncava.
etiquetar_apoyado(F, Apoyadas, Lineas) :-
    problema(F, sin_borde, Lineas, Uniones0),
    maplist(apoyar(Lineas), Apoyadas),
    ordenar(vecindad, F, Uniones0, Uniones),
    maplist(elegir, Uniones).

%!  apoyar(+Lineas:list, +Par) is semidet.
%
%   La línea entre las puntas de Par = A-B es cóncava en Lineas.
apoyar(Lineas, A-B) :-
    linea(A, B, L),
    memberchk(L-menos, Lineas).
```

```prolog
?- aggregate_all(count, etiquetar_apoyado(cubo, [d-g], _), N).
N = 1.

?- once(etiquetar_apoyado(cubo, [d-g], Ls)), memberchk((d-f)-E, Ls).
Ls = [a-b-mas, a-c-mas, a-d-mas, b-e-der, b-g-izq, c-e-izq, c-f-der, ... - ... - menos, ... - ...],
E = menos.
```

Es la segunda interpretación de la
[sección 80.4](index.md#804-version-2-generar-y-probar), el cubo apoyado en el
piso: basta con apoyar una de las dos aristas de abajo, y la flecha `d`
obliga a que la otra también sea cóncava.

## 5

El segundo cubo es el primero corrido 80 unidades a la derecha, con los
puntos renombrados por `copia/2`:

<!-- ejemplo: capitulo-80/soluciones.pl predicado: copia/2 -->
```prolog
%!  copia(?P0, ?P) is nondet.
%
%   P es el punto del segundo cubo que corresponde al punto P0 del primero.
copia(P0, P) :-
    member(P0-P, [a-h, b-i, c-j, d-k, e-l, f-m, g-n]).
```

Cada cubo, solo, tiene cuatro interpretaciones sin borde y una con borde,
y los cubos no comparten ninguna línea: se esperan 4 · 4 = 16 y 1 · 1 = 1.

```prolog
?- interpretaciones_waltz(dos_cubos, sin_borde, N).
N = 16.

?- interpretaciones_waltz(dos_cubos, borde, N).
N = 4.

?- contorno(dos_cubos, C).
C = [g, b, e, c, f, d].
```

Con borde quedan cuatro, no una: `contorno/2` recorre la cara exterior
desde el punto de más a la izquierda, y esa cara solo toca el primer cubo.
El dibujo tiene dos componentes, y el contorno del segundo no se fija. Para
dibujos de varias piezas separadas, la condición de borde debería recorrer
el contorno de cada componente.

## 6

Una línea es ambigua si las interpretaciones le dan al menos dos
etiquetas distintas:

<!-- ejemplo: capitulo-80/soluciones.pl predicado: ambiguas/3 ambigua_en/2 -->
```prolog
%!  ambiguas(+F, +Modo, -Ls:list) is det.
%
%   Ls son las líneas del dibujo F que tienen etiquetas distintas en
%   distintas interpretaciones.
ambiguas(F, Modo, Ls) :-
    todas(waltz, F, Modo, Todas),
    lineas(F, Lineas),
    include(ambigua_en(Todas), Lineas, Ls).

%!  ambigua_en(+Todas:list, +L) is semidet.
%
%   La línea L tiene al menos dos etiquetas en las interpretaciones Todas.
ambigua_en(Todas, L) :-
    findall(E, ( member(Ls, Todas), memberchk(L-E, Ls) ), Es0),
    sort(Es0, [_, _|_]).
```

```prolog
?- ambiguas(cubo, sin_borde, Ls).
Ls = [b-e, b-g, c-e, c-f, d-f, d-g].

?- ambiguas(bloques, sin_borde, Ls), length(Ls, N).
Ls = [b-e, b-g, d-f, d-g, i-l, i-n, j-l, j-m, ... - ...|...],
N = 10.
```

En el cubo, las seis líneas del contorno: las del centro son convexas en
las cuatro interpretaciones. En los dos cubos, las líneas que llegan a las
tes `n` y `o` desde el cubo de adelante, `c-n`, `e-n`, `c-o` y `f-o`, no
son ambiguas: forman la barra de una te, que en el catálogo es siempre un
contorno con el cuerpo del lado opuesto al pie. Las tes deciden qué cubo
está adelante.

## 7

`map_list_to_pairs/3` asocia a cada unión la cantidad de entradas de su
tipo, y `keysort/2` las ordena por esa cantidad, conservando el orden de
las que empatan.

<!-- ejemplo: capitulo-80/soluciones.pl predicado: etiquetar_por_catalogo/3 entradas/2 -->
```prolog
%!  etiquetar_por_catalogo(+F, +Modo, -Lineas:list) is nondet.
%
%   Como etiquetar_por_uniones/4, eligiendo primero las uniones cuyo tipo
%   tiene menos entradas en el catálogo.
etiquetar_por_catalogo(F, Modo, Lineas) :-
    problema(F, Modo, Lineas, Uniones0),
    map_list_to_pairs(entradas, Uniones0, Pares),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Uniones),
    maplist(elegir, Uniones).

%!  entradas(+U, -N:integer) is det.
%
%   N es la cantidad de entradas del catálogo para el tipo de la unión U.
entradas(u(_, Tipo, _), N) :-
    cantidad(Tipo, N),
    !.
```

| `escalera(N)`, sin borde | 2 | 4 | 6 |
|---|---:|---:|---:|
| catálogo | 15 707 | 963 782 | 77 371 066 |
| vecindad | 5 126 | 12 881 | 33 296 |

El orden por catálogo es mucho peor: las flechas de la escalera no
comparten líneas entre sí, así que elegir todas primero es elegir
combinaciones independientes, que se multiplican antes de que alguna
restricción las relacione. Tener pocas entradas no sirve si las uniones
elegidas una tras otra no están unidas.

## 8

<!-- ejemplo: capitulo-80/soluciones.pl predicado: crecimiento/3 -->
```prolog
%!  crecimiento(+Version, +Ns:list, -Filas:list) is det.
%
%   Filas son pares N-Inferencias de la Version en escalera(N) sin borde,
%   para cada N de Ns, medidas en una segunda ejecución.
crecimiento(Version, Ns, Filas) :-
    findall(N-I,
            ( member(N, Ns),
              medir(Version, escalera(N), sin_borde, _, _),
              medir(Version, escalera(N), sin_borde, _, I) ),
            Filas).
```

| N | 2 | 4 | 6 | 8 | 10 | 12 |
|---|---:|---:|---:|---:|---:|---:|
| vecindad | 5 126 | 12 881 | 33 296 | 99 511 | 342 022 | 1 280 773 |
| waltz | 11 557 | 20 744 | 30 959 | 41 145 | 51 471 | 61 953 |

El filtrado crece en proporción a N: cada dos escalones agregan unas
10 000 inferencias. La versión 3 crece en proporción geométrica: cada dos
escalones multiplican el costo por más de tres. Sin borde, cada línea del
contorno admite dos etiquetas, y una elección hecha al principio del
recorrido puede contradecirse recién en otra parte del dibujo. La vuelta
atrás cronológica cambia entonces la elección más reciente, que puede no
tener relación con la contradicción, y vuelve a recorrer todas las
combinaciones de las uniones intermedias antes de llegar a la elección
que la causó. El filtrado descubre la contradicción en la unión donde
aparece, porque después de cada elección propaga sus consecuencias por
todo el dibujo.

## 9

`propagar/5` ya devuelve la lista de las reducciones, como pares
`Union-Tamano`:

<!-- ejemplo: capitulo-80/soluciones.pl predicado: pasos/4 -->
```prolog
%!  pasos(+F, +Modo, -N:integer, -Uniones:list) is semidet.
%
%   N es la cantidad de reducciones de dominio que hace el filtrado del
%   dibujo F, y Uniones las uniones que se redujeron al menos una vez.
pasos(F, Modo, N, Uniones) :-
    inicio(F, Modo, Vecinos, D0),
    assoc_to_keys(D0, Cola),
    propagar(Cola, Vecinos, D0, _, Pasos),
    length(Pasos, N),
    pairs_keys(Pasos, Us),
    sort(Us, Uniones).
```

```prolog
?- pasos(cubo, sin_borde, N, Us).
N = 12,
Us = [a, b, c, d, e, f, g].

?- pasos(cubo, borde, N, Us).
N = 1,
Us = [a].
```

Con borde, `inicio/4` ya deja en una sola combinación cada flecha y cada
ele, porque las etiquetas del contorno están fijas; el filtrado solo
reduce el centro, de cinco combinaciones a una. Sin borde, las siete
uniones se reducen, algunas más de una vez.

## 10

Un prisma triangular apoyado sobre una cara rectangular, visto desde la
izquierda y un poco desde arriba: el triángulo del frente, `p`, `q`, `r`,
y la arista de arriba y la de la derecha que se alejan.

<!-- ejemplo: capitulo-80/soluciones.pl fragmento: punto(prisma, p, 0, 0). .. segmento(prisma, r2, r). -->
```prolog
punto(prisma, p, 0, 0).
punto(prisma, q, 40, 0).
punto(prisma, r, 20, 30).
punto(prisma, q2, 55, 10).
punto(prisma, r2, 35, 40).

segmento(prisma, p, q).
segmento(prisma, q, r).
segmento(prisma, r, p).
segmento(prisma, q, q2).
segmento(prisma, q2, r2).
segmento(prisma, r2, r).
```

```prolog
?- uniones(prisma, Us).
Us = [u(p, ele, [r, q]), u(q, flecha, [p, r, q2]), u(q2, ele, [q, r2]), u(r, flecha, [r2, q, p]), u(r2, ele, [q2, r])].

?- interpretaciones_waltz(prisma, sin_borde, N).
N = 4.

?- interpretaciones_waltz(prisma, borde, N).
N = 1.
```

Dos flechas y tres eles. Con borde, la interpretación es la del prisma que
flota delante del fondo: la arista `q-r`, entre las dos caras visibles, es
convexa, y las otras cinco son contornos; sin borde, como en el
cubo, las aristas del contorno pueden además ser cóncavas, apoyando el
prisma en una de sus caras.

## 11

<!-- ejemplo: capitulo-80/soluciones.pl predicado: etiquetar_cambiado/3 elegir_cambiada/1 -->
```prolog
%!  etiquetar_cambiado(+F, +Modo, -Lineas:list) is nondet.
%
%   Como etiquetar_por_uniones/4 con el orden por vecindad, con el
%   catálogo cambiado.
etiquetar_cambiado(F, Modo, Lineas) :-
    problema(F, Modo, Lineas, Uniones0),
    ordenar(vecindad, F, Uniones0, Uniones),
    maplist(elegir_cambiada, Uniones).

%!  elegir_cambiada(+U) is nondet.
%
%   Como elegir/1, con las entradas de union_cambiada/2.
elegir_cambiada(u(_, Tipo, Vistas)) :-
    union_cambiada(Tipo, Locales),
    maplist(vista, Vistas, Locales).
```

```prolog
?- aggregate_all(count, etiquetar_cambiado(cubo, sin_borde, _), N).
N = 0.
```

Ninguna interpretación, con borde ni sin él. El orden de las líneas es
parte de la entrada: `[mas, der, izq]` pone la etiqueta convexa en la
primera aleta y un contorno en el astil, que describe otra unión, una que
no existe en el mundo triedro. Al perder la flecha de contorno, las
flechas `b`, `c` y `d` del cubo solo pueden tener sus tres líneas
convexas o cóncavas, y las eles del hexágono, que necesitan al menos un
contorno, quedan sin combinación posible. Un catálogo es una tabla de
filas, y en una tabla cada posición tiene un significado: cambiar el
orden de una fila es cambiar la restricción.
