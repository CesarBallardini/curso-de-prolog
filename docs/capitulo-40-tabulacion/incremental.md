# Tablas incrementales, hilos, costo y el intérprete con tablas

Esta página continúa la página
[Subsunción de respuestas y negación tabulada](subsuncion.md#404-negacion-tabulada) del
[capítulo 40](index.md), con las secciones [40.5](#405-tabulacion-incremental)
a [40.7](#407-el-interprete-con-tablas-las-correlativas): las tablas que
siguen los cambios de un predicado dinámico, las tablas y los hilos, lo que
cuesta una tabla, medido en esta máquina, y dos aplicaciones, el intérprete
del sistema experto con tablas y la cadena de correlativas de
*Inscripciones*. Los ejemplos están en `incremental.pl`, `compartida.pl`,
`costo.pl`, `experto.pl` y `requisitos.pl`, en `ejemplos/capitulo-40/`, con
sus pruebas; `compartida.pl` crea hilos y `requisitos.pl` carga los datos
del [capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md), y
ninguno de los dos corre en SWISH.

## 40.5 Tabulación incremental

Una tabla guarda las respuestas calculadas con los datos del momento en que
se completó. Si un predicado dinámico del que depende cambia, la tabla no se
actualiza. `incremental.pl` tiene una red con dos enlaces y la misma relación de
alcance tabulada dos veces, de la manera común y como **incremental**:

<!-- ejemplo: capitulo-40/incremental.pl fragmento: :- dynamic enlace/2 as incremental. .. enlace(b, c). -->
```prolog
:- dynamic enlace/2 as incremental.

% enlace(X, Y): hay un enlace de X a Y.
enlace(a, b).
enlace(b, c).
```

<!-- ejemplo: capitulo-40/incremental.pl fragmento: :- table alcanza_fijo/2. .. enlace(Z, Y). -->
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

<!-- ejemplo: capitulo-40/incremental.pl fragmento: :- table alcanza/2 as incremental. .. enlace(Z, Y). -->
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
?- findall(Y, alcanza(a, Y), Antes0), msort(Antes0, Antes), findall(Y, alcanza_fijo(a, Y), AntesFijo0), msort(AntesFijo0, AntesFijo), assertz(enlace(c, d)), findall(Y, alcanza(a, Y), Despues0), msort(Despues0, Despues), findall(Y, alcanza_fijo(a, Y), DespuesFijo0), msort(DespuesFijo0, DespuesFijo).
Antes0 = Antes, Antes = AntesFijo0, AntesFijo0 = AntesFijo, AntesFijo = DespuesFijo0, DespuesFijo0 = DespuesFijo, DespuesFijo = [b, c],
Despues0 = [b, d, c],
Despues = [b, c, d].
```

`alcanza_fijo/2` sigue respondiendo con la tabla de antes del cambio; con
esa tabla, el resultado es el de un predicado memorizado a mano que nadie
borró, el defecto que el [Patrón 17](../patrones.md#17-memorizacion-con-assertz) pide evitar con un predicado
que borre lo guardado. `abolish_all_tables/0` es ese predicado, y
`restaurar/0`, que usan las pruebas, lo llama después de reponer los
enlaces:

<!-- ejemplo: capitulo-40/incremental.pl predicado: restaurar/0 -->
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
[capítulo 38](../capitulo-38-concurrencia-y-paralelismo/index.md#383-estado-compartido). La declaración `as shared` hace que la tabla sea
una sola para todos los hilos: cuando un hilo la completa, los demás la
usan, y si dos hilos piden a la vez la misma tabla incompleta, uno la
calcula y el otro espera. `compartida.pl` tiene las dos versiones de
Fibonacci:

<!-- ejemplo: capitulo-40/compartida.pl fragmento: :- table fib_compartida/2 as shared. .. F is F1 + F2 -->
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

<!-- ejemplo: capitulo-40/compartida.pl predicado: en_otro_hilo/1 inferencias/2 -->
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
`guardado_local/2` de la memorización con hilos del [capítulo 38](../capitulo-38-concurrencia-y-paralelismo/index.md), sin los
repetidos que allí dejaba la tabla compartida escrita a mano:
`abolish_all_tables/0` borra también las tablas compartidas.

## 40.6 Lo que cuesta

`costo.pl` arma una red de N enlaces en fila, de 0 a N, sin ciclos, y
define el alcance de tres maneras: sin tabla con la recursión a la derecha,
que termina porque no hay ciclos, y tabulado con la recursión a cada lado.
`tablas/1` cuenta las tablas que existen:

<!-- ejemplo: capitulo-40/costo.pl predicado: cadena/1 alcanza_sin_tabla/2 tablas/1 -->
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

<!-- ejemplo: capitulo-40/costo.pl fragmento: :- table alcanza_der/2. .. alcanza_der(Z, Y). -->
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

<!-- ejemplo: capitulo-40/costo.pl fragmento: :- table alcanza_izq/2. .. enlace(Z, Y). -->
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
([sección 17.1](../capitulo-17-rendimiento/index.md#171-medir)):

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
con el segundo, lo hace la derecha ([ejercicio 13](#ejercicios)). La
memorización es otro caso: `fib_tabla(1000, F)` hace 40 031 inferencias, y
`fib_memo(1000, F)` del [capítulo 21](../capitulo-21-base-de-datos-dinamica/index.md#215-memorizacion), con `assertz/1`, hace 8 997: la
tabla cuesta unas cuatro veces más por valor que el hecho dinámico escrito a
mano, a cambio de no tener estado que borrar y de terminar también con
ciclos.

!!! question "Actividad"
    Predecir cuántas tablas deja `alcanza_der(50, Y)` después de
    `cadena(100)`, y cuántas `alcanza_izq(50, Y)`. Comprobarlo con
    `tablas/1`, y explicar por qué la primera no crea las tablas de los
    nodos 0 a 49.

## 40.7 El intérprete con tablas; las correlativas

### El sistema experto

La [sección 39.7](../capitulo-39-semantica-de-los-programas-logicos/negacion.md#397-las-reglas-del-sistema-experto) analizó las reglas del sistema experto con la
negación `no`: la base original es estratificada, y la versión que agrega
r13, «un ave que no es pingüino ni avestruz vuela», crea un ciclo positivo
con r4 (`ave`, `vuela`, `ave`) y dos negativos con r11 y r12. El intérprete
del [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md#347-el-sistema-experto-explica), que resuelve de arriba hacia abajo, entra en el
ciclo positivo con cualquier caso. Tiene además un costo menos visible:
cada hipótesis vuelve a probar las conclusiones intermedias, y `mamifero` se
prueba una vez para el guepardo, otra para el tigre, otra para la jirafa.
El encadenamiento hacia adelante del [capítulo 21](../capitulo-21-base-de-datos-dinamica/index.md) evitaba esa repetición
guardando cada conclusión con `assertz/1`.

`experto.pl` tiene las reglas, las versiones de la base y el intérprete sin
tabla, `probar_sin_tabla/3`, con `\+` para `no`. La versión tabulada separa
el intérprete en dos predicados: `probar/3` recorre las condiciones, y
`cierto/3`, tabulado, prueba cada conclusión una vez por conjunto de
observaciones:

<!-- ejemplo: capitulo-40/experto.pl predicado: probar/3 -->
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

<!-- ejemplo: capitulo-40/experto.pl fragmento: :- table cierto/3. .. probar(Version, Os, Condiciones). -->
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
[sección 40.4](subsuncion.md#404-negacion-tabulada):

<!-- ejemplo: capitulo-40/experto.pl predicado: diagnostico/3 -->
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

Son los resultados del modelo bien fundado de la [sección 39.7](../capitulo-39-semantica-de-los-programas-logicos/negacion.md#397-las-reglas-del-sistema-experto): con la
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
prueba, pero no guarda cómo, y el «¿cómo?» del [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md) necesita
reconstruirlo. El [ejercicio 15](#ejercicios) lo hace, usando la tabla para
elegir solo reglas cuyas condiciones son verdaderas.

### *Inscripciones*: la cadena de correlativas

El módulo `reglas` del [capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md#328-el-proyecto-inscripciones-se-entrega) calcula los requisitos de una materia
con `requisito/2`, la clausura transitiva de `correlativa/2`, y guarda cada
resultado en el predicado dinámico `requisitos_guardados/2`: es el
[Patrón 17](../patrones.md#17-memorizacion-con-assertz) aplicado a una relación. `requisito/2` da una respuesta por
cada cadena de correlativas, y bases de datos tiene a lógica como requisito
por dos caminos, por paradigmas y por sintaxis; por eso `requisitos_de/2`
ordena el resultado con `sort/2` antes de guardarlo. `requisitos.pl` es un
módulo que usa los datos del [capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md) y reemplaza las dos cosas por una
tabla:

<!-- ejemplo: capitulo-40/requisitos.pl fragmento: :- table requisito/2. .. correlativa(Intermedia, Requisito). -->
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

<!-- ejemplo: capitulo-40/requisitos.pl predicado: requisito_sin_tabla/2 requisitos_de/2 -->
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
%   Requisitos son todas las materias que se deben aprobar antes de cursar
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
`requisitos_guardados/2`, y la prueba `como_el_32` de `requisitos.plt`
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
    | C7 | 69 pruebas en nueve archivos; comparan las respuestas ordenadas, porque una tabla no tiene orden fijo; cada versión tabulada se compara con la que no lo está donde esta termina (`requisitos_de/2` con el del [capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md), `fib_tabla/2` con `fib/2`), y lo que no termina se prueba con `call_with_inference_limit/3`, sin depender del tiempo de la máquina |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

11. **(1)** Escribir `camino_der/2`, la relación de camino con la
    recursión a la derecha, tabulada. ¿Da las mismas respuestas que
    `camino/2`? Contar con `current_table/2` cuántas tablas deja
    `camino_der(a, Y)` y cuántas `camino(a, Y)`, y explicar la diferencia.
12. ★ **(2)** Con `incremental.pl` cargado, predecir las respuestas de
    `alcanza(c, Y)` y de `alcanza_fijo(c, Y)` después de
    `assertz(enlace(c, a))`, y después de un `retract(enlace(a, b))`.
    Comprobarlo, y decir qué hace falta para que `alcanza_fijo/2` quede al
    día.
13. **(2)** Con `costo.pl` y `cadena(500)`, medir con `time/1`
    `aggregate_all(count, alcanza_izq(_, 500), N)` y lo mismo con
    `alcanza_der/2` y con `alcanza_sin_tabla/2`, y contar las tablas.
    Explicar por qué el resultado se invierte respecto de la consulta
    `alcanza_*(0, _)` de la [sección 40.6](#406-lo-que-cuesta).
14. ★ **(2)** Escribir, en un módulo que use los del
    [capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md), `habilita(Materia, Otra)`, tabulado: aprobar Materia
    es necesario, directa o indirectamente, para cursar Otra. Escribir
    después `materias_habilitadas(Legajo, Ms)`: las materias que el alumno
    todavía no aprobó ni cursa y cuyos requisitos aprobó todos.
15. **(3)** Escribir `como_tabulado(Version, Observaciones, Meta, Arbol)`,
    que construye el árbol de prueba de una conclusión verdadera con las
    formas `observado(M)`, `deducido(M, Regla, Arbol)`, `A y B` y `X > Y`
    del [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md). Usar `cierto/3` para elegir solo reglas cuyas
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
| Conjuntos de visitados y búsqueda en grafos de estados | [capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) |
| Tablas de transposición con tabulación | [capítulo 42](../capitulo-42-juegos/index.md) |
| `WITH RECURSIVE` frente a la tabulación | [capítulo 43](../capitulo-43-prolog-y-sql/index.md) |
| La clausura ε de un autómata, tabulada | [capítulo 52](../capitulo-52-proyecto-automatas-expresiones-regulares/index.md) |
| Análisis estático con tablas | [capítulo 59](../capitulo-59-proyecto-interpretacion-abstracta/index.md) |
| Un motor Datalog, de abajo hacia arriba, comparado con las tablas | [capítulo 86](../capitulo-86-proyecto-motor-datalog/index.md) |
| Preguntas en castellano evaluadas con tablas | [capítulo 88](../capitulo-88-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- David S. Warren, *Programming in Tabled Prolog*, borrador, Stony Brook
  University, 1999 — capítulo «Tabling and Datalog Programming».
  [Edición en línea del autor, en el archivo web](https://web.archive.org/web/20240628211257/https://www3.cs.stonybrook.edu/~warren/xsbbook/book.html).
  Esta página toma de allí el análisis de la cantidad de tablas según la
  dirección de la recursión. Warren escribe para XSB; los programas del
  capítulo usan la sintaxis y las primitivas de SWI-Prolog.
- Jan Wielemaker y otros, *SWI-Prolog Reference Manual*, sección «Tabled
  execution (SLG resolution)», con sus apartados sobre la tabulación
  incremental y las tablas compartidas.
  [En línea](https://www.swi-prolog.org/pldoc/man?section=tabling). Es la
  referencia de las directivas `incremental` y `shared`, de
  `abolish_all_tables/0` y de `current_table/2`.

Los programas del capítulo son propios, escritos para el curso: el grafo,
el juego y las reglas del sistema experto vienen de los capítulos
[34](../capitulo-34-introspeccion-y-metainterpretes/index.md) y
[39](../capitulo-39-semantica-de-los-programas-logicos/index.md), las
correlativas del [capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md),
y las mediciones se hicieron en esta máquina con SWI-Prolog 9.2.9.
