:- encoding(utf8).

% Capítulo 37 - Los hilos del servidor HTTP.
%
% http_server/2 atiende cada pedido en uno de sus hilos trabajadores; la
% opción workers(N) fija cuántos son. Este archivo usa la biblioteca
% thread_httpd, cuyo conjunto de trabajadores tiene un tamaño fijo;
% library(http/http_server), la del capítulo 30, le agrega trabajadores
% cuando los pedidos esperan. Dos manejadores cuentan las visitas
% en el hecho dinámico visitas/1: /contar lo lee y lo cambia sin
% protección, y /contar_seguro hace lo mismo con un mutex. /hilo responde
% con el nombre del hilo que atendió el pedido. muchos_pedidos/4 hace
% muchos pedidos a la vez, desde varios hilos clientes.
%
%     GET  /hilo            el hilo trabajador que atiende el pedido
%     POST /contar          suma una visita, sin mutex
%     POST /contar_seguro   suma una visita, con el mutex visitas
%
% solo-local: SWISH no permite abrir puertos ni crear hilos.
%
%?- iniciar(P, 3), muchos_pedidos(P, hilo, 30, Hilos), detener(P).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_open)).
:- use_module(library(http/json)).

:- dynamic visitas/1.

% visitas(N): el servidor recibió N pedidos de /contar o /contar_seguro.
visitas(0).

:- http_handler(root(hilo), hilo, [method(get)]).
:- http_handler(root(contar), contar, [method(post)]).
:- http_handler(root(contar_seguro), contar_seguro, [method(post)]).

%!  iniciar(?Puerto:integer, +Trabajadores:integer) is det.
%
%   Arranca el servidor en Puerto de la máquina local, con Trabajadores
%   hilos que atienden los pedidos. Con Puerto libre, elige uno.
iniciar(Puerto, Trabajadores) :-
    http_server(http_dispatch,
                [ port(localhost:Puerto),
                  workers(Trabajadores) ]).

%!  detener(+Puerto:integer) is det.
%
%   Detiene el servidor de Puerto.
detener(Puerto) :-
    http_stop_server(Puerto, []).

%!  sin_visitas is det.
%
%   Pone en cero el contador de visitas.
sin_visitas :-
    retractall(visitas(_)),
    assertz(visitas(0)).

%!  hilo(+Pedido) is det.
%
%   GET /hilo: el nombre del hilo que atiende el pedido.
hilo(_Pedido) :-
    thread_self(Yo),
    reply_json_dict(_{hilo: Yo}).

%!  contar(+Pedido) is det.
%
%   POST /contar: suma una visita y responde con el total. Dos pedidos
%   atendidos a la vez pueden leer el mismo hecho.
contar(_Pedido) :-
    sumar_visita(N),
    reply_json_dict(_{visitas: N}).

%!  contar_seguro(+Pedido) is det.
%
%   POST /contar_seguro: lo mismo, con el mutex visitas.
contar_seguro(_Pedido) :-
    with_mutex(visitas, sumar_visita(N)),
    reply_json_dict(_{visitas: N}).

%!  sumar_visita(-N:integer) is det.
%
%   Suma uno a visitas/1; N es el valor nuevo.
sumar_visita(N) :-
    retract(visitas(N0)),
    N is N0 + 1,
    assertz(visitas(N)).

%!  pedir(+Puerto:integer, +Ruta:atom, -Codigo:integer, -Respuesta) is det.
%
%   Hace el pedido de Ruta al servidor de Puerto: GET para hilo, POST sin
%   cuerpo para las demás. Codigo es el código de estado y Respuesta el
%   cuerpo, leído como JSON si el código es 200.
pedir(Puerto, Ruta, Codigo, Respuesta) :-
    format(atom(Url), "http://127.0.0.1:~w/~w", [Puerto, Ruta]),
    (   Ruta == hilo
    ->  Opciones = []
    ;   Opciones = [method(post), post(atom(''))]
    ),
    setup_call_cleanup(
        http_open(Url, Entrada, [status_code(Codigo)|Opciones]),
        (   Codigo =:= 200
        ->  json_read_dict(Entrada, Respuesta)
        ;   read_string(Entrada, _, Respuesta)
        ),
        close(Entrada)).

%!  muchos_pedidos(+Puerto:integer, +Ruta:atom, +N:integer, -Codigos)
%!      is det.
%
%   Hace N pedidos de Ruta a la vez, repartidos entre varios hilos clientes.
%   Para hilo, Codigos son los nombres distintos de los trabajadores que
%   respondieron, ordenados; para las demás rutas, los pares Codigo-Veces
%   de los códigos de estado recibidos.
muchos_pedidos(Puerto, Ruta, N, Resultado) :-
    numlist(1, N, Is),
    concurrent_maplist(pedido(Puerto, Ruta), Is, Rs),
    msort(Rs, Ordenados),
    (   Ruta == hilo
    ->  sort(Ordenados, Resultado)
    ;   clumped(Ordenados, Resultado)
    ).

%!  pedido(+Puerto:integer, +Ruta:atom, +I, -R) is det.
%
%   R es el nombre del trabajador que respondió, para hilo, o el código de
%   estado, para las demás rutas.
pedido(Puerto, Ruta, _, R) :-
    pedir(Puerto, Ruta, Codigo, Respuesta),
    (   Ruta == hilo
    ->  R = Respuesta.hilo
    ;   R = Codigo
    ).
