# El horario de una materia

Esta página continúa el [capítulo 88](index.md) después de la [sección
88.8](servicio.md#888-version-5-el-programa-el-bucle-y-el-servicio), con la
sección [88.9](#889-una-pregunta-mas-el-horario-de-una-materia), la última:
una clase de pregunta nueva, agregada sin modificar los módulos de las
versiones anteriores. La página termina con el cierre del curso. El código
está en `horario.pl`, en `ejemplos/capitulo-88/`, con sus pruebas.

## 88.9 Una pregunta más: el horario de una materia

El [capítulo 74](../capitulo-74-proyecto-horarios-inscripciones/index.md)
construye los horarios de las materias de *Inscripciones*, y su
`oferta.pl` tiene un horario de ejemplo. «¿Cuándo se cursa lógica?» es
una clase de pregunta nueva: no pide alumnos ni materias, sino clases en
la semana. `horario.pl` la agrega sin modificar ninguno de los módulos
anteriores, con el
[Patrón 79](../patrones.md#79-clausulas-para-un-modulo-cargado): los
predicados que una versión nueva extiende están declarados `multifile`
(`pregunta//1` en `gramatica.pl`, `evaluar/2` y `explicar/2` en
`evaluar.pl`, `escribir_respuesta/1` y `escribir_explicacion/1` en
`preguntas.pl`), y `horario.pl` les agrega una cláusula cada uno:

<!-- ejemplo: capitulo-88/horario.pl fragmento: gramatica:pregunta(cuando(Materia)) .. clases_de(Materia, Clases). -->
```prolog
gramatica:pregunta(cuando(Materia)) -->
    palabra("cuando"),
    palabra("se"),
    [Palabra],
    { lemas:analisis(Palabra, verbo(Lema, _, 3, singular)),
      memberchk(Lema, ["cursar", "dictar"]) },
    nombre_propio(materia, Materia).

evaluar:evaluar(cuando(Materia), horario(Clases)) :-
    clases_de(Materia, Clases).
```

<!-- contexto: capitulo-88/horario.pl -->
```prolog
?- preguntar("¿Cuándo se cursa lógica?").
martes, franja 2, aula a2; jueves, franja 2, aula a2
  asignada(log-1, 2, 5, 6)
  asignada(log-2, 2, 13, 14)
true.

?- sql("¿Cuándo se cursa lógica?").
false.
```

La explicación son los hechos del horario: cada clase de lógica, con su
aula y su momento de la semana, que `momento/4` del
[capítulo 74](../capitulo-74-proyecto-horarios-inscripciones/index.md)
convierte en día y franja. La pregunta no tiene sentencia SQL, porque el
horario no es una tabla de la base del
[capítulo 43](../capitulo-43-prolog-y-sql/index.md): `sql/2` falla cuando
un predicado no tiene tabla. Las demás preguntas siguen igual, y las
pruebas de `horario.plt` lo verifican.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; la gramática es `nondet` y `analizar/2` toma la primera lectura con `once/1`; `evaluar/2`, `explicar/2`, `por_que_no/2`, `preguntar/1` y `sql/2` no dejan alternativas |
    | C2 | representaciones limpias: la forma lógica con `cual/2`, `cuantos/2`, `si_no/1`, `todo/3`, `alguno/3`, `y/2` y `no/1`; los árboles con `prueba/2`; los motivos de una falla con `no_alcanza/2`, `sin_nota/1` y `sin_hechos/1` |
    | C3 | los módulos de los capítulos [43](../capitulo-43-prolog-y-sql/index.md), [54](../capitulo-54-proyecto-morfologia-castellano/index.md) y [74](../capitulo-74-proyecto-horarios-inscripciones/index.md) se cargan sin cambios; la pregunta del horario y los ejercicios agregan cláusulas a predicados `multifile` |
    | C5 | una pregunta que no se analiza tiene su respuesta, y una que no tiene traducción a SQL hace fallar a `sql/2`; ninguna da un resultado incorrecto |
    | C6 | el análisis, la evaluación y la traducción son puros; los efectos están en `preguntar/1`, en el bucle y en los manejadores del servidor |
    | C7 | 120 pruebas en doce archivos, 24 más sobre las soluciones, y 4 más con el controlador ODBC; `costos.plt` verifica las inferencias dentro de un 10 %; `consulta_sql.plt` compara la respuesta de SQLite con la de Prolog en cada pregunta del capítulo; el servidor se prueba con las dieciséis preguntas a la vez |

## Cierre del curso

La parte I, del [capítulo 1](../capitulo-01-la-primera-hora/index.md) al
[13](../capitulo-13-prolog-y-la-logica/index.md), presentó el lenguaje:
hechos, reglas y consultas, la unificación, la forma en que Prolog busca
las respuestas, la recursión, las listas, la aritmética, el corte y la
negación como falla, y la relación de todo eso con la lógica. La parte
II, del [capítulo 14](../capitulo-14-el-entorno-de-trabajo/index.md) al
[32](../capitulo-32-ejecutables-y-distribucion/index.md), llevó esos
programas a la práctica profesional: estilo y documentación, pruebas,
todas las soluciones, orden superior, gramáticas, restricciones,
módulos, archivos, servicios y ejecutables, con *Inscripciones* como
proyecto común. La parte III, del
[capítulo 33](../capitulo-33-inspeccion-de-terminos/index.md) al
[43](../capitulo-43-prolog-y-sql/index.md), trató los programas como
datos, las interfaces y los hilos, la semántica y la tabulación, la
búsqueda, los juegos y la relación con SQL. La parte IV, del
[capítulo 44](../capitulo-44-proyecto-resolver-ecuaciones/index.md) a
este, construyó programas completos con todo lo anterior: resolver
ecuaciones, una aventura de texto, un compilador, autómatas, la
morfología y la traducción del castellano, una máquina de Prolog, un
demostrador de teoremas, juegos y búsquedas, un motor Datalog, un
intérprete de SQL en el
[capítulo 87](../capitulo-87-proyecto-mini-sql-prolog/index.md), y este
programa que responde preguntas.

Este último proyecto reúne varias de esas técnicas en un solo programa:
una gramática con argumentos que construyen un término, un analizador
morfológico cargado de otro capítulo, un metaintérprete que explica, una
tabla con subsunción de respuestas, la traducción de un lenguaje a otro,
y el mismo núcleo puro detrás de un bucle, de una página y de un servidor
con hilos. Ninguna de esas piezas es nueva en este capítulo; lo nuevo es
que encajan sin modificarse, porque cada una se escribió como una
relación con sus modos declarados y sus pruebas.

Lo que sigue depende del interés de cada lector. El análisis del lenguaje
natural continúa en los libros de Pereira y Shieber y de Covington, y en
Chat-80, cuyo código está publicado. La programación con restricciones y
con tablas tiene en SWI-Prolog bibliotecas mucho más amplias que lo que el
curso mostró, y las bases de datos deductivas continúan en los sistemas
Datalog actuales. Las [Lecturas complementarias](../lecturas.md#para-profundizar)
reúnen textos para cada uno de esos caminos, y la práctica más útil es la
de siempre: escribir programas, con sus pruebas, para problemas propios.

## Resumen

| | |
|---|---|
| **interfaz en lenguaje natural** | un programa que responde preguntas escritas en castellano sobre una base de datos |
| **forma lógica** | el significado de la pregunta como una fórmula: qué se pide (una lista, una cantidad, sí o no) y la condición, con cuantificadores, conjunción y negación |
| **restricción y alcance** | las dos partes de un cuantificador: los casos de los que se habla y lo que se dice de ellos |
| **sintagma nominal como función** | `(X^P)^F`: recibe la propiedad que el resto de la oración dice de X y devuelve la fórmula (Montague) |
| **tipos de los argumentos** | el tipo del sujeto y del objeto de cada verbo, que descarta las lecturas sin sentido durante el análisis |
| **presuposición** | lo que una pregunta da por cierto: «todos los alumnos que…» supone que hay alguno |
| **respuesta extensional** | la respuesta como la lista de las entidades que la base prueba |
| `palabras/2`, `sin_tildes/2` | las palabras de una pregunta, y una palabra sin tildes |
| `analisis/2`, `nombre_propio//2`, `nombre_de/2` | los lemas, tabulados, y los nombres propios de la base |
| `responder_claves/2`, `datos_clave/4` | la versión 1: palabras clave y plantillas |
| `analizar/2`, `lecturas/2`, `sn//3`, `sv//3` | la versión 2: la gramática |
| `probar/2`, `evaluar/2`, `explicar/2`, `por_que_no/2`, `hojas/2`, `pasos/3`, `cadena/3` | la versión 3: la evaluación y las explicaciones |
| `sql/2`, `sql_atomo/4`, `ejecutar_sql/3`, `responder_sql/3` | la versión 4: la traducción a SQL y su ejecución |
| `responder/3`, `preguntar/1`, `sql/1`, `conversar/0`, `conversar/2` | la versión 5: el programa completo y el bucle |
| `respuesta_json/2`, `cuerpo_pagina/2`, `preguntar_servicio/3`, `muchas_preguntas/3` | el servicio y la página web |
| `clases_de/2` | el horario de una materia, del [capítulo 74](../capitulo-74-proyecto-horarios-inscripciones/index.md) |
| `string_lower/2` | un texto con todas sus letras en minúscula |
| `read_line_to_string/2` | lee una línea de un flujo, sin el salto de línea; `end_of_file` al final |
| `open_string/2` | abre un texto como un flujo de entrada; en las pruebas del bucle |
| `uri_encoded/3` | codifica un texto para ponerlo en una dirección |
| `write_term/2` | escribe un término con opciones; `spacing(next_argument)` pone un espacio después de cada coma de los argumentos |
| **[Patrón 101](../patrones.md#101-tabla-para-lo-que-la-gramatica-prueba-varias-veces)** | tabla para lo que la gramática prueba varias veces |
| **[Patrón 102](../patrones.md#102-construir-la-propiedad-antes-de-aplicarla)** | construir la propiedad antes de aplicarla |
| **[Patrón 103](../patrones.md#103-una-forma-logica-dos-evaluadores)** | una forma lógica, dos evaluadores |

## Temas que se retoman

Es el último capítulo del curso. Los temas que quedan abiertos, y los
caminos para seguir, están en el [Cierre del curso](#cierre-del-curso).

## Referencias

- Fernando C. N. Pereira y Stuart M. Shieber, *Prolog and
  Natural-Language Analysis*, CSLI, 1987; reedición digital de Microtome
  Publishing, 2002. [Edición digital de Microtome](http://www.mtome.com/Publications/PNLA/pnla-digital.html).
  El [cierre del curso](#cierre-del-curso) lo recomienda para
  seguir con el análisis del lenguaje natural.
- David H. D. Warren y Fernando C. N. Pereira, «An Efficient Easily
  Adaptable System for Interpreting Natural Language Queries»,
  *American Journal of Computational Linguistics* 8 (3–4), 1982,
  páginas 110–122. [ACL Anthology](https://aclanthology.org/J82-3002/).
  Describe Chat-80.
  El [cierre del curso](#cierre-del-curso) lo recomienda, con
  su código publicado, para el mismo camino.

El código del capítulo es propio, escrito para el curso: las fuentes dan
el programa `talk` en inglés y para afirmaciones y preguntas, y las
traducciones de Chat-80 y de Dahl sin programas; la gramática castellana
con tipos y concordancia, el analizador del
[capítulo 54](../capitulo-54-proyecto-morfologia-castellano/index.md)
reutilizado, la evaluación con explicaciones, la tabla de las
correlativas, la traducción a SQL y el servicio no tienen equivalente en
ellas.
