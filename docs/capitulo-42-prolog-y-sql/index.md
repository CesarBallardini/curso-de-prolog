# Capítulo 42 — Prolog y SQL

Una base de datos relacional y un programa Prolog guardan la información de
la misma forma: como **relaciones**, conjuntos de tuplas. Una tabla de SQL
es un predicado definido por hechos, una consulta `SELECT` es una consulta
de Prolog, y una vista es una regla. El parecido llega lejos: las
operaciones del álgebra relacional se escriben como cláusulas, y cada
consulta de SQL de este capítulo tiene su traducción a Prolog. Las
diferencias están en lo que cada lenguaje supone: SQL trabaja con bolsas de
filas, tiene un valor `NULL` con una lógica de tres valores, y verifica las
claves y las restricciones del esquema; Prolog responde una vez por
demostración, aplica el supuesto de mundo cerrado sin excepciones, y no
verifica nada que el programa no verifique.

El capítulo es para quien ya conoce SQL. Sigue una escalera: las tablas
como hechos; las operaciones del álgebra relacional como cláusulas; la
agregación; los puntos donde los dos lenguajes difieren; las consultas
recursivas, con `WITH RECURSIVE` y con tablas; las claves y las
actualizaciones; y, al final, la misma base en SQLite, consultada desde
Prolog con `library(odbc)`. Los datos son los de *Inscripciones*, la
universidad de la parte II, más dos tablas para la recursión: los
empleados de una empresa y los vuelos entre aeropuertos.

Las fuentes son tres libros. *Logic, Programming and Prolog* de Ulf Nilsson
y Jan Małuszyński, capítulo «Logic and Databases», da la traducción del
álgebra relacional a cláusulas, la distinción entre la base extensional y
la intensional, y los supuestos de mundo cerrado y de dominio cerrado; su
capítulo «Query-answering in Deductive Databases» trata la evaluación de
abajo hacia arriba de las consultas recursivas (edición en línea de los
autores: [www.ida.liu.se/~ulfni53/lpp](https://www.ida.liu.se/~ulfni53/lpp/)).
*An Introduction to Logic Programming through Prolog* de J. M. Spivey,
capítulo «Programming with relations», plantea las consultas como vistas y
muestra la selección por sustitución de una constante y la reunión de una
relación consigo misma
([edición del autor](https://spivey.oriel.ox.ac.uk/wiki/files/logprog/logic.pdf)).
*Prolog for Programmers* de Feliks Kluźniak y Stanisław Szpakowicz,
apartado 8.2, «Prolog and Relational Data Bases», observa que un agregado
necesita la columna entera, que la integridad de la base queda a cargo del
programa, y traduce un lenguaje parecido a SQL, Toy-Sequel, a metas de
Prolog; el [capítulo 86](../capitulo-86-proyecto-mini-sql-prolog/index.md)
construye un intérprete así. La correspondencia entre las dos notaciones
sigue el plan de *An introduction to Prolog for SQL programmers*, el
cuaderno SWISH de Robert Laing. La biblioteca `library(odbc)` se usa
según su manual, *SWI-Prolog ODBC Interface*. La lista completa de las
fuentes está en las [Referencias](#referencias).

El capítulo cumple los anuncios de los capítulos [13](../capitulo-13-el-entorno-de-trabajo/index.md) (los datos de
*Inscripciones* como tablas de una base de datos), [14](../capitulo-14-estilo-y-documentacion/index.md) (el átomo `null`
que traduce el `NULL` de SQL), [17](../capitulo-17-todas-las-soluciones/index.md) (`GROUP BY` y las funciones de
agregación), [29](../capitulo-29-prolog-desde-python/index.md) (una base de datos SQL junto a Prolog), [38](../capitulo-38-semantica-de-los-programas-logicos/index.md)
(`WITH RECURSIVE` como evaluación semi-ingenua) y [39](../capitulo-39-tabulacion/index.md) (`WITH RECURSIVE`
frente a la tabulación). Todo corre sin ninguna base de datos instalada:
los programas son Prolog, y cada sentencia SQL del texto se ejecutó en
SQLite 3.50 sobre `references/ejercicios/sql-prolog/schema.sql`, que tiene
los mismos datos que los hechos. Solo la [sección 42.7](odbc.md#la-base-en-sqlite) necesita el
controlador ODBC de SQLite.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- traducir un esquema y sus filas a hechos, y una consulta `SELECT` a una
  consulta o a una regla de Prolog;
- escribir la selección, la proyección, la reunión, la unión, la
  diferencia y la intersección como cláusulas, y una vista como una regla;
- traducir `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING`, `DISTINCT`,
  `ORDER BY` y `LIMIT` a los predicados de todas las soluciones;
- predecir dónde difieren los resultados: filas repetidas, `NULL` y la
  lógica de tres valores, el mundo cerrado;
- escribir una consulta recursiva con `WITH RECURSIVE` y con una regla
  tabulada, y explicar por qué cada una termina o no;
- verificar en Prolog las claves y las restricciones que SQL verifica solo,
  y escribir actualizaciones que las respetan;
- copiar una base de hechos en SQLite y consultarla desde Prolog con
  `library(odbc)`, con sentencias preparadas.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:10 h**.
    Resolver los 6 ejercicios marcados con ★: **1:55 h**.
    Resolver los 14 ejercicios del final: **4:20 h**.

## 42.1 Tablas, filas y hechos

El esquema académico de `schema.sql` tiene cuatro tablas. Dos de ellas:

```sql
CREATE TABLE alumnos (
    legajo  INTEGER PRIMARY KEY,
    nombre  TEXT    NOT NULL,
    carrera TEXT    NOT NULL,
    ingreso INTEGER NOT NULL
);

CREATE TABLE inscripciones (
    legajo  INTEGER NOT NULL REFERENCES alumnos(legajo),
    materia TEXT    NOT NULL REFERENCES materias(codigo),
    nota    INTEGER CHECK (nota BETWEEN 1 AND 10),
    PRIMARY KEY (legajo, materia)
);
```

`universidad.pl` guarda las mismas filas como hechos. Cada tabla es un
predicado, cada fila un hecho y cada columna una posición de argumento, en
el orden del `CREATE TABLE`:

<!-- ejemplo: capitulo-42/universidad.pl predicado: alumno/4 -->
```prolog
% alumno(Legajo, Nombre, Carrera, Ingreso): la tabla alumnos.
alumno(101, ana,      sistemas,   2023).
alumno(102, bruno,    sistemas,   2024).
alumno(103, carla,    civil,      2023).
alumno(104, diego,    sistemas,   2024).
alumno(105, elena,    civil,      2025).
alumno(106, facundo,  industrial, 2024).
alumno(107, gabriela, industrial, 2025).
```

<!-- ejemplo: capitulo-42/universidad.pl predicado: inscripcion/3 -->
```prolog
% inscripcion(Legajo, Materia, Nota): la tabla inscripciones. Nota es null
% mientras el alumno cursa la materia.
inscripcion(101, am1, 8).
inscripcion(101, alg, 9).
inscripcion(101, log, 10).
inscripcion(101, am2, 7).
inscripcion(101, pp,  null).
inscripcion(102, am1, 4).
inscripcion(102, log, 6).
inscripcion(102, alg, 2).
inscripcion(103, am1, 7).
inscripcion(103, alg, 5).
inscripcion(103, am2, null).
inscripcion(104, log, 9).
inscripcion(104, alg, 7).
inscripcion(104, pp,  8).
inscripcion(105, am1, null).
inscripcion(106, log, 3).
inscripcion(106, am1, 6).
```

Son los hechos de *Inscripciones* del [capítulo 13](../capitulo-13-el-entorno-de-trabajo/index.md#137-el-proyecto-inscripciones),
con los mismos nombres. La tabla se nombra en plural porque nombra un
conjunto de filas; el predicado, en singular, porque cada hecho afirma algo
de un alumno. `materia/3` y `correlativa/2` completan el esquema, y las
cuatro tablas se declaran `dynamic` para poder modificarlas en la
[sección 42.6](restricciones.md#claves-restricciones-y-actualizaciones).

La traducción pierde dos cosas, y las dos vuelven en el capítulo. Las
columnas de SQL tienen nombre y las de Prolog solo posición: el tercer
argumento de `alumno/4` es la carrera porque así lo dice el comentario, y
una consulta que confunde el orden no produce ningún error (Spivey lo
señala como la primera diferencia práctica). Y una columna de SQL tiene un
tipo, mientras que un argumento de Prolog admite cualquier término:
`alumno(108, hugo, civil, dos_mil)` es un hecho válido. Nilsson y
Małuszyński llaman a este conjunto de hechos sin variables la **base
extensional**; las reglas que se agregan después forman la **base
intensional**.

El `NULL` de la nota se escribe con el átomo `null`, como anunció el
[capítulo 14](../capitulo-14-estilo-y-documentacion/index.md#146-representacion-de-los-datos). Para Prolog, `null` es un átomo como cualquier
otro; lo que eso cambia se ve en la [sección 42.4](#424-donde-difieren-bolsas-conjuntos-y-null).

La primera consulta, en los dos lenguajes:

```sql
SELECT legajo, nombre FROM alumnos WHERE carrera = 'sistemas';
```

```text
legajo  nombre
------  ------
101     ana
102     bruno
104     diego
```

```prolog
?- alumno(L, N, sistemas, _).
L = 101,
N = ana ;
L = 102,
N = bruno ;
L = 104,
N = diego.
```

La condición `carrera = 'sistemas'` se escribe poniendo la constante en su
posición: Spivey muestra que una selección por igualdad equivale a
sustituir la variable por la constante. Las columnas del `SELECT` son las
variables que la consulta nombra; `_` es una columna que no se pide. SQL
devuelve una tabla entera; Prolog, una respuesta por vez.

La correspondencia completa, que el resto del capítulo recorre:

| SQL | Prolog |
|---|---|
| tabla | predicado definido por hechos |
| fila | hecho |
| columna | posición de argumento |
| `SELECT … WHERE` | consulta; las condiciones son metas |
| columnas del `SELECT` (proyección) | las variables que se piden |
| `JOIN … ON` | metas que comparten una variable |
| `UNION` | varias cláusulas |
| `EXCEPT`, `NOT EXISTS` | `\+` |
| `INTERSECT` | conjunción |
| `CREATE VIEW` | regla |
| `WITH RECURSIVE` | regla recursiva, tabulada |
| `COUNT`, `SUM`, `MAX`, `GROUP BY` | `aggregate_all/3`, `bagof/3` |
| `DISTINCT`, `ORDER BY`, `LIMIT` | `setof/3`, `order_by/2`, `limit/2` |
| `INSERT`, `DELETE`, `UPDATE` | `assertz/1`, `retract/1` |
| `NULL` | el átomo `null`, o la ausencia del hecho |

!!! question "Actividad"
    Predecir, sin ejecutarlas, cuántas respuestas dan
    `inscripcion(101, M, N)`, `inscripcion(L, am2, N)` y
    `alumno(_, N, C, 2025)`, y escribir la sentencia SQL de cada una.
    Comprobarlas en los dos lenguajes.

## 42.2 El álgebra relacional en cláusulas

El álgebra relacional tiene cinco operaciones primitivas: la unión, la
diferencia, el producto cartesiano, la proyección y la selección; las demás,
como la reunión y la intersección, se definen con ellas. Nilsson y
Małuszyński muestran que cada una se escribe como una cláusula (la
diferencia, con negación), y que una **vista**, una relación que no se
guarda sino que se calcula, es una regla. Las vistas de esta sección están
en `universidad.pl`.

**Selección y proyección.** Una regla con menos argumentos que la tabla
proyecta; una constante o una comparación en el cuerpo selecciona. Un
argumento de la cabeza puede quedar como parámetro de la vista:

<!-- ejemplo: capitulo-42/universidad.pl predicado: de_carrera/3 -->
```prolog
%!  de_carrera(?Carrera, ?Legajo, ?Nombre) is nondet.
%
%   Selección y proyección de alumnos: el legajo y el nombre de los alumnos
%   de Carrera.
de_carrera(Carrera, Legajo, Nombre) :-
    alumno(Legajo, Nombre, Carrera, _).
```

`de_carrera(sistemas, L, N)` es la consulta de la sección anterior, y
`de_carrera(C, 103, N)` busca en sentido inverso la carrera de un legajo:
una vista de SQL tiene columnas de salida, y una regla tiene argumentos que
sirven de entrada o de salida.

**Reunión.** Dos metas que comparten una variable reúnen sus tablas por esa
columna. La condición `ON` desaparece: está escrita en el nombre repetido
`Legajo`.

```sql
SELECT a.nombre, i.nota
FROM inscripciones i JOIN alumnos a ON a.legajo = i.legajo
WHERE i.materia = 'am1';
```

<!-- ejemplo: capitulo-42/universidad.pl predicado: acta/3 -->
```prolog
%!  acta(?Materia, ?Alumno, ?Nota) is nondet.
%
%   Reunión de inscripciones con alumnos por el legajo: el nombre de cada
%   alumno inscripto en Materia, con su nota.
acta(Materia, Alumno, Nota) :-
    inscripcion(Legajo, Materia, Nota),
    alumno(Legajo, Alumno, _, _).
```

```prolog
?- acta(am1, Alumno, Nota).
Alumno = ana,
Nota = 8 ;
Alumno = bruno,
Nota = 4 ;
Alumno = carla,
Nota = 7 ;
Alumno = elena,
Nota = null ;
Alumno = facundo,
Nota = 6.
```

SQLite da las mismas cinco filas, con `NULL` en la de elena.

**Reunión de una tabla consigo misma.** En SQL, cada aparición de la tabla
lleva un alias; en Prolog, cada meta tiene sus propias variables. Spivey
insiste en el detalle: dos apariciones que comparten una variable quedan
reunidas por esa columna, y dos que usan variables distintas, no. Los pares
de alumnos inscriptos en la misma materia:

<!-- ejemplo: capitulo-42/universidad.pl predicado: companeros/3 -->
```prolog
%!  companeros(?Materia, ?Alumno1, ?Alumno2) is nondet.
%
%   Reunión de inscripciones consigo misma: dos alumnos distintos inscriptos
%   en la misma Materia, cada par una sola vez.
companeros(Materia, Alumno1, Alumno2) :-
    inscripcion(L1, Materia, _),
    inscripcion(L2, Materia, _),
    L1 < L2,
    alumno(L1, Alumno1, _, _),
    alumno(L2, Alumno2, _, _).
```

```sql
SELECT a1.nombre, a2.nombre
FROM inscripciones i1
JOIN inscripciones i2 ON i1.materia = i2.materia AND i1.legajo < i2.legajo
JOIN alumnos a1 ON a1.legajo = i1.legajo
JOIN alumnos a2 ON a2.legajo = i2.legajo
WHERE i1.materia = 'log';
```

```prolog
?- findall(A1-A2, companeros(log, A1, A2), Pares).
Pares = [ana-bruno, ana-diego, ana-facundo, bruno-diego, bruno-facundo, diego-facundo].
```

Las dos dan los mismos seis pares. `L1 < L2` cumple el mismo papel en los
dos: sin él, cada alumno forma par consigo mismo y cada par aparece dos
veces.

**Unión.** Dos cláusulas con la misma cabeza son la unión de lo que define
cada una:

<!-- ejemplo: capitulo-42/universidad.pl predicado: vinculada/1 -->
```prolog
%!  vinculada(?Materia) is nondet.
%
%   Unión: Materia exige una correlativa o es correlativa de otra. Una
%   respuesta por cada fila de correlativas que la nombra.
vinculada(Materia) :-
    correlativa(Materia, _).
vinculada(Materia) :-
    correlativa(_, Materia).
```

```sql
SELECT materia FROM correlativas
UNION
SELECT requisito FROM correlativas;
```

SQL responde las siete materias, una vez cada una. Prolog responde
catorce veces, una por cada fila de `correlativa/2` que nombra la materia:
la [sección 42.4](#424-donde-difieren-bolsas-conjuntos-y-null) explica por qué.

**Diferencia.** La diferencia necesita negación, y `\+` es la negación por
falla del [capítulo 10](../capitulo-10-negacion-como-falla/index.md). Las materias que no exigen correlativas:

<!-- ejemplo: capitulo-42/universidad.pl predicado: sin_correlativas/1 -->
```prolog
%!  sin_correlativas(?Materia) is nondet.
%
%   Diferencia: las materias que no exigen ninguna correlativa. materia/3
%   liga Materia antes de la negación.
sin_correlativas(Materia) :-
    materia(Materia, _, _),
    \+ correlativa(Materia, _).
```

```sql
SELECT codigo FROM materias
EXCEPT
SELECT materia FROM correlativas;
```

```prolog
?- sin_correlativas(M).
M = am1 ;
M = alg ;
M = log ;
false.

?- \+ correlativa(M, _), materia(M, _, _).
false.
```

La segunda consulta tiene las mismas metas en otro orden, y no responde
nada: `\+ correlativa(M, _)` con `M` libre pregunta si no se puede probar
que *alguna* materia exige correlativas, y eso es falso. SQL no tiene este
problema, porque la subconsulta de `NOT EXISTS` se evalúa para cada fila
externa; en Prolog, la meta que liga la variable va antes de la negación
([sección 10.4](../capitulo-10-negacion-como-falla/index.md#104-donde-ubicar)).

**Intersección.** Es una conjunción, y también una reunión por todas las
columnas:

<!-- ejemplo: capitulo-42/universidad.pl predicado: en_ambas/3 -->
```prolog
%!  en_ambas(?Materia1, ?Materia2, ?Legajo) is nondet.
%
%   Intersección: el alumno de Legajo está inscripto en las dos materias.
en_ambas(Materia1, Materia2, Legajo) :-
    inscripcion(Legajo, Materia1, _),
    inscripcion(Legajo, Materia2, _).
```

`en_ambas(am1, alg, L)` da 101, 102 y 103, como el `INTERSECT` de los
legajos inscriptos en cada materia.

**Vistas de vistas.** La regla de aprobación que el [capítulo 14](../capitulo-14-estilo-y-documentacion/index.md#146-representacion-de-los-datos)
citaba es una vista:

<!-- ejemplo: capitulo-42/universidad.pl predicado: aprobada/3 -->
```prolog
%!  aprobada(?Legajo, ?Materia, ?Nota) is nondet.
%
%   El alumno de Legajo aprobó Materia con Nota: una selección sobre
%   inscripciones. integer/1 descarta las filas con null antes de comparar.
aprobada(L, M, N) :-
    inscripcion(L, M, N),
    integer(N),
    N >= 6.
```

```sql
CREATE VIEW aprobadas AS
  SELECT legajo, materia, nota FROM inscripciones
  WHERE nota >= 6;
```

Una vista se usa como una tabla, en otras vistas o en consultas, y lo mismo
una regla: para el programa que consulta `aprobada/3` es indistinto si
está guardada o se calcula. Esa es la ventaja que Nilsson y Małuszyński
destacan: hechos, reglas y consultas se escriben en un solo lenguaje.

## 42.3 Agregación, agrupación y orden

Kluźniak y Szpakowicz observan que una selección o una reunión se responde
fila por fila, pero un agregado necesita la columna entera. Los predicados
de todas las soluciones del [capítulo 17](../capitulo-17-todas-las-soluciones/index.md) reúnen esa columna:
`aggregate_all/3` calcula `count`, `sum`, `max` o `min` sobre todas las
respuestas de una meta, y `bagof/3` agrupa por las variables libres que no
están cuantificadas con `^`, que es lo que hace `GROUP BY`.

```sql
SELECT materia, COUNT(*) FROM inscripciones GROUP BY materia;
```

```text
materia  COUNT(*)
-------  --------
alg      4
am1      5
am2      2
log      4
pp       2
```

<!-- ejemplo: capitulo-42/universidad.pl predicado: inscriptos_grupo/2 inscriptos/2 -->
```prolog
%!  inscriptos_grupo(?Materia, ?Cantidad) is nondet.
%
%   Lo mismo con bagof/3, que agrupa como GROUP BY: una materia sin
%   inscriptos no forma grupo.
inscriptos_grupo(Materia, Cantidad) :-
    bagof(L, N^inscripcion(L, Materia, N), Ls),
    length(Ls, Cantidad).

%!  inscriptos(?Materia, ?Cantidad) is nondet.
%
%   Cantidad de alumnos inscriptos en cada materia del plan, incluidas las
%   que no tienen ninguno.
inscriptos(Materia, Cantidad) :-
    materia(Materia, _, _),
    aggregate_all(count, inscripcion(_, Materia, _), Cantidad).
```

```prolog
?- findall(M-K, inscriptos_grupo(M, K), Grupos).
Grupos = [alg-4, am1-5, am2-2, log-4, pp-2].

?- findall(M-K, inscriptos(M, K), Todas).
Todas = [am1-5, alg-4, log-4, am2-2, pp-2, ssl-0, bd-0].
```

`inscriptos_grupo/2` da los mismos cinco grupos que `GROUP BY`, y en el
mismo orden, porque `bagof/3` ordena los grupos. Una materia sin
inscriptos no forma grupo en ninguno de los dos. `inscriptos/2` recorre
las materias y cuenta, y da cero para `ssl` y `bd`: es la consulta con
`LEFT JOIN`.

```sql
SELECT m.codigo, COUNT(i.legajo)
FROM materias m LEFT JOIN inscripciones i ON i.materia = m.codigo
GROUP BY m.codigo;
```

`HAVING` es una condición sobre el grupo ya calculado, y en Prolog es una
meta después del agregado. `ORDER BY` y `LIMIT` son `order_by/2` y
`limit/2` de `library(solution_sequences)`
([sección 17.7](../capitulo-17-todas-las-soluciones/index.md#177-librarysolution_sequences)), y `DISTINCT` con `ORDER BY` es `setof/3`:

```sql
SELECT materia, COUNT(*) AS k FROM inscripciones
GROUP BY materia ORDER BY k DESC, materia LIMIT 2;
```

```prolog
?- inscriptos_grupo(M, K), K >= 4.
M = alg,
K = 4 ;
M = am1,
K = 5 ;
M = log,
K = 4 ;
false.

?- findall(M-K, limit(2, order_by([desc(K), asc(M)], inscriptos(M, K))), L).
L = [am1-5, alg-4].
```

SQLite da `am1 5` y `alg 4`. El segundo criterio, `materia`, hace falta en
los dos lenguajes: sin él, el empate entre `alg` y `log` se resuelve de
cualquier manera, y en esta prueba SQLite eligió `log` y Prolog `alg`.

`AVG` necesita otra precaución. Ignora los `NULL`: el promedio de `am1` es
el de cuatro notas, no el de cinco filas. En Prolog, la meta que junta las
notas tiene que descartar `null` explícitamente:

<!-- ejemplo: capitulo-42/universidad.pl predicado: promedio/2 -->
```prolog
%!  promedio(?Materia, ?Promedio) is nondet.
%
%   Promedio de las notas de Materia, sin las filas con null, como AVG. Las
%   materias sin ninguna nota no tienen promedio.
promedio(Materia, Promedio) :-
    bagof(N, L^(inscripcion(L, Materia, N), integer(N)), Notas),
    sum_list(Notas, Suma),
    length(Notas, Cantidad),
    Promedio is Suma / Cantidad.
```

```prolog
?- findall(M-P, promedio(M, P), Ps).
Ps = [alg-5.75, am1-6.25, am2-7, log-7, pp-8].
```

SQLite da los mismos valores, pero como números de punto flotante: `7.0`
y `8.0`. En Prolog, `/` entre enteros da un entero cuando la división es
exacta ([capítulo 8](../capitulo-08-aritmetica/index.md)).

## 42.4 Donde difieren: bolsas, conjuntos y NULL

**Bolsas y conjuntos.** Una relación del álgebra relacional es un conjunto:
no tiene filas repetidas. Una tabla de SQL es una **bolsa**:
`SELECT carrera FROM alumnos` da siete filas con tres valores distintos, y
hace falta `DISTINCT` para obtener el conjunto. Prolog tampoco elimina
repetidos: da una respuesta por cada demostración. `vinculada/1` responde
catorce veces porque hay catorce filas de correlativas que nombran una
materia:

```prolog
?- aggregate_all(count, vinculada(_), K).
K = 14.

?- setof(M, vinculada(M), Ms).
Ms = [alg, am1, am2, bd, log, pp, ssl].
```

Las cláusulas de Prolog son, entonces, un `UNION ALL`, y `setof/3` es el
`UNION`. Una tercera forma de obtener un conjunto es la tabla del
[capítulo 39](../capitulo-39-tabulacion/index.md): un predicado tabulado guarda cada respuesta una vez.

**NULL y la lógica de tres valores.** En SQL, una comparación con `NULL` no
es verdadera ni falsa, sino desconocida, y `WHERE` descarta las filas en
que la condición no es verdadera. Por eso una condición y su negación no
cubren todas las filas:

```sql
SELECT COUNT(*) FROM inscripciones;                       -- 17
SELECT COUNT(*) FROM inscripciones WHERE nota >= 6;       -- 10
SELECT COUNT(*) FROM inscripciones WHERE NOT (nota >= 6); -- 4
```

Las tres inscripciones sin nota no están en ninguno de los dos grupos. En
Prolog no hay un tercer valor: `\+` es verdadero cuando la meta no se puede
probar, y las filas con `null` quedan del lado de la negación.

```prolog
?- aggregate_all(count, aprobada(_, _, _), K).
K = 10.

?- aggregate_all(count, (inscripcion(L, M, N), \+ aprobada(L, M, N)), K).
K = 7.
```

Las diez aprobadas y las siete restantes suman las diecisiete filas: las
cuatro con nota menor que 6 y las tres sin nota.

```text
?- null >= 6.
ERROR: Arithmetic: `null/0' is not a function
```

La comparación directa ni siquiera falla: `null` no es una expresión
aritmética, y `>=/2` lanza un error. Por eso `aprobada/3` pregunta
`integer(N)` antes de comparar. Hay más casos del mismo tipo: en SQL,
`NULL = NULL` es desconocido, y en Prolog `null = null` es verdadero, así
que una reunión por una columna con nulos da en Prolog filas que SQL no da;
y `jefe <> 1` no es verdadero para la directora, cuyo jefe es `NULL`,
mientras que `J \== 1` sí lo es ([ejercicio 10](#ejercicios)).

La otra forma de representar un dato ausente es no escribir el hecho:
guardar las notas en una relación aparte, `nota(Legajo, Materia, Nota)`,
solo para las inscripciones que tienen nota. Entonces `\+ nota(L, M, _)`
dice exactamente «todavía sin nota», sin átomos especiales; el precio es
una tabla más y una reunión en cada consulta que necesita la nota. El
[capítulo 14](../capitulo-14-estilo-y-documentacion/index.md#146-representacion-de-los-datos) discutió esa elección.

**El mundo cerrado.** Nilsson y Małuszyński enuncian los dos supuestos de
una base deductiva: el de **mundo cerrado**, lo que no se deduce de la base
es falso ([sección 10.1](../capitulo-10-negacion-como-falla/index.md#101-el-supuesto-de-mundo-cerrado)), y el de **dominio cerrado**, los únicos
individuos que existen son los que la base nombra. `NOT EXISTS` y `EXCEPT`
aplican el mundo cerrado igual que `\+`: una materia que no está en
`correlativas` no tiene correlativas. `NULL` es el único lugar donde SQL
admite «no se sabe»; en Prolog, esa distinción la hace el programa, con un
átomo o con una relación aparte.

!!! question "Actividad"
    Predecir cuántas filas da, en SQL y en Prolog,
    «las inscripciones que no son de am1 con nota 8», escrita en SQL como
    `WHERE NOT (materia = 'am1' AND nota = 8)` y en Prolog como
    `inscripcion(L, M, N), \+ (M == am1, N == 8)`. Comprobarlo, y explicar
    la diferencia fila por fila.

## 42.5 Consultas recursivas: `WITH RECURSIVE` y tablas

Los superiores de un empleado y los aeropuertos que se alcanzan desde otro
son relaciones recursivas, y SQL las escribe con `WITH RECURSIVE`. La página
[Consultas recursivas](recursion.md#consultas-recursivas) muestra que SQLite
las evalúa de forma semi-ingenua, como la
[sección 38.6](../capitulo-38-semantica-de-los-programas-logicos/index.md#386-evaluacion-de-abajo-hacia-arriba), y lo reproduce en Prolog; compara `UNION` y
`UNION ALL` en un grafo con ciclos con la regla sin tabla y con la tabla del
[capítulo 39](../capitulo-39-tabulacion/index.md); y calcula el precio mínimo, que SQLite no admite como
agregado recursivo, con una tabla con subsunción de respuestas.

## 42.6 Claves, restricciones y actualizaciones

`INSERT`, `DELETE` y `UPDATE` son `assertz/1` y `retract/1`, pero Prolog no
verifica las claves ni las referencias que SQLite verifica solo. La página
[Claves, restricciones y actualizaciones](restricciones.md#claves-restricciones-y-actualizaciones)
escribe el esquema como hechos, obtiene las restricciones violadas con una
consulta, `violacion/1`, y escribe `insertar/1`, `borrar/1` y
`poner_nota/3`, que verifican antes de cambiar la base.

## 42.7 `library(odbc)`: la base en SQLite

La página [La base en SQLite](odbc.md#la-base-en-sqlite) copia la base
académica en SQLite desde Prolog, con las sentencias `CREATE TABLE` escritas
a partir del esquema y un `INSERT` preparado con parámetros, y la consulta
con `odbc_query/3`. Necesita el controlador ODBC de SQLite; sin él, sus
pruebas se bloquean y avisan por qué. Es la única parte del capítulo que no
corre sin una base de datos instalada.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada regla declara modos y determinación; las vistas admiten sus argumentos en cualquier modo, como una tabla, y las que tienen un modo que no terminaría (`destino_sin_tabla/2`) lo declaran |
    | C3 | las vistas son las cláusulas del álgebra relacional sin argumentos de control: `acta/3` o `de_carrera/3` se consultan también en sentido inverso |
    | C5 | una fila que viola el esquema produce un error, `error(restriccion(V), _)`, como en SQLite, y no un `false.` que se confunda con «no hay filas»; la nota `null` no llega a una comparación aritmética, que lanzaría un error de tipo |
    | C6 | el esquema es un conjunto de hechos, y `violacion/1` es una consulta pura sobre ellos; las actualizaciones, `insertar/1`, `borrar/1` y `poner_nota/3`, verifican antes de cambiar la base y dejan todo el efecto al final |
    | C7 | 80 pruebas, y 8 más con el controlador ODBC; cada consulta del texto se compara con el resultado de SQLite, y las pruebas que actualizan la base corren dentro de `snapshot/1`; las pruebas de ODBC se bloquean con un aviso si falta el controlador |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos. Cada
ejercicio se plantea en SQL y en Prolog; la sentencia SQL se ejecuta sobre
`schema.sql` en cualquier SQLite, y la consulta Prolog con `universidad.pl`
o con `recursion.pl` cargado.

1. ★ **(1)** Predecir las filas de
   `SELECT nombre, carrera, ingreso FROM alumnos WHERE ingreso >= 2024 AND carrera <> 'civil';`,
   escribir la consulta Prolog equivalente y comprobar las dos.
2. **(1)** `SELECT carrera FROM alumnos;` y
   `SELECT DISTINCT carrera FROM alumnos ORDER BY carrera;`: ¿cuántas filas
   da cada una? Escribir las dos en Prolog.
3. ★ **(2)** Escribir en Prolog `aprobada_con_nombres(Alumno, Materia,
   Nota)`, la reunión de las tres tablas de
   `SELECT a.nombre, m.nombre, i.nota FROM inscripciones i JOIN alumnos a ON a.legajo = i.legajo JOIN materias m ON m.codigo = i.materia WHERE i.nota >= 6;`.
   ¿Qué ocurre si se omite `integer(Nota)`?
4. **(2)** Escribir en SQL y en Prolog los pares de alumnos distintos de
   la misma carrera, cada par una vez. ¿Cuántos pares da cada lenguaje si
   `a1.legajo < a2.legajo` se reemplaza por `a1.legajo <> a2.legajo`, y
   `L1 < L2` por `L1 \== L2`?
5. ★ **(2)** Predecir cuántas filas da la unión de los legajos inscriptos
   en am1 con los inscriptos en log, con `UNION` y con `UNION ALL`.
   Escribir en Prolog `en_am1_o_log/1` con dos cláusulas y obtener los dos
   resultados.
6. ★ **(2)** Escribir en SQL, con `NOT EXISTS`, y en Prolog, con `\+`, los
   alumnos que no tienen ninguna inscripción. Predecir la respuesta de la
   consulta Prolog con las dos metas en el orden inverso, y comprobarla.
7. **(3)** Los alumnos que aprobaron **todas** las materias de primer año:
   escribirlo en SQL con dos `NOT EXISTS` anidados y en Prolog con
   `forall/2`, y explicar por qué las dos formas dicen lo mismo.
8. **(2)** `SELECT legajo, AVG(nota) FROM inscripciones GROUP BY legajo;`
   da una fila con `NULL`. Escribir `promedio_alumno/2` y explicar qué pasa
   con esa fila en Prolog.
9. **(2)** Una restricción que ningún `CHECK` expresa: un alumno no puede
   estar inscripto en una materia sin haber aprobado sus correlativas.
   Escribir en SQL la consulta que da las inscripciones que la violan, y en
   Prolog `correlativa_pendiente(Legajo, Materia, Requisito)`. ¿Cumplen los
   datos la restricción?
10. ★ **(2)** Predecir las filas de
    `SELECT nombre FROM empleados WHERE jefe <> 1;` y las respuestas de
    `empleado(_, N, _, _, J), J \== 1`, con `recursion.pl`. Explicar la
    diferencia y escribir `no_depende_de(Nombre, Jefe)` para que Prolog dé
    lo mismo que SQL.
11. **(2)** Predecir el resultado de cada consulta, en SQL y en Prolog:
    `SELECT COUNT(*) FROM alumnos WHERE carrera = 'quimica';` ·
    la misma con `GROUP BY carrera` · `SELECT SUM(salario), MAX(salario)
    FROM empleados WHERE depto = 'legal';`, con `aggregate_all/3` y
    `bagof/3`.
12. **(2)** El nivel de cada empleado es la cantidad de jefes que tiene
    por encima; la directora tiene nivel 0. Escribirlo en SQL con
    `WITH RECURSIVE` y en Prolog con `nivel(Id, Nivel)`.
13. ★ **(3)** Escribir en SQL una consulta con `WITH RECURSIVE` que dé el
    menor precio para llegar desde ros a cada destino y que termine, con un
    contador de vuelos acotado. Justificar la cota elegida, escribir la
    misma idea en Prolog sin tabla, `tarifa_con_tope/3`, y comparar el
    resultado con `tarifa/3`.
14. **(2)** Escribir `aumentar(Depto, Porcentaje)`, el
    `UPDATE empleados SET salario = salario * 110 / 100 WHERE depto = 'it';`
    de Prolog, con `retract/1` y `assertz/1`. ¿Por qué los empleados que
    agrega no se vuelven a aumentar?

## Resumen

| | |
|---|---|
| **base extensional** | los hechos sin variables: las filas de las tablas |
| **base intensional** | las reglas: las vistas que se calculan a partir de los hechos |
| **vista** | una relación calculada; en Prolog, una regla |
| **bolsa** | una colección con repeticiones: las filas de SQL y las respuestas de Prolog |
| **lógica de tres valores** | en SQL, una comparación con `NULL` es desconocida, y `WHERE` descarta la fila |
| **supuesto de dominio cerrado** | los únicos individuos que existen son los que la base nombra |
| **tabla de trabajo** | las filas nuevas de un paso de `WITH RECURSIVE`; lo único que se reúne en el paso siguiente |
| **sentencia preparada** | una sentencia SQL con parámetros `?`, compilada una vez y ejecutada con valores |
| `odbc_driver_connect/3` | abre una conexión con una cadena de controlador; la opción `null(T)` elige cómo llega `NULL` |
| `odbc_query/2`, `odbc_query/3`, `odbc_query/4` | ejecuta una sentencia; las filas llegan como `row(…)` al reintentar, o en una lista con `findall/2` |
| `odbc_prepare/4`, `odbc_execute/2`, `odbc_execute/3` | prepara una sentencia con parámetros y la ejecuta con una lista de valores |
| `odbc_free_statement/1`, `odbc_disconnect/1` | libera una sentencia preparada; cierra una conexión |
| `universidad.pl` | las tablas académicas, las vistas (`acta/3`, `companeros/3`, …, y la `aprobada` de *Inscripciones*, del [capítulo 14](../capitulo-14-estilo-y-documentacion/index.md)) y los agregados |
| `tabla/3`, `clave/2`, `referencia/4`, `violacion/1` | el esquema como hechos, y sus restricciones como consulta |
| `insertar/1`, `borrar/1`, `poner_nota/3` | `INSERT`, `DELETE` y `UPDATE` que respetan el esquema |
| `superior/2`, `destino/2`, `tarifa/3`, `iteraciones/2` | la recursión con regla, con tabla, con tabla y mínimo, y paso a paso como SQL |
| `base.pl`, `sqlite.pl` | la base como módulo, y su copia en SQLite con ODBC |
| `nb_current/2` | el valor de una variable global, si existe; en las pruebas |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Un motor Datalog, de abajo hacia arriba, con evaluación semi-ingenua | [capítulo 85](../capitulo-85-proyecto-motor-datalog/index.md) |
| Un intérprete de un subconjunto de SQL escrito en Prolog | [capítulo 86](../capitulo-86-proyecto-mini-sql-prolog/index.md) |
| Preguntas en castellano traducidas a SQL y ejecutadas contra `base.pl` | [capítulo 87](../capitulo-87-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- Ulf Nilsson y Jan Małuszyński, *Logic, Programming and Prolog*, 2.ª
  edición, John Wiley & Sons, 1995 — capítulos «Logic and Databases» y
  «Query-answering in Deductive Databases».
  [Edición en línea de los autores](https://www.ida.liu.se/~ulfni53/lpp/).
  El capítulo toma de allí el álgebra relacional como cláusulas
  ([sección 42.2](#422-el-algebra-relacional-en-clausulas)), la base
  extensional y la intensional, los supuestos de mundo cerrado y de
  dominio cerrado ([sección 42.4](#424-donde-difieren-bolsas-conjuntos-y-null))
  y la evaluación de abajo hacia arriba de las consultas recursivas
  ([sección 42.5](recursion.md#consultas-recursivas)).
- J. M. Spivey, *An Introduction to Logic Programming through Prolog*,
  Prentice Hall, 1996 — capítulo «Programming with relations».
  [Edición del autor](https://spivey.oriel.ox.ac.uk/wiki/files/logprog/logic.pdf).
  De allí vienen las consultas como vistas, la selección como sustitución
  de una constante y la reunión de una relación consigo misma
  ([sección 42.2](#422-el-algebra-relacional-en-clausulas)).
- Feliks Kluźniak y Stanisław Szpakowicz, *Prolog for Programmers*,
  Academic Press, 1985 — apartado 8.2, «Prolog and Relational Data
  Bases». Sin edición en línea de acceso libre verificada. El capítulo
  toma la observación de que un agregado necesita la columna entera
  ([sección 42.3](#423-agregacion-agrupacion-y-orden)) y de que la
  integridad queda a cargo del programa
  ([sección 42.6](restricciones.md#claves-restricciones-y-actualizaciones));
  su Toy-Sequel es el antecedente del
  [capítulo 86](../capitulo-86-proyecto-mini-sql-prolog/index.md).
- Robert Laing, *An introduction to Prolog for SQL programmers*, cuaderno
  de SWISH. [Cuaderno en SWISH](https://swish.swi-prolog.org/p/sql2prolog.swinb).
  Sirvió de modelo para la correspondencia entre las consultas de SQL y
  las de Prolog ([sección 42.1](#421-tablas-filas-y-hechos)).
- Jan Wielemaker, *SWI-Prolog ODBC Interface*, el manual de
  `library(odbc)`.
  [Manual en línea](https://www.swi-prolog.org/pldoc/doc_for?object=section(%27packages/odbc.html%27)).
  Describe `odbc_driver_connect/3`, `odbc_query/2..4`, las sentencias
  preparadas y la opción `null(T)` que usa la
  [sección 42.7](odbc.md#la-base-en-sqlite).
- Christian Werner, *SQLite ODBC Driver*.
  [Página del controlador](http://www.ch-werner.de/sqliteodbc/). Es el
  controlador que la [sección 42.7](odbc.md#la-base-en-sqlite) instala en
  Windows.

Los programas y los datos del capítulo son propios del curso: ninguno se
copia de las fuentes, que aportan las ideas y la correspondencia entre los
dos lenguajes.

## Cierre de la parte III

La parte III recorrió lo que Prolog permite una vez que las prácticas
profesionales de la parte II están en su lugar. Los capítulos
[32](../capitulo-32-inspeccion-de-terminos/index.md) a [35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md) trataron los términos y los programas como datos:
inspeccionarlos, interpretarlos con un metaintérprete, completarlos por
unificación con estructuras incompletas, y transformarlos al cargarlos.
Los capítulos [36](../capitulo-36-interfaces-de-usuario/index.md) y [37](../capitulo-37-concurrencia-y-paralelismo/index.md) llevaron los programas a una pantalla, a una
ventana, a la web y a varios hilos. El [capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md) definió qué significa
un programa, y el [39](../capitulo-39-tabulacion/index.md) mostró cómo SWI-Prolog calcula ese significado
con tablas. Los capítulos [40](../capitulo-40-busqueda-y-planificacion/index.md) y [41](../capitulo-41-juegos/index.md) resolvieron problemas como
búsquedas en un espacio de estados, y este capítulo relacionó los programas
lógicos con las bases de datos relacionales.

La parte IV, «Proyectos», va del [capítulo 43](../capitulo-43-proyecto-resolver-ecuaciones/index.md) al
[87](../capitulo-87-proyecto-preguntas-en-castellano/index.md). Cada capítulo construye un programa completo, en versiones, con las
técnicas de las tres partes: un programa que resuelve ecuaciones, una aventura de
texto, un compilador, y así hasta un motor Datalog, un intérprete de SQL y
un programa que responde preguntas en castellano sobre la base de este
capítulo.
