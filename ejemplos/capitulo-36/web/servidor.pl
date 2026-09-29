:- encoding(utf8).

% Capítulo 36 - Las páginas web como programa: un servidor que sirve, en un
% mismo puerto, las páginas de Inscripciones y del tablero, las rutas de
% JSON de Inscripciones y el servicio del Buscaminas, al que las páginas
% del tablero le piden los datos.
%
%     swipl servidor.pl [--puerto=P]
%
% Sin --puerto elige uno libre. La primera línea que escribe da la
% dirección; las pruebas con el navegador (test_paginas.py) la leen de ahí.
%
% solo-local: SWISH no admite módulos propios ni permite abrir puertos.
%
%?- iniciar(Puerto), detener_api(Puerto).
%
% thread_get_message/1: lo presenta el capítulo 37, con los hilos.

:- use_module(library(main)).
:- use_module(paginas_inscripciones).
:- use_module(tablero_web).
:- use_module('../../capitulo-31/buscaminas/servicio', []).

:- initialization(main, main).

%!  iniciar(?Puerto:integer) is det.
%
%   Arranca el servidor en Puerto, o en uno libre, y dirige las páginas del
%   tablero al servicio del Buscaminas del mismo servidor.
iniciar(Puerto) :-
    iniciar_api(Puerto),
    format(atom(Base), "http://127.0.0.1:~w", [Puerto]),
    usar_servicio(Base).

%!  main(+Argv:list) is det.
%
%   Arranca el servidor, escribe su dirección y espera.
main(Argv) :-
    argv_options(Argv, _, Opciones),
    option(puerto(Puerto), Opciones, _),
    iniciar(Puerto),
    format("Páginas en http://localhost:~w/pagina/materias~n", [Puerto]),
    flush_output,
    thread_get_message(_).
