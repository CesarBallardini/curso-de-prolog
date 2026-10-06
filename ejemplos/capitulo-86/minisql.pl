:- encoding(utf8).

% Capítulo 86 - El intérprete completo.
%
% Reúne las etapas: lexico.pl separa los tokens, sintaxis.pl da la
% sintaxis abstracta, catalogo.pl describe las relaciones, consultas.pl
% compila y ejecuta las consultas, modificaciones.pl las sentencias que
% cambian las tablas, y vistas.pl las vistas. sql/2 ejecuta una sentencia
% y da su resultado como término; sql/1 lo escribe como una tabla;
% guion/2 ejecuta varias sentencias separadas por punto y coma; sesion/0
% lee sentencias de la entrada hasta «salir», como el bucle toysequel de
% Kluźniak y Szpakowicz.
%
% solo-local: carga los módulos del capítulo.
%
%?- sql("SELECT nombre, carrera FROM alumnos WHERE ingreso = 2023", R).
%?- sql("SELECT carrera, COUNT(*) FROM alumnos GROUP BY carrera").

:- module(minisql,
          [ sql/2,
            sql/1,
            guion/2,
            sesion/0,
            mensaje/2
          ]).

:- reexport(lexico).
:- reexport(sintaxis).
:- reexport(catalogo).
:- reexport(consultas).
:- reexport(ingenuo).
:- use_module(modificaciones).
:- use_module(vistas).
:- use_module(library(lists)).
:- use_module(library(apply)).

%!  sql(+Texto, -Resultado) is det.
%
%   Ejecuta la sentencia Texto. Resultado es filas(Nombres, Filas) para
%   una consulta, tablas(Nombres) para SHOW TABLES, columnas(T, Columnas)
%   para DESCRIBE, o lo que da la sentencia que cambia una tabla o el
%   catálogo. Lanza error(sql(Motivo), _) si no se puede ejecutar.
sql(Texto, Resultado) :-
    analizar(Texto, Sentencia),
    ejecutar(Sentencia, Resultado).

%!  ejecutar(+Sentencia, -Resultado) is det.
%
%   Ejecuta una sentencia ya analizada.
ejecutar(Q, filas(Nombres, Filas)) :-
    Q = consulta(_, _, _),
    !,
    compilar_consulta(Q, [], Meta, Fila, Columnas),
    maplist(nombre_de, Columnas, Nombres),
    findall(Fila, Meta, Filas).
ejecutar(tablas, tablas(Nombres)) :-
    !,
    relaciones(Nombres).
ejecutar(describir(T), columnas(T, Columnas)) :-
    !,
    (   relacion(T, _, _, Cols)
    ->  maplist(descripcion, Cols, Columnas)
    ;   throw(error(sql(tabla_desconocida(T)), _))
    ).
ejecutar(S, Resultado) :-
    functor(S, F, _),
    memberchk(F, [crear_vista, borrar_vista]),
    !,
    vista(S, Resultado).
ejecutar(S, Resultado) :-
    modificar(S, Resultado).

% nombre_de(Col, N): N es el nombre de la columna del resultado.
nombre_de(col(N, _, _), N).

% descripcion(Col, D): D es Nombre-Tipo, o Nombre-Tipo-not_null.
descripcion(col(N, T, nulo, _), N-T).
descripcion(col(N, T, no_nulo, _), N-T-not_null).

%!  guion(+Texto, -Resultados:list) is det.
%
%   Ejecuta en orden las sentencias de Texto, separadas por punto y coma.
%   Resultados tiene el resultado de cada una, o error(Motivo) si no se
%   pudo ejecutar; un error no detiene las sentencias que siguen.
guion(Texto, Resultados) :-
    tokens(Texto, Tokens),
    partir(Tokens, Partes),
    maplist(ejecutar_parte, Partes, Resultados).

%!  partir(+Tokens:list, -Partes:list) is det.
%
%   Partes son las listas de tokens entre los punto y coma, sin las
%   vacías.
partir(Tokens, Partes) :-
    (   append(Antes, [;|Despues], Tokens)
    ->  partir(Despues, Resto),
        (   Antes == []
        ->  Partes = Resto
        ;   Partes = [Antes|Resto]
        )
    ;   Tokens == []
    ->  Partes = []
    ;   Partes = [Tokens]
    ).

%!  ejecutar_parte(+Tokens:list, -Resultado) is det.
%
%   El resultado de una sentencia de un guion, o error(Motivo).
ejecutar_parte(Tokens, Resultado) :-
    catch(( analizar_tokens(Tokens, S),
            ejecutar(S, Resultado) ),
          error(sql(Motivo), _),
          Resultado = error(Motivo)).

%!  sql(+Texto) is det.
%
%   Ejecuta la sentencia Texto y escribe el resultado, o el error.
sql(Texto) :-
    catch(( sql(Texto, R),
            escribir(R) ),
          error(sql(Motivo), _),
          escribir(error(Motivo))).

%!  escribir(+Resultado) is det.
%
%   Escribe un resultado: una tabla para las filas, una línea para lo
%   demás.
escribir(filas(Nombres, Filas)) :-
    !,
    escribir_tabla(Nombres, Filas).
escribir(R) :-
    mensaje(R, Texto),
    format("~w~n", [Texto]).

%!  mensaje(+Resultado, -Texto) is det.
%
%   Texto describe en castellano un resultado o un error.
mensaje(tablas(Ns), T) :-
    atomic_list_concat(Ns, ', ', T).
mensaje(columnas(R, Cs), T) :-
    maplist(texto_columna, Cs, Ts),
    atomic_list_concat(Ts, ', ', Lista),
    format(atom(T), "~w: ~w", [R, Lista]).
mensaje(creada(R), T) :-
    format(atom(T), "Relación ~w creada.", [R]).
mensaje(borrada(R), T) :-
    format(atom(T), "Relación ~w borrada.", [R]).
mensaje(insertadas(N), T) :-
    format(atom(T), "Filas insertadas: ~d.", [N]).
mensaje(eliminadas(N), T) :-
    format(atom(T), "Filas eliminadas: ~d.", [N]).
mensaje(actualizadas(N), T) :-
    format(atom(T), "Filas actualizadas: ~d.", [N]).
mensaje(error(Motivo), T) :-
    format(atom(T), "Error: ~w.", [Motivo]).

% texto_columna(D, T): T describe la columna D de DESCRIBE.
texto_columna(N-Tipo-not_null, T) :-
    !,
    format(atom(T), "~w ~w no nulo", [N, Tipo]).
texto_columna(N-Tipo, T) :-
    format(atom(T), "~w ~w", [N, Tipo]).

%!  escribir_tabla(+Nombres:list, +Filas:list) is det.
%
%   Escribe las filas en columnas alineadas, con los nombres arriba; NULL
%   se escribe NULL.
escribir_tabla(Nombres, Filas) :-
    maplist(maplist(texto_valor), Filas, Textos),
    maplist(texto_valor, Nombres, Cabecera),
    foldl(anchos, [Cabecera|Textos], [], Anchos),
    escribir_fila(Anchos, Cabecera),
    maplist(raya, Anchos, Rayas),
    escribir_fila(Anchos, Rayas),
    maplist(escribir_fila(Anchos), Textos).

% texto_valor(V, T): T es el texto con que se escribe V.
texto_valor(null, 'NULL') :-
    !.
texto_valor(V, T) :-
    format(atom(T), "~w", [V]).

% anchos(Fila, A0, A): A es el ancho máximo de cada columna.
anchos(Fila, [], Anchos) :-
    !,
    maplist(atom_length, Fila, Anchos).
anchos(Fila, A0, Anchos) :-
    maplist(atom_length, Fila, As),
    maplist([X, Y, Z]>>(Z is max(X, Y)), As, A0, Anchos).

% raya(N, R): R es una raya de N guiones.
raya(N, R) :-
    length(Cs, N),
    maplist(=(0'-), Cs),
    atom_codes(R, Cs).

% escribir_fila(Anchos, Fila): una línea con cada valor en su ancho,
% separados por dos espacios, sin espacios al final.
escribir_fila(Anchos, Fila) :-
    maplist(celda, Anchos, Fila, Celdas),
    atomic_list_concat(Celdas, '  ', Linea),
    split_string(Linea, "", " ", [Recortada]),
    format("~s~n", [Recortada]).

% celda(Ancho, T, C): C es T completado con espacios hasta Ancho.
celda(Ancho, T, C) :-
    format(atom(C), "~w~t~*|", [T, Ancho]).

%!  sesion is det.
%
%   Lee sentencias de la entrada, cada una terminada en punto y coma, y
%   escribe sus resultados, hasta que se escribe salir.
sesion :-
    format("mini-SQL. Cada sentencia termina en ';'. «salir» termina.~n"),
    bucle.

% bucle: lee y ejecuta sentencias hasta el fin.
bucle :-
    leer_sentencia(Texto),
    (   Texto == fin
    ->  true
    ;   sql(Texto),
        bucle
    ).

%!  leer_sentencia(-Texto) is det.
%
%   Texto son las líneas leídas hasta una que termina en punto y coma, o
%   fin al terminar la entrada o con la palabra salir.
leer_sentencia(Texto) :-
    leer_lineas([], Texto).

% leer_lineas(Leidas, Texto): junta líneas hasta el punto y coma.
leer_lineas(Leidas, Texto) :-
    read_line_to_string(user_input, Linea),
    (   Linea == end_of_file
    ->  Texto = fin
    ;   split_string(Linea, "", " \t", [L]),
        L == "salir"
    ->  Texto = fin
    ;   append(Leidas, [Linea], Todas),
        (   sub_string(Linea, _, _, 0, ";")
        ->  atomic_list_concat(Todas, '\n', A),
            atom_string(A, Texto)
        ;   leer_lineas(Todas, Texto)
        )
    ).
