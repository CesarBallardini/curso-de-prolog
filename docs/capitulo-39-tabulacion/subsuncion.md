# Subsunción de respuestas

Esta página contiene la sección [39.3](index.md#393-subsuncion-de-respuestas) del
[capítulo 39](index.md): las tablas que guardan, para cada llamada, solo la
mejor respuesta según un modo declarado en la directiva. El ejemplo está en
`distancias.pl`, en `ejemplos/capitulo-39/`, con sus pruebas, y corre en
SWISH.

## Subsunción de respuestas

`distancias.pl` tiene un grafo con longitudes y un ciclo, de d a a:

<!-- ejemplo: capitulo-39/distancias.pl predicado: tramo/3 -->
```prolog
% tramo(X, Y, D): hay un tramo de X a Y de longitud D.
tramo(a, b, 4).
tramo(a, c, 1).
tramo(c, b, 2).
tramo(b, d, 5).
tramo(d, a, 3).
```

La suma de las longitudes de un recorrido, tabulada como en la
[sección 39.1](index.md#391-table-recursion-a-la-izquierda-y-ciclos), no termina:

<!-- ejemplo: capitulo-39/distancias.pl fragmento: :- table suma_tramos/3. .. D is D0 + D1. -->
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

<!-- ejemplo: capitulo-39/distancias.pl fragmento: :- table distancia(_, _, min). .. D is D0 + D1. -->
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

<!-- ejemplo: capitulo-39/distancias.pl fragmento: :- table ruta(_, _, lattice(mas_corta/3)). .. append(Nodos0, [Y], Nodos). -->
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

<!-- ejemplo: capitulo-39/distancias.pl predicado: mas_corta/3 -->
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
