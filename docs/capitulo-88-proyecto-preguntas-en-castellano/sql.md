# Evaluar, explicar y traducir la forma lógica a SQL

Esta página continúa el [capítulo 88](index.md) después de la [sección
88.5](palabras.md#885-version-2-la-gramatica-y-la-forma-logica), con las
secciones [88.6](#886-version-3-evaluar-y-explicar) y
[88.7](#887-version-4-la-forma-logica-en-sql): la versión 3, que evalúa la
forma lógica de una pregunta y explica la respuesta, y la versión 4, que
traduce la forma lógica a una sentencia SQL y la ejecuta en SQLite. El
código está en `evaluar.pl`, `sql.pl` y `consulta_sql.pl`, en
`ejemplos/capitulo-88/`, con sus pruebas. La traducción corre sin ninguna
base instalada; la ejecución necesita el controlador ODBC de SQLite, como la
[sección 43.7](../capitulo-43-prolog-y-sql/odbc.md#la-base-en-sqlite).

## 88.6 Versión 3: evaluar y explicar

Pereira y Shieber convierten la forma lógica en una cláusula de Horn con
`clausify/3` y la ejecutan con `setof/3`. La conversión es parcial: «who
wrote every book?» da `all(B, book(B) => wrote(X, B)) => answer(X)`, que
no es una cláusula de Horn, y la respuesta es «too difficult». La versión
3 no convierte la forma lógica: la **interpreta**, con un metaintérprete
como los del [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md#344-arboles-de-prueba),
que devuelve además el árbol de prueba. `todo/3` es la doble negación de
Chat-80: no hay un caso de la restricción que no cumpla el alcance.

<!-- ejemplo: capitulo-88/evaluar.pl predicado: probar/2 definicion/2 -->
```prolog
%!  probar(+F, -Arbol) is nondet.
%
%   F se cumple en la base, con la prueba Arbol: una respuesta por cada
%   prueba. Las variables de F que quedan ligadas son las que la prueba
%   instancia.
probar(y(A, B), y(TA, TB)) :-
    probar(A, TA),
    probar(B, TB).
probar(alguno(_, R, A), alguno(T)) :-
    once(probar(y(R, A), T)).
probar(no(A), no_se_prueba(A, Motivo)) :-
    \+ probar(A, _),
    por_que_no(A, Motivo).
probar(todo(X, R, A), todos(Casos)) :-
    \+ ( probar(R, _), \+ probar(A, _) ),
    findall(X-T, ( probar(R, _), once(probar(A, T)) ), Casos0),
    sort(1, @<, Casos0, Casos).
probar(Atomo, prueba(Atomo, Hechos)) :-
    definicion(Atomo, Hechos).

%!  definicion(?Atomo, -Hechos:list) is nondet.
%
%   Hechos son los hechos de la base, y las comparaciones, que prueban
%   Atomo, un predicado de la forma lógica.
definicion(alumno(L), [alumno(L, N, C, I)]) :-
    alumno(L, N, C, I).
definicion(materia(M), [materia(M, N, A)]) :-
    materia(M, N, A).
definicion(carrera(L, C), [alumno(L, N, C, I)]) :-
    alumno(L, N, C, I).
definicion(cursar(L, M), [inscripcion(L, M, N)]) :-
    inscripcion(L, M, N).
definicion(aprobar(L, M), [inscripcion(L, M, N), N >= 6]) :-
    aprobada(L, M, N).
definicion(necesitar(M, R), Cadena) :-
    pasos(M, R, _),
    cadena(M, R, Cadena).
```

`definicion/2` dice qué hechos de la base prueban cada predicado de la
forma lógica: es el diccionario que Warren y Pereira separan de la
gramática, la única parte del programa que depende de la base. Las hojas
del árbol son esos hechos. `evaluar/2` responde y `explicar/2` da, para
cada respuesta, su primera prueba:

<!-- contexto: capitulo-88/evaluar.pl -->
```prolog
?- evaluar(cuantos(X, y(alumno(X), aprobar(X, alg))), R).
R = numero(2).

?- explicar(si_no(aprobar(102, alg)), E).
E = falla(no_alcanza(inscripcion(102, alg, 2), 2<6)).
```

**Por qué no.** Una falla no tiene árbol. `por_que_no/2` la explica como
`explicacion/3` del sistema experto de la
[sección 34.7](../capitulo-34-introspeccion-y-metainterpretes/index.md#347-el-sistema-experto-explica):
en una conjunción, baja por la primera condición que falla; en `todo/3`,
busca el primer caso de la restricción que no cumple el alcance, un
**contraejemplo**; en `alguno/3`, explica por qué falla cada caso. En un
predicado de la base, dice qué falta: la inscripción no existe, o existe
y su nota no alcanza o todavía no tiene nota.

<!-- ejemplo: capitulo-88/evaluar.pl predicado: por_que_no/2 por_que_no_conectiva/2 motivo/2 -->
```prolog
%!  por_que_no(+F, -Motivo) is det.
%
%   Motivo explica por qué F, que no se prueba, falla: en una conjunción,
%   la primera condición que falla con la primera prueba de las
%   anteriores; en todo/3, el primer caso de la restricción que no cumple
%   el alcance; en alguno/3, por qué falla cada caso de la restricción.
por_que_no(F, Motivo) :-
    (   conectiva(F)
    ->  por_que_no_conectiva(F, Motivo)
    ;   motivo(F, Motivo)
    ).

%!  por_que_no_conectiva(+F, -Motivo) is det.
%
%   Motivo explica por qué falla F, una fórmula compuesta.
por_que_no_conectiva(y(A, B), Motivo) :-
    (   once(probar(A, _))
    ->  por_que_no(B, Motivo)
    ;   por_que_no(A, Motivo)
    ).
por_que_no_conectiva(todo(X, R, A), contraejemplo(X, Motivo)) :-
    once(( probar(R, _), \+ probar(A, _) )),
    por_que_no(A, Motivo).
por_que_no_conectiva(alguno(X, R, A), ninguno(Casos)) :-
    findall(X-M, ( probar(R, _), por_que_no(A, M) ), Casos0),
    sort(1, @<, Casos0, Casos).
por_que_no_conectiva(no(A), se_prueba(Arbol)) :-
    once(probar(A, Arbol)).

%!  motivo(+Atomo, -Motivo) is det.
%
%   Motivo dice qué falta en la base para probar Atomo: aprobar/2 con una
%   inscripción cuya nota no alcanza o falta; cualquier otro predicado,
%   sin hechos que lo prueben.
motivo(aprobar(L, M), Motivo) :-
    inscripcion(L, M, N),
    !,
    (   N == null
    ->  Motivo = sin_nota(inscripcion(L, M, N))
    ;   Motivo = no_alcanza(inscripcion(L, M, N), N < 6)
    ).
motivo(Atomo, sin_hechos(Atomo)).
```

La negación de una pregunta usa el mismo motivo: un alumno está entre
los que «no aprobaron álgebra» porque su nota no alcanza o porque no hay
ningún hecho que lo pruebe. Es el supuesto de mundo cerrado de la
[sección 43.4](../capitulo-43-prolog-y-sql/index.md#434-donde-difieren-bolsas-conjuntos-y-null):
elena y gabriela no están inscriptas en álgebra, y para la base no la
aprobaron.

<!-- contexto: capitulo-88/preguntas.pl -->
```prolog
?- preguntar("¿Quién no aprobó álgebra?").
bruno, carla, elena, facundo y gabriela
  bruno: inscripcion(102, alg, 2), y 2 < 6
  carla: inscripcion(103, alg, 5), y 5 < 6
  elena: ningún hecho prueba aprobar(105, alg)
  facundo: ningún hecho prueba aprobar(106, alg)
  gabriela: ningún hecho prueba aprobar(107, alg)
true.

?- preguntar("¿Todos los alumnos de sistemas aprobaron álgebra?").
No
  bruno: inscripcion(102, alg, 2), y 2 < 6
true.
```

**Las presuposiciones.** «¿Todos los alumnos que cursan bases de datos
aprobaron lógica?» tiene, en lógica, la respuesta «sí»: nadie cursa bases
de datos, y una afirmación sobre todos los elementos de un conjunto vacío
es verdadera. Para quien pregunta, «sí» es engañoso. Dahl observa que una
pregunta así no es verdadera ni falsa sino que no tiene sentido: su
**presuposición**, que hay alumnos que cursan bases de datos, no se
cumple. Sus sistemas usan una lógica con un tercer valor para eso. La
versión 3 verifica la presuposición de «todos» antes de evaluar:

```prolog
?- preguntar("¿Todos los alumnos que cursan bases de datos aprobaron lógica?").
La pregunta supone que hay casos, y no hay ninguno
true.
```

Chat-80 toma la decisión contraria, y la justifica: ignora las
presuposiciones, y a «Which ocean borders the United States?» responde con
los tres océanos sin comentar que la pregunta suponía uno.

**Las correlativas, con una tabla.** «¿Qué necesita bases de datos?» pide
las correlativas de bases de datos, las de esas, y así hasta el final de
la cadena. `necesitar/2` se define con `pasos/3`, escrita con la
recursión a la izquierda y tabulada con la subsunción de respuestas `min`
de la [sección 40.3](../capitulo-40-tabulacion/subsuncion.md#403-subsuncion-de-respuestas),
y la explicación de cada requisito es una cadena de las más cortas, que
da `cadena/3`. La página [Las correlativas, con una tabla](correlativas.md)
muestra las dos definiciones y sus respuestas:

<!-- contexto: capitulo-88/evaluar.pl -->
```prolog
?- setof(R-N, pasos(bd, R, N), Ps).
Ps = [alg-2, log-2, pp-1, ssl-1].
```

!!! question "Actividad"
    Predecir la respuesta y la explicación de «¿Algún alumno de industrial
    aprobó lógica?» y de «¿Ningún alumno aprobó sintaxis?». Comprobarlas
    con `preguntar/1`.

## 88.7 Versión 4: la forma lógica en SQL

La forma lógica es un lenguaje de consulta, y se traduce a otro. Cada
predicado corresponde a una tabla: `alumno/1` y `carrera/2` a `alumnos`,
`cursar/2` y `aprobar/2` a `inscripciones`, `materia/1` a `materias`, y
`necesitar/2` a una tabla recursiva que la sentencia define con
`WITH RECURSIVE`. Una variable compartida es una reunión, una constante es
una selección, `no/1` es `NOT EXISTS` y `todo/3` es la doble negación:

<!-- contexto: capitulo-88/preguntas.pl -->
```prolog
?- sql("¿Quién no aprobó álgebra?").
SELECT DISTINCT t1.legajo, t1.nombre
FROM alumnos t1
WHERE NOT EXISTS (SELECT 1 FROM inscripciones t2 WHERE t2.legajo = t1.legajo AND t2.materia = 'alg' AND t2.nota >= 6)
ORDER BY t1.legajo
true.
```

El apartado [La traducción](#la-traduccion) explica el
traductor, `sql.pl`, y el apartado
[La sentencia en SQLite](#la-sentencia-en-sqlite) ejecuta las
sentencias contra la base del
[capítulo 43](../capitulo-43-prolog-y-sql/index.md) con ODBC y las compara
con la evaluación en Prolog. Las quince preguntas de ejemplo sin
presuposición dan en SQLite la misma respuesta que en Prolog. La que
tiene una presuposición, no: SQL responde «sí», porque `NOT EXISTS` sobre
un conjunto vacío es verdadero, y no tiene un tercer valor para «la
pregunta no tiene sentido».

### La traducción

El [capítulo 43](../capitulo-43-prolog-y-sql/index.md#431-tablas-filas-y-hechos)
escribió la correspondencia entre las dos notaciones en el sentido de SQL
a Prolog: una tabla es un predicado, `JOIN … ON` son metas que comparten
una variable, `NOT EXISTS` es `\+`. La versión 4 la recorre en el otro
sentido. Cada predicado de la forma lógica corresponde a una tabla, con sus
argumentos en unas columnas y, a veces, una condición más sobre la fila:

<!-- ejemplo: capitulo-88/sql.pl predicado: sql_atomo/4 -->
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
[Consultas recursivas](../capitulo-43-prolog-y-sql/recursion.md#consultas-recursivas)
del [capítulo 43](../capitulo-43-prolog-y-sql/index.md): con `UNION`, y no `UNION ALL`, una fila repetida no se
agrega, y la recursión termina aunque el plan de estudios tuviera un
ciclo, como la tabla de `pasos/3`.

La compilación recorre la fórmula con un estado `e(N, Env, Desde, Donde,
Cte)`: cuántos alias se usaron, la columna de cada variable, las tablas,
las condiciones y si hace falta la tabla recursiva. Cada aparición de un
predicado agrega su tabla con un alias nuevo, `t1`, `t2`, …. Cada
argumento se trata según lo que es:

<!-- ejemplo: capitulo-88/sql.pl predicado: columna_valor/5 columna/3 -->
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

<!-- ejemplo: capitulo-88/sql.pl predicado: compilar/3 compilar_conectiva/3 -->
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

<!-- contexto: capitulo-88/preguntas.pl -->
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
del [ejercicio 7 del capítulo 43](../capitulo-43-prolog-y-sql/index.md#ejercicios),
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
[ejercicio 6](#ejercicios) simplifica la forma lógica antes de
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
[sección 43.7](../capitulo-43-prolog-y-sql/odbc.md#la-base-en-sqlite).

### La sentencia en SQLite

`consulta_sql.pl` abre la base en SQLite con `abrir/2` y `copiar_base/1`
de `sqlite.pl` del [capítulo 43](../capitulo-43-prolog-y-sql/index.md), sin copiarlos, ejecuta la sentencia con
`odbc_query/3` y convierte las filas en una respuesta de la misma forma
que `evaluar/2`:

<!-- ejemplo: capitulo-88/consulta_sql.pl predicado: ejecutar_sql/3 respuesta_filas/3 valor_si_no/2 -->
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
`NULL`. El [ejercicio 10](#ejercicios) escribe una traducción que
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
qué, como las del [capítulo 43](../capitulo-43-prolog-y-sql/index.md); las de `sql.plt`, que comparan el texto de
las sentencias, corren siempre. Las sentencias de esta página se
ejecutaron también en SQLite 3.50 sobre `schema.sql`, el esquema con los
mismos datos que usa el [capítulo 43](../capitulo-43-prolog-y-sql/index.md).

El capítulo continúa en la página [Las preguntas como
servicio](servicio.md#888-version-5-el-programa-el-bucle-y-el-servicio), con
la versión 5: el programa completo, el bucle de preguntas y el servicio con
hilos.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos, agregando cláusulas a sus
predicados `multifile` cuando hace falta.

4. ★ **(1)** Predecir qué responden la versión 1 y la versión 5 a
   «¿Quién no cursa lógica?», y explicar la diferencia. ¿Qué supuesto
   hace la versión 5 sobre los alumnos que no tienen ninguna inscripción?
5. ★ **(2)** Agregar el verbo «desaprobar»: un alumno desaprobó una
   materia si está inscripto y su nota es menor que 6. Agregar el lema
   al léxico, los tipos del verbo, la definición de
   `desaprobar/2` para `evaluar.pl` y su tabla para `sql.pl`, y
   comprobar «¿Quién desaprobó álgebra?» en Prolog y en SQL.
6. **(2)** «¿Qué alumnos de sistemas cursan paradigmas?» da una
   sentencia con dos veces la tabla `alumnos`. Explicar por qué, y
   escribir `simplificar(+Forma, -Simple)`, que reemplaza
   `y(alumno(X), carrera(X, C))` por `carrera(X, C)`. Comparar las dos
   sentencias y las dos respuestas.
7. ★ **(2)** Escribir `por_que_no_esta(+Texto, +Nombre, -Motivo)`, que
   explica por qué el alumno o la materia Nombre no está en la respuesta
   de una pregunta con «quién», «qué» o «cuántos». Aplicarlo a elena en
   «¿Quién aprobó análisis 1?» y a ana en «¿Quién no aprobó lógica?».
8. ★ **(2)** Escribir `pasos_sin_tabla/3`, la misma definición que
   `pasos/3` sin la tabla, y explicar qué ocurre con `pasos_sin_tabla(bd,
   R, N)`, usando `call_with_inference_limit/3`. Agregar luego, dentro de
   `snapshot/1`, la correlativa `correlativa(log, bd)`, que cierra un
   ciclo, y comprobar que `pasos/3` termina. ¿Qué hay que hacer antes de
   consultar `pasos/3` después del cambio?
9. **(2)** Escribir `responder_lecturas(+Texto, -Respuestas)`, que
   responde cada lectura de una pregunta ambigua, como pares
   Forma-Respuesta. Aplicarlo a «¿Qué necesita bases de datos?» y a
   «¿Qué necesita lógica?».
10. **(3)** Escribir `sql_presuposicion(+Forma, -SQL)`, una traducción
    de las preguntas de sí o no que da `NULL` cuando una pregunta con
    «todos» no tiene casos, y 1 o 0 en los demás casos. Comprobar en
    SQLite las preguntas 10, 14 y 16 de `ejemplo/2`.

## Referencias

- Fernando C. N. Pereira y Stuart M. Shieber, *Prolog and Natural-Language
  Analysis*, CSLI, 1987; reedición digital de Microtome Publishing, 2002 —
  apartado 5.2, «A Simple Dialogue Program». [Edición digital de
  Microtome](http://www.mtome.com/Publications/PNLA/pnla-digital.html). La
  [sección 88.6](#886-version-3-evaluar-y-explicar) compara la versión 3 con la
  conversión de la forma lógica de `talk` en una cláusula de Horn, con
  `clausify/3` y `setof/3`, que no alcanza a «who wrote every book?».
- David H. D. Warren y Fernando C. N. Pereira, «An Efficient Easily Adaptable
  System for Interpreting Natural Language Queries», *American Journal of
  Computational Linguistics* 8 (3–4), 1982, páginas 110–122. [ACL
  Anthology](https://aclanthology.org/J82-3002/). Describe Chat-80. Esta página
  toma de allí `todo/3` como doble negación, la separación entre el diccionario,
  que depende de la base, y la gramática, y la decisión opuesta sobre las
  presuposiciones ([sección 88.6](#886-version-3-evaluar-y-explicar)). Su
  planificación de las consultas, que reordena las metas según el tamaño de las
  relaciones ([sección 88.7](#887-version-4-la-forma-logica-en-sql)), se
  describe en David H. D. Warren, «Efficient processing of interactive
  relational database queries expressed in logic», VLDB, 1981, que el artículo
  cita.
- Veronica Dahl, «Translating Spanish into Logic through Logic»,
  *American Journal of Computational Linguistics* 7 (3), 1981, páginas
  149–164. [ACL Anthology](https://aclanthology.org/J81-3002/). Los
  sistemas de consulta de bases de datos en castellano, escritos en
  Prolog en la Universidad de Buenos Aires desde 1976, de los que partió
  Chat-80.
  Esta página toma de allí la presuposición de una pregunta con «todos»
  ([sección 88.6](#886-version-3-evaluar-y-explicar)).
