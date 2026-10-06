:- encoding(utf8).

% Capítulo 84 - Versión 1: el registro del servidor como términos.
%
% library(http/http_log) escribe un término request(Id, Instante, Campos)
% al llegar cada pedido y un término completed(Id, Cpu, Bytes, Codigo,
% Estado) al responderlo, y server(Motivo, Instante) al arrancar y al
% detener el servidor. El archivo es una serie de hechos de Prolog.
%
% cargar_hechos/2 lo carga como un programa, en un módulo, y lo consulta
% con las reglas de par_hechos/3 y sin_respuesta_hechos/2. Como
% los números de pedido vuelven a empezar en 1 cada vez que el servidor
% arranca, esas reglas juntan pedidos de una corrida con respuestas de
% otra. leer_registro/3 lee los términos de a uno, como datos, y junta cada
% pedido con su respuesta dentro de cada corrida.
%
% solo-local: lee archivos.
%
%?- leer_registro(registros('2026-10-01.log'), Pedidos, Pendientes).

:- module(registro,
          [ cargar_hechos/2,
            par_hechos/3,
            sin_respuesta_hechos/2,
            leer_registro/3,
            leer_registro/2,
            contar_registro/3,
            paso/4,
            cerrar/2
          ]).

:- use_module(library(apply)).
:- use_module(library(assoc)).
:- use_module(library(lists)).

:- multifile user:file_search_path/2.
:- prolog_load_context(directory, Aqui),
   directory_file_path(Aqui, archivos, Dir),
   asserta(user:file_search_path(registros, Dir)).

%!  cargar_hechos(+Archivo, -Modulo) is det.
%
%   Carga el registro Archivo como un programa, en un módulo propio, Modulo,
%   que se llama como el archivo sin la extensión. Los términos request/3,
%   completed/5 y server/2 se alternan en el archivo, y la carga no avisa
%   por cada uno porque ese aviso se desactiva mientras dura.
cargar_hechos(Archivo, Modulo) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    file_base_name(Ruta, Base),
    file_name_extension(Modulo, _, Base),
    setup_call_cleanup(style_check(-discontiguous),
                       load_files(Modulo:Ruta, []),
                       style_check(+discontiguous)).

%!  par_hechos(+Modulo, ?Id, ?Codigo) is nondet.
%
%   El pedido Id del registro cargado en Modulo tiene una respuesta con
%   Codigo: la regla junta request/3 y completed/5 por el número de pedido.
par_hechos(Modulo, Id, Codigo) :-
    Modulo:request(Id, _, _),
    Modulo:completed(Id, _, _, Codigo, _).

%!  sin_respuesta_hechos(+Modulo, ?Id) is nondet.
%
%   El pedido Id del registro cargado en Modulo no tiene respuesta: la
%   consulta de Triska, request/3 sin completed/5.
sin_respuesta_hechos(Modulo, Id) :-
    Modulo:request(Id, _, _),
    \+ Modulo:completed(Id, _, _, _, _).

%!  leer_registro(+Archivo, -Pedidos:list, -Pendientes:list) is det.
%
%   Pedidos son los pedidos respondidos del registro Archivo, como
%   pedido(Instante, Ip, Metodo, Ruta, Codigo, Cpu), en el orden de las
%   respuestas, y Pendientes los que no tienen respuesta, como
%   pendiente(Instante, Ip, Metodo, Ruta). Lee el archivo como datos, de a
%   un término, y junta cada pedido con su respuesta dentro de la corrida
%   del servidor en la que llegó.
leer_registro(Archivo, Pedidos, Pendientes) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    setup_call_cleanup(open(Ruta, read, In, [encoding(utf8)]),
                       recorrer(In, t, Salida),
                       close(In)),
    partition(es_pedido, Salida, Pedidos, Pendientes).

%!  leer_registro(+Archivo, -Pedidos:list) is det.
%
%   Pedidos son los pedidos respondidos del registro Archivo, ordenados
%   por el instante de llegada.
leer_registro(Archivo, Pedidos) :-
    leer_registro(Archivo, Pedidos0, _),
    msort(Pedidos0, Pedidos).

% es_pedido(T): T es un pedido respondido.
es_pedido(pedido(_, _, _, _, _, _)).

%!  recorrer(+In, +Abiertos, -Salida:list) is det.
%
%   Salida es lo que producen los términos que quedan en In, con Abiertos
%   los pedidos sin respuesta todavía: un assoc del número de pedido.
recorrer(In, Abiertos0, Salida) :-
    read_term(In, Termino, []),
    (   Termino == end_of_file
    ->  cerrar(Abiertos0, Salida)
    ;   paso(Termino, Abiertos0, Abiertos, Producidos),
        append(Producidos, Resto, Salida),
        recorrer(In, Abiertos, Resto)
    ).

%!  paso(+Termino, +Abiertos0, -Abiertos, -Producidos:list) is det.
%
%   Leído Termino con los pedidos Abiertos0 sin respuesta, quedan Abiertos,
%   y se producen los pedidos de la lista Producidos. Un pedido se abre con
%   request/3 y se cierra con el completed/5 de su número; server/2 marca el
%   final de una corrida, y los pedidos abiertos quedan pendientes. Una
%   respuesta sin pedido, de una corrida que empezó antes del archivo, no
%   produce nada.
paso(request(Id, Instante, Campos), A0, A, []) :-
    memberchk(peer(Ip), Campos),
    memberchk(method(Metodo), Campos),
    memberchk(path(Ruta), Campos),
    put_assoc(Id, A0, abierto(Instante, Ip, Metodo, Ruta), A).
paso(completed(Id, Cpu, _, Codigo, _), A0, A, Producidos) :-
    (   del_assoc(Id, A0, abierto(Instante, Ip, Metodo, Ruta), A)
    ->  Producidos = [pedido(Instante, Ip, Metodo, Ruta, Codigo, Cpu)]
    ;   A = A0,
        Producidos = []
    ).
paso(server(_, _), A0, t, Pendientes) :-
    cerrar(A0, Pendientes).

%!  cerrar(+Abiertos, -Pendientes:list) is det.
%
%   Pendientes son los pedidos de Abiertos, que ya no tendrán respuesta,
%   en el orden de sus números.
cerrar(Abiertos, Pendientes) :-
    assoc_to_values(Abiertos, Valores),
    maplist(pendiente, Valores, Pendientes).

% pendiente(Abierto, Pendiente): el pedido abierto, sin respuesta.
pendiente(abierto(Instante, Ip, Metodo, Ruta),
          pendiente(Instante, Ip, Metodo, Ruta)).

%!  contar_registro(+Archivo, -Respondidos:integer, -Pendientes:list) is det.
%
%   Respondidos es la cantidad de pedidos respondidos del registro Archivo,
%   y Pendientes los pedidos sin respuesta, como en leer_registro/3.
contar_registro(Archivo, Respondidos, Pendientes) :-
    leer_registro(Archivo, Pedidos, Pendientes),
    length(Pedidos, Respondidos).
