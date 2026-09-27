:- encoding(utf8).

% Capítulo 30 - Inscripciones, módulo consola: el programa en la terminal.
%
% responder/2 ejecuta una orden y escribe la respuesta para una persona;
% bucle/1 lee órdenes de un stream hasta salir; codigo_de_salida/2 dice con
% qué código termina el programa después de una orden. Los errores se
% escriben con print_message/2, en la salida de errores; las respuestas, en
% la salida actual, con color si es una terminal.
%
% solo-local: SWISH no admite módulos propios ni lee de la entrada.
%
%?- responder("listar logica", Respuesta).

:- module(consola,
          [ responder/2,
            bucle/1,
            codigo_de_salida/2
          ]).

:- use_module(library(readutil)).
:- use_module(library(ansi_term)).
:- use_module(comandos).
:- use_module(intercambio).

%!  responder(+Orden:text, -Respuesta) is det.
%
%   Ejecuta Orden y escribe su respuesta. Además de los comandos de
%   ejecutar/2, acepta ranking, que escribe el ranking, y ayuda, que
%   escribe las órdenes posibles.
responder(Orden, Respuesta) :-
    normalize_space(string(Texto), Orden),
    (   Texto == "ranking"
    ->  current_output(Salida),
        escribir_ranking(Salida),
        Respuesta = ranking
    ;   Texto == "ayuda"
    ->  escribir_ayuda,
        Respuesta = ayuda
    ;   ejecutar(Texto, Respuesta),
        escribir_respuesta(Respuesta)
    ).

%!  escribir_ayuda is det.
%
%   Escribe las órdenes que entiende responder/2.
escribir_ayuda :-
    forall(member(Linea,
                  [ "inscribir a LEGAJO en MATERIA",
                    "dar de baja a LEGAJO en MATERIA",
                    "listar MATERIA",
                    "promedio de LEGAJO",
                    "ranking",
                    "salir" ]),
           format("  ~w~n", [Linea])).

%!  escribir_respuesta(+Respuesta) is det.
%
%   Escribe Respuesta para una persona: en verde si el pedido se cumplió, en
%   rojo si no. Un error se escribe como un mensaje de error.
escribir_respuesta(error(Formal)) :-
    !,
    print_message(error, error(Formal, _)).
escribir_respuesta(Respuesta) :-
    texto_de_respuesta(Respuesta, Texto),
    codigo_de_salida(Respuesta, Codigo),
    (   Codigo =:= 0
    ->  Color = green
    ;   Color = red
    ),
    ansi_format([fg(Color)], "~w", [Texto]),
    nl.

%!  texto_de_respuesta(+Respuesta, -Texto:string) is det.
%
%   Texto es Respuesta en castellano.
texto_de_respuesta(aceptada, "Inscripción aceptada.").
texto_de_respuesta(baja, "Baja registrada.").
texto_de_respuesta(rechazada(Motivo), Texto) :-
    format(string(Texto), "Rechazada: ~w.", [Motivo]).
texto_de_respuesta(inscriptos([]), "No hay inscriptos.") :-
    !.
texto_de_respuesta(inscriptos(Legajos), Texto) :-
    atomic_list_concat(Legajos, ', ', Lista),
    format(string(Texto), "Inscriptos: ~w.", [Lista]).
texto_de_respuesta(promedio(P), Texto) :-
    format(string(Texto), "Promedio: ~2f.", [P]).
texto_de_respuesta(sin_notas, "El alumno no tiene notas.").
texto_de_respuesta(no_entendido,
                   "No se entiende el pedido; ayuda muestra las órdenes.").

%!  codigo_de_salida(+Respuesta, -Codigo:integer) is det.
%
%   Codigo es el código de salida del programa después de Respuesta: 0 si el
%   pedido se cumplió, 1 si se rechazó o no se entendió, 2 si produjo un
%   error.
codigo_de_salida(rechazada(_), 1) :-
    !.
codigo_de_salida(no_entendido, 1) :-
    !.
codigo_de_salida(error(_), 2) :-
    !.
codigo_de_salida(_, 0).

%!  bucle(+In) is det.
%
%   Lee órdenes de In, una por línea, y responde cada una, hasta leer salir
%   o hasta que In se termine. Las líneas vacías se ignoran.
bucle(In) :-
    format("inscripciones> "),
    flush_output,
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  nl
    ;   normalize_space(string(Orden), Linea),
        (   Orden == "salir"
        ->  true
        ;   Orden == ""
        ->  bucle(In)
        ;   responder(Orden, _),
            bucle(In)
        )
    ).
