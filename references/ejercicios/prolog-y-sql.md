# Banco de ejercicios: Prolog y SQL (Tema 11)

Este archivo reúne dos cosas:

1. **Catálogo de ejercicios existentes** (`SQL-n`): ejercicios y ejemplos publicados que relacionan SQL, álgebra relacional y Datalog con Prolog, con su fuente. Los enunciados están resumidos con nuestras palabras; para el original, seguir el enlace o la referencia de página.
2. **Ejercicios en pares propios** (`PAR-n`): cada ejercicio tiene una solución en SQL (dialecto SQLite) y otra en Prolog (SWI-Prolog), sobre tres esquemas pequeños compartidos. Todos los pares están verificados: las dos soluciones se ejecutaron y devuelven el mismo conjunto de filas, salvo los pares marcados **«difieren»**, que existen justamente para mostrar dónde los dos lenguajes dan respuestas distintas (en esos casos se verificó que las respuestas son distintas, tal como se describe).

Etiquetas de temario usadas: **11** Prolog y SQL · 1 Hechos · 2 Reglas · 5 Recursión · 8 Negación · 9 findall/bagof/setof/aggregate_all · 10 assert/retract.

Dificultad: **1** directa, **2** combina varias ideas, **3** requiere pensar la traducción (negación doble, recursión con costo, trampas de NULL).

## Archivos de verificación

Todo está en [`sql-prolog/`](sql-prolog/):

| Archivo | Contenido |
|---|---|
| `schema.sql` | `CREATE TABLE` + `INSERT` de los tres esquemas (SQLite) |
| `datos.pl` | Los mismos datos como hechos Prolog |
| `consultas.pl` | Las soluciones Prolog; cada ejercicio es una cláusula `par(N, Fila)` cuyo cuerpo es la consulta |
| `verificar.py` | Las soluciones SQL; ejecuta cada par en SQLite y en SWI-Prolog y compara |

Para correr la verificación:

```text
cd references/ejercicios/sql-prolog
uv run -p 3.14 python verificar.py        # resumen
uv run -p 3.14 python verificar.py -v     # con los resultados de cada lado
```

Resultado de la última ejecución (Python 3.14.4, SQLite 3.50.4, SWI-Prolog 9.2.9): **57/57 verificaciones correctas** (50 pares más 7 verificaciones complementarias, identificadas con sufijo `b`).

Cada ejercicio se ejecuta sobre una base nueva: en SQL, una base en memoria recién creada; en Prolog, dentro de `snapshot/1`, que descarta los `assertz`/`retract` al terminar. Por eso los ejercicios de actualización no se afectan entre sí.

---

# Parte 1: Catálogo de ejercicios existentes

## Libros de Prolog

### SQL-1 — Las cinco operaciones del álgebra relacional como reglas

- **Fuente:** L. Sterling y E. Shapiro, *The Art of Prolog*, 2.ª ed., MIT Press, 1994, cap. 2 «Database Programming», §2.4 «Logic Programs and the Relational Database Model». Copia local: `books/the-art-of-prolog/11-2-database-programming.md` (páginas 83–84 del PDF; el OCR es malo, conviene leer el libro impreso).
- **Tema:** 11 (+ 2, 8)
- **Dificultad:** 1
- **Solución:** sí, en el texto (reglas `r_union_s`, `r_diff_s`, `r_x_s` y una proyección `r13`).
- **SWISH:** sí; hay que inventar hechos `r/2` y `s/2`.
- **Enunciado:** Dadas dos relaciones `r` y `s` de la misma aridad escritas como hechos, definir con reglas su unión, su diferencia, su producto cartesiano, una proyección sobre algunas columnas y una selección por condición.
- **Notas:** Es la base teórica de todo el tema: unión = dos cláusulas, diferencia = `\+`, producto = conjunción sin variables compartidas, proyección = descartar argumentos con `_`. El libro advierte que la diferencia con `not` sólo es correcta porque los hechos son *ground* (sin variables). Se trabaja en PAR-9 a PAR-12.

### SQL-2 — Intersección y join natural

- **Fuente:** Sterling y Shapiro, *The Art of Prolog*, §2.4, final de la sección (p. 84 del PDF).
- **Tema:** 11 (+ 2)
- **Dificultad:** 1
- **Solución:** sí, en el texto (`r_meet_s`).
- **SWISH:** sí.
- **Enunciado:** Definir la intersección de dos relaciones de igual aridad con una sola regla, y observar que un join natural es simplemente una conjunción de objetivos con variables compartidas.
- **Notas:** Idea clave para el curso: un join natural es una consulta conjuntiva con variables compartidas. Ver PAR-6, PAR-7 y PAR-11.

### SQL-3 — Relaciones de parentesco derivadas

- **Fuente:** Sterling y Shapiro, *The Art of Prolog*, ejercicios de §2.1, apartados (i) y (ii) (p. 75 del PDF).
- **Tema:** 11 (+ 1, 2)
- **Dificultad:** 1
- **Solución:** no.
- **SWISH:** sí.
- **Enunciado:** A partir de una base familiar (Programa 2.1), escribir reglas para hermana, sobrina y hermanos «completos» (mismo padre y misma madre); con un predicado `married_couple/2`, definir suegra, cuñado y yerno.
- **Notas:** Cada regla es una *vista* (`CREATE VIEW`) sobre las tablas de hechos. El caso de hermanos completos es un join de la tabla consigo misma (*self-join*) y obliga a excluir `X = Y`, como en PAR-8.

### SQL-4 — Base de datos de cursos: ubicación, ocupación y conflictos

- **Fuente:** Sterling y Shapiro, *The Art of Prolog*, §2.2 y ejercicios de §2.2, apartados (i) y (ii) (pp. 78–80 del PDF).
- **Tema:** 11 (+ 2)
- **Dificultad:** 2
- **Solución:** no.
- **SWISH:** sí.
- **Enunciado:** Con hechos que describen cursos (docente, día, horario, edificio y aula), definir qué edificio usa un curso, cuándo está ocupado un docente, qué docentes no pueden reunirse y qué pares de cursos tienen conflicto de horario y lugar.
- **Notas:** Buen ejemplo para comparar una tabla «ancha» con varias tablas binarias (el libro discute ambas representaciones del mismo curso). El conflicto de horarios es un self-join con una condición de desigualdad.

### SQL-5 — Requisitos para obtener el título

- **Fuente:** Sterling y Shapiro, *The Art of Prolog*, ejercicios de §2.2, apartado (iii) (p. 80 del PDF).
- **Tema:** 11 (+ 2, 8)
- **Dificultad:** 2
- **Solución:** no.
- **SWISH:** sí.
- **Enunciado:** Representar con hechos las materias que cursó un estudiante y sus notas, y escribir reglas que decidan si cumple los requisitos para recibirse.
- **Notas:** Muy cercano a nuestro esquema académico. «Aprobó todas las obligatorias» es una división relacional: ver PAR-16 (`forall/2` o doble `\+`).

### SQL-6 — Diseñar una base de datos propia

- **Fuente:** Sterling y Shapiro, *The Art of Prolog*, ejercicios de §2.2, apartado (iv) (p. 80 del PDF).
- **Tema:** 11 (+ 1, 2)
- **Dificultad:** 2
- **Solución:** no.
- **SWISH:** sí.
- **Enunciado:** Diseñar una pequeña base de datos para una aplicación a elección, primero con un único predicado y luego con reglas que respondan consultas útiles.
- **Notas:** Sirve como trabajo final de la unidad si se exige además la versión SQL (`CREATE TABLE` más las consultas equivalentes).

### SQL-7 — Clausura transitiva: bloques apilados y grafos

- **Fuente:** Sterling y Shapiro, *The Art of Prolog*, §2.3 (Programas 2.6 y 2.7, `connected/2`) y ejercicios de §2.3, apartados (i) a (iii) (pp. 82–83 del PDF).
- **Tema:** 11 (+ 5)
- **Dificultad:** 2
- **Solución:** parcial (el texto resuelve `connected`; los ejercicios no).
- **SWISH:** sí.
- **Enunciado:** Con hechos `on(B1, B2)`, definir `above/2` como la clausura transitiva de `on`; extender `left_of` y `above` con reglas recursivas; contar los nodos del árbol de prueba de `connected(a, e)`.
- **Notas:** Es la contraparte Prolog de `WITH RECURSIVE`. Ver PAR-33, PAR-35 y PAR-37. Con grafos cíclicos la versión sin tabling no termina (PAR-48).

### SQL-8 — Inventario de piezas (lista de materiales)

- **Fuente:** W. F. Clocksin y C. S. Mellish, *Programming in Prolog*, 5.ª ed., Springer, 2003, §7.4 «Parts Inventory» (se apoya en el programa del cap. 3). Copia local: `books/programming-in-prolog/10-7-more-example-programs.md` (pp. 167–169 del PDF).
- **Tema:** 11 (+ 5, 9)
- **Dificultad:** 3
- **Solución:** sí, en el texto (`partlist/1`, `partsof/3`, `collect/2`).
- **SWISH:** sí (conviene devolver el resultado en una lista en lugar de imprimirlo).
- **Enunciado:** Dado un inventario donde cada ensamble lista sus componentes con cantidades, calcular cuántas piezas básicas de cada tipo hacen falta para construir un ensamble, sumando las cantidades repetidas.
- **Notas:** Es el clásico *bill of materials* que en SQL se resuelve con `WITH RECURSIVE` multiplicando cantidades y luego `GROUP BY pieza` con `SUM`. Extensión natural de PAR-35 para estudiantes avanzados: con `aggregate_all(sum(...))` se evita escribir `collect/2` a mano.

### SQL-9 — Reglas de parentesco sobre predicados dados

- **Fuente:** Clocksin y Mellish, *Programming in Prolog*, ej. 1.3 (inspirado en Kowalski, *Logic for Problem Solving*, 1979) y ej. 1.4. Copia local: `books/programming-in-prolog/04-1-tutorial-introduction.md`.
- **Tema:** 11 (+ 1, 2)
- **Dificultad:** 1
- **Solución:** parcial (apéndice A del libro, respuestas seleccionadas).
- **SWISH:** sí.
- **Enunciado:** Suponiendo definidos `father/2`, `mother/2`, `male/1`, `female/1`, `parent/2` y `diff/2`, escribir `is_mother/1`, `is_father/1`, `is_son/1`, `sister_of/2`, `grandpa_of/2` y `sibling/2`; explicar por qué con la regla ingenua alguien resulta hermana de sí misma.
- **Notas:** Cada regla corresponde a una vista SQL. El ej. 1.4 es el mismo problema que resuelve `a1.legajo < a2.legajo` en PAR-8 (sin esa condición aparecen los pares (X, X)).

### SQL-10 — Modificar la base: consult, assert y retract

- **Fuente:** Clocksin y Mellish, *Programming in Prolog*, §6.1 «Entering New Clauses» y §7.8 «Using the Database» (7.8.1 `random`, 7.8.2 `gensym`). Copias locales: `09-6-built-in-predicates.md` y `10-7-more-example-programs.md`.
- **Tema:** 11 (+ 10)
- **Dificultad:** 2
- **Solución:** sí, en el texto.
- **SWISH:** sí (hay que declarar `:- dynamic`).
- **Enunciado:** Estudiar cómo un programa guarda estado entre consultas agregando y quitando cláusulas (un generador de números aleatorios y un generador de nombres nuevos).
- **Notas:** Sirve para introducir `INSERT`/`UPDATE`/`DELETE` como `assertz`/`retract`. `gensym` es el análogo de una columna `AUTOINCREMENT`. Ver PAR-39 a PAR-45.

### SQL-11 — findall con variables libres

- **Fuente:** Clocksin y Mellish, *Programming in Prolog*, §7.8.3 «Findall» y ej. 7.8.
- **Tema:** 11 (+ 9)
- **Dificultad:** 2
- **Solución:** no.
- **SWISH:** sí.
- **Enunciado:** Determinar qué ocurre con `findall(X, G, L)` cuando `G` contiene variables libres que no aparecen en `X`.
- **Notas:** Es la diferencia entre un agregado sin `GROUP BY` (`findall`, `aggregate_all`) y uno con `GROUP BY` (`bagof`/`setof`, que agrupan por las variables libres salvo que se las marque con `^`). Ver PAR-18 y PAR-46.

## Tutoriales que traducen SQL a Prolog

### SQL-12 — Introducción a Prolog para programadores SQL: consultas básicas

- **Fuente:** cuaderno público de SWISH «An introduction to Prolog for SQL programmers», <https://swish.swi-prolog.org/p/sql2prolog.swinb>. Usa el esquema `college/student/apply` del curso de bases de datos de J. Widom (Stanford).
- **Tema:** 11 (+ 1, 2, 9)
- **Dificultad:** 1
- **Solución:** sí, cada consulta SQL aparece con su traducción Prolog.
- **SWISH:** sí, es un cuaderno de SWISH listo para ejecutar.
- **Enunciado:** Traducir a Prolog consultas de selección (estudiantes con promedio mayor a 3,6), proyección, join entre estudiantes y postulaciones, eliminación de duplicados, ordenamiento por una o varias columnas, búsqueda de subcadenas y columnas calculadas.
- **Notas:** Es la fuente más cercana a esta unidad. Usa `distinct/2` y `order_by/2` de `library(solution_sequences)` para `DISTINCT` y `ORDER BY`, y `sub_atom/5` para `LIKE`. Nuestros PAR-1 a PAR-8 siguen la misma progresión con datos en castellano.

### SQL-13 — Introducción a Prolog para programadores SQL: operaciones de conjuntos y subconsultas

- **Fuente:** el mismo cuaderno de SWISH que SQL-12, secciones de unión, intersección, diferencia, subconsultas y joins externos.
- **Tema:** 11 (+ 2, 8, 9)
- **Dificultad:** 2
- **Solución:** sí.
- **SWISH:** sí.
- **Enunciado:** Traducir `UNION`, `INTERSECT`, `EXCEPT`, subconsultas en `WHERE` (con y sin correlación), `EXISTS`, la «universidad más grande» (máximo sin `MAX`) y los tres tipos de join externo.
- **Notas:** La diferencia se traduce con `\+`; el máximo, con «no existe otro mayor» (como en nuestro PAR-28); el join externo, con una disyunción que completa con `null` (como en PAR-24).

### SQL-14 — Introducción a Prolog para programadores SQL: agregados y actualizaciones

- **Fuente:** el mismo cuaderno de SWISH que SQL-12, secciones de agregación, `GROUP BY`, `HAVING`, `INSERT` y `DELETE`.
- **Tema:** 11 (+ 9, 10)
- **Dificultad:** 2
- **Solución:** sí.
- **SWISH:** sí.
- **Enunciado:** Calcular promedio, mínimo y cantidad con `aggregate_all/3`, contar valores distintos, agrupar por universidad (y por universidad y carrera), filtrar grupos, insertar filas con `assertz` y borrar estudiantes que cumplen una condición agregada con `forall` + `retract`.
- **Notas:** Usa el patrón «generar el grupo y luego `aggregate_all`» (nuestro PAR-19 y PAR-27), que a diferencia de `GROUP BY` también produce grupos vacíos.

### SQL-15 — Prolog como lenguaje de consulta de bases de datos

- **Fuente:** D. S. Warren, *Programming in Tabled Prolog* (borrador en línea, XSB), sección «Prolog as a Database Query Language», <https://www3.cs.stonybrook.edu/~warren/xsbbook/node11.html>. (El servidor rechaza la descarga automática con 403; se abre normalmente desde un navegador.)
- **Tema:** 11 (+ 1, 2, 5)
- **Dificultad:** 1
- **Solución:** sí, en el texto.
- **SWISH:** sí (los ejemplos no dependen de XSB).
- **Enunciado:** Con relaciones de empleados y departamentos, definir relaciones derivadas (por ejemplo, empleados que ganan más de cierto monto) y observar que, restringido a átomos y números y sin recursión, Prolog equivale a un subconjunto de SQL.
- **Notas:** El libro sigue con tabling (capítulos siguientes), que es la herramienta para que la recursión sobre datos cíclicos termine: ver PAR-37, PAR-38 y PAR-48.

## Cursos y hojas de ejercicios de bases de datos

### SQL-16 — Álgebra relacional sobre la base de pizzerías (consultas 1 a 6)

- **Fuente:** J. Widom, curso *Databases* (Stanford, luego Stanford Online/edX), «Relational Algebra Exercises». Enunciados recopilados en <https://github.com/andylamp/stanford_dbclass/blob/master/04%20-%20relational%20algebra/ra-ex.md>; soluciones de estudiantes en <https://github.com/alorchhota/db-stanford>.
- **Tema:** 11 (+ 2, 8)
- **Dificultad:** 2
- **Solución:** sí (de terceros, en los repositorios citados).
- **SWISH:** sí, pasando `Person`, `Eats`, `Serves` y `Frequents` a hechos.
- **Enunciado:** Sobre personas, pizzas que comen, pizzerías que las sirven y pizzerías que frecuentan: pizzas comidas por mujeres mayores de 20; mujeres que comen alguna pizza de cierta pizzería; pizzerías que sirven barato algo que comen Amy o Fay (y luego Amy y Fay); personas que comen algo de Dominos sin frecuentar Dominos.
- **Notas:** Se resuelven igual en álgebra relacional, SQL y Prolog. La consulta 4 («Amy **y** Fay») exige dos apariciones de la relación `Eats`, como la intersección de PAR-11. La 5 es una diferencia (`\+`).

### SQL-17 — Álgebra relacional sobre la base de pizzerías (consultas 7 a 9)

- **Fuente:** la misma hoja que SQL-16.
- **Tema:** 11 (+ 8, 9)
- **Dificultad:** 3
- **Solución:** sí (de terceros).
- **SWISH:** sí.
- **Enunciado:** Edad de la persona más grande que come pizza de hongos; pizzerías que sólo sirven pizzas comidas por mayores de 30; pizzerías que sirven *todas* las pizzas comidas por mayores de 30.
- **Notas:** La 7 es un máximo sin operador de agregación (patrón de PAR-28); la 8 es «sólo» (negación de un contraejemplo); la 9 es la división relacional (patrón de PAR-16 con `forall/2`).

### SQL-18 — Consultas SQL sobre la base de calificaciones de películas

- **Fuente:** J. Widom, curso *Databases*, «SQL Movie-Rating Query Exercises» (conjunto básico y extras). Soluciones de terceros con el script de datos `rating.sql` en <https://github.com/alorchhota/db-stanford>.
- **Tema:** 11 (+ 8, 9)
- **Dificultad:** 2
- **Solución:** sí (de terceros).
- **SWISH:** sí, convirtiendo `Movie`, `Reviewer` y `Rating` en hechos.
- **Enunciado:** Sobre películas, críticos y puntajes: títulos por director, años de películas con puntaje alto ordenados, películas sin puntaje, críticos que puntuaron dos veces la misma película con mejora, mejor puntaje por película, diferencia entre puntaje máximo y mínimo por película, promedios por período, etc.
- **Notas:** El script de datos incluye valores `NULL` (fechas de puntaje desconocidas), útiles para discutir la hipótesis de mundo cerrado (PAR-32, PAR-49). Varias consultas se reescriben con `aggregate_all/3`.

### SQL-19 — Proveedores y piezas

- **Fuente:** C. J. Date, *An Introduction to Database Systems*, 8.ª ed., Addison-Wesley, 2003 (base S/P/SP usada en todo el libro). Descripción del esquema: <https://en.wikipedia.org/wiki/Suppliers_and_Parts_database>. Hoja de práctica de álgebra relacional y SQL sobre la variante S/P/J/SPJ (proveedores, piezas, proyectos), con los datos de Date impresos: HKUST, IELM 230, <https://ieda.ust.hk/dfaculty/ajay/courses/ielm230/old_asgt/11s_asgt/PracticeDate.pdf>.
- **Tema:** 11 (+ 2, 8, 9)
- **Dificultad:** 2
- **Solución:** no (la hoja aclara que no trae respuestas modelo).
- **SWISH:** sí; las cuatro tablas de la hoja se pasan a hechos en pocos minutos.
- **Enunciado:** Sobre proveedores, piezas, proyectos y envíos: nombres de proveedores que envían una pieza dada, proveedores que envían *todas* las piezas, proyectos que sólo usan piezas rojas, proyectos abastecidos por algún proveedor de estado bajo, y proveedores que no tienen el peor estado de su ciudad.
- **Notas:** Es el esquema de referencia de la literatura relacional; nuestro esquema empresa cumple el mismo papel con nombres en castellano. «Envía todas las piezas» es la división de PAR-16; «sólo piezas rojas», una negación de contraejemplo; «no el peor de su ciudad», un mínimo por grupo como PAR-28.

## Documentación de SQLite y SWI-Prolog

### SQL-20 — WITH RECURSIVE: organigrama y árbol genealógico

- **Fuente:** documentación de SQLite, «The WITH Clause», secciones de consultas recursivas, <https://www.sqlite.org/lang_with.html>.
- **Tema:** 11 (+ 5)
- **Dificultad:** 2
- **Solución:** sí, en la documentación.
- **SWISH:** la versión Prolog sí (la documentación sólo da SQL).
- **Enunciado:** Con una tabla `org(name, boss)`, listar a todas las personas de la organización de Alice; con una tabla `family(name, mom, dad, ...)`, listar los ancestros vivos de Alice del más viejo al más joven.
- **Notas:** El organigrama es nuestro PAR-33. El árbol genealógico combina una vista común (`parent_of`, que une las columnas de madre y padre) con una recursiva: en Prolog, dos cláusulas para `padre_o_madre/2` y una regla `ancestro/2`.

### SQL-21 — WITH RECURSIVE sobre grafos con ciclos: UNION contra UNION ALL

- **Fuente:** documentación de SQLite, «The WITH Clause», ejemplos de grafo no dirigido y de grafo acíclico de versiones, <https://www.sqlite.org/lang_with.html>.
- **Tema:** 11 (+ 5)
- **Dificultad:** 2
- **Solución:** sí.
- **SWISH:** la versión Prolog sí, con `:- table`.
- **Enunciado:** Listar todos los nodos conectados a uno dado en un grafo que puede tener ciclos, explicando por qué la consulta usa `UNION` y no `UNION ALL`.
- **Notas:** La documentación explica que `UNION` descarta filas repetidas y por eso la recursión termina aunque haya ciclos; con `UNION ALL` no termina. En Prolog el problema análogo se resuelve con tabling. Ver PAR-37 y PAR-48.

### SQL-22 — Tabling: recursión izquierda y terminación

- **Fuente:** manual de SWI-Prolog, sección 7 «Tabled execution (SLG resolution)», <https://www.swi-prolog.org/pldoc/man?section=tabling>, incluida la subsección de *answer subsumption* (tablas con `min`/`max`).
- **Tema:** 11 (+ 5)
- **Dificultad:** 3
- **Solución:** sí, con ejemplos (`fib/2`, `connection/2`).
- **SWISH:** sí; SWISH admite `:- table`.
- **Enunciado:** Declarar tabulado un predicado recursivo (a izquierda) de conexión en un grafo y comprobar que termina y no repite respuestas; usar *answer subsumption* para quedarse sólo con el camino más corto.
- **Notas:** Con tabling, Prolog evalúa las reglas de forma parecida a Datalog y a `WITH RECURSIVE ... UNION`: respuestas como conjunto y terminación garantizada con datos finitos. La tabla `costo(_,_,min)` de PAR-38 es el `MIN(precio) ... GROUP BY` de SQL.

### SQL-23 — La base de datos dinámica: assert, retract y la vista lógica de actualización

- **Fuente:** manual de SWI-Prolog, sección 4.14 «Database», <https://www.swi-prolog.org/pldoc/man?section=db>.
- **Tema:** 11 (+ 10)
- **Dificultad:** 2
- **Solución:** no son ejercicios, es referencia con ejemplos.
- **SWISH:** sí.
- **Enunciado:** (Para trabajar con la referencia.) Explicar por qué un predicado que se modifica en ejecución debe declararse `dynamic`, y qué consecuencias tiene la «vista lógica de actualización»: un objetivo en curso sigue viendo las cláusulas que había cuando empezó.
- **Notas:** La vista lógica es lo que hace seguro el patrón `forall(retract(...), assertz(...))` de PAR-41: las filas recién agregadas no vuelven a ser procesadas, igual que en un `UPDATE` de SQL.

### SQL-24 — Hechos persistentes en disco

- **Fuente:** manual de SWI-Prolog, `library(persistency)`, <https://www.swi-prolog.org/pldoc/man?section=persistency>.
- **Tema:** 11 (+ 10)
- **Dificultad:** 3
- **Solución:** no (referencia con ejemplo de uso).
- **SWISH:** no (necesita escribir archivos); sí con `swipl` local.
- **Enunciado:** Declarar con `persistent/1` una relación con tipos por columna, asociarla a un archivo con `db_attach/2` y comprobar que las altas y bajas (`assert_<nombre>`, `retract_<nombre>`) sobreviven al reinicio de Prolog.
- **Notas:** Muestra lo que Prolog no trae de fábrica y un SGBD sí: durabilidad y tipos declarados por columna. Buen cierre para comparar con `CREATE TABLE` y sus restricciones (PAR-44, PAR-45).

### SQL-25 — Modificadores de secuencias de soluciones

- **Fuente:** manual de SWI-Prolog, `library(solution_sequences)`, <https://www.swi-prolog.org/pldoc/man?section=solutionsequences>.
- **Tema:** 11 (+ 9)
- **Dificultad:** 1
- **Solución:** referencia con ejemplos.
- **SWISH:** sí.
- **Enunciado:** Usar `distinct/1,2`, `order_by/2`, `limit/2`, `offset/2` y `group_by/4` para reproducir `DISTINCT`, `ORDER BY`, `LIMIT`, `OFFSET` y `GROUP BY` sin armar listas a mano.
- **Notas:** La documentación los presenta explícitamente como inspirados en SQL. Ver PAR-5 y PAR-29.

### SQL-26 — Consultar una base SQL real desde Prolog

- **Fuente:** manual de SWI-Prolog, paquete ODBC, sección «Running SQL queries», <https://www.swi-prolog.org/pldoc/man?section=odbc-query>, y `library(cql/cql)` (Constraint Query Language), <https://www.swi-prolog.org/pldoc/man?section=cql>.
- **Tema:** 11
- **Dificultad:** 3
- **Solución:** referencia con ejemplos.
- **SWISH:** no (requiere un controlador ODBC local).
- **Enunciado:** Conectarse a una base SQLite o PostgreSQL con `odbc_connect/3` y enumerar por *backtracking* las filas de un `SELECT` con `odbc_query/3`, como si fueran hechos.
- **Notas:** Cierra el círculo de la unidad: un resultado SQL se ve desde Prolog como un predicado que tiene una solución por fila. Opcional, para quien quiera profundizar.

## Datalog: teoría y herramientas

### SQL-27 — Datalog, seguridad de reglas y negación estratificada

- **Fuente:** J. D. Ullman, apuntes del curso CS345 (Stanford), en particular «Introduction to Datalog, Stratified Negation», <http://infolab.stanford.edu/~ullman/cs345-notes.html>.
- **Tema:** 11 (+ 2, 5, 8)
- **Dificultad:** 3
- **Solución:** parcial (ejemplos resueltos en las transparencias).
- **SWISH:** sí, los ejemplos son Prolog válido.
- **Enunciado:** Decidir si una regla es segura (toda variable de la cabeza o de un literal negado aparece en un literal positivo del cuerpo) y si un programa con negación es estratificado (no hay recursión a través de una negación).
- **Notas:** La condición de seguridad es la razón de fondo de PAR-14: en Prolog, `\+` con variables sin ligar no «busca» valores. La estratificación explica por qué `requisito/2` puede usarse negado en otra regla pero no dentro de su propia definición.

### SQL-28 — Todo lo que siempre quiso saber sobre Datalog

- **Fuente:** S. Ceri, G. Gottlob y L. Tanca, «What You Always Wanted to Know About Datalog (And Never Dared to Ask)», *IEEE Transactions on Knowledge and Data Engineering* 1(1):146–166, 1989. DOI 10.1109/69.43410. Copia en <https://www2.cs.sfu.ca/CourseCentral/721/jim/DatalogPaper.pdf>.
- **Tema:** 11 (+ 5)
- **Dificultad:** 3
- **Solución:** los ejemplos del artículo están resueltos.
- **SWISH:** sí para los ejemplos.
- **Enunciado:** (Lectura para el docente.) Traducir los programas Datalog del artículo (antepasados, misma generación) a álgebra relacional y comparar la evaluación de abajo hacia arriba (Datalog, SQL) con la de arriba hacia abajo (Prolog).
- **Notas:** Explica por qué SQL y Datalog calculan conjuntos por punto fijo mientras Prolog busca pruebas en profundidad: el origen conceptual de PAR-48.

### SQL-29 — Fundamentos de bases de datos: Datalog y recursión

- **Fuente:** S. Abiteboul, R. Hull y V. Vianu, *Foundations of Databases*, Addison-Wesley, 1995, parte D «Datalog and Recursion» (caps. 12 a 15, con ejercicios al final de cada capítulo). Versión en línea de los autores: <http://webdam.inria.fr/Alice/>.
- **Tema:** 11 (+ 5, 8)
- **Dificultad:** 3
- **Solución:** no.
- **SWISH:** sí para los ejercicios con programas Datalog.
- **Enunciado:** Ejercicios de expresar consultas recursivas en Datalog, evaluar programas con semántica de punto fijo y analizar la negación en Datalog (estratificada y bien fundada).
- **Notas:** Nivel de posgrado; útil como respaldo teórico del docente, no para los estudiantes de segundo año.

### SQL-30 — Soufflé: clausura transitiva, negación y agregados

- **Fuente:** tutorial de Soufflé, <https://souffle-lang.github.io/tutorial>.
- **Tema:** 11 (+ 5, 8, 9)
- **Dificultad:** 2
- **Solución:** sí, en el tutorial.
- **SWISH:** sí, traduciendo `.decl`/`.input` a hechos.
- **Enunciado:** Calcular la alcanzabilidad en un grafo (`reachable`), la relación «misma generación» en un árbol, el primer y el último elemento de una secuencia con negación, y conteos, mínimos, máximos y sumas con agregados.
- **Notas:** Soufflé tiene sintaxis casi idéntica a Prolog, pero evalúa de abajo hacia arriba y siempre termina. «Misma generación» es un buen ejercicio extra sobre nuestro esquema empresa (empleados al mismo nivel, comparar con PAR-34).

### SQL-31 — Consultas recursivas en SQL y en Datalog

- **Fuente:** A. R. Shovon, «Recursive queries in SQL and Datalog», <https://arshovon.com/blog/recursive-queries/>, y «Introduction to Datalog as logic programming», <https://arshovon.com/blog/datalog-introduction/>.
- **Tema:** 11 (+ 5)
- **Dificultad:** 2
- **Solución:** sí.
- **SWISH:** sí.
- **Enunciado:** Con tablas de usuarios (nombre, ciudad) y amistades, encontrar los usuarios conectados con Chicago y calcular la clausura transitiva de la amistad, en SQL con `WITH RECURSIVE` y en Datalog.
- **Notas:** Presenta lado a lado las dos versiones del mismo ejercicio, que es el formato de nuestra Parte 2.

### SQL-32 — Learn Datalog Today

- **Fuente:** J. Enlund, *Learn Datalog Today*, tutorial interactivo con base de películas (Datomic). Código y contenido: <https://github.com/jonase/learndatalogtoday>.
- **Tema:** 11 (+ 2, 9)
- **Dificultad:** 1
- **Solución:** sí, en el tutorial.
- **SWISH:** sí, reescribiendo las tripletas (entidad, atributo, valor) como hechos.
- **Enunciado:** Ejercicios graduados sobre películas, actores y directores: consultas básicas, parámetros, predicados, funciones de transformación, agregados y reglas.
- **Notas:** Representa los datos como tripletas entidad-atributo-valor en lugar de tablas; sirve para discutir que la misma información admite esquemas distintos (una tabla ancha contra varias binarias, como en SQL-4). El sitio en vivo no respondió al verificar la URL; el repositorio sí.

### SQL-33 — Logica: Datalog que se compila a SQL

- **Fuente:** E. Skvortsov y colaboradores, Logica, <https://github.com/EvgSkv/logica> (tutorial en el directorio `tutorial/`); presentación en el blog de Google Open Source, <https://opensource.googleblog.com/2021/04/logica-organizing-your-data-queries.html>.
- **Tema:** 11 (+ 2, 9)
- **Dificultad:** 2
- **Solución:** sí, en el tutorial.
- **SWISH:** no (Logica corre sobre SQLite, DuckDB, PostgreSQL o BigQuery).
- **Enunciado:** Escribir consultas como reglas lógicas con agregación y ver el SQL que genera el compilador.
- **Notas:** Muestra en la práctica que reglas y SQL son intercambiables: el compilador traduce cada regla a un `SELECT`. Útil para que el docente muestre el SQL generado a partir de reglas parecidas a las de Prolog.

---

# Parte 2: Ejercicios en pares SQL / Prolog

## Los tres esquemas

Los datos completos están en `sql-prolog/schema.sql` y `sql-prolog/datos.pl`. Cada tabla SQL es un predicado Prolog con los mismos argumentos en el mismo orden; cada fila es un hecho.

| Tabla SQL | Predicado Prolog | Filas | Para qué sirve |
|---|---|---|---|
| `alumnos(legajo, nombre, carrera, ingreso)` | `alumno/4` | 7 | selección, proyección, orden |
| `materias(codigo, nombre, anio)` | `materia/3` | 7 | joins, división |
| `correlativas(materia, requisito)` | `correlativa/2` | 7 | recursión sin ciclos |
| `inscripciones(legajo, materia, nota)` | `inscripcion/3` | 17 | joins, agregados, `NULL` (3 notas vacías) |
| `departamentos(codigo, nombre, ciudad)` | `departamento/3` | 5 | un departamento sin empleados |
| `empleados(id, nombre, depto, salario, jefe)` | `empleado/5` | 9 | self-join, jerarquía recursiva, `NULL` (la directora no tiene jefe) |
| `vuelos(origen, destino, aerolinea, precio)` | `vuelo/4` | 10 | grafo **con un ciclo** (aep → cor → aep) |

Tres convenciones que hay que explicar antes de empezar:

- **Textos y átomos.** En SQL los textos van entre comillas simples y en minúscula sin espacios (`'sistemas'`), para que coincidan con los átomos de Prolog (`sistemas`).
- **NULL.** Prolog no tiene `NULL`. En `datos.pl` se usa el átomo `null`, que para Prolog es un átomo común: `null >= 6` da error de tipo y `null \== 1` es verdadero. Los pares PAR-6, PAR-7, PAR-24, PAR-32 y PAR-49 giran alrededor de esta diferencia.
- **`:- dynamic`.** `datos.pl` declara dinámicos todos los predicados porque los ejercicios PAR-39 a PAR-45 los modifican con `assertz`/`retract`. En SWISH, pegar `datos.pl` completo en el programa y escribir cada consulta en el panel de consultas.

## Bloque A: consultas sobre una y varias tablas

### PAR-1 — Selección: alumnos de una carrera

- **Tema:** 11 (+ 1)
- **Dificultad:** 1
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Listar legajo y nombre de los alumnos de la carrera `sistemas`.

**SQL (SQLite):**

```sql
SELECT legajo, nombre FROM alumnos WHERE carrera = 'sistemas';
```

**Prolog:**

```prolog
?- alumno(L, N, sistemas, _).
```

**Resultado:** (101, ana) · (102, bruno) · (104, diego). Verificado: SQL y Prolog coinciden.

**Notas:** `WHERE carrera = 'sistemas'` se traduce poniendo la constante en la posición del argumento. `SELECT legajo, nombre` se traduce dejando esas dos variables con nombre y la columna que no interesa (`ingreso`) como `_`. En Prolog las respuestas llegan de a una (con `;` en la consola o «Next» en SWISH); en SQL, todas juntas como tabla.

### PAR-2 — Selección con varias condiciones

- **Tema:** 11 (+ 1)
- **Dificultad:** 1
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Nombre, carrera y año de ingreso de los alumnos que ingresaron en 2024 o después y que no son de la carrera `civil`.

**SQL (SQLite):**

```sql
SELECT nombre, carrera, ingreso FROM alumnos
WHERE ingreso >= 2024 AND carrera <> 'civil';
```

**Prolog:**

```prolog
?- alumno(_, N, C, I), I >= 2024, C \== civil.
```

**Resultado:** (bruno, sistemas, 2024) · (diego, sistemas, 2024) · (facundo, industrial, 2024) · (gabriela, industrial, 2025). Verificado: SQL y Prolog coinciden.

**Notas:** `AND` es la coma. Para comparar átomos se usa `\==` (no son idénticos) y no `=\=`, que es sólo para números. Pregunta para el alumno: ¿qué pasa si se escribe `C \== civil` **antes** de `alumno(...)`? (Aparece también elena, que es de civil: al comparar, `C` todavía está libre, una variable libre no es idéntica a `civil` y la prueba pasa; después `alumno(...)` liga `C` a `civil` sin que nadie lo controle. Verificado. Las comparaciones van **después** del objetivo que liga sus variables; ver también PAR-14.)

### PAR-3 — Proyección con repeticiones

- **Tema:** 11 (+ 1)
- **Dificultad:** 1
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Listar la carrera de cada alumno (sin eliminar repetidos).

**SQL (SQLite):**

```sql
SELECT carrera FROM alumnos;
```

**Prolog:**

```prolog
?- alumno(_, _, C, _).
```

**Resultado:** (sistemas) · (sistemas) · (civil) · (sistemas) · (civil) · (industrial) · (industrial). Verificado: SQL y Prolog coinciden.

**Notas:** SQL trabaja con **bolsas** (multiconjuntos): `SELECT carrera` sin `DISTINCT` devuelve una fila por alumno, 7 en total. Prolog hace lo mismo: una solución por cada hecho que unifica. En el álgebra relacional teórica la proyección elimina repetidos; ni SQL ni Prolog lo hacen por defecto.

### PAR-4 — DISTINCT contra setof

- **Tema:** 11 (+ 9)
- **Dificultad:** 2
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Listar las carreras sin repetir, en orden alfabético.

**SQL (SQLite):**

```sql
SELECT DISTINCT carrera FROM alumnos
ORDER BY carrera;
```

**Prolog:**

```prolog
?- setof(C0, L^N^I^alumno(L, N, C0, I), Cs), member(C, Cs).
```

**Resultado:** (civil) · (industrial) · (sistemas) (en este orden). Verificado: SQL y Prolog coinciden.

**Notas:** `setof/3` elimina repetidos **y** ordena, así que equivale a `SELECT DISTINCT ... ORDER BY`. El `L^N^I^` dice «para algún legajo, nombre e ingreso»: sin él, `setof` agruparía por esas variables y daría una lista por alumno (ver SQL-11). Trampa frecuente: `setof(C, alumno(_, _, C, _), Cs)` **no** sirve, porque las `_` también son variables libres y `setof` agrupa por ellas: devuelve siete listas de un elemento (verificado). Alternativa sin listas: `distinct(C, alumno(_, _, C, _))`, que elimina repetidos pero conserva el orden de aparición (sistemas, civil, industrial).

### PAR-5 — ORDER BY con dos criterios

- **Tema:** 11 (+ 9)
- **Dificultad:** 2
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Listar año de ingreso y nombre de todos los alumnos, ordenados por año y, dentro del mismo año, por nombre.

**SQL (SQLite):**

```sql
SELECT ingreso, nombre FROM alumnos
ORDER BY ingreso, nombre;
```

**Prolog:**

```prolog
?- order_by([asc(I), asc(N)], alumno(_, N, _, I)).
```

**Resultado:** (2023, ana) · (2023, carla) · (2024, bruno) · (2024, diego) · (2024, facundo) · (2025, elena) · (2025, gabriela) (en este orden). Verificado: SQL y Prolog coinciden.

**Notas:** `order_by/2` de `library(solution_sequences)` es la traducción directa (SQL-25). Otra forma, usando sólo el tema 9: `setof(I-N, L^C^alumno(L, N, C, I), Ps), member(I-N, Ps)`, porque el orden estándar de los pares `I-N` compara primero `I` y después `N`. Cuidado: `setof` también elimina repetidos y `ORDER BY` no.

### PAR-6 — Join de dos tablas (y el primer NULL)

- **Tema:** 11 (+ 1, 2)
- **Dificultad:** 1
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Nombre y nota de cada alumno inscripto en `am1`.

**SQL (SQLite):**

```sql
SELECT a.nombre, i.nota
FROM alumnos a JOIN inscripciones i ON a.legajo = i.legajo
WHERE i.materia = 'am1';
```

**Prolog:**

```prolog
?- inscripcion(L, am1, Nota), alumno(L, N, _, _).
```

**Resultado:** (ana, 8) · (bruno, 4) · (carla, 7) · (elena, NULL) · (facundo, 6). Verificado: SQL y Prolog coinciden.

**Notas:** El join es la variable compartida `L`. La inscripción de elena todavía no tiene nota: SQL muestra `NULL` y Prolog muestra el átomo `null`, así que el resultado es el mismo. La diferencia aparece cuando se **opera** con la nota (siguiente ejercicio).

### PAR-7 — Join de tres tablas con condición sobre la nota

- **Tema:** 11 (+ 2)
- **Dificultad:** 2
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Nombre del alumno, nombre de la materia y nota de todas las materias aprobadas (nota 6 o más).

**SQL (SQLite):**

```sql
SELECT a.nombre, m.nombre, i.nota
FROM inscripciones i
JOIN alumnos  a ON a.legajo = i.legajo
JOIN materias m ON m.codigo = i.materia
WHERE i.nota >= 6;
```

**Prolog:**

```prolog
?- inscripcion(L, M, Nota), integer(Nota), Nota >= 6,
   alumno(L, A, _, _), materia(M, NM, _).
```

**Resultado:** (ana, analisis_1, 8) · (ana, algebra, 9) · (ana, logica, 10) · (ana, analisis_2, 7) · (bruno, logica, 6) · (carla, analisis_1, 7) · (diego, logica, 9) · (diego, algebra, 7) · (diego, paradigmas, 8) · (facundo, analisis_1, 6). Verificado: SQL y Prolog coinciden.

**Notas:** En SQL, `NULL >= 6` es *desconocido* y la fila se descarta sin error. En Prolog, `null >= 6` **lanza un error de tipo** (`null` no es un número), por eso hace falta el filtro `integer(Nota)` antes de comparar. Pedir al alumno que borre `integer(Nota)` y observe el error. El orden de los objetivos no cambia el resultado pero sí el trabajo: filtrar primero es como empujar el `WHERE` antes del join.

### PAR-8 — Self-join: pares de alumnos de la misma carrera

- **Tema:** 11 (+ 2)
- **Dificultad:** 2
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Listar los pares de alumnos (nombre, nombre, carrera) que estudian la misma carrera, cada par una sola vez.

**SQL (SQLite):**

```sql
SELECT a1.nombre, a2.nombre, a1.carrera
FROM alumnos a1 JOIN alumnos a2
  ON a1.carrera = a2.carrera AND a1.legajo < a2.legajo;
```

**Prolog:**

```prolog
?- alumno(L1, N1, C, _), alumno(L2, N2, C, _), L1 < L2.
```

**Resultado:** (ana, bruno, sistemas) · (ana, diego, sistemas) · (bruno, diego, sistemas) · (carla, elena, civil) · (facundo, gabriela, industrial). Verificado: SQL y Prolog coinciden.

**Notas:** La misma tabla aparece dos veces con alias (`a1`, `a2`); en Prolog, el mismo predicado dos veces con variables distintas. Sin `L1 < L2` aparecen los pares (ana, ana) y cada par dos veces, (ana, bruno) y (bruno, ana): es el ej. 1.4 de Clocksin y Mellish (SQL-9). Probar con `L1 \== L2` para ver la duplicación.

### PAR-9 — UNION: inscriptos en una materia o en otra

- **Tema:** 11 (+ 2, 9)
- **Dificultad:** 2
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Legajos de los alumnos inscriptos en `am1` o en `log`, sin repetir y ordenados.

**SQL (SQLite):**

```sql
SELECT legajo FROM inscripciones WHERE materia = 'am1'
UNION
SELECT legajo FROM inscripciones WHERE materia = 'log'
ORDER BY legajo;
```

**Prolog:**

```prolog
en_am1_o_log(L) :- inscripcion(L, am1, _).
en_am1_o_log(L) :- inscripcion(L, log, _).

?- setof(L0, en_am1_o_log(L0), Ls), member(L, Ls).
```

**Resultado:** (101) · (102) · (103) · (104) · (105) · (106) (en este orden). Verificado: SQL y Prolog coinciden.

**Notas:** La unión se escribe como **dos cláusulas** de la misma regla (Sterling y Shapiro, SQL-1). `UNION` de SQL elimina repetidos; la regla no, por eso se envuelve en `setof`. Los alumnos 101, 102 y 106 están en las dos materias.

### PAR-10 — UNION ALL: la misma regla sin setof

- **Tema:** 11 (+ 2)
- **Dificultad:** 1
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Igual que PAR-9, pero conservando las repeticiones: un legajo por cada inscripción a `am1` o a `log`.

**SQL (SQLite):**

```sql
SELECT legajo FROM inscripciones WHERE materia = 'am1'
UNION ALL
SELECT legajo FROM inscripciones WHERE materia = 'log';
```

**Prolog:**

```prolog
?- en_am1_o_log(L).
```

**Resultado:** (101) · (102) · (103) · (105) · (106) · (101) · (102) · (104) · (106). Verificado: SQL y Prolog coinciden.

**Notas:** Nueve filas en los dos lenguajes: la regla con dos cláusulas es exactamente `UNION ALL`. Pregunta: ¿qué conviene usar en SQL cuando se sabe que no hay repetidos, `UNION` o `UNION ALL`? (`UNION ALL`, porque no necesita ordenar ni comparar filas.)

### PAR-11 — INTERSECT: inscriptos en las dos materias

- **Tema:** 11 (+ 1)
- **Dificultad:** 1
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Legajos de los alumnos inscriptos en `am1` y también en `alg`.

**SQL (SQLite):**

```sql
SELECT legajo FROM inscripciones WHERE materia = 'am1'
INTERSECT
SELECT legajo FROM inscripciones WHERE materia = 'alg';
```

**Prolog:**

```prolog
?- inscripcion(L, am1, _), inscripcion(L, alg, _).
```

**Resultado:** (101) · (102) · (103). Verificado: SQL y Prolog coinciden.

**Notas:** La intersección es una conjunción con la misma variable (`r_meet_s` en SQL-2). Aquí no aparecen repetidos porque la clave primaria de `inscripciones` es (legajo, materia); si hubiera dos inscripciones de un alumno en `am1`, Prolog devolvería el legajo dos veces e `INTERSECT` una sola.

### PAR-12 — EXCEPT: inscriptos en una materia pero no en otra

- **Tema:** 11 (+ 8)
- **Dificultad:** 1
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Legajos de los alumnos inscriptos en `am1` que no están inscriptos en `alg`.

**SQL (SQLite):**

```sql
SELECT legajo FROM inscripciones WHERE materia = 'am1'
EXCEPT
SELECT legajo FROM inscripciones WHERE materia = 'alg';
```

**Prolog:**

```prolog
?- inscripcion(L, am1, _), \+ inscripcion(L, alg, _).
```

**Resultado:** (105) · (106). Verificado: SQL y Prolog coinciden.

**Notas:** La diferencia es `\+` (negación por falla). Funciona bien porque cuando se evalúa `\+ inscripcion(L, alg, _)` la variable `L` ya tiene valor: la negación sólo **verifica**, no genera. Se usa `_` para la nota porque no importa cuál sea.

### PAR-13 — NOT EXISTS: alumnos sin inscripciones

- **Tema:** 11 (+ 8)
- **Dificultad:** 1
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Legajo y nombre de los alumnos que no están inscriptos en ninguna materia.

**SQL (SQLite):**

```sql
SELECT a.legajo, a.nombre FROM alumnos a
WHERE NOT EXISTS (SELECT * FROM inscripciones i
                  WHERE i.legajo = a.legajo);
```

**Prolog:**

```prolog
?- alumno(L, N, _, _), \+ inscripcion(L, _, _).
```

**Resultado:** (107, gabriela). Verificado: SQL y Prolog coinciden.

**Notas:** `NOT EXISTS (subconsulta correlacionada)` se traduce palabra por palabra: «no existe una inscripción de `L`» es `\+ inscripcion(L, _, _)`. Es la hipótesis de mundo cerrado: lo que no figura como hecho se considera falso.

### PAR-14 — Negación antes de tiempo (difieren)

- **Tema:** 11 (+ 8)
- **Dificultad:** 2
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Un alumno intentó resolver PAR-13 poniendo la negación primero. Ejecutar su consulta, comparar con la de SQL y explicar la diferencia.

**SQL (SQLite):**

```sql
SELECT a.legajo, a.nombre FROM alumnos a
WHERE NOT EXISTS (SELECT * FROM inscripciones i
                  WHERE i.legajo = a.legajo);
```

**Prolog:**

```prolog
?- \+ inscripcion(L, _, _), alumno(L, N, _, _).
```

**Resultado:** SQL: (107, gabriela). Prolog: (ninguna solución). Verificado: **difieren**, como se explica en las notas.

**Notas:** Con `L` libre, `inscripcion(L, _, _)` tiene solución (cualquier inscripción), así que `\+ inscripcion(L, _, _)` **falla** y la consulta no devuelve nada. `\+` no significa «para algún `L` que no esté inscripto», sino «no hay ninguna inscripción». En SQL no pasa porque `NOT EXISTS` siempre se evalúa fila por fila de `alumnos` (la correlación `i.legajo = a.legajo` liga la variable). Regla práctica: toda variable de un objetivo negado tiene que estar ligada por un objetivo positivo anterior (la *seguridad* de Datalog, SQL-27).

### PAR-15 — Vista contra regla

- **Tema:** 11 (+ 2)
- **Dificultad:** 1
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Definir la vista/regla `aprobadas` (inscripciones con nota 6 o más) y usarla para listar las materias aprobadas por el alumno 101.

**SQL (SQLite):**

```sql
CREATE VIEW aprobadas AS
  SELECT legajo, materia, nota FROM inscripciones
  WHERE nota >= 6;

SELECT materia FROM aprobadas WHERE legajo = 101;
```

**Prolog:**

```prolog
aprobada(L, M, N) :-
    inscripcion(L, M, N), integer(N), N >= 6.

?- aprobada(101, M, _).
```

**Resultado:** (alg) · (am1) · (am2) · (log). Verificado: SQL y Prolog coinciden.

**Notas:** Una vista es una consulta con nombre y una regla también: ninguna guarda datos, se recalculan cada vez que se consultan. La regla `aprobada/3` se reutiliza en PAR-16, PAR-22 y PAR-49. En SQLite la vista queda en la base con `CREATE VIEW`; en Prolog la regla queda en el programa.

### PAR-16 — División: aprobaron todas las materias de primer año

- **Tema:** 11 (+ 8)
- **Dificultad:** 3
- **Esquema:** académico (`alumnos`, `materias`, `correlativas`, `inscripciones`)
- **Enunciado:** Legajo y nombre de los alumnos que aprobaron **todas** las materias de primer año.

**SQL (SQLite):**

```sql
SELECT a.legajo, a.nombre FROM alumnos a
WHERE NOT EXISTS (
  SELECT * FROM materias m
  WHERE m.anio = 1
    AND NOT EXISTS (SELECT * FROM inscripciones i
                    WHERE i.legajo = a.legajo
                      AND i.materia = m.codigo
                      AND i.nota >= 6));
```

**Prolog:**

```prolog
?- alumno(L, N, _, _),
   forall(materia(M, _, 1), aprobada(L, M, _)).
```

**Resultado:** (101, ana). Verificado: SQL y Prolog coinciden.

**Verificación complementaria PAR-16b** (la misma consulta con doble negación, sin `forall`):

```prolog
?- alumno(L, N, _, _),
   \+ ( materia(M, _, 1), \+ aprobada(L, M, _) ).
```

Resultado: (101, ana). Verificado: SQL y Prolog coinciden.

**Notas:** «Para todo» no existe en SQL: se escribe como «no existe una materia de primer año que el alumno no haya aprobado» (doble `NOT EXISTS`). En Prolog, `forall(Condición, Acción)` se define justamente como `\+ (Condición, \+ Acción)`: la verificación complementaria PAR-16b muestra que las dos formas coinciden. Sólo ana cumple: diego no cursó `am1`.

## Bloque B: agregados

### PAR-17 — COUNT(*) contra aggregate_all(count)

- **Tema:** 11 (+ 9)
- **Dificultad:** 1
- **Esquema:** académico
- **Enunciado:** ¿Cuántos alumnos tiene la carrera `sistemas`?

**SQL (SQLite):**

```sql
SELECT COUNT(*) FROM alumnos WHERE carrera = 'sistemas';
```

**Prolog:**

```prolog
?- aggregate_all(count, alumno(_, _, sistemas, _), K).
```

**Resultado:** (3). Verificado: SQL y Prolog coinciden.

**Notas:** `aggregate_all(count, Objetivo, K)` cuenta las soluciones de `Objetivo`, igual que `COUNT(*)` cuenta las filas que pasan el `WHERE`. Equivale a `findall(x, Objetivo, L), length(L, K)`. Si no hay ninguna solución, da 0 (ver PAR-46).

### PAR-18 — GROUP BY contra bagof

- **Tema:** 11 (+ 9)
- **Dificultad:** 2
- **Esquema:** académico
- **Enunciado:** Cantidad de alumnos por carrera.

**SQL (SQLite):**

```sql
SELECT carrera, COUNT(*) FROM alumnos
GROUP BY carrera;
```

**Prolog:**

```prolog
?- bagof(L, N^I^alumno(L, N, C, I), Ls), length(Ls, K).
```

**Resultado:** (civil, 2) · (industrial, 2) · (sistemas, 3). Verificado: SQL y Prolog coinciden.

**Notas:** `bagof/3` con la variable `C` libre (sin `^`) produce **una solución por cada valor de `C`**: es exactamente `GROUP BY carrera`. Las variables marcadas con `^` son las que se «agregan» dentro del grupo. Como `GROUP BY`, `bagof` sólo produce grupos no vacíos: una carrera sin alumnos no aparece (ver PAR-46b).

### PAR-19 — Conteo por grupo incluyendo los grupos vacíos

- **Tema:** 11 (+ 9)
- **Dificultad:** 2
- **Esquema:** académico
- **Enunciado:** Para cada materia, la cantidad de inscriptos, **incluidas** las materias sin inscriptos.

**SQL (SQLite):**

```sql
SELECT m.codigo, COUNT(i.legajo)
FROM materias m LEFT JOIN inscripciones i ON i.materia = m.codigo
GROUP BY m.codigo;
```

**Prolog:**

```prolog
?- materia(M, _, _), aggregate_all(count, inscripcion(_, M, _), K).
```

**Resultado:** (alg, 4) · (am1, 5) · (am2, 2) · (bd, 0) · (log, 4) · (pp, 2) · (ssl, 0). Verificado: SQL y Prolog coinciden.

**Notas:** En SQL hace falta un `LEFT JOIN` y contar `COUNT(i.legajo)` (no `COUNT(*)`, que contaría 1 para las materias sin inscriptos, porque la fila completada con `NULL` existe). En Prolog el patrón «generar el grupo y después contar» (`materia(M, _, _), aggregate_all(...)`) incluye los ceros sin esfuerzo: `ssl` y `bd` dan 0. Es el patrón que usa el cuaderno de SWISH (SQL-14).

### PAR-20 — AVG ignora los NULL; en Prolog hay que filtrarlos

- **Tema:** 11 (+ 9)
- **Dificultad:** 2
- **Esquema:** académico
- **Enunciado:** Promedio de notas de cada alumno, contando sólo las materias que ya tienen nota.

**SQL (SQLite):**

```sql
SELECT legajo, AVG(nota) FROM inscripciones
WHERE nota IS NOT NULL
GROUP BY legajo;
```

**Prolog:**

```prolog
?- bagof(N, M^(inscripcion(L, M, N), integer(N)), Ns),
   sum_list(Ns, S), length(Ns, K), P is S / K.
```

**Resultado:** (101, 8.5) · (102, 4) · (103, 6) · (104, 8) · (106, 4.5). Verificado: SQL y Prolog coinciden.

**Notas:** `AVG` de SQL descarta los `NULL` por su cuenta; en Prolog el filtro `integer(N)` va dentro del objetivo de `bagof` (si no, `sum_list` falla con el átomo `null`). El `WHERE nota IS NOT NULL` del SQL evita que aparezca elena con promedio `NULL` (sólo tiene una inscripción sin nota); en Prolog `bagof` directamente no produce ese grupo. Detalle numérico: Prolog calcula `12 / 3` como el entero 4 y SQLite como el real 4.0; el verificador los considera iguales.

### PAR-21 — MAX en subconsulta: quién sacó la nota más alta

- **Tema:** 11 (+ 9)
- **Dificultad:** 2
- **Esquema:** académico
- **Enunciado:** Nombre y nota del alumno (o los alumnos) con la nota más alta en `log`.

**SQL (SQLite):**

```sql
SELECT a.nombre, i.nota
FROM inscripciones i JOIN alumnos a ON a.legajo = i.legajo
WHERE i.materia = 'log'
  AND i.nota = (SELECT MAX(nota) FROM inscripciones
                WHERE materia = 'log');
```

**Prolog:**

```prolog
?- aggregate_all(max(N), (inscripcion(_, log, N), integer(N)), Max),
   inscripcion(L, log, Max), alumno(L, A, _, _).
```

**Resultado:** (ana, 10). Verificado: SQL y Prolog coinciden.

**Notas:** Primero se calcula el máximo y después se buscan las filas que lo alcanzan, igual que la subconsulta `= (SELECT MAX(...))`. Si hubiera empate, las dos versiones devuelven a todos los empatados. `aggregate_all(max(N), ...)` **falla** si no hay ninguna nota (SQL devolvería `NULL`); ver PAR-47b. En el `MAX` de SQL no hace falta excluir los `NULL`; en Prolog sí (`integer(N)`), porque `aggregate_all(max(...))` evalúa aritméticamente y con `null` lanza un error de tipo (verificado).

### PAR-22 — HAVING: alumnos con tres o más materias aprobadas

- **Tema:** 11 (+ 2, 9)
- **Dificultad:** 2
- **Esquema:** académico
- **Enunciado:** Nombre de los alumnos con al menos tres materias aprobadas y cuántas aprobaron.

**SQL (SQLite):**

```sql
SELECT a.nombre, COUNT(*)
FROM alumnos a JOIN inscripciones i ON i.legajo = a.legajo
WHERE i.nota >= 6
GROUP BY a.legajo, a.nombre
HAVING COUNT(*) >= 3;
```

**Prolog:**

```prolog
?- alumno(L, N, _, _),
   aggregate_all(count, aprobada(L, _, _), K), K >= 3.
```

**Resultado:** (ana, 4) · (diego, 3). Verificado: SQL y Prolog coinciden.

**Notas:** `HAVING` filtra grupos después de agregar: en Prolog es simplemente una comparación **después** de `aggregate_all`. Se reutiliza la regla `aprobada/3` de PAR-15, igual que en SQL se podría reutilizar la vista `aprobadas`.

## Bloque C: esquema empresa

### PAR-23 — Self-join: cada empleado con su jefe

- **Tema:** 11 (+ 2)
- **Dificultad:** 1
- **Esquema:** empresa (`empleados`, `departamentos`)
- **Enunciado:** Nombre de cada empleado y nombre de su jefe directo.

**SQL (SQLite):**

```sql
SELECT e.nombre, j.nombre
FROM empleados e JOIN empleados j ON e.jefe = j.id;
```

**Prolog:**

```prolog
?- empleado(_, E, _, _, IdJ), empleado(IdJ, J, _, _, _).
```

**Resultado:** (jorge, marta) · (lucia, marta) · (pablo, jorge) · (sofia, jorge) · (tomas, lucia) · (valeria, lucia) · (nicolas, valeria) · (irene, marta). Verificado: SQL y Prolog coinciden.

**Notas:** La columna `jefe` referencia a la misma tabla: se une `empleados` consigo misma. En Prolog el join es la variable `IdJ`. marta no aparece en ninguno de los dos lenguajes: en SQL porque `NULL = 1` no es verdadero; en Prolog porque no hay ningún empleado con identificador `null`.

### PAR-24 — LEFT JOIN: todos los empleados, tengan o no jefe

- **Tema:** 11 (+ 2, 8)
- **Dificultad:** 2
- **Esquema:** empresa (`empleados`, `departamentos`)
- **Enunciado:** Igual que PAR-23, pero incluyendo a quien no tiene jefe, con `NULL` en la segunda columna.

**SQL (SQLite):**

```sql
SELECT e.nombre, j.nombre
FROM empleados e LEFT JOIN empleados j ON e.jefe = j.id;
```

**Prolog:**

```prolog
jefe_o_null(E, J) :-
    empleado(_, E, _, _, IdJ), empleado(IdJ, J, _, _, _).
jefe_o_null(E, null) :-
    empleado(_, E, _, _, IdJ), \+ empleado(IdJ, _, _, _, _).

?- jefe_o_null(E, J).
```

**Resultado:** (marta, NULL) · (jorge, marta) · (lucia, marta) · (pablo, jorge) · (sofia, jorge) · (tomas, lucia) · (valeria, lucia) · (nicolas, valeria) · (irene, marta). Verificado: SQL y Prolog coinciden.

**Notas:** Prolog no tiene joins externos: se escriben como dos cláusulas, una para «tiene pareja en la otra tabla» y otra para «no la tiene» (con `\+`), que completa con `null`. Así lo traduce también el cuaderno de SWISH (SQL-13). Alternativa con si-entonces-sino: `( empleado(IdJ, J, _, _, _) -> true ; J = null )`.

### PAR-25 — Join con selección sobre la otra tabla

- **Tema:** 11 (+ 2)
- **Dificultad:** 1
- **Esquema:** empresa (`empleados`, `departamentos`)
- **Enunciado:** Nombre de los empleados que trabajan en Rosario y el nombre de su departamento.

**SQL (SQLite):**

```sql
SELECT e.nombre, d.nombre
FROM empleados e JOIN departamentos d ON e.depto = d.codigo
WHERE d.ciudad = 'rosario';
```

**Prolog:**

```prolog
?- empleado(_, E, D, _, _), departamento(D, ND, rosario).
```

**Resultado:** (marta, direccion) · (lucia, sistemas) · (tomas, sistemas) · (valeria, sistemas) · (nicolas, sistemas) · (irene, recursos_humanos). Verificado: SQL y Prolog coinciden.

**Notas:** La condición `d.ciudad = 'rosario'` se escribe poniendo la constante en el tercer argumento de `departamento/3`. Pregunta: ¿cambia el resultado si se escribe primero `departamento(D, ND, rosario)` y después `empleado(...)`? (No cambia el conjunto de respuestas, sólo su orden y el trabajo que hace Prolog.)

### PAR-26 — Departamentos sin empleados

- **Tema:** 11 (+ 8)
- **Dificultad:** 1
- **Esquema:** empresa (`empleados`, `departamentos`)
- **Enunciado:** Códigos de los departamentos que no tienen ningún empleado.

**SQL (SQLite):**

```sql
SELECT d.codigo FROM departamentos d
WHERE NOT EXISTS (SELECT * FROM empleados e
                  WHERE e.depto = d.codigo);
```

**Prolog:**

```prolog
?- departamento(D, _, _), \+ empleado(_, _, D, _, _).
```

**Resultado:** (legal). Verificado: SQL y Prolog coinciden.

**Notas:** Mismo patrón que PAR-13: primero se genera el departamento y después se niega. Invertir el orden reproduce el error de PAR-14.

### PAR-27 — SUM con GROUP BY y HAVING

- **Tema:** 11 (+ 9)
- **Dificultad:** 2
- **Esquema:** empresa (`empleados`, `departamentos`)
- **Enunciado:** Departamentos cuya masa salarial (suma de salarios) supera 1 000 000, con esa suma.

**SQL (SQLite):**

```sql
SELECT depto, SUM(salario) FROM empleados
GROUP BY depto
HAVING SUM(salario) > 1000000;
```

**Prolog:**

```prolog
?- departamento(D, _, _),
   aggregate_all(sum(S), empleado(_, _, D, S, _), T), T > 1000000.
```

**Resultado:** (it, 1820000) · (ventas, 1230000). Verificado: SQL y Prolog coinciden.

**Notas:** Diferencia oculta: para `legal` (sin empleados) `aggregate_all(sum(S), ...)` da **0**, mientras que en SQL el grupo `legal` ni siquiera existe (y `SUM` sobre cero filas sería `NULL`, PAR-47). Aquí no se nota porque el filtro `> 1000000` elimina ese caso, pero si el enunciado dijera «menos de 500 000», Prolog listaría `legal` y SQL no.

### PAR-28 — El mejor pago de cada departamento

- **Tema:** 11 (+ 8)
- **Dificultad:** 3
- **Esquema:** empresa (`empleados`, `departamentos`)
- **Enunciado:** Para cada departamento con empleados, el nombre y el salario de quien más gana.

**SQL (SQLite):**

```sql
SELECT e.depto, e.nombre, e.salario FROM empleados e
WHERE e.salario = (SELECT MAX(salario) FROM empleados e2
                   WHERE e2.depto = e.depto);
```

**Prolog:**

```prolog
?- empleado(_, N, D, S, _),
   \+ ( empleado(_, _, D, S2, _), S2 > S ).
```

**Resultado:** (dir, marta, 900000) · (ventas, jorge, 500000) · (it, lucia, 650000) · (rrhh, irene, 400000). Verificado: SQL y Prolog coinciden.

**Notas:** La versión Prolog no usa agregados: «nadie del mismo departamento gana más» (`\+` con `S2 > S`). Es el mismo truco que el cuaderno de SWISH usa para «la universidad más grande» (SQL-13) y que exige la consulta 7 de las pizzerías (SQL-16). La subconsulta SQL es correlacionada: se recalcula para el departamento de cada fila. Variante para el alumno: resolverlo con `aggregate_all(max(S), empleado(_, _, D, S, _), Max)`.

### PAR-29 — ORDER BY DESC y LIMIT

- **Tema:** 11 (+ 9)
- **Dificultad:** 2
- **Esquema:** empresa (`empleados`, `departamentos`)
- **Enunciado:** Nombre y salario de los tres empleados mejor pagos, de mayor a menor.

**SQL (SQLite):**

```sql
SELECT nombre, salario FROM empleados
ORDER BY salario DESC
LIMIT 3;
```

**Prolog:**

```prolog
?- limit(3, order_by([desc(S)], empleado(_, N, _, S, _))).
```

**Resultado:** (marta, 900000) · (lucia, 650000) · (jorge, 500000) (en este orden). Verificado: SQL y Prolog coinciden.

**Notas:** `limit/2` y `order_by/2` son los análogos directos (SQL-25). Sin ellos: `findall(S-N, empleado(_, N, _, S, _), Ps), msort(Ps, Asc), reverse(Asc, [P1, P2, P3 | _])`. Con empates en el tercer puesto, ninguno de los dos lenguajes garantiza cuál de los empatados aparece.

## Bloque D: NULL contra mundo cerrado

### PAR-30 — NOT IN con un NULL en la subconsulta (difieren)

- **Tema:** 11 (+ 8)
- **Dificultad:** 3
- **Esquema:** empresa (`empleados`, `departamentos`)
- **Enunciado:** Listar los empleados que no son jefes de nadie. Comparar la solución SQL con `NOT IN` y la solución Prolog, y explicar por qué SQL no devuelve ninguna fila.

**SQL (SQLite):**

```sql
SELECT id, nombre FROM empleados
WHERE id NOT IN (SELECT jefe FROM empleados);
```

**Prolog:**

```prolog
?- empleado(Id, N, _, _, _), \+ empleado(_, _, _, _, Id).
```

**Resultado:** SQL: (ninguna fila). Prolog: (4, pablo) · (5, sofia) · (6, tomas) · (8, nicolas) · (9, irene). Verificado: **difieren**, como se explica en las notas.

**Notas:** La subconsulta `SELECT jefe FROM empleados` contiene un `NULL` (el de marta). Para SQL, `4 NOT IN (1, 1, 2, 2, 3, 3, 7, 1, NULL)` significa `4 <> 1 AND ... AND 4 <> NULL`, y `4 <> NULL` es *desconocido*, así que la condición nunca es verdadera: **ninguna fila**. En Prolog, `null` es un átomo cualquiera y `\+ empleado(_, _, _, _, 4)` simplemente no encuentra al 4 como jefe. Es la trampa de `NULL` más conocida de SQL. Soluciones: `NOT EXISTS` (PAR-31) o `WHERE jefe IS NOT NULL` dentro de la subconsulta.

### PAR-31 — NOT EXISTS: la versión correcta

- **Tema:** 11 (+ 8)
- **Dificultad:** 2
- **Esquema:** empresa (`empleados`, `departamentos`)
- **Enunciado:** Resolver PAR-30 con `NOT EXISTS` y comprobar que coincide con Prolog.

**SQL (SQLite):**

```sql
SELECT e.id, e.nombre FROM empleados e
WHERE NOT EXISTS (SELECT * FROM empleados s
                  WHERE s.jefe = e.id);
```

**Prolog:**

```prolog
?- empleado(Id, N, _, _, _), \+ empleado(_, _, _, _, Id).
```

**Resultado:** (4, pablo) · (5, sofia) · (6, tomas) · (8, nicolas) · (9, irene). Verificado: SQL y Prolog coinciden.

**Notas:** Con `NOT EXISTS` la comparación con `NULL` sólo hace que esa fila de la subconsulta no cuente; no «contamina» toda la condición. Por eso `NOT EXISTS` es la traducción fiel de `\+`. Resultado: pablo, sofia, tomas, nicolas e irene.

### PAR-32 — Comparar con NULL: `<>` contra `\==` (difieren)

- **Tema:** 11 (+ 8)
- **Dificultad:** 2
- **Esquema:** empresa (`empleados`, `departamentos`)
- **Enunciado:** Listar los empleados cuyo jefe no es el empleado 1. Comparar ambas soluciones: ¿qué pasa con marta?

**SQL (SQLite):**

```sql
SELECT nombre FROM empleados WHERE jefe <> 1;
```

**Prolog:**

```prolog
?- empleado(_, N, _, _, J), J \== 1.
```

**Resultado:** SQL: (pablo) · (sofia) · (tomas) · (valeria) · (nicolas). Prolog: (marta) · (pablo) · (sofia) · (tomas) · (valeria) · (nicolas). Verificado: **difieren**, como se explica en las notas.

**Verificación complementaria PAR-32b** (la versión Prolog que reproduce la lógica de SQL):

```prolog
?- empleado(_, N, _, _, J), J \== null, J \== 1.
```

Resultado: (pablo) · (sofia) · (tomas) · (valeria) · (nicolas). Verificado: SQL y Prolog coinciden.

**Notas:** SQL usa lógica de **tres valores**: `NULL <> 1` es *desconocido* y la fila de marta se descarta. Prolog usa lógica de dos valores con **mundo cerrado**: `null \== 1` es verdadero y marta aparece. Ninguna está «mal»: responden preguntas distintas. Si se quiere la respuesta de SQL, hay que excluir `null` explícitamente (PAR-32b).

## Bloque E: recursión

### PAR-33 — Subordinados directos e indirectos

- **Tema:** 11 (+ 5)
- **Dificultad:** 2
- **Esquema:** empresa
- **Enunciado:** Identificador y nombre de todas las personas que dependen, directa o indirectamente, de lucia (id 3).

**SQL (SQLite):**

```sql
WITH RECURSIVE subordinado(id) AS (
  SELECT id FROM empleados WHERE jefe = 3
  UNION
  SELECT e.id FROM empleados e JOIN subordinado s ON e.jefe = s.id
)
SELECT e.id, e.nombre FROM empleados e JOIN subordinado s ON e.id = s.id;
```

**Prolog:**

```prolog
subordinado(S, J) :-
    empleado(S, _, _, _, J).
subordinado(S, J) :-
    empleado(S, _, _, _, X), subordinado(X, J).

?- subordinado(Id, 3), empleado(Id, N, _, _, _).
```

**Resultado:** (6, tomas) · (7, valeria) · (8, nicolas). Verificado: SQL y Prolog coinciden.

**Notas:** La regla recursiva tiene la misma forma que el CTE: un **caso base** (la parte antes del `UNION`: subordinados directos) y un **caso recursivo** (la parte después: subordinados de un subordinado). nicolas aparece porque depende de valeria, que depende de lucia. El organigrama de la documentación de SQLite (SQL-20) es el mismo ejercicio.

### PAR-34 — Nivel jerárquico: recursión con un contador

- **Tema:** 11 (+ 5)
- **Dificultad:** 2
- **Esquema:** empresa
- **Enunciado:** Para cada empleado, su nivel en la jerarquía: 0 para quien no tiene jefe, 1 para quienes dependen de ella, y así sucesivamente.

**SQL (SQLite):**

```sql
WITH RECURSIVE nivel(id, k) AS (
  SELECT id, 0 FROM empleados WHERE jefe IS NULL
  UNION
  SELECT e.id, n.k + 1 FROM empleados e JOIN nivel n ON e.jefe = n.id
)
SELECT e.nombre, n.k FROM empleados e JOIN nivel n ON e.id = n.id;
```

**Prolog:**

```prolog
nivel(Id, 0) :-
    empleado(Id, _, _, _, null).
nivel(Id, K) :-
    empleado(Id, _, _, _, J), nivel(J, K0), K is K0 + 1.

?- empleado(Id, N, _, _, _), nivel(Id, K).
```

**Resultado:** (marta, 0) · (jorge, 1) · (lucia, 1) · (pablo, 2) · (sofia, 2) · (tomas, 2) · (valeria, 2) · (nicolas, 3) · (irene, 1). Verificado: SQL y Prolog coinciden.

**Notas:** La columna calculada `n.k + 1` del CTE es el `K is K0 + 1` de Prolog. El caso base de Prolog busca el átomo `null`; el de SQL, `jefe IS NULL` (con `jefe = NULL` no encontraría a nadie). Si por error hubiera un ciclo en la columna `jefe` (a jefe de b y b jefe de a), **ninguna** de las dos versiones terminaría: el `UNION` de SQL no descarta filas porque `k` cambia en cada vuelta.

### PAR-35 — Correlativas transitivas (conjunto)

- **Tema:** 11 (+ 5, 9)
- **Dificultad:** 2
- **Esquema:** académico
- **Enunciado:** Todas las materias que hay que aprobar, directa o indirectamente, antes de cursar `bd`, sin repetir y en orden alfabético.

**SQL (SQLite):**

```sql
WITH RECURSIVE requisito(r) AS (
  SELECT requisito FROM correlativas WHERE materia = 'bd'
  UNION
  SELECT c.requisito FROM correlativas c JOIN requisito q ON c.materia = q.r
)
SELECT r FROM requisito ORDER BY r;
```

**Prolog:**

```prolog
requisito(M, R) :-
    correlativa(M, R).
requisito(M, R) :-
    correlativa(M, X), requisito(X, R).

?- setof(R0, requisito(bd, R0), Rs), member(R, Rs).
```

**Resultado:** (alg) · (log) · (pp) · (ssl) (en este orden). Verificado: SQL y Prolog coinciden.

**Verificación complementaria PAR-35b** (`UNION ALL` contra la regla sin `setof`: las mismas repeticiones):

```sql
WITH RECURSIVE requisito(r) AS (
  SELECT requisito FROM correlativas WHERE materia = 'bd'
  UNION ALL
  SELECT c.requisito FROM correlativas c JOIN requisito q ON c.materia = q.r
)
SELECT r FROM requisito;
```

```prolog
?- requisito(bd, R).
```

Resultado: (pp) · (ssl) · (log) · (alg) · (log). Verificado: SQL y Prolog coinciden.

**Notas:** `log` es requisito de `bd` por dos caminos (a través de `pp` y de `ssl`). El `UNION` del CTE lo deja una vez; la regla recursiva lo encuentra **dos veces**, una por cada prueba, así que hace falta `setof`. PAR-35b muestra que la regla sin `setof` se comporta exactamente como `UNION ALL`: cinco filas con `log` repetido. Prolog es de bolsas «por construcción»: cada solución corresponde a una prueba distinta.

### PAR-36 — Vuelos con una escala (join de una tabla consigo misma)

- **Tema:** 11 (+ 2)
- **Dificultad:** 1
- **Esquema:** vuelos
- **Enunciado:** Desde `ros`, todos los destinos alcanzables con exactamente una escala: ciudad de escala, destino final y precio total.

**SQL (SQLite):**

```sql
SELECT v1.destino, v2.destino, v1.precio + v2.precio
FROM vuelos v1 JOIN vuelos v2 ON v1.destino = v2.origen
WHERE v1.origen = 'ros';
```

**Prolog:**

```prolog
?- vuelo(ros, Y, _, P1), vuelo(Y, Z, _, P2), P is P1 + P2.
```

**Resultado:** (aep, brc, 160) · (aep, cor, 120) · (aep, mdz, 140) · (aep, ush, 200). Verificado: SQL y Prolog coinciden.

**Notas:** Antes de la recursión conviene resolver a mano los caminos de longitud fija: una escala es un join de `vuelos` consigo misma; dos escalas, tres copias; etc. La recursión (PAR-37) generaliza esto a «cualquier cantidad de escalas».

### PAR-37 — Ciudades alcanzables en un grafo con ciclos (tabling)

- **Tema:** 11 (+ 5)
- **Dificultad:** 3
- **Esquema:** vuelos
- **Enunciado:** Todas las ciudades a las que se puede llegar desde `ros` con cualquier cantidad de escalas. Atención: hay un ciclo `aep → cor → aep`.

**SQL (SQLite):**

```sql
WITH RECURSIVE alcanza(ciudad) AS (
  SELECT destino FROM vuelos WHERE origen = 'ros'
  UNION
  SELECT v.destino FROM vuelos v JOIN alcanza a ON v.origen = a.ciudad
)
SELECT ciudad FROM alcanza;
```

**Prolog:**

```prolog
:- table alcanza/2.
alcanza(X, Y) :- vuelo(X, Y, _, _).
alcanza(X, Y) :- alcanza(X, Z), vuelo(Z, Y, _, _).

?- alcanza(ros, Y).
```

**Resultado:** (aep) · (brc) · (cor) · (mdz) · (ush) · (sla). Verificado: SQL y Prolog coinciden.

**Notas:** La directiva `:- table alcanza/2.` hace que Prolog guarde las respuestas ya encontradas y no repita llamadas idénticas: la recursión termina aunque haya ciclos, y además cada ciudad aparece **una sola vez**, igual que con `UNION`. La regla está escrita con recursión **a izquierda** (`alcanza(X, Z)` primero), que sin tabling entraría en un bucle infinito de inmediato; con tabling es la forma natural (SQL-22). Sin la directiva, ver PAR-48. Los conceptos: SQL y Datalog calculan el resultado de abajo hacia arriba hasta que no aparecen filas nuevas (punto fijo); Prolog sin tabling busca pruebas de arriba hacia abajo y en profundidad (SQL-28).

### PAR-38 — Precio mínimo a cada destino (tabling con min)

- **Tema:** 11 (+ 5, 9)
- **Dificultad:** 3
- **Esquema:** vuelos
- **Enunciado:** Para cada ciudad alcanzable desde `ros`, el precio total más barato para llegar.

**SQL (SQLite):**

```sql
WITH RECURSIVE camino(destino, precio, ruta) AS (
  SELECT destino, precio, 'ros/' || destino FROM vuelos WHERE origen = 'ros'
  UNION
  SELECT v.destino, c.precio + v.precio, c.ruta || '/' || v.destino
  FROM camino c JOIN vuelos v ON v.origen = c.destino
  WHERE instr(c.ruta, v.destino) = 0
)
SELECT destino, MIN(precio) FROM camino GROUP BY destino;
```

**Prolog:**

```prolog
:- table costo(_, _, min).
costo(X, Y, P) :- vuelo(X, Y, _, P).
costo(X, Y, P) :- costo(X, Z, P1), vuelo(Z, Y, _, P2), P is P1 + P2.

?- costo(ros, Y, P).
```

**Resultado:** (aep, 50) · (brc, 160) · (cor, 120) · (mdz, 140) · (sla, 200) · (ush, 200). Verificado: SQL y Prolog coinciden.

**Notas:** En SQL hay que construir los caminos **con su ruta** para cortar los ciclos (`instr(c.ruta, v.destino) = 0` descarta volver a una ciudad ya visitada; sin eso, con `UNION` no alcanza, porque cada vuelta por el ciclo tiene un precio distinto y la fila es «nueva»), y al final agrupar con `MIN`. En Prolog, `:- table costo(_, _, min).` (*answer subsumption*) le indica al motor que, para cada par origen-destino, guarde sólo el precio mínimo: la búsqueda termina aunque haya ciclos porque un camino más caro no agrega nada a la tabla. Ejemplo: a `mdz` se llega por `aep` (140) o por `aep → cor` (175); queda 140.

## Bloque F: INSERT, UPDATE y DELETE contra assertz y retract

En todos los ejercicios de este bloque el resultado que se compara es el contenido de la tabla **después** de la modificación. Recordar que para modificar un predicado en ejecución hace falta declararlo `:- dynamic` (está en `datos.pl`).

### PAR-39 — INSERT contra assertz

- **Tema:** 11 (+ 10)
- **Dificultad:** 1
- **Esquema:** académico
- **Enunciado:** Inscribir a gabriela (legajo 107) en `log`, todavía sin nota, y listar sus inscripciones.

**SQL (SQLite):**

```sql
INSERT INTO inscripciones (legajo, materia, nota) VALUES (107, 'log', NULL);

SELECT materia, nota FROM inscripciones WHERE legajo = 107;
```

**Prolog:**

```prolog
?- assertz(inscripcion(107, log, null)),
   inscripcion(107, M, N).
```

**Resultado:** (log, NULL). Verificado: SQL y Prolog coinciden.

**Notas:** `assertz` agrega el hecho al **final** del predicado (como una fila nueva); `asserta` lo agrega al principio. En SQL el orden físico de las filas no importa; en Prolog el orden de los hechos determina el orden de las respuestas.

### PAR-40 — UPDATE de una fila: retract + assertz

- **Tema:** 11 (+ 10)
- **Dificultad:** 1
- **Esquema:** académico
- **Enunciado:** Registrar la nota 8 de ana (legajo 101) en `pp` y listar todas sus inscripciones.

**SQL (SQLite):**

```sql
UPDATE inscripciones SET nota = 8
WHERE legajo = 101 AND materia = 'pp';

SELECT materia, nota FROM inscripciones WHERE legajo = 101;
```

**Prolog:**

```prolog
?- retract(inscripcion(101, pp, _)),
   assertz(inscripcion(101, pp, 8)),
   inscripcion(101, M, N).
```

**Resultado:** (alg, 9) · (am1, 8) · (am2, 7) · (log, 10) · (pp, 8). Verificado: SQL y Prolog coinciden.

**Notas:** Prolog no tiene «modificar»: un `UPDATE` es borrar el hecho viejo y agregar el nuevo. Observar que la fila modificada pasa al final del predicado (en SQL esa diferencia no se ve). Si la inscripción no existiera, `retract` fallaría y no se agregaría nada, que es lo mismo que hace un `UPDATE` que no encuentra filas.

### PAR-41 — UPDATE masivo: aumento del 10 % a un departamento

- **Tema:** 11 (+ 10)
- **Dificultad:** 2
- **Esquema:** empresa
- **Enunciado:** Aumentar un 10 % el salario de todos los empleados de `it` y listar los nuevos salarios.

**SQL (SQLite):**

```sql
UPDATE empleados SET salario = salario * 110 / 100
WHERE depto = 'it';

SELECT id, salario FROM empleados WHERE depto = 'it';
```

**Prolog:**

```prolog
?- forall(retract(empleado(I, Nom, it, S0, J)),
          ( S1 is S0 * 110 // 100, assertz(empleado(I, Nom, it, S1, J)) )),
   empleado(Id, _, it, S, _).
```

**Resultado:** (3, 715000) · (6, 462000) · (7, 495000) · (8, 330000). Verificado: SQL y Prolog coinciden.

**Notas:** `forall(retract(...), (calcular, assertz(...)))` recorre todos los hechos que coinciden, los borra y agrega la versión nueva. ¿Por qué no vuelve a aumentar los hechos recién agregados? Por la **vista lógica de actualización** de SWI-Prolog (SQL-23): `retract` sólo recorre las cláusulas que existían cuando empezó. Es la misma garantía que da `UPDATE` en SQL. Se usa `//` (división entera) para que coincida con la división entera de SQLite; los salarios son múltiplos de 100, así que el resultado es exacto.

### PAR-42 — DELETE con condición simple: retractall

- **Tema:** 11 (+ 10)
- **Dificultad:** 1
- **Esquema:** académico
- **Enunciado:** Borrar todas las inscripciones sin nota e informar cuántas inscripciones quedan y cuántas siguen sin nota.

**SQL (SQLite):**

```sql
DELETE FROM inscripciones WHERE nota IS NULL;

SELECT COUNT(*), COUNT(*) - COUNT(nota) FROM inscripciones;
```

**Prolog:**

```prolog
?- retractall(inscripcion(_, _, null)),
   aggregate_all(count, inscripcion(_, _, _), Total),
   aggregate_all(count, inscripcion(_, _, null), SinNota).
```

**Resultado:** (14, 0). Verificado: SQL y Prolog coinciden.

**Notas:** `retractall(Cabeza)` borra todos los hechos que unifican con `Cabeza` y siempre tiene éxito (aunque no borre nada), como un `DELETE` con `WHERE`. Quedan 14 de 17. En SQL la condición es `IS NULL`; en Prolog, unificar con el átomo `null`.

### PAR-43 — DELETE con condición aritmética

- **Tema:** 11 (+ 10)
- **Dificultad:** 2
- **Esquema:** vuelos
- **Enunciado:** Borrar los vuelos de la aerolínea `fb` que cuestan más de 70 y listar los vuelos de `fb` que quedan.

**SQL (SQLite):**

```sql
DELETE FROM vuelos WHERE aerolinea = 'fb' AND precio > 70;

SELECT origen, destino, precio FROM vuelos WHERE aerolinea = 'fb';
```

**Prolog:**

```prolog
?- forall(( vuelo(O0, D0, fb, P0), P0 > 70 ), retract(vuelo(O0, D0, fb, P0))),
   vuelo(O, D, fb, P).
```

**Resultado:** (cor, aep, 60) · (cor, mdz, 55). Verificado: SQL y Prolog coinciden.

**Notas:** La condición `P > 70` no se puede escribir dentro del patrón de `retractall`, por eso primero se **buscan** los hechos que cumplen la condición y después se borra cada uno. Error típico, verificado: `forall((retract(vuelo(O, D, fb, P)), P > 70), true)` borra **todos** los vuelos de `fb`, porque `retract` borra el hecho **antes** de comprobar el precio y el borrado no se deshace al volver atrás.

### PAR-44 — Clave primaria: SQL la controla, Prolog no

- **Tema:** 11 (+ 10)
- **Dificultad:** 2
- **Esquema:** académico
- **Enunciado:** Intentar dar de alta a zoe con el legajo 101, que ya existe. En SQL, observar el error; en Prolog, escribir `alta_alumno/4` que sólo agregue el alumno si el legajo está libre. En los dos casos, listar después los alumnos con legajo 101.

**SQL (SQLite):**

```sql
INSERT INTO alumnos VALUES (101, 'zoe', 'civil', 2025);
-- Error: UNIQUE constraint failed: alumnos.legajo

SELECT nombre FROM alumnos WHERE legajo = 101;
```

**Prolog:**

```prolog
alta_alumno(L, N, C, I) :-
    \+ alumno(L, _, _, _),
    assertz(alumno(L, N, C, I)).

?- ( alta_alumno(101, zoe, civil, 2025) -> true ; true ),
   alumno(101, N, _, _).
```

**Resultado:** (ana). Verificado: SQL y Prolog coinciden.

**Verificación complementaria PAR-44b** (`assertz` directo, sin control: la «clave» queda duplicada):

```prolog
?- assertz(alumno(101, zoe, civil, 2025)),
   alumno(101, N, _, _).
```

Resultado: Prolog: (ana) · (zoe). Verificado contra el valor esperado.

**Notas:** `PRIMARY KEY` hace que SQLite rechace la fila (`UNIQUE constraint failed: alumnos.legajo`, capturado por el verificador). Prolog no tiene restricciones: `assertz` agrega el hecho duplicado sin protestar (PAR-44b: quedan ana y zoe con el mismo legajo). La restricción hay que programarla en el predicado de alta, comprobando antes con `\+`. En SQLite existe `INSERT OR IGNORE`, que se comporta como `alta_alumno/4`: si la clave existe, no hace nada.

### PAR-45 — Clave foránea: integridad referencial a mano

- **Tema:** 11 (+ 8, 10)
- **Dificultad:** 2
- **Esquema:** académico
- **Enunciado:** Intentar inscribir en `am1` a un legajo inexistente (999) y a gabriela (107). Escribir `alta_inscripcion/2`, que sólo inscribe si el alumno y la materia existen y la inscripción no está repetida. Listar después las inscripciones de 999 y 107.

**SQL (SQLite):**

```sql
PRAGMA foreign_keys = ON;

INSERT INTO inscripciones (legajo, materia) VALUES (999, 'am1');
-- Error: FOREIGN KEY constraint failed
INSERT INTO inscripciones (legajo, materia) VALUES (107, 'am1');

SELECT legajo, materia, nota FROM inscripciones
WHERE legajo IN (999, 107);
```

**Prolog:**

```prolog
alta_inscripcion(L, M) :-
    alumno(L, _, _, _),
    materia(M, _, _),
    \+ inscripcion(L, M, _),
    assertz(inscripcion(L, M, null)).

?- ( alta_inscripcion(999, am1) -> true ; true ),
   ( alta_inscripcion(107, am1) -> true ; true ),
   inscripcion(L, M, N), member(L, [999, 107]).
```

**Resultado:** (107, am1, NULL). Verificado: SQL y Prolog coinciden.

**Notas:** `REFERENCES` sólo se controla en SQLite si se activa `PRAGMA foreign_keys = ON` en **cada conexión** (por compatibilidad, viene apagado; sin él, la fila de 999 se insertaría). En Prolog, cada restricción es un objetivo más en la regla de alta: `alumno(L, _, _, _)` es la clave foránea hacia alumnos, `materia(M, _, _)` hacia materias y `\+ inscripcion(L, M, _)` la clave primaria. Discusión: ¿qué ventaja tiene que la base controle las restricciones en lugar de cada programa que la modifica?

## Bloque G: dónde difieren

Preguntas conceptuales con evidencia ejecutable. En cada caso conviene pedir primero la predicción y después ejecutar.

### PAR-46 — Contar lo que no existe: 0 contra grupo vacío

- **Tema:** 11 (+ 9)
- **Dificultad:** 2
- **Esquema:** académico
- **Enunciado:** ¿Cuántos alumnos hay en la carrera `quimica` (que no existe)? Responder con un conteo simple y con un conteo agrupado por carrera. ¿Coinciden SQL y Prolog en los dos casos?

**SQL (SQLite):**

```sql
SELECT COUNT(*) FROM alumnos WHERE carrera = 'quimica';
```

**Prolog:**

```prolog
?- aggregate_all(count, alumno(_, _, quimica, _), K).
```

**Resultado:** (0). Verificado: SQL y Prolog coinciden.

**Verificación complementaria PAR-46b** (agrupando: `GROUP BY` contra `bagof`):

```sql
SELECT carrera, COUNT(*) FROM alumnos
WHERE carrera = 'quimica'
GROUP BY carrera;
```

```prolog
?- C = quimica,
   bagof(L, N^I^alumno(L, N, C, I), Ls), length(Ls, K).
```

Resultado: (ninguna fila). Verificado: SQL y Prolog coinciden.

**Notas:** Coinciden, y conviene saber por qué. Sin agrupar, `COUNT(*)` y `aggregate_all(count, ...)` dan 0. Agrupando, `GROUP BY` no produce ninguna fila (no hay grupo `quimica`) y `bagof` **falla** (no hay soluciones): los dos tratan igual los grupos vacíos. `findall`/`aggregate_all` corresponden a los agregados sin `GROUP BY`; `bagof`/`setof`, a los agregados con `GROUP BY` (ver SQL-11 y PAR-18).

### PAR-47 — SUM y MAX de nada: NULL contra 0 y contra falla (difieren)

- **Tema:** 11 (+ 9)
- **Dificultad:** 2
- **Esquema:** empresa
- **Enunciado:** Calcular la suma y el máximo de los salarios del departamento `legal`, que no tiene empleados. Comparar las respuestas.

**SQL (SQLite):**

```sql
SELECT SUM(salario) FROM empleados WHERE depto = 'legal';
```

**Prolog:**

```prolog
?- aggregate_all(sum(S), empleado(_, _, legal, S, _), T).
```

**Resultado:** SQL: (NULL). Prolog: (0). Verificado: **difieren**, como se explica en las notas.

**Verificación complementaria PAR-47b** (el máximo de un conjunto vacío):

```sql
SELECT MAX(salario) FROM empleados WHERE depto = 'legal';
```

```prolog
?- aggregate_all(max(S), empleado(_, _, legal, S, _), M).
```

Resultado: SQL: (NULL). Prolog: (ninguna solución). Verificado: **difieren**, como se explica en las notas.

**Notas:** SQL devuelve una fila con `NULL` en los dos casos: «no se sabe». Prolog responde 0 para la suma (el neutro de la suma, matemáticamente razonable) y **falla** para el máximo (no hay máximo de un conjunto vacío). Consecuencia práctica: una consulta Prolog que usa `aggregate_all(max(...))` sin controlar el caso vacío puede fallar entera. En SQL, `COALESCE(SUM(salario), 0)` reproduce el comportamiento de Prolog.

### PAR-48 — Terminación: la misma recursión sin tabling

- **Tema:** 11 (+ 5)
- **Dificultad:** 3
- **Esquema:** vuelos
- **Enunciado:** Escribir la alcanzabilidad de PAR-37 **sin** `:- table`, con recursión a derecha, y preguntar por todas las ciudades alcanzables desde `ros`. ¿Termina? ¿Y el CTE de PAR-37 si se cambia `UNION` por `UNION ALL`?

**SQL (SQLite):**

```sql
-- (sin versión SQL)
```

**Prolog:**

```prolog
alcanza_sin_tabla(X, Y) :- vuelo(X, Y, _, _).
alcanza_sin_tabla(X, Y) :- vuelo(X, Z, _, _), alcanza_sin_tabla(Z, Y).

?- call_with_inference_limit(
       findall(Y, alcanza_sin_tabla(ros, Y), _), 100000, R0),
   ( R0 == inference_limit_exceeded -> R = no_termina ; R = termina ).
```

**Resultado:** Prolog: (no_termina). Verificado contra el valor esperado.

**Verificación complementaria PAR-48b** (`UNION ALL` en el CTE: SQL tampoco termina si no descarta repetidos):

```sql
WITH RECURSIVE alcanza(ciudad) AS (
  SELECT destino FROM vuelos WHERE origen = 'ros'
  UNION ALL
  SELECT v.destino FROM vuelos v JOIN alcanza a ON v.origen = a.ciudad
)
SELECT COUNT(*) FROM (SELECT * FROM alcanza LIMIT 1000);
```

Resultado: SQL: (1000). Verificado contra el valor esperado.

**Notas:** Ninguno termina. Prolog recorre `aep → cor → aep → cor → ...` en profundidad y produce respuestas repetidas para siempre; el verificador lo corta con un límite de 100 000 inferencias (`call_with_inference_limit/3`) y comprueba que se agota. El CTE con `UNION ALL` también genera filas sin fin; el verificador lo corta con `LIMIT 1000` y comprueba que llega a las 1000 filas. Con `UNION` (SQL) o `:- table` (Prolog) el cálculo se detiene cuando no aparecen respuestas nuevas: la documentación de SQLite lo explica en SQL-21. Moraleja: la recursión sobre datos (grafos, jerarquías) necesita semántica de conjuntos para terminar.

### PAR-49 — Negar lo desconocido: lógica de tres valores contra mundo cerrado (difieren)

- **Tema:** 11 (+ 8)
- **Dificultad:** 3
- **Esquema:** académico
- **Enunciado:** Listar las inscripciones que **no** están aprobadas. En SQL, con `WHERE NOT (nota >= 6)`; en Prolog, con `\+ aprobada(...)`. Explicar por qué las inscripciones sin nota aparecen en un lenguaje y no en el otro.

**SQL (SQLite):**

```sql
SELECT legajo, materia, nota FROM inscripciones
WHERE NOT (nota >= 6);
```

**Prolog:**

```prolog
?- inscripcion(L, M, N), \+ aprobada(L, M, _).
```

**Resultado:** SQL: (102, am1, 4) · (102, alg, 2) · (103, alg, 5) · (106, log, 3). Prolog: (101, pp, null) · (102, am1, 4) · (102, alg, 2) · (103, alg, 5) · (103, am2, null) · (105, am1, null) · (106, log, 3). Verificado: **difieren**, como se explica en las notas.

**Notas:** Para SQL, `NULL >= 6` es *desconocido* y `NOT desconocido` sigue siendo *desconocido*: la fila no pasa el `WHERE`. Una inscripción sin nota no está «aprobada» ni «no aprobada». Para Prolog (hipótesis de mundo cerrado, negación por falla) lo que no se puede probar es falso: como `aprobada(101, pp, _)` no se puede probar, `\+ aprobada(101, pp, _)` es verdadero. Para obtener en SQL lo mismo que Prolog: `WHERE nota IS NULL OR nota < 6`. Para obtener en Prolog lo mismo que SQL: `integer(N), N < 6`.

### PAR-50 — Bolsas contra conjuntos

- **Tema:** 11 (+ 9)
- **Dificultad:** 1
- **Esquema:** académico
- **Enunciado:** Contar las carreras de la tabla de alumnos de dos maneras: con repeticiones y sin repeticiones.

**SQL (SQLite):**

```sql
SELECT COUNT(carrera), COUNT(DISTINCT carrera) FROM alumnos;
```

**Prolog:**

```prolog
?- findall(C, alumno(_, _, C, _), Bolsa), length(Bolsa, B),
   sort(Bolsa, Conjunto), length(Conjunto, S).
```

**Resultado:** (7, 3). Verificado: SQL y Prolog coinciden.

**Notas:** El modelo relacional teórico (y Datalog) trabaja con **conjuntos**; SQL y Prolog trabajan con **bolsas**: 7 valores contra 3 distintos. En SQL se pasa de bolsa a conjunto con `DISTINCT`; en Prolog, con `sort/2`, `setof/3` o `distinct/2`. Preguntas de cierre: ¿qué ejercicios de esta lista cambiarían su resultado si se quitara el `DISTINCT`/`setof`? (PAR-4, PAR-9, PAR-35.) ¿Por qué en SQL `UNION` elimina repetidos pero `SELECT` no?

---

# Resumen: tabla de correspondencias

| SQL (SQLite) | Prolog (SWI) | Ejercicios |
|---|---|---|
| tabla, fila | predicado, hecho | todos |
| `WHERE col = constante` | constante en el argumento | PAR-1 |
| `WHERE` con `<`, `>=`, `<>` | `<`, `>=` (números), `\==` (átomos), **después** de ligar las variables | PAR-2 |
| `SELECT col1, col2` | variables con nombre; `_` para las demás columnas | PAR-1, PAR-3 |
| `DISTINCT` | `setof/3`, `distinct/2`, `sort/2` | PAR-4, PAR-50 |
| `ORDER BY`, `LIMIT` | `order_by/2`, `limit/2`, `setof/3`, `msort/2` | PAR-5, PAR-29 |
| `JOIN ... ON a.x = b.x` | variable compartida | PAR-6, PAR-7 |
| self-join | el mismo predicado dos veces, con `L1 < L2` | PAR-8, PAR-23, PAR-36 |
| `LEFT JOIN` | dos cláusulas: con pareja y `\+` sin pareja | PAR-24 |
| `UNION` / `UNION ALL` | dos cláusulas (+ `setof` para eliminar repetidos) | PAR-9, PAR-10 |
| `INTERSECT` | conjunción | PAR-11 |
| `EXCEPT`, `NOT EXISTS` | `\+`, con las variables ya ligadas | PAR-12, PAR-13, PAR-14, PAR-26 |
| división (doble `NOT EXISTS`) | `forall/2` | PAR-16 |
| `CREATE VIEW` | regla | PAR-15 |
| `COUNT`, `SUM`, `MAX`, `AVG` sin `GROUP BY` | `aggregate_all/3`, `findall/3` + `sum_list/2` | PAR-17, PAR-21, PAR-47 |
| `GROUP BY` | `bagof/3` con variable libre, o generar el grupo + `aggregate_all/3` | PAR-18, PAR-19, PAR-20 |
| `HAVING` | comparación después del agregado | PAR-22, PAR-27 |
| máximo por grupo (subconsulta correlacionada) | `\+` «nadie es mayor» | PAR-28 |
| `NULL` | no existe; convención `null` o ausencia del hecho | PAR-30, PAR-32, PAR-49 |
| `WITH RECURSIVE ... UNION` | regla recursiva + `:- table` | PAR-33 a PAR-38, PAR-48 |
| `MIN` sobre caminos | `:- table p(_, _, min)` | PAR-38 |
| `INSERT` | `assertz/1` | PAR-39 |
| `UPDATE` | `retract/1` + `assertz/1` | PAR-40, PAR-41 |
| `DELETE` | `retract/1`, `retractall/1` | PAR-42, PAR-43 |
| `PRIMARY KEY`, `REFERENCES` | comprobación con `\+` / objetivo positivo antes de `assertz` | PAR-44, PAR-45 |
