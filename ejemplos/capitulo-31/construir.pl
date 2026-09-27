:- encoding(utf8).

% Capítulo 31 - Construir un programa en un comando, en Windows y en Linux.
%
%     swipl construir.pl [--salida=DIRECTORIO] -- programa.pl...
%
% El -- es necesario: sin él, swipl carga cada archivo .pl que sigue a
% construir.pl, como si fuera parte del constructor.
%
% Para cada programa, arranca otro swipl con swipl -o Salida -c Programa,
% que lo carga y lo guarda: así en lo guardado solo está el programa, no
% este constructor. En Linux produce un ejecutable autónomo; en Windows, un
% estado guardado, programa.state, y un lanzador, programa.bat, porque los
% antivirus suelen bloquear los ejecutables que produce SWI-Prolog.
%
% solo-local: SWISH no ejecuta procesos ni escribe archivos.
%
%?- destino(unix, 'salida/contar', Salida, Autonomo).

:- use_module(library(main)).
:- use_module(library(process)).
:- use_module(library(filesex)).
:- use_module(library(readutil)).

:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): las opciones del programa.
opt_type(salida, salida, atom).

% opt_help(Clave, Texto): la ayuda de cada opción.
opt_help(salida,      "Directorio de lo construido; por omisión, salida").
opt_help(help(usage), " [--salida=DIRECTORIO] -- programa.pl...").

%!  main(+Argv:list) is det.
%
%   Construye cada programa de Argv y termina con el código 0; con 1 si no
%   recibe ninguno; con 2 si una construcción falla.
main(Argv) :-
    argv_options(Argv, Programas, Opciones),
    option(salida(Directorio), Opciones, salida),
    catch(( construir_todos(Programas, Directorio),
            Codigo = 0 ),
          Error,
          ( print_message(error, Error),
            codigo_de_error(Error, Codigo) )),
    halt(Codigo).

%!  codigo_de_error(+Error, -Codigo:integer) is det.
%
%   Codigo es 1 para un error de uso y 2 para cualquier otro.
codigo_de_error(uso(_), 1) :-
    !.
codigo_de_error(_, 2).

%!  construir_todos(+Programas:list, +Directorio:atom) is det.
%
%   Construye cada uno de Programas en Directorio.
%
%   @error uso(sin_programas) si Programas es la lista vacía.
construir_todos([], _) :-
    throw(uso(sin_programas)).
construir_todos([P|Ps], Directorio) :-
    maplist(construir(Directorio), [P|Ps]).

%!  construir(+Directorio:atom, +Programa:atom) is det.
%
%   Construye Programa en Directorio y escribe lo que construyó. Lo que el
%   swipl que construye escribe en su salida de errores se repite en la
%   propia, o forma parte del error si la construcción falla.
%
%   @error construccion(Programa, Estado, Mensajes) si el swipl que
%          construye no termina con el código 0.
construir(Directorio, Programa) :-
    make_directory_path(Directorio),
    file_base_name(Programa, Archivo),
    file_name_extension(Nombre, _, Archivo),
    directory_file_path(Directorio, Nombre, Base),
    sistema(Sistema),
    destino(Sistema, Base, Salida, Autonomo),
    format(atom(OpcionAutonomo), "--stand_alone=~w", [Autonomo]),
    process_create(path(swipl), ['-q', '-o', Salida, '-c', Programa,
                                 OpcionAutonomo],
                   [stderr(pipe(Err)), process(Pid)]),
    read_string(Err, _, Mensajes),
    close(Err),
    process_wait(Pid, Estado),
    (   Estado == exit(0)
    ->  format(user_error, "~s", [Mensajes])
    ;   throw(construccion(Programa, Estado, Mensajes))
    ),
    lanzador(Sistema, Base, Nombre),
    format("~w -> ~w~n", [Programa, Salida]).

%!  sistema(-Sistema:atom) is det.
%
%   Sistema es windows o unix.
sistema(Sistema) :-
    (   current_prolog_flag(windows, true)
    ->  Sistema = windows
    ;   Sistema = unix
    ).

%!  destino(+Sistema:atom, +Base:atom, -Salida:atom, -Autonomo:boolean)
%!      is det.
%
%   Salida es el archivo que se construye a partir de Base en Sistema, y
%   Autonomo dice si lleva el sistema de Prolog adentro: en Linux, un
%   ejecutable autónomo; en Windows, un estado guardado, Base.state, que se
%   ejecuta con swipl -x.
destino(windows, Base, Salida, false) :-
    atom_concat(Base, '.state', Salida).
destino(unix, Base, Base, true).

%!  lanzador(+Sistema:atom, +Base:atom, +Nombre:atom) is det.
%
%   En Windows, escribe Base.bat, que ejecuta el estado guardado con los
%   argumentos que recibe. En Linux no hace falta.
lanzador(unix, _, _).
lanzador(windows, Base, Nombre) :-
    texto_del_lanzador(Nombre, Texto),
    atom_concat(Base, '.bat', Bat),
    setup_call_cleanup(open(Bat, write, Stream, [encoding(utf8)]),
                       write(Stream, Texto),
                       close(Stream)).

%!  texto_del_lanzador(+Nombre:atom, -Texto:string) is det.
%
%   Texto es el contenido de Nombre.bat: %~dp0 es el directorio del propio
%   .bat, y %* son sus argumentos.
texto_del_lanzador(Nombre, Texto) :-
    format(string(Texto), "@swipl -x \"%~~dp0~w.state\" -- %*~n", [Nombre]).

:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   Los mensajes propios del constructor.
prolog:message(uso(sin_programas)) -->
    [ 'Falta el nombre de un programa (-h para ver la ayuda)' ].
prolog:message(construccion(Programa, Estado, Mensajes)) -->
    [ 'No se pudo construir ~w: swipl terminó con ~w'-[Programa, Estado] ],
    { split_string(Mensajes, "\n", "\r", Lineas0),
      exclude(sin_informacion, Lineas0, Lineas) },
    lineas_del_otro_swipl(Lineas).

%!  sin_informacion(+Linea:string) is semidet.
%
%   Linea no agrega nada al mensaje: está vacía, o repite el código de
%   salida que el mensaje ya informa.
sin_informacion("").
sin_informacion(Linea) :-
    string_concat("Warning: Halting with status", _, Linea).

%!  lineas_del_otro_swipl(+Lineas:list(string))// is det.
%
%   Las líneas de error del swipl que construyó, una por renglón y sin su
%   prefijo ERROR:, que print_message/2 vuelve a agregar.
lineas_del_otro_swipl([]) -->
    [].
lineas_del_otro_swipl([Linea|Lineas]) -->
    { (   string_concat("ERROR: ", Resto, Linea)
      ->  true
      ;   Resto = Linea
      ) },
    [ nl, '~s'-[Resto] ],
    lineas_del_otro_swipl(Lineas).
