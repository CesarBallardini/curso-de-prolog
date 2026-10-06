:- encoding(utf8).

% Pruebas de acceso.pl: las sesiones sin HTTP, y las dos rutas nuevas con
% el servicio arrancado en un puerto libre. Las que inscriben restauran el
% estado con estado/1 y restaurar/1 del módulo datos del capítulo 30.

:- use_module(library(http/http_client)).
:- use_module(library(http/json)).
:- use_module('../capitulo-30/inscripciones/datos', [estado/1, restaurar/1]).

:- dynamic puerto_de_prueba/1.

%!  arrancar_para_pruebas is det.
%
%   Arranca el servicio en un puerto libre y lo recuerda.
arrancar_para_pruebas :-
    iniciar_api(Puerto),
    assertz(puerto_de_prueba(Puerto)).

%!  parar_despues_de_pruebas is det.
%
%   Detiene el servicio de las pruebas.
parar_despues_de_pruebas :-
    retract(puerto_de_prueba(Puerto)),
    detener_api(Puerto).

%!  enviar(+Ruta:atom, +Cuerpo:dict, +Cabeceras:list, -Codigo:integer,
%!         -Respuesta:dict) is det.
%
%   Hace POST a Ruta con Cuerpo como JSON y las Cabeceras agregadas.
enviar(Ruta, Cuerpo, Cabeceras, Codigo, Respuesta) :-
    puerto_de_prueba(Puerto),
    format(atom(Url), "http://127.0.0.1:~w~w", [Puerto, Ruta]),
    findall(request_header(C), member(C, Cabeceras), Opciones),
    append(Opciones,
           [ status_code(Codigo), json_object(dict),
             request_header('Accept'='application/json') ],
           Todas),
    http_post(Url, json(Cuerpo), Respuesta, Todas).

%!  ficha_por_http(+Legajo:integer, +Clave:atom, -Ficha:atom) is det.
%
%   Ficha es la que entrega POST /sesion a Legajo con Clave.
ficha_por_http(Legajo, Clave, Ficha) :-
    enviar('/sesion', _{legajo: Legajo, clave: Clave}, [], 200, R),
    atom_string(Ficha, R.ficha).

:- begin_tests(acceso).

test(iniciar_sesion) :-
    iniciar_sesion(102, tango, 1700000000, F),
    atomic_list_concat(['102', '1700003600', _], '.', F).

test(iniciar_sesion_clave_mala, [fail]) :-
    iniciar_sesion(102, tanga, 1700000000, _).

test(iniciar_sesion_sin_credencial, [fail]) :-
    iniciar_sesion(107, tango, 1700000000, _).

test(ficha_del_pedido, true(L == 102)) :-
    iniciar_sesion(102, tango, 1700000000, F),
    atom_concat('Bearer ', F, V),
    ficha_del_pedido([method(post), authorization(V)], 1700000001, L).

test(ficha_vencida, [fail]) :-
    iniciar_sesion(102, tango, 1700000000, F),
    atom_concat('Bearer ', F, V),
    ficha_del_pedido([authorization(V)], 1700003600, _).

test(sin_cabecera, [fail]) :-
    ficha_del_pedido([method(post)], 1700000000, _).

:- end_tests(acceso).

:- begin_tests(acceso_http, [ setup(arrancar_para_pruebas),
                              cleanup(parar_despues_de_pruebas) ]).

test(sesion, true(N == 3)) :-
    ficha_por_http(104, '123456', F),
    atomic_list_concat(Partes, '.', F),
    length(Partes, N).

test(sesion_rechazada, true(C == 401)) :-
    enviar('/sesion', _{legajo: 104, clave: tango}, [], C, _).

test(sesion_incompleta, true(C == 401)) :-
    enviar('/sesion', _{legajo: 104}, [], C, _).

test(inscribirse, [ setup(estado(E)), cleanup(restaurar(E)),
                    true(C-A == 201-true) ]) :-
    ficha_por_http(104, '123456', F),
    atom_concat('Bearer ', F, V),
    enviar('/mis-inscripciones', _{materia: ssl},
           ['Authorization'=V], C, R),
    A = R.aceptada.

test(sin_ficha, true(C == 401)) :-
    enviar('/mis-inscripciones', _{materia: ssl}, [], C, _).

test(ficha_alterada, true(C == 401)) :-
    ficha_por_http(104, '123456', F),
    atomic_list_concat([_, Vence, Mac], '.', F),
    atomic_list_concat(['Bearer 101', Vence, Mac], '.', V),
    enviar('/mis-inscripciones', _{materia: ssl},
           ['Authorization'=V], C, _).

test(sin_materia, true(C == 400)) :-
    ficha_por_http(104, '123456', F),
    atom_concat('Bearer ', F, V),
    enviar('/mis-inscripciones', _{curso: ssl},
           ['Authorization'=V], C, _).

test(rutas_del_30, true(C == 200)) :-
    puerto_de_prueba(Puerto),
    format(atom(Url), "http://127.0.0.1:~w/ranking", [Puerto]),
    http_get(Url, _, [status_code(C), json_object(dict)]).

:- end_tests(acceso_http).
