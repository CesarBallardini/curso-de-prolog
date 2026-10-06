:- encoding(utf8).

% Capítulo 87 - Versión 4: la forma lógica traducida a SQL.
%
% Cada predicado de la forma lógica corresponde a una tabla de la base
% del capítulo 42 (sql_atomo/4): alumno/1 y carrera/2 a alumnos, cursar/2
% y aprobar/2 a inscripciones, materia/1 a materias, y necesitar/2 a la
% tabla recursiva requisitos, que la sentencia define con WITH RECURSIVE.
% Cada aparición de un predicado agrega la tabla con un alias propio, t1,
% t2, …; una variable se convierte en la primera columna en la que
% aparece, y cada aparición siguiente agrega una igualdad: es la reunión
% del capítulo 42, metas que comparten una variable. Una constante agrega
% una selección. no/1 es NOT EXISTS con una subconsulta que ve las
% columnas de afuera, y todo/3 es la doble negación: no existe un caso de
% la restricción para el que no exista el alcance.
%
% La sentencia se arma como texto, con un salto de línea antes de FROM,
% WHERE y ORDER BY. mostrar_sql/1 la escribe.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- sql(cuantos(X, y(alumno(X), aprobar(X, alg))), S), write(S).
%?- sql(si_no(aprobar(101, log)), S), write(S).

:- module(sql,
          [ sql/2,
            mostrar_sql/1,
            sql_atomo/4
          ]).

% Otros archivos pueden agregar la tabla de un predicado nuevo.
:- multifile sql_atomo/4.

%!  sql(+Forma, -SQL:string) is semidet.
%
%   SQL es una sentencia SELECT que responde la pregunta Forma: las
%   claves y los nombres para cual/2, la cantidad para cuantos/2, y 1 o 0
%   para si_no/1. Falla si Forma usa un predicado sin tabla.
sql(cual(X, F), SQL) :-
    compilar(F, e(0, [], [], [], no), E),
    E = e(_, Env, _, _, _),
    columna(Env, X, col(Alias, Tabla, Col)),
    (   nombrada(Tabla)
    ->  format(string(Lista), "DISTINCT ~w.~w, ~w.nombre", [Alias, Col, Alias])
    ;   format(string(Lista), "DISTINCT ~w.~w", [Alias, Col])
    ),
    format(string(Orden), "~w.~w", [Alias, Col]),
    sentencia(Lista, E, Orden, SQL).
sql(cuantos(X, F), SQL) :-
    compilar(F, e(0, [], [], [], no), E),
    E = e(_, Env, _, _, _),
    columna(Env, X, col(Alias, _, Col)),
    format(string(Lista), "COUNT(DISTINCT ~w.~w)", [Alias, Col]),
    sentencia(Lista, E, "", SQL).
sql(si_no(F), SQL) :-
    compilar(F, e(0, [], [], [], no), e(_, _, Desde, Donde, Cte)),
    subconsulta(Desde, Donde, Sub),
    prefijo(Cte, Prefijo),
    format(string(SQL), "~sSELECT EXISTS (~s)", [Prefijo, Sub]).

%!  nombrada(?Tabla) is semidet.
%
%   Las filas de Tabla tienen una columna nombre.
nombrada(alumnos).
nombrada(materias).

%!  sentencia(+Lista, +E, +Orden, -SQL:string) is det.
%
%   SQL es SELECT Lista con las tablas y las condiciones de E, ordenada
%   por Orden si no es "".
sentencia(Lista, e(_, _, Desde0, Donde0, Cte), Orden, SQL) :-
    reverse(Desde0, Desde),
    reverse(Donde0, Donde),
    prefijo(Cte, Prefijo),
    atomic_list_concat(Desde, ', ', DesdeTexto),
    format(string(SQL0), "~sSELECT ~s~nFROM ~w", [Prefijo, Lista, DesdeTexto]),
    (   Donde == []
    ->  SQL1 = SQL0
    ;   atomic_list_concat(Donde, '\n  AND ', DondeTexto),
        format(string(SQL1), "~s~nWHERE ~w", [SQL0, DondeTexto])
    ),
    (   Orden == ""
    ->  SQL = SQL1
    ;   format(string(SQL), "~s~nORDER BY ~s", [SQL1, Orden])
    ).

%!  subconsulta(+Desde0:list, +Donde0:list, -Sub:string) is det.
%
%   Sub es SELECT 1 con las tablas y las condiciones dadas, en una línea.
%   Las listas llegan en orden inverso, la última agregada primero.
subconsulta(Desde0, Donde0, Sub) :-
    reverse(Desde0, Desde),
    reverse(Donde0, Donde),
    (   Desde == []
    ->  DesdeTexto = ""
    ;   atomic_list_concat(Desde, ', ', D),
        format(string(DesdeTexto), " FROM ~w", [D])
    ),
    (   Donde == []
    ->  DondeTexto = ""
    ;   atomic_list_concat(Donde, ' AND ', W),
        format(string(DondeTexto), " WHERE ~w", [W])
    ),
    format(string(Sub), "SELECT 1~s~s", [DesdeTexto, DondeTexto]).

%!  prefijo(+Cte, -Prefijo:string) is det.
%
%   Prefijo define la tabla recursiva requisitos si Cte es si, y es
%   vacío si es no.
prefijo(no, "").
prefijo(si, "WITH RECURSIVE requisitos(materia, requisito) AS (\c
             SELECT materia, requisito FROM correlativas UNION \c
             SELECT r.materia, c.requisito FROM requisitos r, \c
             correlativas c WHERE c.materia = r.requisito)\n").

% --- La compilación ------------------------------------------------------

% El estado de la compilación es e(N, Env, Desde, Donde, Cte): N alias
% usados; Env, pares Variable-col(Alias, Tabla, Columna) con la columna
% de cada variable; Desde y Donde, las tablas y las condiciones, en orden
% inverso; Cte, si si hace falta la tabla requisitos.

%!  compilar(+F, +E0, -E) is semidet.
%
%   E es E0 con las tablas y las condiciones de la fórmula F.
compilar(F, E0, E) :-
    (   conectiva(F)
    ->  compilar_conectiva(F, E0, E)
    ;   compilar_atomo(F, E0, E)
    ).

% conectiva(F): F es una fórmula compuesta, no un predicado de la base.
conectiva(y(_, _)).
conectiva(alguno(_, _, _)).
conectiva(no(_)).
conectiva(todo(_, _, _)).

%!  compilar_conectiva(+F, +E0, -E) is semidet.
%
%   E es E0 con las tablas y las condiciones de F, una fórmula compuesta.
compilar_conectiva(y(A, B), E0, E) :-
    compilar(A, E0, E1),
    compilar(B, E1, E).
compilar_conectiva(alguno(_, R, A), E0, E) :-
    compilar(y(R, A), E0, E).
compilar_conectiva(no(A), e(N0, Env, Desde, Donde, Cte0),
                   e(N, Env, Desde, [Condicion|Donde], Cte)) :-
    compilar(A, e(N0, Env, [], [], Cte0), e(N, _, DesdeA, DondeA, Cte)),
    subconsulta(DesdeA, DondeA, Sub),
    format(string(Condicion), "NOT EXISTS (~s)", [Sub]).
compilar_conectiva(todo(_, R, A), E0, E) :-
    compilar(no(y(R, no(A))), E0, E).

%!  compilar_atomo(+Atomo, +E0, -E) is semidet.
%
%   E es E0 con la tabla de Atomo, con un alias nuevo, y sus condiciones.
%   Falla si Atomo no tiene tabla.
compilar_atomo(Atomo, e(N0, Env0, Desde, Donde0, Cte0),
               e(N, Env, [Tabla|Desde], Donde, Cte)) :-
    sql_atomo(Atomo, Nombre, Columnas, Extra),
    N is N0 + 1,
    format(atom(Alias), "t~d", [N]),
    format(atom(Tabla), "~w ~w", [Nombre, Alias]),
    foldl(columna_valor(Alias, Nombre), Columnas, Env0-Donde0, Env-Donde1),
    (   Extra == ""
    ->  Donde = Donde1
    ;   format(string(C), "~w.~s", [Alias, Extra]),
        Donde = [C|Donde1]
    ),
    (   Nombre == requisitos
    ->  Cte = si
    ;   Cte = Cte0
    ).

%!  columna_valor(+Alias, +Tabla, +Par, +Estado0, -Estado) is det.
%
%   Par es Columna-Valor. Si Valor es una variable sin columna, Columna
%   pasa a ser la suya; si ya tiene una, se agrega la igualdad entre las
%   dos; si es una constante, la selección Columna = constante.
columna_valor(Alias, Tabla, Col-Valor, Env0-Donde0, Env-Donde) :-
    (   var(Valor)
    ->  (   columna(Env0, Valor, col(A, _, C))
        ->  format(string(Cond), "~w.~w = ~w.~w", [Alias, Col, A, C]),
            Env = Env0,
            Donde = [Cond|Donde0]
        ;   Env = [Valor-col(Alias, Tabla, Col)|Env0],
            Donde = Donde0
        )
    ;   literal(Valor, Literal),
        format(string(Cond), "~w.~w = ~s", [Alias, Col, Literal]),
        Env = Env0,
        Donde = [Cond|Donde0]
    ).

%!  columna(+Env:list, +Variable, -Columna) is semidet.
%
%   Columna es la columna de Variable en Env. Compara con ==/2: unificar
%   ligaría variables distintas.
columna([V-C|Env], Variable, Columna) :-
    (   V == Variable
    ->  Columna = C
    ;   columna(Env, Variable, Columna)
    ).

%!  literal(+Valor, -Literal:string) is det.
%
%   Literal es Valor escrito en SQL: un entero tal cual, un átomo entre
%   comillas simples, con cada comilla del texto duplicada.
literal(Valor, Literal) :-
    (   integer(Valor)
    ->  number_string(Valor, Literal)
    ;   atom_string(Valor, Texto),
        split_string(Texto, "'", "", Partes),
        atomic_list_concat(Partes, "''", Doblado),
        format(string(Literal), "'~w'", [Doblado])
    ).

%!  sql_atomo(?Atomo, ?Tabla, ?Columnas:list, ?Extra:string) is semidet.
%
%   Atomo, un predicado de la forma lógica, es una fila de Tabla con los
%   argumentos en Columnas, pares Columna-Argumento, y la condición Extra
%   sobre la fila ("" si no hay).
sql_atomo(alumno(L), alumnos, [legajo-L], "").
sql_atomo(materia(M), materias, [codigo-M], "").
sql_atomo(carrera(L, C), alumnos, [legajo-L, carrera-C], "").
sql_atomo(cursar(L, M), inscripciones, [legajo-L, materia-M], "").
sql_atomo(aprobar(L, M), inscripciones, [legajo-L, materia-M], "nota >= 6").
sql_atomo(necesitar(M, R), requisitos, [materia-M, requisito-R], "").

%!  mostrar_sql(+Forma) is semidet.
%
%   Escribe la sentencia SQL de Forma.
mostrar_sql(Forma) :-
    sql(Forma, SQL),
    format("~s~n", [SQL]).
