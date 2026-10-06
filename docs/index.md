# Curso de Prolog

Curso de SWI-Prolog en castellano, destinado a estudiantes de segundo año sin
conocimientos previos de Prolog. Está diseñado para el estudio autónomo, de
principio a fin. Cada bloque de código proviene de un programa con sus
pruebas; el que se puede ejecutar en SWISH, en el navegador, incluye un enlace
"▶ Abrir en SWISH", y el que requiere una instalación local indica el motivo.

!!! info "Estado del curso"
    El curso está **completo**: ochenta y siete capítulos en cuatro partes,
    con sus ejercicios, sus soluciones y sus ejemplos verificados. El autor
    revisó los capítulos [1](capitulo-01-la-primera-hora/index.md) a
    [7](capitulo-07-listas/index.md); los demás están en revisión.

## Organización

- **Parte I — Introducción** (capítulos [1](capitulo-01-la-primera-hora/index.md)
  a [12](capitulo-12-prolog-y-la-logica/index.md)). Para quien no conoce
  Prolog: hechos, reglas y consultas, términos y unificación, la forma en que
  Prolog busca las respuestas (árboles de derivación, traza y cajas de Byrd),
  recursión, listas, aritmética y acumuladores, el corte, la negación como
  falla, el texto y la relación de Prolog con la lógica. Desde el
  [capítulo 2](capitulo-02-hechos-consultas-y-variables/index.md) cada regla
  lleva su encabezado de documentación (PlDoc), y desde el
  [capítulo 3](capitulo-03-reglas-y-conjunciones/index.md) cada programa tiene
  sus pruebas plunit. El [capítulo 1](capitulo-01-la-primera-hora/index.md) es
  un recorrido general de una hora, que permite disponer de un programa en
  funcionamiento desde el comienzo.
- **Parte II — Prolog para programadores** (capítulos
  [13](capitulo-13-el-entorno-de-trabajo/index.md) a
  [31](capitulo-31-ejecutables-y-distribucion/index.md)). Empieza por el
  entorno de trabajo y sigue con las técnicas de uso profesional cotidiano:
  estilo, control, rendimiento, todas las soluciones, orden superior,
  operadores y reglas como datos, base de datos dinámica, gramáticas,
  estructuras de datos, restricciones, módulos, errores, pruebas, archivos y
  formatos, programas de línea de comandos; y, para cerrar, el programa usado
  desde Python, publicado como servicio web y empaquetado como ejecutable.
  Cada capítulo presenta sus predicados con ejemplos breves y después los
  aplica en *Inscripciones*, un proyecto que crece a lo largo de la parte. El
  Buscaminas, armado por partes en varios capítulos, queda completo en el
  [capítulo 31](capitulo-31-ejecutables-y-distribucion/index.md), con
  [su código fuente](capitulo-31-ejecutables-y-distribucion/buscaminas.md).
- **Parte III — Lo avanzado** (capítulos
  [32](capitulo-32-inspeccion-de-terminos/index.md) a
  [42](capitulo-42-prolog-y-sql/index.md)). Inspección de términos,
  introspección y metaintérpretes, estructuras incompletas y listas
  diferencia, transformación y compilación de programas, interfaces de usuario
  (la terminal, las ventanas de XPCE y las páginas web), concurrencia y
  paralelismo, la semántica de los programas lógicos, tabulación, búsqueda y
  planificación, y juegos. *Inscripciones* y el Buscaminas pasan a esas
  interfaces, a los hilos, a la tabulación y a la búsqueda. La parte cierra
  con Prolog y SQL ([capítulo 42](capitulo-42-prolog-y-sql/index.md)): las
  correspondencias entre ambos lenguajes, sus diferencias y el uso de una base
  de datos SQL desde Prolog.
- **Parte IV — Proyectos** (capítulos
  [43](capitulo-43-proyecto-resolver-ecuaciones/index.md) a
  [87](capitulo-87-proyecto-preguntas-en-castellano/index.md)). Cada capítulo
  desarrolla un programa completo en versiones sucesivas, con las técnicas de
  las partes anteriores, a partir de las fuentes que cita al final. Los
  proyectos abarcan la matemática (ecuaciones, métodos numéricos, aritmética
  racional y matrices, la transformada rápida de Fourier simbólica); los
  circuitos lógicos y su diagnóstico por abducción; los lenguajes y la
  computación (un compilador, autómatas y expresiones regulares, las máquinas
  de Turing, un intérprete funcional); los juegos y el diálogo (una aventura
  de texto, ELIZA, el mundo del Wumpus, Kalah, Mastermind y Nim, consejos para
  el ajedrez); el castellano (su morfología, la traducción al inglés, las
  órdenes en castellano); el análisis y la implementación de programas
  (interpretación abstracta, análisis de programas, una máquina de Prolog, un
  demostrador de teoremas); los sistemas de reglas y el razonamiento (sistemas
  de producción, el algoritmo Rete, razonamiento rebatible, evidencia y
  árboles de decisión); el aprendizaje automático (reglas aprendidas de
  ejemplos, espacios de versiones, un perceptrón); la planificación y la
  búsqueda (planificación por regresión, grafos Y/O, planificación de tareas,
  los horarios de *Inscripciones*); los rompecabezas y las búsquedas (el cubo
  de Rubik, rompecabezas con simetrías, robots y laberintos, el etiquetado de
  Waltz, una colección de problemas); la criptografía, el procesamiento de
  textos y el análisis de registros; y las bases de datos, con un motor
  Datalog y un mini-SQL. El último proyecto responde preguntas en castellano
  sobre los datos de *Inscripciones* y cierra el curso.
- **[Apéndice B — Los capítulos en PDF y las diapositivas](pdf.md)**. Cada
  capítulo y sus soluciones, en PDF, para leer o imprimir, y las diapositivas
  de los capítulos que las tienen.

Cada capítulo tiene la misma estructura: objetivos, desarrollo con ejemplos
ejecutables, actividades intercaladas, ejercicios con nivel de dificultad,
resumen y una tabla de los temas que se retoman en capítulos posteriores; desde
la parte III, cada capítulo termina además con las referencias de sus fuentes,
y el [capítulo 87](capitulo-87-proyecto-preguntas-en-castellano/index.md)
reemplaza esa tabla por el cierre del curso. Las soluciones de los ejercicios
están en una página separada de cada capítulo, y las formas de programa de la
parte I están reunidas en la página de [plantillas](plantillas.md). Las formas
del trabajo profesional y las técnicas de las partes II a IV —cómo se escribe,
se prueba y se entrega un programa, y cómo se resuelven los problemas que
plantean los proyectos— son los 103 recuadros del catálogo de
[patrones](patrones.md). Las [lecturas complementarias](lecturas.md) reúnen
textos y ejercicios en línea que explican los mismos temas de otra manera.

## Requisitos

La parte I y la mayor parte de la II se siguen sin ninguna instalación: sus
ejemplos se ejecutan en SWISH, en el navegador. Desde el
[capítulo 24](capitulo-24-modulos-y-organizacion/index.md), que presenta los
módulos, muchos ejemplos requieren una instalación local, y también la mayor
parte de los de la parte IV.

Para trabajar en una instalación local se requiere
[SWI-Prolog](https://www.swi-prolog.org/) 9; el curso se verificó con la
versión 9.2.9. Algunos capítulos usan además:

- el pack `reif` ([capítulo 15](capitulo-15-control/index.md));
- Python 3 (capítulos [29](capitulo-29-prolog-desde-python/index.md) a
  [31](capitulo-31-ejecutables-y-distribucion/index.md)), con el paquete
  `janus-swi` en el [capítulo 29](capitulo-29-prolog-desde-python/index.md);
- Docker, de manera optativa
  ([capítulo 31](capitulo-31-ejecutables-y-distribucion/index.md));
- XPCE, que acompaña a `swipl-win` en Windows: las ventanas del
  [capítulo 36](capitulo-36-interfaces-de-usuario/index.md) y herramientas
  optativas de los capítulos [16](capitulo-16-rendimiento/index.md) y
  [26](capitulo-26-pruebas-y-depuracion/index.md);
- una terminal que interprete las secuencias ANSI (capítulos
  [36](capitulo-36-interfaces-de-usuario/index.md),
  [41](capitulo-41-juegos/index.md) y
  [44](capitulo-44-proyecto-aventura-de-texto/index.md));
- el controlador ODBC de SQLite (capítulos
  [42](capitulo-42-prolog-y-sql/index.md) y
  [87](capitulo-87-proyecto-preguntas-en-castellano/index.md)), que en Windows
  se instala como indica [El controlador ODBC en
  Windows](capitulo-42-prolog-y-sql/odbc.md#el-controlador-odbc-en-windows);
- un procesador de varios núcleos, para que las mediciones de los capítulos
  [37](capitulo-37-concurrencia-y-paralelismo/index.md) y
  [41](capitulo-41-juegos/index.md) muestren la ganancia del paralelismo.

## Licencia

Este curso se distribuye bajo la licencia MIT: ver [la licencia](licencia.md).
Los libros, cursos y ejercicios de terceros que se citan conservan su propia
licencia; por eso se los enlaza y se los cita, en lugar de reproducirlos.
