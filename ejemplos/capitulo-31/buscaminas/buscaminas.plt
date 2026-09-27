:- encoding(utf8).

% Pruebas del programa completo, ejecutado en otro proceso como lo ejecuta
% una persona: el juego en la terminal, con las jugadas en la entrada, y el
% servicio, que se llama por HTTP.

:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/json)).

:- begin_tests(buscaminas).

%!  jugar_programa(+Argumentos:list, +Jugadas:string, -Estado) is det.
%
%   Ejecuta buscaminas.pl con Argumentos y Jugadas como teclado; Estado es
%   exit(Codigo).
jugar_programa(Argumentos, Jugadas, Estado) :-
    source_file(user:correr(_, _, _), Programa),
    process_create(path(swipl), [Programa|Argumentos],
                   [ stdin(pipe(In)), stdout(null), stderr(null),
                     process(Pid) ]),
    format(In, "~s", [Jugadas]),
    close(In),
    process_wait(Pid, Estado).

% Con la semilla 42, la mina de un 2 x 2 con 1 está en 1-1.
test(ganar, true(E == exit(0))) :-
    jugar_programa(['--semilla=42', '2', '2', '1'], "d 1 2\nd 2 1\nd 2 2\n", E).

test(perder, true(E == exit(1))) :-
    jugar_programa(['--semilla=42', '2', '2', '1'], "d 1 1\n", E).

test(uso, true(E == exit(2))) :-
    jugar_programa(['2', '2'], "", E).

test(demasiadas_minas, true(E == exit(2))) :-
    jugar_programa(['2', '2', '9'], "", E).

% El programa como servicio: arranca, escribe su dirección, y responde.
test(servicio, true(C == 201)) :-
    source_file(user:correr(_, _, _), Programa),
    setup_call_cleanup(
        process_create(path(swipl), ['-q', Programa, '--servicio'],
                       [stdout(pipe(Out)), process(Pid)]),
        ( read_line_to_string(Out, Linea),
          split_string(Linea, " ", "/", Palabras),
          last(Palabras, Direccion),
          atom_concat(Direccion, '/partidas', Url),
          http_post(Url, json(_{filas: 3, columnas: 3, minas: 1, semilla: 1}),
                    _, [status_code(C)]) ),
        ( process_kill(Pid),
          process_wait(Pid, _),
          close(Out) )).

:- end_tests(buscaminas).
