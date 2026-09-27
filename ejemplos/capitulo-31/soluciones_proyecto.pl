:- encoding(utf8).

% Capítulo 31 - Solución del ejercicio 11: ejecutar el programa del
% proyecto construido, como lo ejecuta cada sistema.
%
% Carga construir.pl, para construir con él y ejecutar lo construido con
% destino/4. La prueba, en soluciones_proyecto.plt, construye principal.pl
% y lo ejecuta dos veces con el mismo archivo de estado.
%
% solo-local: SWISH no ejecuta procesos ni escribe archivos.
%
%?- ejecutar_construido(salida, principal, [listar, logica], Salida, E).

:- ensure_loaded(construir).
:- use_module(library(process)).
:- use_module(library(readutil)).

%!  ejecutar_construido(+Directorio:atom, +Nombre:atom, +Argumentos:list,
%!                      -Salida:list(string), -Estado) is det.
%
%   Ejecuta el programa Nombre construido en Directorio con Argumentos:
%   con swipl -x en Windows, directamente en Linux. Salida son las líneas
%   que escribe, y Estado, exit(Codigo).
ejecutar_construido(Directorio, Nombre, Argumentos, Salida, Estado) :-
    sistema(Sistema),
    destino(Sistema, Nombre, Archivo, _),
    directory_file_path(Directorio, Archivo, Construido),
    (   Sistema == windows
    ->  Programa = path(swipl),
        Todos = ['-x', Construido, '--'|Argumentos]
    ;   Programa = Construido,
        Todos = Argumentos
    ),
    process_create(Programa, Todos,
                   [stdout(pipe(Out)), stderr(null), process(Pid)]),
    read_string(Out, _, Texto),
    close(Out),
    process_wait(Pid, Estado),
    split_string(Texto, "\n", "\r", Lineas),
    exclude(==(""), Lineas, Salida).
