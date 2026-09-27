:- encoding(utf8).

% Pruebas de construir.pl: lo que decide sin construir nada, y una
% construcción real de contar.pl en un directorio temporal, que después se
% ejecuta como se ejecuta en cada sistema.

:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(filesex)).

:- begin_tests(construir).

%!  ejecutar_construido(+Directorio:atom, +Argumentos:list,
%!                      -Salida:list(string), -Estado) is det.
%
%   Ejecuta el contar construido en Directorio, desde el directorio de
%   este capítulo: con swipl -x en Windows, directamente en Linux.
ejecutar_construido(Directorio, Argumentos, Salida, Estado) :-
    ejecutar_programa(Directorio, contar, Argumentos, Salida, Estado).

%!  ejecutar_programa(+Directorio:atom, +Nombre:atom, +Argumentos:list,
%!                    -Salida:list(string), -Estado) is det.
%
%   Ejecuta el programa Nombre construido en Directorio, desde el
%   directorio de este capítulo.
ejecutar_programa(Directorio, Nombre, Argumentos, Salida, Estado) :-
    source_file(user:construir(_, _), Constructor),
    file_directory_name(Constructor, Capitulo),
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
                   [cwd(Capitulo), stdout(pipe(Out)), stderr(null),
                    process(Pid)]),
    read_string(Out, _, Texto),
    close(Out),
    process_wait(Pid, Estado),
    split_string(Texto, "\n", "\r", Lineas),
    exclude(==(""), Lineas, Salida).

test(destino_linux, true(S-A == 'salida/contar'-true)) :-
    destino(unix, 'salida/contar', S, A).

test(destino_windows, true(S-A == 'salida/contar.state'-false)) :-
    destino(windows, 'salida/contar', S, A).

test(lanzador, true(T == "@swipl -x \"%~dp0contar.state\" -- %*\n")) :-
    texto_del_lanzador(contar, T).

% La construcción de verdad: el programa construido cuenta como el fuente.
test(construir_y_ejecutar,
     [ setup(( tmp_file(construido, D), make_directory(D) )),
       cleanup(delete_directory_and_contents(D)),
       true(S-E == ["       4       5  archivos/texto.txt"]-exit(0)) ]) :-
    source_file(user:construir(_, _), Constructor),
    file_directory_name(Constructor, Capitulo),
    directory_file_path(Capitulo, 'contar.pl', Programa),
    with_output_to(string(_), construir(D, Programa)),
    ejecutar_construido(D, ['archivos/texto.txt'], S, E).

% El programa construido conserva sus códigos de salida.
test(construido_sin_argumentos,
     [ setup(( tmp_file(construido, D), make_directory(D) )),
       cleanup(delete_directory_and_contents(D)),
       true(E == exit(1)) ]) :-
    source_file(user:construir(_, _), Constructor),
    file_directory_name(Constructor, Capitulo),
    directory_file_path(Capitulo, 'contar.pl', Programa),
    with_output_to(string(_), construir(D, Programa)),
    ejecutar_construido(D, [], _, E).

% El proyecto: el programa de línea de comandos del capítulo 28, construido,
% responde como el fuente.
test(proyecto,
     [ setup(( tmp_file(construido, D), make_directory(D) )),
       cleanup(delete_directory_and_contents(D)),
       true(S-E == ["Inscriptos: 101, 102, 104, 106."]-exit(0)) ]) :-
    source_file(user:construir(_, _), Constructor),
    file_directory_name(Constructor, Capitulo),
    directory_file_path(Capitulo, 'inscripciones/principal.pl', Programa),
    with_output_to(string(_), construir(D, Programa)),
    ejecutar_programa(D, principal, [listar, logica], S, E).

test(programa_inexistente, throws(construccion(_, exit(1), _))) :-
    tmp_file(construido, D),
    setup_call_cleanup(true,
                       construir(D, 'no_existe.pl'),
                       ( exists_directory(D)
                       -> delete_directory_and_contents(D)
                       ;  true )).

:- end_tests(construir).
