:- encoding(utf8).

% Capítulo 56 - Versión 4: el plan sobre una carpeta real.
%
% leer_modelo/2 recorre una carpeta del disco y construye el modelo que
% espera el planificador de la versión 3. ejecutar_plan/6 realiza las
% acciones del plan con los predicados de archivos de SWI-Prolog, o, en
% modo simulación, solo las describe. Cada ruta se resuelve dentro de la
% carpeta de trabajo, y una ruta que queda fuera provoca un error antes de
% tocar el disco. Antes de borrar pregunta; los programas se ejecutan con
% salida_de/4, del capítulo 28. crear_muestra/2 hace lo inverso de
% leer_modelo/2: escribe un modelo en una carpeta, para las pruebas.
%
% solo-local: lee y escribe archivos y crea procesos, y carga otros
% archivos con ensure_loaded/1.

:- ensure_loaded(plan).
:- ensure_loaded('../capitulo-28/procesos').
:- use_module(library(filesex)).
:- use_module(library(readutil)).

% Otros archivos pueden agregar maneras de realizar acciones nuevas.
:- multifile realizar/6.

%!  leer_modelo(+Raiz, -Modelo:list) is det.
%
%   Modelo son las carpetas y los archivos que hay debajo de la carpeta
%   Raiz, ordenados, con rutas relativas a Raiz. La fecha de un archivo es
%   la de su última modificación, en la zona horaria local.
leer_modelo(Raiz, Modelo) :-
    findall(E, entrada(Raiz, ".", E), Es),
    msort(Es, Modelo).

%!  entrada(+Raiz, +Rel:string, -E) is nondet.
%
%   E es una carpeta o un archivo que está debajo de la carpeta Rel.
entrada(Raiz, Rel, E) :-
    ruta_real(Raiz, Rel, Dir),
    directory_files(Dir, Nombres),
    member(N0, Nombres),
    \+ memberchk(N0, ['.', '..']),
    atom_string(N0, N),
    dentro(Rel, N, R),
    directory_file_path(Dir, N0, Abs),
    (   exists_directory(Abs)
    ->  (   E = carpeta(R)
        ;   entrada(Raiz, R, E)
        )
    ;   size_file(Abs, B),
        time_file(Abs, T),
        format_time(string(F), '%F', T),
        E = archivo(R, B, F)
    ).

%!  ruta_real(+Raiz, +R:string, -Abs:atom) is det.
%
%   Abs es la ruta absoluta de R dentro de la carpeta Raiz.
%
%   @error permission_error(acceder, ruta, R) si Abs queda fuera de Raiz.
ruta_real(Raiz, R, Abs) :-
    absolute_file_name(Raiz, RaizAbs, [file_type(directory)]),
    absolute_file_name(R, Abs, [relative_to(RaizAbs)]),
    atom_concat(RaizAbs, '/', Prefijo),
    (   (   Abs == RaizAbs
        ;   sub_atom(Abs, 0, _, _, Prefijo)
        )
    ->  true
    ;   permission_error(acceder, ruta, R)
    ).

%!  ejecutar_plan(+Modo, +Raiz, +Plan:list, +Leer, +Salida,
%!                -Resultados:list) is det.
%
%   Resultados dice qué pasó con cada acción de Plan sobre la carpeta Raiz.
%   Modo es real o simulacion; en simulación ninguna acción modifica el
%   disco ni ejecuta programas. Las confirmaciones se preguntan en Salida;
%   la respuesta es la línea L de call(Leer, L), por ejemplo
%   read_line_to_string(Entrada).
ejecutar_plan(Modo, Raiz, Plan, Leer, Out, Resultados) :-
    maplist(realizar(Modo, Raiz, Leer, Out), Plan, Resultados).

%!  realizar(+Modo, +Raiz, +Leer, +Salida, +Accion, -Resultado) is det.
%
%   Resultado dice qué pasó al realizar Accion.
realizar(_, _, _, _, informar(Hecho), Hecho) :-
    !.
realizar(_, _, _, _, rechazo(Motivo), rechazo(Motivo)) :-
    !.
realizar(_, _, _, _, salir, salir) :-
    !.
realizar(simulacion, _, _, _, Accion, simulada(Accion)) :-
    !.
realizar(real, Raiz, _, _, copiar(R, D), copiado(R, D)) :-
    ruta_real(Raiz, R, De),
    ruta_real(Raiz, D, A),
    copy_file(De, A).
realizar(real, Raiz, _, _, mover(R, D), movido(R, D)) :-
    ruta_real(Raiz, R, De),
    ruta_real(Raiz, D, A),
    rename_file(De, A).
realizar(real, Raiz, Leer, Out, borrar(R), Resultado) :-
    ruta_real(Raiz, R, Abs),
    format(Out, "¿Quieres borrar ~s? (s/n) ", [R]),
    flush_output(Out),
    call(Leer, Respuesta),
    (   afirmativa(Respuesta)
    ->  delete_file(Abs),
        Resultado = borrado(R)
    ;   Resultado = conservado(R)
    ).
realizar(real, Raiz, _, _, ejecutar(R), salida(R, Estado, Lineas)) :-
    ruta_real(Raiz, R, Abs),
    salida_de(swipl, ['-t', halt, Abs], Texto, Estado),
    split_string(Texto, "\n", "\r", Lineas0),
    exclude(==(""), Lineas0, Lineas).

%!  afirmativa(+Respuesta) is semidet.
%
%   Respuesta es una línea que empieza con s: «s», «si», «sí».
afirmativa(Respuesta) :-
    string(Respuesta),
    string_lower(Respuesta, R),
    sub_string(R, 0, 1, _, "s").

%!  crear_muestra(+Raiz, +Modelo:list) is det.
%
%   Crea en la carpeta Raiz, que debe existir, las carpetas y los archivos
%   de Modelo, con su tamaño y su fecha (a las 12:00 UTC). Un archivo .pl
%   en el que cabe un programa corto es un programa que escribe una línea.
crear_muestra(Raiz, Modelo) :-
    forall(member(carpeta(C), Modelo),
           ( ruta_real(Raiz, C, Abs),
             make_directory_path(Abs) )),
    forall(member(archivo(R, B, F), Modelo),
           crear_archivo(Raiz, R, B, F)).

%!  crear_archivo(+Raiz, +R:string, +Bytes:integer, +Fecha:string) is det.
%
%   Escribe el archivo R de Bytes bytes con fecha de modificación Fecha.
crear_archivo(Raiz, R, Bytes, Fecha) :-
    ruta_real(Raiz, R, Abs),
    contenido(R, Bytes, Texto),
    setup_call_cleanup(open(Abs, write, S, [newline(posix)]),
                       write(S, Texto),
                       close(S)),
    split_string(Fecha, "-", "", Partes),
    maplist(number_string, [A, M, D], Partes),
    date_time_stamp(date(A, M, D, 12, 0, 0, 0, -, -), Stamp),
    set_time_file(Abs, [], [modified(Stamp)]).

%!  contenido(+R:string, +Bytes:integer, -Texto:string) is det.
%
%   Texto tiene Bytes caracteres: un programa que escribe «Hola desde R»,
%   completado con un comentario, si R es un .pl en el que el programa
%   cabe, y una fila de x si no.
contenido(R, Bytes, Texto) :-
    format(string(Programa), "~s~n~s~s~s~n",
           [ ":- initialization(main, main).",
             "main :- writeln('Hola desde ", R, "')." ]),
    string_length(Programa, L),
    (   string_concat(_, ".pl", R),
        Bytes - L >= 2
    ->  Relleno is Bytes - L - 2,
        format(string(Texto), "~s%~*c~n", [Programa, Relleno, 0'x])
    ;   format(string(Texto), "~*c", [Bytes, 0'x])
    ).
