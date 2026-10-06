:- encoding(utf8).

% Capítulo 83 - Las curvas, versión 3: un archivo de especificaciones.
%
% Se ejecuta con swipl curvas_programa.pl [-t FORMATO] entrada salida. La
% entrada es un archivo de especificaciones: términos
% curva(Nombre, Curva, Desde, Hasta, N), cada uno terminado en un punto, y
% comentarios que empiezan con %. La salida es el archivo con la definición
% de cada curva, en el formato de -t (epic, tikz o svg) o, sin -t, svg si la
% salida termina en .svg y tikz si no; los comentarios de la entrada pasan
% a la salida en el mismo orden. Los términos se leen como datos y se
% verifican antes de calcular nada: un término que no es una especificación
% válida es un error con su número de línea, y nunca se ejecuta.
%
% solo-local: SWISH no ejecuta programas con argumentos ni lee archivos.
%
%?- especificacion(curva(c, circulo(0, 0, 1), 0, 2*pi, 4), 1, Parte).

:- use_module(library(main)).
:- use_module(curvas).

:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): la opción --Opcion, o -Opcion si es una
% letra, da el valor Clave(Valor), de tipo Tipo.
opt_type(formato, formato, oneof([epic, tikz, svg])).
opt_type(t,       formato, oneof([epic, tikz, svg])).

% opt_help(Clave, Texto): la ayuda de cada opción, para -h y --help.
opt_help(formato,     "Formato de la salida; sin -t, svg o tikz según la salida").
opt_help(help(usage), " [-t epic|tikz|svg] entrada salida").

%!  main(+Argv:list) is det.
%
%   El programa: escribe el archivo de salida y termina con el código 0;
%   con 1 ante un error de uso, y con 2 ante cualquier otro error, como una
%   especificación inválida o un archivo que no existe.
main(Argv) :-
    set_stream(user_error, encoding(utf8)),
    argv_options(Argv, Archivos, Opciones),
    catch(( curvas_archivos(Archivos, Opciones),
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

%!  curvas_archivos(+Archivos:list, +Opciones:list) is det.
%
%   Archivos es [Entrada, Salida]: lee las especificaciones de Entrada y
%   escribe Salida en el formato de Opciones. Lanza uso(archivos) con otra
%   cantidad de archivos.
curvas_archivos([Entrada, Salida], Opciones) :-
    !,
    formato(Opciones, Salida, Formato),
    curvas(Entrada, Formato, Texto),
    setup_call_cleanup(open(Salida, write, Out, [encoding(utf8)]),
                       write(Out, Texto),
                       close(Out)).
curvas_archivos(_, _) :-
    throw(uso(archivos)).

%!  formato(+Opciones:list, +Salida, -Formato) is det.
%
%   Formato es el de la opción -t, o, sin ella, svg si el nombre de Salida
%   termina en .svg y tikz si no.
formato(Opciones, Salida, Formato) :-
    (   option(formato(Formato0), Opciones)
    ->  Formato = Formato0
    ;   file_name_extension(_, svg, Salida)
    ->  Formato = svg
    ;   Formato = tikz
    ).

%!  curvas(+Entrada, +Formato, -Texto:string) is det.
%
%   Texto es el archivo, en Formato, que definen las especificaciones de
%   Entrada. Todo se calcula antes de escribir, así que un error no deja
%   una salida a medio escribir.
curvas(Entrada, Formato, Texto) :-
    leer_especificaciones(Entrada, Partes),
    documento(Formato, Partes, Texto).

%!  leer_especificaciones(+Archivo, -Partes:list) is det.
%
%   Partes son los comentarios y las curvas del archivo de
%   especificaciones Archivo, en orden: comentario(Texto) y
%   curva(Nombre, Puntos).
leer_especificaciones(Archivo, Partes) :-
    setup_call_cleanup(open(Archivo, read, In, [encoding(utf8)]),
                       leer_partes(In, [], Partes),
                       close(In)).

%!  leer_partes(+In, +Vistos:list(atom), -Partes:list) is det.
%
%   Partes son los comentarios y las curvas que quedan en In. Vistos son
%   los nombres de las curvas ya leídas; un nombre repetido es un error.
leer_partes(In, Vistos, Partes) :-
    read_term(In, Termino, [comments(Comentarios), term_position(Posicion)]),
    stream_position_data(line_count, Posicion, Linea),
    comentarios(Comentarios, Partes, Resto),
    (   Termino == end_of_file
    ->  Resto = []
    ;   especificacion(Termino, Linea, Parte),
        Parte = curva(Nombre, _),
        (   memberchk(Nombre, Vistos)
        ->  throw(error(especificacion(Linea, nombre_repetido(Nombre)), _))
        ;   true
        ),
        Resto = [Parte|Resto1],
        leer_partes(In, [Nombre|Vistos], Resto1)
    ).

%!  comentarios(+Comentarios:list, -Partes:list, ?Resto:list) is det.
%
%   Partes es la lista de los comentarios de línea de Comentarios, pares
%   Posicion-Cadena de read_term/3, seguida de Resto: un
%   comentario(Texto) por línea, sin el % ni los blancos del principio.
%   read_term/3 junta en una cadena las líneas de comentario seguidas. Los
%   comentarios de bloque no se copian.
comentarios([], Resto, Resto).
comentarios([_-Cadena|Cs], Partes, Resto) :-
    (   string_concat("%", _, Cadena)
    ->  split_string(Cadena, "\n", "\r", Lineas),
        maplist(comentario, Lineas, Propias),
        append(Propias, Partes1, Partes)
    ;   Partes = Partes1
    ),
    comentarios(Cs, Partes1, Resto).

%!  comentario(+Linea:string, -Parte) is det.
%
%   Parte es comentario(Texto), con Texto la línea de comentario Linea sin
%   el % ni los blancos del principio.
comentario(Linea, comentario(Texto)) :-
    split_string(Linea, "", "% ", [Texto]).

%!  especificacion(+Termino, +Linea:integer, -Parte) is det.
%
%   Parte es curva(Nombre, Puntos), la curva que especifica Termino, leído
%   en la línea Linea: curva(Nombre, Curva, Desde, Hasta, N). Lanza
%   error(especificacion(Linea, Problema), _) si Termino no es una
%   especificación válida: el nombre tiene que ser un átomo de letras, como
%   los de los comandos de LaTeX; la curva, una que curva/1 acepte; Desde y
%   Hasta, expresiones aritméticas sin variables; N, un entero positivo.
especificacion(Termino, Linea, curva(Nombre, Puntos)) :-
    (   Termino = curva(Nombre, Curva, Desde, Hasta, N)
    ->  true
    ;   throw(error(especificacion(Linea, termino(Termino)), _))
    ),
    verificar(Linea, nombre(Nombre)),
    verificar(Linea, curva(Curva)),
    verificar(Linea, extremo(Desde)),
    verificar(Linea, extremo(Hasta)),
    verificar(Linea, intervalos(N)),
    muestra(Curva, Desde, Hasta, N, Puntos).

%!  verificar(+Linea:integer, +Condicion) is det.
%
%   Condicion se cumple; si no, lanza
%   error(especificacion(Linea, Condicion), _).
verificar(Linea, Condicion) :-
    (   valida(Condicion)
    ->  true
    ;   throw(error(especificacion(Linea, Condicion), _))
    ).

%!  valida(+Condicion) is semidet.
%
%   Condicion se cumple: nombre(Nombre), curva(Curva), extremo(Expresion)
%   o intervalos(N).
valida(nombre(Nombre)) :-
    atom(Nombre),
    atom_codes(Nombre, Codigos),
    Codigos \== [],
    forall(member(C, Codigos), letra(C)).
valida(curva(Curva)) :-
    curva(Curva).
valida(extremo(Expresion)) :-
    ground(Expresion),
    catch(_ is Expresion, error(_, _), fail).
valida(intervalos(N)) :-
    integer(N),
    N > 0.

%!  letra(+C:integer) is semidet.
%
%   C es el código de una letra sin acento, de la a a la z, en minúscula o
%   en mayúscula.
letra(C) :-
    (   between(0'a, 0'z, C)
    ->  true
    ;   between(0'A, 0'Z, C)
    ).

:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El texto de los errores del programa.
prolog:message(error(especificacion(Linea, Problema), _)) -->
    [ 'línea ~d: '-[Linea] ],
    problema(Problema).
prolog:message(uso(archivos)) -->
    [ 'Hacen falta dos archivos: entrada y salida (-h para ver la ayuda)' ].

%!  problema(+Problema)// is det.
%
%   El texto de un problema de una especificación.
problema(termino(T)) -->
    [ '~q no es curva(Nombre, Curva, Desde, Hasta, N)'-[T] ].
problema(nombre(N)) -->
    [ 'el nombre ~q no es un átomo de letras'-[N] ].
problema(curva(C)) -->
    [ '~q no es una curva conocida'-[C] ].
problema(extremo(E)) -->
    [ 'el extremo ~q no es una expresión aritmética'-[E] ].
problema(intervalos(N)) -->
    [ 'la cantidad de intervalos ~q no es un entero positivo'-[N] ].
problema(nombre_repetido(N)) -->
    [ 'la curva ~q ya está definida'-[N] ].
