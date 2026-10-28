# Los hilos del servidor HTTP y las inscripciones concurrentes

Esta página continúa el [capítulo 38](index.md) después de la
[sección 38.5](paralelismo.md#385-motores), con las secciones
[38.6](#386-los-hilos-del-servidor-http) y
[38.7](#387-inscripciones-concurrentes): cómo atiende los pedidos el servidor HTTP de los
capítulos [31](../capitulo-31-servicios-web-rest/index.md) y
[32](../capitulo-32-ejecutables-y-distribucion/index.md), con un conjunto de hilos trabajadores, y qué
exige eso de los manejadores. Aplica al servidor lo que la
[sección 38.3](index.md#383-estado-compartido) mostró sobre el estado compartido, y la
[sección 38.7](#387-inscripciones-concurrentes) lo aplica al servicio de *Inscripciones*.
El ejemplo es `servidor.pl`, en `ejemplos/capitulo-38/`, con sus pruebas.

## 38.6 Los hilos del servidor HTTP

`http_server/2`, de `library(http/thread_httpd)`, arranca un servidor con
un hilo que acepta las conexiones y un conjunto de **hilos trabajadores**: el
primero pone cada conexión en una cola, y un trabajador libre la saca, lee el
pedido, llama al manejador y responde. La opción `workers(N)` fija cuántos
son, 5 si no se indica, y `http_workers/2` los consulta o los cambia con el
servidor en marcha. `servidor.pl` arranca uno con tres trabajadores:

<!-- ejemplo: capitulo-38/servidor.pl predicado: iniciar/2 hilo/1 -->
```prolog
%!  iniciar(?Puerto:integer, +Trabajadores:integer) is det.
%
%   Arranca el servidor en Puerto de la máquina local, con Trabajadores
%   hilos que atienden los pedidos. Con Puerto libre, elige uno.
iniciar(Puerto, Trabajadores) :-
    http_server(http_dispatch,
                [ port(localhost:Puerto),
                  workers(Trabajadores) ]).

%!  hilo(+Pedido) is det.
%
%   GET /hilo: el nombre del hilo que atiende el pedido.
hilo(_Pedido) :-
    thread_self(Yo),
    reply_json_dict(_{hilo: Yo}).
```

`muchos_pedidos/4` hace muchos pedidos a la vez, desde tantos hilos clientes
como núcleos, con `concurrent_maplist/3`, y reúne las respuestas:

```text
?- iniciar(P, 3), muchos_pedidos(P, hilo, 30, Hilos), detener(P).
% Started server at http://localhost:57204/
P = 57204,
Hilos = ["httpd@localhost:57204_1", "httpd@localhost:57204_2", "httpd@localhost:57204_3"].
```

Treinta pedidos, atendidos por los tres trabajadores. El servicio de los
capítulos [31](../capitulo-31-servicios-web-rest/index.md#311-un-servidor-en-diez-lineas) y [32](../capitulo-32-ejecutables-y-distribucion/index.md#328-el-proyecto-inscripciones-se-entrega) arranca con `http_server/1`, de
`library(http/http_server)`, que usa el mismo mecanismo y agrega trabajadores
cuando hay pedidos esperando: empieza con 5 y crece hasta 100, y los
trabajadores agregados terminan después de 10 segundos sin trabajo. Un hilo
propio de la biblioteca, `__http_scheduler`, decide cuándo agregar uno.

Un manejador, entonces, puede estar corriendo en varios trabajadores a la
vez, y todo lo de la [sección 38.3](index.md#383-estado-compartido) se aplica. `contar/1`
suma una visita a `visitas/1` como `descontar/1` descontaba una vacante, y
`contar_seguro/1` hace lo mismo con un mutex:

<!-- ejemplo: capitulo-38/servidor.pl predicado: contar/1 contar_seguro/1 sumar_visita/1 -->
```prolog
%!  contar(+Pedido) is det.
%
%   POST /contar: suma una visita y responde con el total. Dos pedidos
%   atendidos a la vez pueden leer el mismo hecho.
contar(_Pedido) :-
    sumar_visita(N),
    reply_json_dict(_{visitas: N}).

%!  contar_seguro(+Pedido) is det.
%
%   POST /contar_seguro: lo mismo, con el mutex visitas.
contar_seguro(_Pedido) :-
    with_mutex(visitas, sumar_visita(N)),
    reply_json_dict(_{visitas: N}).

%!  sumar_visita(-N:integer) is det.
%
%   Suma uno a visitas/1; N es el valor nuevo.
sumar_visita(N) :-
    retract(visitas(N0)),
    N is N0 + 1,
    assertz(visitas(N)).
```

```text
?- iniciar(P, 3), muchos_pedidos(P, contar, 500, Codigos), visitas(V), detener(P).
% Started server at http://localhost:57235/
P = 57235,
Codigos = [200-493, 500-7],
V = 493.

?- sin_visitas, iniciar(P, 3), muchos_pedidos(P, contar_seguro, 500, Codigos), visitas(V), detener(P).
% Started server at http://localhost:57740/
P = 57740,
Codigos = [200-500],
V = 500.
```

Sin mutex, siete pedidos recibieron el código 500: en su trabajador,
`retract/1` no encontró el hecho que otro trabajador acababa de quitar, el
manejador falló y el servidor respondió con un error. Las visitas contadas
son 493. Con el mutex, las 500. El tiempo de red domina cada pedido, y las
carreras son menos que en la [sección 38.3](index.md#383-estado-compartido); no por eso
dejan de ocurrir.

Tres consecuencias para los manejadores:

- **El estado compartido, detrás de un mutex o de una transacción**
  ([Patrón 52](../patrones.md#52-estado-compartido-detras-de-un-mutex)), y el mutex alrededor de la operación sobre los
  datos, no del pedido entero.
- **Nada por cliente en el hilo.** Un trabajador atiende a un cliente y
  después a otro: una variable global o un predicado `thread_local/1` que un
  manejador deja al terminar lo encuentra el pedido siguiente de ese
  trabajador, que puede ser de otro cliente. Lo que es de un cliente viaja en
  el pedido, o se guarda en la base de datos con su identificador.
- **Las pruebas, con pedidos simultáneos.** El
  [Patrón 41](../patrones.md#41-servidor-bajo-prueba) arranca el servidor en un puerto libre; para un manejador que
  cambia estado, además, se hacen muchos pedidos a la vez y se comparan
  cantidades, como en `servidor.plt`.

## 38.7 Inscripciones concurrentes

`inscribir/3`, del módulo `reglas` del [capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md#328-el-proyecto-inscripciones-se-entrega), tiene la forma de
`reservar/3`: `inscripcion_posible/3` consulta las vacantes, y después
`agregar_inscripcion/3`, `cambiar_vacantes/2` y `contar_operacion/0`
cambian los datos. `concurrente.pl` carga los módulos del
[capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md) sin cambiarlos. `carrera/4` deja una vacante en una materia e inscribe a la vez a
varios alumnos, cada uno en su hilo, con el predicado que recibe; al terminar
restaura el estado:

<!-- ejemplo: capitulo-38/concurrente.pl predicado: carrera/4 -->
```prolog
%!  carrera(:Inscribir, +Materia:atom, +Legajos:list, -Resultado) is det.
%
%   Deja una vacante en Materia e inscribe a la vez a todos los Legajos con
%   Inscribir. Resultado es Aceptadas-Vacantes: cuántas inscripciones de
%   Materia quedaron cursando y la lista de valores de vacantes/2. Al
%   terminar restaura el estado anterior.
carrera(Inscribir, Materia, Legajos, Aceptadas-Vacantes) :-
    estado(Antes),
    vacantes(Materia, N),
    Cambio is 1 - N,
    cambiar_vacantes(Materia, Cambio),
    findall(L-Materia, member(L, Legajos), Pedidos),
    simultaneos(Inscribir, Pedidos, _),
    aggregate_all(count, inscripcion(_, Materia, cursando), Aceptadas),
    findall(V, vacantes(Materia, V), Vacantes),
    restaurar(Antes).
```

Los alumnos 102, 105, 106 y 107 pueden cursar Álgebra. Mil carreras con
`inscribir/3`, contadas por resultado:

```text
?- findall(R, (between(1, 1000, _), carrera(inscribir, alg, [102, 105, 106, 107], R)), Rs), msort(Rs, S), clumped(S, C).
Rs = [1-[0], 1-[0], 1-[0], 1-[0], 1-[0], 1-[0], 1-[0], 1-[...], ... - ...|...],
S = [1-[0], 1-[0], 1-[0], 1-[0], 1-[0], 1-[0], 1-[0], 1-[...], ... - ...|...],
C = [1-[0]-734, 2-[0]-177, 3-[0]-1, 4-[-3]-86, 4-[-2]-2].
```

En 266 de las mil, la materia quedó con más alumnos que vacantes: hasta
cuatro inscriptos para un lugar, y −3 vacantes. En las 177 con dos inscriptos
y 0 vacantes, un `retract/1` de `cambiar_vacantes/2` falló, como en
`cupo.pl`, e `inscribir/3` falló después de registrar la inscripción. El
contador de operaciones sufre lo mismo: ocho hilos que hacen 1 000
inscripciones rechazadas cada uno lo dejan en 1 704, no en 8 000.

`inscribir_seguro/3` aplica el [Patrón 52](../patrones.md#52-estado-compartido-detras-de-un-mutex) con las dos herramientas:
el mutex `inscripciones` para que dos inscripciones no se intercalen, y una
transacción para que un hilo que solo consulta no vea una inscripción
registrada con la vacante todavía sin descontar. `ocupacion/3` es esa
consulta, con `snapshot/1`:

<!-- ejemplo: capitulo-38/concurrente.pl predicado: inscribir_seguro/3 ocupacion/3 -->
```prolog
%!  inscribir_seguro(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   inscribir/3 con el mutex inscripciones, que impide que dos
%   inscripciones o bajas se superpongan, y dentro de una transacción: los
%   hilos que solo leen ven los datos de antes o los de después, nunca los
%   de la mitad.
inscribir_seguro(Legajo, Materia, Resultado) :-
    with_mutex(inscripciones,
               transaction(inscribir(Legajo, Materia, Resultado))).

%!  ocupacion(+Materia:atom, -Cursando:integer, -Vacantes:integer) is det.
%
%   Cursando es la cantidad de alumnos que cursan Materia y Vacantes sus
%   vacantes, leídas las dos en el mismo estado de la base de datos.
ocupacion(Materia, Cursando, Vacantes) :-
    snapshot(( aggregate_all(count, inscripcion(_, Materia, cursando),
                             Cursando),
               vacantes(Materia, Vacantes) )).
```

```prolog
?- carrera(inscribir_seguro, alg, [102, 105, 106, 107], R).
R = 1-[0].
```

La prueba `una_vacante` lo repite cien veces y compara el conjunto de los
resultados, `[1-[0]]`: qué alumno obtiene la vacante depende del orden de los
hilos, cuántos la obtienen no. La transacción también se mide: con cuatro
hilos que inscriben con el mutex pero sin transacción y un hilo que lee 3 000
veces cuántos cursan y cuántas vacantes quedan, en cuatro de cinco
ejecuciones entre una y tres lecturas sumaron 5, un alumno más que el cupo;
con `inscribir_seguro/3`, ninguna. La prueba `lector` lo comprueba con mil
lecturas.

El servicio del [capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md) atiende `POST /inscripciones` en sus
trabajadores, con la misma carrera. Quinientas rondas de cuatro pedidos
simultáneos para la última vacante de Álgebra dieron 106 rondas con más de
una inscripción aceptada; en algunas, un pedido recibió el código 400 con el
mensaje «pedido incompleto», porque `inscribir/3` falló y el manejador tomó
esa falla por un cuerpo mal formado. `concurrente.pl` declara otro
manejador para la misma ruta, que reemplaza al de `api.pl` porque se declara
después:

<!-- ejemplo: capitulo-38/concurrente.pl fragmento: :- http_handler(root(inscripciones), inscripciones_seguras, [method(post)]). .. :- http_handler(root(inscripciones), inscripciones_seguras, [method(post)]). -->
```prolog
:- http_handler(root(inscripciones), inscripciones_seguras, [method(post)]).
```

<!-- ejemplo: capitulo-38/concurrente.pl predicado: inscripciones_seguras/1 -->
```prolog
%!  inscripciones_seguras(+Pedido) is det.
%
%   POST /inscripciones: el manejador del capítulo 32, api:inscripciones/1,
%   con el mutex inscripciones y dentro de una transacción, como
%   inscribir_seguro/3. Reemplaza al de api.pl, porque se declara para la
%   misma ruta después.
inscripciones_seguras(Pedido) :-
    with_mutex(inscripciones,
               transaction(api:inscripciones(Pedido))).
```

Llama al manejador original, `api:inscripciones/1`, calificado con su
módulo porque `api` no lo exporta, con el mismo mutex y dentro de una
transacción. Con este archivo cargado, las mismas 500 rondas dieron una
inscripción aceptada y tres rechazadas en cada una, y la prueba `servicio`
de `concurrente.plt` lo comprueba con el servicio en un puerto libre. La
corrección tiene un costo que el [Patrón 52](../patrones.md#52-estado-compartido-detras-de-un-mutex) advierte: el mutex cubre
también la lectura del cuerpo del pedido y la escritura de la respuesta, y
un cliente lento retiene a todos los demás. La versión fina llama a
`inscribir_seguro/3` desde un manejador propio (ejercicio 14).

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; los que corren metas en otros hilos las declaran con `:`, y `concurrencia/5`, `carrera/4` y `con_trabajadores/4` son `det` con cualquier orden de los hilos |
    | C4 | `reservar_con_mutex/3`, `reservar_cas/3` e `inscribir_seguro/3` no dejan alternativas: `with_mutex/2` y `transaction/1` ejecutan su meta como `once/1`, y `reservar_cas/3` corta el `repeat/0` al confirmar |
    | C6 | las secuencias que leen y cambian el estado compartido son pocas y están en predicados de borde con nombre propio —`reservar_con_mutex/3`, `contar_seguro/1`, `inscribir_seguro/3`—; el núcleo de *Inscripciones* no cambió |
    | C7 para la concurrencia | 54 pruebas en ocho archivos, ninguna dependiente del orden de los hilos: los resultados se ordenan con `msort/2` o se comparan como conjuntos, y lo que se compara son invariantes —inscriptos más vacantes, un solo hecho de vacantes, visitas contadas—; las versiones con carreras se muestran en el texto con ejecuciones reales y no se prueban con hilos. Las pruebas pasan también en Linux |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

12. **(2)** Escribir `sumar_visita_cas(N)`, la operación de `sumar_visita/1`
    con `transaction/3`, como `reservar_cas/3`. Probarla con 8 hilos que
    suman 1 000 visitas cada uno.
13. **(2)** Agregar a `servidor.pl` un manejador `contar_por_hilo/1` que
    cuente las visitas en un predicado `thread_local/1`. Hacer 30 pedidos
    con tres trabajadores, predecir los valores que devuelve y explicarlos.
14. ★ **(2)** Escribir un manejador de `POST /inscripciones` que lea el
    pedido fuera del mutex y llame a `inscribir_seguro/3`, con las mismas
    respuestas que el de `api.pl`, y comprobar con cuatro pedidos
    simultáneos que acepta uno solo.
15. **(3)** Escribir `inscribir_cas/3` con `transaction/3`: la meta es
    `inscribir/3`, y la restricción verifica que Álgebra tenga un solo hecho
    `vacantes/2`, no negativo, y que haya un solo hecho `operaciones/1`; si
    no se cumple, se repite. Compararlo con `inscribir_seguro/3` en mil
    carreras.

## Resumen

| | |
|---|---|
| `thread_create/2`, `thread_create/3` | crea un hilo que ejecuta una copia de la meta; la opción `alias(Nombre)` le da nombre |
| `thread_join/2` | espera a que un hilo termine y da su estado: `true`, `false` o `exception(E)` |
| `thread_self/1` | el identificador del hilo que la ejecuta; el del toplevel es `main` |
| `thread_property/2` | las propiedades de un hilo; `status(S)` da `running` mientras corre, o su estado final |
| `message_queue_create/1`, `message_queue_create/2` | crea una cola de mensajes; `max_size(N)` la acota |
| `message_queue_destroy/1` | libera una cola |
| `thread_send_message/2` | agrega una copia de un término a una cola, o a la de un hilo; espera si la cola está llena |
| `thread_get_message/1`, `thread_get_message/2` | saca el primer mensaje que unifica, de la cola del hilo o de otra; espera si no hay ninguno |
| `with_mutex/2` | ejecuta una meta como `once/1` con un mutex, que un solo hilo tiene por vez |
| `transaction/1` | los cambios a la base de datos de una meta se ven todos juntos al terminar, o ninguno; no excluye a otros hilos |
| `transaction/3` | como `transaction/1`, con una restricción que se verifica con un mutex antes de confirmar |
| `snapshot/1` | ejecuta una meta sobre el estado de la base de datos del momento en que empieza, y descarta sus cambios |
| `thread_local/1` | declara un predicado dinámico con cláusulas propias de cada hilo |
| `concurrent_maplist/2..4` | `maplist/2..4` con los elementos repartidos entre hilos |
| `concurrent_forall/2` | `forall/2` con las acciones repartidas entre hilos |
| `first_solution/3` | corre varias metas en hilos y se queda con la primera respuesta |
| `engine_create/3` | crea un motor sobre una meta, sin ejecutarla |
| `engine_next/2` | la respuesta siguiente de un motor; falla si no quedan |
| `engine_destroy/1` | libera un motor |
| `engine_post/3`, `engine_fetch/1`, `engine_yield/1` | pasar un término a un motor y pedirle una respuesta; tomarlo dentro; entregar una respuesta sin terminar |
| `current_engine/1` | los motores que existen |
| `http_workers/2` | la cantidad de trabajadores de un servidor HTTP; con un número, la cambia |
| bandera `cpu_count` | la cantidad de núcleos que ve SWI-Prolog |
| **[Patrón 52](../patrones.md#52-estado-compartido-detras-de-un-mutex)** | estado compartido detrás de un mutex |
| `random_member/2` | un elemento al azar de una lista (en las soluciones) |
| `subset/2` | se cumple si todos los elementos de la primera lista están en la segunda; en las pruebas |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Tablas compartidas entre hilos: la tabulación con varios hilos | [capítulo 40](../capitulo-40-tabulacion/index.md) |
| Buscar jugadas en paralelo y con un límite de tiempo | [capítulo 42](../capitulo-42-juegos/index.md) |
| Preguntas en castellano sobre *Inscripciones* desde el servicio | [capítulo 88](../capitulo-88-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- El manual de SWI-Prolog: «The HTTP server libraries»
  ([en línea](https://www.swi-prolog.org/pldoc/man?section=httpserver)),
  `with_mutex/2` ([en línea](https://www.swi-prolog.org/pldoc/man?predicate=with_mutex/2))
  y «Transactions» ([en línea](https://www.swi-prolog.org/pldoc/man?section=transactions)).
  Esta página toma de ahí los hilos trabajadores del servidor y las
  garantías del mutex y de las transacciones que usan sus manejadores.

El código es propio, escrito para el curso sobre los módulos del
[capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md), y las mediciones son del curso: las fuentes aportan las
primitivas y sus garantías, no código copiado ni adaptado.
