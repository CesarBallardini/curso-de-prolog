:- encoding(utf8).

% Capítulo 36 - El tablero del Buscaminas en una página web, como cliente
% del servicio REST del capítulo 31.
%
%     POST /juego          empieza una partida y lleva a su página
%     GET  /juego/{id}     el tablero: un formulario con un botón por celda
%     POST /juego/{id}     la jugada del formulario, y de vuelta al tablero
%
% Estas páginas no cargan el módulo partida: piden y envían JSON al
% servicio, cuya dirección fija usar_servicio/1. cuerpo_tablero/3 arma la
% página a partir de la respuesta del servicio, y es puro.
%
% solo-local: SWISH no admite módulos propios ni permite abrir puertos.
%
%?- iniciar_paginas(Puerto), detener_paginas(Puerto).

:- module(tablero_web,
          [ cuerpo_tablero/3,
            servicio/1,
            usar_servicio/1,
            iniciar_paginas/1,
            detener_paginas/1
          ]).

:- use_module(library(http/http_server)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(http/html_write)).
:- use_module(library(random)).

:- dynamic servicio/1.

% servicio(Base): la dirección base del servicio del Buscaminas.
servicio('http://127.0.0.1:8000').

:- http_handler(root(juego), nuevo_juego, [method(post)]).
:- http_handler(root(juego/Id), juego(Id), [methods([get, post])]).

%!  usar_servicio(+Base:atom) is det.
%
%   Las páginas usan el servicio de la dirección Base.
usar_servicio(Base) :-
    retractall(servicio(_)),
    assertz(servicio(Base)).

%!  iniciar_paginas(?Puerto:integer) is det.
%
%   Arranca el servidor de las páginas en Puerto, o en uno libre.
iniciar_paginas(Puerto) :-
    http_server([port(localhost:Puerto)]).

%!  detener_paginas(+Puerto:integer) is det.
%
%   Detiene el servidor de Puerto.
detener_paginas(Puerto) :-
    http_stop_server(Puerto, []).

%!  nuevo_juego(+Pedido) is det.
%
%   POST /juego: pide al servicio una partida de principiante y redirige a
%   su página.
nuevo_juego(Pedido) :-
    random_between(1, 1000000, Semilla),
    enviar('/partidas', _{filas: 9, columnas: 9, minas: 10, semilla: Semilla},
           Respuesta),
    get_dict(id, Respuesta, Id),
    format(atom(Pagina), "/juego/~w", [Id]),
    http_redirect(see_other, Pagina, Pedido).

%!  juego(+Id:atom, +Pedido) is det.
%
%   GET /juego/Id muestra el tablero; POST /juego/Id envía al servicio la
%   jugada del formulario y redirige al tablero.
juego(Id, Pedido) :-
    memberchk(method(Metodo), Pedido),
    format(atom(Ruta), "/partidas/~w", [Id]),
    (   Metodo == post
    ->  http_parameters(Pedido, [ accion(Accion, [oneof([descubrir, marcar])]),
                                  celda(Celda, [atom]) ]),
        atomic_list_concat([F, C], '-', Celda),
        atom_number(F, Fila),
        atom_number(C, Columna),
        format(atom(RutaJugada), "~w/~w", [Ruta, Accion]),
        enviar(RutaJugada, _{fila: Fila, columna: Columna}, _),
        format(atom(Pagina), "/juego/~w", [Id]),
        http_redirect(see_other, Pagina, Pedido)
    ;   pedir(Ruta, Respuesta),
        cuerpo_tablero(Id, Respuesta, Cuerpo),
        reply_html_page(title('Buscaminas'), Cuerpo)
    ).

%!  pedir(+Ruta:atom, -Respuesta:dict) is det.
%
%   Respuesta es el JSON que el servicio responde a GET Ruta.
pedir(Ruta, Respuesta) :-
    servicio(Base),
    atom_concat(Base, Ruta, Url),
    setup_call_cleanup(http_open(Url, S, []),
                       json_read_dict(S, Respuesta),
                       close(S)).

%!  enviar(+Ruta:atom, +Datos:dict, -Respuesta:dict) is det.
%
%   Respuesta es el JSON que el servicio responde a POST Ruta con Datos.
enviar(Ruta, Datos, Respuesta) :-
    servicio(Base),
    atom_concat(Base, Ruta, Url),
    http_post(Url, json(Datos), Respuesta, [json_object(dict)]).

%!  cuerpo_tablero(+Id, +Respuesta:dict, -Cuerpo) is det.
%
%   Cuerpo es la página de la partida Id, a partir de la Respuesta del
%   servicio: el estado, y un formulario con la acción y un botón por celda
%   oculta; las celdas descubiertas son texto.
cuerpo_tablero(Id, Respuesta, [ h1('Buscaminas'),
                                p(Texto),
                                form([action(Accion), method(post)],
                                     [ p([ label([ input([ type(radio),
                                                           name(accion),
                                                           value(descubrir),
                                                           checked ]),
                                                   ' descubrir ' ]),
                                           label([ input([ type(radio),
                                                           name(accion),
                                                           value(marcar) ]),
                                                   ' marcar' ])
                                         ]),
                                       table(Filas)
                                     ])
                              ]) :-
    _{estado: Estado, minas_restantes: Restantes, tablero: Tablero}
        :< Respuesta,
    format(atom(Accion), "/juego/~w", [Id]),
    texto_de_estado(Estado, Restantes, Texto),
    foldl(fila_html(Estado), Tablero, Filas, 1, _).

%!  texto_de_estado(+Estado:string, +Restantes:integer, -Texto:atom) is det.
%
%   Texto describe el estado de la partida.
texto_de_estado("sigue", Restantes, Texto) :-
    format(atom(Texto), "Minas sin marcar: ~d", [Restantes]).
texto_de_estado("gano", _, 'Partida ganada').
texto_de_estado("perdio", _, 'Partida perdida').

%!  fila_html(+Estado:string, +Fila:string, -Html, +F0:integer,
%!            -F:integer) is det.
%
%   Html es la fila F0 del tablero; F es F0 + 1.
fila_html(Estado, Fila, tr(Celdas), F0, F) :-
    F is F0 + 1,
    string_chars(Fila, Simbolos),
    foldl(celda_html(Estado, F0), Simbolos, Celdas, 1, _).

%!  celda_html(+Estado:string, +F:integer, +Simbolo:char, -Html,
%!             +C0:integer, -C:integer) is det.
%
%   Html muestra la celda F-C0: un botón si está oculta o marcada y la
%   partida sigue, o el símbolo. C es C0 + 1.
celda_html(Estado, F, Simbolo, td(Contenido), C0, C) :-
    C is C0 + 1,
    (   Estado == "sigue",
        memberchk(Simbolo, ['#', 'M'])
    ->  format(atom(Valor), "~d-~d", [F, C0]),
        Contenido = button([type(submit), name(celda), value(Valor)],
                           Simbolo)
    ;   Contenido = Simbolo
    ).
