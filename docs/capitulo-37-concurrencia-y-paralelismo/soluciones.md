# Soluciones del capítulo 37 — Concurrencia y paralelismo

El código de esta página está en `ejemplos/capitulo-37/`: `soluciones.pl`
para los ejercicios 2, 4, 6, 7, 10, 11 y 12, `soluciones_servidor.pl` para
el 13 y `soluciones_inscripciones.pl` para el 14 y el 15, cada uno con sus
pruebas. Como las del capítulo, las pruebas que usan hilos comparan
cantidades o conjuntos, nunca el orden en que los hilos terminan. Ningún
archivo corre en SWISH.

## 1

<!-- ejemplo: capitulo-37/hilos.pl predicado: ejecutar/2 -->
```prolog
%!  ejecutar(:Meta, -Estado) is det.
%
%   Corre Meta en un hilo nuevo y espera a que termine. Estado es true si
%   Meta tuvo éxito, false si falló, o exception(E) si lanzó E. Las
%   ligaduras que Meta haga en el otro hilo no llegan a este.
ejecutar(Meta, Estado) :-
    thread_create(Meta, Id),
    thread_join(Id, Estado).
```

```prolog
?- ejecutar(fail, E).
E = false.

?- ejecutar(atom_length(X, 3), E).
E = exception(error(instantiation_error, context(system:atom_length/2, _))).

?- en_paralelo([X = 1, X = 2], Es).
Es = [true, true].
```

La segunda meta produce un error de instanciación en el otro hilo, que
`thread_join/2` entrega como estado; la consulta no lanza nada. En la
tercera, cada hilo recibe su propia copia de la meta: `X = 1` y `X = 2`
ligan variables distintas, y las dos tienen éxito. La cuarta puede cambiar
de una ejecución a otra:

```text
?- retractall(visto(_)), en_paralelo([assertz(visto(a)), retract(visto(a))], Es).
Es = [true, true].
```

Si el hilo del `assertz/1` agrega el hecho antes de que el otro lo busque,
`retract/1` lo encuentra y el resultado es `[true, true]`; si no, el
resultado es `[true, false]` y el hecho queda en la base de datos. En esta
máquina salió `[true, true]` en todas las ejecuciones probadas, lo que no
prueba que la otra intercalación no ocurra: el programa la permite.

## 2

<!-- ejemplo: capitulo-37/soluciones.pl predicado: respuestas_en_hilo/3 responder/3 -->
```prolog
%!  respuestas_en_hilo(?Plantilla, :Meta, -Lista:list) is det.
%
%   Lista es findall(Plantilla, Meta, Lista), calculada en un hilo nuevo y
%   recibida por la cola del hilo que llama. Si Meta lanza una excepción,
%   se lanza también aquí.
respuestas_en_hilo(Plantilla, Meta, Lista) :-
    thread_self(Yo),
    thread_create(responder(Yo, Plantilla, Meta), Id),
    thread_get_message(respuestas(Id, R)),
    thread_join(Id, _),
    (   R = ok(Lista0)
    ->  Lista = Lista0
    ;   R = error(E),
        throw(E)
    ).

%!  responder(+Destino, ?Plantilla, :Meta) is det.
%
%   Envía a Destino respuestas(Yo, ok(Lista)), con Lista las respuestas de
%   Meta, o respuestas(Yo, error(E)) si Meta lanza E. Yo es este hilo.
responder(Destino, Plantilla, Meta) :-
    thread_self(Yo),
    catch(( findall(Plantilla, Meta, Lista),
            R = ok(Lista) ),
          E,
          R = error(E)),
    thread_send_message(Destino, respuestas(Yo, R)).
```

```prolog
?- respuestas_en_hilo(X, member(X, [a, b, c]), L).
L = [a, b, c].
```

El hilo nuevo envía el resultado a la cola del hilo que llama, junto con su
propio identificador: `thread_get_message/1` espera el mensaje de **ese**
hilo, aunque en la cola haya otros. La excepción viaja como dato,
`error(E)`, y se vuelve a lanzar en el hilo que llama; la prueba
`respuestas_error` lo comprueba con `atom_length(X, _)`.

## 3

Los tres trabajadores esperan en la cola de pendientes; el único `fin` lo
toma uno de ellos, que termina, y los otros dos siguen esperando un mensaje
que nadie envía. El productor queda detenido en `maplist(thread_join, Ids,
_)`, esperando a esos dos. Con los predicados de `colas.pl`, sin
`con_trabajadores/4`:

```text
?- message_queue_create(P), message_queue_create(H), length(Ids, 3), maplist(trabajador(cuadrado, P, H), Ids), thread_send_message(P, fin), sleep(1), findall(S, (member(Id, Ids), thread_property(Id, status(S))), Ss), forall(between(1, 2, _), thread_send_message(P, fin)), maplist(thread_join, Ids, _).
P = <message_queue>(000001a3aa7e8420),
H = <message_queue>(000001a3aa7e7be0),
Ids = [<thread>(3,000001a3aa67cbd0), <thread>(4,000001a3aa67cc30), <thread>(5,000001a3aa67cd50)],
Ss = [true, running, running].
```

Un segundo después del `fin`, un trabajador terminó y dos siguen corriendo;
qué trabajador terminó cambia de una ejecución a otra. Los dos `fin` que
faltan los terminan, y `thread_join/2` ya no espera. Esperar con
`call_with_time_limit/2` alrededor de `thread_join/2` no sirve en todos los
sistemas: en Linux la espera se interrumpe a los dos segundos, pero en
Windows, con SWI-Prolog 9.2.9, `thread_join/2` no atiende la señal y la
sesión queda detenida.

## 4

<!-- ejemplo: capitulo-37/soluciones.pl predicado: tuberia/2 cuadrar/2 sumar_cola/3 -->
```prolog
%!  tuberia(+Xs:list(number), -Suma:number) is det.
%
%   Suma es la suma de los cuadrados de Xs. Un hilo eleva al cuadrado y
%   otro suma; los une una cola, y el hilo que llama pone los números en
%   otra.
tuberia(Xs, Suma) :-
    thread_self(Yo),
    message_queue_create(Numeros),
    message_queue_create(Cuadrados),
    thread_create(cuadrar(Numeros, Cuadrados), Id1),
    thread_create(sumar_cola(Cuadrados, 0, Yo), Id2),
    forall(member(X, Xs), thread_send_message(Numeros, dato(X))),
    thread_send_message(Numeros, fin),
    thread_get_message(suma(Suma)),
    thread_join(Id1, _),
    thread_join(Id2, _),
    message_queue_destroy(Numeros),
    message_queue_destroy(Cuadrados).

%!  cuadrar(+Entrada, +Salida) is det.
%
%   Por cada dato(X) de Entrada envía dato(Y), con Y el cuadrado de X, a
%   Salida; al recibir fin, envía fin y termina.
cuadrar(Entrada, Salida) :-
    thread_get_message(Entrada, M),
    (   M = dato(X)
    ->  Y is X * X,
        thread_send_message(Salida, dato(Y)),
        cuadrar(Entrada, Salida)
    ;   thread_send_message(Salida, fin)
    ).

%!  sumar_cola(+Entrada, +S0:number, +Destino) is det.
%
%   Suma los dato(X) de Entrada a S0; al recibir fin, envía suma(S) a
%   Destino y termina.
sumar_cola(Entrada, S0, Destino) :-
    thread_get_message(Entrada, M),
    (   M = dato(X)
    ->  S1 is S0 + X,
        sumar_cola(Entrada, S1, Destino)
    ;   thread_send_message(Destino, suma(S0))
    ).
```

```prolog
?- tuberia([1, 2, 3], S).
S = 14.

?- tuberia([], S).
S = 0.
```

El `fin` recorre la tubería detrás de los datos: el primer hilo lo recibe
después del último número, lo reenvía y termina; el segundo lo recibe
después del último cuadrado, envía la suma y termina. Como las colas
conservan el orden de llegada, ningún dato queda atrás del `fin`. La prueba
`tuberia` comprueba además que la cantidad de hilos al terminar es la misma
que al empezar.

## 5

Las filas son los pasos, en el orden en que ocurren; cada hilo ejecuta las
líneas de `reservar/3` y de `descontar/1`. Primera intercalación, con
`vacantes(m, 1)`:

| Paso | Hilo A | Hilo B | Base de datos |
|---|---|---|---|
| 1 | `vacantes(m, N)`: N = 1 | | `vacantes(m, 1)` |
| 2 | | `vacantes(m, N)`: N = 1 | `vacantes(m, 1)` |
| 3 | `N > 0`, `assertz(inscripto(a, m))` | | |
| 4 | | `N > 0`, `assertz(inscripto(b, m))` | dos inscriptos |
| 5 | `descontar/1`: `retract(vacantes(m, 1))`, `assertz(vacantes(m, 0))` | | `vacantes(m, 0)` |
| 6 | | `descontar/1`: `retract(vacantes(m, 0))`, `assertz(vacantes(m, -1))` | `vacantes(m, -1)` |

Los dos leyeron un lugar libre antes de que alguno lo descontara. Segunda
intercalación, con `vacantes(m, 5)`:

| Paso | Hilo A | Hilo B | Base de datos |
|---|---|---|---|
| 1 | `vacantes(m, N)`: N = 5; `assertz(inscripto(a, m))` | | `vacantes(m, 5)` |
| 2 | `descontar/1`: `retract/1` empieza a recorrer `vacantes/2` y ve `vacantes(m, 5)` | | |
| 3 | | `descontar/1`: `retract(vacantes(m, 5))` | sin hecho de vacantes |
| 4 | | `assertz(vacantes(m, 4))` | `vacantes(m, 4)` |
| 5 | `retract/1` intenta quitar `vacantes(m, 5)`, que ya no existe; `vacantes(m, 4)` no es visible para esa llamada | | |
| 6 | `retract/1` falla, `reservar/3` falla | | `inscripto(a, m)` sin vacante descontada |

La vista lógica de la [sección 20.3](../capitulo-20-base-de-datos-dinamica/index.md#203-la-vista-logica-de-actualizacion) fija qué cláusulas ve una
llamada al empezar: la que agrega otro hilo después no está entre ellas.

## 6

<!-- ejemplo: capitulo-37/soluciones.pl predicado: sumar_cas/1 -->
```prolog
%!  sumar_cas(-N:integer) is det.
%
%   Suma uno a contador/1 con transaction/3: lee el valor fuera del mutex y
%   lo reemplaza solo si sigue siendo el que leyó; si no, repite. N es el
%   valor nuevo.
sumar_cas(N) :-
    repeat,
    transaction(( contador(N0),
                  N is N0 + 1 ),
                ( retract(contador(N0)),
                  assertz(contador(N)) ),
                contador),
    !.
```

```prolog
?- sumar_en_hilos(8, 1000, F).
F = 8000.
```

La meta lee el contador y calcula el siguiente fuera del mutex; la
restricción, con el mutex `contador`, quita el valor leído y agrega el
nuevo. Si otro hilo confirmó antes, el valor leído ya no está, `retract/1`
falla, la transacción se descarta y `repeat/0` vuelve a empezar.

## 7

<!-- ejemplo: capitulo-37/soluciones.pl predicado: mover/3 transferir_ingenuo/3 transferir/3 -->
```prolog
%!  mover(+Desde:atom, +Hacia:atom, +Monto:integer) is det.
%
%   Resta Monto del saldo de Desde y lo suma al de Hacia, sin protección.
mover(Desde, Hacia, Monto) :-
    retract(saldo(Desde, S0)),
    S is S0 - Monto,
    assertz(saldo(Desde, S)),
    retract(saldo(Hacia, T0)),
    T is T0 + Monto,
    assertz(saldo(Hacia, T)).

%!  transferir_ingenuo(+Desde:atom, +Hacia:atom, +Monto:integer) is det.
%
%   Toma el mutex de Desde y después el de Hacia. Dos hilos que transfieren
%   en sentidos opuestos pueden esperarse para siempre.
transferir_ingenuo(Desde, Hacia, Monto) :-
    with_mutex(Desde,
               with_mutex(Hacia, mover(Desde, Hacia, Monto))).

%!  transferir(+Desde:atom, +Hacia:atom, +Monto:integer) is det.
%
%   Toma los dos mutex siempre en el orden de sus nombres: ningún hilo
%   espera un mutex que tiene otro hilo que a su vez espera el suyo.
transferir(Desde, Hacia, Monto) :-
    msort([Desde, Hacia], [Primero, Segundo]),
    with_mutex(Primero,
               with_mutex(Segundo, mover(Desde, Hacia, Monto))).
```

`opuestas/3`, en el mismo archivo, corre dos hilos que transfieren en
sentidos opuestos y espera cinco segundos a que terminen:

```text
?- opuestas(transferir_ingenuo, 10000, R).
R = detenidos.

?- opuestas(transferir, 10000, R).
R = terminaron.
```

Con `transferir_ingenuo/3`, un hilo toma el mutex `a` y espera `b`, y el
otro toma `b` y espera `a`: ninguno puede seguir, y los dos quedan
esperando para siempre. Es un **interbloqueo**, y no hay error que lo
avise. Con `transferir/3`, los dos hilos toman primero el mutex de nombre
menor: el que lo obtiene obtiene también el segundo, porque nadie lo tiene
sin tener antes el primero. Con ocho hilos y transferencias al azar:

```prolog
?- al_azar(8, 1250, T, H).
T = 4000,
H = 4.
```

Diez mil transferencias, y la suma de los saldos sigue siendo 4 000, con un
hecho por cuenta. La prueba `opuestas` de `soluciones.plt` usa la versión
corregida; la ingenua no se prueba, porque su resultado depende del orden de
los hilos y, cuando falla, deja dos hilos detenidos.

## 8

<!-- ejemplo: capitulo-37/memo.pl fragmento: :- thread_local guardado_local/2. .. :- thread_local guardado_local/2. -->
```prolog
:- thread_local guardado_local/2.
```

```text
?- thread_create((assertz(guardado_local(7, 13)), nb_setval(k, 1)), Id), thread_join(Id, E), aggregate_all(count, guardado_local(_, _), N).
Id = <thread>(3,00000194bf08d740),
E = true,
N = 0.
```

Las cláusulas de un predicado `thread_local` que agregó un hilo se borran
cuando el hilo termina, y sus variables globales también: no queda nada que
consultar, desde ningún hilo. Mientras el hilo vive, solo él las ve; por eso
el hilo principal cuenta 0 aunque el otro haya agregado un hecho.

## 9

`concurrent_forall/3` con la misma condición y la misma acción que
`goldbach_paralelo/1`, hasta 100 000, con `paralelo.pl` cargado:

```text
?- time(concurrent_forall(between(2, 50000, I), (P is 2 * I, suma_de_primos(P, _)), [threads(1)])).
% 34,791,105 inferences, 3.016 CPU in 3.023 seconds (100% CPU, 11536947 Lips)
true.

?- time(concurrent_forall(between(2, 50000, I), (P is 2 * I, suma_de_primos(P, _)), [threads(2)])).
% 35,235,423 inferences, 3.234 CPU in 1.646 seconds (196% CPU, 10894044 Lips)
true.

?- time(concurrent_forall(between(2, 50000, I), (P is 2 * I, suma_de_primos(P, _)), [threads(4)])).
% 35,175,099 inferences, 3.406 CPU in 0.837 seconds (407% CPU, 10326635 Lips)
true.

?- time(concurrent_forall(between(2, 50000, I), (P is 2 * I, suma_de_primos(P, _)), [threads(8)])).
% 35,175,155 inferences, 3.656 CPU in 0.469 seconds (780% CPU, 9620555 Lips)
true.

?- time(concurrent_forall(between(2, 50000, I), (P is 2 * I, suma_de_primos(P, _)), [threads(16)])).
% 35,175,267 inferences, 4.406 CPU in 0.348 seconds (1265% CPU, 7983039 Lips)
true.
```

| Hilos | Segundos | Mejora | Tiempo de procesador |
|---|---|---|---|
| 1 | 3,02 | 1,0 | 3,02 |
| 2 | 1,65 | 1,8 | 3,23 |
| 4 | 0,84 | 3,6 | 3,41 |
| 8 | 0,47 | 6,4 | 3,66 |
| 16 | 0,35 | 8,7 | 4,41 |

Hasta 8 hilos, la mejora sigue de cerca a la cantidad de hilos: cada uno
tiene un núcleo para él. De 8 a 16, en cambio, solo pasa de 6,4 a 8,7: la
máquina tiene 8 núcleos, y los 16 hilos de ejecución que informa
`cpu_count` son dos por núcleo, que comparten sus unidades de cálculo. El
tiempo de procesador total crece con los hilos, de 3,0 a 4,4 segundos: cada
hilo avanza más despacio cuando comparte el núcleo, y repartir los trabajos
también cuesta.

## 10

<!-- ejemplo: capitulo-37/soluciones.pl predicado: posicion_extremos/3 desde_el_principio/3 desde_el_final/3 -->
```prolog
%!  posicion_extremos(+Lista:list, :Condicion, -Pos:integer) is semidet.
%
%   Pos es la posición, desde 1, de un elemento de Lista que cumple
%   Condicion: el primero desde el principio o el primero desde el final,
%   según qué búsqueda termine antes. Falla si ninguno la cumple.
posicion_extremos(Lista, Condicion, Pos) :-
    first_solution(Pos, [ desde_el_principio(Lista, Condicion, Pos),
                          desde_el_final(Lista, Condicion, Pos) ],
                   []).

%!  desde_el_principio(+Lista:list, :Condicion, -Pos:integer) is semidet.
%
%   Pos es la posición del primer elemento de Lista que cumple Condicion.
desde_el_principio(Lista, Condicion, Pos) :-
    nth1(Pos, Lista, X),
    call(Condicion, X),
    !.

%!  desde_el_final(+Lista:list, :Condicion, -Pos:integer) is semidet.
%
%   Pos es la posición del último elemento de Lista que cumple Condicion.
desde_el_final(Lista, Condicion, Pos) :-
    reverse(Lista, Invertida),
    length(Lista, N),
    nth1(I, Invertida, X),
    call(Condicion, X),
    !,
    Pos is N + 1 - I.
```

```prolog
?- posicion_extremos([1, 3, 4, 5, 7], [X]>>(0 is X mod 2), P).
P = 3.
```

La respuesta depende del orden de los hilos cuando más de un elemento
cumple la condición: en `[1, 2, 3, 4, 5]` con los pares, la búsqueda desde
el principio da 2 y la búsqueda desde el final da 4, y gana la que termina
primero. Con un solo elemento que la cumple, las dos dan la misma posición.
La prueba `extremos_dos` acepta cualquiera de las dos respuestas posibles,
con `memberchk/2`, y `extremos_unico` exige la única.

## 11

<!-- ejemplo: capitulo-37/soluciones.pl predicado: emparejar/4 pares/4 -->
```prolog
%!  emparejar(+N:integer, :Gen1, :Gen2, -Pares:list) is det.
%
%   Pares son los primeros N pares X-Y, con X la i-ésima respuesta de
%   call(Gen1, X) e Y la i-ésima de call(Gen2, Y); menos, si alguno de los
%   dos generadores se termina antes.
emparejar(N, Gen1, Gen2, Pares) :-
    setup_call_cleanup(( engine_create(X, call(Gen1, X), M1),
                         engine_create(Y, call(Gen2, Y), M2) ),
                       pares(N, M1, M2, Pares),
                       ( engine_destroy(M1),
                         engine_destroy(M2) )).

%!  pares(+N:integer, +M1, +M2, -Pares:list) is det.
%
%   Pares son los N pares siguientes de las respuestas de M1 y M2.
pares(N, M1, M2, Pares) :-
    (   N > 0,
        engine_next(M1, X),
        engine_next(M2, Y)
    ->  Pares = [X-Y|Resto],
        N1 is N - 1,
        pares(N1, M1, M2, Resto)
    ;   Pares = []
    ).
```

```prolog
?- emparejar(3, multiplo(2), multiplo(5), P).
P = [2-5, 4-10, 6-15].
```

Cada motor conserva el punto en que quedó su generador, y `pares/4` pide una
respuesta a cada uno en cada llamada. Si uno de los dos se termina antes, la
lista se corta allí: `emparejar(5, multiplo(2), [X]>>member(X, [a, b]), P)`
da `[2-a, 4-b]`.

## 12

<!-- ejemplo: capitulo-37/soluciones.pl predicado: nuevo_generador/1 identificador/2 siguiente_id/2 -->
```prolog
%!  nuevo_generador(-Motor) is det.
%
%   Motor da los identificadores id(1), id(2), ... de a uno.
nuevo_generador(Motor) :-
    engine_create(Id, identificador(1, Id), Motor).

%!  identificador(+N:integer, -Id) is multi.
%
%   Id es id(N), id(N + 1), ..., en ese orden, sin fin.
identificador(N, id(N)).
identificador(N, Id) :-
    N1 is N + 1,
    identificador(N1, Id).

%!  siguiente_id(+Motor, -Id) is det.
%
%   Id es el identificador siguiente de Motor.
siguiente_id(Motor, Id) :-
    engine_next(Motor, Id).
```

Un motor se puede usar desde cualquier hilo, pero de a uno por vez: si un
hilo llama a `engine_next/2` mientras otro está ejecutando el mismo motor,
la segunda llamada espera a que termine la primera. Así, cuatro hilos que
piden 100 identificadores cada uno al mismo motor reciben los números del
1 al 400, sin repetidos, repartidos de cualquier manera entre los hilos; la
prueba `identificadores_hilos` reúne las cuatro listas, las ordena y las
compara con `numlist(1, 400, L)`.

## 13

<!-- ejemplo: capitulo-37/soluciones_servidor.pl predicado: contar_por_hilo/1 visitas_por_hilo/3 -->
```prolog
%!  contar_por_hilo(+Pedido) is det.
%
%   Suma una visita a la cuenta del trabajador que atiende el pedido, y
%   responde con su nombre y su cuenta.
contar_por_hilo(_Pedido) :-
    (   retract(visitas_del_hilo(N0))
    ->  true
    ;   N0 = 0
    ),
    N is N0 + 1,
    assertz(visitas_del_hilo(N)),
    thread_self(Yo),
    reply_json_dict(_{hilo: Yo, visitas: N}).

%!  visitas_por_hilo(+Puerto:integer, +N:integer, -Cuentas:list) is det.
%
%   Hace N pedidos simultáneos de /contar_por_hilo. Cuentas son los pares
%   Hilo-Maximo: la mayor cuenta que respondió cada trabajador.
visitas_por_hilo(Puerto, N, Cuentas) :-
    numlist(1, N, Is),
    concurrent_maplist(visita(Puerto), Is, Pares),
    msort(Pares, Ordenados),
    findall(H-Max, aggregate(max(V), member(H-V, Ordenados), Max), Cuentas).
```

```text
?- iniciar(P, 3), visitas_por_hilo(P, 30, Cuentas), visitas_por_hilo(P, 30, C2), detener(P).
% Started server at http://localhost:51137/
P = 51137,
Cuentas = ["httpd@localhost:51137_1"-9, "httpd@localhost:51137_2"-11, "httpd@localhost:51137_3"-10],
C2 = ["httpd@localhost:51137_1"-19, "httpd@localhost:51137_2"-21, "httpd@localhost:51137_3"-20].
```

Cada trabajador cuenta solo los pedidos que atendió él, y su cuenta no
vuelve a cero entre un pedido y el siguiente, ni entre una tanda de pedidos
y la siguiente: el hilo sigue vivo. Por eso la cuenta no es la de un
cliente ni la del servidor, sino la de un trabajador, y el reparto cambia de
una ejecución a otra. Lo único que no cambia es la suma: 30 después de la
primera tanda y 60 después de la segunda, que es lo que comprueba la prueba.

## 14

<!-- ejemplo: capitulo-37/soluciones_inscripciones.pl predicado: inscripciones_finas/1 inscribir_pedido/1 -->
```prolog
%!  inscripciones_finas(+Pedido) is det.
%
%   POST /inscripciones: las mismas respuestas que el manejador de api.pl,
%   con los errores convertidos por api:responder/1, y el mutex tomado solo
%   por inscribir_seguro/3.
inscripciones_finas(Pedido) :-
    api:responder(user:inscribir_pedido(Pedido)).

%!  inscribir_pedido(+Pedido) is semidet.
%
%   Lee el legajo y la materia del cuerpo de Pedido, los inscribe con
%   inscribir_seguro/3 y responde. Falla si al cuerpo le falta un campo.
inscribir_pedido(Pedido) :-
    http_read_json_dict(Pedido, Datos, [value_string_as(atom)]),
    _{legajo: Legajo, materia: Materia} :< Datos,
    inscribir_seguro(Legajo, Materia, Respuesta),
    api:resultado_json(Respuesta, Resultado, Codigo),
    reply_json_dict(Resultado, [status(Codigo)]).
```

El manejador reutiliza dos predicados privados de `api.pl`, calificados con
el módulo: `api:responder/1`, que convierte los errores y una falla en
códigos de estado, y `api:resultado_json/3`, que da el cuerpo y el código de
la respuesta. `responder/1` no está declarado como metapredicado, y la meta
que recibe se califica con `user:`, el módulo donde está
`inscribir_pedido/1`. El mutex lo toma solo `inscribir_seguro/3`: leer el
cuerpo y escribir la respuesta ocurren fuera de él, y un cliente lento ya no
retiene a los demás. La prueba `servicio_fino` hace cuatro pedidos
simultáneos por la última vacante de Álgebra y obtiene `[201, 409, 409,
409]`, y un pedido sin materia recibe 400, como con el manejador de
`api.pl`.

## 15

<!-- ejemplo: capitulo-37/soluciones_inscripciones.pl predicado: inscribir_cas/3 coherentes/1 -->
```prolog
%!  inscribir_cas(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   inscribir/3 dentro de transaction/3: se ejecuta sin mutex, y al
%   confirmar se verifica con el mutex inscripciones que los datos sean
%   coherentes; si otra inscripción se confirmó mientras tanto, no lo son,
%   y se vuelve a empezar.
inscribir_cas(Legajo, Materia, Resultado) :-
    repeat,
    transaction(inscribir(Legajo, Materia, Resultado),
                coherentes(Materia),
                inscripciones),
    !.

%!  coherentes(+Materia:atom) is semidet.
%
%   Materia tiene un solo hecho vacantes/2, no negativo, y hay un solo
%   hecho operaciones/1.
coherentes(Materia) :-
    aggregate_all(count, vacantes(Materia, _), 1),
    vacantes(Materia, V),
    V >= 0,
    aggregate_all(count, operaciones(_), 1).
```

`carrera/4`, de `concurrente.pl`, corre la inscripción de cuatro alumnos a
la vez con una sola vacante:

```prolog
?- carrera(inscribir_cas, alg, [102, 105, 106, 107], R).
R = 1-[0].
```

`inscribir/3` corre dentro de la transacción sin mutex, sobre el estado del
momento en que empezó. Si otra inscripción se confirma mientras tanto, las
dos quitaron el mismo `vacantes(alg, 1)` y agregaron cada una su
`vacantes(alg, 0)`; al confirmar la segunda, `coherentes/1` ve los dos
hechos, falla, y la transacción se descarta y se repite, esta vez con la
vacante ya ocupada. Lo mismo ocurre con el contador de operaciones, que
cambia en toda inscripción. En mil carreras, las mil dieron una
inscripción aceptada:

```text
?- findall(R, (between(1, 1000, _), carrera(inscribir_cas, alg, [102, 105, 106, 107], R)), Rs), msort(Rs, S), clumped(S, C).
Rs = S, S = [1-[0], 1-[0], 1-[0], 1-[0], 1-[0], 1-[0], 1-[0], 1-[...], ... - ...|...],
C = [1-[0]-1000].

?- time((between(1, 1000, _), carrera(inscribir_seguro, alg, [102, 105, 106, 107], _), fail ; true)).
% 328,999 inferences, 0.156 CPU in 0.785 seconds (20% CPU, 2105594 Lips)
true.

?- time((between(1, 1000, _), carrera(inscribir_cas, alg, [102, 105, 106, 107], _), fail ; true)).
% 417,692 inferences, 0.344 CPU in 0.777 seconds (44% CPU, 1215104 Lips)
true.
```

Los tiempos son iguales: cada carrera crea cuatro hilos, y eso pesa más que
la inscripción. `inscribir_cas/3` hace más inferencias, las de las
inscripciones repetidas. Su ventaja aparecería con una decisión costosa
—muchas correlativas que verificar— que corre sin mutex; su riesgo es la
restricción, que debe detectar todo conflicto posible: una que solo verificara
las vacantes dejaría pasar dos incrementos del contador de operaciones.
