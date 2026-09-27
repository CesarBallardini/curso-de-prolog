:- encoding(utf8).

% Capítulo 30 - Inscripciones: el programa de línea de comandos.
%
%     swipl principal.pl [opciones] [orden]
%
% Con una orden, como listar logica, la ejecuta y termina con el código de
% salida de consola:codigo_de_salida/2. Sin orden, lee órdenes del teclado
% hasta salir. Con --estado=ARCHIVO, carga el estado de ese archivo si
% existe, y lo guarda al terminar: así una inscripción dura de una ejecución
% a la siguiente.
%
% solo-local: SWISH no ejecuta programas con argumentos ni usa archivos.
%
%?- responder("listar logica", Respuesta).

:- use_module(library(main)).
:- ensure_loaded(inscripciones).

:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): las opciones del programa.
opt_type(estado,  estado,  atom).
opt_type(ajustes, ajustes, atom).

% opt_help(Clave, Texto): la ayuda de cada opción.
opt_help(estado,      "Archivo donde se guarda el estado entre ejecuciones").
opt_help(ajustes,     "Archivo de ajustes, como archivos/ajustes.cfg").
opt_help(help(usage), " [opciones] [orden]").

%!  main(+Argv:list) is det.
%
%   Ejecuta la orden de Argv, o el bucle si no hay ninguna, y termina con el
%   código de salida de la respuesta. Un error que nadie capturó se escribe
%   como mensaje, y el código es 2.
main(Argv) :-
    argv_options(Argv, Palabras, Opciones),
    catch(correr(Palabras, Opciones, Codigo),
          Error,
          ( print_message(error, Error),
            Codigo = 2 )),
    halt(Codigo).

%!  correr(+Palabras:list, +Opciones:list, -Codigo:integer) is det.
%
%   Carga los ajustes y el estado que piden Opciones, ejecuta la orden
%   formada por Palabras o el bucle, y guarda el estado.
correr(Palabras, Opciones, Codigo) :-
    (   option(ajustes(Ajustes), Opciones)
    ->  cargar_ajustes(Ajustes)
    ;   true
    ),
    (   option(estado(Archivo), Opciones),
        exists_file(Archivo)
    ->  cargar_estado(Archivo)
    ;   true
    ),
    (   Palabras == []
    ->  prompt(_, ''),
        bucle(user_input),
        Codigo = 0
    ;   atomic_list_concat(Palabras, ' ', Orden),
        responder(Orden, Respuesta),
        codigo_de_salida(Respuesta, Codigo)
    ),
    (   option(estado(Archivo), Opciones)
    ->  guardar_estado(Archivo)
    ;   true
    ).
