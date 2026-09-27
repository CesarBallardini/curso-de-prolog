:- encoding(utf8).

% Capítulo 28 - Soluciones de los ejercicios 12 y 13: el proyecto.
%
% Es principal.pl con dos cambios: la opción --salida=ARCHIVO, que escribe la
% respuesta de la orden en el archivo, y un bucle que cuenta las órdenes que
% ejecutó y escribe la cantidad al salir.
%
% solo-local: SWISH no ejecuta programas con argumentos ni usa archivos.
%
%?- open_string("listar logica\nsalir\n", In), bucle_contando(In, 0, N).

:- use_module(library(main)).
:- use_module(library(readutil)).
:- ensure_loaded(inscripciones/inscripciones).

:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): las opciones del programa.
opt_type(estado,  estado,  atom).
opt_type(ajustes, ajustes, atom).
opt_type(salida,  salida,  atom).

% opt_help(Clave, Texto): la ayuda de cada opción.
opt_help(estado,      "Archivo donde se guarda el estado entre ejecuciones").
opt_help(ajustes,     "Archivo de ajustes, como archivos/ajustes.cfg").
opt_help(salida,      "Archivo donde se escribe la respuesta de la orden").
opt_help(help(usage), " [opciones] [orden]").

%!  main(+Argv:list) is det.
%
%   Como main/1 de principal.pl.
main(Argv) :-
    argv_options(Argv, Palabras, Opciones),
    catch(correr(Palabras, Opciones, Codigo),
          Error,
          ( print_message(error, Error),
            Codigo = 2 )),
    halt(Codigo).

%!  correr(+Palabras:list, +Opciones:list, -Codigo:integer) is det.
%
%   Como correr/3 de principal.pl, con la opción salida y el bucle que
%   cuenta las órdenes.
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
        bucle_contando(user_input, 0, N),
        format("Órdenes ejecutadas: ~d.~n", [N]),
        Codigo = 0
    ;   atomic_list_concat(Palabras, ' ', Orden),
        responder_en(Opciones, Orden, Respuesta),
        codigo_de_salida(Respuesta, Codigo)
    ),
    (   option(estado(Archivo), Opciones)
    ->  guardar_estado(Archivo)
    ;   true
    ).

% --- Ejercicio 12 -----------------------------------------------------------

%!  responder_en(+Opciones:list, +Orden, -Respuesta) is det.
%
%   Ejecuta Orden con responder/2. Con la opción salida(Archivo), lo que
%   responder/2 escribe va al archivo, que se reemplaza; sin ella, a la
%   salida actual. Los mensajes de error siguen yendo a la terminal.
responder_en(Opciones, Orden, Respuesta) :-
    (   option(salida(Archivo), Opciones)
    ->  with_output_to(string(Texto), responder(Orden, Respuesta)),
        setup_call_cleanup(open(Archivo, write, Stream, [encoding(utf8)]),
                           write(Stream, Texto),
                           close(Stream))
    ;   responder(Orden, Respuesta)
    ).

% --- Ejercicio 13 -----------------------------------------------------------

%!  bucle_contando(+In, +Hasta:integer, -N:integer) is det.
%
%   Como bucle/1, y N es Hasta más la cantidad de órdenes que ejecutó; las
%   líneas vacías y salir no cuentan. La cantidad pasa de una llamada a la
%   siguiente como argumento, sin la base dinámica.
bucle_contando(In, Hasta, N) :-
    format("inscripciones> "),
    flush_output,
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  nl,
        N = Hasta
    ;   normalize_space(string(Orden), Linea),
        (   Orden == "salir"
        ->  N = Hasta
        ;   Orden == ""
        ->  bucle_contando(In, Hasta, N)
        ;   responder(Orden, _),
            Siguiente is Hasta + 1,
            bucle_contando(In, Siguiente, N)
        )
    ).
