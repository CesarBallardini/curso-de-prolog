# Soluciones del capítulo 30 — Servicios web (REST)

El código de esta página está en `ejemplos/capitulo-30/`: `soluciones.pl`,
`soluciones_proyecto.pl`, `soluciones.py` y el directorio `buscaminas/`, con
sus pruebas. Las de Prolog arrancan el servidor en un puerto libre y lo
llaman por HTTP; las de Python lo ejecutan como programa.

## 1

<!-- ejemplo: capitulo-30/soluciones.pl fragmento: :- http_handler(root(hijos/Nombre) .. reply_json_dict(_{nombre: Nombre, hijos: Hijos}). consulta: iniciar(Puerto), detener(Puerto). -->
```prolog
:- http_handler(root(hijos/Nombre), hijos(Nombre), [method(get)]).

%!  hijos(+Nombre:atom, +Pedido) is det.
%
%   GET /hijos/Nombre: {"nombre": Nombre, "hijos": [...]}.
hijos(Nombre, _Pedido) :-
    findall(H, padre(Nombre, H), Hijos),
    reply_json_dict(_{nombre: Nombre, hijos: Hijos}).
```

`soluciones.pl` carga `servidor.pl` y declara la ruta nueva: las rutas de un
servidor se pueden declarar en cualquier archivo cargado, antes o después de
arrancarlo.

## 2

Los dos pedidos reciben 405, «método no permitido». No lo decide ningún
manejador: la opción `method(get)` de `/hola` y `method(post)` de `/edades`
hacen que el servidor rechace los demás métodos antes de llamarlo. Las pruebas
del ejercicio 7 lo verifican.

## 3

<!-- ejemplo: capitulo-30/soluciones.pl fragmento: :- http_handler(root(mayores) .. reply_json_dict(_{edad: Minima, personas: Personas}). consulta: iniciar(Puerto), detener(Puerto). -->
```prolog
:- http_handler(root(mayores), mayores, [method(get)]).

%!  mayores(+Pedido) is det.
%
%   GET /mayores?edad=N: las personas de más de N años. Sin el parámetro, o
%   con uno que no es un entero, el servidor responde 400.
mayores(Pedido) :-
    http_parameters(Pedido, [edad(Minima, [integer])]),
    findall(P, ( edad(P, Anios), Anios > Minima ), Personas),
    reply_json_dict(_{edad: Minima, personas: Personas}).
```

El parámetro no tiene `default`, y es obligatorio: sin él, o con un texto que
no es un entero, `http_parameters/2` responde 400 sin llamar al resto del
manejador. `/mayores?edad=40` responde `["juan", "ana"]`.

## 4

<!-- ejemplo: capitulo-30/soluciones.pl fragmento: :- http_delete_handler(id(persona)). .. [methods([get, delete]), id(persona)]). -->
```prolog
:- http_delete_handler(id(persona)).
:- http_handler(root(personas/Nombre), persona_u_olvido(Nombre),
                [methods([get, delete]), id(persona)]).
```

<!-- ejemplo: capitulo-30/soluciones.pl predicado: persona_u_olvido/2 olvidar/1 -->
```prolog
%!  persona_u_olvido(+Nombre:atom, +Pedido) is det.
%
%   GET /personas/Nombre, como persona/2; DELETE /personas/Nombre olvida la
%   edad de la persona y responde 204, sin cuerpo, o 404 si no la conocía.
persona_u_olvido(Nombre, Pedido) :-
    memberchk(method(Metodo), Pedido),
    (   Metodo == delete
    ->  responder(olvidar(Nombre))
    ;   persona(Nombre, Pedido)
    ).

%!  olvidar(+Nombre:atom) is det.
%
%   Olvida la edad de Nombre y responde 204.
%
%   @error existence_error(persona, Nombre) si no se conoce.
olvidar(Nombre) :-
    (   retract(edad(Nombre, _))
    ->  throw(http_reply(no_content))
    ;   existence_error(persona, Nombre)
    ).
```

La ruta `/personas/{nombre}` ya existe, con el método `GET`. Declarar otra
ruta con el mismo comienzo no la reemplaza: en SWI-Prolog 9.2.9, dos rutas con
partes variables que empiezan igual comparten las opciones de la última que se
declaró. Por eso `servidor.pl` le da a la ruta un identificador,
`id(persona)`, y la solución la borra con `http_delete_handler/1` antes de
declarar la nueva, que atiende los dos métodos y elige por el método del
pedido. `throw(http_reply(no_content))` responde 204, sin cuerpo.

## 5

<!-- ejemplo: capitulo-30/soluciones.pl predicado: edades_remotas/3 edad_remota/3 consulta: iniciar(Puerto), detener(Puerto). -->
```prolog
%!  edades_remotas(+Base:atom, +Personas:list(atom), -Pares:list(pair))
%!      is det.
%
%   Pares son los pares Persona-Edad de las Personas que están en el servidor
%   de Base, en el mismo orden.
edades_remotas(Base, Personas, Pares) :-
    convlist(edad_remota(Base), Personas, Pares).

%!  edad_remota(+Base:atom, +Persona:atom, -Par:pair) is semidet.
%
%   Par es Persona-Edad según el servidor de Base. Falla si no la conoce.
edad_remota(Base, Persona, Persona-Edad) :-
    ficha_remota(Base, Persona, Ficha),
    get_dict(edad, Ficha, Edad).
```

`convlist/3` aplica `edad_remota/3` a cada persona y descarta aquellas para
las que falla: las que el servidor no conoce, porque `ficha_remota/3` falla
con el código 404. Con `[ana, zoe, luis]`, el resultado es `[ana-41,
luis-12]`.

## 6

<!-- ejemplo: capitulo-30/soluciones.py fragmento: def ficha_o_none .. return None -->
```python
def ficha_o_none(base, persona):
    """Devuelve la ficha de persona, o None si el servidor no la conoce."""
    try:
        return cliente.ficha(base, persona)
    except cliente.PersonaDesconocidaError:
        return None
```

## 7

```prolog
test(post_a_hola, true(C == 405)) :-
    pedir(post, '/hola', C, _).

test(get_a_edades, true(C == 405)) :-
    pedir(get, '/edades', C, _).
```

`pedir/4`, en `soluciones.plt`, hace el pedido con el método que recibe, con
la opción `method(M)` de `http_open/3`, al servidor que la unidad arrancó en
su `setup`.

## 8

<!-- ejemplo: capitulo-30/soluciones.pl fragmento: :- set_setting(http:cors, [*]). .. hola(Pedido). -->
```prolog
:- set_setting(http:cors, [*]).
:- http_handler(root(hola), hola_con_cors, [method(get)]).

%!  hola_con_cors(+Pedido) is det.
%
%   GET /hola, como hola/1, con el encabezado de CORS que permite llamarla
%   desde páginas de cualquier origen.
hola_con_cors(Pedido) :-
    cors_enable,
    hola(Pedido).
```

```prolog
test(cors, true(Origen == '*')) :-
    base(Base),
    atom_concat(Base, '/hola', Url),
    setup_call_cleanup(
        http_open(Url, Stream,
                  [ header(access_control_allow_origin, Origen),
                    request_header('Origin'='http://ejemplo.org') ]),
        read_string(Stream, _, _),
        close(Stream)).
```

La ruta `/hola` no tiene partes variables, y declararla otra vez la
reemplaza. La opción `header/2` de `http_open/3` nombra el encabezado en
minúsculas y con guiones bajos: `access_control_allow_origin`.

## 9

<!-- ejemplo: capitulo-30/soluciones.pl predicado: hora/1 consulta: iniciar(Puerto), detener(Puerto). -->
```prolog
%!  hora(+Pedido) is det.
%
%   GET /hora: {"hora": Texto}, la fecha y la hora del servidor en el
%   formato ISO 8601, como "2026-09-25T14:03:07-03:00".
hora(_Pedido) :-
    get_time(Ahora),
    format_time(string(Texto), '%FT%T%:z', Ahora),
    reply_json_dict(_{hora: Texto}).
```

`%FT%T%:z` es el formato de ISO 8601: la fecha, la hora y la diferencia con
la hora universal. La prueba no compara con una hora fija, que cambia en cada
ejecución: verifica que `parse_time/3` lee la respuesta como ISO 8601.

## 10

<!-- ejemplo: capitulo-30/soluciones_proyecto.pl predicado: ranking_limitado/1 consulta: iniciar_api(Puerto), detener_api(Puerto). -->
```prolog
%!  ranking_limitado(+Pedido) is det.
%
%   GET /ranking?limite=N: las N primeras filas del ranking; sin el
%   parámetro, todas. Un límite que no es un entero entre 1 y 1000 responde
%   400. Sin el parámetro, Limite queda libre: var/1, que el capítulo 32
%   presenta, lo distingue.
ranking_limitado(Pedido) :-
    http_parameters(Pedido,
                    [limite(Limite, [between(1, 1000), optional(true)])]),
    ranking_py(Filas),
    (   var(Limite)
    ->  Elegidas = Filas
    ;   length(Filas, Total),
        Cantidad is min(Limite, Total),
        length(Elegidas, Cantidad),
        append(Elegidas, _, Filas)
    ),
    reply_json_dict(Elegidas).
```

`http_parameters/2` no conoce el tipo `positive_integer`: con él, el límite
llega como el átomo `'2'`, y la cuenta produce un error 500. `between(1,
1000)` convierte el texto en un entero y verifica el rango, y un límite fuera
de él responde 400. `optional(true)` deja la variable libre cuando el
parámetro falta.

## 11

<!-- ejemplo: capitulo-30/soluciones_proyecto.pl predicado: materias_del_alumno/2 materia_json/2 consulta: iniciar_api(Puerto), detener_api(Puerto). -->
```prolog
%!  materias_del_alumno(+Texto:atom, +Pedido) is det.
%
%   GET /alumnos/L/materias: las materias del alumno L, cada una con su nota
%   o con el estado cursando; 404 si el alumno no existe.
materias_del_alumno(Texto, _Pedido) :-
    (   atom_number(Texto, Legajo),
        alumno(Legajo, _, _, _)
    ->  indice_por_alumno(Indice),
        materias_de(Indice, Legajo, Pares),
        maplist(materia_json, Pares, Materias),
        reply_json_dict(Materias)
    ;   reply_json_dict(_{error: "alumno inexistente"}, [status(404)])
    ).

%!  materia_json(+Par:pair, -Materia:dict) is det.
%
%   Materia es el dict del par Materia-Estado.
materia_json(Materia-nota(N), _{materia: Materia, nota: N}).
materia_json(Materia-cursando, _{materia: Materia, estado: cursando}).
```

`materias_de/3`, del [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md), da los pares `Materia-Estado` del
alumno, y `materia_json/2` convierte cada estado en un dict: con la clave
`nota` si tiene nota, con `estado: cursando` si no.

## 12

<!-- ejemplo: capitulo-30/soluciones_proyecto.pl predicado: baja/3 consulta: iniciar_api(Puerto), detener_api(Puerto). -->
```prolog
%!  baja(+Texto:atom, +Materia:atom, +Pedido) is det.
%
%   DELETE /inscripciones/L/M: da de baja al alumno L en la materia M y
%   responde 204, sin cuerpo; 404 si no la cursa.
baja(Texto, Materia, _Pedido) :-
    (   atom_number(Texto, Legajo),
        dar_de_baja(Legajo, Materia)
    ->  throw(http_reply(no_content))
    ;   reply_json_dict(_{error: "no la cursa"}, [status(404)])
    ).
```

`dar_de_baja/2` falla si el alumno no cursa la materia, y esa falla se
convierte en el 404. Una baja que se cumple responde 204, como el `DELETE`
del ejercicio 4.

## 13

<!-- ejemplo: capitulo-30/soluciones.py fragmento: class InscripcionRechazadaError .. raise InscripcionRechazadaError(legajo, materia, cuerpo['motivo']) -->
```python
class InscripcionRechazadaError(Exception):
    """Las reglas no permiten la inscripción; motivo dice por qué."""

    def __init__(self, legajo, materia, motivo):
        """Guarda el pedido y el motivo del rechazo."""
        super().__init__(f'{legajo} en {materia}: {motivo}')
        self.motivo = motivo


class DatoInvalidoError(ValueError):
    """Un dato no tiene el tipo que esperan las reglas: el servicio respondió 400."""


class Inscripciones:
    """Un cliente del servicio de Inscripciones, en la dirección base."""

    def __init__(self, base):
        """Guarda la dirección base del servicio, como 'http://127.0.0.1:8080'."""
        self.base = base

    def _pedir(self, ruta, datos=None):
        """Hace el pedido; devuelve el código de estado y el cuerpo leído como JSON."""
        cuerpo = None if datos is None else json.dumps(datos).encode('utf-8')
        pedido = urllib.request.Request(  # noqa: S310
            f'{self.base}{ruta}', data=cuerpo, headers={'Content-Type': 'application/json'}
        )
        try:
            with urllib.request.urlopen(pedido) as respuesta:  # noqa: S310
                return respuesta.status, json.load(respuesta)
        except urllib.error.HTTPError as error:
            return error.code, json.load(error)

    def ranking(self):
        """Devuelve el ranking: una lista de diccionarios con legajo, nombre y promedio."""
        return self._pedir('/ranking')[1]

    def materias(self):
        """Devuelve las materias: diccionarios con codigo, nombre, anio e inscriptos."""
        return self._pedir('/materias')[1]

    def inscribir(self, legajo, materia):
        """Inscribe al alumno legajo en materia, o lanza una de las dos excepciones."""
        codigo, cuerpo = self._pedir('/inscripciones', {'legajo': legajo, 'materia': materia})
        if codigo == 400:
            raise DatoInvalidoError(cuerpo['error'])
        if codigo != 201:
            raise InscripcionRechazadaError(legajo, materia, cuerpo['motivo'])
```

Las excepciones y los nombres de las funciones son los de
`inscripciones_py.py`, del [capítulo 29](../capitulo-29-prolog-desde-python/index.md): un programa de Python que usaba
las reglas con Janus puede usarlas a través del servicio cambiando solo la
creación del cliente. La diferencia está en la frontera: aquí los códigos de
estado —400, 404, 409— se convierten en las excepciones, en lugar de los
errores de Prolog.

## 14

El servicio ofrece por HTTP las reglas de `buscaminas.pl`, las del [capítulo 29](../capitulo-29-prolog-desde-python/index.md),
sin cambiarlas. Las cuatro rutas empiezan con `/partidas`, y por lo que
muestra el ejercicio 4 no pueden declararse por separado: un solo manejador,
con la opción `prefix`, recibe todas y elige por el método y por el resto de
la dirección:

<!-- ejemplo: capitulo-30/buscaminas/servicio_buscaminas.pl predicado: partidas/1 ruta/3 consulta: iniciar_buscaminas(Puerto), detener_buscaminas(Puerto). -->
```prolog
%!  partidas(+Pedido) is det.
%
%   Atiende todas las rutas que empiezan con /partidas: separa el resto de
%   la dirección en partes y elige la ruta por el método y las partes.
partidas(Pedido) :-
    memberchk(method(Metodo), Pedido),
    (   memberchk(path_info(Resto), Pedido)
    ->  true
    ;   Resto = ''
    ),
    split_string(Resto, "/", "", Partes0),
    exclude(==(""), Partes0, Partes),
    ruta(Metodo, Partes, Pedido).

%!  ruta(+Metodo:atom, +Partes:list(string), +Pedido) is det.
%
%   Atiende el pedido de Metodo a /partidas seguido de Partes; 404 si no
%   es ninguna de las rutas del servicio.
ruta(post, [], Pedido) :-
    !,
    crear(Pedido).
ruta(get, [Id], Pedido) :-
    !,
    consultar(Id, Pedido).
ruta(post, [Id, Accion], Pedido) :-
    !,
    jugar(Id, Accion, Pedido).
ruta(_, _, _) :-
    reply_json_dict(_{error: "ruta inexistente"}, [status(404)]).
```

Cada partida se guarda con un número en `partida/2`, y cada jugada la
reemplaza por la siguiente:

<!-- ejemplo: capitulo-30/buscaminas/servicio_buscaminas.pl predicado: jugar/3 jugada/7 consulta: iniciar_buscaminas(Puerto), detener_buscaminas(Puerto). -->
```prolog
%!  jugar(+Texto:string, +Accion:string, +Pedido) is det.
%
%   POST /partidas/Id/descubrir o /marcar, con la fila y la columna: aplica
%   la jugada y responde el estado y el tablero. 400 si la celda está fuera
%   del tablero o la partida terminó; 404 si no existe la partida o la
%   acción.
jugar(Texto, Nombre, Pedido) :-
    responder(( accion(Nombre, Accion),
                http_read_json_dict(Pedido, Datos),
                _{fila: F, columna: C} :< Datos,
                with_mutex(partidas,
                           jugada(Texto, Accion, F, C, Id, Juego, Estado)),
                respuesta(Id, Juego, Estado, Respuesta),
                reply_json_dict(Respuesta) )).

%!  jugada(+Texto, +Accion, +F, +C, -Id, -Juego, -Estado) is det.
%
%   Aplica la jugada a la partida de número Texto y la guarda.
%
%   @error domain_error(partida_en_curso, Id) si la partida terminó.
%   @error domain_error(celda_del_tablero, F-C) si la celda no existe.
jugada(Texto, Accion, F, C, Id, Juego, Estado) :-
    partida_de(Texto, Id, estado(Juego0, Estado0)),
    (   Estado0 == sigue
    ->  true
    ;   domain_error(partida_en_curso, Id)
    ),
    jugar_py(Juego0, Accion, F, C, prolog(Juego), Estado),
    (   Estado == fuera
    ->  domain_error(celda_del_tablero, F-C)
    ;   retract(partida(Id, _)),
        assertz(partida(Id, estado(Juego, Estado)))
    ).
```

`with_mutex/2` hace que dos pedidos a la vez no modifiquen las partidas al
mismo tiempo: el servidor atiende cada pedido en un hilo propio. El
[capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md) presenta los hilos, `with_mutex/2` y lo que pasa sin él.

Del lado de Python, el paquete del [capítulo 29](../capitulo-29-prolog-desde-python/index.md) recibe un adaptador más, que
implementa el mismo puerto con pedidos HTTP:

<!-- ejemplo: capitulo-30/buscaminas/adaptador_http.py fragmento: class PartidaEnServicio .. return PartidaEnServicio(self.base, cuerpo) -->
```python
class PartidaEnServicio:
    """Una partida que vive en el servicio; cumple dominio.Partida."""

    def __init__(self, base, respuesta):
        """Toma la partida de la respuesta de POST /partidas."""
        self._url = f'{base}/partidas/{respuesta["id"]}'
        self.filas = respuesta['filas']
        self.columnas = respuesta['columnas']
        self.estado = respuesta['estado']
        self._tablero = respuesta['tablero']

    def _jugar(self, accion, fila, columna):
        """Envía la jugada; una respuesta que no es 200 es un error."""
        codigo, cuerpo = _pedir(f'{self._url}/{accion}', {'fila': fila, 'columna': columna})
        if codigo != 200:
            raise ValueError(cuerpo['error'])
        self.estado = cuerpo['estado']
        self._tablero = cuerpo['tablero']

    def descubrir(self, fila, columna):
        """Descubre la celda."""
        self._jugar('descubrir', fila, columna)

    def marcar(self, fila, columna):
        """Marca la celda, o le quita la marca."""
        self._jugar('marcar', fila, columna)

    def tablero(self, mostrar_minas):
        """Devuelve las filas del tablero; el servicio muestra las minas al terminar."""
        return self._tablero


class ReglasEnServicio:
    """La fábrica de partidas del servicio, en la dirección base; cumple dominio.Reglas."""

    def __init__(self, base):
        """Guarda la dirección base del servicio, como 'http://127.0.0.1:8080'."""
        self.base = base

    def partida_al_azar(self, filas, columnas, minas, semilla):
        """Crea una partida nueva en el servicio."""
        datos = {'filas': filas, 'columnas': columnas, 'minas': minas, 'semilla': semilla}
        codigo, cuerpo = _pedir(f'{self.base}/partidas', datos)
        if codigo != 201:
            raise ValueError(cuerpo['error'])
        return PartidaEnServicio(self.base, cuerpo)
```

El dominio, la aplicación y la interfaz de texto no cambian. La raíz de
composición elige el adaptador, e importa solo el que elige:

<!-- ejemplo: capitulo-30/buscaminas/__main__.py fragmento: def reglas_elegidas .. return ReglasEnProlog() -->
```python
def reglas_elegidas(servidor):
    """Devuelve la fábrica de partidas: la del servicio, o la de Prolog con Janus."""
    if servidor:
        from buscaminas.adaptador_http import ReglasEnServicio  # noqa: PLC0415

        return ReglasEnServicio(servidor)
    from buscaminas.adaptador_prolog import ReglasEnProlog  # noqa: PLC0415

    return ReglasEnProlog()
```

```text
$ swipl buscaminas/servicio_buscaminas.pl --puerto=8080
% Started server at http://localhost:8080/
Buscaminas en http://localhost:8080/
```

```text
$ python -m buscaminas 9 9 10 --servidor http://127.0.0.1:8080
```

Jugar contra el servicio no necesita Janus ni SWI-Prolog del lado de Python:
las reglas se ejecutan en el servidor. Las pruebas de `test_buscaminas.py`
juegan con la interfaz de texto contra el servicio, y la prueba de las
dependencias verifica que el adaptador nuevo tampoco apunta hacia afuera: no
importa la aplicación ni la interfaz.
