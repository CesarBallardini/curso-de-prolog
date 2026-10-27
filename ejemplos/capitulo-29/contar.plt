:- encoding(utf8).

% Pruebas de contar.pl: el núcleo, y el programa completo ejecutado en otro
% proceso, con sus argumentos, su salida y su código de salida.

:- use_module(library(process)).
:- use_module(library(readutil)).

:- begin_tests(contar).

%!  correr(+Argumentos:list, -Salida:list(string), -Errores:string,
%!         -Estado) is det.
%
%   Ejecuta contar.pl con Argumentos en otro proceso, desde su directorio.
%   Salida son las líneas que escribe; Errores, lo que escribe en la salida
%   de errores; Estado, exit(Codigo).
correr(Argumentos, Salida, Errores, Estado) :-
    source_file(user:contar_texto(_, _, _), Programa),
    file_directory_name(Programa, Directorio),
    process_create(path(swipl), [Programa|Argumentos],
                   [ cwd(Directorio), stdout(pipe(Out)), stderr(pipe(Err)),
                     process(Pid) ]),
    read_string(Out, _, Texto),
    read_string(Err, _, Errores),
    close(Out),
    close(Err),
    process_wait(Pid, Estado),
    split_string(Texto, "\n", "\r", Lineas),
    exclude(==(""), Lineas, Salida).

% --- El núcleo -------------------------------------------------------------

test(contar_texto, true(L-P == 2-3)) :-
    contar_texto("uno dos\ntres\n", L, P).

test(texto_vacio, true(L-P == 0-0)) :-
    contar_texto("", L, P).

test(blancos_repetidos, true(L-P == 1-2)) :-
    contar_texto("  uno \t  dos  \n", L, P).

% --- El programa -----------------------------------------------------------

test(dos_archivos, true(S-E == [ "       4       5  archivos/texto.txt",
                                 "       2       4  archivos/otro.txt" ]
                               -exit(0))) :-
    correr(['archivos/texto.txt', 'archivos/otro.txt'], S, _, E).

test(solo_lineas, true(S-E == ["       4  archivos/texto.txt"]-exit(0))) :-
    correr(['-l', 'archivos/texto.txt'], S, _, E).

test(sin_archivos, true(E == exit(1))) :-
    correr([], [], Errores, E),
    once(sub_string(Errores, _, _, _, "Falta el nombre de un archivo")).

test(archivo_inexistente, true(E == exit(2))) :-
    correr(['no_existe.txt'], [], Errores, E),
    once(sub_string(Errores, _, _, _, "does not exist")).

test(opcion_desconocida, true(E == exit(1))) :-
    correr(['--bytes', 'archivos/texto.txt'], [], _, E).

:- end_tests(contar).
