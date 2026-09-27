:- encoding(utf8).

% Capítulo 28 - Procesos externos: ejecutar otro programa y leer su salida.
%
% process_create/3, de library(process), ejecuta un programa en un proceso
% nuevo, sin pasar por el intérprete de comandos del sistema. Los ejemplos
% ejecutan swipl, que está instalado en Windows y en Linux.
%
% solo-local: el sandbox de SWISH no permite crear procesos.
%
%?- version_de_swipl(Version).
%?- salida_de(swipl, ['-g', 'halt(3)'], Salida, Estado).

:- use_module(library(process)).
:- use_module(library(readutil)).

%!  salida_de(+Programa:atom, +Argumentos:list, -Salida:string, -Estado)
%!      is det.
%
%   Ejecuta Programa, que se busca en el PATH, con Argumentos, y espera que
%   termine. Salida es lo que escribió en su salida, y Estado, exit(Codigo)
%   con su código de salida.
%
%   @error existence_error(source_sink, path(Programa)) si Programa no está
%          en el PATH.
salida_de(Programa, Argumentos, Salida, Estado) :-
    setup_call_cleanup(
        process_create(path(Programa), Argumentos,
                       [stdout(pipe(Out)), process(Pid)]),
        read_string(Out, _, Salida),
        close(Out)),
    process_wait(Pid, Estado).

%!  version_de_swipl(-Version:string) is det.
%
%   Version es lo que escribe swipl --version, sin el salto de línea.
version_de_swipl(Version) :-
    salida_de(swipl, ['--version'], Salida, exit(0)),
    normalize_space(string(Version), Salida).

%!  sistema(-Sistema:atom) is det.
%
%   Sistema es windows o unix, el sistema en el que se ejecuta el programa.
sistema(Sistema) :-
    (   current_prolog_flag(windows, true)
    ->  Sistema = windows
    ;   Sistema = unix
    ).
