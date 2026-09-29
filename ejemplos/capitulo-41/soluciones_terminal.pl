:- encoding(utf8).

% Capítulo 41 - Soluciones de los ejercicios 13 y 14, sobre
% tateti_terminal.pl.
%
% jugar_con_o/2 empieza la partida con una jugada de la computadora, que
% juega con x; paso/3 y responder/4 no cambian, porque jugada/4 marca con
% el jugador de turno y la poda busca para el lado que mueve.
% Cambian el comienzo y los mensajes: bucle_para/4, pantalla_para/3 y
% mensaje_para/5 reciben la marca de la persona.
% autojuego/5 juega una partida entera entre dos rivales de la computadora.
%
% solo-local: carga tateti_terminal.pl, que usa un módulo propio y la
% terminal.
%
%?- autojuego(tateti(3), profundidad(9), profundidad(9), Js, R).

:- ensure_loaded(tateti_terminal).

% --- Ejercicio 13: la computadora mueve primero ------------------------------

%!  jugar_con_o(+N:integer, +Rival) is det.
%
%   Juega en la terminal una partida de N por N en la que la computadora
%   mueve primero, con x, y la persona juega con o.
jugar_con_o(N, Rival) :-
    inicio_con_o(N, Rival, Estado),
    con_pantalla(bucle_para(o, get_single_char, Estado, _)).

%!  inicio_con_o(+N:integer, +Rival, -Estado) is det.
%
%   Estado es el de una partida nueva después de la primera jugada de la
%   computadora.
inicio_con_o(N, Rival, e(tateti(N), Rival, P, 1, jugar)) :-
    inicial(tateti(N), P0),
    responder(Rival, tateti(N), P0, P).

%!  bucle_para(+Persona, :Siguiente, +Estado0, -Estado) is det.
%
%   Como bucle/3, con la pantalla de una persona que juega con la marca
%   Persona.
bucle_para(Persona, Siguiente, Estado0, Estado) :-
    pantalla_para(Persona, Estado0, Lineas),
    dibujar(Lineas),
    (   terminado(Estado0)
    ->  Estado = Estado0
    ;   leer_tecla(Siguiente, Tecla),
        paso(Tecla, Estado0, Estado1),
        bucle_para(Persona, Siguiente, Estado1, Estado)
    ).

%!  pantalla_para(+Persona, +Estado, -Lineas:list(string)) is det.
%
%   Como pantalla/2, con los mensajes para una persona que juega con la
%   marca Persona.
pantalla_para(Persona, e(tateti(N), _, pos(Tablero, _), Cursor, Pedido),
              Lineas) :-
    numlist(1, N, Filas),
    maplist(fila_con_cursor(N, Tablero, Cursor), Filas, Dibujo),
    caja("Ta-te-ti", Dibujo, Caja),
    mensaje_para(Persona, tateti(N), pos(Tablero, _), Pedido, Mensaje),
    caja("Estado", [Mensaje], Estado),
    Ayuda = "Flechas: mover  Espacio o cifra: marcar  q: salir",
    append([Caja, Estado, [Ayuda]], Lineas).

%!  mensaje_para(+Persona, +Juego, +Posicion, +Pedido, -Mensaje:string)
%!      is det.
%
%   Como mensaje/4, para una persona que juega con la marca Persona.
mensaje_para(_, _, _, salir, "Partida abandonada.") :-
    !.
mensaje_para(Persona, Juego, Posicion, jugar, Mensaje) :-
    (   fin(Juego, Posicion, Resultado)
    ->  resultado_para(Resultado, Persona, Mensaje)
    ;   upcase_atom(Persona, Marca),
        format(string(Mensaje), "Tu turno: juegas con ~w.", [Marca])
    ).

%!  resultado_para(+Resultado, +Persona, -Mensaje:string) is det.
%
%   Mensaje anuncia Resultado a la persona que juega con Persona.
resultado_para(empate, _, "Empate.").
resultado_para(gana(J), Persona, Mensaje) :-
    (   J == Persona
    ->  Mensaje = "Ganaste."
    ;   Mensaje = "Gana la computadora."
    ).

% --- Ejercicio 14: la computadora contra sí misma ----------------------------

%!  autojuego(+Juego, +RivalX, +RivalO, -Jugadas:list(integer), -Resultado)
%!      is det.
%
%   Jugadas son las de una partida entera de Juego en la que x elige con
%   RivalX y o con RivalO, y Resultado es cómo termina.
autojuego(Juego, RivalX, RivalO, Jugadas, Resultado) :-
    inicial(Juego, P),
    seguir(Juego, RivalX, RivalO, P, Jugadas, Resultado).

%!  seguir(+Juego, +RivalX, +RivalO, +Posicion, -Jugadas:list(integer),
%!         -Resultado) is det.
%
%   Jugadas son las que siguen a Posicion hasta el final de la partida.
seguir(Juego, RivalX, RivalO, P, Jugadas, Resultado) :-
    (   fin(Juego, P, R)
    ->  Jugadas = [],
        Resultado = R
    ;   turno(Juego, P, Lado),
        rival_de(Lado, RivalX, RivalO, Rival),
        responder(Rival, Juego, P, P1),
        jugada(Juego, P, J, P1),
        !,
        Jugadas = [J|Js],
        seguir(Juego, RivalX, RivalO, P1, Js, Resultado)
    ).

% rival_de(Lado, RX, RO, R): elige para Lado el rival R, RX para max y RO
% para min.
rival_de(max, RX, _, RX).
rival_de(min, _, RO, RO).
