:- encoding(utf8).

% Pruebas de refranes.pl: los hechos que se leen al cargar, y el programa
% construido, que se ejecuta después de borrar el archivo de datos.

:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(filesex)).

:- begin_tests(refranes).

%!  construir_sin_datos(+Directorio:atom, -Programa) is det.
%
%   Copia refranes.pl y sus datos a Directorio, lo construye allí con
%   swipl -c y borra el archivo de datos. Programa es lo que se ejecuta:
%   path(swipl) con el estado en Windows, el ejecutable en Linux.
construir_sin_datos(Directorio, Programa-Prefijo) :-
    source_file(user:cargar_refranes(_), Fuente),
    file_directory_name(Fuente, Capitulo),
    directory_file_path(Directorio, archivos, Datos),
    make_directory_path(Datos),
    directory_file_path(Directorio, 'refranes.pl', Copia),
    copy_file(Fuente, Copia),
    directory_file_path(Capitulo, 'archivos/refranes.txt', Refranes),
    directory_file_path(Datos, 'refranes.txt', CopiaDeRefranes),
    copy_file(Refranes, CopiaDeRefranes),
    (   current_prolog_flag(windows, true)
    ->  directory_file_path(Directorio, 'refranes.state', Salida),
        Autonomo = '--stand_alone=false',
        Programa = path(swipl),
        Prefijo = ['-x', Salida, '--']
    ;   directory_file_path(Directorio, refranes, Salida),
        Autonomo = '--stand_alone=true',
        Programa = Salida,
        Prefijo = []
    ),
    process_create(path(swipl), ['-q', '-o', Salida, '-c', Copia, Autonomo],
                   [stderr(null), process(Pid)]),
    process_wait(Pid, exit(0)),
    delete_file(CopiaDeRefranes).

%!  correr(+Programa, +Argumentos:list, -Salida:list(string), -Estado)
%!      is det.
%
%   Ejecuta el programa construido con Argumentos.
correr(Programa-Prefijo, Argumentos, Salida, Estado) :-
    append(Prefijo, Argumentos, Todos),
    process_create(Programa, Todos,
                   [stdout(pipe(Out)), stderr(null), process(Pid)]),
    read_string(Out, _, Texto),
    close(Out),
    process_wait(Pid, Estado),
    split_string(Texto, "\n", "\r", Lineas),
    exclude(==(""), Lineas, Salida).

test(cargados, true(N == 3)) :-
    aggregate_all(count, refran(_, _), N).

test(refran, true(T == "El que busca encuentra.")) :-
    refran(2, T).

% El programa construido responde sin el archivo: los hechos están adentro.
test(sin_el_archivo, [ setup(( tmp_file(construido, D), make_directory(D) )),
                       cleanup(delete_directory_and_contents(D)),
                       true(S-E == ["El que busca encuentra."]-exit(0)) ]) :-
    construir_sin_datos(D, Programa),
    correr(Programa, ['2'], S, E).

test(numero_inexistente, [ setup(( tmp_file(construido, D),
                                   make_directory(D) )),
                           cleanup(delete_directory_and_contents(D)),
                           true(E == exit(1)) ]) :-
    construir_sin_datos(D, Programa),
    correr(Programa, ['9'], _, E).

:- end_tests(refranes).
