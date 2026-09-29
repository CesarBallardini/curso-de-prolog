:- encoding(utf8).

% Pruebas de las páginas del tablero: el servicio JSON del capítulo 31 y
% las páginas corren en el mismo servidor, en un puerto libre, y las
% páginas le piden los datos por HTTP.

:- use_module(library(http/http_open)).
:- use_module(library(http/html_write)).
:- use_module('../../capitulo-31/buscaminas/servicio').

:- dynamic puerto_de_prueba/1.

%!  arrancar_para_pruebas is det.
%
%   Arranca el servidor en un puerto libre y dirige las páginas a él.
arrancar_para_pruebas :-
    iniciar_servicio(Puerto, local),
    format(atom(Base), "http://127.0.0.1:~w", [Puerto]),
    usar_servicio(Base),
    assertz(puerto_de_prueba(Puerto)).

%!  parar_despues_de_pruebas is det.
%
%   Detiene el servidor de las pruebas.
parar_despues_de_pruebas :-
    retract(puerto_de_prueba(Puerto)),
    detener_servicio(Puerto).

%!  enviar_formulario(+Ruta:atom, +Campos:list, -Codigo:integer,
%!                    -Final:atom, -Texto:string) is det.
%
%   Envía Campos a Ruta con POST y sigue la redirección: Codigo, Final y
%   Texto son el código, la dirección y el cuerpo de la última respuesta.
enviar_formulario(Ruta, Campos, Codigo, Final, Texto) :-
    puerto_de_prueba(Puerto),
    format(atom(Url), "http://127.0.0.1:~w~w", [Puerto, Ruta]),
    setup_call_cleanup(
        http_open(Url, S, [ method(post), post(form(Campos)),
                            status_code(Codigo), final_url(Final) ]),
        read_string(S, _, Texto),
        close(S)).

:- begin_tests(tablero_web, [ setup(arrancar_para_pruebas),
                              cleanup(parar_despues_de_pruebas) ]).

test(texto_de_estado,
     true(Ts == ['Minas sin marcar: 3', 'Partida ganada',
                 'Partida perdida'])) :-
    tablero_web:texto_de_estado("sigue", 3, T1),
    tablero_web:texto_de_estado("gano", 3, T2),
    tablero_web:texto_de_estado("perdio", 3, T3),
    Ts = [T1, T2, T3].

test(sin_botones_al_terminar, true(Filas == [tr([td(*), td('1')])])) :-
    cuerpo_tablero(1, _{estado: "perdio", minas_restantes: 1,
                        tablero: ["*1"]},
                   [_, p('Partida perdida'), form(_, [_, table(Filas)])]).

test(botones, true(Fila == tr([td(button([type(submit), name(celda),
                                          value('1-1')], 'M')),
                               td('1')]))) :-
    cuerpo_tablero(1, _{estado: "sigue", minas_restantes: 0,
                        tablero: ["M1"]},
                   [_, _, form(_, [_, table([Fila])])]).

% Una partida nueva lleva a su página; marcar la celda 1-1 vuelve a ella
% con una M en el botón y nueve minas sin marcar.
test(jugar, true(C1-C2 == 200-200)) :-
    enviar_formulario('/juego', [], C1, Final, T1),
    once(sub_string(T1, _, _, _, "Minas sin marcar: 10")),
    uri_components(Final, uri_components(_, _, Ruta, _, _)),
    enviar_formulario(Ruta, [accion=marcar, celda='1-1'], C2, _, T2),
    once(sub_string(T2, _, _, _, "value=\"1-1\">M</button>")),
    once(sub_string(T2, _, _, _, "Minas sin marcar: 9")).

test(accion_desconocida, true(C == 400)) :-
    enviar_formulario('/juego/1', [accion=saltar, celda='1-1'], C, _, _).

% Las páginas en un servidor propio, en otro puerto, piden los datos al
% servicio de usar_servicio/1: una partida nueva muestra un botón por celda.
test(paginas_en_otro_puerto, [ cleanup(detener_paginas(P)),
                               true(C-N == 200-81) ]) :-
    iniciar_paginas(P),
    format(atom(Url), "http://127.0.0.1:~w/juego", [P]),
    setup_call_cleanup(
        http_open(Url, S, [ method(post), post(form([])),
                            status_code(C) ]),
        read_string(S, _, Texto),
        close(S)),
    aggregate_all(count, sub_string(Texto, _, _, _, "<button"), N).

:- end_tests(tablero_web).
