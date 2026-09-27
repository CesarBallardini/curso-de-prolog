:- encoding(utf8).

% Capítulo 28 - Leer del teclado: preguntas con respuestas validadas.
%
% Cada predicado escribe la pregunta en la salida actual y lee la respuesta,
% una línea, del stream In: user_input para el teclado, o un stream sobre una
% cadena en las pruebas. Una respuesta que no sirve se rechaza con un aviso,
% y la pregunta se repite.
%
% solo-local: el sandbox de SWISH no permite leer de la entrada.
%
%?- open_string("tal vez\nS\n", In), preguntar_si_no(In, "¿Seguir?", R).

:- use_module(library(readutil)).

%!  preguntar(+In, +Pregunta:string, -Respuesta:string) is det.
%
%   Escribe Pregunta y lee una línea de In, sin los blancos de los extremos.
%
%   @error existence_error(respuesta, Pregunta) si In se terminó.
preguntar(In, Pregunta, Respuesta) :-
    format("~w ", [Pregunta]),
    flush_output,
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  existence_error(respuesta, Pregunta)
    ;   normalize_space(string(Respuesta), Linea)
    ).

%!  preguntar_si_no(+In, +Pregunta:string, -Respuesta) is det.
%
%   Respuesta es si o no. Acepta s, si, sí, n y no, en mayúsculas o en
%   minúsculas, y repite la pregunta ante cualquier otra respuesta.
preguntar_si_no(In, Pregunta, Respuesta) :-
    format(string(Completa), "~w (s/n)", [Pregunta]),
    preguntar(In, Completa, Texto),
    string_lower(Texto, Minusculas),
    (   si_no(Minusculas, R)
    ->  Respuesta = R
    ;   format("Responder s o n.~n"),
        preguntar_si_no(In, Pregunta, Respuesta)
    ).

%!  si_no(+Texto:string, -Respuesta) is semidet.
%
%   Texto es una forma de responder si o no.
si_no("s",  si).
si_no("si", si).
si_no("sí", si).
si_no("n",  no).
si_no("no", no).

%!  preguntar_numero(+In, +Pregunta:string, +Min:integer, +Max:integer,
%!                   -N:integer) is det.
%
%   N es un entero entre Min y Max, leído de In; la pregunta se repite
%   mientras la respuesta no lo sea.
preguntar_numero(In, Pregunta, Min, Max, N) :-
    format(string(Completa), "~w (~d a ~d)", [Pregunta, Min, Max]),
    preguntar(In, Completa, Texto),
    (   number_string(N0, Texto),
        integer(N0),
        between(Min, Max, N0)
    ->  N = N0
    ;   format("Se espera un entero entre ~d y ~d.~n", [Min, Max]),
        preguntar_numero(In, Pregunta, Min, Max, N)
    ).
