:- encoding(utf8).

% Capítulo 28 - Solución del ejercicio 1: contar.pl con la opción -c.
%
% Es contar.pl con tres cambios: la opción caracteres, una tercera cantidad
% en contar_texto/4, y la columna que la escribe. El resto no cambia.
%
% solo-local: SWISH no ejecuta programas con argumentos ni lee archivos.
%
%?- contar_texto("uno dos\ntrés\n", Lineas, Palabras, Caracteres).

:- use_module(library(main)).
:- use_module(library(readutil)).

:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): las opciones del programa.
opt_type(lineas,     lineas,     boolean).
opt_type(l,          lineas,     boolean).
opt_type(palabras,   palabras,   boolean).
opt_type(w,          palabras,   boolean).
opt_type(caracteres, caracteres, boolean).
opt_type(c,          caracteres, boolean).

% opt_help(Clave, Texto): la ayuda de cada opción.
opt_help(lineas,      "Escribe solo la cantidad de líneas").
opt_help(palabras,    "Escribe solo la cantidad de palabras").
opt_help(caracteres,  "Escribe solo la cantidad de caracteres").
opt_help(help(usage), " [opciones] archivo...").

%!  main(+Argv:list) is det.
%
%   Como main/1 de contar.pl.
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
%   Codigo es 1 para un error de uso, 2 para cualquier otro.
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
    contar_texto(Texto, Lineas, Palabras, Caracteres),
    columnas(Opciones, Lineas-Palabras-Caracteres, Numeros),
    maplist(columna, Numeros, Columnas),
    atomic_list_concat(Columnas, Fila),
    format("~w  ~w~n", [Fila, Archivo]).

%!  columna(+N:integer, -Columna:atom) is det.
%
%   Columna es N alineado a la derecha en ocho caracteres.
columna(N, Columna) :-
    format(atom(Columna), "~t~d~8|", [N]).

%!  columnas(+Opciones:list, +Cuentas, -Numeros:list(integer)) is det.
%
%   Numeros son las cantidades de Cuentas, Lineas-Palabras-Caracteres, que
%   piden Opciones, o las tres si no piden ninguna.
columnas(Opciones, Lineas-Palabras-Caracteres, Numeros) :-
    (   option(lineas(true), Opciones)
    ->  Numeros = [Lineas]
    ;   option(palabras(true), Opciones)
    ->  Numeros = [Palabras]
    ;   option(caracteres(true), Opciones)
    ->  Numeros = [Caracteres]
    ;   Numeros = [Lineas, Palabras, Caracteres]
    ).

%!  contar_texto(+Texto:string, -Lineas:integer, -Palabras:integer,
%!               -Caracteres:integer) is det.
%
%   Como contar_texto/3 de contar.pl, y Caracteres es la cantidad de
%   caracteres de Texto: una letra con tilde cuenta una vez.
contar_texto(Texto, Lineas, Palabras, Caracteres) :-
    aggregate_all(count, sub_string(Texto, _, _, _, "\n"), Lineas),
    split_string(Texto, " \t\r\n", " \t\r\n", Partes),
    exclude(==(""), Partes, Todas),
    length(Todas, Palabras),
    string_length(Texto, Caracteres).

:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El texto de los mensajes propios del programa.
prolog:message(uso(sin_archivos)) -->
    [ 'Falta el nombre de un archivo (-h para ver la ayuda)' ].
