:- encoding(utf8).

% Pruebas de servidor.pl: el servidor arranca en un puerto libre al empezar
% la unidad y se detiene al terminar; cada prueba lo llama por HTTP.

:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/json)).

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

%!  url(+Ruta:atom, -Url:atom) is det.
%
%   Url es la dirección de Ruta en el servidor de las pruebas.
url(Ruta, Url) :-
    puerto_de_prueba(Puerto),
    format(atom(Url), "http://localhost:~w~w", [Puerto, Ruta]).

%!  obtener(+Ruta:atom, -Codigo:integer, -Respuesta:dict) is det.
%
%   Hace GET a Ruta; Codigo es el código de estado y Respuesta el JSON.
obtener(Ruta, Codigo, Respuesta) :-
    url(Ruta, Url),
    setup_call_cleanup(
        http_open(Url, Stream,
                  [ status_code(Codigo),
                    request_header('Accept'='application/json') ]),
        json_read_dict(Stream, Respuesta),
        close(Stream)).

%!  enviar(+Ruta:atom, +Cuerpo:dict, -Codigo:integer, -Respuesta:dict) is det.
%
%   Hace POST a Ruta con Cuerpo como JSON.
enviar(Ruta, Cuerpo, Codigo, Respuesta) :-
    url(Ruta, Url),
    http_post(Url, json(Cuerpo), Respuesta,
              [ status_code(Codigo), json_object(dict),
                request_header('Accept'='application/json') ]).

:- begin_tests(servidor, [ setup(arrancar_para_pruebas),
                           cleanup(parar_despues_de_pruebas) ]).

test(hola, true(C-S == 200-"Hola, ana")) :-
    obtener('/hola?nombre=ana', C, R),
    S = R.saludo.

test(persona, true(C-E-H == 200-41-["luis", "eva"])) :-
    obtener('/personas/ana', C, R),
    E = R.edad,
    H = R.hijos.

test(persona_inexistente, true(C == 404)) :-
    obtener('/personas/zoe', C, _).

test(nietos, true(C-N == 200-["luis", "eva"])) :-
    obtener('/nietos?abuelo=juan', C, R),
    N = R.nietos.

test(falta_un_parametro, true(C == 400)) :-
    obtener('/nietos', C, _).

test(cambiar_edad, [ cleanup(cambiar_edad(juan, 68)),
                     true(C-E == 201-69) ]) :-
    enviar('/edades', _{nombre: juan, edad: 69}, C, R),
    E = R.edad.

test(edad_negativa, true(C == 400)) :-
    enviar('/edades', _{nombre: juan, edad: -1}, C, _).

test(falta_un_campo, true(C == 400)) :-
    enviar('/edades', _{nombre: juan}, C, _).

test(edad_de_inexistente, true(C == 404)) :-
    enviar('/edades', _{nombre: zoe, edad: 3}, C, _).

test(ruta_inexistente, true(C == 404)) :-
    obtener('/nada', C, _).

:- end_tests(servidor).
