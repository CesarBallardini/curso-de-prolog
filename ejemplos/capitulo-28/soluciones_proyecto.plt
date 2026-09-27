:- encoding(utf8).

% Pruebas de las soluciones de los ejercicios 12 y 13.

:- use_module(library(process)).
:- use_module(library(readutil)).

:- begin_tests(soluciones_proyecto).

%!  correr(+Argumentos:list, +Entrada:string, -Salida:list(string), -Estado)
%!      is det.
%
%   Ejecuta soluciones_proyecto.pl con Argumentos, desde su directorio, con
%   Entrada como teclado. Salida son las líneas que escribe, y Estado,
%   exit(Codigo).
correr(Argumentos, Entrada, Salida, Estado) :-
    source_file(user:bucle_contando(_, _, _), Programa),
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

% Ejercicio 12: la respuesta va al archivo, y la terminal queda vacía.
test(salida, [ setup(( tmp_file(salida, F),
                       atom_concat('--salida=', F, Opcion) )),
               cleanup(delete_file(F)),
               true(S-Texto-E == []-"Inscriptos: 101, 102, 104, 106.\n"
                                 -exit(0)) ]) :-
    correr([Opcion, listar, logica], "", S, E),
    read_file_to_string(F, Texto, [encoding(utf8)]).

% Sin --salida, la respuesta va a la terminal, como en principal.pl.
test(sin_salida, true(S-E == ["Inscriptos: 101, 102, 104, 106."]-exit(0))) :-
    correr([listar, logica], "", S, E).

% Ejercicio 13: dos órdenes; la línea vacía no cuenta. En la última línea, la
% cantidad sigue al indicador, porque la entrada no es una terminal y
% «salir» no se ve.
test(bucle_contando, true(N == 2)) :-
    setup_call_cleanup(
        open_string("listar logica\n\npromedio de 101\nsalir\n", In),
        with_output_to(string(_), bucle_contando(In, 0, N)),
        close(In)).

test(contador_al_salir,
     true(Ultima == "inscripciones> Órdenes ejecutadas: 1.")) :-
    correr([], "listar logica\nsalir\n", S, exit(0)),
    last(S, Ultima).

:- end_tests(soluciones_proyecto).
