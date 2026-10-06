:- encoding(utf8).

% Capítulo 83 - El filtro de marcas, versión 3: un programa para la terminal.
%
% Se ejecuta con swipl cribar_programa.pl -i INICIO -f FIN [entrada [salida]].
% Sin archivos, lee la entrada estándar y escribe en la salida estándar,
% como los filtros de la terminal; con uno, lee el archivo y escribe en la
% salida estándar; con dos, escribe el segundo. Lee y escribe de a una
% línea, con paso/7 de cribar_seguro.pl, así que la memoria que usa no
% depende del tamaño del texto. Si las marcas no forman pares, escribe el
% error con su número de línea, borra el archivo de salida a medio escribir
% y termina con el código 2.
%
% solo-local: SWISH no ejecuta programas con argumentos ni lee archivos.
%
%?- cribar_cadena("a\nINICIO\nb\nFIN\nc\n", "INICIO", "FIN", Salida).

:- use_module(library(main)).
:- use_module(library(readutil)).
:- use_module(cribar_seguro).

:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): la opción --Opcion, o -Opcion si es una
% letra, da el valor Clave(Valor), de tipo Tipo.
opt_type(inicio, inicio, string).
opt_type(i,      inicio, string).
opt_type(fin,    fin,    string).
opt_type(f,      fin,    string).

% opt_help(Clave, Texto): la ayuda de cada opción, para -h y --help.
opt_help(inicio,      "Texto con el que empieza la línea que abre una sección").
opt_help(fin,         "Texto con el que empieza la línea que la cierra").
opt_help(help(usage), " -i INICIO -f FIN [entrada [salida]]").

%!  main(+Argv:list) is det.
%
%   El programa: filtra según Argv y termina con el código 0; con 1 ante un
%   error de uso, y con 2 ante cualquier otro error, como unas marcas que
%   no forman pares o un archivo que no existe.
main(Argv) :-
    set_stream(user_input, encoding(utf8)),
    set_stream(user_output, encoding(utf8)),
    set_stream(user_error, encoding(utf8)),
    argv_options(Argv, Archivos, Opciones),
    catch(( marcas(Opciones, Inicio, Fin),
            cribar_archivos(Archivos, Inicio, Fin),
            Codigo = 0 ),
          Error,
          ( print_message(error, Error),
            codigo_de_error(Error, Codigo) )),
    halt(Codigo).

%!  marcas(+Opciones:list, -Inicio:string, -Fin:string) is det.
%
%   Inicio y Fin son las marcas de Opciones. Lanza uso(sin_marcas) si
%   falta alguna, o si alguna es la cadena vacía.
marcas(Opciones, Inicio, Fin) :-
    (   option(inicio(Inicio), Opciones),
        option(fin(Fin), Opciones),
        Inicio \== "",
        Fin \== ""
    ->  true
    ;   throw(uso(sin_marcas))
    ).

%!  codigo_de_error(+Error, -Codigo:integer) is det.
%
%   Codigo es el código de salida del programa para Error: 1 para un error
%   de uso, 2 para cualquier otro.
codigo_de_error(uso(_), 1) :-
    !.
codigo_de_error(_, 2).

%!  cribar_archivos(+Archivos:list, +Inicio:string, +Fin:string) is det.
%
%   Filtra la entrada que nombra Archivos hacia la salida que nombra: la
%   entrada y la salida estándar si Archivos es [], un archivo y la salida
%   estándar si es [Entrada], dos archivos si es [Entrada, Salida]. Lanza
%   uso(Problema) si hay más archivos, o si la salida es la entrada.
cribar_archivos([], Inicio, Fin) :-
    cribar_stream(user_input, user_output, Inicio, Fin).
cribar_archivos([Entrada], Inicio, Fin) :-
    setup_call_cleanup(open(Entrada, read, In, [encoding(utf8)]),
                       cribar_stream(In, user_output, Inicio, Fin),
                       close(In)).
cribar_archivos([Entrada, Salida], Inicio, Fin) :-
    (   exists_file(Salida),
        same_file(Entrada, Salida)
    ->  throw(uso(misma_salida(Salida)))
    ;   true
    ),
    setup_call_cleanup(open(Entrada, read, In, [encoding(utf8)]),
                       cribar_hacia(In, Salida, Inicio, Fin),
                       close(In)).
cribar_archivos([_, _, _|_], _, _) :-
    throw(uso(demasiados_archivos)).

%!  cribar_hacia(+In, +Salida, +Inicio:string, +Fin:string) is det.
%
%   Filtra el stream In hacia el archivo Salida, que se reemplaza. Si se
%   produce un error, borra Salida antes de relanzarlo, para no dejar un
%   archivo a medio escribir.
cribar_hacia(In, Salida, Inicio, Fin) :-
    catch(setup_call_cleanup(open(Salida, write, Out, [encoding(utf8)]),
                             cribar_stream(In, Out, Inicio, Fin),
                             close(Out)),
          Error,
          ( delete_file(Salida),
            throw(Error) )).

%!  cribar_stream(+In, +Out, +Inicio:string, +Fin:string) is det.
%
%   Lee las líneas de In y escribe en Out las que quedan fuera de las
%   secciones, de a una, con paso/7.
cribar_stream(In, Out, Inicio, Fin) :-
    cribar_stream(In, Out, 1, copiando, Inicio, Fin).

%!  cribar_stream(+In, +Out, +N:integer, +Estado, +Inicio:string,
%!                +Fin:string) is det.
%
%   Como cribar_stream/4, con la próxima línea de In numerada N y el
%   recorrido en Estado.
cribar_stream(In, Out, N, Estado, Inicio, Fin) :-
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  final(Estado)
    ;   paso(Estado, N, Linea, Inicio, Fin, Estado1, Salida),
        forall(member(L, Salida), format(Out, "~w~n", [L])),
        N1 is N + 1,
        cribar_stream(In, Out, N1, Estado1, Inicio, Fin)
    ).

%!  cribar_cadena(+Texto:string, +Inicio:string, +Fin:string,
%!                -Salida:string) is det.
%
%   Salida es lo que escribe cribar_stream/4 con la entrada Texto: el
%   mismo recorrido que hace el programa, sin archivos.
cribar_cadena(Texto, Inicio, Fin, Salida) :-
    setup_call_cleanup(open_string(Texto, In),
                       with_output_to(string(Salida),
                                      cribar_stream(In, current_output,
                                                    Inicio, Fin)),
                       close(In)).

:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El texto de los errores de uso del programa.
prolog:message(uso(sin_marcas)) -->
    [ 'Faltan las marcas: -i INICIO -f FIN (-h para ver la ayuda)' ].
prolog:message(uso(demasiados_archivos)) -->
    [ 'Sobran archivos: a lo sumo una entrada y una salida' ].
prolog:message(uso(misma_salida(Archivo))) -->
    [ 'La salida ~w es el mismo archivo que la entrada'-[Archivo] ].
