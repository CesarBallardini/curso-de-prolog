:- encoding(utf8).

% Capítulo 78 - Partidas entre estrategias, y contra una persona.
%
% Una estrategia es un predicado que recibe el juego y la posición y elige
% una jugada: se pasa como argumento, sin sus tres últimos argumentos, y la
% partida la llama con call/4. profundidad(D) busca con la poda alfa-beta
% del capítulo 41; tiempo(S), con su profundización progresiva; primera
% toma la primera jugada legal. nim:suma, en nim.pl, es la suma de Nim.
%
% partida/6 juega una partida entera entre dos estrategias, sin entrada ni
% salida. jugar/4 juega contra una persona, que es la estrategia persona:
% lee sus jugadas, una por línea, de un stream. Cada juego dice cómo se
% muestra una posición y cómo se lee una jugada con dos predicados
% multifile, pantalla/3 y leer_jugada/4.
%
% solo-local: es un módulo que carga otro, y lee de un stream.
%
%?- partida(nim([1, 2, 3]), primera, nim:suma, Jugadas, Resultado).

:- module(partida,
          [ partida/5,
            partida/6,
            profundidad/4,
            tiempo/4,
            primera/3,
            jugar/4
          ]).

:- use_module(library(readutil)).
:- use_module(capitulo41).

:- multifile
    pantalla/3,
    leer_jugada/4.

:- meta_predicate
    partida(+, 3, 3, -, -),
    partida(+, +, 3, 3, -, -),
    jugar(+, 3, 3, +).

% --- Partidas entre dos estrategias ----------------------------------------

%!  partida(+Juego, :Max, :Min, -Jugadas:list, -Resultado) is det.
%
%   Jugadas es la partida entera de Juego desde su posición inicial, con la
%   estrategia Max para el jugador max y Min para el jugador min, y
%   Resultado, el de fin/3.
partida(Juego, Max, Min, Jugadas, Resultado) :-
    inicial(Juego, Posicion),
    partida(Juego, Posicion, Max, Min, Jugadas, Resultado).

%!  partida(+Juego, +Posicion, :Max, :Min, -Jugadas:list, -Resultado)
%!      is det.
%
%   Como partida/5, desde Posicion.
partida(Juego, Posicion, Max, Min, Jugadas, Resultado) :-
    (   fin(Juego, Posicion, R)
    ->  Jugadas = [],
        Resultado = R
    ;   turno(Juego, Posicion, Lado),
        estrategia(Lado, Max, Min, Estrategia),
        call(Estrategia, Juego, Posicion, Jugada),
        once(jugada(Juego, Posicion, Jugada, Siguiente)),
        Jugadas = [Jugada|Resto],
        partida(Juego, Siguiente, Max, Min, Resto, Resultado)
    ).

% estrategia(Lado, Max, Min, E): E es la estrategia del que juega del Lado.
estrategia(max, Max, _, Max).
estrategia(min, _, Min, Min).

%!  profundidad(+D:integer, +Juego, +Posicion, -Jugada) is det.
%
%   Jugada es la que elige alfabeta/6 del capítulo 41 buscando D jugadas
%   hacia adelante.
profundidad(D, Juego, Posicion, Jugada) :-
    alfabeta(Juego, Posicion, D, Jugada, _, _).

%!  tiempo(+Segundos:number, +Juego, +Posicion, -Jugada) is det.
%
%   Jugada es la que elige profundizar/6 del capítulo 41 en Segundos. Si
%   ni la profundidad 1 termina a tiempo, la primera jugada legal.
tiempo(Segundos, Juego, Posicion, Jugada) :-
    profundizar(Juego, Posicion, Segundos, J, _, _),
    (   J == ninguna
    ->  primera(Juego, Posicion, Jugada)
    ;   Jugada = J
    ).

%!  primera(+Juego, +Posicion, -Jugada) is semidet.
%
%   Jugada es la primera jugada legal de Posicion. Falla si no hay.
primera(Juego, Posicion, Jugada) :-
    once(jugada(Juego, Posicion, Jugada, _)).

% --- Contra una persona -----------------------------------------------------

%!  jugar(+Juego, :Max, :Min, +In) is det.
%
%   Juega Juego mostrando cada posición. Una de las estrategias, o las dos,
%   puede ser persona: sus jugadas se leen de In, una por línea, con
%   leer_jugada/4 del juego. La partida termina al final del juego o al
%   final de In.
jugar(Juego, Max, Min, In) :-
    inicial(Juego, Posicion),
    bucle(Juego, Posicion, Max, Min, In).

%!  bucle(+Juego, +Posicion, :Max, :Min, +In) is det.
%
%   Muestra Posicion y sigue la partida desde ella.
bucle(Juego, Posicion, Max, Min, In) :-
    mostrar(Juego, Posicion),
    (   fin(Juego, Posicion, Resultado)
    ->  anunciar(Juego, Posicion, Resultado, Max, Min)
    ;   turno(Juego, Posicion, Lado),
        estrategia(Lado, Max, Min, Estrategia),
        (   persona(Estrategia)
        ->  pedir(Juego, Posicion, In, Jugada)
        ;   call(Estrategia, Juego, Posicion, Jugada),
            format("La computadora juega ~W.~n",
                   [Jugada, [spacing(next_argument)]])
        ),
        (   Jugada == abandono
        ->  format("Partida abandonada.~n")
        ;   once(jugada(Juego, Posicion, Jugada, Siguiente)),
            bucle(Juego, Siguiente, Max, Min, In)
        )
    ).

%!  mostrar(+Juego, +Posicion) is det.
%
%   Escribe las líneas de pantalla/3 del juego.
mostrar(Juego, Posicion) :-
    pantalla(Juego, Posicion, Lineas),
    forall(member(L, Lineas), format("~w~n", [L])).

%!  pedir(+Juego, +Posicion, +In, -Jugada) is det.
%
%   Jugada es la primera línea de In que leer_jugada/4 traduce a una jugada
%   legal en Posicion, o abandono si In se termina antes.
pedir(Juego, Posicion, In, Jugada) :-
    format("Tu jugada: "),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  nl,
        Jugada = abandono
    ;   format("~w~n", [Linea]),
        leer_jugada(Juego, Posicion, Linea, J),
        jugada(Juego, Posicion, J, _)
    ->  Jugada = J
    ;   format("Esa jugada no es válida.~n"),
        pedir(Juego, Posicion, In, Jugada)
    ).

%!  anunciar(+Juego, +Posicion, +Resultado, :Max, :Min) is det.
%
%   Escribe quién ganó, desde el punto de vista de la persona si una de las
%   dos estrategias es persona.
anunciar(_, Posicion, Resultado, Max, Min) :-
    valor_final(Resultado, Posicion, Valor),
    (   Valor > 0
    ->  ganador(Max, Mensaje)
    ;   Valor < 0
    ->  ganador(Min, Mensaje)
    ;   Mensaje = "Empate."
    ),
    format("~w~n", [Mensaje]).

%!  ganador(:Estrategia, -Mensaje:string) is det.
%
%   Mensaje anuncia la victoria del que juega con Estrategia.
ganador(Estrategia, Mensaje) :-
    (   persona(Estrategia)
    ->  Mensaje = "Ganaste."
    ;   Mensaje = "Gana la computadora."
    ).

%!  persona(:Estrategia) is semidet.
%
%   Estrategia es persona, con el módulo que le agrega meta_predicate/1 o
%   sin él.
persona(Estrategia) :-
    strip_module(Estrategia, _, persona).
