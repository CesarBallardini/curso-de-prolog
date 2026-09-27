:- encoding(utf8).

% Capítulo 31 - Solución del ejercicio 12: buscaminas.pl con la opción
% --nivel.
%
%     swipl soluciones_buscaminas.pl [--semilla=N] filas columnas minas
%     swipl soluciones_buscaminas.pl [--semilla=N] --nivel=NIVEL
%     swipl soluciones_buscaminas.pl --servicio [--puerto=P] [--publico]
%
% Con tres números, o con un nivel, juega en la terminal, y termina con el
% código 0 si la partida se gana y con 1 si se pierde. Con --servicio,
% ofrece el juego por HTTP. Los módulos: vecinos, tablero, descubrir,
% resolver, partida, terminal y servicio; este archivo solo lee los
% argumentos y elige.
%
% solo-local: SWISH no admite módulos propios ni ejecuta programas.
%
%?- nueva_partida(9, 9, 10, 7, P), mostrar(P, false).

:- use_module(library(main)).
:- use_module(partida).
:- use_module(terminal).
:- use_module(servicio).

:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): las opciones del programa.
opt_type(semilla,  semilla,  integer).
opt_type(nivel,    nivel,    oneof([principiante, intermedio, experto])).
opt_type(servicio, servicio, boolean).
opt_type(puerto,   puerto,   nonneg).
opt_type(publico,  publico,  boolean).

% opt_help(Clave, Texto): la ayuda de cada opción.
opt_help(semilla,     "Semilla del azar: la misma semilla repite el tablero").
opt_help(nivel,       "Tablero principiante, intermedio o experto").
opt_help(servicio,    "Ofrece el juego por HTTP en lugar de jugar").
opt_help(puerto,      "Puerto del servicio; sin la opción, uno libre").
opt_help(publico,     "El servicio acepta pedidos de cualquier interfaz").
opt_help(help(usage),
         " [--semilla=N] filas columnas minas | --nivel=NIVEL | --servicio").

% nivel(Nivel, Filas, Columnas, Minas): el tablero de cada nivel.
nivel(principiante,  9,  9, 10).
nivel(intermedio,   16, 16, 40).
nivel(experto,      16, 30, 99).

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
%   @error uso(argumentos) si no son tres números, ni un nivel, ni
%          --servicio.
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
correr([], Opciones, Codigo) :-
    option(nivel(Nivel), Opciones),
    !,
    nivel(Nivel, Filas, Columnas, Minas),
    jugar(Filas, Columnas, Minas, Opciones, Codigo).
correr([F, C, M], Opciones, Codigo) :-
    !,
    maplist(numero, [F, C, M], [Filas, Columnas, Minas]),
    jugar(Filas, Columnas, Minas, Opciones, Codigo).
correr(_, _, _) :-
    throw(uso(argumentos)).

%!  jugar(+Filas:integer, +Columnas:integer, +Minas:integer,
%!        +Opciones:list, -Codigo:integer) is det.
%
%   Juega en la terminal una partida de Filas por Columnas con Minas, con
%   la semilla de Opciones. Codigo es 0 si la partida se gana y 1 si se
%   pierde.
jugar(Filas, Columnas, Minas, Opciones, Codigo) :-
    option(semilla(Semilla), Opciones, 0),
    nueva_partida(Filas, Columnas, Minas, Semilla, Partida),
    prompt(_, ''),
    jugar_en_terminal(user_input, Partida, Estado),
    (   Estado == gano
    ->  Codigo = 0
    ;   Codigo = 1
    ).

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
    [ 'Uso: swipl ~w [--semilla=N] filas columnas minas'-[Programa],
      nl, '     swipl ~w [--semilla=N] --nivel=NIVEL'-[Programa],
      nl, '     swipl ~w --servicio [--puerto=P] [--publico]'-[Programa] ],
    { Programa = 'soluciones_buscaminas.pl' }.
