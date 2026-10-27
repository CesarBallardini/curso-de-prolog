:- encoding(utf8).

% Dos unidades. sqlite_sentencias no necesita ningún controlador: prueba
% las sentencias SQL que se escriben a partir del esquema. sqlite_odbc
% abre bases SQLite en memoria; si el controlador ODBC de SQLite no está
% instalado, la guarda hay_sqlite_odbc/0, que se evalúa una vez al cargar
% este archivo, imprime el motivo, y la unidad queda con una sola prueba,
% bloqueada: se informa como bloqueada, no como fallida.

:- begin_tests(sqlite_sentencias).

test(cadena, [true(C == Esperada)]) :-
    cadena_conexion(':memory:', C),
    (   current_prolog_flag(windows, true)
    ->  Esperada = 'DRIVER={SQLite3 ODBC Driver};Database=:memory:'
    ;   Esperada = 'DRIVER=SQLite3;Database=:memory:'
    ).

test(create_alumnos, [true(S == 'CREATE TABLE alumnos (legajo INTEGER \c
                                 NOT NULL, nombre TEXT NOT NULL, carrera \c
                                 TEXT NOT NULL, ingreso INTEGER NOT NULL, \c
                                 PRIMARY KEY (legajo))')]) :-
    sentencia_create(alumnos, S).

test(create_inscripciones,
     [true(S == 'CREATE TABLE inscripciones (legajo INTEGER NOT NULL, \c
                 materia TEXT NOT NULL, nota INTEGER, PRIMARY KEY \c
                 (legajo, materia), FOREIGN KEY (legajo) REFERENCES \c
                 alumnos (legajo), FOREIGN KEY (materia) REFERENCES \c
                 materias (codigo), CHECK (nota BETWEEN 1 AND 10))')]) :-
    sentencia_create(inscripciones, S).

test(insert, [true(S == 'INSERT INTO materias VALUES (?, ?, ?)')]) :-
    sentencia_insert(materias, S).

test(fila_hecho, [true(H == inscripcion(101, pp, null))]) :-
    fila_hecho(inscripciones, row(101, pp, null), H).

:- end_tests(sqlite_sentencias).

%!  hay_sqlite_odbc is semidet.
%
%   El controlador ODBC de SQLite está instalado: una conexión con una
%   base en memoria se abre y se cierra. Se prueba una sola vez; si falla,
%   se imprime el motivo.
hay_sqlite_odbc :-
    (   nb_current(hay_sqlite_odbc, Hay)
    ->  true
    ;   cadena_conexion(':memory:', Cadena),
        catch(( odbc_driver_connect(Cadena, C, []),
                odbc_disconnect(C),
                Hay = si ),
              Error,
              Hay = no(Error)),
        nb_setval(hay_sqlite_odbc, Hay),
        avisar(Hay)
    ),
    Hay == si.

%!  avisar(+Hay) is det.
%
%   Imprime en user_error por qué se bloquean las pruebas de ODBC.
avisar(si).
avisar(no(Error)) :-
    (   Error = error(odbc(_, _, Texto), _)
    ->  true
    ;   Texto = Error
    ),
    format(user_error,
           "% sqlite_odbc: pruebas bloqueadas, no hay controlador ODBC \c
            de SQLite~n% (~w)~n", [Texto]).

%!  con_base(-Conexion) is det.
%
%   Abre una base en memoria y le copia la base académica.
con_base(Conexion) :-
    abrir(':memory:', Conexion),
    copiar_base(Conexion).

:- if(hay_sqlite_odbc).

:- begin_tests(sqlite_odbc).

test(filas, [ setup(con_base(C)), cleanup(odbc_disconnect(C)),
              all(T-K == [alumnos-7, materias-7, correlativas-7,
                          inscripciones-17]) ]) :-
    member(T, [alumnos, materias, correlativas, inscripciones]),
    aggregate_all(count, leer_tabla(C, T, _), K).

% Las filas vuelven iguales a los hechos, null incluido.
test(ida_y_vuelta, [ setup(con_base(C)), cleanup(odbc_disconnect(C)),
                     true(Leidas == Hechos) ]) :-
    findall(H, leer_tabla(C, inscripciones, H), Leidas),
    findall(inscripcion(L, M, N), base:inscripcion(L, M, N), Hechos).

test(parametro, [ setup(con_base(C)), cleanup(odbc_disconnect(C)),
                  all(N == [carla, elena]) ]) :-
    alumnos_de(C, civil, N).

% La misma reunión en SQL y como vista.
test(acta, [ setup(con_base(C)), cleanup(odbc_disconnect(C)),
             true(Sql == Prolog) ]) :-
    findall(A-N,
            odbc_query(C, 'SELECT a.nombre, i.nota \c
                           FROM inscripciones i JOIN alumnos a \c
                           ON a.legajo = i.legajo \c
                           WHERE i.materia = \'am1\'', row(A, N)),
            Sql0),
    msort(Sql0, Sql),
    findall(A-N, ( base:inscripcion(L, am1, N),
                   base:alumno(L, A, _, _) ), Prolog0),
    msort(Prolog0, Prolog).

test(aprobadas, [ setup(con_base(C)), cleanup(odbc_disconnect(C)),
                  true(K == 10) ]) :-
    odbc_query(C, 'SELECT COUNT(*) FROM inscripciones WHERE nota >= 6',
               row(K)).

test(clave_repetida, [ setup(con_base(C)), cleanup(odbc_disconnect(C)),
                       error(odbc('HY000', 19, _)) ]) :-
    odbc_query(C, 'INSERT INTO alumnos VALUES (101, \'zoe\', \c
                   \'civil\', 2025)').

test(referencia, [ setup(con_base(C)), cleanup(odbc_disconnect(C)),
                   error(odbc('HY000', 19, _)) ]) :-
    odbc_query(C, 'INSERT INTO inscripciones VALUES (999, \'am1\', NULL)').

test(insertar, [ setup(con_base(C)), cleanup(odbc_disconnect(C)),
                 true(R == affected(1)) ]) :-
    odbc_query(C, 'INSERT INTO inscripciones VALUES (107, \'am1\', NULL)',
               R).

:- end_tests(sqlite_odbc).

:- else.

% Sin el controlador, la unidad tiene una sola prueba, bloqueada: plunit
% la cuenta como bloqueada y no como fallida.
:- begin_tests(sqlite_odbc).

test(sin_controlador, [blocked('no hay controlador ODBC de SQLite')]) :-
    true.

:- end_tests(sqlite_odbc).

:- endif.
