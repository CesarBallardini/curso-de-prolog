:- encoding(utf8).

% Capítulo 87 - Las preguntas como servicio: una página y JSON.
%
% Un servidor HTTP con hilos, como el del capítulo 37, atiende dos rutas:
%
%     GET /pregunta?texto=…   la respuesta en JSON: el texto, las líneas
%                             de la respuesta y la sentencia SQL
%     GET /?texto=…           una página con un formulario y la respuesta,
%                             armada con html//1 como las del capítulo 36
%
% El trabajo de cada pedido es responder/3, que solo lee la base: los
% pedidos que llegan a la vez se atienden en paralelo sin un mutex. Las
% tablas de lemas.pl y de evaluar.pl son, como todas las tablas de
% SWI-Prolog, privadas de cada hilo: cada trabajador analiza una palabra
% la primera vez que la recibe. respuesta_json/2 y cuerpo_pagina/2 son
% puros; los manejadores solo leen el pedido y responden.
%
% solo-local: SWISH no permite abrir puertos ni crear hilos.
%
%?- iniciar(P, 3), preguntar_servicio(P, "¿Quién cursa lógica?", D), detener(P).

:- module(servicio,
          [ iniciar/2,
            detener/1,
            respuesta_json/2,
            cuerpo_pagina/2,
            preguntar_servicio/3,
            muchas_preguntas/3
          ]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_open)).
:- use_module(library(http/json)).
:- use_module(library(uri)).
:- use_module(preguntas).
:- use_module(gramatica).
:- use_module(sql, [sql/2]).

:- http_handler(root(pregunta), pagina_json, [method(get)]).
:- http_handler(root(.), pagina_html, [method(get)]).

%!  iniciar(?Puerto:integer, +Trabajadores:integer) is det.
%
%   Arranca el servidor en Puerto de la máquina local, con Trabajadores
%   hilos. Con Puerto libre, elige uno.
iniciar(Puerto, Trabajadores) :-
    http_server(http_dispatch,
                [ port(localhost:Puerto),
                  workers(Trabajadores) ]).

%!  detener(+Puerto:integer) is det.
%
%   Detiene el servidor de Puerto.
detener(Puerto) :-
    http_stop_server(Puerto, []).

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

%!  lineas_servicio(+Puerto:integer, +Texto, -Lineas:list) is det.
%
%   Lineas son las líneas de la respuesta del servidor a Texto.
lineas_servicio(Puerto, Texto, Lineas) :-
    preguntar_servicio(Puerto, Texto, Dict),
    Lineas = Dict.lineas.
