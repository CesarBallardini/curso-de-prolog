:- encoding(utf8).

% Capítulo 30 - Inscripciones: el servicio web, como programa.
%
%     swipl servicio.pl [--puerto=N]
%
% Carga el programa, arranca el servicio en el puerto N de la máquina local,
% o en uno libre, escribe su dirección y atiende pedidos hasta que el proceso
% termina.
%
% solo-local: SWISH no permite abrir puertos ni iniciar un servidor.
%
%?- iniciar_api(Puerto), detener_api(Puerto).

:- use_module(library(main)).
:- ensure_loaded(inscripciones).

:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): las opciones del programa.
opt_type(puerto, puerto, nonneg).

% opt_help(Clave, Texto): la ayuda de cada opción.
opt_help(puerto, "Puerto del servicio; sin la opción, uno libre").

%!  main(+Argv:list) is det.
%
%   Arranca el servicio, escribe su dirección en la primera línea de la
%   salida y espera: el servicio atiende los pedidos en sus propios hilos.
main(Argv) :-
    argv_options(Argv, _, Opciones),
    option(puerto(Puerto), Opciones, _),
    iniciar_api(Puerto),
    format("Inscripciones en http://localhost:~w/~n", [Puerto]),
    flush_output,
    thread_get_message(_).
