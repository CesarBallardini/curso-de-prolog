# Curso de Prolog

Curso de SWI-Prolog en castellano, destinado a estudiantes de segundo año sin
conocimientos previos de Prolog. Está diseñado para el estudio autónomo, de
principio a fin, y **todos los ejemplos se abren y se ejecutan en el
navegador**: cada bloque de código incluye un enlace "▶ Abrir en SWISH".

!!! info "Estado del curso"
    Las **partes I y II (capítulos 1 a 31) están completas**, con sus
    ejercicios, sus soluciones y sus ejemplos verificados. Los capítulos 7 a
    31 están en revisión. Las partes III y IV están en preparación.

## Organización

- **Parte I — Introducción** (capítulos 1 a 12). Para quien no conoce Prolog.
  Abarca hasta el corte, la negación como falla y los árboles de derivación, y
  se desarrolla exclusivamente con hechos, reglas, unificación, recursión y
  listas. El capítulo 1 es un recorrido general de una hora, que permite
  disponer de un programa en funcionamiento desde el comienzo.
- **Parte II — Prolog para programadores** (capítulos 13 a 31). Empieza por el entorno
  de trabajo y sigue con las técnicas de uso profesional cotidiano: estilo,
  control, rendimiento, todas las soluciones, orden superior, operadores y
  reglas como datos, base de datos dinámica, gramáticas, estructuras de
  datos, restricciones, módulos, errores, pruebas, archivos y formatos,
  programas de línea de comandos;
  y, para cerrar, el programa usado desde Python, publicado como servicio web y
  empaquetado como ejecutable. Cada capítulo presenta sus predicados con
  ejemplos breves y después los aplica en un proyecto que crece a lo largo de
  la parte. El Buscaminas, armado por partes en varios capítulos, queda
  completo en el [capítulo 31](capitulo-31-ejecutables-y-distribucion/index.md), con [su código fuente](capitulo-31-ejecutables-y-distribucion/buscaminas.md).
- **Parte III — Lo avanzado** (capítulos 32 a 42). Inspección de términos,
  metaintérpretes, listas diferencia, transformación y compilación de
  programas, interfaces, concurrencia, la semántica de los programas lógicos,
  tabulación, búsqueda y planificación, y juegos. Cierra con Prolog y SQL
  (capítulo 42): las correspondencias entre ambos lenguajes, sus diferencias
  y el uso de una base de datos SQL desde Prolog.
- **Parte IV — Proyectos** (capítulos 43 a 87). Cada capítulo desarrolla un
  programa completo en versiones sucesivas, con las técnicas de las partes
  anteriores: desde resolver ecuaciones, una aventura de texto y un compilador
  hasta sistemas expertos, planificación, juegos, procesamiento del lenguaje y
  un mini-SQL; el último responde preguntas en castellano sobre los datos del
  proyecto *Inscripciones*.
- **[Apéndice B — Los capítulos en PDF](pdf.md)**. Cada capítulo y sus
  soluciones, en PDF, para leer o imprimir.

Cada capítulo tiene la misma estructura: objetivos, desarrollo con ejemplos
ejecutables, actividades intercaladas, ejercicios con nivel de dificultad,
resumen y una tabla de los temas que se retoman en capítulos posteriores. Las
soluciones de los ejercicios están en una página separada de cada capítulo, y
las formas de programa que se repiten están reunidas en la página de
[plantillas](plantillas.md). Las formas del trabajo profesional de la parte
II —cómo se escribe, se prueba y se entrega un programa— están en el
catálogo de [patrones](patrones.md). Las [lecturas complementarias](lecturas.md) reúnen
textos y ejercicios en línea que explican los mismos temas de otra manera.

## Requisitos

Para seguir el curso y resolver los ejercicios no se requiere ninguna instalación:
los ejemplos se ejecutan en SWISH, en el navegador. Para trabajar en una
instalación local se requiere [SWI-Prolog](https://www.swi-prolog.org/) 9;
el curso se verificó con la versión 9.2.9. Los capítulos 29 a 31 usan además
Python 3 y, de manera optativa, Docker.

## Licencia

Este curso se distribuye bajo la licencia MIT: ver [la licencia](licencia.md).
Los libros, cursos y ejercicios de terceros que se citan conservan su propia
licencia; por eso se los enlaza y se los cita, en lugar de reproducirlos.
