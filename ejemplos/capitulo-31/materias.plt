:- encoding(utf8).

% Pruebas de materias.pl, con la solución del ejercicio 6: el programa
% construido responde sin el archivo JSON.

:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(filesex)).

:- begin_tests(materias).

% copy_file/2, que copia un archivo, se presenta en el capítulo 56.
%!  construir_sin_datos(+Directorio:atom, -Programa) is det.
%
%   Copia materias.pl y su archivo JSON a Directorio, lo construye allí y
%   borra la copia del archivo JSON. Programa es lo que se ejecuta:
%   path(swipl) con el estado en Windows, el ejecutable en Linux, con los
%   argumentos que van antes de los del programa.
construir_sin_datos(Directorio, Programa-Prefijo) :-
    source_file(user:cargar_materias(_), Fuente),
    file_directory_name(Fuente, Capitulo),
    directory_file_path(Directorio, archivos, Datos),
    make_directory_path(Datos),
    directory_file_path(Directorio, 'materias.pl', Copia),
    copy_file(Fuente, Copia),
    directory_file_path(Capitulo, 'archivos/materias.json', Json),
    directory_file_path(Datos, 'materias.json', CopiaDelJson),
    copy_file(Json, CopiaDelJson),
    (   current_prolog_flag(windows, true)
    ->  directory_file_path(Directorio, 'materias.state', Salida),
        Autonomo = '--stand_alone=false',
        Programa = path(swipl),
        Prefijo = ['-x', Salida, '--']
    ;   directory_file_path(Directorio, materias, Salida),
        Autonomo = '--stand_alone=true',
        Programa = Salida,
        Prefijo = []
    ),
    process_create(path(swipl), ['-q', '-o', Salida, '-c', Copia, Autonomo],
                   [stderr(null), process(Pid)]),
    process_wait(Pid, exit(0)),
    delete_file(CopiaDelJson).

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

test(cargadas, true(N == 7)) :-
    aggregate_all(count, materia(_, _, _), N).

test(materia, true(N-A == logica-1)) :-
    materia(log, N, A).

test(sin_el_archivo, [ setup(( tmp_file(construido, D), make_directory(D) )),
                       cleanup(delete_directory_and_contents(D)),
                       true(S-E == ["logica"]-exit(0)) ]) :-
    construir_sin_datos(D, Programa),
    correr(Programa, [log], S, E).

test(codigo_desconocido, [ setup(( tmp_file(construido, D),
                                   make_directory(D) )),
                           cleanup(delete_directory_and_contents(D)),
                           true(E == exit(1)) ]) :-
    construir_sin_datos(D, Programa),
    correr(Programa, [xyz], _, E).

:- end_tests(materias).
