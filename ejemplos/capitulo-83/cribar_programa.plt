:- encoding(utf8).

% Pruebas de cribar_programa.pl: el recorrido sobre un stream, y el
% programa completo ejecutado en otro proceso, con sus argumentos, su
% entrada, su salida y su código de salida.

:- use_module(library(process)).
:- use_module(library(readutil)).

:- begin_tests(cribar_programa).

%!  correr(+Argumentos:list, +Entrada:string, -Salida:list(string),
%!         -Errores:string, -Estado) is det.
%
%   Ejecuta cribar_programa.pl con Argumentos en otro proceso, desde su
%   directorio, y le escribe Entrada en la entrada estándar. Salida son las
%   líneas que escribe; Errores, lo que escribe en la salida de errores;
%   Estado, exit(Codigo).
correr(Argumentos, Entrada, Salida, Errores, Estado) :-
    source_file(user:cribar_stream(_, _, _, _), Programa),
    file_directory_name(Programa, Directorio),
    process_create(path(swipl), [Programa|Argumentos],
                   [ cwd(Directorio), stdin(pipe(In)), stdout(pipe(Out)),
                     stderr(pipe(Err)), process(Pid) ]),
    set_stream(In, encoding(utf8)),
    set_stream(Out, encoding(utf8)),
    set_stream(Err, encoding(utf8)),
    format(In, "~w", [Entrada]),
    close(In),
    read_string(Out, _, Texto),
    read_string(Err, _, Errores),
    close(Out),
    close(Err),
    process_wait(Pid, Estado),
    split_string(Texto, "\n", "\r", Lineas),
    exclude(==(""), Lineas, Salida).

%!  salida_temporal(-Archivo) is det.
%
%   Archivo es el nombre de un archivo temporal que todavía no existe.
salida_temporal(Archivo) :-
    tmp_file(cribar, Archivo).

% --- El recorrido sobre un stream -----------------------------------------

test(cadena, true(S == "a\nc\n")) :-
    cribar_cadena("a\nINICIO\nb\nFIN\nc\n", "INICIO", "FIN", S).

test(cadena_sin_salto_final, true(S == "a\nc\n")) :-
    cribar_cadena("a\nINICIO\nFIN\nc", "INICIO", "FIN", S).

test(cadena_con_retornos, true(S == "a\nc\n")) :-
    cribar_cadena("a\r\nINICIO\r\nb\r\nFIN\r\nc\r\n", "INICIO", "FIN", S).

test(cadena_sin_fin, error(marcas(inicio_sin_fin(2)))) :-
    cribar_cadena("a\nINICIO\nb\n", "INICIO", "FIN", _).

% --- El programa -----------------------------------------------------------

test(tuberia, true(S-E == ["a", "c"]-exit(0))) :-
    correr(['-i', 'INICIO', '-f', 'FIN'], "a\nINICIO\nb\nFIN\nc\n", S, _, E).

test(examen, true(E == exit(0))) :-
    correr(['--inicio=\\solstart', '--fin=\\solend',
            'archivos/examen_soluciones.tex'], "", S, _, E),
    length(S, 11),
    \+ ( member(L, S), sub_string(L, _, _, _, "abuelo(A, N)") ),
    memberchk("\\item ¿Cuántas respuestas tiene \\texttt{member(X, [a, b, a])}?",
              S).

test(a_un_archivo, true(Lineas-E == 11-exit(0))) :-
    salida_temporal(Archivo),
    correr(['-i', '\\solstart', '-f', '\\solend',
            'archivos/examen_soluciones.tex', Archivo], "", [], _, E),
    read_file_to_string(Archivo, Texto, [encoding(utf8)]),
    delete_file(Archivo),
    split_string(Texto, "\n", "", Partes),
    exclude(==(""), Partes, Todas),
    length(Todas, Lineas).

test(marcas_rotas, true(E == exit(2))) :-
    salida_temporal(Archivo),
    correr(['-i', '\\solstart', '-f', '\\solend',
            'archivos/examen_roto.tex', Archivo], "", [], Errores, E),
    once(sub_string(Errores, _, _, _,
               "línea 7: marca de inicio dentro de la sección abierta en la línea 4")),
    \+ exists_file(Archivo).

test(sin_marcas, true(E == exit(1))) :-
    correr(['archivos/examen_soluciones.tex'], "", [], Errores, E),
    once(sub_string(Errores, _, _, _, "Faltan las marcas")).

test(misma_salida, true(E == exit(1))) :-
    correr(['-i', 'x', '-f', 'y', 'archivos/examen_roto.tex',
            'archivos/examen_roto.tex'], "", [], Errores, E),
    once(sub_string(Errores, _, _, _, "es el mismo archivo")),
    source_file(user:cribar_stream(_, _, _, _), Programa),
    file_directory_name(Programa, Directorio),
    directory_file_path(Directorio, 'archivos/examen_roto.tex', Roto),
    size_file(Roto, Bytes),
    Bytes > 0.

test(archivo_inexistente, true(E == exit(2))) :-
    correr(['-i', 'x', '-f', 'y', 'no_existe.tex'], "", [], Errores, E),
    once(sub_string(Errores, _, _, _, "does not exist")).

:- end_tests(cribar_programa).
