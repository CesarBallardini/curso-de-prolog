# Soluciones del capítulo 18 — Orden superior

El código de esta página está en `ejemplos/capitulo-18/soluciones.pl` y pasa
sus pruebas.

## 1

```prolog
?- maplist(succ, [1, 2, 3], L).
L = [2, 3, 4].

?- maplist(succ, L, [0, 1, 2]).
false.

?- foldl([X, A0, A]>>(A is A0 * X), [1, 2, 3, 4], 1, P).
P = 24.

?- partition([X]>>(X < 3), [3, 1, 4, 1, 5], I, E).
I = [1, 1],
E = [3, 4, 5].
```

`succ(X, Y)` relaciona un natural con el siguiente, en los dos sentidos. La
segunda consulta falla porque su primer paso es `succ(X, 0)`: 0 no es el
sucesor de ningún natural, y `maplist/3` exige que la relación se cumpla para
todos los pares. La tercera multiplica los elementos a partir de 1, el valor
neutro del producto. La cuarta separa los menores que 3 de los demás, cada
grupo en el orden original.

## 2

<!-- ejemplo: capitulo-18/soluciones.pl predicado: doble/2 dobles/2 positivo/1 todos_positivos/1 consulta: dobles([1, 2, 3], D). -->
```prolog
%!  doble(+N:number, -D:number) is det.
%
%   D es el doble de N.
doble(N, D) :-
    D is 2 * N.

%!  dobles(+L:list(number), -D:list(number)) is det.
%
%   D es la lista de los dobles de los elementos de L.
dobles(L, D) :-
    maplist(doble, L, D).

%!  positivo(+N:number) is semidet.
%
%   N es mayor que cero.
positivo(N) :-
    N > 0.

%!  todos_positivos(+L:list(number)) is semidet.
%
%   Todos los elementos de L son positivos.
todos_positivos(L) :-
    maplist(positivo, L).
```

```prolog
?- dobles([1, 2, 3], D).
D = [2, 4, 6].

?- todos_positivos([1, 0]).
false.
```

Cada predicado es una línea: el recorrido de las plantillas 12 y 11 lo hace
`maplist`, y lo que queda es la relación entre un elemento y el suyo.

## 3

<!-- ejemplo: capitulo-18/soluciones.pl predicado: largo/2 contar/3 maximo/2 dar_vuelta/2 consulta: dar_vuelta([a, b, c], R). -->
```prolog
%!  largo(+L:list, -N:integer) is det.
%
%   N es la cantidad de elementos de L.
largo(L, N) :-
    foldl(contar, L, 0, N).

%!  contar(+X, +Hasta:integer, -Total:integer) is det.
%
%   Total es Hasta más uno; X no interviene.
contar(_, Hasta, Total) :-
    Total is Hasta + 1.

%!  maximo(+L:list(number), -Max:number) is semidet.
%
%   Max es el mayor elemento de L. Falla con la lista vacía.
maximo([Primero|Resto], Max) :-
    foldl([X, M0, M]>>(M is max(X, M0)), Resto, Primero, Max).

%!  dar_vuelta(+L:list, -R:list) is det.
%
%   R tiene los elementos de L en el orden inverso.
dar_vuelta(L, R) :-
    foldl([X, Hasta, [X|Hasta]]>>true, L, [], R).
```

```prolog
?- largo([], N).
N = 0.

?- maximo([], M).
false.

?- dar_vuelta([a, b, c], R).
R = [c, b, a].
```

`maximo/2` falla con la lista vacía: no tiene un valor inicial que sirva para
todas las listas, y toma el primer elemento, que la lista vacía no tiene.
`largo/2` empieza en 0 y `dar_vuelta/2` en `[]`, y los dos responden con la
lista vacía. En `dar_vuelta/2`, el paso antepone cada elemento a lo acumulado:
el primero de la entrada queda último, como en el `dar_vuelta/2` con
acumulador del [capítulo 8](../capitulo-08-aritmetica/index.md). La lambda `[X, Hasta, [X|Hasta]]>>true` hace
todo el trabajo en sus parámetros, y su cuerpo no tiene nada que hacer.

## 4

<!-- ejemplo: capitulo-18/soluciones.pl predicado: conservar/3 conservar_/3 descartar/3 descartar_/3 consulta: conservar(positivo, [1, -1, 2], L). -->
```prolog
%!  conservar(:Condicion, +L:list, -Cumplen:list) is det.
%
%   Cumplen son los elementos de L que cumplen Condicion, en su orden.
conservar(Condicion, L, Cumplen) :-
    conservar_(L, Condicion, Cumplen).

%!  conservar_(+L:list, :Condicion, -Cumplen:list) is det.
%
%   El recorrido de conservar/3, con la lista primero.
conservar_([], _, []).
conservar_([X|Xs], Condicion, Cumplen) :-
    (   call(Condicion, X)
    ->  Cumplen = [X|Resto]
    ;   Cumplen = Resto
    ),
    conservar_(Xs, Condicion, Resto).

%!  descartar(:Condicion, +L:list, -NoCumplen:list) is det.
%
%   NoCumplen son los elementos de L que no cumplen Condicion, en su orden.
descartar(Condicion, L, NoCumplen) :-
    descartar_(L, Condicion, NoCumplen).

%!  descartar_(+L:list, :Condicion, -NoCumplen:list) is det.
%
%   El recorrido de descartar/3, con la lista primero.
descartar_([], _, []).
descartar_([X|Xs], Condicion, NoCumplen) :-
    (   call(Condicion, X)
    ->  NoCumplen = Resto
    ;   NoCumplen = [X|Resto]
    ),
    descartar_(Xs, Condicion, Resto).
```

```prolog
?- conservar(positivo, [1, -1, 2], L).
L = [1, 2].

?- descartar(positivo, [1, -1, 2], L).
L = [-1].
```

Los dos recorren con la lista primero, como `cada_uno_/2` de la
[sección 18.6](index.md#186-escribir-un-predicado-de-orden-superior), y deciden con `->`: la condición se usa como prueba, y
solo cuenta su primera respuesta, como en `include/3`. La declaración
`meta_predicate` marca con `1` el argumento que se llama con un argumento más,
tanto en el predicado público como en el que recorre.

## 5

```prolog
?- maplist([X]>>(X = Y), [a, b]).
true.

?- maplist({Y}/[X]>>(X = Y), [a, b]).
false.
```

En la primera, `Y` no está entre llaves: cada llamada de la lambda trabaja con
una copia nueva de `Y`, la liga a `a` o a `b`, y la `Y` de la consulta queda
libre. En la segunda, `{Y}` hace que las dos llamadas compartan `Y`, que no
puede ser `a` y `b` a la vez.

<!-- ejemplo: capitulo-18/soluciones.pl predicado: todos_hijos_de/2 consulta: todos_hijos_de(P, [luis, eva]). -->
```prolog
%!  todos_hijos_de(?P, +Hijos:list) is nondet.
%
%   P es el padre de todos los Hijos. {P} hace que la lambda comparta P con
%   la cláusula: todas las llamadas buscan el mismo padre.
todos_hijos_de(P, Hijos) :-
    maplist({P}/[H]>>padre(P, H), Hijos).
```

```prolog
?- todos_hijos_de(P, [luis, eva]).
P = pedro.

?- todos_hijos_de(P, [ana, luis]).
false.
```

Sin las llaves, `todos_hijos_de(P, [ana, luis])` se cumple y deja `P` libre:
cada llamada encuentra el padre de un hijo, cada una con su copia de `P`. La
lambda no es la única solución: la clausura `padre(P)` fija el primer
argumento y comparte `P` sin necesidad de llaves, y
`maplist(padre(P), Hijos)` es la forma más corta.

## 6

<!-- ejemplo: capitulo-18/soluciones.pl predicado: mi_foldl/4 mi_foldl_/4 consulta: mi_foldl(contar, [a, b, c], 0, N). -->
```prolog
%!  mi_foldl(:Paso, +L:list, +V0, -V) is semidet.
%
%   V es el resultado de aplicar Paso a cada elemento de L, de izquierda a
%   derecha, a partir de V0: call(Paso, X, Antes, Despues). Falla si Paso
%   falla para algún elemento; con un Paso det, es det.
mi_foldl(Paso, L, V0, V) :-
    mi_foldl_(L, Paso, V0, V).

%!  mi_foldl_(+L:list, :Paso, +V0, -V) is semidet.
%
%   El recorrido de mi_foldl/4, con la lista primero.
mi_foldl_([], _, V, V).
mi_foldl_([X|Xs], Paso, V0, V) :-
    call(Paso, X, V0, V1),
    mi_foldl_(Xs, Paso, V1, V).
```

La declaración, al principio del archivo, es
`:- meta_predicate mi_foldl(3, +, +, -), mi_foldl_(+, 3, +, -).`

- `:Paso` es un objetivo, y su número en la declaración, `3`, dice cuántos
  argumentos le agrega `call/N`: el elemento, el valor anterior y el nuevo.
- `+L` es la lista que se recorre, y debe llegar ligada: con la lista libre,
  el predicado generaría listas de longitud creciente.
- `+V0` es el valor inicial y `-V` el final.

La determinación depende de `Paso`. Con un paso `det`, `mi_foldl/4` es `det`:
la lista primero en `mi_foldl_/4` evita que quede la alternativa de la
[sección 18.6](index.md#186-escribir-un-predicado-de-orden-superior). Con un paso que puede fallar, falla. El encabezado declara
`semidet`, el caso general para un paso que es `det` o `semidet`, y lo explica
en el comentario.

## 7

<!-- ejemplo: capitulo-18/soluciones.pl predicado: materias_cursando/2 consulta: legajos(Ls), informe(materias_cursando, Ls, F). -->
```prolog
%!  materias_cursando(+Legajo:integer, -Cantidad:integer) is det.
%
%   Cantidad es la cantidad de materias que el alumno Legajo está cursando.
materias_cursando(Legajo, Cantidad) :-
    aggregate_all(count, inscripcion(Legajo, _, cursando), Cantidad).
```

```prolog
?- legajos(Ls), informe(materias_cursando, Ls, F).
Ls = [101, 102, 103, 104, 105, 106, 107],
F = [101-1, 102-0, 103-1, 104-0, 105-1, 106-0, 107-0].
```

Aparecen todos los alumnos: `materias_cursando/2` es `det`, y responde 0 para
los que no cursan nada. `promedio_de_alumno/2` falla para un alumno sin
notas, y `informe/3`, con `convlist/3`, omite a ese alumno. La diferencia está
en el cálculo, no en el informe.

## 8

`informe/3` no necesita cambios: no depende de que las claves sean legajos.

```prolog
?- materias(Ms), informe(promedio_de_materia, Ms, F).
Ms = [am1, alg, log, am2, pp, ssl, bd],
F = [am1-6.25, alg-5.75, log-7, am2-7, pp-8].
```

`mostrar_informe/2` del capítulo, en cambio, busca el nombre de cada clave
con `alumno/4`. `mostrar_informe/3` recibe ese paso como argumento:

<!-- ejemplo: capitulo-18/soluciones.pl predicado: nombre_de_alumno/2 nombre_de_materia/2 mostrar_informe/3 consulta: materias(Ms), informe(promedio_de_materia, Ms, F), mostrar_informe(nombre_de_materia, 'Promedios', F). -->
```prolog
%!  nombre_de_alumno(+Legajo:integer, -Nombre:atom) is semidet.
%
%   Nombre es el nombre del alumno Legajo.
nombre_de_alumno(Legajo, Nombre) :-
    alumno(Legajo, Nombre, _, _).

%!  nombre_de_materia(+Codigo:atom, -Nombre:atom) is semidet.
%
%   Nombre es el nombre de la materia Codigo.
nombre_de_materia(Codigo, Nombre) :-
    materia(Codigo, Nombre, _).

%!  mostrar_informe(:Nombre, +Titulo:atom, +Filas:list(pair)) is semidet.
%
%   Escribe Titulo y una línea por fila, con la clave, el nombre que le da
%   call(Nombre, Clave, N) y el valor. Falla en la primera fila cuya clave no
%   tiene nombre.
mostrar_informe(Nombre, Titulo, Filas) :-
    format("~w~n", [Titulo]),
    maplist({Nombre}/[Clave-Valor]>>( call(Nombre, Clave, N),
                                      format("  ~w ~w: ~w~n",
                                             [Clave, N, Valor]) ),
            Filas).
```

```prolog
?- materias(Ms), informe(promedio_de_materia, Ms, F), mostrar_informe(nombre_de_materia, 'Promedios', F).
Promedios
  am1 analisis_1: 6.25
  alg algebra: 5.75
  log logica: 7
  am2 analisis_2: 7
  pp paradigmas: 8
Ms = [am1, alg, log, am2, pp, ssl, bd],
F = [am1-6.25, alg-5.75, log-7, am2-7, pp-8].
```

Sintaxis y bases de datos no tienen notas, y el informe las omite. La lambda
de `mostrar_informe/3` declara `{Nombre}` entre llaves, y el encabezado marca
`Nombre` con `:` y la declaración con `2`: se llama con la clave y el nombre.

## 9

<!-- ejemplo: capitulo-18/soluciones.pl predicado: jugar/2 jugada/3 todas_descubiertas/1 consulta: jugar([1-6, 6-1], Resultado). -->
```prolog
%!  jugar(+Jugadas:list(pair), -Resultado) is det.
%
%   Resultado es el estado de la partida después de Jugadas, una lista de
%   celdas Fila-Columna: perdida(Celda) si una jugada cae en una mina, ganada
%   si quedan descubiertas todas las celdas sin mina, o
%   en_curso(Descubiertas).
jugar(Jugadas, Resultado) :-
    foldl(jugada, Jugadas, en_curso([]), Resultado).

%!  jugada(+Celda:pair, +Antes, -Despues) is det.
%
%   Despues es el estado de la partida después de un clic en Celda. Una
%   partida perdida o ganada no cambia.
jugada(F-C, Antes, Despues) :-
    (   Antes \= en_curso(_)
    ->  Despues = Antes
    ;   mina(F, C)
    ->  Despues = perdida(F-C)
    ;   Antes = en_curso(Vistas),
        descubrir(F-C, Vistas, Descubiertas),
        (   todas_descubiertas(Descubiertas)
        ->  Despues = ganada
        ;   Despues = en_curso(Descubiertas)
        )
    ).

%!  todas_descubiertas(+Descubiertas:list) is semidet.
%
%   Toda celda sin mina del tablero está en Descubiertas.
todas_descubiertas(Descubiertas) :-
    tamanio(Filas, Columnas),
    forall(( between(1, Filas, F),
             between(1, Columnas, C),
             \+ mina(F, C) ),
           memberchk(F-C, Descubiertas)).
```

```prolog
?- jugar([1-6, 1-1, 2-1], R).
R = perdida(1-1).
```

El estado de la partida es el valor acumulado de `foldl/4`. `jugada/3` lo
deja igual cuando la partida ya terminó, de modo que los clics que siguen a
una mina no cambian el resultado. `todas_descubiertas/1` es el [Patrón 13](../patrones.md#13-comprobar-para-todos): toda
celda sin mina está en la lista. Las pruebas cubren los tres resultados: una
partida en curso con veinte celdas descubiertas, una perdida y una ganada, con
la lista de todas las celdas sin mina como jugadas.

## 10

<!-- ejemplo: capitulo-18/soluciones.pl predicado: descubrir_a_lo_ancho/2 a_lo_ancho/3 consulta: descubrir_a_lo_ancho(1-6, D). -->
```prolog
%!  descubrir_a_lo_ancho(+Celda:pair, -Descubiertas:list) is det.
%
%   Descubiertas son las celdas que descubre un clic en Celda, en el orden en
%   que se descubren: primero la celda, después sus vecinas, después las
%   vecinas de estas. Pendientes es la cola de celdas por examinar.
descubrir_a_lo_ancho(Celda, Descubiertas) :-
    a_lo_ancho([Celda], [], Invertidas),
    reverse(Invertidas, Descubiertas).

%!  a_lo_ancho(+Pendientes:list, +Vistas:list, -Descubiertas:list) is det.
%
%   Descubiertas son las celdas de Vistas más las que se descubren desde las
%   Pendientes, la última descubierta primero.
a_lo_ancho([], Vistas, Vistas).
a_lo_ancho([F-C|Pendientes], Vistas, Descubiertas) :-
    (   memberchk(F-C, Vistas)
    ->  a_lo_ancho(Pendientes, Vistas, Descubiertas)
    ;   minas_alrededor(F, C, 0)
    ->  findall(VF-VC, vecina(F, C, VF, VC), Vecinas),
        append(Pendientes, Vecinas, Siguientes),
        a_lo_ancho(Siguientes, [F-C|Vistas], Descubiertas)
    ;   a_lo_ancho(Pendientes, [F-C|Vistas], Descubiertas)
    ).
```

```prolog
?- descubrir_a_lo_ancho(1-6, D).
D = [1-6, 1-5, 2-5, 2-6, 1-4, 2-4, 3-4, 3-5, ... - ...|...].
```

`a_lo_ancho/3` lleva una **cola** de celdas pendientes: agrega las vecinas al
final, con `append/3`, y examina primero las que llegaron antes. El orden de
descubrimiento avanza por distancias: la celda, sus vecinas, las vecinas de
estas. `descubrir/3`, con `foldl/4`, termina de explorar desde la primera
vecina antes de pasar a la segunda: es un recorrido en profundidad. El
conjunto de celdas es el mismo, y la prueba `mismas_celdas` lo verifica
ordenando las dos listas. La diferencia de orden importa en el
[capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md), donde el recorrido a lo ancho encuentra el camino más corto.
