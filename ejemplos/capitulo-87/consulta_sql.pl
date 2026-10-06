:- encoding(utf8).

% Capítulo 87 - La traducción a SQL, ejecutada en SQLite con ODBC.
%
% Abre la base SQLite del capítulo 42 con abrir/2 y copiar_base/1 de
% sqlite.pl, ejecuta la sentencia de sql/2 con odbc_query/3, y convierte
% las filas en una respuesta de la misma forma que evaluar/2: lista/1 con
% las claves, numero/1 o si y no. Así las dos evaluaciones de una misma
% forma lógica, la de Prolog y la de SQLite, se comparan con ==/2.
%
% solo-local: usa library(odbc) y el controlador ODBC de SQLite, como la
% sección 42.7; sin el controlador, sus pruebas quedan bloqueadas.
%
%?- abrir(':memory:', C), copiar_base(C), responder_sql(C, "¿Cuántos aprobaron álgebra?", R).

:- module(consulta_sql,
          [ ejecutar_sql/3,
            responder_sql/3,
            abrir/2,
            copiar_base/1
          ]).

:- if(exists_source(library(odbc))).
:- use_module(library(odbc)).
:- endif.
:- use_module('../capitulo-42/sqlite', [abrir/2, copiar_base/1]).
:- use_module(gramatica).
:- use_module(sql).

%!  responder_sql(+Conexion, +Texto, -Respuesta) is semidet.
%
%   Respuesta responde la pregunta Texto con la base de Conexion: la
%   forma lógica de Texto, traducida a SQL y ejecutada en SQLite.
responder_sql(Conexion, Texto, Respuesta) :-
    analizar(Texto, Forma),
    ejecutar_sql(Conexion, Forma, Respuesta).

%!  ejecutar_sql(+Conexion, +Forma, -Respuesta) is semidet.
%
%   Respuesta es el resultado de la sentencia SQL de Forma en la base de
%   Conexion, en la forma de evaluar/2.
ejecutar_sql(Conexion, Forma, Respuesta) :-
    sql(Forma, Texto),
    atom_string(SQL, Texto),
    findall(Fila, odbc_query(Conexion, SQL, Fila), Filas),
    respuesta_filas(Forma, Filas, Respuesta).

%!  respuesta_filas(+Forma, +Filas:list, -Respuesta) is semidet.
%
%   Respuesta es lo que dicen las Filas del SELECT de Forma.
respuesta_filas(cual(_, _), Filas, lista(Claves)) :-
    findall(Clave, member(row(Clave, _), Filas), Claves).
respuesta_filas(cuantos(_, _), [row(N)], numero(N)).
respuesta_filas(si_no(_), [row(Valor)], Respuesta) :-
    valor_si_no(Valor, Respuesta).

% valor_si_no(Valor, Respuesta): SELECT EXISTS da 1 para sí y 0 para no.
valor_si_no(1, si).
valor_si_no(0, no).
