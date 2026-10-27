:- encoding(utf8).

% Pruebas de la solución del ejercicio 1: el núcleo y el programa completo,
% ejecutado en otro proceso.

:- use_module(library(process)).
:- use_module(library(readutil)).

:- begin_tests(soluciones_contar).

%!  correr(+Argumentos:list, -Salida:list(string), -Estado) is det.
%
%   Ejecuta soluciones_contar.pl con Argumentos, desde su directorio.
%   Salida son las líneas que escribe, y Estado, exit(Codigo).
correr(Argumentos, Salida, Estado) :-
    source_file(user:contar_texto(_, _, _, _), Programa),
    file_directory_name(Programa, Directorio),
    process_create(path(swipl), [Programa|Argumentos],
                   [ cwd(Directorio), stdout(pipe(Out)), stderr(null),
                     process(Pid) ]),
    read_string(Out, _, Texto),
    close(Out),
    process_wait(Pid, Estado),
    split_string(Texto, "\n", "\r", Lineas),
    exclude(==(""), Lineas, Salida).

% Una letra con tilde es un carácter, aunque ocupe dos bytes en UTF-8.
test(caracteres, true(C == 13)) :-
    contar_texto("uno dos\ntrés\n", _, _, C).

test(tres_columnas,
     true(S-E == ["       4       5      34  archivos/texto.txt"]-exit(0))) :-
    correr(['archivos/texto.txt'], S, E).

test(solo_caracteres,
     true(S-E == ["      34  archivos/texto.txt"]-exit(0))) :-
    correr(['-c', 'archivos/texto.txt'], S, E).

test(caracteres_largo,
     true(S-E == ["      34  archivos/texto.txt"]-exit(0))) :-
    correr(['--caracteres', 'archivos/texto.txt'], S, E).

:- end_tests(soluciones_contar).
