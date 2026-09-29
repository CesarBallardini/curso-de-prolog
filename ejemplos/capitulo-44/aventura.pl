:- encoding(utf8).

% Capítulo 44 - Versión 6 de la aventura: pantalla completa. Es el
% programa terminado.
%
% La pantalla tiene tres recuadros: el lugar, el inventario y los últimos
% mensajes. pantalla/2 es el modelo de pantalla del capítulo 36: da las
% líneas a partir del estado y de los mensajes, sin escribir nada; los
% textos salen de la gramática de respuestas de la versión 4. bucle/2 es
% el único predicado que dibuja y lee. Las órdenes se escriben en la
% última fila y se terminan con Enter, así que se leen por líneas.
%
% solo-local: SWISH no admite módulos propios ni tiene una terminal.
%
%?- iniciar, pantalla([], Lineas).

:- module(aventura,
          [ pantalla/2,
            partir/3,
            bucle/2,
            aventura/1,
            aventura/0
          ]).

:- reexport(juego).
:- use_module('../capitulo-36/texto/pantalla').

% ancho(A): los recuadros tienen A columnas de texto.
ancho(60).

% mensajes_visibles(N): el recuadro de mensajes muestra las últimas N líneas.
mensajes_visibles(8).

%!  aventura is det.
%
%   Juega en la terminal, a pantalla completa.
aventura :-
    aventura(user_input).

%!  aventura(+In) is det.
%
%   Muestra el menú de inicio y juega la partida elegida a pantalla
%   completa, con las líneas que llegan por el stream In.
aventura(In) :-
    opciones_de_inicio(Opciones),
    menu(In, Opciones, Eleccion),
    (   preparar(Eleccion, Texto)
    ->  ancho(Ancho),
        partir(Texto, Ancho, Mensajes),
        bucle(In, Mensajes)
    ;   true
    ).

%!  bucle(+In, +Mensajes:list(string)) is det.
%
%   Dibuja la pantalla con Mensajes, lee una orden de In, la ejecuta y
%   sigue, hasta que la orden es salir, la partida está ganada o In se
%   termina.
bucle(In, Mensajes0) :-
    pantalla(Mensajes0, Lineas),
    dibujar(Lineas),
    length(Lineas, N),
    Fila is N + 1,
    ir_a(Fila, 1),
    format("> "),
    flush_output,
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  Orden = salir,
        Eco = "salir"
    ;   entender(Linea, Orden),
        Eco = Linea
    ),
    responder(Orden, Texto),
    agregar_mensajes(Mensajes0, Eco, Texto, Mensajes),
    (   (   Orden == salir
        ;   ganado
        )
    ->  pantalla(Mensajes, Final),
        dibujar(Final),
        nl
    ;   bucle(In, Mensajes)
    ).

%!  agregar_mensajes(+Mensajes0:list(string), +Orden:string,
%!                   +Texto:string, -Mensajes:list(string)) is det.
%
%   Mensajes son Mensajes0 seguidos del eco de Orden y de Texto partido en
%   líneas, sin pasar de las últimas que se ven.
agregar_mensajes(Mensajes0, Orden, Texto, Mensajes) :-
    ancho(Ancho),
    string_concat("> ", Orden, Eco),
    partir(Texto, Ancho, Nuevas),
    append(Mensajes0, [Eco|Nuevas], Todos),
    mensajes_visibles(Visibles),
    length(Todos, Cantidad),
    Sobran is max(0, Cantidad - Visibles),
    length(Viejos, Sobran),
    append(Viejos, Mensajes, Todos).

%!  pantalla(+Mensajes:list(string), -Lineas:list(string)) is det.
%
%   Lineas es la pantalla: el lugar y el inventario, con los textos de
%   mirar e inventario, y Mensajes, cada uno en su recuadro.
pantalla(Mensajes, Lineas) :-
    ancho(Ancho),
    responder(mirar, Lugar),
    partir(Lugar, Ancho, Lineas1),
    responder(inventario, Inventario),
    partir(Inventario, Ancho, Lineas2),
    maplist(recuadro(Ancho),
            ["Lugar", "Inventario", "Mensajes"],
            [Lineas1, Lineas2, Mensajes],
            Cajas),
    append(Cajas, Lineas).

%!  recuadro(+Ancho:integer, +Titulo:string, +Lineas:list(string),
%!           -Caja:list(string)) is det.
%
%   Caja es el recuadro de Titulo con Lineas, todas completadas con
%   blancos hasta Ancho columnas, para que los recuadros tengan el mismo
%   ancho.
recuadro(Ancho, Titulo, Lineas, Caja) :-
    maplist(completar(Ancho), ["" | Lineas], [Vacia | Completas]),
    (   Completas == []
    ->  caja(Titulo, [Vacia], Caja)
    ;   caja(Titulo, Completas, Caja)
    ).

%!  completar(+Ancho:integer, +Linea:string, -Completa:string) is det.
%
%   Completa es Linea seguida de blancos hasta Ancho columnas.
completar(Ancho, Linea, Completa) :-
    format(string(Completa), "~w~t~*|", [Linea, Ancho]).

%!  partir(+Texto:string, +Ancho:integer, -Lineas:list(string)) is det.
%
%   Lineas son las palabras de Texto repartidas en líneas de Ancho
%   columnas como máximo; una palabra más larga ocupa su propia línea.
partir(Texto, Ancho, Lineas) :-
    split_string(Texto, " ", " ", Partes),
    exclude(==(""), Partes, Palabras),
    (   Palabras = [P|Ps]
    ->  llenar(Ps, P, Ancho, Lineas)
    ;   Lineas = []
    ).

%!  llenar(+Palabras:list(string), +Linea:string, +Ancho:integer,
%!         -Lineas:list(string)) is det.
%
%   Lineas son Linea, completada con las Palabras que entran en Ancho, y
%   las líneas de las palabras que quedan.
llenar([], Linea, _, [Linea]).
llenar([P|Ps], Linea, Ancho, Lineas) :-
    string_length(Linea, L1),
    string_length(P, L2),
    (   L1 + 1 + L2 =< Ancho
    ->  atomics_to_string([Linea, " ", P], Linea1),
        llenar(Ps, Linea1, Ancho, Lineas)
    ;   Lineas = [Linea|Resto],
        llenar(Ps, P, Ancho, Resto)
    ).
