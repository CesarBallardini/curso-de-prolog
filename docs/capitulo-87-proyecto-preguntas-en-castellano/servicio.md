# Las preguntas como servicio

Esta página contiene la segunda parte de la
[sección 87.8](index.md#878-version-5-el-programa-el-bucle-y-el-servicio)
del [capítulo 87](index.md): el programa de preguntas detrás de un
servidor HTTP con hilos, con una ruta que responde en JSON y una página
web con un formulario. El código está en `servicio.pl`, en
`ejemplos/capitulo-87/`, con sus pruebas; abre un puerto y crea hilos, y
no corre en SWISH.

## Las preguntas como servicio

El [capítulo 36](../capitulo-36-interfaces-de-usuario/index.md#361-el-nucleo-y-las-interfaces)
separó el núcleo de un programa de sus interfaces: la pantalla, la
ventana y la página web llaman a los mismos predicados puros, y solo
cambia cómo se leen los datos y cómo se muestra el resultado. El núcleo de
este capítulo es `responder/3`, y `preguntar/1` ya es una interfaz, la del
bucle de la terminal. El servidor agrega dos más:

```text
GET /pregunta?texto=…   la respuesta en JSON: el texto, las líneas
                        de la respuesta y la sentencia SQL
GET /?texto=…           una página con un formulario y la respuesta
```

`respuesta_json/2` arma la respuesta en JSON con las líneas que escribe
`preguntar/1`, capturadas con `with_output_to/2`, y la sentencia de
`sql/2`, o `null` si la pregunta no tiene:

<!-- ejemplo: capitulo-87/servicio.pl predicado: respuesta_json/2 lineas/2 -->
```prolog
%!  respuesta_json(+Texto, -Dict) is det.
%
%   Dict tiene la pregunta Texto, las líneas que preguntar/1 escribe y la
%   sentencia SQL de la pregunta, o null si no tiene.
respuesta_json(Texto, _{pregunta: Texto, lineas: Lineas, sql: SQL}) :-
    lineas(Texto, Lineas),
    (   analizar(Texto, Forma),
        sql(Forma, SQL0)
    ->  SQL = SQL0
    ;   SQL = null
    ).

%!  lineas(+Texto, -Lineas:list(string)) is det.
%
%   Lineas son las líneas que preguntar/1 escribe para Texto.
lineas(Texto, Lineas) :-
    with_output_to(string(Salida), preguntar(Texto)),
    split_string(Salida, "\n", "", Partes),
    exclude(==(""), Partes, Lineas).
```

`cuerpo_pagina/2` arma la página como un término de `html//1`, igual que
las páginas de *Inscripciones* de la
[sección 36.6](../capitulo-36-interfaces-de-usuario/index.md#366-paginas-web-sobre-los-servicios):
un formulario con un campo de texto que envía la pregunta a la misma
ruta, y, si el pedido trae una pregunta, la respuesta y la sentencia SQL
en dos bloques `pre`. Los dos predicados son puros, y los manejadores solo
leen el parámetro del pedido y responden:

<!-- ejemplo: capitulo-87/servicio.pl predicado: pagina_json/1 pagina_html/1 cuerpo_pagina/2 -->
```prolog
%!  pagina_json(+Pedido) is det.
%
%   GET /pregunta?texto=…: la respuesta en JSON.
pagina_json(Pedido) :-
    http_parameters(Pedido, [texto(Texto, [string])]),
    respuesta_json(Texto, Dict),
    reply_json_dict(Dict).

%!  pagina_html(+Pedido) is det.
%
%   GET /: el formulario, y la respuesta si el pedido trae un texto.
pagina_html(Pedido) :-
    http_parameters(Pedido, [texto(Texto, [string, default("")])]),
    cuerpo_pagina(Texto, Cuerpo),
    reply_html_page(title('Preguntas sobre Inscripciones'), Cuerpo).

%!  cuerpo_pagina(+Texto, -Cuerpo) is det.
%
%   Cuerpo es la página para la pregunta Texto, un término de html//1:
%   el formulario y, si Texto no es "", la respuesta y la sentencia SQL.
cuerpo_pagina(Texto, [ h1('Preguntas sobre Inscripciones'),
                       form([action('/'), method(get)],
                            [ input([name(texto), value(Texto), size(50)]),
                              input([type(submit), value('Preguntar')])
                            ])
                     | Respuesta ]) :-
    (   Texto == ""
    ->  Respuesta = []
    ;   respuesta_json(Texto, Dict),
        atomic_list_concat(Dict.lineas, '\n', Lineas),
        (   Dict.sql == null
        ->  Sql = []
        ;   Sql = [h2('SQL'), pre(Dict.sql)]
        ),
        Respuesta = [h2('Respuesta'), pre(Lineas)|Sql]
    ).
```

**Los hilos.** El servidor se inicia como el de la
[sección 37.6](../capitulo-37-concurrencia-y-paralelismo/index.md#376-los-hilos-del-servidor-http),
con `http_server/2` y la opción `workers(N)`: N hilos trabajadores
atienden los pedidos, varios a la vez. El trabajo de cada pedido solo lee
la base, de modo que no hace falta ningún mutex, a diferencia del
contador de visitas de aquella sección. Lo que sí cambia con los hilos son
las tablas. Como explica la página
[Tablas incrementales, hilos y costo](../capitulo-39-tabulacion/incremental.md#tablas-y-hilos)
del [capítulo 39](../capitulo-39-tabulacion/index.md), una tabla de
SWI-Prolog es privada del hilo que la llena, salvo que se declare
`as shared`. Cada trabajador analiza entonces una palabra la primera vez
que la recibe, aunque otro trabajador ya la haya analizado, y llena su
propia tabla de `pasos/3`. Con tres trabajadores, el análisis morfológico
de cada palabra se hace a lo sumo tres veces, y después ninguna.

`preguntar_servicio/3` es un cliente: codifica la pregunta en la
dirección con `uri_encoded/3`, porque lleva signos y tildes, y lee la
respuesta con `json_read_dict/3`. `muchas_preguntas/3` hace varias
preguntas a la vez, cada una desde un hilo cliente, con
`concurrent_maplist/3`:

<!-- ejemplo: capitulo-87/servicio.pl predicado: preguntar_servicio/3 muchas_preguntas/3 -->
```prolog
%!  preguntar_servicio(+Puerto:integer, +Texto, -Dict) is det.
%
%   Dict es la respuesta en JSON del servidor de Puerto a Texto. El texto
%   viaja en la dirección, codificado con uri_encoded/3.
preguntar_servicio(Puerto, Texto, Dict) :-
    uri_encoded(query_value, Texto, Codificado),
    format(atom(Url), "http://127.0.0.1:~w/pregunta?texto=~w",
           [Puerto, Codificado]),
    setup_call_cleanup(
        http_open(Url, Entrada, []),
        json_read_dict(Entrada, Dict, [value_string_as(string)]),
        close(Entrada)).

%!  muchas_preguntas(+Puerto:integer, +Textos:list, -Lineas:list) is det.
%
%   Hace las preguntas Textos al servidor de Puerto a la vez, desde varios
%   hilos clientes. Lineas tiene, en el orden de Textos, las líneas de
%   cada respuesta.
muchas_preguntas(Puerto, Textos, Lineas) :-
    concurrent_maplist(lineas_servicio(Puerto), Textos, Lineas).
```

```text
?- iniciar(P, 3), preguntar_servicio(P, "¿Ana aprobó lógica?", D), detener(P).
% Started server at http://localhost:52731/
P = 52731,
D = _{lineas:["Sí", "  inscripcion(101, log, 10), 10 >= 6"], pregunta:"¿Ana aprobó lógica?", sql:"SELECT EXISTS (SELECT 1 FROM inscripciones t1 WHERE t1.legajo = 101 AND t1.materia = 'log' AND t1.nota >= 6)"}.
```

El puerto lo elige el sistema, y cambia en cada ejecución. Las pruebas de
`servicio.plt` arrancan el servidor con tres trabajadores, le hacen las
dieciséis preguntas de `ejemplo/2` a la vez, y comparan cada respuesta
con la que `preguntar/1` escribe en el mismo proceso: el resultado no
depende de qué trabajador atiende cada pedido ni del orden en que
terminan.
