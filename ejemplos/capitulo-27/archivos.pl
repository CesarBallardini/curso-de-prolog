:- encoding(utf8).

% Capítulo 27 - Streams y archivos: términos, líneas, archivos completos y
% una gramática sobre un archivo.
%
% Los archivos de ejemplo están en el directorio archivos/, junto a este
% archivo. El alias archivos(Nombre) los encuentra desde cualquier
% directorio de trabajo.
%
% solo-local: el sandbox de SWISH no permite leer ni escribir archivos.
%
%?- leer_terminos(archivos('hechos.txt'), Terminos).
%?- contar_lineas(archivos('texto.txt'), N).

:- use_module(library(readutil)).
:- use_module(library(pio)).
:- use_module(library(dcg/basics)).

:- multifile user:file_search_path/2.
:- prolog_load_context(directory, Aqui),
   directory_file_path(Aqui, archivos, Dir),
   asserta(user:file_search_path(archivos, Dir)).

%!  leer_terminos(+Archivo, -Terminos:list) is det.
%
%   Terminos son los términos de Archivo, en orden, cada uno terminado en un
%   punto. Archivo puede ser un alias, como archivos('hechos.txt'). El stream
%   se cierra aunque la lectura produzca un error.
leer_terminos(Archivo, Terminos) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    setup_call_cleanup(open(Ruta, read, Stream, [encoding(utf8)]),
                       leer_terminos_de(Stream, Terminos),
                       close(Stream)).

%!  leer_terminos_de(+Stream, -Terminos:list) is det.
%
%   Terminos son los términos que quedan en Stream.
leer_terminos_de(Stream, Terminos) :-
    read_term(Stream, Termino, []),
    (   Termino == end_of_file
    ->  Terminos = []
    ;   Terminos = [Termino|Resto],
        leer_terminos_de(Stream, Resto)
    ).

%!  escribir_terminos(+Archivo, +Terminos:list) is det.
%
%   Escribe Terminos en Archivo, uno por línea, en una forma que
%   leer_terminos/2 vuelve a leer. Reemplaza el contenido anterior.
escribir_terminos(Archivo, Terminos) :-
    setup_call_cleanup(open(Archivo, write, Stream, [encoding(utf8)]),
                       forall(member(T, Terminos), portray_clause(Stream, T)),
                       close(Stream)).

%!  contar_lineas(+Archivo, -N:integer) is det.
%
%   N es la cantidad de líneas de Archivo.
contar_lineas(Archivo, N) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    setup_call_cleanup(open(Ruta, read, Stream, [encoding(utf8)]),
                       contar_lineas_de(Stream, 0, N),
                       close(Stream)).

%!  contar_lineas_de(+Stream, +Hasta:integer, -N:integer) is det.
%
%   N es Hasta más las líneas que quedan en Stream.
contar_lineas_de(Stream, Hasta, N) :-
    read_line_to_string(Stream, Linea),
    (   Linea == end_of_file
    ->  N = Hasta
    ;   Siguiente is Hasta + 1,
        contar_lineas_de(Stream, Siguiente, N)
    ).

%!  numerar_lineas(+Entrada, +Salida) is det.
%
%   Escribe en Salida las líneas de Entrada, cada una precedida por su
%   número. Los dos streams se cierran aunque se produzca un error.
numerar_lineas(Entrada, Salida) :-
    absolute_file_name(Entrada, Ruta, [access(read)]),
    setup_call_cleanup(
        open(Ruta, read, In, [encoding(utf8)]),
        setup_call_cleanup(
            open(Salida, write, Out, [encoding(utf8)]),
            numerar_desde(In, Out, 1),
            close(Out)),
        close(In)).

%!  numerar_desde(+In, +Out, +N:integer) is det.
%
%   Copia las líneas que quedan en In a Out, numeradas desde N.
numerar_desde(In, Out, N) :-
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  true
    ;   format(Out, "~t~d~3|  ~s~n", [N, Linea]),
        Siguiente is N + 1,
        numerar_desde(In, Out, Siguiente)
    ).

%!  lineas_no_vacias(+Archivo, -Lineas:list(string)) is det.
%
%   Lineas son las líneas de Archivo que no están vacías, leídas del archivo
%   completo de una sola vez.
lineas_no_vacias(Archivo, Lineas) :-
    read_file_to_string(Archivo, Texto, [encoding(utf8)]),
    split_string(Texto, "\n", "\r", Todas),
    exclude(==(""), Todas, Lineas).

%!  palabras_del_archivo(+Archivo, -Palabras:list(string)) is det.
%
%   Palabras son las palabras de Archivo, leídas con una gramática sobre el
%   archivo, sin cargarlo entero en memoria.
palabras_del_archivo(Archivo, Palabras) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    phrase_from_file(palabras(Palabras), Ruta, [encoding(utf8)]).

%!  palabras(-Palabras:list(string))// is det.
%
%   Las palabras del texto, separadas por blancos.
palabras([P|Ps]) -->
    blanks,
    nonblanks(Codigos),
    { Codigos \== [] },
    !,
    { string_codes(P, Codigos) },
    palabras(Ps).
palabras([]) -->
    blanks.

%!  archivos_del_directorio(-Nombres:list(atom)) is det.
%
%   Nombres son los archivos del directorio archivos/, en orden alfabético.
archivos_del_directorio(Nombres) :-
    absolute_file_name(archivos('.'), Directorio, [file_type(directory)]),
    directory_files(Directorio, Todos),
    exclude([N]>>sub_atom(N, 0, _, _, '.'), Todos, SinPuntos),
    sort(SinPuntos, Nombres).
