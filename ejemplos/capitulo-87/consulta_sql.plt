:- encoding(utf8).

% Dos unidades, como sqlite.plt del capítulo 42. consulta_sql_filas no
% necesita ningún controlador: prueba cómo se leen las filas.
% consulta_sql_odbc copia la base en una base SQLite en memoria y compara,
% para cada pregunta del capítulo, la respuesta de la sentencia SQL con la
% de evaluar/2; si el controlador ODBC de SQLite no está instalado, la
% guarda hay_controlador/0 imprime el motivo y la unidad queda con una
% sola prueba, bloqueada.

:- use_module(preguntas, [ejemplo/2]).
:- use_module(evaluar, [evaluar/2]).

:- begin_tests(consulta_sql_filas).

test(cual, [true(R == lista([101, 104]))]) :-
    consulta_sql:respuesta_filas(cual(_, _), [row(101, ana), row(104, diego)],
                                 R).

test(cuantos, [true(R == numero(2))]) :-
    consulta_sql:respuesta_filas(cuantos(_, _), [row(2)], R).

test(si, [true(R == si)]) :-
    consulta_sql:respuesta_filas(si_no(_), [row(1)], R).

test(no, [true(R == no)]) :-
    consulta_sql:respuesta_filas(si_no(_), [row(0)], R).

:- end_tests(consulta_sql_filas).

%!  hay_controlador is semidet.
%
%   El controlador ODBC de SQLite está instalado: una conexión con una
%   base en memoria se abre y se cierra. Se prueba una sola vez; si falla,
%   se imprime el motivo.
hay_controlador :-
    (   nb_current(hay_controlador_87, Hay)
    ->  true
    ;   sqlite:cadena_conexion(':memory:', Cadena),
        catch(( odbc_driver_connect(Cadena, C, []),
                odbc_disconnect(C),
                Hay = si ),
              Error,
              Hay = no(Error)),
        nb_setval(hay_controlador_87, Hay),
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
           "% consulta_sql_odbc: pruebas bloqueadas, no hay controlador \c
            ODBC de SQLite~n% (~w)~n", [Texto]).

%!  con_base(-Conexion) is det.
%
%   Abre una base en memoria y le copia la base académica.
con_base(Conexion) :-
    abrir(':memory:', Conexion),
    copiar_base(Conexion).

:- if(hay_controlador).

:- begin_tests(consulta_sql_odbc).

% Las quince preguntas sin presuposición: SQLite y Prolog responden lo
% mismo.
test(iguales, [ setup(con_base(C)), cleanup(odbc_disconnect(C)),
                true(Distintas == []) ]) :-
    findall(N-Sql-Prolog,
            ( ejemplo(N, Texto),
              N =\= 14,
              responder_sql(C, Texto, Sql),
              gramatica:analizar(Texto, Forma),
              evaluar(Forma, Prolog),
              Sql \== Prolog ),
            Distintas).

test(quince, [ setup(con_base(C)), cleanup(odbc_disconnect(C)),
               true(K == 15) ]) :-
    aggregate_all(count,
                  ( ejemplo(N, Texto),
                    N =\= 14,
                    responder_sql(C, Texto, _) ),
                  K).

% La pregunta 14: SQL no tiene presuposiciones, y responde sí.
test(presuposicion, [ setup(con_base(C)), cleanup(odbc_disconnect(C)),
                      true(R == si) ]) :-
    ejemplo(14, Texto),
    responder_sql(C, Texto, R).

test(recursiva, [ setup(con_base(C)), cleanup(odbc_disconnect(C)),
                  true(R == lista([alg, log, pp, ssl])) ]) :-
    responder_sql(C, "¿Qué necesita bases de datos?", R).

:- end_tests(consulta_sql_odbc).

:- else.

% Sin el controlador, la unidad tiene una sola prueba, bloqueada: plunit
% la cuenta como bloqueada y no como fallida.
:- begin_tests(consulta_sql_odbc).

test(sin_controlador, [blocked('no hay controlador ODBC de SQLite')]) :-
    true.

:- end_tests(consulta_sql_odbc).

:- endif.
