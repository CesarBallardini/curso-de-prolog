# Capítulo 30 — Servicios web (REST)

El [capítulo 29](../capitulo-29-prolog-desde-python/index.md) llevó las reglas de Prolog a un programa de Python que corre en
la misma máquina, en el mismo proceso. Un **servicio web** las ofrece a
cualquier programa, en cualquier lenguaje y en cualquier máquina de la red: el
programa cliente envía un pedido por HTTP, y el servicio responde con datos en
JSON. Es la forma en que se conectan hoy la mayoría de los programas: una
aplicación web, una aplicación de teléfono o un script le piden los datos a un
servicio, sin saber en qué lenguaje está escrito.

SWI-Prolog trae un servidor HTTP completo en su biblioteca. Este capítulo lo
usa para ofrecer reglas como servicio: rutas, parámetros, JSON de entrada y de
salida, códigos de estado para los errores, clientes en Prolog y en Python,
pruebas que arrancan el servidor, y lo que hace falta para ponerlo en
funcionamiento. El proyecto se convierte en un servicio: los alumnos, las
materias, el ranking y las inscripciones, por HTTP.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- arrancar un servidor HTTP y declarar sus rutas;
- leer parámetros y cuerpos en JSON, y responder JSON con el código de estado
  que corresponde;
- convertir los errores de las reglas en códigos de estado;
- escribir clientes del servicio en Prolog y en Python;
- probar un servicio arrancándolo en un puerto libre;
- habilitar CORS, registrar los pedidos y dejar un servicio funcionando.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:11 h**.
    Resolver los 6 ejercicios marcados con ★: **1:53 h**.
    Resolver los 14 ejercicios del final: **3:58 h**.

## 30.1 Un servidor en diez líneas

Un servidor HTTP espera **pedidos** en un **puerto** de la máquina. Cada
pedido tiene un **método** —`GET` para consultar, `POST` para enviar datos— y
una **ruta**, como `/hola`; la respuesta tiene un **código de estado** —200 si
todo salió bien— y un cuerpo. `servidor.pl` declara la ruta `/hola` con
`http_handler/3`, y el predicado que la atiende, el **manejador**, recibe el
pedido y responde:

<!-- ejemplo: capitulo-30/servidor.pl fragmento: :- use_module(library(http/http_server)). .. :- dynamic edad/2. consulta: iniciar(Puerto), detener(Puerto). -->
```prolog
:- use_module(library(http/http_server)).
:- use_module(library(http/http_json)).
:- use_module(library(error)).

:- meta_predicate responder(0).

:- dynamic edad/2.
```

<!-- ejemplo: capitulo-30/servidor.pl predicado: hola/1 iniciar/1 detener/1 consulta: iniciar(Puerto), detener(Puerto). -->
```prolog
%!  hola(+Pedido) is det.
%
%   GET /hola?nombre=N: responde {"saludo": "Hola, N"}.
hola(Pedido) :-
    http_parameters(Pedido, [nombre(Nombre, [default(mundo)])]),
    format(string(Saludo), "Hola, ~w", [Nombre]),
    reply_json_dict(_{saludo: Saludo}).

%!  iniciar(?Puerto:integer) is det.
%
%   Arranca el servidor en Puerto de la máquina local; con Puerto libre,
%   elige uno que no esté en uso.
iniciar(Puerto) :-
    http_server([port(localhost:Puerto)]).

%!  detener(+Puerto:integer) is det.
%
%   Detiene el servidor de Puerto.
detener(Puerto) :-
    http_stop_server(Puerto, []).
```

`http_server/1` arranca el servidor y vuelve enseguida: el servidor atiende
los pedidos en sus propios hilos, y el toplevel sigue disponible. Con
`port(localhost:Puerto)`, el servidor solo acepta pedidos de la misma máquina;
con `Puerto` libre, elige uno que no esté en uso y lo liga. Desde otra
terminal, `curl` —un cliente de HTTP de la línea de comandos— le hace el
pedido:

```text
$ curl http://localhost:8080/hola?nombre=ana
{"saludo":"Hola, ana"}
```

El servidor también se ejecuta como programa, con un `main/1` como los del
[capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md):

```text
$ swipl servidor.pl --puerto=8080
% Started server at http://localhost:8080/
Servidor en http://localhost:8080/
```

La primera línea es un mensaje informativo de SWI-Prolog, que `swipl -q` no
escribe; la segunda la escribe `main/1`, que después espera, con
`thread_get_message/1`, mientras los hilos del servidor atienden los pedidos.

## 30.2 Rutas y parámetros

Una ruta de `http_handler/3` puede tener partes variables. Con
`root(personas/Nombre)`, el pedido `/personas/ana` llama a
`persona(ana, Pedido)`: la parte variable llega como un átomo, en el primer
argumento del manejador. La opción `method(get)` limita la ruta a un método;
un pedido con otro método recibe el código 405. Dos rutas con partes variables
que empiezan igual, como `partidas/Id` y `partidas/Id/Accion`, no conviven en
SWI-Prolog 9.2.9: las dos quedan con las opciones de la última que se declaró.
En ese caso, una sola ruta con la opción `prefix` recibe todos los pedidos que
empiezan igual, y el manejador elige por el resto de la dirección; es lo que
hace la solución del ejercicio 14.

Los **parámetros** de la dirección, lo que sigue al `?`, se leen con
`http_parameters/2`, que declara cada uno con sus opciones:

<!-- ejemplo: capitulo-30/servidor.pl predicado: nietos/1 consulta: iniciar(Puerto), detener(Puerto). -->
```prolog
%!  nietos(+Pedido) is det.
%
%   GET /nietos?abuelo=A: responde {"abuelo": A, "nietos": [...]}.
nietos(Pedido) :-
    http_parameters(Pedido, [abuelo(Abuelo, [atom])]),
    findall(N, abuelo(Abuelo, N), Nietos),
    reply_json_dict(_{abuelo: Abuelo, nietos: Nietos}).
```

`atom`, `integer`, `between(1, 10)` o `oneof(Lista)` declaran el tipo, y
`default(Valor)` lo hace optativo. Un parámetro que falta o que no tiene el
tipo declarado no llega al manejador: el servidor responde 400 —pedido
incorrecto— con el motivo:

```text
$ curl -H "Accept: application/json" http://localhost:8080/nietos
{"code":400,"message":"Missing value for parameter \"abuelo\"."}
```

## 30.3 JSON de entrada y de salida

`reply_json_dict/1,2`, de `library(http/http_json)`, responde un dict de
Prolog como un objeto de JSON, y una lista como un arreglo; la opción
`status(Codigo)` elige el código de estado. `http_read_json_dict/3` lee el
cuerpo de un pedido `POST` en JSON y lo convierte en un dict:

<!-- ejemplo: capitulo-30/servidor.pl predicado: edades/1 cambiar_edad/2 consulta: iniciar(Puerto), detener(Puerto). -->
```prolog
%!  edades(+Pedido) is det.
%
%   POST /edades con {"nombre": N, "edad": E}: cambia la edad y responde la
%   ficha nueva con el código 201.
edades(Pedido) :-
    responder(( http_read_json_dict(Pedido, Datos, [value_string_as(atom)]),
                _{nombre: Nombre, edad: Anios} :< Datos,
                cambiar_edad(Nombre, Anios),
                ficha(Nombre, Ficha),
                reply_json_dict(Ficha, [status(201)]) )).

%!  cambiar_edad(+Persona:atom, +Anios:integer) is det.
%
%   Registra que Persona tiene Anios años.
%
%   @error type_error(nonneg, Anios) si Anios no es un entero no negativo.
%   @error existence_error(persona, Persona) si no se conoce a Persona.
cambiar_edad(Persona, Anios) :-
    must_be(nonneg, Anios),
    (   retract(edad(Persona, _))
    ->  assertz(edad(Persona, Anios))
    ;   existence_error(persona, Persona)
    ).
```

```text
$ curl -X POST -H "Content-Type: application/json" \
       -d '{"nombre": "juan", "edad": 69}' http://localhost:8080/edades
{"edad":69,"hijos": ["ana", "pedro" ],"nombre":"juan"}
```

La conversión es la del [capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md#277-json): la opción
`value_string_as(atom)` lee los textos como átomos, y `:<` extrae los campos
que el manejador necesita. 201 —creado— es el código de un `POST` que
registró algo. En JSON, los booleanos se escriben `true` y `false`, y la
ausencia de valor, `null`: en un dict de Prolog son esos mismos átomos. La
notación `@(true)` del [capítulo 29](../capitulo-29-prolog-desde-python/index.md) es de Janus, y no sirve para JSON.

## 30.4 Códigos de estado y errores

Un servicio que responde 200 a todo obliga a su cliente a examinar cada
respuesta para saber si funcionó. El código de estado lo dice antes de leer
el cuerpo:

| Código | Significa | En este capítulo |
|---|---|---|
| 200 | correcto | una consulta |
| 201 | creado | un `POST` que registró un dato |
| 400 | pedido incorrecto | un parámetro que falta, un tipo equivocado, un JSON mal formado |
| 404 | no encontrado | una ruta, una persona o una materia que no existen |
| 405 | método no permitido | `POST` a una ruta de `GET` |
| 409 | conflicto | una inscripción que las reglas rechazan |
| 500 | error interno | un error del programa, no del pedido |

Las reglas de `servidor.pl` ya producen errores del
[capítulo 25](../capitulo-25-errores-y-excepciones/index.md): `ficha/2` lanza un error de existencia para una persona
desconocida, y `cambiar_edad/2` uno de tipo para una edad negativa. Los
manejadores no los examinan uno por uno: `responder/1` ejecuta el manejador y
convierte cada clase de error en su código:

<!-- ejemplo: capitulo-30/servidor.pl predicado: persona/2 responder/1 responder_error/1 codigo_de_error/2 consulta: iniciar(Puerto), detener(Puerto). -->
```prolog
%!  persona(+Nombre:atom, +Pedido) is det.
%
%   GET /personas/Nombre: responde la ficha de la persona, o 404.
persona(Nombre, _Pedido) :-
    responder(( ficha(Nombre, Ficha),
                reply_json_dict(Ficha) )).

%!  responder(:Objetivo) is det.
%
%   Ejecuta Objetivo, que responde el pedido. Si produce un error de tipo o
%   de dominio, responde 400; si es de existencia, 404; si falla, como
%   cuando al cuerpo le falta un campo, 400. Los demás errores siguen su
%   camino, y el servidor responde 500.
responder(Objetivo) :-
    catch(( Objetivo
          ->  true
          ;   reply_json_dict(_{error: "pedido incompleto"}, [status(400)])
          ),
          error(Formal, _),
          responder_error(Formal)).

%!  responder_error(+Formal) is det.
%
%   Responde el error Formal con su código de estado.
responder_error(Formal) :-
    codigo_de_error(Formal, Codigo),
    !,
    format(string(Texto), "~w", [Formal]),
    reply_json_dict(_{error: Texto}, [status(Codigo)]).
responder_error(Formal) :-
    throw(error(Formal, _)).

%!  codigo_de_error(+Formal, -Codigo:integer) is semidet.
%
%   Codigo es el código de estado de HTTP del error Formal.
codigo_de_error(type_error(_, _), 400).
codigo_de_error(domain_error(_, _), 400).
codigo_de_error(syntax_error(_), 400).
codigo_de_error(existence_error(_, _), 404).
```

`responder/1` ejecuta su argumento como una meta, y la declaración
`:- meta_predicate responder(0)` del comienzo de `servidor.pl` lo dice, como
en la [sección 24.4](../capitulo-24-modulos-y-organizacion/index.md#244-meta_predicate-y-los-modulos). Un error que no está en la tabla sigue su camino, y el servidor responde 500,
el código de un error del programa. Los errores que el propio servidor
detecta —una ruta que no existe, un parámetro que falta— los responde en
HTML, salvo que el pedido diga, con el encabezado `Accept:
application/json`, que el cliente espera JSON: entonces los responde en JSON,
como los demás.

!!! example "Patrón 40 — Un endpoint JSON"
    **Problema.** Una ruta del servicio tiene que leer datos del pedido,
    aplicar las reglas y responder, y cada falla de las reglas tiene que
    llegar al cliente como un código de estado, no como un 500 ni como un
    200 con un mensaje de error.

    **Versión ingenua.** Un manejador largo, que valida los datos a mano,
    llama a las reglas, examina cada resultado con `->` y escribe la
    respuesta en cada rama, con los códigos elegidos en cada lugar.

    **Patrón.** Un manejador corto por ruta: lee los parámetros con
    `http_parameters/2` o el cuerpo con `http_read_json_dict/3`, llama al
    núcleo y responde con `reply_json_dict/2`. Las reglas señalan los
    problemas con errores ISO, y un solo predicado, `responder/1`, convierte
    cada clase de error en su código: tipo y dominio en 400, existencia en
    404. El núcleo no depende de HTTP.

    **Cuándo no usarlo.** En una ruta que devuelve un archivo o una página
    HTML: no hay JSON que armar, y los errores del servidor alcanzan.

!!! question "Actividad"
    Con el servidor ejecutándose, hacer con `curl` un `GET` a `/personas/zoe`,
    un `POST` a `/hola` y un `POST` a `/edades` con el cuerpo `{mal`, primero
    sin y después con `-H "Accept: application/json"`. ¿Qué código y qué
    cuerpo recibe cada pedido? ¿Cuáles responde `responder/1`, y cuáles el
    servidor?

## 30.5 Clientes

Un cliente de Prolog usa `http_open/3`, que abre la respuesta de un pedido
como un stream, y `http_post/4` para enviar datos. `cliente.pl` arma las
direcciones con `library(uri)`, que codifica los valores: un nombre con
espacios, con tildes o con `&` no rompe la dirección, por la misma razón que
el [capítulo 29](../capitulo-29-prolog-desde-python/index.md) pasaba los valores como ligaduras:

<!-- ejemplo: capitulo-30/cliente.pl predicado: direccion/4 obtener_json/3 ficha_remota/3 consulta: direccion('http://localhost:8080', '/nietos', [abuelo=juan], Url). -->
```prolog
%!  direccion(+Base:atom, +Ruta:atom, +Parametros:list, -Url:atom) is det.
%
%   Url es Ruta en el servidor de Base, con Parametros, pares Nombre=Valor,
%   codificados como parámetros de la dirección.
direccion(Base, Ruta, Parametros, Url) :-
    atom_concat(Base, Ruta, Url0),
    (   Parametros == []
    ->  Url = Url0
    ;   uri_query_components(Consulta, Parametros),
        atomic_list_concat([Url0, '?', Consulta], Url)
    ).

%!  obtener_json(+Url:atom, -Codigo:integer, -Respuesta:dict) is det.
%
%   Hace GET a Url; Codigo es el código de estado y Respuesta, el cuerpo
%   de la respuesta leído como JSON.
obtener_json(Url, Codigo, Respuesta) :-
    setup_call_cleanup(
        http_open(Url, Stream,
                  [ status_code(Codigo),
                    request_header('Accept'='application/json') ]),
        json_read_dict(Stream, Respuesta),
        close(Stream)).

%!  ficha_remota(+Base:atom, +Persona:atom, -Ficha:dict) is semidet.
%
%   Ficha es la ficha de Persona según el servidor de Base. Falla si el
%   servidor responde 404.
%
%   @error http_status(Codigo) con cualquier otro código que no sea 200.
ficha_remota(Base, Persona, Ficha) :-
    uri_encoded(segment, Persona, Segmento),
    atom_concat('/personas/', Segmento, Ruta),
    direccion(Base, Ruta, [], Url),
    obtener_json(Url, Codigo, Respuesta),
    (   Codigo =:= 200
    ->  Ficha = Respuesta
    ;   Codigo =:= 404
    ->  fail
    ;   throw(http_status(Codigo))
    ).
```

```prolog
?- direccion('http://localhost:8080', '/nietos', [abuelo='juan pérez'], Url).
Url = 'http://localhost:8080/nietos?abuelo=juan%20p%C3%A9rez'.
```

`uri_query_components/2` arma la consulta de la dirección con los pares
`Nombre=Valor`, y `uri_encoded/3` codifica un valor para una parte de la
dirección, aquí un segmento de la ruta.

La opción `status_code(Codigo)` de `http_open/3` entrega el código en lugar de
lanzar un error cuando no es 200, y `ficha_remota/3` decide qué hacer con
cada uno: 404 es una falla, como `edad_de/2` con una persona desconocida;
cualquier otro código distinto de 200, un error.

Del lado de Python, `urllib.request`, de la biblioteca estándar, hace lo
mismo; el paquete `requests` es una alternativa muy usada, con una
interfaz más breve. El cliente convierte el 404 en una excepción, como la
frontera del [Patrón 39](../patrones.md#39-frontera-pythonprolog):

<!-- ejemplo: capitulo-30/cliente.py fragmento: class PersonaDesconocidaError .. return cuerpo['nietos'] -->
```python
class PersonaDesconocidaError(LookupError):
    """El servidor no conoce a la persona: respondió 404."""


def _pedir(pedido):
    """Hace el pedido; devuelve el código de estado y el cuerpo leído como JSON."""
    try:
        with urllib.request.urlopen(pedido) as respuesta:  # noqa: S310
            return respuesta.status, json.load(respuesta)
    except urllib.error.HTTPError as error:
        return error.code, json.load(error)


def ficha(base, persona):
    """Devuelve la ficha de persona, o lanza PersonaDesconocidaError."""
    ruta = urllib.parse.quote(persona)
    codigo, cuerpo = _pedir(f'{base}/personas/{ruta}')
    if codigo == 404:
        raise PersonaDesconocidaError(persona)
    return cuerpo


def nietos(base, abuelo):
    """Devuelve la lista de los nietos de abuelo."""
    consulta = urllib.parse.urlencode({'abuelo': abuelo})
    _, cuerpo = _pedir(f'{base}/nietos?{consulta}')
    return cuerpo['nietos']
```

Para el cliente de Python, el servicio es HTTP y JSON: no importa Janus ni
necesita SWI-Prolog. El servicio podría reescribirse en otro lenguaje sin que
el cliente cambie.

## 30.6 Probar un servidor

Las pruebas de un servicio hacen pedidos de verdad, a un servidor que
funciona. `servidor.plt` lo arranca una vez para toda la unidad, en un puerto
libre, y lo detiene al terminar:

<!-- ejemplo: capitulo-30/servidor.plt fragmento: :- dynamic puerto_de_prueba/1. .. detener(Puerto). -->
```prolog
:- dynamic puerto_de_prueba/1.

%!  arrancar_para_pruebas is det.
%
%   Arranca el servidor en un puerto libre y lo recuerda.
arrancar_para_pruebas :-
    iniciar(Puerto),
    assertz(puerto_de_prueba(Puerto)).

%!  parar_despues_de_pruebas is det.
%
%   Detiene el servidor de las pruebas y olvida su puerto.
parar_despues_de_pruebas :-
    retract(puerto_de_prueba(Puerto)),
    detener(Puerto).
```

```prolog
:- begin_tests(servidor, [ setup(arrancar_para_pruebas),
                           cleanup(parar_despues_de_pruebas) ]).

test(persona_inexistente, true(C == 404)) :-
    obtener('/personas/zoe', C, _).
```

Un puerto fijo, como 8080, haría fallar las pruebas cuando otro programa lo
usa, o cuando dos baterías corren a la vez; un puerto libre, elegido por el
sistema, no. Las pruebas del cliente de Python arrancan el servidor como
programa, con `swipl -q servidor.pl`, y leen el puerto de la primera línea
que escribe:

<!-- ejemplo: capitulo-30/test_cliente.py fragmento: @pytest.fixture .. proceso.wait() -->
```python
@pytest.fixture(scope='module')
def base():
    """Arranca el servidor de Prolog y devuelve su dirección base."""
    swipl = shutil.which('swipl')
    assert swipl is not None, 'swipl no está en el PATH'
    proceso = subprocess.Popen(  # noqa: S603
        [swipl, '-q', 'servidor.pl'], cwd=AQUI, stdout=subprocess.PIPE, text=True
    )
    try:
        linea = proceso.stdout.readline()
        puerto = re.search(r'localhost:(\d+)', linea).group(1)
        # 127.0.0.1 y no localhost: en Windows, localhost prueba primero IPv6, y
        # cada pedido espera antes de volver a IPv4.
        yield f'http://127.0.0.1:{puerto}'
    finally:
        proceso.kill()
        proceso.wait()
```

En Windows, `localhost` se resuelve primero como dirección IPv6, y el
servidor, que escucha en IPv4, no responde por ahí: cada pedido espera unos
segundos antes de probar IPv4. `127.0.0.1` es la dirección IPv4 directa, y
las pruebas la usan. Las de Prolog corren con `make test`, y también en la
integración continua del curso; las de Python, con `make appendix`.

!!! example "Patrón 41 — Servidor bajo prueba"
    **Problema.** Las pruebas de un servicio tienen que ejercitar las rutas,
    los códigos y el JSON de verdad, sin depender de un servidor que alguien
    arrancó a mano ni de un puerto que puede estar ocupado.

    **Versión ingenua.** Probar solo los predicados del núcleo, o arrancar el
    servidor a mano en el puerto 8080 antes de ejecutar las pruebas.

    **Patrón.** La unidad de pruebas arranca el servidor en su `setup`, en un
    puerto libre de `localhost` —`port(localhost:Puerto)` con `Puerto`
    libre—, recuerda el puerto y lo detiene en su `cleanup`. Cada prueba hace
    un pedido y verifica el código de estado y el cuerpo. Las pruebas que
    cambian datos los restauran, como en el [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md).

    **Cuándo no usarlo.** Para la lógica del núcleo: se prueba directamente,
    sin HTTP, que es más rápido y señala el error con más precisión.

!!! question "Actividad"
    Ejecutar `swipl servidor.pl --puerto=8080` en dos terminales a la vez.
    ¿Qué ocurre con el segundo servidor? Repetir sin la opción `--puerto`, y
    comparar los puertos que eligen los dos. ¿Qué pasaría con las pruebas si
    usaran siempre el puerto 8080?

## 30.7 CORS, registro y despliegue

Un navegador no permite que una página de un sitio llame a un servicio de
otro, salvo que el servicio lo autorice con el encabezado
`Access-Control-Allow-Origin`: es la política **CORS**. `library(http/http_cors)`
lo agrega: el ajuste `http:cors` dice qué orígenes se aceptan —`[*]`, todos—
y `cors_enable/0`, llamado en el manejador, agrega el encabezado a la
respuesta:

```prolog
:- use_module(library(http/http_cors)).
:- set_setting(http:cors, [*]).

hola(Pedido) :-
    cors_enable,
    …
```

`library(http/http_log)` registra cada pedido en el archivo `httpd.log`: la
hora, la ruta, el código de estado y el tiempo de respuesta. Basta cargarla.

Para dejar un servicio funcionando, lo más simple es ejecutarlo como programa,
`swipl servicio.pl --puerto=8080`, y que el sistema lo vuelva a arrancar si
termina. En Linux, `library(http/http_unix_daemon)` lo convierte en un
**demonio**: un proceso que se desprende de la terminal, cambia de usuario y
registra sus mensajes en el sistema. No existe en Windows. Lo habitual es
además ponerlo detrás de un servidor web como nginx, que atiende HTTPS y
reenvía los pedidos. El [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md) prepara el servicio en una imagen de Docker.

## 30.8 Pengines y SWISH, en una nota

**Pengines** —*Prolog engines*— es otra forma de ofrecer Prolog por la red: en
lugar de rutas con JSON, el cliente envía una consulta de Prolog y recibe sus
respuestas, una por una, como en el toplevel. SWISH está construido sobre
Pengines, y `library(pengines)` viene con SWI-Prolog. Conviene cuando los
clientes son programas que hablan Prolog; para clientes en cualquier
lenguaje, un servicio con rutas y JSON, como el de este capítulo, es más
simple de usar y de proteger, porque el servidor decide qué consultas se
pueden hacer.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C5 | cada error de las reglas llega al cliente como un código de estado —400, 404, 409—, con el motivo en el cuerpo; las pruebas verifican el código de cada caso |
    | C6 | los manejadores son el borde: leen el pedido, llaman al núcleo y responden; las reglas y el proyecto no cambian para ofrecerse por HTTP |
    | C7 | las pruebas arrancan el servidor en un puerto libre y lo llaman por HTTP; las de Prolog corren en la integración continua |

## 30.9 El proyecto: *Inscripciones* como servicio

*Inscripciones* recibe su décimo módulo, `api`, con seis rutas:

| Pedido | Respuesta |
|---|---|
| `GET /alumnos` | los alumnos |
| `GET /alumnos/{legajo}` | un alumno; 404 si no existe, 400 si el legajo no es un número |
| `GET /materias` | las materias, con la cantidad de inscriptos |
| `GET /materias/{codigo}/promedio` | el promedio de sus notas, o `null`; 404 si la materia no existe |
| `GET /ranking` | el ranking |
| `POST /inscripciones` | 201 si se acepta; 409 con el motivo si se rechaza; 404 si el alumno o la materia no existen |

Los manejadores usan los predicados de siempre —`inscribir/3`,
`promedio_de_materia/2`, `ranking/1`— y las conversiones a dicts del módulo
`puente` del [capítulo 29](../capitulo-29-prolog-desde-python/index.md): un dict es un objeto de JSON, lo reciba Python o un
cliente HTTP. La inscripción es la ruta más completa:

<!-- ejemplo: capitulo-30/inscripciones/api.pl predicado: inscripciones/1 resultado_json/3 consulta: iniciar_api(Puerto), detener_api(Puerto). -->
```prolog
%!  inscripciones(+Pedido) is det.
%
%   POST /inscripciones con {"legajo": L, "materia": M}: inscribe al
%   alumno. Responde 201 si la inscripción se acepta; 404 si el alumno o la
%   materia no existen; 409, con el motivo, si las reglas la rechazan.
inscripciones(Pedido) :-
    responder(( http_read_json_dict(Pedido, Datos, [value_string_as(atom)]),
                _{legajo: Legajo, materia: Materia} :< Datos,
                inscribir(Legajo, Materia, Respuesta),
                resultado_json(Respuesta, Resultado, Codigo),
                reply_json_dict(Resultado, [status(Codigo)]) )).

%!  resultado_json(+Respuesta, -Resultado:dict, -Codigo:integer) is det.
%
%   Resultado es el cuerpo de la respuesta de inscribir/3, y Codigo su
%   código de estado: 201 si se acepta, 404 si el alumno o la materia no
%   existen, 409 si las reglas la rechazan por otro motivo.
resultado_json(aceptada, _{aceptada: true}, 201).
resultado_json(rechazada(Motivo), _{aceptada: false, motivo: Texto}, Codigo) :-
    term_string(Motivo, Texto),
    (   memberchk(Motivo, [alumno_inexistente, materia_inexistente])
    ->  Codigo = 404
    ;   Codigo = 409
    ).
```

```text
$ swipl servicio.pl --puerto=8080
% Started server at http://localhost:8080/
Inscripciones en http://localhost:8080/
```

```text
$ curl -X POST -H "Content-Type: application/json" \
       -d '{"legajo": 105, "materia": "log"}' http://localhost:8080/inscripciones
{"aceptada":false,"motivo":"sin_vacantes"}
$ curl http://localhost:8080/materias/ssl/promedio
{"codigo":"ssl","promedio":null}
```

El resultado de `inscribir/3` se convierte en `resultado_json/3`, y no con
`inscribir_py/3` del módulo `puente`: esa conversión escribe los booleanos
como `@(true)`, para Janus, y JSON los escribe `true`. La batería del proyecto
suma las trece pruebas de `api.plt`, que arrancan el servicio en un puerto
libre, y la de `servicio.plt`, que ejecuta `servicio.pl` como programa y le
hace un pedido.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Agregar a `servidor.pl` la ruta `GET /hijos/{nombre}`, que
   responde la lista de los hijos de una persona.
2. **(1)** ¿Qué código responde el servidor a un `POST` a `/hola`? ¿Y a un
   `GET` a `/edades`? ¿Qué parte del programa decide cada uno?
3. ★ **(2)** Agregar la ruta `GET /mayores?edad=N`, con los nombres de las
   personas de más de `N` años; `N` es un entero obligatorio.
4. **(2)** Agregar la ruta `DELETE /personas/{nombre}`, que olvida la edad de
   una persona: 204 sin cuerpo si existía, 404 si no.
5. ★ **(2)** Escribir en `cliente.pl` el predicado `edades_remotas/3`: los
   pares `Persona-Edad` de una lista de personas, consultando el servidor, sin
   las que el servidor no conoce.
6. **(1)** Escribir en `cliente.py` la función `ficha_o_none(base, persona)`,
   que devuelve `None` en lugar de lanzar la excepción.
7. ★ **(2)** Escribir las pruebas de plunit de los códigos 405 del ejercicio 2,
   con el [Patrón 41](../patrones.md#41-servidor-bajo-prueba).
8. **(2)** Habilitar CORS en `/hola`, y escribir una prueba que verifique el
   encabezado `Access-Control-Allow-Origin`.
9. **(1)** Agregar la ruta `GET /hora`, con la fecha y la hora del servidor en
   el formato ISO 8601.
10. ★ **(2)** En el proyecto, agregar a `GET /ranking` el parámetro optativo
    `limite`, un entero positivo, que limita la cantidad de filas.
11. **(2)** En el proyecto, agregar la ruta `GET /alumnos/{legajo}/materias`:
    las materias del alumno, cada una con su estado.
12. **(2)** En el proyecto, agregar la ruta `DELETE
    /inscripciones/{legajo}/{materia}`, que da de baja: 204, o 404 si el
    alumno no la cursa.
13. **(3)** Escribir un cliente de Python para el servicio del proyecto, con
    las mismas funciones y excepciones que `inscripciones_py.py` del
    [capítulo 29](../capitulo-29-prolog-desde-python/index.md): `ranking()`, `materias()` e `inscribir(legajo, materia)`,
    que lanza `InscripcionRechazadaError`.
14. ★ **(3)** Ofrecer el Buscaminas como servicio: `POST /partidas` crea una
    partida y responde su número; `POST /partidas/{id}/descubrir` y
    `POST /partidas/{id}/marcar` aplican una jugada; `GET /partidas/{id}`
    responde el tablero y el estado. Escribir después, para el paquete de
    Python del [capítulo 29](../capitulo-29-prolog-desde-python/index.md), un adaptador que implemente su puerto con este
    servicio, de modo que la interfaz de texto juegue contra el servidor sin
    cambiar.

## Resumen

| | |
|---|---|
| `http_server/1`, `http_stop_server/2` | arrancar y detener el servidor; `port(localhost:P)` con `P` libre |
| `http_handler/3` | una ruta, con partes variables y un método |
| `http_parameters/2` | los parámetros de la dirección, con tipo y valor por omisión |
| `reply_json_dict/1,2`, `http_read_json_dict/3` | JSON de salida y de entrada, como dicts |
| códigos de estado | 200, 201, 400, 404, 405, 409, 500 |
| `http_open/3`, `http_post/4`, `library(uri)` | un cliente de Prolog |
| `urllib.request`, `requests` | un cliente de Python |
| `library(http/http_cors)`, `library(http/http_log)` | CORS y registro de pedidos |
| `library(http/http_unix_daemon)` | un demonio, solo en Linux |
| `library(pengines)` | consultas de Prolog por la red |
| `uri_query_components/2`, `uri_encoded/3` | la consulta de una dirección, con pares `Nombre=Valor`; un valor codificado para una parte de la dirección |
| `process_kill/1` | termina un proceso; en las pruebas |
| **Patrones 40, 41** | un endpoint JSON; servidor bajo prueba |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| El servicio como ejecutable y en una imagen de Docker | [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md) |
| El Buscaminas completo, en la terminal y como servicio | [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md) |
| Una interfaz web sobre el servicio | [capítulo 36](../capitulo-36-interfaces-de-usuario/index.md) |
