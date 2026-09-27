:- encoding(utf8).

% Pruebas de servicio.pl (capítulo 31): el programa se ejecuta en otro
% proceso, como lo ejecuta una persona; la prueba lee de su primera línea la
% dirección, lo llama por HTTP y lo termina.

:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(http/http_open)).
:- use_module(library(http/json)).

:- begin_tests(servicio).

%!  con_servicio(-Base:atom, :Objetivo) is det.
%
%   Ejecuta servicio.pl en otro proceso, liga Base a la dirección que
%   escribe, ejecuta Objetivo y termina el proceso.
con_servicio(Base, Objetivo) :-
    source_file(user:main(_), Programa),
    setup_call_cleanup(
        process_create(path(swipl), ['-q', Programa],
                       [stdout(pipe(Out)), process(Pid)]),
        ( read_line_to_string(Out, Linea),
          % "Inscripciones en http://localhost:P/": la última palabra, sin
          % la barra final.
          split_string(Linea, " ", "/", Palabras),
          last(Palabras, Direccion),
          atom_string(Base, Direccion),
          call(Objetivo) ),
        ( process_kill(Pid),
          process_wait(Pid, _),
          close(Out) )).

test(programa, true(C-Primero == 200-101)) :-
    con_servicio(Base,
                 ( atom_concat(Base, '/ranking', Url),
                   setup_call_cleanup(http_open(Url, S, [status_code(C)]),
                                      json_read_dict(S, [F|_]),
                                      close(S)) )),
    Primero = F.legajo.

:- end_tests(servicio).
