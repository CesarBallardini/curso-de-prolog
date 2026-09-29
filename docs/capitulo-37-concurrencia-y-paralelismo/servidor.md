# Los hilos del servidor HTTP

Esta página contiene la [sección 37.6](index.md#376-los-hilos-del-servidor-http) del
[capítulo 37](index.md): cómo atiende los pedidos el servidor HTTP de los
capítulos [30](../capitulo-30-servicios-web-rest/index.md) y
[31](../capitulo-31-ejecutables-y-distribucion/index.md), con un conjunto de hilos trabajadores, y qué
exige eso de los manejadores. Aplica al servidor lo que la
[sección 37.3](index.md#373-estado-compartido) mostró sobre el estado compartido, y la
[sección 37.7](index.md#377-inscripciones-concurrentes) lo aplica al servicio de *Inscripciones*.
El ejemplo es `servidor.pl`, en `ejemplos/capitulo-37/`, con sus pruebas.

`http_server/2`, de `library(http/thread_httpd)`, arranca un servidor con
un hilo que acepta las conexiones y un conjunto de **hilos trabajadores**: el
primero pone cada conexión en una cola, y un trabajador libre la saca, lee el
pedido, llama al manejador y responde. La opción `workers(N)` fija cuántos
son, 5 si no se indica, y `http_workers/2` los consulta o los cambia con el
servidor en marcha. `servidor.pl` arranca uno con tres trabajadores:

<!-- ejemplo: capitulo-37/servidor.pl predicado: iniciar/2 hilo/1 -->
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
capítulos [30](../capitulo-30-servicios-web-rest/index.md#301-un-servidor-en-diez-lineas) y [31](../capitulo-31-ejecutables-y-distribucion/index.md#318-el-proyecto-inscripciones-se-entrega) arranca con `http_server/1`, de
`library(http/http_server)`, que usa el mismo mecanismo y agrega trabajadores
cuando hay pedidos esperando: empieza con 5 y crece hasta 100, y los
trabajadores agregados terminan después de 10 segundos sin trabajo. Un hilo
propio de la biblioteca, `__http_scheduler`, decide cuándo agregar uno.

Un manejador, entonces, puede estar corriendo en varios trabajadores a la
vez, y todo lo de la [sección 37.3](index.md#373-estado-compartido) se aplica. `contar/1`
suma una visita a `visitas/1` como `descontar/1` descontaba una vacante, y
`contar_seguro/1` hace lo mismo con un mutex:

<!-- ejemplo: capitulo-37/servidor.pl predicado: contar/1 contar_seguro/1 sumar_visita/1 -->
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
carreras son menos que en la [sección 37.3](index.md#373-estado-compartido); no por eso
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
