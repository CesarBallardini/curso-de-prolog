:- encoding(utf8).

% Pruebas de servicio_buscaminas.pl: el servicio arranca en un puerto libre
% al empezar la unidad; cada prueba crea su propia partida.

:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/json)).

:- dynamic puerto_de_prueba/1.

%!  arrancar_para_pruebas is det.
%
%   Arranca el servicio en un puerto libre y lo recuerda.
arrancar_para_pruebas :-
    iniciar_buscaminas(Puerto),
    assertz(puerto_de_prueba(Puerto)).

%!  parar_despues_de_pruebas is det.
%
%   Detiene el servicio de las pruebas.
parar_despues_de_pruebas :-
    retract(puerto_de_prueba(Puerto)),
    detener_buscaminas(Puerto).

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

%!  partida_nueva(-Ruta:atom) is det.
%
%   Crea una partida de 5 × 5 con 4 minas y la semilla 42, y da su ruta.
partida_nueva(Ruta) :-
    enviar('/partidas', _{filas: 5, columnas: 5, minas: 4, semilla: 42},
           201, R),
    get_dict(id, R, Id),
    format(atom(Ruta), "/partidas/~w", [Id]).

:- begin_tests(servicio_buscaminas, [ setup(arrancar_para_pruebas),
                                      cleanup(parar_despues_de_pruebas) ]).

test(crear, true(E-T == "sigue"-["#####", "#####", "#####", "#####",
                                  "#####"])) :-
    partida_nueva(Ruta),
    obtener(Ruta, 200, R),
    get_dict(estado, R, E),
    get_dict(tablero, R, T).

% Con la semilla 42, las minas son 2-3, 3-2, 3-4 y 5-1.
test(perder, true(E-T == "perdio"-["M####", "##*##", "#*#*#", "#####",
                                   "*####"])) :-
    partida_nueva(Ruta),
    atom_concat(Ruta, '/marcar', Marcar),
    atom_concat(Ruta, '/descubrir', Descubrir),
    enviar(Marcar, _{fila: 1, columna: 1}, 200, _),
    enviar(Descubrir, _{fila: 2, columna: 3}, 200, R),
    get_dict(estado, R, E),
    get_dict(tablero, R, T).

test(partida_terminada, true(C == 400)) :-
    partida_nueva(Ruta),
    atom_concat(Ruta, '/descubrir', Descubrir),
    enviar(Descubrir, _{fila: 2, columna: 3}, 200, _),
    enviar(Descubrir, _{fila: 1, columna: 1}, C, _).

test(fuera_del_tablero, true(C == 400)) :-
    partida_nueva(Ruta),
    atom_concat(Ruta, '/descubrir', Descubrir),
    enviar(Descubrir, _{fila: 9, columna: 9}, C, _).

test(accion_inexistente, true(C == 404)) :-
    partida_nueva(Ruta),
    atom_concat(Ruta, '/saltar', Saltar),
    enviar(Saltar, _{fila: 1, columna: 1}, C, _).

test(partida_inexistente, true(C == 404)) :-
    obtener('/partidas/999', C, _).

test(dimensiones_invalidas, true(C == 400)) :-
    enviar('/partidas', _{filas: 0, columnas: 5, minas: 4, semilla: 1}, C, _).

:- end_tests(servicio_buscaminas).
