:- encoding(utf8).

% Capítulo 78 - Mastermind, versión 2: los códigos que todavía son
% posibles.
%
% La versión 1 busca cada intento desde el primer código y comprueba cada
% candidato contra todas las respuestas. Aquí el programa guarda la lista
% de los códigos que todavía son posibles, como los mundos consistentes
% del capítulo 77: al principio los 5040; después de cada respuesta, solo
% los que la explican, es decir, los que, de ser el secreto, habrían
% recibido esa respuesta. El intento siguiente es el primero de la lista.
% La lista conserva el orden de los códigos, así que los intentos son los
% mismos de la versión 1; cada código se compara con cada respuesta una
% sola vez.
%
% jugar/1 adivina el código que piensa una persona, que escribe las
% respuestas, una por línea, en un stream.
%
% solo-local: es un módulo que carga otro, y lee de un stream.
%
%?- adivinar_candidatos([3, 8, 1, 6], Intentos).
%?- quedan([r([0, 1, 2, 3], 0, 1)], N).

:- module(candidatos,
          [ candidatos/1,
            filtrar/5,
            quedan/2,
            adivinar_candidatos/2,
            jugar/1
          ]).

:- use_module(library(apply)).
:- use_module(library(readutil)).
:- reexport(mastermind).

%!  candidatos(-Codigos:list) is det.
%
%   Codigos son los 5040 códigos, en orden.
candidatos(Codigos) :-
    findall(C, codigo(C), Codigos).

%!  filtrar(+Codigos0:list, +Intento:list, +Toros:integer, +Vacas:integer,
%!          -Codigos:list) is det.
%
%   Codigos son los de Codigos0 que explican la respuesta: si fueran el
%   secreto, Intento habría recibido Toros toros y Vacas vacas.
filtrar(Codigos0, Intento, Toros, Vacas, Codigos) :-
    include(explica(Intento, Toros, Vacas), Codigos0, Codigos).

%!  explica(+Intento:list, +Toros:integer, +Vacas:integer, +Codigo:list)
%!      is semidet.
%
%   Si Codigo fuera el secreto, Intento recibiría Toros toros y Vacas
%   vacas.
explica(Intento, Toros, Vacas, Codigo) :-
    respuesta(Codigo, Intento, Toros, Vacas).

%!  quedan(+Respuestas:list, -N:integer) is det.
%
%   N es la cantidad de códigos que explican todas las Respuestas, una
%   lista de términos r(Intento, Toros, Vacas).
quedan(Respuestas, N) :-
    candidatos(Codigos0),
    foldl(descartar, Respuestas, Codigos0, Codigos),
    length(Codigos, N).

%!  descartar(+Respuesta, +Codigos0:list, -Codigos:list) is det.
%
%   Codigos son los de Codigos0 que explican Respuesta, r(I, T, V).
descartar(r(I, T, V), Codigos0, Codigos) :-
    filtrar(Codigos0, I, T, V, Codigos).

%!  adivinar_candidatos(+Secreto:list, -Intentos:list) is det.
%
%   Intentos son los intentos contra Secreto, hasta el que lo acierta:
%   los mismos que da adivinar/2 de la versión 1.
adivinar_candidatos(Secreto, Intentos) :-
    candidatos(Codigos),
    adivinar_entre(Codigos, Secreto, Intentos).

%!  adivinar_entre(+Codigos:list, +Secreto:list, -Intentos:list) is det.
%
%   Como adivinar_candidatos/2, con Codigos los que todavía son posibles.
%   El primero es el intento; el resto, filtrado por su respuesta, son los
%   posibles de la jugada siguiente.
adivinar_entre([Intento|Codigos0], Secreto, [Intento|Intentos]) :-
    respuesta(Secreto, Intento, T, V),
    (   T =:= 4
    ->  Intentos = []
    ;   filtrar(Codigos0, Intento, T, V, Codigos),
        adivinar_entre(Codigos, Secreto, Intentos)
    ).

% --- Contra una persona -----------------------------------------------------

%!  jugar(+In) is det.
%
%   Adivina el código que piensa una persona. Las respuestas se leen de
%   In, una por línea: los toros y las vacas, separados por un espacio.
jugar(In) :-
    format("Piensa un código de cuatro dígitos distintos.~n"),
    candidatos(Codigos),
    preguntar(Codigos, 1, In).

%!  preguntar(+Codigos:list, +N:integer, +In) is det.
%
%   Propone el intento número N, el primero de Codigos, y sigue con los
%   que explican la respuesta.
preguntar([], _, _) :-
    format("Tus respuestas se contradicen: ningún código las cumple.~n").
preguntar([Intento|Codigos0], N, In) :-
    atomic_list_concat(Intento, ' ', Texto),
    format("Intento ~d: ~w. ¿Toros y vacas? ", [N, Texto]),
    leer_respuesta(In, Leida),
    (   Leida = fin
    ->  format("Partida abandonada.~n")
    ;   Leida = r(4, 0)
    ->  format("Tu código es ~w: encontrado en ~d intentos.~n", [Texto, N])
    ;   Leida = r(T, V),
        filtrar(Codigos0, Intento, T, V, Codigos),
        N1 is N + 1,
        preguntar(Codigos, N1, In)
    ).

%!  leer_respuesta(+In, -Respuesta) is det.
%
%   Respuesta es r(Toros, Vacas), leída de la primera línea de In que es
%   una respuesta posible, o fin si In se termina antes.
leer_respuesta(In, Respuesta) :-
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  nl,
        Respuesta = fin
    ;   format("~w~n", [Linea]),
        split_string(Linea, " ", " ", [A, B]),
        number_string(T, A),
        number_string(V, B),
        posible(T, V)
    ->  Respuesta = r(T, V)
    ;   format("Esa respuesta no es posible. ¿Toros y vacas? "),
        leer_respuesta(In, Respuesta)
    ).

%!  posible(+Toros:integer, +Vacas:integer) is semidet.
%
%   Toros y Vacas pueden ser la respuesta a un intento: no son negativos,
%   suman a lo sumo 4, y no son tres toros y una vaca, que obligaría a
%   cambiar de lugar un solo dígito.
posible(T, V) :-
    integer(T),
    integer(V),
    T >= 0,
    V >= 0,
    T + V =< 4,
    T-V \== 3-1.
