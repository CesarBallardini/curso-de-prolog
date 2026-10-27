:- encoding(utf8).

% Pruebas del módulo servicio: el servicio arranca en un puerto libre al
% empezar la unidad.

:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/json)).

:- dynamic puerto_de_prueba/1.

%!  arrancar_para_pruebas is det.
%
%   Arranca el servicio en un puerto libre y lo recuerda.
arrancar_para_pruebas :-
    iniciar_servicio(Puerto, local),
    assertz(puerto_de_prueba(Puerto)).

%!  parar_despues_de_pruebas is det.
%
%   Detiene el servicio de las pruebas.
parar_despues_de_pruebas :-
    retract(puerto_de_prueba(Puerto)),
    detener_servicio(Puerto).

%!  url(+Ruta:atom, -Url:atom) is det.
%
%   Url es la dirección de Ruta en el servicio de las pruebas.
url(Ruta, Url) :-
    puerto_de_prueba(Puerto),
    format(atom(Url), "http://127.0.0.1:~w~w", [Puerto, Ruta]).

%!  enviar(+Ruta:atom, +Cuerpo:dict, -Codigo:integer, -Respuesta:dict) is det.
%
%   Hace POST a Ruta con Cuerpo como JSON.
enviar(Ruta, Cuerpo, Codigo, Respuesta) :-
    url(Ruta, Url),
    http_post(Url, json(Cuerpo), Respuesta,
              [ status_code(Codigo), json_object(dict),
                request_header('Accept'='application/json') ]).

%!  obtener(+Ruta:atom, -Codigo:integer, -Respuesta:dict) is det.
%
%   Hace GET a Ruta y lee la respuesta como JSON.
obtener(Ruta, Codigo, Respuesta) :-
    url(Ruta, Url),
    setup_call_cleanup(
        http_open(Url, Stream, [ status_code(Codigo),
                                 request_header('Accept'='application/json') ]),
        json_read_dict(Stream, Respuesta),
        close(Stream)).

%!  partida_nueva(+Datos:dict, -Ruta:atom) is det.
%
%   Crea una partida con Datos y da su ruta.
partida_nueva(Datos, Ruta) :-
    enviar('/partidas', Datos, 201, R),
    get_dict(id, R, Id),
    format(atom(Ruta), "/partidas/~w", [Id]).

:- begin_tests(servicio, [ setup(arrancar_para_pruebas),
                           cleanup(parar_despues_de_pruebas) ]).

% Con la semilla 42, las minas de un 5 x 5 con 4 son 2-3, 3-2, 3-4 y 5-1.
test(perder, true(E-T == "perdio"-["#####", "##*##", "#*#*#", "#####",
                                   "*####"])) :-
    partida_nueva(_{filas: 5, columnas: 5, minas: 4, semilla: 42}, Ruta),
    atom_concat(Ruta, '/descubrir', Descubrir),
    enviar(Descubrir, _{fila: 2, columna: 3}, 200, R),
    get_dict(estado, R, E),
    get_dict(tablero, R, T).

test(consultar, true(C-N == 200-4)) :-
    partida_nueva(_{filas: 5, columnas: 5, minas: 4, semilla: 42}, Ruta),
    obtener(Ruta, C, R),
    get_dict(minas_restantes, R, N).

test(sin_sugerencia, true(C == 404)) :-
    partida_nueva(_{filas: 5, columnas: 5, minas: 4, semilla: 42}, Ruta),
    atom_concat(Ruta, '/sugerencia', Sugerencia),
    obtener(Sugerencia, C, _).

test(accion_inexistente, true(C == 404)) :-
    partida_nueva(_{filas: 5, columnas: 5, minas: 4, semilla: 42}, Ruta),
    atom_concat(Ruta, '/saltar', Saltar),
    enviar(Saltar, _{fila: 1, columna: 1}, C, _).

test(fuera_del_tablero, true(C == 400)) :-
    partida_nueva(_{filas: 5, columnas: 5, minas: 4, semilla: 42}, Ruta),
    atom_concat(Ruta, '/descubrir', Descubrir),
    enviar(Descubrir, _{fila: 9, columna: 9}, C, _).

test(partida_inexistente, true(C == 404)) :-
    obtener('/partidas/999', C, _).

test(demasiadas_minas, true(C == 400)) :-
    enviar('/partidas', _{filas: 2, columnas: 2, minas: 4, semilla: 1}, C, _).

:- end_tests(servicio).
