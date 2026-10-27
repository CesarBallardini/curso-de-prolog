:- encoding(utf8).

% Pruebas de soluciones_contar.pl: la opción --version, en el programa
% ejecutado en otro proceso, y el conteo habitual.

:- use_module(library(process)).
:- use_module(library(readutil)).

:- begin_tests(soluciones_contar).

%!  correr(+Argumentos:list, -Salida:list(string), -Estado) is det.
%
%   Ejecuta soluciones_contar.pl con Argumentos en otro proceso, desde su
%   directorio.
correr(Argumentos, Salida, Estado) :-
    source_file(user:version(_), Programa),
    file_directory_name(Programa, Directorio),
    process_create(path(swipl), [Programa|Argumentos],
                   [ cwd(Directorio), stdout(pipe(Out)), stderr(null),
                     process(Pid) ]),
    read_string(Out, _, Texto),
    close(Out),
    process_wait(Pid, Estado),
    split_string(Texto, "\n", "\r", Lineas),
    exclude(==(""), Lineas, Salida).

test(version, true(S-E == ["contar 1.0.0"]-exit(0))) :-
    correr(['--version'], S, E).

test(version_sin_archivos, true(S == "contar 1.0.0\n")) :-
    with_output_to(string(S), correr([], [version(true)])).

test(cuenta, true(S-E == ["       4       5  archivos/texto.txt"]-exit(0))) :-
    correr(['archivos/texto.txt'], S, E).

test(sin_archivos, true(E == exit(1))) :-
    correr([], _, E).

:- end_tests(soluciones_contar).
