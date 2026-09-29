:- encoding(utf8).

% Capítulo 31 - Buscaminas completo: el programa.
%
%     swipl buscaminas.pl [--semilla=N] filas columnas minas
%     swipl buscaminas.pl --servicio [--puerto=P] [--publico]
%
% Con tres números, juega en la terminal, y termina con el código 0 si la
% partida se gana y con 1 si se pierde. Con --servicio, ofrece el juego por
% HTTP. Los módulos: vecinos, tablero, descubrir, resolver, partida,
% terminal y servicio; este archivo solo lee los argumentos y elige.
%
% solo-local: SWISH no admite módulos propios ni ejecuta programas.
%
%?- nueva_partida(9, 9, 10, 7, P), mostrar(P, false).
%
% thread_get_message/1: lo presenta el capítulo 37, con los hilos.

:- use_module(library(main)).
:- use_module(partida).
:- use_module(terminal).
:- use_module(servicio).

:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): las opciones del programa.
opt_type(semilla,  semilla,  integer).
opt_type(servicio, servicio, boolean).
opt_type(puerto,   puerto,   nonneg).
opt_type(publico,  publico,  boolean).

% opt_help(Clave, Texto): la ayuda de cada opción.
opt_help(semilla,     "Semilla del azar: la misma semilla repite el tablero").
opt_help(servicio,    "Ofrece el juego por HTTP en lugar de jugar").
opt_help(puerto,      "Puerto del servicio; sin la opción, uno libre").
opt_help(publico,     "El servicio acepta pedidos de cualquier interfaz").
opt_help(help(usage), " [--semilla=N] filas columnas minas | --servicio").

%!  main(+Argv:list) is det.
%
%   Juega en la terminal o arranca el servicio, según los argumentos, y
%   termina con el código de salida del resultado: 0 si se gana, 1 si se
%   pierde, 2 ante un error.
main(Argv) :-
    argv_options(Argv, Posicionales, Opciones),
    catch(correr(Posicionales, Opciones, Codigo),
          Error,
          ( print_message(error, Error),
            Codigo = 2 )),
    halt(Codigo).

%!  correr(+Posicionales:list, +Opciones:list, -Codigo:integer) is det.
%
%   Hace lo que piden los argumentos.
%
%   @error uso(argumentos) si no son tres números ni --servicio.
correr(_, Opciones, 0) :-
    option(servicio(true), Opciones),
    !,
    option(puerto(Puerto), Opciones, _),
    (   option(publico(true), Opciones)
    ->  Alcance = publico
    ;   Alcance = local
    ),
    iniciar_servicio(Puerto, Alcance),
    format("Buscaminas en http://localhost:~w/~n", [Puerto]),
    flush_output,
    thread_get_message(_).
correr([F, C, M], Opciones, Codigo) :-
    !,
    maplist(numero, [F, C, M], [Filas, Columnas, Minas]),
    option(semilla(Semilla), Opciones, 0),
    nueva_partida(Filas, Columnas, Minas, Semilla, Partida),
    prompt(_, ''),
    jugar_en_terminal(user_input, Partida, Estado),
    (   Estado == gano
    ->  Codigo = 0
    ;   Codigo = 1
    ).
correr(_, _, _) :-
    throw(uso(argumentos)).

%!  numero(+Argumento:atom, -N:integer) is det.
%
%   N es el entero que escribe Argumento.
%
%   @error type_error(integer, Argumento) si no es un entero.
numero(Argumento, N) :-
    (   atom_number(Argumento, N),
        integer(N)
    ->  true
    ;   type_error(integer, Argumento)
    ).

:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El mensaje de uso.
prolog:message(uso(argumentos)) -->
    [ 'Uso: swipl buscaminas.pl [--semilla=N] filas columnas minas',
      nl, '     swipl buscaminas.pl --servicio [--puerto=P] [--publico]' ].
