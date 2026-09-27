:- encoding(utf8).

% Capítulo 30 - Un cliente de Prolog para el servicio de servidor.pl.
%
% Cada predicado arma una dirección a partir de Base, como
% 'http://localhost:8080', hace el pedido con http_open/3 o http_post/4 y
% convierte la respuesta de JSON en un dict. Los valores de la dirección se
% codifican con library(uri): un nombre con espacios o con & no rompe la
% dirección.
%
% solo-local: SWISH no permite conexiones de red.
%
%?- direccion('http://localhost:8080', '/nietos', [abuelo=juan], Url).

:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(uri)).

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

%!  nietos_remotos(+Base:atom, +Abuelo:atom, -Nietos:list) is det.
%
%   Nietos son los nietos de Abuelo según el servidor de Base.
nietos_remotos(Base, Abuelo, Nietos) :-
    direccion(Base, '/nietos', [abuelo=Abuelo], Url),
    obtener_json(Url, 200, Respuesta),
    Nietos = Respuesta.nietos.

%!  cambiar_edad_remota(+Base:atom, +Persona:atom, +Anios:integer,
%!                      -Codigo:integer) is det.
%
%   Pide al servidor de Base que registre la edad de Persona. Codigo es el
%   código de estado de la respuesta: 201 si la aceptó.
cambiar_edad_remota(Base, Persona, Anios, Codigo) :-
    direccion(Base, '/edades', [], Url),
    http_post(Url, json(_{nombre: Persona, edad: Anios}), _,
              [ status_code(Codigo), json_object(dict),
                request_header('Accept'='application/json') ]).
