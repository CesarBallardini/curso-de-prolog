# La base en SQLite

Esta página contiene la sección [42.7](index.md#427-libraryodbc-la-base-en-sqlite) del
[capítulo 42](index.md): la base académica copiada en SQLite y consultada
desde Prolog con `library(odbc)`. Los ejemplos están en `base.pl` y
`sqlite.pl`, en `ejemplos/capitulo-42/`, con sus pruebas; necesitan el
controlador ODBC de SQLite y no corren en SWISH.

## La base en SQLite

ODBC es una interfaz estándar para comunicarse con bases de datos a través de
un controlador por cada sistema. `library(odbc)` de SWI-Prolog la usa, y
con el controlador de SQLite un programa Prolog crea, llena y consulta una
base SQLite. SWISH no tiene ODBC: los dos archivos de esta sección corren
solo en una instalación local, y necesitan el controlador:

- **Linux** (Debian, Ubuntu): los paquetes `unixodbc` y `libsqliteodbc`, y
  `library(odbc)`, que en Ubuntu está en `swi-prolog-odbc` y no en
  `swi-prolog-nox`. El controlador se registra con el nombre `SQLite3`.
- **Windows**: el controlador de Christian Werner, `sqliteodbc_w64.exe`,
  de [www.ch-werner.de/sqliteodbc](http://www.ch-werner.de/sqliteodbc/), que se registra como
  `SQLite3 ODBC Driver`. `library(odbc)` viene con SWI-Prolog. Los pasos
  de la instalación están en [El controlador ODBC en
  Windows](#el-controlador-odbc-en-windows).

Las pruebas de esta sección se ejecutaron el 2026-09-28 en Linux, con la
imagen `swipl:9.2.9` y esos paquetes; en Windows, sin el controlador, se
bloquean y avisan por qué.

**La base como módulo.** `base.pl` es un módulo que incluye `universidad.pl`
y exporta las tablas, el esquema y las actualizaciones:

<!-- ejemplo: capitulo-42/base.pl archivo -->
```prolog
:- module(base,
          [ alumno/4,
            materia/3,
            correlativa/2,
            inscripcion/3,
            tabla/3,
            clave/2,
            referencia/4,
            admite_nulo/2,
            rango/4,
            fila/2,
            aprobada/3,
            violacion/1,
            insertar/1,
            borrar/1,
            poner_nota/3
          ]).

:- include(universidad).
```

**Crear la base.** `sqlite.pl` escribe cada `CREATE TABLE` a partir del
esquema, con la misma información que `schema.sql`:

<!-- ejemplo: capitulo-42/sqlite.pl predicado: sentencia_create/2 definicion/3 -->
```prolog
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
```

```prolog
?- sentencia_create(alumnos, S).
S = 'CREATE TABLE alumnos (legajo INTEGER NOT NULL, nombre TEXT NOT NULL, carrera TEXT NOT NULL, ingreso INTEGER NOT NULL, PRIMARY KEY (legajo))'.
```

La conexión se abre con `odbc_driver_connect/3`, con una cadena que nombra
el controlador y el archivo de la base (`:memory:` es una base en memoria).
La opción `null(null)` hace que el `NULL` de SQL llegue a Prolog como el
átomo `null`, el mismo de los hechos; sin ella llegaría como `'$null$'`.
SQLite verifica las claves foráneas solo si se le pide con un `PRAGMA`:

<!-- ejemplo: capitulo-42/sqlite.pl predicado: cadena_conexion/2 abrir/2 -->
```prolog
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
```

Las filas se insertan con una **sentencia preparada**: `odbc_prepare/4`
compila un `INSERT` con un parámetro `?` por columna, y `odbc_execute/2` lo
ejecuta con los valores de cada hecho. Los valores viajan como parámetros,
sin escribirse dentro del texto SQL, así que un nombre con un apóstrofo no
rompe la sentencia, y un texto no puede inyectar otra sentencia.

<!-- ejemplo: capitulo-42/sqlite.pl predicado: copiar_tabla/2 -->
```prolog
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
```

**Consultar.** `odbc_query/3` ejecuta una sentencia y da las filas de a una,
al reintentar, como términos `row(…)`; la opción `findall/2` las da todas
juntas en una lista. Una sesión en Linux, con `$C` para reusar la conexión
de la consulta anterior (la respuesta repite `C = '$odbc_connection'(…)`,
que se omite desde la segunda consulta):

```text
?- use_module(sqlite).
true.

?- abrir('universidad.db', C), copiar_base(C).
C = '$odbc_connection'(103069499300816).

?- findall(L-N, odbc_query($C, 'SELECT legajo, nombre FROM alumnos WHERE carrera = \'civil\'', row(L, N)), Filas).
Filas = [103-carla, 105-elena].

?- odbc_query($C, 'SELECT materia, COUNT(*), AVG(nota) FROM inscripciones GROUP BY materia', Filas, [findall(M-K-P, row(M, K, P))]).
Filas = [alg-4-5.75, am1-5-6.25, am2-2-7.0, log-4-7.0, pp-2-8.0].

?- findall(N, alumnos_de($C, sistemas, N), Ns).
Ns = [ana, bruno, diego].

?- findall(L-M, leer_tabla($C, inscripciones, inscripcion(L, M, null)), Cursando).
Cursando = [101-pp, 103-am2, 105-am1].

?- odbc_query($C, 'INSERT INTO alumnos VALUES (101, \'zoe\', \'civil\', 2025)').
ERROR: ODBC: State HY000: [SQLite]UNIQUE constraint failed: alumnos.legajo (19)
```

`alumnos_de/3` es una consulta con parámetro, como la vista `de_carrera/3`
de la [sección 42.2](index.md#422-el-algebra-relacional-en-clausulas), y `leer_tabla/3` convierte cada fila en el hecho
correspondiente: una tabla de SQLite se consulta como un predicado. El
error de la última consulta es la restricción de clave de la
[sección 42.6](restricciones.md#claves-restricciones-y-actualizaciones), verificada esta vez por SQLite.

<!-- ejemplo: capitulo-42/sqlite.pl predicado: alumnos_de/3 fila_hecho/3 leer_tabla/3 -->
```prolog
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
```

**Las pruebas sin controlador.** `sqlite.plt` tiene dos unidades. La
primera prueba las sentencias SQL que se escriben a partir del esquema y no
necesita ODBC. La segunda abre bases en memoria; una guarda intenta una
conexión una sola vez al cargar el archivo, y si el controlador no está,
imprime el motivo y deja la unidad con una prueba bloqueada. En Windows,
sin el controlador:

```text
% sqlite_odbc: pruebas bloqueadas, no hay controlador ODBC de SQLite
% ([Microsoft][Administrador de controladores ODBC] No se encuentra el nombre del origen de datos y no se especificó ningún controlador predeterminado)
…
% one test is blocked (use run_tests/2 with show_blocked(true) for details)
% All 5 tests passed in 0.072 seconds (0.063 cpu)
```

En Linux, con el controlador, pasan las trece. `base.pl` queda como la
base que usan los proyectos de la parte IV: el [capítulo 87](../capitulo-87-proyecto-preguntas-en-castellano/index.md) traduce
preguntas en castellano a SQL y las ejecuta contra ella.

Hay otra forma de tener una base SQL junto a Prolog sin ODBC: la del
[capítulo 29](../capitulo-29-prolog-desde-python/index.md). Un programa en Python abre la base con el módulo
`sqlite3` de su biblioteca estándar y consulta las reglas con Janus; cada
lenguaje cumple su parte, y los datos cruzan la frontera como listas.

## El controlador ODBC en Windows

Los pasos siguientes instalan el controlador ODBC de SQLite en Windows 11,
en cualquiera de sus ediciones (Home incluida), para una instalación de
SWI-Prolog de 64 bits. La instalación requiere una cuenta con permisos de
administrador. No hace falta crear un origen de datos (DSN): `sqlite.pl`
nombra el controlador en la cadena de conexión.

1. **Verificar la arquitectura de SWI-Prolog.** La consulta
   `current_prolog_flag(arch, A)` responde `A = 'x64-win64'` en una
   instalación de 64 bits, que necesita el controlador de 64 bits. Un
   SWI-Prolog de 32 bits no puede cargar un controlador de 64 bits, ni a la
   inversa.
2. **Descargar el instalador.** En la [página del
   controlador](http://www.ch-werner.de/sqliteodbc/), en «Current version»,
   el archivo es `sqliteodbc_w64.exe` (versión 0.99991, de 2023-10-23).
   `sqliteodbc.exe` es el de 32 bits, y las variantes `_dl` y `_msvcr100`
   dependen de bibliotecas que no vienen con Windows. La página se sirve
   solo por HTTP y no publica sumas de verificación, por lo que el
   navegador puede advertir que la descarga no es segura; para conservar el
   archivo, en Edge se elige «…» y luego «Conservar».
3. **Ejecutar el instalador.** El instalador no está firmado:
    - SmartScreen muestra «Windows protegió su PC»; «Más información» y
      luego «Ejecutar de todas formas» continúan.
    - Si el «Control inteligente de aplicaciones» de Seguridad de Windows
      está activado, bloquea el instalador sin ofrecer cómo continuar.
      Desactivarlo (Seguridad de Windows, «Control de aplicaciones y
      navegador») no tiene vuelta atrás sin reinstalar Windows; en ese caso
      conviene usar Linux o WSL, como en la lista anterior.
    - El Control de cuentas de usuario pide permiso para hacer cambios en el
      dispositivo; se responde «Sí».
    - En el asistente se acepta la licencia (de tipo BSD) y se dejan la
      carpeta (`C:\Program Files\SQLite ODBC Driver for Win64`) y los
      componentes que propone.
4. **Verificar que el controlador quedó registrado.** En PowerShell:

    ```text
    Get-OdbcDriver -Name "SQLite3*" -Platform 64-bit
    ```

    La respuesta incluye `Name : SQLite3 ODBC Driver`. El mismo nombre
    aparece en la pestaña «Controladores» de «Orígenes de datos ODBC (64
    bits)», en el menú Inicio.
5. **Verificar la conexión desde Prolog.** En `ejemplos/capitulo-42/`:

    ```text
    swipl -g "consult(['sqlite.pl','sqlite.plt']),run_tests" -t halt
    ```

    Con el controlador instalado no queda ninguna prueba bloqueada y pasan
    las trece de la sección. El mensaje «No se encuentra el nombre del
    origen de datos y no se especificó ningún controlador predeterminado»
    indica que el controlador no está registrado con ese nombre o que su
    arquitectura no coincide con la de SWI-Prolog.

El controlador se desinstala desde Configuración, «Aplicaciones»,
«Aplicaciones instaladas», con la entrada «SQLite ODBC Driver for Win64».
