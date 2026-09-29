# Tablas incrementales, hilos y costo

Esta página contiene las secciones [39.5](index.md#395-tabulacion-incremental)
y [39.6](index.md#396-lo-que-cuesta) del [capítulo 39](index.md): las
tablas que siguen los cambios de un predicado dinámico, las tablas y los
hilos, y lo que cuesta una tabla, medido en esta máquina. Los ejemplos
están en `incremental.pl`, `compartida.pl` y `costo.pl`, en
`ejemplos/capitulo-39/`, con sus pruebas; `compartida.pl` crea hilos y no
corre en SWISH.

## Tabulación incremental

Una tabla guarda las respuestas calculadas con los datos del momento en que
se completó. Si un predicado dinámico del que depende cambia, la tabla no se
actualiza. `incremental.pl` tiene una red con dos enlaces y la misma relación de
alcance tabulada dos veces, de la manera común y como **incremental**:

<!-- ejemplo: capitulo-39/incremental.pl fragmento: :- dynamic enlace/2 as incremental. .. enlace(b, c). -->
```prolog
:- dynamic enlace/2 as incremental.

% enlace(X, Y): hay un enlace de X a Y.
enlace(a, b).
enlace(b, c).
```

<!-- ejemplo: capitulo-39/incremental.pl fragmento: :- table alcanza_fijo/2. .. enlace(Z, Y). -->
```prolog
:- table alcanza_fijo/2.

%!  alcanza_fijo(?X, ?Y) is nondet.
%
%   Desde X se llega a Y por uno o más enlaces. La tabla no sigue los
%   cambios de enlace/2.
alcanza_fijo(X, Y) :-
    enlace(X, Y).
alcanza_fijo(X, Y) :-
    alcanza_fijo(X, Z),
    enlace(Z, Y).
```

<!-- ejemplo: capitulo-39/incremental.pl fragmento: :- table alcanza/2 as incremental. .. enlace(Z, Y). -->
```prolog
:- table alcanza/2 as incremental.

%!  alcanza(?X, ?Y) is nondet.
%
%   La misma relación, con una tabla incremental: sigue los cambios de
%   enlace/2.
alcanza(X, Y) :-
    enlace(X, Y).
alcanza(X, Y) :-
    alcanza(X, Z),
    enlace(Z, Y).
```

`:- dynamic enlace/2 as incremental` declara que los cambios de `enlace/2`
se registran, y `:- table alcanza/2 as incremental` que la tabla depende de
ellos. Cuando un `assertz/1` o un `retract/1` cambia `enlace/2`, SWI-Prolog
marca como inválidas las tablas incrementales que usaron ese predicado,
directa o indirectamente, y la próxima llamada las recalcula:

```prolog
?- findall(Y, alcanza(a, Y), Antes), findall(Y, alcanza_fijo(a, Y), AntesFijo), assertz(enlace(c, d)), findall(Y, alcanza(a, Y), Despues), findall(Y, alcanza_fijo(a, Y), DespuesFijo).
Antes = AntesFijo, AntesFijo = DespuesFijo, DespuesFijo = [b, c],
Despues = [b, d, c].
```

`alcanza_fijo/2` sigue respondiendo con la tabla de antes del cambio; con
esa tabla, el resultado es el de un predicado memorizado a mano que nadie
borró, el defecto que el [Patrón 17](../patrones.md#17-memorizacion-con-assertz) pide evitar con un predicado
que borre lo guardado. `abolish_all_tables/0` es ese predicado, y
`restaurar/0`, que usan las pruebas, lo llama después de reponer los
enlaces:

<!-- ejemplo: capitulo-39/incremental.pl predicado: restaurar/0 -->
```prolog
%!  restaurar is det.
%
%   Deja la red con sus dos enlaces iniciales y borra las tablas.
restaurar :-
    retractall(enlace(_, _)),
    assertz(enlace(a, b)),
    assertz(enlace(b, c)),
    abolish_all_tables.
```

La tabla incremental no necesita ese paso, pero tiene su costo: cada cambio
de `enlace/2` recorre el grafo de dependencias entre tablas, y la tabla
invalidada se recalcula entera en la próxima consulta. Conviene cuando las
consultas son muchas más que los cambios. La declaración tiene que estar en
los dos lados: una tabla incremental que usa un predicado dinámico no
declarado `incremental` no se invalida con sus cambios, y un predicado
tabulado sin `incremental` entre la tabla y los datos corta la cadena de
invalidación.

### Tablas y hilos

Las tablas de SWI-Prolog son **de cada hilo**: lo que un hilo calcula en una
tabla común no lo ve ningún otro, como los predicados `thread_local` del
[capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md#373-estado-compartido). La declaración `as shared` hace que la tabla sea
una sola para todos los hilos: cuando un hilo la completa, los demás la
usan, y si dos hilos piden a la vez la misma tabla incompleta, uno la
calcula y el otro espera. `compartida.pl` tiene las dos versiones de
Fibonacci:

<!-- ejemplo: capitulo-39/compartida.pl fragmento: :- table fib_compartida/2 as shared. .. F is F1 + F2 -->
```prolog
:- table fib_compartida/2 as shared.

%!  fib_compartida(+N:integer, -F:integer) is det.
%
%   La misma relación, con una tabla que comparten todos los hilos.
fib_compartida(N, F) :-
    (   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib_compartida(N1, F1),
        fib_compartida(N2, F2),
        F is F1 + F2
```

<!-- ejemplo: capitulo-39/compartida.pl predicado: en_otro_hilo/1 inferencias/2 -->
```prolog
%!  en_otro_hilo(:Meta) is semidet.
%
%   Ejecuta once(Meta) en un hilo nuevo y espera a que termine. Falla si
%   Meta falla o produce una excepción.
en_otro_hilo(Meta) :-
    thread_create(once(Meta), Id, []),
    thread_join(Id, true).

%!  inferencias(:Objetivo, -I:integer) is det.
%
%   I es la cantidad de inferencias que usa la primera respuesta de
%   Objetivo.
inferencias(Objetivo, I) :-
    statistics(inferences, I0),
    once(Objetivo),
    statistics(inferences, I1),
    I is I1 - I0.
```

```prolog
?- en_otro_hilo(fib_privada(300, _)), inferencias(fib_privada(300, _), I).
I = 12024.

?- en_otro_hilo(fib_compartida(300, _)), inferencias(fib_compartida(300, _), I).
I = 7.
```

`fib_privada/2` tiene una tabla común: el hilo principal no ve la que
completó el otro hilo, y recalcula los 300 valores. `fib_compartida/2`
encuentra la tabla completa. Es la diferencia entre `guardado/2` y
`guardado_local/2` de la memorización con hilos del [capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md), sin los
repetidos que allí dejaba la tabla compartida escrita a mano:
`abolish_all_tables/0` borra también las tablas compartidas.

## Lo que cuesta

`costo.pl` arma una red de N enlaces en fila, de 0 a N, sin ciclos, y
define el alcance de tres maneras: sin tabla con la recursión a la derecha,
que termina porque no hay ciclos, y tabulado con la recursión a cada lado.
`tablas/1` cuenta las tablas que existen:

<!-- ejemplo: capitulo-39/costo.pl predicado: cadena/1 alcanza_sin_tabla/2 tablas/1 -->
```prolog
%!  cadena(+N:integer) is det.
%
%   Reemplaza los enlaces por N enlaces en fila, de I a I + 1 para I de 0 a
%   N - 1, y borra las tablas.
cadena(N) :-
    must_be(nonneg, N),
    retractall(enlace(_, _)),
    abolish_all_tables,
    forall(between(1, N, J),
           ( I is J - 1,
             assertz(enlace(I, J)) )).

%!  alcanza_sin_tabla(?X, ?Y) is nondet.
%
%   Desde X se llega a Y por uno o más enlaces, sin tabla: termina solo si
%   la red no tiene ciclos.
alcanza_sin_tabla(X, Y) :-
    enlace(X, Y).
alcanza_sin_tabla(X, Y) :-
    enlace(X, Z),
    alcanza_sin_tabla(Z, Y).

%!  tablas(-N:integer) is det.
%
%   N es la cantidad de tablas que existen en este momento.
tablas(N) :-
    aggregate_all(count, current_table(_, _), N).
```

<!-- ejemplo: capitulo-39/costo.pl fragmento: :- table alcanza_der/2. .. alcanza_der(Z, Y). -->
```prolog
:- table alcanza_der/2.

%!  alcanza_der(?X, ?Y) is nondet.
%
%   La misma relación, tabulada, con la recursión a la derecha.
alcanza_der(X, Y) :-
    enlace(X, Y).
alcanza_der(X, Y) :-
    enlace(X, Z),
    alcanza_der(Z, Y).
```

<!-- ejemplo: capitulo-39/costo.pl fragmento: :- table alcanza_izq/2. .. enlace(Z, Y). -->
```prolog
:- table alcanza_izq/2.

%!  alcanza_izq(?X, ?Y) is nondet.
%
%   La misma relación, tabulada, con la recursión a la izquierda.
alcanza_izq(X, Y) :-
    enlace(X, Y).
alcanza_izq(X, Y) :-
    alcanza_izq(X, Z),
    enlace(Z, Y).
```

Con 500 enlaces, cada consulta desde un proceso nuevo, medido con `time/1`
([sección 16.1](../capitulo-16-rendimiento/index.md#161-medir)):

```text
?- cadena(500), time(aggregate_all(count, alcanza_sin_tabla(0, _), N)).
% 2,507 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
N = 500.

?- cadena(500), time(aggregate_all(count, alcanza_izq(0, _), N)), tablas(T).
% 6,057 inferences, 0.000 CPU in 0.001 seconds (0% CPU, Infinite Lips)
N = 500,
T = 1.

?- cadena(500), time(aggregate_all(count, alcanza_der(0, _), N)), tablas(T).
% 267,547 inferences, 0.063 CPU in 0.063 seconds (99% CPU, 4280752 Lips)
N = 500,
T = 501.
```

Tres observaciones, las tres medidas en esta máquina:

- **La tabla agrega trabajo donde Prolog no repite nada.** En una red sin
  ciclos ni caminos repetidos, `alcanza_sin_tabla/2` ya resuelve cada nodo
  una vez; la versión tabulada con la recursión a la izquierda hace 2,4
  veces sus inferencias, en crear la tabla, guardar cada respuesta y
  entregarla. Una segunda consulta igual, con la tabla completa, cuesta
  1 505 inferencias.
- **La dirección de la recursión decide cuántas tablas hay.** Con la
  recursión a la izquierda, todas las llamadas recursivas son variantes de
  `alcanza_izq(0, Y)` y usan una sola tabla. Con la recursión a la derecha,
  cada nodo intermedio es una llamada nueva, `alcanza_der(1, Y)`,
  `alcanza_der(2, Y)`, …, con su propia tabla: 501 tablas que guardan en
  total 125 250 respuestas, porque la del nodo k tiene los 500 − k nodos
  que siguen. Warren analiza esta diferencia en el capítulo «Tabling and
  Datalog Programming».
- **Las tablas ocupan memoria hasta que se borran.** Después de cada
  consulta, `statistics(table_space_used, B)` da 24 824 bytes con la
  recursión a la izquierda y 6 220 696 con la derecha, doscientas cincuenta
  veces más.

El trabajo de la recursión a la derecha crece con el cuadrado del largo, y
el de la izquierda linealmente:

| Enlaces | Sin tabla | Izquierda | Derecha | Derecha, segundos |
|---:|---:|---:|---:|---:|
| 500 | 2 507 | 6 057 | 267 547 | 0,063 |
| 1 000 | 5 007 | 12 057 | 1 035 047 | 0,222 |
| 2 000 | 10 007 | 24 057 | 4 070 047 | 0,907 |

La conclusión no es que la recursión a la izquierda sea siempre mejor: la
cantidad de tablas depende de qué argumentos llegan ligados. Con el primer
argumento ligado, la recursión a la izquierda reutiliza la llamada inicial;
con el segundo, lo hace la derecha ([ejercicio 13](index.md#ejercicios)). La
memorización es otro caso: `fib_tabla(1000, F)` hace 40 031 inferencias, y
`fib_memo(1000, F)` del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#205-memorizacion), con `assertz/1`, hace 8 997: la
tabla cuesta unas cuatro veces más por valor que el hecho dinámico escrito a
mano, a cambio de no tener estado que borrar y de terminar también con
ciclos.

!!! question "Actividad"
    Predecir cuántas tablas deja `alcanza_der(50, Y)` después de
    `cadena(100)`, y cuántas `alcanza_izq(50, Y)`. Comprobarlo con
    `tablas/1`, y explicar por qué la primera no crea las tablas de los
    nodos 0 a 49.
