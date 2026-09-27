:- encoding(utf8).

% Capítulo 28 - Un programa de línea de comandos: contar líneas y palabras.
%
% Se ejecuta con swipl contar.pl [opciones] archivo...; escribe, para cada
% archivo, la cantidad de líneas y de palabras. main/1 lee los argumentos,
% convierte los errores en mensajes y en un código de salida, y termina con
% halt/1. contar_texto/3, el núcleo, no depende de argumentos ni de archivos.
%
% solo-local: SWISH no ejecuta programas con argumentos ni lee archivos.
%
%?- contar_texto("uno dos\ntres\n", Lineas, Palabras).

:- use_module(library(main)).
:- use_module(library(readutil)).

:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): la opción --Opcion, o -Opcion si es una
% letra, da el valor Clave(Valor), de tipo Tipo.
opt_type(lineas,   lineas,   boolean).
opt_type(l,        lineas,   boolean).
opt_type(palabras, palabras, boolean).
opt_type(w,        palabras, boolean).

% opt_help(Clave, Texto): la ayuda de cada opción, para -h y --help.
opt_help(lineas,      "Escribe solo la cantidad de líneas").
opt_help(palabras,    "Escribe solo la cantidad de palabras").
opt_help(help(usage), " [opciones] archivo...").

%!  main(+Argv:list) is det.
%
%   El programa: cuenta cada archivo de Argv y termina con el código 0; con
%   1 si no recibe ningún archivo; con 2 si se produce otro error, como un
%   archivo que no existe. Cada error se escribe como un mensaje.
main(Argv) :-
    argv_options(Argv, Archivos, Opciones),
    catch(( contar_archivos(Archivos, Opciones),
            Codigo = 0 ),
          Error,
          ( print_message(error, Error),
            codigo_de_error(Error, Codigo) )),
    halt(Codigo).

%!  codigo_de_error(+Error, -Codigo:integer) is det.
%
%   Codigo es el código de salida del programa para Error: 1 para un error
%   de uso, 2 para cualquier otro.
codigo_de_error(uso(_), 1) :-
    !.
codigo_de_error(_, 2).

%!  contar_archivos(+Archivos:list, +Opciones:list) is det.
%
%   Escribe la cuenta de cada archivo de Archivos.
%
%   @error uso(sin_archivos) si Archivos es la lista vacía.
contar_archivos([], _) :-
    throw(uso(sin_archivos)).
contar_archivos([Archivo|Archivos], Opciones) :-
    maplist(contar_archivo(Opciones), [Archivo|Archivos]).

%!  contar_archivo(+Opciones:list, +Archivo) is det.
%
%   Escribe la cuenta de Archivo, con las columnas que piden Opciones.
contar_archivo(Opciones, Archivo) :-
    read_file_to_string(Archivo, Texto, [encoding(utf8)]),
    contar_texto(Texto, Lineas, Palabras),
    columnas(Opciones, Lineas, Palabras, Numeros),
    maplist(columna, Numeros, Columnas),
    atomic_list_concat(Columnas, Fila),
    format("~w  ~w~n", [Fila, Archivo]).

%!  columna(+N:integer, -Columna:atom) is det.
%
%   Columna es N alineado a la derecha en ocho caracteres.
columna(N, Columna) :-
    format(atom(Columna), "~t~d~8|", [N]).

%!  columnas(+Opciones:list, +Lineas:integer, +Palabras:integer,
%!           -Numeros:list(integer)) is det.
%
%   Numeros son las cantidades que se escriben: las que piden Opciones, o
%   las dos si no piden ninguna.
columnas(Opciones, Lineas, Palabras, Numeros) :-
    (   option(lineas(true), Opciones)
    ->  Numeros = [Lineas]
    ;   option(palabras(true), Opciones)
    ->  Numeros = [Palabras]
    ;   Numeros = [Lineas, Palabras]
    ).

%!  contar_texto(+Texto:string, -Lineas:integer, -Palabras:integer) is det.
%
%   Lineas es la cantidad de saltos de línea de Texto, y Palabras la de sus
%   palabras, separadas por blancos.
contar_texto(Texto, Lineas, Palabras) :-
    aggregate_all(count, sub_string(Texto, _, _, _, "\n"), Lineas),
    split_string(Texto, " \t\r\n", " \t\r\n", Partes),
    exclude(==(""), Partes, Todas),
    length(Todas, Palabras).

:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El texto de los mensajes propios del programa.
prolog:message(uso(sin_archivos)) -->
    [ 'Falta el nombre de un archivo (-h para ver la ayuda)' ].
