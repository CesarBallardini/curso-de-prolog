:- encoding(utf8).

% Capítulo 36 - El Buscaminas en una ventana de XPCE, sobre el módulo
% partida del capítulo 31.
%
% Una grilla de botones, uno por celda; un menú Acción elige si un clic
% descubre o marca; el menú Juego empieza una partida nueva en uno de tres
% niveles. Los predicados puros (nivel/4, clic/4, vista/2, rotulo/2) no
% dependen de XPCE y se prueban en cualquier Prolog; los que crean la
% ventana necesitan XPCE, que en Windows está en swipl-win y no en la
% consola swipl.
%
% solo-local: SWISH no tiene XPCE ni admite módulos propios.
%
%?- abrir_buscaminas(principiante).

:- module(buscaminas_xpce,
          [ nivel/4,
            clic/4,
            vista/2,
            rotulo/2,
            ventana_con_partida/2,
            partida_de/2,
            abrir_buscaminas/1
          ]).

:- if(exists_source(library(pce))).
:- use_module(library(pce)).
:- endif.
:- use_module(library(random)).
:- use_module('../../capitulo-31/buscaminas/partida').

% partida_de(Ventana, Partida): la partida que muestra cada ventana abierta.
:- dynamic partida_de/2.

% nivel(Nivel, Filas, Columnas, Minas): los tres niveles del juego.
nivel(principiante,  9,  9, 10).
nivel(intermedio,   16, 16, 40).
nivel(experto,      16, 30, 99).

%!  clic(+Accion:atom, +Celda:pair, +Partida0, -Partida) is det.
%
%   Partida es Partida0 después de un clic con Accion en Celda; un clic en
%   una partida terminada no cambia nada.
clic(Accion, Celda, Partida0, Partida) :-
    (   estado(Partida0, sigue)
    ->  jugar(Accion, Celda, Partida0, Partida)
    ;   Partida = Partida0
    ).

%!  vista(+Partida, -Celdas:list) is det.
%
%   Celdas tiene un término celda(F, C, Etiqueta, Activa) por celda: el
%   texto del botón y si todavía admite clics (on) o no (off).
vista(Partida, Celdas) :-
    estado(Partida, Estado),
    (   Estado == sigue
    ->  Minas = false
    ;   Minas = true
    ),
    filas(Partida, Minas, Filas),
    findall(celda(F, C, Etiqueta, Activa),
            ( nth1(F, Filas, Fila),
              string_chars(Fila, Simbolos),
              nth1(C, Simbolos, Simbolo),
              boton(Simbolo, Etiqueta, Activa) ),
            Celdas).

%!  boton(+Simbolo:char, -Etiqueta:atom, -Activa:atom) is det.
%
%   Etiqueta y Activa muestran en un botón el Simbolo de filas/3.
boton('#', '', on) :-
    !.
boton('M', 'M', on) :-
    !.
boton('.', '', off) :-
    !.
boton(Simbolo, Simbolo, off).

%!  rotulo(+Partida, -Texto:string) is det.
%
%   Texto describe el estado de Partida, para el rótulo de la ventana.
rotulo(Partida, Texto) :-
    estado(Partida, Estado),
    (   Estado == gano
    ->  Texto = "Partida ganada"
    ;   Estado == perdio
    ->  Texto = "Partida perdida"
    ;   minas_restantes(Partida, N),
        format(string(Texto), "Minas sin marcar: ~d", [N])
    ).

%!  abrir_buscaminas(+Nivel:atom) is det.
%
%   Abre una ventana con una partida nueva de Nivel.
abrir_buscaminas(Nivel) :-
    nivel(Nivel, Filas, Columnas, Minas),
    random_between(1, 1000000, Semilla),
    nueva_partida(Filas, Columnas, Minas, Semilla, Partida),
    ventana_con_partida(Partida, Ventana),
    send(Ventana, open).

%!  ventana_con_partida(+Partida, -Ventana) is det.
%
%   Ventana es un frame de XPCE, todavía sin abrir, que muestra Partida:
%   arriba, el diálogo controles, con el menú Juego, la acción y el rótulo;
%   abajo, el diálogo tablero, con un botón por celda.
ventana_con_partida(Partida, Ventana) :-
    new(Ventana, frame('Buscaminas')),
    send(Ventana, append, new(Controles, dialog)),
    send(Controles, name, controles),
    send(Controles, append, new(Barra, menu_bar)),
    send(Barra, append, new(Juego, popup(juego))),
    forall(nivel(Nivel, _, _, _),
           send(Juego, append,
                menu_item(Nivel,
                          message(@(prolog), nuevo, Ventana, Nivel)))),
    send(Juego, append,
         menu_item(salir, message(@(prolog), cerrar, Ventana))),
    send(Controles, append, new(Accion, menu(accion, choice))),
    send_list(Accion, append, [descubrir, marcar]),
    send(Controles, append, label(estado, ''), right),
    send(new(Tablero, dialog), below, Controles),
    send(Tablero, name, tablero),
    dimensiones(Partida, Filas, Columnas),
    forall(( between(1, Filas, F), between(1, Columnas, C) ),
           agregar_boton(Tablero, Ventana, F, C)),
    assertz(partida_de(Ventana, Partida)),
    send(Ventana, done_message, message(@(prolog), cerrar, Ventana)),
    mostrar(Ventana, Partida).

% celda_en_pixeles(Ancho, Alto): el lugar de cada botón en el tablero.
celda_en_pixeles(32, 26).

%!  agregar_boton(+Tablero, +Ventana, +F:integer, +C:integer) is det.
%
%   Agrega a Tablero el botón de la celda F-C, en su lugar de la grilla.
agregar_boton(Tablero, Ventana, F, C) :-
    nombre_de_boton(F, C, Nombre),
    new(B, button(Nombre, message(@(prolog), pulsar, Ventana, F, C), '')),
    celda_en_pixeles(Ancho, Alto),
    X is (C - 1) * Ancho,
    Y is (F - 1) * Alto,
    send(Tablero, display, B, point(X, Y)).

%!  nombre_de_boton(+F:integer, +C:integer, -Nombre:atom) is det.
%
%   Nombre es el nombre del botón de la celda F-C.
nombre_de_boton(F, C, Nombre) :-
    format(atom(Nombre), "c_~d_~d", [F, C]).

%!  pulsar(+Ventana, +F:integer, +C:integer) is det.
%
%   Responde al clic en la celda F-C: aplica clic/4 con la acción elegida
%   en el menú y muestra la partida que resulta.
pulsar(Ventana, F, C) :-
    get(Ventana, member, controles, Controles),
    get(Controles, member, accion, Menu),
    get(Menu, selection, Accion),
    retract(partida_de(Ventana, Partida0)),
    clic(Accion, F-C, Partida0, Partida),
    assertz(partida_de(Ventana, Partida)),
    mostrar(Ventana, Partida).

%!  mostrar(+Ventana, +Partida) is det.
%
%   Pone en los botones y en el rótulo de Ventana lo que dicen vista/2 y
%   rotulo/2. Un cambio de etiqueta devuelve al botón su ancho por omisión,
%   80 píxeles, y por eso el ancho se fija después de la etiqueta.
mostrar(Ventana, Partida) :-
    get(Ventana, member, tablero, Tablero),
    celda_en_pixeles(Ancho0, _),
    Ancho is Ancho0 - 2,
    vista(Partida, Celdas),
    forall(member(celda(F, C, Etiqueta, Activa), Celdas),
           ( nombre_de_boton(F, C, Nombre),
             get(Tablero, member, Nombre, B),
             send(B, label, Etiqueta),
             send(B, width, Ancho),
             send(B, active, Activa) )),
    rotulo(Partida, Texto),
    atom_string(Atomo, Texto),
    get(Ventana, member, controles, Controles),
    get(Controles, member, estado, Rotulo),
    send(Rotulo, selection, Atomo).

%!  nuevo(+Ventana, +Nivel:atom) is det.
%
%   Cierra Ventana y abre otra con una partida nueva de Nivel.
nuevo(Ventana, Nivel) :-
    cerrar(Ventana),
    abrir_buscaminas(Nivel).

%!  cerrar(+Ventana) is det.
%
%   Olvida la partida de Ventana y la cierra.
cerrar(Ventana) :-
    retractall(partida_de(Ventana, _)),
    send(Ventana, destroy).
