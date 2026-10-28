# Capítulo 38 — Concurrencia y paralelismo

Todos los programas del curso ejecutan una consulta por vez: un objetivo,
después el siguiente. SWI-Prolog puede correr varios objetivos a la vez, cada
uno en su propio **hilo**, dentro del mismo proceso y sobre la misma base de
datos. El servicio del [capítulo 31](../capitulo-31-servicios-web-rest/index.md) ya lo hacía sin decirlo: cada pedido lo
atiende un hilo distinto. Este capítulo muestra cómo se crean los hilos, cómo
se comunican, cómo se reparte un cálculo entre los núcleos de la máquina, y
sobre todo qué ocurre cuando dos hilos cambian el mismo dato: el cupo de una
materia, que con un solo hilo nunca se excedía, se excede.

Cada sección presenta un programa, la falla que aparece al correrlo con
varios hilos y la técnica que la corrige, con la medición en esta máquina.
El capítulo cumple tres anuncios: la base de datos y los hilos, y las
variables globales que pertenecen a un hilo, del
[capítulo 21](../capitulo-21-base-de-datos-dinamica/index.md); los hilos que atienden los pedidos de un servicio, de los
capítulos [31](../capitulo-31-servicios-web-rest/index.md) y [32](../capitulo-32-ejecutables-y-distribucion/index.md); y el servidor que atiende a varios clientes a
la vez, del [capítulo 37](../capitulo-37-interfaces-de-usuario/index.md). SWISH no permite crear hilos, colas, mutex
ni motores: ningún ejemplo del capítulo corre allí.

Las fuentes, citadas al final de cada página, son el manual de SWI-Prolog y «Purity», de
*The Power of Prolog* de Markus Triska: el código puro no tiene carreras.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- crear hilos con `thread_create/3`, esperarlos con `thread_join/2` y saber
  qué comparten: la base de datos sí, las pilas y las variables globales no;
- comunicar hilos con colas de mensajes y organizar un productor y varios
  consumidores sin que ninguno quede esperando para siempre;
- reconocer una condición de carrera sobre el estado compartido, y
  corregirla con `with_mutex/2` o con `transaction/3`, sabiendo qué
  garantiza y qué no `transaction/1`;
- repartir un cálculo entre los núcleos con `concurrent_maplist/3`,
  `concurrent_forall/2` y `first_solution/3`, y medir cuándo conviene;
- usar un motor como generador de respuestas o como corrutina;
- escribir manejadores de un servidor HTTP que sigan siendo correctos cuando
  varios hilos trabajadores los ejecutan a la vez;
- escribir pruebas de programas concurrentes que no dependan del orden en
  que se ejecutan los hilos.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **2:35 h**.
    Resolver los 6 ejercicios marcados con ★: **1:55 h**.
    Resolver los 15 ejercicios del capítulo: **4:30 h**.

## 38.1 Hilos

`thread_create(Meta, Id)` crea un hilo que ejecuta Meta y devuelve enseguida
su identificador; `thread_join(Id, Estado)` espera a que termine y da cómo
terminó. `hilos.pl` los combina:

<!-- ejemplo: capitulo-38/hilos.pl predicado: ejecutar/2 en_paralelo/2 crear/2 -->
```prolog
%!  ejecutar(:Meta, -Estado) is det.
%
%   Corre Meta en un hilo nuevo y espera a que termine. Estado es true si
%   Meta tuvo éxito, false si falló, o exception(E) si lanzó E. Las
%   ligaduras que Meta haga en el otro hilo no llegan a este.
ejecutar(Meta, Estado) :-
    thread_create(Meta, Id),
    thread_join(Id, Estado).

%!  en_paralelo(:Metas:list, -Estados:list) is det.
%
%   Corre cada una de Metas en su propio hilo, todos a la vez, y espera a
%   que terminen. Estados tiene el estado de cada una, en el orden de Metas.
en_paralelo(Metas, Estados) :-
    maplist(crear, Metas, Ids),
    maplist(thread_join, Ids, Estados).

%!  crear(:Meta, -Id) is det.
%
%   Id es un hilo nuevo que corre Meta.
crear(Meta, Id) :-
    thread_create(Meta, Id).
```

```prolog
?- ejecutar(X = 1, Estado).
Estado = true.

?- en_paralelo([true, fail, X is 1 / 0], Estados).
Estados = [true, false, exception(error(evaluation_error(zero_divisor), context((/)/2, _)))].
```

El estado es `true` si la meta tuvo éxito, `false` si falló y
`exception(E)` si lanzó E: la excepción no llega al hilo que espera, sino que
queda como dato. La primera respuesta no liga X. El hilo nuevo recibe una
**copia** de la meta, y lo que liga en ella queda en su copia: un hilo tiene
sus propias pilas y sus propias variables, y el resultado de un cálculo se
devuelve por otro camino, como una cola de mensajes
([sección 38.2](#382-colas-de-mensajes)). `en_paralelo/2` crea todos los
hilos antes de esperar al primero, así que las tres metas corren a la vez.

`thread_self/1` da el identificador del hilo que la ejecuta. El hilo del
toplevel se llama `main`; los demás se identifican con un término opaco, que
cambia en cada ejecución, salvo que se les dé un nombre con la opción
`alias`:

<!-- ejemplo: capitulo-38/hilos.pl predicado: nombres/2 anotar_nombre/0 -->
```prolog
%!  nombres(-Principal, -Otro) is det.
%
%   Principal es el nombre del hilo que llama, y Otro el que da
%   thread_self/1 dentro de un hilo creado con el alias trabajador, que lo
%   anota en visto/1.
nombres(Principal, Otro) :-
    thread_self(Principal),
    retractall(visto(_)),
    thread_create(anotar_nombre, Id, [alias(trabajador)]),
    thread_join(Id, true),
    visto(Otro).

%!  anotar_nombre is det.
%
%   Agrega a la base de datos el nombre del hilo que lo ejecuta.
anotar_nombre :-
    thread_self(Yo),
    assertz(visto(Yo)).
```

```prolog
?- nombres(Principal, Otro).
Principal = main,
Otro = trabajador.
```

El hilo `trabajador` escribió su nombre con `assertz/1`, y el hilo principal
lo leyó: **la base de datos es de todos los hilos**. Lo que un hilo agrega o
quita lo ven los demás, y de ahí vienen los problemas de la
[sección 38.3](#383-estado-compartido). Las variables globales de la
[sección 21.4](../capitulo-21-base-de-datos-dinamica/index.md#214-contadores-y-estado-global), en cambio, son de cada hilo:

<!-- ejemplo: capitulo-38/hilos.pl predicado: global_en_hilo/1 -->
```prolog
%!  global_en_hilo(-Estado) is det.
%
%   Asigna la variable global clave en este hilo y la lee en otro. Estado
%   es el de ese otro hilo: la clave no existe allí.
global_en_hilo(Estado) :-
    nb_setval(clave, principal),
    ejecutar(nb_getval(clave, _), Estado).
```

```prolog
?- global_en_hilo(Estado).
Estado = exception(error(existence_error(variable, clave), context(system:nb_getval/2, _))).
```

El hilo nuevo empieza sin variables globales: la clave que asignó el hilo
principal no existe en él. Un hilo, entonces, comparte con los demás el
programa, la base de datos y los archivos abiertos, y tiene propios sus
pilas, sus ligaduras, sus variables globales y su cola de mensajes.

Crear un hilo cuesta: `uno_por_trabajo/3`, en `colas.pl`, crea un hilo para
elevar al cuadrado cada número de una lista, y `con_trabajadores/4`, de la
sección siguiente, reparte los mismos trabajos entre cuatro hilos. Con 10 000
números:

```text
?- numlist(1, 10000, _L), time(uno_por_trabajo(cuadrado, _L, _)).
% 136,385 inferences, 1.297 CPU in 1.403 seconds (92% CPU, 105164 Lips)
_L = [1, 2, 3, 4, 5, 6, 7, 8, 9|...].

?- numlist(1, 10000, _L), time(con_trabajadores(cuadrado, 4, _L, _)).
% 120,360 inferences, 0.047 CPU in 0.031 seconds (150% CPU, 2567680 Lips)
_L = [1, 2, 3, 4, 5, 6, 7, 8, 9|...].

?- numlist(1, 10000, _L), time(maplist(cuadrado, _L, _)).
% 30,000 inferences, 0.000 CPU in 0.003 seconds (0% CPU, Infinite Lips)
_L = [1, 2, 3, 4, 5, 6, 7, 8, 9|...].
```

Un hilo por trabajo tarda 1,4 segundos, 140 microsegundos por hilo; cuatro
hilos que toman los trabajos de una cola, tres centésimas. Y
`maplist/3`, sin hilos, tres milésimas: con trabajos tan pequeños, repartir
cuesta más que calcular. Los hilos convienen cuando cada trabajo es grande
([sección 38.4](paralelismo.md#384-paralelismo-de-datos)) o cuando hay que esperar algo
externo, como un cliente de la red
([sección 38.6](servidor.md#386-los-hilos-del-servidor-http)).

!!! question "Actividad"
    Predecir el estado que da `ejecutar/2` con cada meta, y comprobarlo:
    `atom_length(X, 3)`, `member(X, [a, b])`, `assertz(visto(uno))`. Después
    de la tercera, ¿qué responde `visto(V)` en el toplevel?

## 38.2 Colas de mensajes

Una **cola de mensajes** guarda términos en el orden en que llegan.
`thread_send_message(Cola, Termino)` agrega una copia del término;
`thread_get_message(Cola, Termino)` saca el primero que unifica con Termino,
y si no hay ninguno, **espera** hasta que llegue. `message_queue_create/1,2`
crea una cola y `message_queue_destroy/1` la libera. Cada hilo tiene además
su propia cola, que se nombra con su identificador; `thread_get_message/1`
lee la del hilo que la llama. El `main/1` del servicio del
[capítulo 31](../capitulo-31-servicios-web-rest/index.md#311-un-servidor-en-diez-lineas) usaba esa espera para no terminar nunca:
nadie le envía un mensaje.

Como `thread_get_message/2` busca el primer mensaje que unifica, un hilo
puede atender los mensajes en otro orden que el de llegada:

```text
?- message_queue_create(Q), thread_send_message(Q, a(1)), thread_send_message(Q, b(2)), thread_get_message(Q, b(X)), thread_get_message(Q, Y).
Q = <message_queue>(000002956428cc60),
X = 2,
Y = a(1).
```

`con_trabajadores/4` organiza el trabajo en un **productor** y varios
**consumidores**. El hilo que llama crea dos colas, `Pendientes` y `Hechos`,
y N trabajadores; pone en `Pendientes` un mensaje `trabajo(X)` por cada dato
y un `fin` por cada trabajador, y después saca de `Hechos` tantos resultados
como datos puso:

<!-- ejemplo: capitulo-38/colas.pl predicado: con_trabajadores/4 trabajador/4 trabajar/3 resultado/3 -->
```prolog
%!  con_trabajadores(:Trabajo, +N:integer, +Xs:list, -Pares:list) is det.
%
%   Pares tiene un par X-R por cada X de Xs, ordenados por X: R es
%   resultado(Y) si call(Trabajo, X, Y) tuvo éxito, fallo si falló o
%   error(E) si lanzó E. Los calculan N hilos trabajadores, que toman los
%   trabajos de una cola de a uno.
con_trabajadores(Trabajo, N, Xs, Pares) :-
    message_queue_create(Pendientes, [max_size(100)]),
    message_queue_create(Hechos),
    length(Ids, N),
    maplist(trabajador(Trabajo, Pendientes, Hechos), Ids),
    forall(member(X, Xs), thread_send_message(Pendientes, trabajo(X))),
    forall(member(_, Ids), thread_send_message(Pendientes, fin)),
    length(Xs, Cantidad),
    length(Recibidos, Cantidad),
    maplist(thread_get_message(Hechos), Recibidos),
    maplist(thread_join, Ids, _),
    message_queue_destroy(Pendientes),
    message_queue_destroy(Hechos),
    msort(Recibidos, Pares).

%!  trabajador(:Trabajo, +Pendientes, +Hechos, -Id) is det.
%
%   Id es un hilo nuevo que atiende la cola Pendientes con trabajar/3.
trabajador(Trabajo, Pendientes, Hechos, Id) :-
    thread_create(trabajar(Trabajo, Pendientes, Hechos), Id).

%!  trabajar(:Trabajo, +Pendientes, +Hechos) is det.
%
%   Toma mensajes de Pendientes hasta recibir fin. Por cada trabajo(X),
%   deja en Hechos el par X-R con el resultado de call(Trabajo, X, Y).
trabajar(Trabajo, Pendientes, Hechos) :-
    thread_get_message(Pendientes, Mensaje),
    (   Mensaje = trabajo(X)
    ->  resultado(Trabajo, X, R),
        thread_send_message(Hechos, X-R),
        trabajar(Trabajo, Pendientes, Hechos)
    ;   true
    ).

%!  resultado(:Trabajo, +X, -R) is det.
%
%   R es resultado(Y) si call(Trabajo, X, Y) tiene éxito, fallo si falla y
%   error(E) si lanza la excepción E.
resultado(Trabajo, X, R) :-
    catch(( call(Trabajo, X, Y)
          ->  R = resultado(Y)
          ;   R = fallo
          ),
          E,
          R = error(E)).
```

```prolog
?- con_trabajadores(cuadrado, 4, [1, 2, 3, 4, 5], Pares).
Pares = [1-resultado(1), 2-resultado(4), 3-resultado(9), 4-resultado(16), 5-resultado(25)].

?- con_trabajadores(raiz_exacta, 2, [16, a, 15], Pares).
Pares = [15-fallo, 16-resultado(4), a-error(error(type_error(evaluable, a/0), context(system:(is)/2, _)))].
```

Tres decisiones del programa evitan que un hilo quede esperando para siempre,
que es la falla propia de las colas:

- **Un `fin` por trabajador.** Un trabajador termina cuando lo recibe; si
  hubiera menos `fin` que trabajadores, alguno esperaría otro mensaje que no
  llega, y `thread_join/2` esperaría a ese trabajador sin fin.
- **Siempre un resultado.** Si un trabajo falla o lanza una excepción, el
  trabajador igual envía un par, con `fallo` o `error(E)`: el productor
  cuenta los mensajes, y uno que falte lo dejaría esperando. Además, el
  trabajador sigue vivo para el trabajo siguiente.
- **Una cola acotada.** `max_size(100)` limita los mensajes pendientes: con
  la cola llena, `thread_send_message/2` espera a que un trabajador saque
  uno. Una lista de un millón de datos no se copia entera en la cola.

Los resultados llegan en el orden en que terminan los trabajos, que cambia de
una ejecución a otra; `msort/2` los ordena, y la respuesta ya no depende del
orden de los hilos. Las pruebas de `colas.plt` comparan esa lista ordenada,
nunca el orden de llegada.

!!! question "Actividad"
    En `con_trabajadores/4`, mover `maplist(thread_join, Ids, _)` antes de
    la línea que recoge los resultados, y predecir si el programa sigue
    terminando con 10 datos y con 1 000. Comprobarlo, y predecir qué
    cambiaría si la cola `Hechos` también se creara con `max_size(100)`.

## 38.3 Estado compartido

`cupo.pl` reduce *Inscripciones* a una materia con vacantes. `reservar/3` es
la forma de `inscribir/3` del [capítulo 21](../capitulo-21-base-de-datos-dinamica/index.md#2111-el-proyecto-inscribir-y-dar-de-baja): consulta las vacantes,
y si quedan, inscribe y descuenta una con `retract/1` y `assertz/1`:

<!-- ejemplo: capitulo-38/cupo.pl predicado: reservar/3 descontar/1 -->
```prolog
%!  reservar(+Materia:atom, +Legajo:integer, -Resultado) is det.
%
%   Si Materia tiene vacantes, inscribe a Legajo y descuenta una: Resultado
%   es aceptada. Si no, Resultado es rechazada. Correcto con un solo hilo.
reservar(Materia, Legajo, Resultado) :-
    vacantes(Materia, N),
    (   N > 0
    ->  assertz(inscripto(Legajo, Materia)),
        descontar(Materia),
        Resultado = aceptada
    ;   Resultado = rechazada
    ).

%!  descontar(+Materia:atom) is det.
%
%   Resta una a las vacantes de Materia.
descontar(Materia) :-
    retract(vacantes(Materia, N0)),
    N is N0 - 1,
    assertz(vacantes(Materia, N)).
```

`concurrencia(Reservar, Hilos, Intentos, Vacantes, Resumen)` abre la materia
`m` con Vacantes lugares y corre Hilos hilos, cada uno con Intentos llamadas a
Reservar. El resumen da los inscriptos, los hechos `vacantes/2` de la materia,
sus valores y las llamadas que fallaron, que anota con `assertz/1`: agregar un
hecho es seguro con varios hilos, como se verá.

<!-- ejemplo: capitulo-38/cupo.pl predicado: concurrencia/5 -->
```prolog
%!  concurrencia(:Reservar, +Hilos:integer, +Intentos:integer,
%!               +Vacantes:integer, -Resumen) is det.
%
%   Abre la materia m con Vacantes lugares y corre Hilos hilos, cada uno con
%   Intentos llamadas a call(Reservar, m, Legajo, _), todas con legajos
%   distintos. Resumen es resumen(Inscriptos, Hechos, Valores, Fallos):
%   cuántos alumnos quedaron inscriptos, cuántos hechos vacantes/2 tiene m,
%   sus valores sin repetir y cuántas llamadas fallaron.
concurrencia(Reservar, Hilos, Intentos, Vacantes,
             resumen(Inscriptos, Hechos, Valores, Fallos)) :-
    abrir(m, Vacantes),
    numlist(1, Hilos, Hs),
    maplist(reservador(Reservar, Intentos), Hs, Ids),
    maplist(thread_join, Ids, _),
    aggregate_all(count, inscripto(_, m), Inscriptos),
    aggregate_all(count, vacantes(m, _), Hechos),
    findall(V, vacantes(m, V), Vs),
    sort(Vs, Valores),
    aggregate_all(count, fallo(_), Fallos).
```

Con un hilo, 1 000 intentos y 100 vacantes, el resultado es el esperado: 100
inscriptos, un hecho con 0 vacantes, ningún fallo. Con ocho hilos, dos
ejecuciones seguidas:

```text
?- concurrencia(reservar, 8, 1000, 100, R).
R = resumen(170, 1, [-1], 111).

?- concurrencia(reservar, 8, 1000, 100, R).
R = resumen(227, 1, [0], 369).
```

Es una **condición de carrera**: el resultado depende de cómo se intercalan
los hilos, y cambia en cada ejecución. Dos intercalaciones la explican:

- Dos hilos leen `vacantes(m, 1)`, los dos ven un lugar, los dos inscriben y
  los dos descuentan: las vacantes quedan en −1.
- El hilo A lee `vacantes(m, 5)` y el hilo B lo quita y agrega
  `vacantes(m, 4)` antes de que A llegue a `descontar/1`. El `retract/1` de A
  busca las cláusulas con la **vista lógica** de la
  [sección 21.3](../capitulo-21-base-de-datos-dinamica/index.md#213-la-vista-logica-de-actualizacion): la cláusula que existía cuando empezó ya no
  existe, y la nueva no es visible para esa llamada. `retract/1` falla, y
  `reservar/3`, que debía ser `det`, falla con el alumno ya inscripto y la
  vacante sin descontar. Así se llega a 227 inscriptos con 0 vacantes.

Cada operación sobre la base de datos es atómica: `assertz/1` agrega una
cláusula entera, `retract/1` quita una, y ningún hilo ve una cláusula a
medio escribir. Lo que no es atómico es la **secuencia**: leer un valor,
decidir y escribir otro. La falla no aparece con un hilo ni en pruebas que
llaman a `reservar/3` de a una vez; `cupo.plt` no la prueba, porque una
prueba que a veces falla no prueba nada, y el texto la muestra.

### `with_mutex/2`

Un **mutex** es un permiso que un solo hilo tiene por vez.
`with_mutex(Nombre, Meta)` espera a obtener el mutex Nombre, ejecuta Meta
como `once/1` y lo libera al terminar, también si Meta falla o lanza una
excepción. Si todas las secuencias que leen y cambian las vacantes corren con
el mismo mutex, no se intercalan:

<!-- ejemplo: capitulo-38/cupo.pl predicado: reservar_con_mutex/3 -->
```prolog
%!  reservar_con_mutex(+Materia:atom, +Legajo:integer, -Resultado) is det.
%
%   reservar/3 con el mutex cupo: un solo hilo a la vez lee y cambia las
%   vacantes.
reservar_con_mutex(Materia, Legajo, Resultado) :-
    with_mutex(cupo, reservar(Materia, Legajo, Resultado)).
```

```prolog
?- concurrencia(reservar_con_mutex, 8, 1000, 100, R).
R = resumen(100, 1, [0], 0).
```

El resultado es el mismo en cada ejecución, y es el invariante: inscriptos
más vacantes suman el cupo, hay un solo hecho de vacantes y ningún intento
falla. El precio es que las reservas se hacen de a una: el mutex ordena a los
hilos, y mientras uno lo tiene, los demás esperan.

### `transaction/1` y `transaction/3`

`transaction(Meta)` ejecuta Meta de modo que sus cambios a la base de datos
sean invisibles para los demás hilos hasta que Meta termina con éxito; en ese
momento se ven todos juntos. Si Meta falla o lanza una excepción, ninguno
queda. Con `reservar/3` dentro de una transacción, un hilo nunca ve un
alumno inscripto con la vacante sin descontar. Pero la transacción no ordena
a los hilos:

<!-- ejemplo: capitulo-38/cupo.pl predicado: reservar_en_transaccion/3 -->
```prolog
%!  reservar_en_transaccion(+Materia:atom, +Legajo:integer, -Resultado)
%!      is det.
%
%   reservar/3 dentro de una transacción: sus cambios se ven todos juntos,
%   o ninguno. No impide que dos transacciones lean el mismo valor.
reservar_en_transaccion(Materia, Legajo, Resultado) :-
    transaction(reservar(Materia, Legajo, Resultado)).
```

```text
?- concurrencia(reservar_en_transaccion, 8, 1000, 100, R).
R = resumen(8000, 6305, [85, 86, 87], 0).
```

Los 8 000 alumnos quedaron inscriptos, con 6 305 hechos `vacantes/2`. Dentro
de su transacción, cada hilo ve la base de datos del momento en que empezó:
varios leen `vacantes(m, 87)`, todos lo quitan y todos agregan
`vacantes(m, 86)`. El manual lo dice: varias transacciones pueden quitar la
misma cláusula y confirmarse, porque confirmar un `retract/1` ya hecho no
tiene efecto. `transaction/1` da **atomicidad y aislamiento**, no exclusión.

`transaction(Meta, Restriccion, Mutex)` agrega lo que falta. Ejecuta Meta
aislada, sin ningún mutex; después toma Mutex, vuelve a ver la base de datos
actual con los cambios de Meta, ejecuta Restriccion y, si tiene éxito,
confirma; si no, descarta todo. `reservar_cas/3` decide con las vacantes que
leyó y confirma solo si siguen siendo esas; si otro hilo las cambió, repite:

<!-- ejemplo: capitulo-38/cupo.pl predicado: reservar_cas/3 decidir/4 confirmar/3 -->
```prolog
%!  reservar_cas(+Materia:atom, +Legajo:integer, -Resultado) is det.
%
%   Decide la inscripción en una transacción, y la confirma solo si las
%   vacantes siguen siendo las que leyó; si cambiaron, la descarta y vuelve
%   a empezar.
reservar_cas(Materia, Legajo, Resultado) :-
    repeat,
    transaction(decidir(Materia, Legajo, N, Resultado),
                confirmar(Materia, N, Resultado),
                cupo),
    !.

%!  decidir(+Materia:atom, +Legajo:integer, -N:integer, -Resultado) is det.
%
%   N son las vacantes de Materia. Si N es positivo, inscribe a Legajo y
%   Resultado es aceptada; si no, Resultado es rechazada.
decidir(Materia, Legajo, N, Resultado) :-
    vacantes(Materia, N),
    (   N > 0
    ->  assertz(inscripto(Legajo, Materia)),
        Resultado = aceptada
    ;   Resultado = rechazada
    ).

%!  confirmar(+Materia:atom, +N:integer, +Resultado) is semidet.
%
%   Las vacantes de Materia siguen siendo N; si Resultado es aceptada, las
%   reemplaza por N - 1. Falla si otro hilo las cambió.
confirmar(Materia, N, aceptada) :-
    retract(vacantes(Materia, N)),
    N1 is N - 1,
    assertz(vacantes(Materia, N1)).
confirmar(Materia, N, rechazada) :-
    vacantes(Materia, N).
```

```prolog
?- concurrencia(reservar_cas, 8, 1000, 100, R).
R = resumen(100, 1, [0], 0).
```

Es la operación *compare and swap*: leer, calcular y escribir solo si lo
leído no cambió. Conviene cuando lo que se calcula antes de escribir es
costoso y los conflictos son raros: el cálculo corre en paralelo y solo la
confirmación va de a una. Con reservas tan simples no hay diferencia que
medir: 8 000 intentos con 10 000 vacantes tardan 0,085 segundos con el mutex
y 0,120 con la transacción, que repite las reservas que chocan.

!!! example "Patrón 52 — Estado compartido detrás de un mutex"
    **Problema.** Varios hilos leen un dato de la base de datos, deciden
    según lo leído y lo cambian: un cupo, un contador, un saldo. Cada
    operación es atómica, pero la secuencia no, y dos hilos pueden decidir
    con el mismo valor.

    **Versión ingenua.** La secuencia de un solo hilo, `retract/1` y
    `assertz/1`, sin protección: correcta en las pruebas de a una llamada, y
    con varios hilos pierde actualizaciones, excede el cupo o falla en un
    `retract/1` cuya cláusula ya quitó otro hilo.

    **Patrón.** Toda secuencia que lee y cambia el dato pasa por un
    predicado que la ejecuta con `with_mutex/2`, siempre con el mismo nombre
    de mutex; si los que solo leen no deben ver un cambio a medias, la
    secuencia va además dentro de `transaction/1`. Cuando la decisión es
    costosa y los conflictos son raros, `transaction/3` con una restricción
    que verifica lo leído, repetida hasta que confirma. Las pruebas corren
    muchos hilos y comparan cantidades: el invariante, no el orden.

    **Cuándo no usarlo.** Cuando el dato puede ser de cada hilo
    (`thread_local/1`) o viajar en mensajes (una cola). Cuando solo se
    agregan hechos independientes: `assertz/1` ya es atómico. Y no dentro
    del mutex la entrada y salida lenta, como leer de la red: todos los
    hilos esperarían a ese cliente.

### La base de datos y los hilos

El [capítulo 21](../capitulo-21-base-de-datos-dinamica/index.md#212-assertz1-asserta1-retract1-retractall1) advirtió que entre el `retract/1` y el `assertz/1`
de `cumple_anios/1` el hecho no existe, y que con varios hilos eso pedía más
cuidado. Las reglas son estas: cada `assertz/1`, `asserta/1`, `retract/1` y
`retractall/1` es atómico; cada llamada que recorre un predicado dinámico lo
ve como estaba al empezar; y una secuencia de operaciones no es atómica si
no va dentro de un mutex o de una transacción. `snapshot/1` es la
transacción de quien solo lee: ejecuta una meta sobre el estado de la base de
datos del momento en que empieza, sin ver los cambios que otros hilos
confirman mientras tanto.

La memorización de la [sección 21.5](../capitulo-21-base-de-datos-dinamica/index.md#215-memorizacion) guarda valores con
`assertz/1` ([Patrón 17](../patrones.md#17-memorizacion-con-assertz)). Con varios hilos da valores correctos, porque
guardar dos veces el mismo valor no cambia la respuesta, pero la tabla
crece: `memo.pl` calcula `fib(300)` en ocho hilos a la vez, con la tabla
compartida `guardado/2`:

```text
?- en_hilos(fib_compartido, 8, 300), aggregate_all(count, guardado(_, _), N).
N = 1959.
```

Hay 299 valores distintos y 1 959 hechos: los hilos calcularon los mismos
valores a la vez, y cada uno guardó los suyos. La declaración
`:- thread_local` hace que un predicado dinámico tenga una colección de
cláusulas **por hilo**: cada hilo ve solo las que agregó, empieza sin
ninguna y las pierde al terminar. Es la otra salida del estado compartido:
no compartirlo.

<!-- ejemplo: capitulo-38/memo.pl fragmento: :- thread_local guardado_local/2. .. :- thread_local guardado_local/2. -->
```prolog
:- thread_local guardado_local/2.
```

<!-- ejemplo: capitulo-38/memo.pl predicado: fib_local/2 -->
```prolog
%!  fib_local(+N:integer, -F:integer) is det.
%
%   La misma relación, con los valores en guardado_local/2: cada hilo ve
%   solo los que guardó él.
fib_local(N, F) :-
    (   guardado_local(N, F0)
    ->  F = F0
    ;   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib_local(N1, F1),
        fib_local(N2, F2),
        F0 is F1 + F2,
        assertz(guardado_local(N, F0)),
        F = F0
    ).
```

```prolog
?- en_hilos(fib_local, 8, 300), aggregate_all(count, guardado_local(_, _), N).
N = 0.
```

Los ocho hilos calcularon con su propia tabla, sin repetidos ni mutex, y el
hilo principal no ve ninguna de ellas. El costo es que cada hilo calcula todo
de nuevo: la tabla local conviene para datos de trabajo de un hilo, no para
resultados que otros hilos podrían reutilizar.

!!! question "Actividad"
    Predecir el resumen de `concurrencia(reservar, 1, 1000, 100, R)` y el de
    `concurrencia(reservar_en_transaccion, 1, 1000, 100, R)`, y explicar por
    qué la transacción, que falla con ocho hilos, es correcta con uno.

El capítulo continúa en la página
[Paralelismo de datos y motores](paralelismo.md#384-paralelismo-de-datos),
con el reparto de un cálculo entre los núcleos del procesador y los
motores, que entregan las respuestas de una meta de a una. Antes, los
[ejercicios](#ejercicios) de esta página practican las secciones 38.1 a 38.3.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir la respuesta de cada consulta y comprobarla, con
   `hilos.pl` cargado: `ejecutar(fail, E).` · `ejecutar(atom_length(X, 3),
   E).` · `en_paralelo([X = 1, X = 2], Es).` ·
   `en_paralelo([assertz(visto(a)), retract(visto(a))], Es).` ¿Cuál de las
   cuatro puede cambiar de una ejecución a otra?
2. **(2)** Escribir `respuestas_en_hilo(Plantilla, Meta, Lista)`, que ejecuta
   `findall(Plantilla, Meta, Lista)` en un hilo nuevo y devuelve la lista al
   hilo que llama por su cola de mensajes. Si la meta lanza una excepción, el
   hilo que llama debe recibirla.
3. **(1)** Una versión de `con_trabajadores/4` envía un solo `fin`, con tres
   trabajadores. Decir qué ocurre y en qué línea queda esperando el
   programa. Comprobarlo sin bloquear la sesión: consultar el estado de los
   trabajadores con `thread_property/2` y después enviar los `fin` que
   faltan.
4. **(2)** Escribir `tuberia(Xs, Suma)`: un hilo eleva al cuadrado cada
   número que recibe y lo pasa, por una segunda cola, a otro hilo que los
   suma; el hilo que llama pone los números en la primera cola y recibe la
   suma. Ningún hilo debe quedar esperando al terminar.
5. ★ **(2)** Escribir, como una tabla de pasos de dos hilos A y B, una
   intercalación de `reservar/3` que deje `vacantes(m, -1)` y otra que haga
   fallar a `reservar/3` con el alumno inscripto. Decir en qué línea de
   `reservar/3` o de `descontar/1` está cada hilo en cada paso.
6. ★ **(3)** Dos cuentas, `saldo(Cuenta, Monto)`, y
   `transferir(Desde, Hacia, Monto)`, que resta de una y suma a la otra.
   Escribirlo con un mutex por cuenta, que tome primero el de Desde y
   después el de Hacia, y mostrar con dos hilos que transfieren en sentidos
   opuestos que el programa puede quedar detenido para siempre. Corregirlo
   tomando los mutex siempre en el mismo orden, y probar con 8 hilos y
   10 000 transferencias que la suma de los saldos no cambia.
7. **(1)** ¿Qué pasa con las cláusulas de `guardado_local/2` de un hilo
   cuando el hilo termina? ¿Y con sus variables globales? Comprobarlo con
   `ejecutar/2` y `thread_local/1`.

## Referencias

- El manual de SWI-Prolog: «Multithreaded applications»
  ([en línea](https://www.swi-prolog.org/pldoc/man?section=threads)), con
  «Message queues» ([en línea](https://www.swi-prolog.org/pldoc/man?section=msgqueue))
  y `with_mutex/2` ([en línea](https://www.swi-prolog.org/pldoc/man?predicate=with_mutex/2)),
  y «Transactions» ([en línea](https://www.swi-prolog.org/pldoc/man?section=transactions)).
  El capítulo toma de ahí las primitivas y sus garantías, entre ellas que
  confirmar un `retract/1` ya hecho por otra transacción no tiene efecto.
- Markus Triska, *The Power of Prolog* — «Purity», apartado «Practical
  importance» ([edición en línea](https://www.metalevel.at/prolog/purity)):
  el código puro no tiene carreras, porque no modifica datos compartidos.
