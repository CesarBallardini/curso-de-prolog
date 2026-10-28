# El mini-SQL frente a SQLite

Esta página continúa la página [Las vistas](vistas.md#8710-version-8-las-vistas) del
[capítulo 87](index.md), con la sección
[87.11](#8711-el-mini-sql-frente-al-sql-del-capitulo-43), la última: los
pares SQL del [capítulo 43](../capitulo-43-prolog-y-sql/index.md)
ejecutados en el mini-SQL y comparados con SQLite. El código está en
`comparacion.pl`, en `ejemplos/capitulo-87/`, con sus pruebas.

## 87.11 El mini-SQL frente al SQL del capítulo 43

Los ejercicios del [capítulo 43](../capitulo-43-prolog-y-sql/index.md#ejercicios)
son cincuenta pares de una sentencia SQL y su traducción a Prolog, con
57 verificaciones que una herramienta hace ejecutando cada sentencia en
SQLite. `comparacion.pl` ejecuta en el mini-SQL las sentencias de las 42
verificaciones que su subconjunto admite, sobre las mismas tablas, y compara las filas
con las de SQLite 3.50, guardadas en `sqlite/2`: en el mismo orden si la
sentencia tiene `ORDER BY`, y con las mismas repeticiones si no. Las
tablas de la empresa y de los vuelos se crean con `empresa/0`, en el
subconjunto del mini-SQL.

<!-- contexto: capitulo-87/comparacion.pl -->
```prolog
?- resumen(Coinciden, Total).
Coinciden = Total, Total = 42.

?- filas_par('30', Fs), sqlite('30', Ss).
Fs = Ss, Ss = [].
```

Los 42 coinciden (una prueba por par en `comparacion.plt`). Entre ellos
están los cinco pares en que el [capítulo 43](../capitulo-43-prolog-y-sql/index.md) mostró que la traducción
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

| Diferencia del [capítulo 43](../capitulo-43-prolog-y-sql/index.md#434-donde-difieren-bolsas-conjuntos-y-null) | Prolog escrito a mano | El mini-SQL |
|---|---|---|
| bolsas y conjuntos | una respuesta por demostración | `SELECT` da la bolsa; `DISTINCT`, `UNION`, `INTERSECT` y `EXCEPT` eliminan repetidas |
| `NULL` en una comparación | error, o una fila de más en la negación | dos polaridades: desconocida no cumple ninguna |
| `NULL = NULL` en una reunión | `null = null` unifica | la igualdad unificada deja `V \== null` |
| agregados de ninguna fila | `bagof/3` falla | `COUNT` 0, los demás `NULL` |
| claves y tipos | a cargo del programa | verificados en cada `INSERT` y `UPDATE` |
| recursión | regla recursiva, con tabla si hace falta | no la admite: una vista no se nombra a sí misma |

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; las gramáticas son `nondet` y solo se llaman dentro de una condición de `->` o con `phrase/2` en `analizar_tokens/2`, que es `det`; los compiladores y las sentencias son `det` y lanzan `error(sql(Motivo), _)` |
    | C2 | representaciones limpias: tokens `n/1`, `s/1`, `i/1`; sintaxis abstracta `consulta/3`, `seleccion/6`, `y/2`, `o/2`, `no/1`, `comparar/3`; columnas `col/4`; marcos `marco/2` |
    | C3 | las tablas son las del [capítulo 43](../capitulo-43-prolog-y-sql/index.md), cargadas sin copiarlas; los resultados se comparan con los de SQLite en 42 pares |
    | C5 | toda sentencia incorrecta produce un error que la nombra antes de ejecutar nada; una actualización que viola una restricción no cambia ninguna fila |
    | C6 | el análisis y la compilación son puros; los efectos están en `modificaciones.pl` y `vistas.pl`, y cada uno reemplaza el estado entero o no lo toca |
    | C7 | 168 pruebas en diez archivos y 17 más sobre las soluciones; `costos.plt` verifica las cuatro cifras de inferencias dentro de un 10 %, y `comparacion.plt` cada par frente a SQLite |

## Resumen

| | |
|---|---|
| **analizador léxico** | separa el texto en tokens; la gramática trabaja sobre tokens, no sobre caracteres |
| **sintaxis abstracta** | el término que representa una sentencia, independiente de su texto y de su traducción |
| **punto más lejano** | el resto de la entrada más corto que alcanzó alguna alternativa; ahí está el error |
| **catálogo** | cada relación con su generador y su marco de columnas, que comparten variables |
| **tabla de símbolos** | los marcos de cada nivel de consulta; un nombre se busca desde adentro hacia afuera |
| **igualdad al compilar** | unificar dos columnas o una columna y una constante; correcto solo en la conjunción de primer nivel |
| **lógica de tres valores** | verdadera, falsa o desconocida; cada condición se compila en una meta por polaridad |
| **instantánea** | una actualización calcula todas las filas nuevas sobre el estado anterior |
| **vista** | una relación calculada; su generador no se distingue del de una tabla |
| `tokens/2` | los tokens de un texto |
| `analizar/2`, `analizar_tokens/2` | la sintaxis abstracta de una sentencia |
| `relacion/4`, `restriccion/2`, `marcos/3`, `buscar_columna/4` | el catálogo y la tabla de símbolos |
| `traducir_ingenuo/3`, `consulta_ingenua/2` | el compilador de Toy-Sequel |
| `compilar_consulta/5`, `condicion/5`, `expresion/7`, `igualdades/3` | el compilador |
| `traducir/3`, `filas/3`, `mostrar_traduccion/1` | una consulta traducida, ejecutada o escrita |
| `modificar/2`, `vista/2` | las sentencias que cambian las tablas y las vistas |
| `sql/2`, `sql/1`, `guion/2`, `sesion/0` | el intérprete |
| `coincide/1`, `resumen/2` | la comparación con SQLite |
| **[Patrón 97](../patrones.md#97-una-condicion-dos-metas)** | una condición, dos metas |
| **[Patrón 98](../patrones.md#98-la-igualdad-se-unifica-solo-en-la-conjuncion-positiva)** | la igualdad se unifica solo en la conjunción positiva |
| **[Patrón 99](../patrones.md#99-el-error-en-el-punto-mas-lejano)** | el error en el punto más lejano |
| **[Patrón 100](../patrones.md#100-calcular-el-estado-nuevo-antes-de-cambiar)** | calcular el estado nuevo antes de cambiar |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Preguntas en castellano traducidas a consultas sobre las tablas de *Inscripciones* | [capítulo 88](../capitulo-88-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- *SQLite Documentation*, «NULL Handling in SQLite Versus Other Database
  Engines» y «SELECT».
  [NULL](https://www.sqlite.org/nulls.html) y
  [SELECT](https://www.sqlite.org/lang_select.html).
  De allí vienen el lugar de `NULL` en `ORDER BY`, los agregados de
  ninguna fila y la división entera que el mini-SQL imita, y que la
  comparación verifica.

El código del capítulo es propio, escrito para el curso: el listado de
Toy-Sequel se tomó como descripción de la arquitectura, no se copió, y el
mini-SQL usa la sintaxis de SQL; la lógica de tres valores, la igualdad
al compilar restringida a la conjunción, las subconsultas, los
agregados, las actualizaciones sobre la instantánea y la comparación con
SQLite no tienen equivalente en la fuente.
