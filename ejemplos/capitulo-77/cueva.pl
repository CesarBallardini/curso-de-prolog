:- encoding(utf8).

% Capítulo 77 - Versión 1: «Hunt the Wumpus», el juego de Gregory Yob.
%
% La cueva tiene 20 salas, cada una con tres túneles: los vértices y las
% aristas de un dodecaedro. En dos salas hay pozos sin fondo, en otras dos
% murciélagos gigantes que llevan al jugador a una sala al azar, y en otra
% duerme el wumpus. Desde una sala vecina de un peligro se lo advierte: el
% olor del wumpus, una corriente de aire, el ruido de los murciélagos. El
% jugador se mueve por los túneles o dispara una de sus cinco flechas
% torcidas, que recorre de una a cinco salas; si una sala de la ruta no
% está conectada con aquella en que está la flecha, la flecha toma un
% túnel al azar. Entrar en la sala del wumpus o disparar lo despierta, y
% se mueve a una sala vecina en tres casos de cada cuatro.
%
% El estado de la partida es un término, con el estado del generador de
% azar adentro: jugada/5 es puro, y una partida queda determinada por su
% semilla y sus órdenes. partida/2 lee las órdenes de un stream: el
% teclado en jugar/0, una cadena en las pruebas. Los mensajes al jugador
% le hablan de tú.
%
% solo-local: es un módulo que carga otro, y lee de un stream.
%
%?- nueva_partida(7, E), observacion(E, O).
%?- nueva_partida(7, E0), jugada(mover(2), E0, E, R, Ms).

:- module(cueva,
          [ tunel/2,
            sala/1,
            nueva_partida/2,
            observacion/2,
            jugada/5,
            mensaje_texto/2,
            orden//1,
            partida/2,
            jugar/0
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(dcg/basics)).
:- use_module(azar).

% --- La cueva ---------------------------------------------------------------

% tuneles(S, Vecinas): la sala S tiene túneles hacia las tres Vecinas.
tuneles(1, [2, 5, 8]).
tuneles(2, [1, 3, 10]).
tuneles(3, [2, 4, 12]).
tuneles(4, [3, 5, 14]).
tuneles(5, [1, 4, 6]).
tuneles(6, [5, 7, 15]).
tuneles(7, [6, 8, 17]).
tuneles(8, [1, 7, 9]).
tuneles(9, [8, 10, 18]).
tuneles(10, [2, 9, 11]).
tuneles(11, [10, 12, 19]).
tuneles(12, [3, 11, 13]).
tuneles(13, [12, 14, 20]).
tuneles(14, [4, 13, 15]).
tuneles(15, [6, 14, 16]).
tuneles(16, [15, 17, 20]).
tuneles(17, [7, 16, 18]).
tuneles(18, [9, 17, 19]).
tuneles(19, [11, 18, 20]).
tuneles(20, [13, 16, 19]).

%!  sala(?S) is nondet.
%
%   S es una sala de la cueva, del 1 al 20.
sala(S) :-
    tuneles(S, _).

%!  tunel(?A, ?B) is nondet.
%
%   Hay un túnel de la sala A a la sala B.
tunel(A, B) :-
    tuneles(A, Vecinas),
    member(B, Vecinas).

% --- El estado de la partida ------------------------------------------------

% El estado es j(Jugador, Wumpus, Pozos, Murcielagos, Flechas, Azar): las
% salas del jugador y del wumpus, las listas de salas con pozos y con
% murciélagos, las flechas que quedan y el estado del generador de azar.

%!  nueva_partida(+Semilla:integer, -E) is det.
%
%   E es una partida nueva: el jugador, el wumpus, dos pozos y dos salas
%   con murciélagos en seis salas distintas, elegidas al azar a partir de
%   Semilla, y cinco flechas.
nueva_partida(Semilla, j(J, W, [P1, P2], [M1, M2], 5, S)) :-
    must_be(integer, Semilla),
    numlist(1, 20, Salas),
    elegir_distintos(6, Salas, [J, W, P1, P2, M1, M2], Semilla, S).

%!  observacion(+E, -Observacion) is det.
%
%   Observacion es lo que el jugador sabe en el estado E:
%   obs(Sala, Vecinas, Avisos, Flechas), con Avisos una lista ordenada de
%   wumpus, corriente y murcielagos, uno por cada peligro que hay en una
%   sala vecina.
observacion(j(J, W, Pozos, Murcielagos, Flechas, _),
            obs(J, Vecinas, Avisos, Flechas)) :-
    tuneles(J, Vecinas),
    findall(A,
            ( member(V, Vecinas),
              peligro(V, W, Pozos, Murcielagos, A) ),
            Avisos0),
    sort(Avisos0, Avisos).

%!  peligro(+V, +W, +Pozos:list, +Murcielagos:list, -Aviso) is nondet.
%
%   Aviso es el aviso que da la sala V, con el wumpus en W y los pozos y
%   los murciélagos en las salas de las listas.
peligro(V, V, _, _, wumpus).
peligro(V, _, Pozos, _, corriente) :-
    memberchk(V, Pozos).
peligro(V, _, _, Murcielagos, murcielagos) :-
    memberchk(V, Murcielagos).

% --- Las jugadas ------------------------------------------------------------

%!  jugada(+Orden, +E0, -E, -Resultado, -Mensajes:list) is det.
%
%   Orden, mover(S) o disparar(Ruta), lleva la partida de E0 a E.
%   Resultado es sigue, gana o pierde(Causa); Mensajes son los términos que
%   cuentan lo que pasó, en orden. Una orden imposible deja la partida como
%   estaba, con un mensaje que lo explica.
jugada(mover(S), E0, E, Resultado, Mensajes) :-
    E0 = j(J, _, _, _, _, _),
    (   tunel(J, S)
    ->  entrar(S, E0, E, Resultado, Mensajes)
    ;   E = E0,
        Resultado = sigue,
        Mensajes = [sin_tunel(S)]
    ).
jugada(disparar(Ruta), E0, E, Resultado, Mensajes) :-
    length(Ruta, N),
    (   between(1, 5, N)
    ->  disparar(Ruta, E0, E, Resultado, Mensajes)
    ;   E = E0,
        Resultado = sigue,
        Mensajes = [ruta_invalida]
    ).

%!  entrar(+S, +E0, -E, -Resultado, -Mensajes:list) is det.
%
%   El jugador entra en la sala S. En la sala del wumpus lo despierta; en
%   un pozo cae; con murciélagos, lo llevan a una sala al azar, donde
%   vuelve a entrar.
entrar(S, j(_, W, Pozos, Murcielagos, F, A0), E, Resultado, Mensajes) :-
    (   S == W
    ->  despertar(W, W1, A0, A),
        E = j(S, W1, Pozos, Murcielagos, F, A),
        (   W1 == S
        ->  Resultado = pierde(wumpus),
            Mensajes = [despiertas_wumpus, te_come]
        ;   Resultado = sigue,
            Mensajes = [despiertas_wumpus]
        )
    ;   memberchk(S, Pozos)
    ->  E = j(S, W, Pozos, Murcielagos, F, A0),
        Resultado = pierde(pozo),
        Mensajes = [caes_en_pozo]
    ;   memberchk(S, Murcielagos)
    ->  azar(20, K, A0, A1),
        Destino is K + 1,
        entrar(Destino, j(S, W, Pozos, Murcielagos, F, A1), E, Resultado,
               Mensajes1),
        Mensajes = [murcielagos(Destino)|Mensajes1]
    ;   E = j(S, W, Pozos, Murcielagos, F, A0),
        Resultado = sigue,
        Mensajes = []
    ).

%!  despertar(+W0, -W, +A0, -A) is det.
%
%   El wumpus despierta en W0 y queda en W: en tres casos de cada cuatro
%   pasa por uno de sus tres túneles, elegido al azar; en el cuarto se
%   queda.
despertar(W0, W, A0, A) :-
    azar(4, K, A0, A),
    (   K < 3
    ->  tuneles(W0, Vecinas),
        nth0(K, Vecinas, W)
    ;   W = W0
    ).

%!  disparar(+Ruta:list, +E0, -E, -Resultado, -Mensajes:list) is det.
%
%   El jugador dispara una flecha por las salas de Ruta. Si la flecha
%   falla, el wumpus despierta; la partida se pierde si llega a la sala del
%   jugador o si no quedan flechas.
disparar(Ruta, j(J, W, Pozos, Murcielagos, F0, A0), E, Resultado,
         Mensajes) :-
    F is F0 - 1,
    vuelo(Ruta, J, J, W, A0, A1, Impacto),
    (   Impacto == wumpus
    ->  E = j(J, W, Pozos, Murcielagos, F, A1),
        Resultado = gana,
        Mensajes = [acertaste]
    ;   Impacto == jugador
    ->  E = j(J, W, Pozos, Murcielagos, F, A1),
        Resultado = pierde(flecha),
        Mensajes = [flecha_te_alcanza]
    ;   despertar(W, W1, A1, A),
        E = j(J, W1, Pozos, Murcielagos, F, A),
        (   W1 == J
        ->  Resultado = pierde(wumpus),
            Mensajes = [fallaste, te_come]
        ;   F =:= 0
        ->  Resultado = pierde(sin_flechas),
            Mensajes = [fallaste, sin_flechas]
        ;   Resultado = sigue,
            Mensajes = [fallaste]
        )
    ).

%!  vuelo(+Ruta:list, +Desde, +J, +W, +A0, -A, -Impacto) is det.
%
%   La flecha sale de la sala Desde por las salas de Ruta, con el jugador
%   en J y el wumpus en W. Si una sala de Ruta no está conectada con la
%   sala en que está la flecha, la flecha toma uno de sus túneles al azar.
%   Impacto es wumpus, jugador o nada.
vuelo([], _, _, _, A, A, nada).
vuelo([S|Ruta], Desde, J, W, A0, A, Impacto) :-
    (   tunel(Desde, S)
    ->  Siguiente = S,
        A1 = A0
    ;   tuneles(Desde, Vecinas),
        elegir(Vecinas, Siguiente, A0, A1)
    ),
    (   Siguiente == W
    ->  Impacto = wumpus,
        A = A1
    ;   Siguiente == J
    ->  Impacto = jugador,
        A = A1
    ;   vuelo(Ruta, Siguiente, J, W, A1, A, Impacto)
    ).

% --- Los textos -------------------------------------------------------------

%!  mensaje_texto(+Mensaje, -Texto:string) is det.
%
%   Texto es lo que se le dice al jugador por Mensaje: un mensaje de una
%   jugada, una observación obs/4 o el resultado final.
mensaje_texto(obs(S, [A, B, C], Avisos, _), Texto) :-
    maplist(aviso_texto, Avisos, Lineas),
    format(string(Sala),
           "Estás en la sala ~w. Hay túneles hacia las salas ~w, ~w y ~w.",
           [S, A, B, C]),
    atomic_list_concat([Sala|Lineas], '\n', Atomo),
    atom_string(Atomo, Texto).
mensaje_texto(sin_tunel(S), Texto) :-
    format(string(Texto), "No hay un túnel hacia la sala ~w.", [S]).
mensaje_texto(ruta_invalida,
              "La flecha recorre de una a cinco salas.").
mensaje_texto(no_entiendo, Texto) :-
    format(string(Texto), "~w ~w",
           [ "No entiendo. Escribe m y una sala para moverte,",
             "o d y de una a cinco salas para disparar."
           ]).
mensaje_texto(murcielagos(S), Texto) :-
    format(string(Texto),
           "¡Un murciélago gigante te lleva a la sala ~w!", [S]).
mensaje_texto(despiertas_wumpus, "¡Despiertas al wumpus!").
mensaje_texto(te_come, "El wumpus te come. Pierdes.").
mensaje_texto(caes_en_pozo, "Caes en un pozo sin fondo. Pierdes.").
mensaje_texto(acertaste, "¡Tu flecha alcanza al wumpus! Ganas.").
mensaje_texto(flecha_te_alcanza, "Tu propia flecha te alcanza. Pierdes.").
mensaje_texto(fallaste, "La flecha no alcanza a nadie.").
mensaje_texto(sin_flechas, "Te quedaste sin flechas. Pierdes.").

%!  aviso_texto(+Aviso, -Texto:string) is det.
%
%   Texto es la advertencia de un peligro en una sala vecina.
aviso_texto(wumpus, "Sientes el olor del wumpus.").
aviso_texto(corriente, "Sientes una corriente de aire.").
aviso_texto(murcielagos, "Oyes murciélagos cerca.").

% --- Las órdenes y el bucle del juego ---------------------------------------

%!  orden(-Orden)// is semidet.
%
%   Una orden escrita: m o mover y una sala, o d o disparar y de una a
%   cinco salas, separadas por espacios.
orden(mover(S)) -->
    blanks, verbo(mover), blank, blanks, integer(S), blanks.
orden(disparar(Ruta)) -->
    blanks, verbo(disparar), salas(Ruta), blanks.

% verbo(V): las palabras que nombran la acción V.
verbo(mover) --> "mover".
verbo(mover) --> "m".
verbo(disparar) --> "disparar".
verbo(disparar) --> "d".

%!  salas(-Salas:list)// is nondet.
%
%   Una o más salas, cada una precedida de espacios.
salas([S|Ss]) -->
    blank, blanks, integer(S),
    (   salas(Ss)
    ;   { Ss = [] }
    ).

%!  partida(+In, +Semilla:integer) is det.
%
%   Juega una partida nueva con Semilla, con las órdenes que llegan, una
%   por línea, por el stream In, hasta que la partida termina o la entrada
%   se acaba.
partida(In, Semilla) :-
    nueva_partida(Semilla, E),
    bucle(In, E).

%!  bucle(+In, +E) is det.
%
%   Muestra lo que el jugador observa en E, escribe el indicador > y lee
%   una orden, que juega.
bucle(In, E0) :-
    observacion(E0, Obs),
    escribir(Obs),
    format("> "),
    flush_output,
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  true
    ;   string_codes(Linea, Codigos),
        phrase(orden(Orden), Codigos)
    ->  jugada(Orden, E0, E, Resultado, Mensajes),
        maplist(escribir, Mensajes),
        (   Resultado == sigue
        ->  bucle(In, E)
        ;   true
        )
    ;   escribir(no_entiendo),
        bucle(In, E0)
    ).

%!  escribir(+Mensaje) is det.
%
%   Escribe el texto de Mensaje en una línea.
escribir(Mensaje) :-
    mensaje_texto(Mensaje, Texto),
    format("~s~n", [Texto]).

%!  jugar is det.
%
%   Juega en la terminal una partida con una semilla tomada del reloj.
jugar :-
    get_time(T),
    Semilla is truncate(T * 1000) mod 2147483648,
    partida(user_input, Semilla).
