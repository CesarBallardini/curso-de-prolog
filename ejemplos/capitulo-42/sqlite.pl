:- encoding(utf8).

% Capítulo 42 - Prolog y SQL: la base académica en SQLite, con ODBC.
%
% Copia las tablas del módulo base en una base SQLite: las sentencias
% CREATE TABLE se escriben a partir del esquema guardado como hechos, y
% las filas se insertan con una sentencia preparada. Después la base se
% consulta desde Prolog con odbc_query/3 y con sentencias con parámetros.
% El NULL de SQL llega como el átomo null, igual que en los hechos.
%
% solo-local: usa library(odbc) y un controlador ODBC, que SWISH no tiene.
%
% El controlador de SQLite es, en Windows, el de Christian Werner
% (sqliteodbc) y, en Linux, el de los paquetes unixodbc y libsqliteodbc.
%
%?- abrir(':memory:', C), copiar_base(C), alumnos_de(C, civil, N).

:- module(sqlite,
          [ cadena_conexion/2,
            abrir/2,
            sentencia_create/2,
            sentencia_insert/2,
            copiar_base/1,
            fila_hecho/3,
            leer_tabla/3,
            alumnos_de/3
          ]).

:- use_module(library(odbc)).
:- use_module(base).

%!  cadena_conexion(+Archivo, -Cadena) is det.
%
%   Cadena es la cadena de conexión de ODBC para la base SQLite guardada
%   en Archivo (':memory:' es una base en memoria). El controlador se
%   registra con un nombre en Windows y con otro en Linux.
cadena_conexion(Archivo, Cadena) :-
    (   current_prolog_flag(windows, true)
    ->  Controlador = '{SQLite3 ODBC Driver}'
    ;   Controlador = 'SQLite3'
    ),
    format(atom(Cadena), 'DRIVER=~w;Database=~w', [Controlador, Archivo]).

%!  abrir(+Archivo, -Conexion) is det.
%
%   Abre una conexión con la base SQLite de Archivo. NULL se representa
%   con el átomo null, y SQLite verifica las claves foráneas.
abrir(Archivo, Conexion) :-
    cadena_conexion(Archivo, Cadena),
    odbc_driver_connect(Cadena, Conexion, [null(null)]),
    odbc_query(Conexion, 'PRAGMA foreign_keys = ON').

%!  sentencia_create(+Tabla, -SQL) is det.
%
%   SQL es la sentencia CREATE TABLE de Tabla, escrita a partir de sus
%   columnas, su clave, sus referencias y sus rangos.
sentencia_create(Tabla, SQL) :-
    tabla(Tabla, _, Columnas),
    findall(D, definicion(Tabla, Columnas, D), Ds),
    atomic_list_concat(Ds, ', ', Cuerpo),
    format(atom(SQL), 'CREATE TABLE ~w (~w)', [Tabla, Cuerpo]).

%!  definicion(+Tabla, +Columnas, -Definicion) is nondet.
%
%   Definicion es una de las partes de CREATE TABLE para Tabla: una por
%   columna, la clave primaria, una por referencia y una por rango.
definicion(Tabla, Columnas, Definicion) :-
    member(Columna-Tipo, Columnas),
    tipo_sql(Tipo, TipoSQL),
    (   admite_nulo(Tabla, Columna)
    ->  format(atom(Definicion), '~w ~w', [Columna, TipoSQL])
    ;   format(atom(Definicion), '~w ~w NOT NULL', [Columna, TipoSQL])
    ).
definicion(Tabla, _, Definicion) :-
    clave(Tabla, Columnas),
    atomic_list_concat(Columnas, ', ', Lista),
    format(atom(Definicion), 'PRIMARY KEY (~w)', [Lista]).
definicion(Tabla, _, Definicion) :-
    referencia(Tabla, Columna, Referida, ColumnaReferida),
    format(atom(Definicion), 'FOREIGN KEY (~w) REFERENCES ~w (~w)',
           [Columna, Referida, ColumnaReferida]).
definicion(Tabla, _, Definicion) :-
    rango(Tabla, Columna, Min, Max),
    format(atom(Definicion), 'CHECK (~w BETWEEN ~w AND ~w)',
           [Columna, Min, Max]).

% tipo_sql(Tipo, TipoSQL): el tipo de columna en SQL.
tipo_sql(entero, 'INTEGER').
tipo_sql(texto,  'TEXT').

%!  sentencia_insert(+Tabla, -SQL) is det.
%
%   SQL es un INSERT de una fila de Tabla, con un parámetro ? por columna.
sentencia_insert(Tabla, SQL) :-
    tabla(Tabla, _, Columnas),
    findall(?, member(_, Columnas), Marcas),
    atomic_list_concat(Marcas, ', ', Lista),
    format(atom(SQL), 'INSERT INTO ~w VALUES (~w)', [Tabla, Lista]).

%!  copiar_base(+Conexion) is det.
%
%   Crea las tablas del módulo base en la base de Conexion y copia sus
%   filas, las tablas referidas antes que las que se refieren a ellas.
copiar_base(Conexion) :-
    forall(member(Tabla, [alumnos, materias, correlativas, inscripciones]),
           copiar_tabla(Conexion, Tabla)).

%!  copiar_tabla(+Conexion, +Tabla) is det.
%
%   Crea Tabla y le inserta cada fila de los hechos con la misma sentencia
%   preparada: los valores viajan como parámetros, sin escribirlos en SQL.
copiar_tabla(Conexion, Tabla) :-
    sentencia_create(Tabla, Create),
    odbc_query(Conexion, Create),
    sentencia_insert(Tabla, Insert),
    tabla(Tabla, _, Columnas),
    findall(T, ( member(_-Tipo, Columnas), tipo_parametro(Tipo, T) ),
            Tipos),
    setup_call_cleanup(
        odbc_prepare(Conexion, Insert, Tipos, Sentencia),
        forall(fila(Tabla, Fila),
               ( Fila =.. [_|Valores],
                 odbc_execute(Sentencia, Valores) )),
        odbc_free_statement(Sentencia)).

% tipo_parametro(Tipo, Parametro): cómo se declara un parámetro de ese tipo
% en odbc_prepare/4.
tipo_parametro(entero, integer).
tipo_parametro(texto,  varchar(64)).

%!  fila_hecho(+Tabla, +Fila, -Hecho) is det.
%
%   Hecho es el hecho de Tabla con los valores de Fila, un término row/N
%   de odbc_query/3.
fila_hecho(Tabla, Fila, Hecho) :-
    tabla(Tabla, Predicado, _),
    Fila =.. [row|Valores],
    Hecho =.. [Predicado|Valores].

%!  leer_tabla(+Conexion, +Tabla, -Hecho) is nondet.
%
%   Hecho es una fila de Tabla en la base de Conexion, como hecho.
leer_tabla(Conexion, Tabla, Hecho) :-
    tabla(Tabla, _, _),
    format(atom(SQL), 'SELECT * FROM ~w', [Tabla]),
    odbc_query(Conexion, SQL, Fila),
    fila_hecho(Tabla, Fila, Hecho).

%!  alumnos_de(+Conexion, +Carrera, -Nombre) is nondet.
%
%   Nombre es un alumno de Carrera, según la base de Conexion. Carrera
%   viaja como parámetro de una sentencia preparada.
alumnos_de(Conexion, Carrera, Nombre) :-
    setup_call_cleanup(
        odbc_prepare(Conexion,
                     'SELECT nombre FROM alumnos WHERE carrera = ?',
                     [varchar(64)], Sentencia),
        odbc_execute(Sentencia, [Carrera], row(Nombre)),
        odbc_free_statement(Sentencia)).
