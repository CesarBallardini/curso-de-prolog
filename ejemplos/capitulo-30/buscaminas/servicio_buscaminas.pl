:- encoding(utf8).

% Capítulo 30 - Solución del ejercicio 14: el Buscaminas como servicio.
%
% Ofrece por HTTP las reglas de buscaminas.pl, sin cambiarlas. Cada partida
% tiene un número y se guarda en partida/2; las jugadas la reemplazan por la
% partida siguiente. Las respuestas llevan el estado y el tablero, un texto
% por fila; las minas se ven cuando la partida terminó.
%
% Las rutas comparten el comienzo /partidas, y un solo manejador, con la
% opción prefix, las distingue por el resto de la dirección: en SWI-Prolog
% 9.2.9, dos rutas con partes variables y el mismo comienzo fijo, como
% partidas/Id y partidas/Id/Accion, se quedan con las opciones de la última
% que se declaró.
%
%     POST /partidas                   {"filas", "columnas", "minas", "semilla"}
%     GET  /partidas/{id}              el estado y el tablero
%     POST /partidas/{id}/descubrir    {"fila", "columna"}
%     POST /partidas/{id}/marcar       {"fila", "columna"}
%
% solo-local: SWISH no admite módulos propios ni permite abrir puertos.
%
%?- iniciar_buscaminas(Puerto), detener_buscaminas(Puerto).
%
% thread_get_message/1 y with_mutex/2: los presenta el capítulo 37, con los
% hilos.

:- use_module(library(http/http_server)).
:- use_module(library(http/http_json)).
:- use_module(library(error)).
:- use_module(buscaminas).

:- meta_predicate responder(0).

:- dynamic partida/2, ultima_partida/1.

% ultima_partida(N): el número de la última partida creada.
ultima_partida(0).

:- http_handler(root(partidas), partidas, [prefix, methods([get, post])]).

%!  partidas(+Pedido) is det.
%
%   Atiende todas las rutas que empiezan con /partidas: separa el resto de
%   la dirección en partes y elige la ruta por el método y las partes.
partidas(Pedido) :-
    memberchk(method(Metodo), Pedido),
    (   memberchk(path_info(Resto), Pedido)
    ->  true
    ;   Resto = ''
    ),
    split_string(Resto, "/", "", Partes0),
    exclude(==(""), Partes0, Partes),
    ruta(Metodo, Partes, Pedido).

%!  ruta(+Metodo:atom, +Partes:list(string), +Pedido) is det.
%
%   Atiende el pedido de Metodo a /partidas seguido de Partes; 404 si no
%   es ninguna de las rutas del servicio.
ruta(post, [], Pedido) :-
    !,
    crear(Pedido).
ruta(get, [Id], Pedido) :-
    !,
    consultar(Id, Pedido).
ruta(post, [Id, Accion], Pedido) :-
    !,
    jugar(Id, Accion, Pedido).
ruta(_, _, _) :-
    reply_json_dict(_{error: "ruta inexistente"}, [status(404)]).

%!  crear(+Pedido) is det.
%
%   POST /partidas: crea una partida con minas al azar y responde 201 con
%   su número, sus dimensiones, su estado y su tablero.
crear(Pedido) :-
    responder(( http_read_json_dict(Pedido, Datos),
                _{filas: F, columnas: C, minas: N, semilla: S} :< Datos,
                maplist(must_be(positive_integer), [F, C, N]),
                must_be(integer, S),
                partida_al_azar_py(F, C, N, S, prolog(Juego)),
                with_mutex(partidas, nueva_partida(Juego, Id)),
                respuesta(Id, Juego, sigue, Respuesta0),
                put_dict(_{filas: F, columnas: C}, Respuesta0, Respuesta),
                reply_json_dict(Respuesta, [status(201)]) )).

%!  consultar(+Texto:string, +Pedido) is det.
%
%   GET /partidas/Id: el estado y el tablero de la partida; 404 si no
%   existe.
consultar(Texto, _Pedido) :-
    responder(( partida_de(Texto, Id, estado(Juego, Estado)),
                respuesta(Id, Juego, Estado, Respuesta),
                reply_json_dict(Respuesta) )).

%!  jugar(+Texto:string, +Accion:string, +Pedido) is det.
%
%   POST /partidas/Id/descubrir o /marcar, con la fila y la columna: aplica
%   la jugada y responde el estado y el tablero. 400 si la celda está fuera
%   del tablero o la partida terminó; 404 si no existe la partida o la
%   acción.
jugar(Texto, Nombre, Pedido) :-
    responder(( accion(Nombre, Accion),
                http_read_json_dict(Pedido, Datos),
                _{fila: F, columna: C} :< Datos,
                with_mutex(partidas,
                           jugada(Texto, Accion, F, C, Id, Juego, Estado)),
                respuesta(Id, Juego, Estado, Respuesta),
                reply_json_dict(Respuesta) )).

%!  accion(+Nombre:string, -Accion:atom) is det.
%
%   Accion es descubrir o marcar, la acción que nombra Nombre.
%
%   @error existence_error(accion, Nombre) si no es ninguna de las dos.
accion(Nombre, Accion) :-
    (   atom_string(Accion, Nombre),
        memberchk(Accion, [descubrir, marcar])
    ->  true
    ;   existence_error(accion, Nombre)
    ).

%!  jugada(+Texto, +Accion, +F, +C, -Id, -Juego, -Estado) is det.
%
%   Aplica la jugada a la partida de número Texto y la guarda.
%
%   @error domain_error(partida_en_curso, Id) si la partida terminó.
%   @error domain_error(celda_del_tablero, F-C) si la celda no existe.
jugada(Texto, Accion, F, C, Id, Juego, Estado) :-
    partida_de(Texto, Id, estado(Juego0, Estado0)),
    (   Estado0 == sigue
    ->  true
    ;   domain_error(partida_en_curso, Id)
    ),
    jugar_py(Juego0, Accion, F, C, prolog(Juego), Estado),
    (   Estado == fuera
    ->  domain_error(celda_del_tablero, F-C)
    ;   retract(partida(Id, _)),
        assertz(partida(Id, estado(Juego, Estado)))
    ).

%!  nueva_partida(+Juego, -Id:integer) is det.
%
%   Guarda Juego con un número nuevo, Id.
nueva_partida(Juego, Id) :-
    retract(ultima_partida(Anterior)),
    Id is Anterior + 1,
    assertz(ultima_partida(Id)),
    assertz(partida(Id, estado(Juego, sigue))).

%!  partida_de(+Texto:string, -Id:integer, -Partida) is det.
%
%   Partida es la partida de número Texto.
%
%   @error existence_error(partida, Texto) si no existe.
partida_de(Texto, Id, Partida) :-
    (   number_string(Id, Texto),
        partida(Id, Partida)
    ->  true
    ;   existence_error(partida, Texto)
    ).

%!  respuesta(+Id:integer, +Juego, +Estado:atom, -Respuesta:dict) is det.
%
%   Respuesta tiene el número, el estado y el tablero de la partida, con las
%   minas a la vista si terminó.
respuesta(Id, Juego, Estado, _{id: Id, estado: Estado, tablero: Filas}) :-
    (   Estado == sigue
    ->  Minas = @(false)
    ;   Minas = @(true)
    ),
    filas_py(Juego, Minas, Filas).

%!  responder(:Objetivo) is det.
%
%   Ejecuta Objetivo, que responde el pedido: un error de tipo o de dominio
%   responde 400; uno de existencia, 404; si Objetivo falla, como cuando al
%   cuerpo le falta un campo, 400.
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
codigo_de_error(type_error(_, _), 400).
codigo_de_error(domain_error(_, _), 400).
codigo_de_error(syntax_error(_), 400).
codigo_de_error(existence_error(_, _), 404).

%!  iniciar_buscaminas(?Puerto:integer) is det.
%
%   Arranca el servicio en Puerto de la máquina local, o en uno libre.
iniciar_buscaminas(Puerto) :-
    http_server([port(localhost:Puerto)]).

%!  detener_buscaminas(+Puerto:integer) is det.
%
%   Detiene el servicio de Puerto.
detener_buscaminas(Puerto) :-
    http_stop_server(Puerto, []).

% --- El programa -----------------------------------------------------------

:- use_module(library(main)).
:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): las opciones del programa.
opt_type(puerto, puerto, nonneg).

% opt_help(Clave, Texto): la ayuda de cada opción.
opt_help(puerto, "Puerto del servicio; sin la opción, uno libre").

%!  main(+Argv:list) is det.
%
%   swipl servicio_buscaminas.pl [--puerto=N]: arranca el servicio, escribe
%   su dirección y atiende pedidos hasta que el proceso termina.
main(Argv) :-
    argv_options(Argv, _, Opciones),
    option(puerto(Puerto), Opciones, _),
    iniciar_buscaminas(Puerto),
    format("Buscaminas en http://localhost:~w/~n", [Puerto]),
    flush_output,
    thread_get_message(_).
