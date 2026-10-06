# El mini-SQL frente a SQLite

Esta página contiene la [sección 86.11](index.md#8611-el-mini-sql-frente-al-sql-del-capitulo-42) del
[capítulo 86](index.md): los pares SQL del [capítulo 42](../capitulo-42-prolog-y-sql/index.md) ejecutados en el mini-SQL y comparados con SQLite. El código está en `comparacion.pl`, en `ejemplos/capitulo-86/`, con sus pruebas.

## El mini-SQL frente a SQLite

Los ejercicios del [capítulo 42](../capitulo-42-prolog-y-sql/index.md#ejercicios)
son cincuenta pares de una sentencia SQL y su traducción a Prolog, con
57 verificaciones que una herramienta hace ejecutando cada sentencia en
SQLite. `comparacion.pl` ejecuta en el mini-SQL las sentencias de las 42
verificaciones que su subconjunto admite, sobre las mismas tablas, y compara las filas
con las de SQLite 3.50, guardadas en `sqlite/2`: en el mismo orden si la
sentencia tiene `ORDER BY`, y con las mismas repeticiones si no. Las
tablas de la empresa y de los vuelos se crean con `empresa/0`, en el
subconjunto del mini-SQL.

<!-- contexto: capitulo-86/comparacion.pl -->
```prolog
?- resumen(Coinciden, Total).
Coinciden = Total, Total = 42.

?- filas_par('30', Fs), sqlite('30', Ss).
Fs = Ss, Ss = [].
```

Los 42 coinciden (una prueba por par en `comparacion.plt`). Entre ellos
están los cinco pares en que el [capítulo 42](../capitulo-42-prolog-y-sql/index.md) mostró que la traducción
directa a Prolog da otras filas que SQL: `NOT IN` con un `NULL` en la
subconsulta (el par 30, que en SQL no da ninguna fila), `jefe <> 1` con
la directora sin jefe, la suma y el máximo de ningún salario, que son
`NULL` y no cero ni un fallo, y `NOT (nota >= 6)`. El mini-SQL da en
todos las filas de SQL, porque compila la semántica de SQL en lugar de
traducir la sintaxis. De las quince verificaciones que quedan fuera, tres
repiten la sentencia de otra (14, 16b y 32b) y dos no tienen sentencia
SQL (44b y 48); las otras diez usan lo que el mini-SQL no tiene:
`LEFT JOIN` (19 y 24), `WITH RECURSIVE` (33, 34, 35, 35b, 37, 38 y 48b)
y las claves foráneas de SQLite (45).

| Diferencia del [capítulo 42](../capitulo-42-prolog-y-sql/index.md#424-donde-difieren-bolsas-conjuntos-y-null) | Prolog escrito a mano | El mini-SQL |
|---|---|---|
| bolsas y conjuntos | una respuesta por demostración | `SELECT` da la bolsa; `DISTINCT`, `UNION`, `INTERSECT` y `EXCEPT` eliminan repetidas |
| `NULL` en una comparación | error, o una fila de más en la negación | dos polaridades: desconocida no cumple ninguna |
| `NULL = NULL` en una reunión | `null = null` unifica | la igualdad unificada deja `V \== null` |
| agregados de ninguna fila | `bagof/3` falla | `COUNT` 0, los demás `NULL` |
| claves y tipos | a cargo del programa | verificados en cada `INSERT` y `UPDATE` |
| recursión | regla recursiva, con tabla si hace falta | no la admite: una vista no se nombra a sí misma |
