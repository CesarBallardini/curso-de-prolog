:- encoding(utf8).

% Pruebas de principal.pl (capítulo 30): el programa completo, ejecutado en
% otro proceso con sus argumentos, como lo ejecuta una persona.

:- use_module(library(process)).
:- use_module(library(readutil)).

:- begin_tests(principal).

%!  correr(+Argumentos:list, +Entrada:string, -Salida:list(string), -Estado)
%!      is det.
%
%   Ejecuta principal.pl con Argumentos, desde su directorio, y le da
%   Entrada como teclado. Salida son las líneas que escribe, y Estado,
%   exit(Codigo).
correr(Argumentos, Entrada, Salida, Estado) :-
    source_file(user:main(_), Programa),
    file_directory_name(Programa, Directorio),
    process_create(path(swipl), [Programa|Argumentos],
                   [ cwd(Directorio), stdin(pipe(In)), stdout(pipe(Out)),
                     stderr(null), process(Pid) ]),
    format(In, "~s", [Entrada]),
    close(In),
    read_string(Out, _, Texto),
    close(Out),
    process_wait(Pid, Estado),
    split_string(Texto, "\n", "\r", Lineas),
    exclude(==(""), Lineas, Salida).

test(listar, true(S-E == ["Inscriptos: 101, 102, 104, 106."]-exit(0))) :-
    correr([listar, logica], "", S, E).

test(rechazada, true(S-E == ["Rechazada: sin_vacantes."]-exit(1))) :-
    correr([inscribir, a, '105', en, logica], "", S, E).

test(ajustes, true(S-E == ["Rechazada: falta(log)."]-exit(1))) :-
    correr(['--ajustes=../archivos/ajustes.cfg',
            inscribir, a, '102', en, paradigmas], "", S, E).

test(ajustes_inexistentes, true(E == exit(2))) :-
    correr(['--ajustes=no_existe.cfg', ranking], "", _, E).

% Con --estado, la inscripción de una ejecución se ve en la siguiente.
test(estado, [ setup(( tmp_file(estado, F),
                       atom_concat('--estado=', F, Opcion) )),
               cleanup(delete_file(F)),
               true(S == ["Inscriptos: 104."]) ]) :-
    correr([Opcion, inscribir, a, '104', en, sintaxis], "", _, exit(0)),
    correr([Opcion, listar, sintaxis], "", S, exit(0)).

% Sin orden, el programa lee las órdenes del teclado.
test(bucle, true(S-E == [ "inscripciones> Promedio: 8.50.",
                          "inscripciones> " ]-exit(0))) :-
    correr([], "promedio de 101\nsalir\n", S, E).

:- end_tests(principal).
