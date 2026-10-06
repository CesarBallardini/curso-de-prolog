:- encoding(utf8).

% Capítulo 84 - Versión 2: el formato común, una línea de texto por pedido.
%
% Los servidores web escriben sus registros en el formato común (Common Log
% Format): el cliente, dos campos de identidad, la fecha entre corchetes, la
% línea del pedido entre comillas, el código de la respuesta y los bytes.
% Una gramática traduce cada línea al mismo término pedido/6 de la
% versión 1, con sin_medir en lugar del tiempo de CPU, que el formato no
% registra. El archivo se lee de a una línea, con un paso por línea, como
% el filtro del capítulo 83; una línea que la gramática no reconoce no
% detiene la lectura: queda como defectuosa(N, Linea), con su número.
%
% solo-local: lee archivos y carga registro.pl.
%
%?- leer_comun(registros('2026-10-01-comun.log'), Pedidos, Defectuosas).

:- module(comun,
          [ leer_comun/3,
            paso_comun/3,
            linea//1,
            comparar/4,
            contar_comun/3,
            diferencias/4
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(readutil)).
:- use_module(library(dcg/basics)).
:- reexport(registro).

%!  leer_comun(+Archivo, -Pedidos:list, -Defectuosas:list) is det.
%
%   Pedidos son los pedidos del registro Archivo, escrito en el formato
%   común, como pedido(Instante, Ip, Metodo, Ruta, Codigo, sin_medir), y
%   Defectuosas las líneas que no tienen ese formato, como
%   defectuosa(N, Linea), con N el número de la línea.
leer_comun(Archivo, Pedidos, Defectuosas) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    setup_call_cleanup(open(Ruta, read, In, [encoding(utf8)]),
                       recorrer_comun(In, 1, Salida),
                       close(In)),
    partition(es_pedido, Salida, Pedidos, Defectuosas).

% es_pedido(T): T es un pedido.
es_pedido(pedido(_, _, _, _, _, _)).

%!  recorrer_comun(+In, +N:integer, -Salida:list) is det.
%
%   Salida es lo que producen las líneas que quedan en In, con la próxima
%   numerada N.
recorrer_comun(In, N, Salida) :-
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  Salida = []
    ;   paso_comun(N, Linea, Producidos),
        append(Producidos, Resto, Salida),
        N1 is N + 1,
        recorrer_comun(In, N1, Resto)
    ).

%!  paso_comun(+N:integer, +Linea:string, -Producidos:list) is det.
%
%   Producidos es la lista con el pedido de la línea N, Linea, o con
%   defectuosa(N, Linea) si la línea no tiene el formato común.
paso_comun(N, Linea, Producidos) :-
    string_codes(Linea, Codigos),
    (   phrase(linea(Pedido), Codigos)
    ->  Producidos = [Pedido]
    ;   Producidos = [defectuosa(N, Linea)]
    ).

%!  linea(-Pedido)// is semidet.
%
%   Una línea del formato común: Ip, dos campos que no se usan, [Fecha],
%   "METODO Ruta HTTP/Version", el código de la respuesta y los bytes.
linea(pedido(Instante, Ip, Metodo, Ruta, Codigo, sin_medir)) -->
    ip(Ip), " ", campo, " ", campo, " [", fecha(Instante), "] \"",
    metodo(Metodo), " ", ruta(Ruta), " HTTP/", version, "\" ",
    integer(Codigo), " ", bytes, eos.

% ip(Ip)//: cuatro enteros separados por puntos.
ip(ip(A, B, C, D)) -->
    integer(A), ".", integer(B), ".", integer(C), ".", integer(D).

% campo//: un guion o una palabra sin blancos.
campo -->
    nonblanks(Cs),
    { Cs \== [] }.

%!  fecha(-Instante:float)// is semidet.
%
%   Dia/Mes/Anio:Hora:Minuto:Segundo Zona, con el mes en tres letras en
%   inglés y la zona como +HHMM o -HHMM. Instante es el instante Unix.
fecha(Instante) -->
    integer(D), "/", mes(M), "/", integer(A), ":",
    integer(H), ":", integer(Mi), ":", integer(S), " ", zona(Zona),
    { date_time_stamp(date(A, M, D, H, Mi, S, Zona, -, -), Instante) }.

% mes(M)//: el nombre del mes M en tres letras.
mes(M) -->
    [C1, C2, C3],
    { atom_codes(Nombre, [C1, C2, C3]),
      numero_de_mes(Nombre, M) }.

% numero_de_mes(Nombre, M): el mes de Nombre, en inglés, es el M.
numero_de_mes('Jan', 1).
numero_de_mes('Feb', 2).
numero_de_mes('Mar', 3).
numero_de_mes('Apr', 4).
numero_de_mes('May', 5).
numero_de_mes('Jun', 6).
numero_de_mes('Jul', 7).
numero_de_mes('Aug', 8).
numero_de_mes('Sep', 9).
numero_de_mes('Oct', 10).
numero_de_mes('Nov', 11).
numero_de_mes('Dec', 12).

% zona(Z)//: -HHMM o +HHMM; Z son los segundos al oeste de UTC, como en
% date/9.
zona(Z) -->
    [C], digits([H1, H2, M1, M2]),
    { signo(C, S),
      number_codes(H, [H1, H2]),
      number_codes(M, [M1, M2]),
      Z is S * (H * 3600 + M * 60) }.

% signo(C, S): el signo de una zona, de código C, es S: 1 al oeste de UTC
% y -1 al este.
signo(0'-, 1).
signo(0'+, -1).

% metodo(M)//: el método en mayúsculas; M en minúsculas, como en http_log.
metodo(M) -->
    mayusculas(Cs),
    { Cs \== [],
      atom_codes(Mayus, Cs),
      downcase_atom(Mayus, M) }.

% mayusculas(Cs)//: cero o más letras mayúsculas.
mayusculas([C|Cs]) -->
    [C],
    { code_type(C, upper) },
    !,
    mayusculas(Cs).
mayusculas([]) -->
    [].

% ruta(R)//: la ruta, hasta el primer blanco.
ruta(R) -->
    nonblanks(Cs),
    { Cs \== [],
      atom_codes(R, Cs) }.

% version//: la versión de HTTP, como 1.1.
version -->
    integer(_), ".", integer(_).

% bytes//: la cantidad de bytes, o un guion si no hubo cuerpo.
bytes -->
    integer(_),
    !.
bytes -->
    "-".

%!  comparar(+Comun:list, +Registro:list, -Faltan:list, -Sobran:list)
%!      is det.
%
%   Faltan son los pedidos de Registro, leídos con la versión 1, que no
%   están en Comun, y Sobran los de Comun que no están en Registro. Se
%   comparan el segundo del instante, el cliente, el método, la ruta y el
%   código.
comparar(Comun, Registro, Faltan, Sobran) :-
    maplist(clave, Comun, C0),
    maplist(clave, Registro, R0),
    msort(C0, C),
    msort(R0, R),
    ord_subtract(R, C, Faltan),
    ord_subtract(C, R, Sobran).

% clave(Pedido, Clave): lo que el formato común registra de un pedido.
clave(pedido(T, Ip, M, R, Codigo, _), clave(S, Ip, M, R, Codigo)) :-
    S is truncate(T).

%!  contar_comun(+Archivo, -N:integer, -Defectuosas:list) is det.
%
%   N es la cantidad de pedidos del registro Archivo, en el formato común,
%   y Defectuosas sus líneas defectuosas, como en leer_comun/3.
contar_comun(Archivo, N, Defectuosas) :-
    leer_comun(Archivo, Pedidos, Defectuosas),
    length(Pedidos, N).

%!  diferencias(+Comun, +Registro, -Faltan:list, -Sobran:list) is det.
%
%   comparar/4 entre los pedidos del archivo Comun, en el formato común, y
%   los del archivo Registro, en el formato de http_log.
diferencias(Comun, Registro, Faltan, Sobran) :-
    leer_comun(Comun, PedidosComun, _),
    leer_registro(Registro, PedidosRegistro),
    comparar(PedidosComun, PedidosRegistro, Faltan, Sobran).
