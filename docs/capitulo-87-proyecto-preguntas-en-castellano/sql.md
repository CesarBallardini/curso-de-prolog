# La forma lógica en SQL

Esta página contiene la [sección 87.7](index.md#877-version-4-la-forma-logica-en-sql)
del [capítulo 87](index.md): la versión 4, que traduce la forma lógica de
una pregunta a una sentencia SQL y la ejecuta en SQLite. El código está en
`sql.pl` y `consulta_sql.pl`, en `ejemplos/capitulo-87/`, con sus pruebas.
La traducción corre sin ninguna base instalada; la ejecución necesita el
controlador ODBC de SQLite, como la
[sección 42.7](../capitulo-42-prolog-y-sql/odbc.md#la-base-en-sqlite).

## La traducción

El [capítulo 42](../capitulo-42-prolog-y-sql/index.md#421-tablas-filas-y-hechos)
escribió la correspondencia entre las dos notaciones en el sentido de SQL
a Prolog: una tabla es un predicado, `JOIN … ON` son metas que comparten
una variable, `NOT EXISTS` es `\+`. La versión 4 la recorre en el otro
sentido. Cada predicado de la forma lógica corresponde a una tabla, con sus
argumentos en unas columnas y, a veces, una condición más sobre la fila:

<!-- ejemplo: capitulo-87/sql.pl predicado: sql_atomo/4 -->
```prolog
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
```

`necesitar/2` no corresponde a una tabla de la base sino a `requisitos`,
la clausura de `correlativas`, que la sentencia define al principio con
`WITH RECURSIVE`. Es la consulta recursiva de la página
[Consultas recursivas](../capitulo-42-prolog-y-sql/recursion.md#consultas-recursivas)
del [capítulo 42](../capitulo-42-prolog-y-sql/index.md): con `UNION`, y no `UNION ALL`, una fila repetida no se
agrega, y la recursión termina aunque el plan de estudios tuviera un
ciclo, como la tabla de `pasos/3`.

La compilación recorre la fórmula con un estado `e(N, Env, Desde, Donde,
Cte)`: cuántos alias se usaron, la columna de cada variable, las tablas,
las condiciones y si hace falta la tabla recursiva. Cada aparición de un
predicado agrega su tabla con un alias nuevo, `t1`, `t2`, …. Cada
argumento se trata según lo que es:

<!-- ejemplo: capitulo-87/sql.pl predicado: columna_valor/5 columna/3 -->
```prolog
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
```

Una variable que todavía no tiene columna toma la de su primera
aparición; cada aparición siguiente agrega una igualdad, y así una
variable compartida se convierte en una reunión. Una constante agrega una
selección. `columna/3` compara las variables con `==/2`: unificar una
variable de la fórmula con la del entorno las ligaría, y dos variables
distintas pasarían a ser la misma.

`y/2` y `alguno/3` agregan sus tablas y sus condiciones a la consulta en
curso: un cuantificador existencial no necesita nada más, porque las
tablas de `FROM` ya se recorren buscando alguna fila. `no/1` compila su
fórmula en una subconsulta que ve el entorno de afuera, la **subconsulta
correlacionada** de `NOT EXISTS`; las columnas que la subconsulta liga por
primera vez quedan dentro de ella. `todo/3` es la doble negación:

<!-- ejemplo: capitulo-87/sql.pl predicado: compilar/3 compilar_conectiva/3 -->
```prolog
%!  compilar(+F, +E0, -E) is semidet.
%
%   E es E0 con las tablas y las condiciones de la fórmula F.
compilar(F, E0, E) :-
    (   conectiva(F)
    ->  compilar_conectiva(F, E0, E)
    ;   compilar_atomo(F, E0, E)
    ).

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
```

`sql/2` arma la sentencia de cada clase de pregunta: `cual/2` pide la clave
y el nombre de cada respuesta, sin repetir, en el orden de la clave;
`cuantos/2` cuenta las claves distintas; y `si_no/1` pregunta si existe
alguna fila, con `SELECT EXISTS`, que SQLite responde con 1 o 0.

<!-- contexto: capitulo-87/preguntas.pl -->
```prolog
?- sql("¿Todos los alumnos de civil cursan análisis 1?").
SELECT EXISTS (SELECT 1 WHERE NOT EXISTS (SELECT 1 FROM alumnos t1, alumnos t2 WHERE t2.legajo = t1.legajo AND t2.carrera = 'civil' AND NOT EXISTS (SELECT 1 FROM inscripciones t3 WHERE t3.legajo = t1.legajo AND t3.materia = 'am1')))
true.

?- sql("¿Qué necesita bases de datos?").
WITH RECURSIVE requisitos(materia, requisito) AS (SELECT materia, requisito FROM correlativas UNION SELECT r.materia, c.requisito FROM requisitos r, correlativas c WHERE c.materia = r.requisito)
SELECT DISTINCT t1.codigo, t1.nombre
FROM materias t1, requisitos t2
WHERE t2.materia = 'bd'
  AND t2.requisito = t1.codigo
ORDER BY t1.codigo
true.
```

La primera sentencia dice, con la doble negación: no existe un alumno de
civil para el que no exista una inscripción en análisis 1. Es la forma
del [ejercicio 7 del capítulo 42](../capitulo-42-prolog-y-sql/index.md#ejercicios),
«los alumnos que aprobaron todas las materias de primer año», escrita
por el programa.

**Lo que la traducción no optimiza.** «¿Qué alumnos de sistemas cursan
paradigmas?» da una sentencia con dos veces la tabla `alumnos`:

```prolog
?- sql("¿Qué alumnos de sistemas cursan paradigmas?").
SELECT DISTINCT t1.legajo, t1.nombre
FROM alumnos t1, alumnos t2, inscripciones t3
WHERE t2.legajo = t1.legajo
  AND t2.carrera = 'sistemas'
  AND t3.legajo = t1.legajo
  AND t3.materia = 'pp'
ORDER BY t1.legajo
true.
```

`alumno(X)` y `carrera(X, sistemas)` son dos predicados de la forma
lógica, y cada uno trae su tabla. La sentencia es correcta, y el orden
en que se recorren las tablas lo decide el planificador de SQLite; el
[ejercicio 5](index.md#ejercicios) simplifica la forma lógica antes de
traducirla. Warren y Pereira cuentan que, al montar la base de Chat-80 en
un sistema relacional, las consultas con más de dos relaciones no
terminaban en un tiempo razonable, y que por eso Chat-80 planifica sus
consultas: reordena las metas según el tamaño de las relaciones antes de
ejecutarlas. Un sistema de bases de datos actual hace esa planificación
solo; es una de las razones para traducir la pregunta a SQL.

**Las constantes.** Un valor de la base viaja dentro del texto de la
sentencia, entre comillas simples, y `literal/2` duplica cada comilla del
valor, como pide SQL. Las constantes de una forma lógica vienen siempre
de la base, a través de los nombres propios, y nunca del texto que se
escribe; aun así, la forma segura de pasar valores son las sentencias
preparadas con parámetros de la
[sección 42.7](../capitulo-42-prolog-y-sql/odbc.md#la-base-en-sqlite).

## La sentencia en SQLite

`consulta_sql.pl` abre la base en SQLite con `abrir/2` y `copiar_base/1`
de `sqlite.pl` del [capítulo 42](../capitulo-42-prolog-y-sql/index.md), sin copiarlos, ejecuta la sentencia con
`odbc_query/3` y convierte las filas en una respuesta de la misma forma
que `evaluar/2`:

<!-- ejemplo: capitulo-87/consulta_sql.pl predicado: ejecutar_sql/3 respuesta_filas/3 valor_si_no/2 -->
```prolog
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
```

Con una conexión `C` abierta por `abrir(':memory:', C), copiar_base(C)`,
una sesión con el controlador da:

```text
?- responder_sql($C, "¿Cuántos aprobaron álgebra?", R).
R = numero(2).

?- responder_sql($C, "¿Qué necesita bases de datos?", R).
R = lista([alg, log, pp, ssl]).

?- responder_sql($C, "¿Todos los alumnos que cursan bases de datos aprobaron lógica?", R).
R = si.
```

Las pruebas de `consulta_sql.plt` hacen esa comparación para las
dieciséis preguntas de `ejemplo/2`. Las quince sin presuposición dan en
SQLite la misma respuesta que `evaluar/2`. La última pregunta de la sesión
no: Prolog responde que la presuposición no se cumple, y SQL responde
«sí», porque `NOT EXISTS` sobre un conjunto vacío es verdadero. La lógica
de tres valores de SQL, con `NULL`, no sirve para esto: `EXISTS` nunca da
`NULL`. El [ejercicio 10](index.md#ejercicios) escribe una traducción que
lo da cuando la pregunta no tiene casos.

La comparación es posible porque las dos versiones leen el mismo
término; es el patrón 103:

!!! example "Patrón 103 — Una forma lógica, dos evaluadores"
    **Problema.** Una pregunta se responde de dos maneras: en Prolog, que
    además explica la respuesta con los hechos que la prueban, y en un
    sistema de bases de datos, que planifica la consulta. Dos
    traducciones escritas por separado pueden dar respuestas distintas
    sin que nada lo advierta.

    **Versión ingenua.** Escribir dos programas a partir del texto: una
    gramática que produce metas de Prolog y otra que produce SQL, o un
    traductor de SQL a Prolog para la explicación. Cada uno tiene sus
    propios errores, y comparar sus resultados exige comparar dos
    análisis de la misma pregunta.

    **Patrón.** Analizar una sola vez, en una **forma lógica**: un
    término con su propio lenguaje pequeño, `cual/2`, `cuantos/2`,
    `si_no/1`, `todo/3`, `alguno/3`, `no/1`, `y/2` y los predicados de la
    base. Dos evaluadores la leen: `evaluar/2` la interpreta en Prolog, y
    `sql/2` la compila a una sentencia que `ejecutar_sql/3` ejecuta y
    `respuesta_filas/3` convierte en una respuesta de la misma forma que
    la de `evaluar/2`. Lo que depende de la base está en un solo hecho
    por predicado en cada evaluador, `definicion/2` y `sql_atomo/4`. Las
    pruebas comparan las dos respuestas pregunta por pregunta, y cada
    evaluador verifica al otro. Es la
    [especificación como dato del Patrón 91](../patrones.md#91-especificacion-como-dato)
    con más de un intérprete.

    **Cuándo no usarlo.** Cuando los dos evaluadores no pueden dar la
    misma semántica y la diferencia no se documenta: una presuposición
    que no se cumple da en Prolog una advertencia y en SQL «sí», y las
    pruebas tienen que separar ese caso en lugar de esconderlo. Y cuando
    hay un solo destino: la forma lógica agrega un lenguaje intermedio
    que nadie más lee.

Sin el controlador, las pruebas de esa unidad se bloquean y avisan por
qué, como las del [capítulo 42](../capitulo-42-prolog-y-sql/index.md); las de `sql.plt`, que comparan el texto de
las sentencias, corren siempre. Las sentencias de esta página se
ejecutaron también en SQLite 3.50 sobre `schema.sql`, el esquema con los
mismos datos que usa el [capítulo 42](../capitulo-42-prolog-y-sql/index.md).
