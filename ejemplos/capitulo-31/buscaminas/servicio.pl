:- encoding(utf8).

% Capítulo 31 - Buscaminas completo, módulo servicio: el juego por HTTP
% (capítulo 30).
%
%     POST /partidas                    {"filas", "columnas", "minas", "semilla"}
%     GET  /partidas/{id}               el estado y el tablero
%     POST /partidas/{id}/descubrir     {"fila", "columna"}
%     POST /partidas/{id}/marcar        {"fila", "columna"}
%     GET  /partidas/{id}/sugerencia    una celda segura, o 404
%
% Todas las rutas empiezan con /partidas, y un solo manejador, con la opción
% prefix, las distingue. Las partidas se guardan en partida_guardada/2; las
% jugadas las reemplazan. Los errores del módulo partida se convierten en
% códigos de estado.
%
% solo-local: SWISH no admite módulos propios ni permite abrir puertos.
%
%?- iniciar_servicio(Puerto, local), detener_servicio(Puerto).

:- module(servicio,
          [ iniciar_servicio/2,
            detener_servicio/1
          ]).

:- use_module(library(http/http_server)).
:- use_module(library(http/http_json)).
:- use_module(partida).

:- dynamic partida_guardada/2, ultima_partida/1.

% ultima_partida(N): el número de la última partida creada.
ultima_partida(0).

:- http_handler(root(partidas), partidas, [prefix, methods([get, post])]).

%!  iniciar_servicio(?Puerto:integer, +Alcance:atom) is det.
%
%   Arranca el servicio en Puerto, o en uno libre. Con Alcance local, solo
%   acepta pedidos de la misma máquina; con publico, de cualquier interfaz.
iniciar_servicio(Puerto, local) :-
    http_server([port(localhost:Puerto)]).
iniciar_servicio(Puerto, publico) :-
    http_server([port(Puerto)]).

%!  detener_servicio(+Puerto:integer) is det.
%
%   Detiene el servicio de Puerto.
detener_servicio(Puerto) :-
    http_stop_server(Puerto, []).

%!  partidas(+Pedido) is det.
%
%   Atiende las rutas que empiezan con /partidas: elige por el método y por
%   las partes del resto de la dirección.
partidas(Pedido) :-
    memberchk(method(Metodo), Pedido),
    (   memberchk(path_info(Resto), Pedido)
    ->  true
    ;   Resto = ''
    ),
    split_string(Resto, "/", "", Partes0),
    exclude(==(""), Partes0, Partes),
    responder(ruta(Metodo, Partes, Pedido)).

%!  ruta(+Metodo:atom, +Partes:list(string), +Pedido) is det.
%
%   Atiende un pedido ya separado en partes.
%
%   @error existence_error(ruta, Partes) si no es ninguna de las rutas.
ruta(post, [], Pedido) :-
    !,
    http_read_json_dict(Pedido, Datos),
    _{filas: F, columnas: C, minas: N, semilla: S} :< Datos,
    nueva_partida(F, C, N, S, Partida),
    with_mutex(partidas, guardar_nueva(Partida, Id)),
    respuesta(Id, Partida, Respuesta),
    reply_json_dict(Respuesta, [status(201)]).
ruta(get, [Texto], _) :-
    !,
    partida_de(Texto, Id, Partida),
    respuesta(Id, Partida, Respuesta),
    reply_json_dict(Respuesta).
ruta(get, [Texto, "sugerencia"], _) :-
    !,
    partida_de(Texto, _, Partida),
    (   sugerencia(Partida, F-C)
    ->  reply_json_dict(_{fila: F, columna: C})
    ;   existence_error(celda_segura, Texto)
    ).
ruta(post, [Texto, Nombre], Pedido) :-
    !,
    atom_string(Accion, Nombre),
    http_read_json_dict(Pedido, Datos),
    _{fila: F, columna: C} :< Datos,
    with_mutex(partidas, jugada(Texto, Accion, F-C, Id, Partida)),
    respuesta(Id, Partida, Respuesta),
    reply_json_dict(Respuesta).
ruta(_, Partes, _) :-
    existence_error(ruta, Partes).

%!  guardar_nueva(+Partida, -Id:integer) is det.
%
%   Guarda Partida con un número nuevo, Id.
guardar_nueva(Partida, Id) :-
    retract(ultima_partida(Anterior)),
    Id is Anterior + 1,
    assertz(ultima_partida(Id)),
    assertz(partida_guardada(Id, Partida)).

%!  jugada(+Texto, +Accion:atom, +Celda:pair, -Id:integer, -Partida) is det.
%
%   Aplica la jugada a la partida de número Texto y guarda la siguiente.
jugada(Texto, Accion, Celda, Id, Partida) :-
    partida_de(Texto, Id, Partida0),
    jugar(Accion, Celda, Partida0, Partida),
    retract(partida_guardada(Id, _)),
    assertz(partida_guardada(Id, Partida)).

%!  partida_de(+Texto:string, -Id:integer, -Partida) is det.
%
%   Partida es la partida guardada con el número Texto.
%
%   @error existence_error(partida, Texto) si no existe.
partida_de(Texto, Id, Partida) :-
    (   number_string(Id, Texto),
        partida_guardada(Id, Partida)
    ->  true
    ;   existence_error(partida, Texto)
    ).

%!  respuesta(+Id:integer, +Partida, -Respuesta:dict) is det.
%
%   Respuesta tiene el número, las dimensiones, el estado, las minas sin
%   marcar y el tablero de Partida, con las minas a la vista si terminó.
respuesta(Id, Partida, _{id: Id, filas: F, columnas: C, estado: Estado,
                         minas_restantes: Restantes, tablero: Filas}) :-
    dimensiones(Partida, F, C),
    estado(Partida, Estado),
    minas_restantes(Partida, Restantes),
    (   Estado == sigue
    ->  Minas = false
    ;   Minas = true
    ),
    filas(Partida, Minas, Filas).

%!  responder(:Objetivo) is det.
%
%   Ejecuta Objetivo, que responde el pedido. Un error de tipo o de dominio
%   responde 400, salvo una acción desconocida, que es una ruta inexistente;
%   uno de existencia, 404; si Objetivo falla, como cuando al cuerpo le
%   falta un campo, 400.
responder(Objetivo) :-
    catch(( Objetivo
          ->  true
          ;   reply_json_dict(_{error: "pedido incompleto"}, [status(400)])
          ),
          error(Formal, _),
          responder_error(Formal)).

%!  responder_error(+Formal) is det.
%
%   Responde el error Formal con su código de estado.
responder_error(Formal) :-
    codigo_de_error(Formal, Codigo),
    !,
    format(string(Texto), "~w", [Formal]),
    reply_json_dict(_{error: Texto}, [status(Codigo)]).
responder_error(Formal) :-
    throw(error(Formal, _)).

%!  codigo_de_error(+Formal, -Codigo:integer) is semidet.
%
%   Codigo es el código de estado de HTTP del error Formal.
codigo_de_error(domain_error(accion, _), 404) :-
    !.
codigo_de_error(type_error(_, _), 400).
codigo_de_error(domain_error(_, _), 400).
codigo_de_error(syntax_error(_), 400).
codigo_de_error(existence_error(_, _), 404).
