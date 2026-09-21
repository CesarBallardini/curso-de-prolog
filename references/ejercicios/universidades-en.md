# Guías de ejercicios de cursos universitarios (en inglés)

Guías de ejercicios de Prolog de cursos universitarios, en inglés y con URL pública. Cada sección corresponde a una institución y trae su propia licencia.

| Prefijo | Institución y curso | URL | Licencia | Soluciones |
|---|---|---|---|---|
| `UNI-CAM` | University of Cambridge, Dept. of Computer Science and Technology. *Prolog* (Part IB), *Supervision Work* 2023–24, Ian Lewis (con aportes de Andrew Rice y Nik Sultana) | https://www.cl.cam.ac.uk/teaching/2324/Prolog/questions-student.pdf (curso: https://www.cl.cam.ac.uk/teaching/2324/Prolog/) | Material de curso sin licencia explícita (© University of Cambridge) | No publicadas (son para supervisiones) |
| `UNI-RWTH` | RWTH Aachen, *Logic Programming* SS 2013, Prof. Jürgen Giesl y Carsten Otto. Hojas 1 a 11 | `https://verify.rwth-aachen.de/lp13/exercises/exerciseN.pdf` (N = 1…11; la 12 da 404). Curso: https://verify.rwth-aachen.de/lp13/ | Material de curso sin licencia explícita | No publicadas |
| `UNI-POR` | Universidade do Porto, DCC-FCUP, *Programação em Lógica* 2016/17, Inês Dutra. *Programming in Prolog: List of Exercises* #2 a #5 | `https://www.dcc.fc.up.pt/~ines/aulas/1617/PL/problemsN.pdf` (N = 2…5; la #1 da 404) | Material de curso sin licencia explícita | No publicadas |
| `UNI-CSUS` | California State University, Sacramento, *Logic Programming: A Courseware*, Vishma Shah, 2015 | https://athena.ecs.csus.edu/~mei/logicp/exercises.html | © 2015 CSUS | Enlace "Solutions" protegido con contraseña |
| `UNI-428` | *CSE 428: Solutions to exercises on Logic Programming and Prolog*, Catuscia Palamidessi (curso CSE 428 de Penn State, primavera 1999; página alojada en LIX, École Polytechnique) | https://www.lix.polytechnique.fr/~catuscia/teaching/cg428/99Spring/exercises/Prolog_solutions.html | Sin licencia explícita | **Sí**, en la misma página |

- **Fuentes buscadas y descartadas:** Edinburgh (*ARPROLOG*, *Prolog Exercise Sheets* 1 a 4 en `inf.ed.ac.uk/teaching/courses/ar/ARPROLOG/exercises/`) devuelve **HTTP 410 Gone** (verificado en septiembre de 2026). Para Imperial, Saarland, KU Leuven y TU Wien no se encontraron guías de Prolog en inglés con URL pública vigente. *Learn Prolog Now!* (Blackburn, Bos y Striegnitz, que se originó en Saarland) y *P-99* no están acá porque son libros o colecciones y no guías de un curso.
- **Enunciados:** parafraseados y condensados en castellano. El texto completo está en la URL de cada fuente.
- **Soluciones verificadas:** las que se incluyen (propias o de CSE 428) se probaron con SWI-Prolog 9.2.9.
- **Total:** 180 entradas (Cambridge 73, RWTH 30, Porto 52, CSUS 13, CSE 428 12). Algunos ejercicios de preguntas encadenadas se agrupan en una sola entrada.

**Cantidad por tema** (un ejercicio puede tener más de un tema):

| Tema | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | A | X |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ejercicios | 1 | 8 | 15 | 23 | 54 | 46 | 70 | 47 | 18 | 8 | 2 | 9 | 2 | 37 |

---

## University of Cambridge: *Prolog Supervision Work* 2023–24 (`UNI-CAM`)

Fuente común: Ian Lewis, *Prolog Supervision Work*, Department of Computer Science and Technology, University of Cambridge, 2023–24. https://www.cl.cam.ac.uk/teaching/2324/Prolog/questions-student.pdf. La guía clasifica cada pregunta como *Bookwork*, *Shallow*, *Deeper* u *Open*, y esa etiqueta se conserva en cada entrada. Varias preguntas remiten a ejemplos de las diapositivas del curso (cebra, bandera holandesa, anagramas, evaluador simbólico, Countdown), que están en https://www.cl.cam.ac.uk/teaching/2324/Prolog/materials.html. La guía pide resolver todo con lo visto en clase, sin `assert`, `findall` ni `retract`.

### UNI-CAM-1.1 — Reglas de unificación
- **Fuente:** Cambridge, Supervisión 1, sección 1 "Prolog Basics", pregunta 1.1 (*Bookwork*). URL de arriba.
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Enunciar las reglas que usa Prolog para unificar dos términos.

### UNI-CAM-1.2 — Unificar a mano dos árboles
- **Fuente:** Cambridge, Supervisión 1, 1.2 (*Shallow*).
- **Tema:** 3
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (para comprobar)
- **Enunciado:** Unificar a mano los dos términos de abajo, explicando qué regla de unificación se aplica en cada paso.
  ```prolog
  tree(tree(tree(1,2),A,B),tree(C,tree(E,F,G)))
  tree(C,tree(Z,C))
  ```
- **Notas:** Ojo: los dos términos tienen aridades distintas en la raíz (`tree/3` y `tree/2`). Detectarlo antes de empezar es parte del ejercicio.

### UNI-CAM-1.3 — `a(A)` con `A` en distintos Prolog
- **Fuente:** Cambridge, Supervisión 1, 1.3 (*Deeper*).
- **Tema:** 3
- **Dificultad:** 2
- **Solución:** no (comparar con END-6.2: SWI crea un término cíclico y `unify_with_occurs_check/2` falla)
- **SWISH:** sí
- **Enunciado:** Describir los distintos comportamientos posibles de una implementación de Prolog al unificar `a(A)` con `A`.

### UNI-CAM-1.4 — Unificación e inferencia de tipos de ML
- **Fuente:** Cambridge, Supervisión 1, 1.4 (*Open*).
- **Tema:** 3, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Relacionar la unificación con la inferencia de tipos de ML y discutir el equivalente en ML de unificar `a(A)` con `A`.
- **Notas:** Presupone conocer ML. Se puede omitir.

### UNI-CAM-2.1 — Acertijo de la cebra, partes 1 y 2
- **Fuente:** Cambridge, Supervisión 1, sección 2 "Zebra Puzzle", 2.1 (*Shallow*). La consulta está en las diapositivas.
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no (en las diapositivas del curso)
- **SWISH:** sí
- **Enunciado:** Implementar y probar las partes 1 y 2 del acertijo de la cebra tal como se presentan en clase: una lista de casas como términos y pistas expresadas con `member/2` y relaciones de vecindad.

### UNI-CAM-2.2 — Cómo se expresa una pista
- **Fuente:** Cambridge, Supervisión 1, 2.2 (*Shallow*).
- **Tema:** 3, 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Explicar cómo quedó expresada la pista 2 en la consulta de la cebra.

### UNI-CAM-2.3 — ¿Qué hace resoluble a este acertijo?
- **Fuente:** Cambridge, Supervisión 1, 2.3 (*Open*).
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Identificar qué características del acertijo permiten resolverlo con este método y proponer otro acertijo que se resuelva igual.

### UNI-CAM-3.1 — Glosario de terminología
- **Fuente:** Cambridge, Supervisión 1, sección 3 "Rules", 3.1 (*Bookwork*).
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Armar un glosario con la terminología de Prolog vista hasta ahora: término, átomo, hecho, regla, consulta, etc.

### UNI-CAM-3.2 — Reglas como fórmulas de primer orden
- **Fuente:** Cambridge, Supervisión 1, 3.2 (*Shallow*).
- **Tema:** 2
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Escribir en lógica de primer orden las reglas del ejemplo de clase y explicar cómo se combinan varias reglas en una sola fórmula.

### UNI-CAM-3.3 — Cebra, parte 3: reescribir con reglas
- **Fuente:** Cambridge, Supervisión 1, 3.3 (*Deeper*).
- **Tema:** 2, 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir el acertijo de la cebra con reglas auxiliares (por ejemplo, "a la derecha de" o "al lado de") y acortarlo lo más posible sin agregar términos a la consulta.

### UNI-CAM-4.1 — Sintaxis de listas
- **Fuente:** Cambridge, Supervisión 1, sección 4 "Lists", 4.1 (*Bookwork*).
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Resumir la sintaxis de listas de Prolog.

### UNI-CAM-4.2 — Árbol de búsqueda de `last/2`
- **Fuente:** Cambridge, Supervisión 1, 4.2 (*Bookwork*).
- **Tema:** 4, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde (con `trace` se puede seguir en SWISH)
- **Enunciado:** Dibujar el árbol de búsqueda de `last([1,2], A)`.

### UNI-CAM-4.3 — Uso y árbol de búsqueda de `append/3`
- **Fuente:** Cambridge, Supervisión 1, 4.3 (*Shallow*).
- **Tema:** 4, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Explicar cómo se usa la definición habitual de `append/3` y dibujar el árbol de búsqueda de un ejemplo representativo.

### UNI-CAM-4.4 — Dos definiciones de `member/2`
- **Fuente:** Cambridge, Supervisión 1, 4.4 (*Deep*).
- **Tema:** 6, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Comparar la definición recursiva de `member/2` con `member(X, Y) :- append(_, [X|_], Y).`: analogía con la aplicación parcial, si conviene reemplazar una por otra, qué ventajas tiene cada una y un argumento informal de que son lógicamente equivalentes.
- **Notas:** La pregunta sobre aplicación parcial presupone programación funcional; el resto es independiente.

### UNI-CAM-4.5 — ¿Qué hace `a/1`?
- **Fuente:** Cambridge, Supervisión 1, 4.5 (*Deeper*).
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** propia, verificada: `a/1` tiene éxito si la lista está ordenada de forma no decreciente.
- **SWISH:** sí
- **Enunciado:** Deducir para qué sirven estas cláusulas:
  ```prolog
  a([]).
  a([H|T]) :- a(T,H).
  a([],_).
  a([H|T],Prev) :- H >= Prev, a(T,H).
  ```

### UNI-CAM-4.6 — ¿Qué hace `b/2`?
- **Fuente:** Cambridge, Supervisión 1, 4.6 (*Deeper*).
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** propia, verificada: ordena la lista intercambiando pares adyacentes desordenados hasta que `a/1` se cumple, al estilo del ordenamiento de burbuja (`b([3,1,2], Y)` da `[1,2,3]`).
- **SWISH:** sí
- **Enunciado:** Explicar qué hace y cómo funciona `b/2`, que usa `a/1` del ejercicio anterior.
  ```prolog
  b(X,X) :- a(X).
  b(X,Y) :- append(A,[H1,H2|B],X), H1 > H2, append(A,[H2,H1|B],X1), b(X1,Y).
  ```
- **Notas:** Al pedir más respuestas con `;` aparece la misma lista varias veces, una por cada orden posible de intercambios. Es un buen punto de partida para el tema 8.

### UNI-CAM-5.1 — `A = 1+2` frente a `A is 1+2`
- **Fuente:** Cambridge, Supervisión 1, sección 5 "Arithmetic", 5.1 (*Bookwork*).
- **Tema:** 3, 7
- **Dificultad:** 1
- **Solución:** no (en `A = 1+2`, A queda ligada al término `1+2`; en `A is 1+2`, A vale `3`)
- **SWISH:** sí
- **Enunciado:** Explicar la diferencia entre `A = 1+2` y `A is 1+2`.

### UNI-CAM-5.2 — Optimización de la última llamada
- **Fuente:** Cambridge, Supervisión 1, 5.2 (*Bookwork*).
- **Tema:** 5
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Explicar qué es la optimización de la última llamada (*Last Call Optimisation*).

### UNI-CAM-5.3 — "Prueba de destrucción" de `len`
- **Fuente:** Cambridge, Supervisión 1, 5.3 (*Bookwork*).
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Aplicar al predicado `len` de clase la "prueba de destrucción" de las diapositivas: llevarlo a entradas grandes hasta agotar la pila, comparando la versión con acumulador y la versión sin él.

### UNI-CAM-5.4 — Aritmética de Peano: `prim`, `plus` y `mult`
- **Fuente:** Cambridge, Supervisión 1, 5.4 (*Deeper*).
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `z` como cero y `s(A)` como sucesor, implementar `prim(A, B)` (número ↔ representación primitiva), `plus/3` y `mult/3` sobre representaciones primitivas, sin hacer la aritmética con `is`.
- **Notas:** Es la misma idea que END-2.10 y POP-02.

### UNI-CAM-5.5 — ¿Se puede invertir `prim`?
- **Fuente:** Cambridge, Supervisión 1, 5.5 (*Shallow*).
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dar una consulta en la que `prim` funcione al revés y otra en la que no.

### UNI-CAM-5.6 — `prim` reversible
- **Fuente:** Cambridge, Supervisión 1, 5.6 (*Shallow*).
- **Tema:** 7, X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir una versión reversible de `prim` con `var/1` e `integer/1`.
- **Notas:** Usa predicados metalógicos. Conviene contrastarlo con la solución pura con `#=` (POP-05).

### UNI-CAM-5.7 — Cinco consultas de igualdad
- **Fuente:** Cambridge, Supervisión 1, 5.7 (*Shallow*).
- **Tema:** 3, 7
- **Dificultad:** 1
- **Solución:** no (en SWI: `1+1 = 2` falla, `1+1 is 2` falla, `1+1 =:= 2` tiene éxito, `One + One = Two` liga `Two = One+One`)
- **SWISH:** sí
- **Enunciado:** Predecir y explicar el resultado de `1 + 1 = 2`, `1 + 1 is 2`, `1 + 1 =:= 2`, `One + One = Two` y de una consulta que combina `prim` con `plus`.

### UNI-CAM-5.8 — Álgebra con `plus` y no con `is`
- **Fuente:** Cambridge, Supervisión 1, 5.8 (*Open*).
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** `3 is A+2` falla, porque `is` no despeja incógnitas. Mostrar con un ejemplo que `prim` y `plus` sí pueden resolver esa ecuación y explicar por qué.

### UNI-CAM-5.9 — Un predicado con y sin optimización de la última llamada
- **Fuente:** Cambridge, Supervisión 1, 5.9 (*Deeper*).
- **Tema:** 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Proponer otro predicado que admita una versión con recursión de cola y otra sin ella, y diseñar una prueba que muestre la diferencia.

### UNI-CAM-6.1 — `len` con acumulador usado "al revés"
- **Fuente:** Cambridge, Supervisión 1, sección 6 "Backtracking", 6.1 (*Shallow*).
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Razonar, antes de probarlo, qué pasa si se usa la versión con acumulador de `len` con la longitud dada y la lista libre.

### UNI-CAM-6.2 — `take` usado "al revés"
- **Fuente:** Cambridge, Supervisión 1, 6.2 (*Shallow*).
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Lo mismo que 6.1, para el predicado `take` de clase.

### UNI-CAM-6.3 — `append` usado "al revés"
- **Fuente:** Cambridge, Supervisión 1, 6.3 (*Shallow*).
- **Tema:** 4, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Lo mismo que 6.1, para `append/3`.

### UNI-CAM-7.1 — Árbol de búsqueda de `perm`
- **Fuente:** Cambridge, Supervisión 1, sección 7 "Generate and Test", 7.1 (*Shallow*).
- **Tema:** 4, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Dibujar el árbol de búsqueda de `perm([1,2], A)`.

### UNI-CAM-7.2 — Bandera holandesa por generar y comprobar
- **Fuente:** Cambridge, Supervisión 1, 7.2 (*Shallow*).
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Completar la solución de clase del problema de la bandera holandesa: ordenar una lista de rojos, blancos y azules generando permutaciones y comprobando el orden.

### UNI-CAM-7.3 — Ocho reinas
- **Fuente:** Cambridge, Supervisión 1, 7.3 (*Deeper*).
- **Tema:** 4, 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Completar la solución de clase del problema de las ocho reinas.

### UNI-CAM-7.4 — N reinas
- **Fuente:** Cambridge, Supervisión 1, 7.4 (*Deeper*).
- **Tema:** 4, 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Generalizar las ocho reinas a N reinas.

### UNI-CAM-7.5 — Generador de anagramas
- **Fuente:** Cambridge, Supervisión 1, 7.5 (*Deeper*).
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (con un diccionario chico de hechos)
- **Enunciado:** Completar el generador de anagramas de clase.

### UNI-CAM-7.6 — Anagramas de dos palabras
- **Fuente:** Cambridge, Supervisión 1, 7.6 (*Deeper*).
- **Tema:** 4, 6
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Extender el generador para encontrar pares de palabras que juntas son anagrama de la original (HOTDOG → HOT + DOG).

### UNI-CAM-7.7 — ¿Cuándo conviene "comprobar y generar"?
- **Fuente:** Cambridge, Supervisión 1, 7.7 (*Open*).
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Discutir en qué situaciones es más eficiente intercalar las comprobaciones antes de generar todo (*test-and-generate*) que generar primero y comprobar después.

### UNI-CAM-8.1 — Orden de las cláusulas del evaluador simbólico
- **Fuente:** Cambridge, Supervisión 2, sección 8 "Symbolic Evaluation", 8.1 (*Deeper*).
- **Tema:** 3, 4, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Explicar qué cambia si se reordenan las cláusulas del evaluador simbólico de expresiones de clase.

### UNI-CAM-9.1 — Qué puntos de elección elimina el corte
- **Fuente:** Cambridge, Supervisión 2, sección 9 "Cut", 9.1 (*Bookwork*).
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Describir qué puntos de elección elimina el operador de corte.

### UNI-CAM-9.2 — Un corte que cambia el significado lógico
- **Fuente:** Cambridge, Supervisión 2, 9.2 (*Shallow*).
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Revisar el ejemplo de clase de un predicado cuyo significado lógico cambia al agregar un corte y crear un ejemplo propio.
- **Notas:** Se relaciona con SL-3.4 (`max/3` con corte rojo).

### UNI-CAM-10.1 — Hipótesis de mundo cerrado
- **Fuente:** Cambridge, Supervisión 2, sección 10 "Negation", 10.1 (*Bookwork*).
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Enunciar la hipótesis de mundo cerrado.

### UNI-CAM-10.2 — Negación y comportamiento no lógico
- **Fuente:** Cambridge, Supervisión 2, 10.2 (*Bookwork*).
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Explicar en general cómo la negación puede hacer que un programa se comporte de forma no lógica.

### UNI-CAM-10.3 — Negaciones anidadas
- **Fuente:** Cambridge, Supervisión 2, 10.3 (*Shallow*).
- **Tema:** 8, 3
- **Dificultad:** 1
- **Solución:** propia, verificada: `X=1` da `X = 1`; `not(X=1)` falla; `not(not(X=1))` tiene éxito **sin ligar** `X`; `not(not(not(X=1)))` falla.
- **SWISH:** sí
- **Enunciado:** Dar y explicar la respuesta de Prolog a las consultas de abajo, indicando el valor de `X` cuando la respuesta es afirmativa.
  ```prolog
  ?- X=1.
  ?- not(X=1).
  ?- not(not(X=1)).
  ?- not(not(not(X=1))).
  ```
- **Notas:** Muestra que la negación nunca liga variables: `\+ \+ G` comprueba G sin conservar sus ligaduras.

### UNI-CAM-11.1–11.3 — Preparar la base de datos de alumnos
- **Fuente:** Cambridge, Supervisión 2, sección 11 "Databases", 11.1, 11.2 y 11.3 (*Bookwork*).
- **Tema:** 1, 11
- **Dificultad:** 1
- **Solución:** no corresponde
- **SWISH:** sí
- **Enunciado:** Sobre las "tablas" `tName(Crsid, Nombre)`, `tCollege(Crsid, College)` y `tGrade(Crsid, Parte, Nota)`, en las que cada hecho es una fila, agregar datos propios, crear una tabla nueva `tDOB` y dejar a algunos alumnos sin college para poder probar las consultas siguientes.
  ```prolog
  tName(acr31,'Andrew Rice').
  tCollege(acr31,'Churchill').
  tGrade(acr31,'IA',2.1).
  ```
- **Notas:** Es la mejor fuente del banco para el tema 11: cada pregunta de las siguientes trae la consulta SQL equivalente.

### UNI-CAM-11.4 — Nombre y college (*join* interno)
- **Fuente:** Cambridge, Supervisión 2, 11.4 (*Bookwork*).
- **Tema:** 2, 11
- **Dificultad:** 1
- **Solución:** propia, verificada: `q(N, C) :- tName(Id, N), tCollege(Id, C).`
- **SWISH:** sí
- **Enunciado:** Escribir una regla que devuelva, por backtracking, el nombre y el college de cada alumno, equivalente a `SELECT name, college FROM tName, tCollege WHERE tName.crsid = tCollege.crsid`.

### UNI-CAM-11.5 — *Join* con parámetro
- **Fuente:** Cambridge, Supervisión 2, 11.5 (*Bookwork*).
- **Tema:** 2, 11
- **Dificultad:** 1
- **Solución:** propia, verificada: `q(Id, N, C) :- tName(Id, N), tCollege(Id, C).`, que se consulta con `Id` instanciado.
- **SWISH:** sí
- **Enunciado:** Igual que 11.4, pero filtrando por un CRSID elegido por el usuario (el `WHERE … = ?` de una sentencia preparada).
- **Notas:** El "parámetro" de SQL es simplemente un argumento instanciado.

### UNI-CAM-11.6 — *Left outer join*
- **Fuente:** Cambridge, Supervisión 2, 11.6 (*Shallow*).
- **Tema:** 8, 11
- **Dificultad:** 2
- **Solución:** propia, verificada:
  ```prolog
  q(N, C) :- tName(Id, N), ( tCollege(Id, C) ; \+ tCollege(Id, _), C = '' ).
  ```
- **SWISH:** sí
- **Enunciado:** Nombre y college, o vacío si el college no se conoce (equivalente a `LEFT OUTER JOIN`).

### UNI-CAM-11.7 — *Full outer join*
- **Fuente:** Cambridge, Supervisión 2, 11.7 (*Shallow*).
- **Tema:** 8, 11
- **Dificultad:** 2
- **Solución:** propia, verificada: la regla de 11.6 más `q('', C) :- tCollege(Id, C), \+ tName(Id, _).`
- **SWISH:** sí
- **Enunciado:** Nombre y college, dejando vacío el que falte de cualquiera de los dos lados (equivalente a `FULL OUTER JOIN`).

### UNI-CAM-11.8 — Mínimo con un único resultado
- **Fuente:** Cambridge, Supervisión 2, 11.8 (*Deeper*).
- **Tema:** 7, 8, 11
- **Dificultad:** 2
- **Solución:** propia, verificada: `q(Id, Min) :- tGrade(Id, _, G), \+ (tGrade(Id, _, G2), G2 < G), !, Min = G.`
- **SWISH:** sí
- **Enunciado:** Obtener la nota numéricamente más baja de un CRSID dado, con una sola respuesta aunque se pidan más (equivalente a `SELECT min(grade) … WHERE crsid = ?`).

### UNI-CAM-11.9 — Contar notas de primera clase
- **Fuente:** Cambridge, Supervisión 2, 11.9 (*Deeper*).
- **Tema:** 5, 11
- **Dificultad:** 2
- **Solución:** propia, verificada con agregación (tema 9): `q(N) :- aggregate_all(count, tGrade(_, _, 1), N).` La guía pide hacerlo sin `findall` ni agregados, es decir, con un acumulador.
- **SWISH:** sí
- **Enunciado:** Contar cuántas notas de primera clase (valor 1) hay en total (equivalente a `SELECT count(grade) … WHERE grade = 1`).

### UNI-CAM-11.10 — Contar por grupo (`GROUP BY`)
- **Fuente:** Cambridge, Supervisión 2, 11.10 (*Deeper*, marcado como *Hard*).
- **Tema:** 5, 9, 11
- **Dificultad:** 3
- **Solución:** propia, verificada con agregación: `q(Id, N) :- setof(I, P^tGrade(I, P, 1), Ids), member(Id, Ids), aggregate_all(count, tGrade(Id, _, 1), N).` La guía sugiere en cambio acumular manualmente una lista de CRSID ya vistos.
- **SWISH:** sí
- **Enunciado:** Devolver por backtracking pares `(CRSID, cantidad de notas de primera clase)` para cada alumno que tenga al menos una (equivalente a `SELECT crsid, count(grade) … WHERE grade = 1 GROUP BY crsid`).

### UNI-CAM-12.1 — Profundización iterativa
- **Fuente:** Cambridge, Supervisión 2, sección 12 "Countdown", 12.1 (*Bookwork*).
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Explicar qué es la profundización iterativa (*iterative deepening*).

### UNI-CAM-12.2 — Elegir N elementos de una lista
- **Fuente:** Cambridge, Supervisión 2, 12.2 (*Deeper*).
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar `choose(N, L, R, S)`: elegir N elementos de L y ponerlos en R, dejando en S los restantes.

### UNI-CAM-12.3 — Countdown con resta y división entera
- **Fuente:** Cambridge, Supervisión 2, 12.3 (*Shallow*).
- **Tema:** 4, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Agregar al evaluador simbólico cláusulas para la resta y la división entera (`//`) y hacer funcionar el juego de números de Countdown.

### UNI-CAM-13.1 — Patrones de búsqueda en grafos
- **Fuente:** Cambridge, Supervisión 2, sección 13 "Graph search", 13.1 (*Bookwork*).
- **Tema:** 4, 5
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Escribir los patrones estándar de búsqueda en grafos: sin ciclos, con ciclos, con registro del camino y con ciclos y registro del camino.

### UNI-CAM-13.2 — Redundancia en la representación de estados
- **Fuente:** Cambridge, Supervisión 2, 13.2 (*Bookwork*).
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Explicar por qué conviene minimizar la redundancia en la representación de los estados.

### UNI-CAM-13.3 — Misioneros y caníbales
- **Fuente:** Cambridge, Supervisión 2, 13.3 (*Shallow*).
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Tres misioneros y tres caníbales deben cruzar un río con un bote para dos personas, sin que los caníbales superen nunca en número a los misioneros en ninguna orilla. Encontrar la secuencia de cruces.

### UNI-CAM-13.4 — Torres de Hanoi como búsqueda
- **Fuente:** Cambridge, Supervisión 2, 13.4 (*Deeper*).
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con tres discos y tres postes, encontrar por búsqueda en grafos la secuencia de movimientos que pasa la torre del primer poste al tercero sin apoyar nunca un disco sobre uno más chico.

### UNI-CAM-13.5 — El paraguas
- **Fuente:** Cambridge, Supervisión 2, 13.5 (*Deeper*).
- **Tema:** 4, 7
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Cuatro personas que tardan 1, 2, 5 y 10 minutos deben llegar a una casa con un solo paraguas que cubre a dos por vez. Encontrar cómo lograrlo en 17 minutos.
- **Notas:** Es el clásico del puente y la linterna. Se busca en el espacio de estados con un costo acumulado.

### UNI-CAM-14.1 — ¿Qué es una lista diferencia?
- **Fuente:** Cambridge, Supervisión 2, sección 14 "Difference lists", 14.1 (*Bookwork*).
- **Tema:** 6, X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Definir las listas diferencia, explicar cómo se escribe la lista diferencia vacía y por qué.

### UNI-CAM-14.2 — Derivar `append` para listas diferencia
- **Fuente:** Cambridge, Supervisión 2, 14.2 (*Bookwork*).
- **Tema:** 6, X
- **Dificultad:** 2
- **Solución:** no (ver SL-3.13)
- **SWISH:** sí
- **Enunciado:** Derivar la cláusula que concatena dos listas diferencia y explicar por qué funciona.

### UNI-CAM-14.3 — Ordenamiento por selección
- **Fuente:** Cambridge, Supervisión 2, 14.3 (*Deeper*).
- **Tema:** 5, 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Ordenar tomando el mínimo de la lista y ordenando recursivamente el resto.

### UNI-CAM-14.4 — Quicksort
- **Fuente:** Cambridge, Supervisión 2, 14.4 (*Deeper*).
- **Tema:** 5, 6, 7
- **Dificultad:** 2
- **Solución:** no (ver SL-3.19 y UNI-428-9)
- **SWISH:** sí
- **Enunciado:** Implementar quicksort.

### UNI-CAM-14.5 — Quicksort con partición en tres
- **Fuente:** Cambridge, Supervisión 2, 14.5 (*Deeper*).
- **Tema:** 5, 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar quicksort partiendo en tres grupos: menores, iguales y mayores que el pivote.

### UNI-CAM-14.6 — ¿Cuándo conviene la partición en tres?
- **Fuente:** Cambridge, Supervisión 2, 14.6 (*Deeper*).
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Discutir en qué situaciones conviene el pivote de tres vías (por ejemplo, con muchas claves repetidas).

### UNI-CAM-14.7 — Quicksort sin `append`
- **Fuente:** Cambridge, Supervisión 2, 14.7 (*Deeper*).
- **Tema:** 6, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Eliminar el `append` de quicksort usando listas diferencia.

### UNI-CAM-14.8 — Mergesort
- **Fuente:** Cambridge, Supervisión 2, 14.8 (*Deeper*).
- **Tema:** 5, 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar el ordenamiento por mezcla (*mergesort*).

### UNI-CAM-14.9 — Hanoi recursivo, con listas y con listas diferencia
- **Fuente:** Cambridge, Supervisión 2, 14.9 (*Deeper*).
- **Tema:** 5, 6, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar el algoritmo recursivo directo de las Torres de Hanoi (sin búsqueda en grafos), primero con listas y después con listas diferencia.

### UNI-CAM-14.10 — Bandera holandesa en una pasada
- **Fuente:** Cambridge, Supervisión 2, 14.10 (*Deeper*).
- **Tema:** 5, 6, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Resolver la bandera holandesa recorriendo la lista una sola vez, juntando tres listas (una por color) y concatenándolas al final. Hacerlo primero con listas y después con listas diferencia.

### UNI-CAM-15.1 — Sudoku: rangos frente a permutaciones
- **Fuente:** Cambridge, Supervisión 2, sección 15 "Sudoku", 15.1 (*Bookwork*).
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Explicar por qué la solución de Sudoku basada en rangos es mucho más lenta que la basada en permutaciones y qué principio general ilustra.

### UNI-CAM-16.1 — Sudoku 9×9 con CLP
- **Fuente:** Cambridge, Supervisión 2, sección 16 "Constraints", 16.1 (*Shallow*).
- **Tema:** X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (con `library(clpfd)`)
- **Enunciado:** Extender el resolvedor CLP de Sudoku de 4×4 visto en clase a uno de 9×9 y probarlo.

### UNI-CAM-16.2 — SEND + MORE = MONEY
- **Fuente:** Cambridge, Supervisión 2, 16.2 (*Shallow*).
- **Tema:** X, 7
- **Dificultad:** 2
- **Solución:** propia, verificada con la formulación de la guía (`Var ins 0..9`, `all_different/1`, `labeling/2`): **25 soluciones** si se permiten ceros a la izquierda.
- **SWISH:** sí
- **Enunciado:** Hacer funcionar la formulación CLP(FD) dada de SEND + MORE = MONEY y contar las soluciones distintas.

### UNI-CAM-16.3 — Sin ceros a la izquierda
- **Fuente:** Cambridge, Supervisión 2, 16.3 (*Deeper*).
- **Tema:** X
- **Dificultad:** 2
- **Solución:** propia, verificada: con `S #\= 0` y `M #\= 0` queda **1 solución**: 9567 + 1085 = 10652.
- **SWISH:** sí
- **Enunciado:** Agregar la restricción de que ningún número empiece con 0 y contar las soluciones que quedan.

### UNI-CAM-16.4 — Criptoaritmética en base arbitraria
- **Fuente:** Cambridge, Supervisión 2, 16.4 (*Deeper*).
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Generalizar el programa a cualquier base y contar las soluciones del acertijo en base 16.

### UNI-CAM-17.1 — Cómo funciona `findall`
- **Fuente:** Cambridge, Supervisión 2, sección 17 "Extra-fun", 17.1 (*Deeper*).
- **Tema:** 9, 10
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí (con otro nombre, porque `findall/3` es predefinido)
- **Enunciado:** Explicar una implementación de `findall/3` con `assertz`, `retract` y un bucle guiado por fallo.
  ```prolog
  findall(T, G, S) :- call(G), assertz(findallsol(T)), fail.
  findall(_, _, S) :- collect(S).
  collect([T|R]) :- retract(findallsol(T)), !, collect(R).
  collect([]).
  ```
- **Notas:** Une los temas 9 y 10. Como ejercicio adicional: la versión simplificada no maneja llamadas anidadas.

---

## RWTH Aachen: *Logic Programming* SS 2013 (`UNI-RWTH`)

Fuente común: Jürgen Giesl y Carsten Otto, *Logic Programming*, RWTH Aachen, semestre de verano 2013. Hoja N en `https://verify.rwth-aachen.de/lp13/exercises/exerciseN.pdf`. El curso es teórico, de nivel avanzado (semántica de punto fijo, resolución, µ-recursión), y usa SWI-Prolog para la parte práctica. Varios ejercicios exigen resolver sin predicados predefinidos.

### UNI-RWTH-1.1 — Directorios: `both`, `contains` y respuestas en orden
- **Fuente:** RWTH, hoja 1, Ejercicio 1 "Simple Prolog". https://verify.rwth-aachen.de/lp13/exercises/exercise1.pdf
- **Tema:** 1, 2, 4, 5
- **Dificultad:** 1
- **Solución:** propia, verificada: `both(D,A,B) :- indir(D,A), indir(D,B).`, `contains(D,X) :- indir(D,X).` y `contains(D,X) :- indir(D,Y), contains(Y,X).` Respuestas: `indir(X,cv)` da `peter` y `rene`; `samedir(tetris,X)` da `cv`, `tetris` y `photo`; `both(X,cv,dissertation)` da `rene`.
- **SWISH:** sí
- **Enunciado:** Con hechos `indir(Dir, Elem)` (qué contiene cada directorio) y la regla `samedir/2`: (a) definir `both(Dir, A, B)`; (b) definir `contains(Dir, X)` a cualquier profundidad, asegurando que termine; (c) listar a mano, en orden, las respuestas de tres consultas.
  ```prolog
  indir(home,peter).  indir(peter,cv).  indir(rene,cv).   % ... más hechos en el PDF
  samedir(X1, X2) :- indir(DIR, X1), indir(DIR, X2).
  ```
- **Notas:** `samedir(tetris, X)` incluye a `tetris` mismo, un detalle que conviene discutir.

### UNI-RWTH-1.2 — De fórmulas a programa: menús con lactosa
- **Fuente:** RWTH, hoja 1, Ejercicio 2 "Syntax".
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dado un conjunto de fórmulas (hechos `part/2`, `ingredient/2` y `lactoseingredient/1`, y dos implicaciones universales), escribir el programa Prolog correspondiente y las consultas "¿qué ingredientes están en ambos menús?" y "¿qué ingredientes con lactosa tiene menu1?".
- **Notas:** Muestra cómo una fórmula ∀ con implicación se traduce en una regla.

### UNI-RWTH-1.3 — Inducción estructural sobre términos
- **Fuente:** RWTH, hoja 1, Ejercicio 3 "Induction".
- **Tema:** 3, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Demostrar por inducción estructural que renombrar variables no cambia el tamaño de un término.

### UNI-RWTH-2.1a — Predicados básicos de listas sin predefinidos
- **Fuente:** RWTH, hoja 2, Ejercicio 1(a) "Programming in Prolog". https://verify.rwth-aachen.de/lp13/exercises/exercise2.pdf
- **Tema:** 5, 6, 8
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar sin predicados predefinidos (salvo `\=`): `contained/2`, `notContained/2`, `app/3`, `removeDuplicates/2`, `union/3` y `remove/3`.
- **Notas:** `notContained/2` se puede escribir sin negación, recorriendo la lista con `\=`.

### UNI-RWTH-2.1b–e — Variables libres y sustituciones sobre fórmulas
- **Fuente:** RWTH, hoja 2, Ejercicio 1(b)–(e).
- **Tema:** 3, 5, 6, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con fórmulas representadas como términos (`forall/2`, `neg/1`, `and/2`, `funcPred(Nombre, Args)`, `variable(V)`), escribir `variables/2` (primero todas las variables, después solo las libres), `notInRange/2` y `substitute/3`, que aplica una sustitución sin capturar variables ligadas.
- **Notas:** Es un ejercicio integrador sobre términos como estructuras de datos. Se relaciona con la parte de lógica de primer orden del curso.

### UNI-RWTH-2.2 — Modelo de Herbrand y forma de Skolem
- **Fuente:** RWTH, hoja 2, Ejercicio 2.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Para una fórmula dada, probar que es satisfacible, buscar un modelo de Herbrand, llevarla a forma normal de Skolem y comparar ambas.

### UNI-RWTH-2.3 — Algoritmo de Gilmore
- **Fuente:** RWTH, hoja 2, Ejercicio 3.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Mostrar con el algoritmo de Gilmore que el programa `plus/3` de Peano implica `plus(s(0), s(0), s(s(0)))`.

### UNI-RWTH-3.1 — Forma normal conjuntiva
- **Fuente:** RWTH, hoja 3, Ejercicio 1. https://verify.rwth-aachen.de/lp13/exercises/exercise3.pdf
- **Tema:** X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Llevar a FNC la fórmula proposicional ¬([(p1 ∨ (p2 → p3)) ∧ ¬(p4 ∨ p5)] ∨ p6).
- **Notas:** Es lógica proposicional pura. Se puede programar con END-4.6.

### UNI-RWTH-3.2 — Multirresolución: ¿correcta y completa?
- **Fuente:** RWTH, hoja 3, Ejercicio 2.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Probar o refutar la corrección y la completitud de una variante de la resolución proposicional que resuelve varios literales a la vez.

### UNI-RWTH-3.3 — Refutación por resolución proposicional
- **Fuente:** RWTH, hoja 3, Ejercicio 3.
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Mostrar por resolución que el conjunto de cláusulas {{p1,¬p2}, {¬p4}, {¬p3,p4}, {¬p1,p4}, {p1,p2,p3}} es insatisfacible (alcanzan cinco pasos).

### UNI-RWTH-3.4 — Algoritmo de unificación paso a paso
- **Fuente:** RWTH, hoja 3, Ejercicio 4.
- **Tema:** 3
- **Dificultad:** 2
- **Solución:** no (se puede comprobar con `unify_with_occurs_check/2`)
- **SWISH:** sí
- **Enunciado:** Aplicar el algoritmo de unificación a cuatro pares de literales, anotando cada sustitución intermedia y el unificador más general, o el tipo de falla (*clash* u *occurs*).
  ```prolog
  p(X, h(Z), f(X,X))   y   p(f(Y,Y), Y, f(Z,Z))
  ```

### UNI-RWTH-4.1 — Resolución en lógica de predicados con `plus`
- **Fuente:** RWTH, hoja 4, Ejercicio 1. https://verify.rwth-aachen.de/lp13/exercises/exercise4.pdf
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Probar por resolución que el programa `plus/3` implica `plus(s(s(0)), s(0), s(s(s(0))))`.

### UNI-RWTH-4.2 — Lema de *lifting*
- **Fuente:** RWTH, hoja 4, Ejercicio 2.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Encontrar (o describir de forma finita) todas las instancias básicas de un paso de resolución dado, según el lema de *lifting*.

### UNI-RWTH-4.3 — Resolución de entrada y resolución SLD
- **Fuente:** RWTH, hoja 4, Ejercicio 3.
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (el inciso c es un programa)
- **Enunciado:** Para cuatro cláusulas sobre `p/2`: derivar la cláusula vacía por resolución de entrada, intentarlo con SLD desde cada cláusula negativa dando la sustitución de respuesta y escribir las cláusulas como programa y consultas.

### UNI-RWTH-4.4 — Semántica procedural de `monus`
- **Fuente:** RWTH, hoja 4, Ejercicio 4.
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Para el programa `monus`/`pred` en notación de sucesor, mostrar un cómputo exitoso de `?- monus(s(s(s(0))), s(0), X).` con su respuesta, y los primeros pasos de un cómputo infinito.

### UNI-RWTH-4.5 — Completitud de la resolución binaria y resolución sin renombrar
- **Fuente:** RWTH, hoja 4, Ejercicio 5.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Probar que la resolución binaria es completa sin variables y que la resolución sin renombrar variables es incompleta.

### UNI-RWTH-5 — Semántica de punto fijo
- **Fuente:** RWTH, hoja 5, Ejercicios 1–3. https://verify.rwth-aachen.de/lp13/exercises/exercise5.pdf
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Monotonía y continuidad de funciones sobre conjuntos, iteraciones del operador `trans_P` para `plus/3`, menor punto fijo y semántica de punto fijo de dos consultas.

### UNI-RWTH-6 — µ-recursión y resta en Prolog
- **Fuente:** RWTH, hoja 6, Ejercicio 1. https://verify.rwth-aachen.de/lp13/exercises/exercise6.pdf
- **Tema:** X, 5
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí (solo el inciso g)
- **Enunciado:** Mostrar que varias funciones son µ-recursivas y cuáles son primitivas recursivas. En el inciso (g), escribir `subtraction(X, Y, Z)` en notación de sucesor, que falla si X < Y.
- **Notas:** Solo el inciso (g) está al alcance del curso.

### UNI-RWTH-7.1 — Árbol SLD de caminos con aristas ε
- **Fuente:** RWTH, hoja 7, Ejercicio 1. https://verify.rwth-aachen.de/lp13/exercises/exercise7.pdf
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Para `path(X, Y, N)` (camino de X a Y con a lo sumo N aristas no-ε, con N en notación de sucesor), dibujar el árbol SLD finito de `?- path(a, a, s(s(0))).` y encontrar un intercambio de dos literales que lo vuelva infinito.
  ```prolog
  path(X, X, Y).
  path(X, Y, s(Z)) :- edge(X, A), path(A, Y, Z).
  path(X, Y, Z) :- eps(X, A), path(A, Y, Z).
  ```

### UNI-RWTH-7.2 — Leer respuestas de un árbol SLD dado
- **Fuente:** RWTH, hoja 7, Ejercicio 2.
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dado el árbol SLD, con una rama infinita, de `?- p(W, Z).` para un programa de cuatro cláusulas, dar las respuestas en el orden en que Prolog las encuentra y explicarlo.

### UNI-RWTH-8.1 — Primalidad sin corte ni negación
- **Fuente:** RWTH, hoja 8, Ejercicio 1. https://verify.rwth-aachen.de/lp13/exercises/exercise8.pdf
- **Tema:** 4, 5, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar `isPrime/1` con la definición directa (ningún m entre 1 y n divide a n), en tres cláusulas, sin `!` ni `\+`, y dibujar el árbol SLD de `?- isPrime(3).`
- **Notas:** Sin negación hay que recorrer los candidatos con un predicado auxiliar que tenga éxito solo si ninguno divide.

### UNI-RWTH-8.2 — Cinco igualdades de Prolog
- **Fuente:** RWTH, hoja 8, Ejercicio 2.
- **Tema:** 3, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Para cada par entre `=`, `==`, `=:=`, `is` y `unify_with_occurs_check`, dar dos términos con los que el primero tenga éxito y el segundo falle o dé error, o explicar por qué no existen.
- **Notas:** Es excelente para fijar las diferencias entre unificación, identidad y comparación aritmética.

### UNI-RWTH-9.1 — Árboles SLD con corte
- **Fuente:** RWTH, hoja 9, Ejercicio 1. https://verify.rwth-aachen.de/lp13/exercises/exercise9.pdf
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Para una versión de `isPrime/1` con `!, fail`, dibujar los árboles SLD de `isPrime(3)` e `isPrime(9)`, marcando las ramas podadas por el corte.

### UNI-RWTH-9.2 — `or`, `nor`, `and` y `nand` n-arios con metavariables
- **Fuente:** RWTH, hoja 9, Ejercicio 2.
- **Tema:** 8, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar `or/1`, `nor/1`, `and/1` y `nand/1`, que reciben una lista de objetivos y se comportan como los conectivos n-arios (por ejemplo, `or([])` es falso y `and([])` es verdadero), sin usar `;` y pudiendo usar `!` y `\+`.
- **Notas:** Llamar objetivos guardados en una lista es la base del orden superior (`call/1`).

### UNI-RWTH-9.3 — Operadores `#` (divide) y `--` (resta acotada)
- **Fuente:** RWTH, hoja 9, Ejercicio 3.
- **Tema:** 7, X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** dudoso (`arithmetic_function/1` puede estar restringido en el *sandbox*; conviene `swipl` local)
- **Enunciado:** (a) Definir el operador infijo `X # Y` ("X divide a Y") con una precedencia tal que `1 + 3 # 2 * 6` sea verdadero. (b) Definir `--` como resta que devuelve 0 en vez de negativos, usable dentro de `is`.

### UNI-RWTH-10.1 — Implementar la unificación con *occurs check*
- **Fuente:** RWTH, hoja 10, Ejercicio 1. https://verify.rwth-aachen.de/lp13/exercises/exercise10.pdf
- **Tema:** 3, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar `unify/2` con la semántica de `unify_with_occurs_check/2` sin usarlo, con `==`, `var/1` y `=..`.

### UNI-RWTH-10.2 — Metaintérprete que muestra las cláusulas usadas
- **Fuente:** RWTH, hoja 10, Ejercicio 2.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí (`clause/2` funciona sobre los predicados del programa)
- **Enunciado:** Extender el metaintérprete `prove/1` para que, por cada solución, imprima en orden las cláusulas instanciadas que la probaron, sin imprimir las que no conducen a ella.

### UNI-RWTH-10.3 — Clausura transitiva leyendo y escribiendo archivos
- **Fuente:** RWTH, hoja 10, Ejercicio 3.
- **Tema:** 9, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no (SWISH no tiene acceso al sistema de archivos)
- **Enunciado:** Escribir `tc(In, Out)`, que lea hechos `edge/2` de un archivo, calcule la clausura transitiva y la escriba en otro archivo.

### UNI-RWTH-11.1 — Árboles abiertos: reemplazar hojas por el mínimo en una pasada
- **Fuente:** RWTH, hoja 11, Ejercicio 1. https://verify.rwth-aachen.de/lp13/exercises/exercise11.pdf
- **Tema:** 3, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con la idea de las listas diferencia, escribir `replaceWithMin/2`, que reemplace todas las hojas de un árbol `t(V, Izq, Der)` por el mínimo del árbol recorriéndolo una sola vez, gracias a una variable que se instancia al final.
- **Notas:** Es el clásico *repmin*.

### UNI-RWTH-11.2 — Gramática de programas Prolog sin `-->`
- **Fuente:** RWTH, hoja 11, Ejercicio 2.
- **Tema:** A
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dada una gramática libre de contexto de "programas" (reglas, átomos, variables), escribir `program/1`, que reconozca listas de símbolos del lenguaje usando listas diferencia a mano, sin `-->` ni concatenación.
- **Notas:** Muestra qué hace la traducción de las DCG por dentro.

---

## Universidade do Porto: *Programming in Prolog, List of Exercises* #2–#5 (`UNI-POR`)

Fuente común: Inês Dutra, DCC-FCUP, Universidade do Porto, 2016/17. Lista N en `https://www.dcc.fc.up.pt/~ines/aulas/1617/PL/problemsN.pdf`. Las listas no traen soluciones.

### UNI-POR-2.1 — Predicados básicos de listas
- **Fuente:** Porto, lista #2, ej. 1. https://www.dcc.fc.up.pt/~ines/aulas/1617/PL/problems2.pdf
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir: último elemento de una lista, elementos consecutivos, borrar una aparición de un elemento y borrar todas sus apariciones.

### UNI-POR-2.2 — Mutaciones de palabras
- **Fuente:** Porto, lista #2, ej. 2.
- **Tema:** 6, 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** A partir de una lista de palabras (nombres de animales en francés), formar palabras nuevas solapando el final de una con el comienzo de otra (VACHE + CHEVAL → VACHEVAL), usando `append/3`.

### UNI-POR-2.3 — Aplanar una lista
- **Fuente:** Porto, lista #2, ej. 3.
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Aplanar una lista cuyos elementos pueden ser listas, a cualquier profundidad.

### UNI-POR-2.4 — Colas
- **Fuente:** Porto, lista #2, ej. 4.
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir predicados para manipular una cola: quitar la cabeza, agregar al final e insertar un elemento.

### UNI-POR-2.5 — Demostrador de lógica proposicional
- **Fuente:** Porto, lista #2, ej. 5.
- **Tema:** 3, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir un demostrador simple de lógica proposicional con equivalencia, implicación, disyunción, conjunción y negación, definiendo operadores (por ejemplo, `op(700, xfy, <=>)`).
- **Notas:** Conecta con la parte de lógica del curso. Ver también END-4.3 a 4.6.

### UNI-POR-2.6 — Romanos a arábigos
- **Fuente:** Porto, lista #2, ej. 6.
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** no (ver END-3.16)
- **SWISH:** sí
- **Enunciado:** Convertir números romanos a arábigos.

### UNI-POR-2.7 — N reinas
- **Fuente:** Porto, lista #2, ej. 7.
- **Tema:** 4, 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Encontrar todas las formas de ubicar N reinas en un tablero de N×N sin que se ataquen.

### UNI-POR-2.8 — Camino más corto: primero el mejor y en anchura
- **Fuente:** Porto, lista #2, ej. 8.
- **Tema:** 4, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** En un mapa de cinco ciudades, encontrar el camino más corto entre dos ciudades con búsqueda primero el mejor y con búsqueda en anchura.

### UNI-POR-2.9 — Oraciones correctas que el programa aprende
- **Fuente:** Porto, lista #2, ej. 9.
- **Tema:** 10, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no del todo (interacción con el usuario)
- **Enunciado:** Decidir si una oración es semánticamente correcta y ampliar el programa para que aprenda (con `assert`) las oraciones que rechazó por error, aceptando preguntas y afirmaciones en el mismo formato.

### UNI-POR-2.10 — Diseño de una unidad arquitectónica
- **Fuente:** Porto, lista #2, ej. 10.
- **Tema:** 4
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Generar el diseño de dos habitaciones rectangulares que cumpla una lista de restricciones (puertas, ventanas, ninguna ventana al norte…) por generar y comprobar.

### UNI-POR-2.11 — Gramática con árbol sintáctico
- **Fuente:** Porto, lista #2, ej. 11.
- **Tema:** A
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir una DCG que analice oraciones como "John ate the cake" y construya su árbol sintáctico.

### UNI-POR-2.12 — Palabras distintas en orden alfabético
- **Fuente:** Porto, lista #2, ej. 12.
- **Tema:** 6, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dado un texto, producir la lista ordenada alfabéticamente de sus palabras distintas.
- **Notas:** Con `sort/2` es inmediato; sin él, es un buen ejercicio de listas.

### UNI-POR-3.1 — Imprimir una lista
- **Fuente:** Porto, lista #3, ej. 1. https://www.dcc.fc.up.pt/~ines/aulas/1617/PL/problems3.pdf
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `print_list/1`, que imprima los elementos de una lista separados por espacios.

### UNI-POR-3.2 — Lista entre dos números
- **Fuente:** Porto, lista #3, ej. 2.
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** no (ver END-3.8)
- **SWISH:** sí
- **Enunciado:** `create_list(5, 12, S)` construye la lista de enteros de 5 a 12.

### UNI-POR-3.3 — Media de una lista
- **Fuente:** Porto, lista #3, ej. 3.
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** no (ver END-3.6)
- **SWISH:** sí
- **Enunciado:** Calcular la media de una lista de números.

### UNI-POR-3.4 — Números dentro de una lista
- **Fuente:** Porto, lista #3, ej. 4.
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Detectar si una lista contiene números y devolverlos.

### UNI-POR-3.5 — Incrementar los enteros
- **Fuente:** Porto, lista #3, ej. 5.
- **Tema:** 6, 7, 8
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Incrementar en 1 cada elemento entero de una lista y dejar el resto igual: `[5,6,a,8,b]` da `[6,7,a,9,b]`.

### UNI-POR-3.6 — Encapsular cada elemento
- **Fuente:** Porto, lista #3, ej. 6.
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Convertir cada elemento de una lista en una lista de un elemento: `[a,b]` da `[[a],[b]]`.

### UNI-POR-3.7 — Intercalar ceros
- **Fuente:** Porto, lista #3, ej. 7.
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Poner un 0 después de cada elemento: `[1,2,3]` da `[1,0,2,0,3,0]`.

### UNI-POR-3.8 — Clonar una lista
- **Fuente:** Porto, lista #3, ej. 8.
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** `clone(L, S)` devuelve una lista con dos copias de L.

### UNI-POR-3.9 — Modificar el n-ésimo elemento
- **Fuente:** Porto, lista #3, ej. 9.
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reemplazar el elemento en la posición N de una lista por un valor dado.

### UNI-POR-3.10 — Matriz aleatoria
- **Fuente:** Porto, lista #3, ej. 10.
- **Tema:** 6, 7, X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Generar una matriz de N×N con enteros aleatorios entre I y J.

### UNI-POR-3.11 — Conjuntos como listas, con y sin repetidos
- **Fuente:** Porto, lista #3, ej. 11.
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** sí, esencialmente la misma consigna está resuelta en UNI-428-3
- **SWISH:** sí (cambiando nombres que chocan con predicados de biblioteca)
- **Enunciado:** Definir `subset`, `disjoint`, `union`, `intersection` y `difference`, en dos versiones: listas con repetidos y listas sin repetidos.

### UNI-POR-3.12 — Longitud de una lista
- **Fuente:** Porto, lista #3, ej. 12.
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** sí (UNI-428-4)
- **SWISH:** sí (con otro nombre, porque `length/2` es predefinido)
- **Enunciado:** Definir `length(L, N)`.

### UNI-POR-3.13 — Suma de una lista
- **Fuente:** Porto, lista #3, ej. 13.
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** sí (UNI-428-7)
- **SWISH:** sí
- **Enunciado:** Definir `sumlist(L, N)` para una lista de enteros.

### UNI-POR-3.14 — Sumas acumuladas
- **Fuente:** Porto, lista #3, ej. 14.
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** sí (UNI-428-8)
- **SWISH:** sí
- **Enunciado:** `add_up_list([1,2,3,4], K)` da `K = [1,3,6,10]`.

### UNI-POR-3.15 — Mezclar listas ordenadas
- **Fuente:** Porto, lista #3, ej. 15.
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** sí (UNI-428-10)
- **SWISH:** sí
- **Enunciado:** Mezclar dos listas ordenadas de enteros en una lista ordenada.

### UNI-POR-3.16 — Árboles binarios: preorden y árbol de búsqueda balanceado
- **Fuente:** Porto, lista #3, ej. 16.
- **Tema:** 3, 5, 6
- **Dificultad:** 2
- **Solución:** sí (UNI-428-11)
- **SWISH:** sí
- **Enunciado:** Con árboles `emptybt` y `consbt(N, T1, T2)`: (a) recorrido en preorden; (b) construir un árbol de búsqueda balanceado a partir de una lista de enteros.

### UNI-POR-4.1 — Camino de costo mínimo
- **Fuente:** Porto, lista #4, ej. 1. https://www.dcc.fc.up.pt/~ines/aulas/1617/PL/problems4.pdf
- **Tema:** 4, 7, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** En un grafo con costos en los arcos (por ejemplo, ciudades y distancias), encontrar un camino de costo mínimo entre dos nodos.

### UNI-POR-4.2 — Altura de un árbol binario
- **Fuente:** Porto, lista #4, ej. 2.
- **Tema:** 3, 5, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `height/2`: el árbol vacío tiene altura 0 y un árbol de un solo elemento, 1.

### UNI-POR-4.3 — ¿Es una lista?
- **Fuente:** Porto, lista #4, ej. 3.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** no (ver SL-1.4)
- **SWISH:** sí
- **Enunciado:** Definir un predicado que reconozca si un término es una lista.

### UNI-POR-4.4 — Tres definiciones de sublista y su eficiencia
- **Fuente:** Porto, lista #4, ej. 4.
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Comparar la eficiencia de tres definiciones de sublista (una recursiva con `prefix/2` y dos con dos llamadas a `conc/3` en distinto orden) y explicar por qué una es ineficiente.
  ```prolog
  sub2(L, S) :- conc(L1, _, L), conc(_, S, L1).
  sub3(L, S) :- conc(_, L2, L), conc(S, _, L2).
  ```

### UNI-POR-4.5 — `reverse` con listas diferencia
- **Fuente:** Porto, lista #4, ej. 5.
- **Tema:** 6, X
- **Dificultad:** 3
- **Solución:** no (ver SL-3.13)
- **SWISH:** sí
- **Enunciado:** Definir `reverse/2` con ambos argumentos representados como listas diferencia.

### UNI-POR-4.6 — Conjunto potencia con `bagof`
- **Fuente:** Porto, lista #4, ej. 6.
- **Tema:** 9, 6
- **Dificultad:** 2
- **Solución:** no (ver END-2.8)
- **SWISH:** sí
- **Enunciado:** Definir `powerset(Set, Subsets)` usando `bagof/3`.

### UNI-POR-4.7 — ¿Es un árbol AVL?
- **Fuente:** Porto, lista #4, ej. 7.
- **Tema:** 3, 5, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con árboles `t(Izq, Raíz, Der)` o `nil`, decidir si en cada nodo las alturas de los subárboles difieren en a lo sumo 1.

### UNI-POR-4.8 — Búsqueda desde varios estados iniciales
- **Fuente:** Porto, lista #4, ej. 8.
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Explicar cómo modificar los programas de búsqueda de clase para partir de varios estados iniciales.

### UNI-POR-5.1 — Prolog frente a un lenguaje imperativo
- **Fuente:** Porto, lista #5, ej. 1. https://www.dcc.fc.up.pt/~ines/aulas/1617/PL/problems5.pdf
- **Tema:** 0
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Enumerar las diferencias principales entre un lenguaje declarativo como Prolog y uno imperativo.

### UNI-POR-5.2 — Pseudocódigo del motor de Prolog
- **Fuente:** Porto, lista #5, ej. 2.
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Escribir en pseudocódigo el algoritmo de ejecución de Prolog.

### UNI-POR-5.3 — Árbol de ejecución de `top/2`
- **Fuente:** Porto, lista #5, ej. 3.
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí (para comprobar las respuestas)
- **Enunciado:** Dibujar el árbol de ejecución de `?- top(X,Y).` para un programa con `p`, `q`, `r` y `s`, indicando la solución de cada rama.

### UNI-POR-5.4 — Poner cortes en distintos lugares
- **Fuente:** Porto, lista #5, ej. 4.
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** En el programa de abajo, insertar `!` en distintos lugares y comentar cómo cambian las respuestas de `?- p(Z).`
  ```prolog
  p(Y) :- q(X,Y), r(Y).
  p(X) :- q(X,X).
  q(a,a). q(a,b). r(b).
  ```

### UNI-POR-5.5 — ¿Qué calcula `c/3`?
- **Fuente:** Porto, lista #5, ej. 5.
- **Tema:** 6, 7, 8
- **Dificultad:** 1
- **Solución:** no (cuenta las apariciones de X en la lista; comparar con END-5.4)
- **SWISH:** sí
- **Enunciado:** Explicar qué implementa un predicado de tres cláusulas con corte sobre listas.

### UNI-POR-5.6 — Implementar la unificación
- **Fuente:** Porto, lista #5, ej. 6.
- **Tema:** 3, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar en Prolog el algoritmo de unificación (ver UNI-RWTH-10.1).

### UNI-POR-5.7 — Código WAM defectuoso
- **Fuente:** Porto, lista #5, ej. 7.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Corregir el código WAM que generó un compilador con errores para un predicado de dos cláusulas y proponer instrucciones de indexación.

### UNI-POR-5.8 — CLP frente a Prolog
- **Fuente:** Porto, lista #5, ej. 8.
- **Tema:** X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Explicar qué distingue a la programación lógica con restricciones de Prolog.

### UNI-POR-5.9 — Falla en Prolog, funciona con CLP
- **Fuente:** Porto, lista #5, ej. 9.
- **Tema:** 7, X
- **Dificultad:** 2
- **Solución:** no (por ejemplo, `X is Y+1, Y = 2` da error de instanciación, mientras que `X #= Y+1, Y = 2` funciona)
- **SWISH:** sí
- **Enunciado:** Escribir un fragmento que falle en Prolog pero funcione con restricciones.

### UNI-POR-5.10 — FOURTY + TEN + TEN = SIXTY
- **Fuente:** Porto, lista #5, ej. 10.
- **Tema:** 4, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Resolver la criptoaritmética FOURTY + TEN + TEN = SIXTY, primero en Prolog puro y después con CLP(FD).

### UNI-POR-5.11 — Búsqueda en profundidad limitada
- **Fuente:** Porto, lista #5, ej. 11.
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar una búsqueda en profundidad con límite de profundidad.

### UNI-POR-5.12 — Movimientos del 8-puzzle
- **Fuente:** Porto, lista #5, ej. 12.
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir un predicado conciso que genere los movimientos posibles del hueco en el 8-puzzle, y una versión en estilo CLP.

### UNI-POR-5.13 — `findall`, `bagof` y `setof`
- **Fuente:** Porto, lista #5, ej. 13.
- **Tema:** 9
- **Dificultad:** 1
- **Solución:** propia, verificada: `findall(X, p(Y,X), L)` da `L = [4,1,2,3]`; `bagof` da una respuesta por cada `Y`: `Y = a, L = [4,1]` y `Y = b, L = [2,3]`; `setof` da `Y = a, L = [1,4]` y `Y = b, L = [2,3]`.
- **SWISH:** sí
- **Enunciado:** Con los hechos de abajo, predecir y explicar el resultado de las tres consultas.
  ```prolog
  p(a,4). p(a,1). p(b,2). p(b,3).
  ?- findall(X,p(Y,X),L).
  ?- bagof(X,p(Y,X),L).
  ?- setof(X,p(Y,X),L).
  ```
- **Notas:** Es el ejercicio más claro del banco sobre las variables libres en `bagof/3`.

### UNI-POR-5.14 — Calculadora interactiva
- **Fuente:** Porto, lista #5, ej. 14.
- **Tema:** 7, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no del todo (SWISH no tiene un bucle de lectura por consola; conviene `swipl` local)
- **Enunciado:** Escribir `calc/0`, que muestre un *prompt*, lea una expresión aritmética terminada en punto, la evalúe, muestre el resultado y repita hasta que el usuario escriba `quit`.

### UNI-POR-5.15 — Reglas con variables que no aparecen en el cuerpo
- **Fuente:** Porto, lista #5, ej. 15.
- **Tema:** 11
- **Dificultad:** 2
- **Solución:** no (`Y` queda sin restricción: la "vista" no es segura, porque su resultado no está acotado por los datos)
- **SWISH:** no corresponde
- **Enunciado:** Explicar por qué, en un contexto de bases de datos, no conviene definir `p(X,Y) :- q(X).`
- **Notas:** Es una pregunta directa sobre la seguridad de las reglas (*range restriction*), tema clásico de Datalog.

### UNI-POR-5.16 — Árboles rojo-negro de YAP
- **Fuente:** Porto, lista #5, ej. 16.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no (requiere la biblioteca de YAP; SWI tiene `library(rbtrees)`)
- **Enunciado:** Medir tiempos de inserción y borrado de muchos números aleatorios en un árbol rojo-negro para varios tamaños y graficar los resultados.

---

## California State University, Sacramento: *Logic Programming Courseware* (`UNI-CSUS`)

Fuente común: Vishma Shah, *Logic Programming: A Courseware*, CSUS, 2015. https://athena.ecs.csus.edu/~mei/logicp/exercises.html. Hay tres bloques: *Prolog Exercises* (P), *Unification & Trees of Resolution* (U) y *Conjunction & Backtracking* (C). El enlace a las soluciones pide contraseña.

### UNI-CSUS-P1 — Leer hechos, reglas y consultas en castellano
- **Fuente:** CSUS, Prolog Exercises (1).
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Escribir en lenguaje natural el significado de seis cláusulas, como `likes(Person, carrots) :- vegetarian(Person).` y `?- pass(Who).`

### UNI-CSUS-P2 — Del castellano a Prolog
- **Fuente:** CSUS, Prolog Exercises (2).
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir en Prolog cuatro enunciados, por ejemplo "a cualquiera le gusta ir de compras si es una chica" y "¿a quién le gusta ir de compras?".

### UNI-CSUS-P3 — Cubo de un número
- **Fuente:** CSUS, Prolog Exercises (3.a) y (3.b).
- **Tema:** 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí (la lectura por teclado del inciso b conviene hacerla en `swipl` local)
- **Enunciado:** Escribir un programa que calcule el cubo de un número y, después, una versión que lea el número desde el *prompt*.

### UNI-CSUS-P4 — Encontrar errores en cláusulas
- **Fuente:** CSUS, Prolog Exercises (4).
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** no (la primera cláusula tiene una conjunción en la cabeza, que no es una cláusula de Horn; la segunda tiene una regla dentro del cuerpo)
- **SWISH:** sí (para ver los errores de sintaxis)
- **Enunciado:** Encontrar el error en `hates(X,Y), hates(Y,X) :- enemies(X,Y)` y en `p(X) :- (q(X) :- r(X)).`

### UNI-CSUS-P5 — Viajeros sanos y ricos
- **Fuente:** CSUS, Prolog Exercises (5).
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir hechos y reglas (alguien es viajero si está sano y es rico; puede viajar si es viajero) y las consultas "¿quién puede viajar?" y "¿quién está sano y es rico?".

### UNI-CSUS-P6 — Predecir respuestas
- **Fuente:** CSUS, Prolog Exercises (6).
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dado un programa de vegetarianos y vegetales, predecir las respuestas de seis consultas, entre ellas `?- vegetarian(_).` y `?- likes(Who, egg_plant).`

### UNI-CSUS-P7 — Una regla simétrica que no termina
- **Fuente:** CSUS, Prolog Exercises (7).
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** propia, verificada: las respuestas se repiten sin fin: `a-b`, `b-c`, `b-a`, `c-b`, `a-b`, …
- **SWISH:** sí (SWISH corta la ejecución)
- **Enunciado:** Predecir qué responde Prolog a `?- p(X,Y).` si se pide `;` una y otra vez.
  ```prolog
  p(a,b). p(b,c).
  p(X,Y) :- p(Y,X).
  ```
- **Notas:** Es el mismo problema que POP-06.

### UNI-CSUS-U1 — ¿Unifican? (1)
- **Fuente:** CSUS, Unification & Trees of Resolution (1)–(4) y (7).
- **Tema:** 3, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Decidir si unifican y por qué: `likes(jax,X)` con `likes(X,jin)`; `food(X,Y,Z)` con `food(M,M,M)`; `food(b,c,d(a))` con `food(X,X,X)`; `[H|T]` con una lista; `[X|Y]` con una lista de términos compuestos.
- **Notas:** Cinco ítems cortos agrupados en una sola entrada.

### UNI-CSUS-U5 — Árboles de deducción por resolución (1)
- **Fuente:** CSUS, Unification & Trees of Resolution (5).
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Dado un conjunto de cláusulas en forma disyuntiva sobre vegetales y gustos, construir el árbol de deducción por resolución de una cláusula objetivo, mostrando cada unificación.

### UNI-CSUS-U6 — Árboles de deducción por resolución (2)
- **Fuente:** CSUS, Unification & Trees of Resolution (6).
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde
- **Enunciado:** Lo mismo, con un conjunto de ocho cláusulas sobre guitarras e instrumentos.

### UNI-CSUS-C1 — Disyunción como hecho
- **Fuente:** CSUS, Conjunction & Backtracking (1) y (2).
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Explicar el significado de `likes(mary,john) ; likes(john,mary).` y reescribir una regla con `;` en el cuerpo como dos cláusulas.

### UNI-CSUS-C3 — Seguir la búsqueda con el orden de objetivos cambiado
- **Fuente:** CSUS, Conjunction & Backtracking (3).
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Seguir la búsqueda de `?- f(X).` para `f(X) :- g(X), t(X), s(X).` con hechos para `g`, `t` y `s`, y repetirlo con los subobjetivos en orden inverso.

### UNI-CSUS-C4 — ¿Quién es feliz?
- **Fuente:** CSUS, Conjunction & Backtracking (4).
- **Tema:** 2, 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Seguir la búsqueda de `?- happy(X).` para `happy(X) :- friend(X,Y), likes(Y,X).` con cuatro hechos.

---

## CSE 428: *Solutions to exercises on Logic Programming and Prolog* (`UNI-428`)

Fuente común: Catuscia Palamidessi, CSE 428 (Penn State, primavera 1999). https://www.lix.polytechnique.fr/~catuscia/teaching/cg428/99Spring/exercises/Prolog_solutions.html. **Todas las entradas tienen solución en la página**, y las que se probaron dan los resultados que ahí se indican. La página usa `not/1` y `redefine_system_predicate/1`; en SWI-Prolog conviene usar `\+` y cambiar los nombres que chocan con predicados de biblioteca.

### UNI-428-1 — Relaciones familiares a partir de `father/2`
- **Fuente:** CSE 428, primer ejercicio.
- **Tema:** 2, 4, 5
- **Dificultad:** 1
- **Solución:** sí, en la página (verificada: `brother` da b-c, c-b, d-e, e-d; `cousin` da d-f, e-f, f-d, f-e; `grandson` da d-a, e-a, f-a; `descendent` da 8 pares, en el orden indicado)
- **SWISH:** sí
- **Enunciado:** A partir de hechos `father/2`, definir `brother/2`, `cousin/2`, `grandson/2` y `descendent/2` (este último, recursivo). Para un árbol de 6 personas, dar las respuestas en orden y dibujar el árbol SLD.

### UNI-428-2 — Invertir una lista: cuadrática y lineal
- **Fuente:** CSE 428, segundo ejercicio.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** sí, en la página (verificada la versión con acumulador)
- **SWISH:** sí
- **Enunciado:** Definir `reverse(L, K)` primero de forma ingenua con `append` y después con recursión de cola.

### UNI-428-3 — Conjuntos como listas, en tres representaciones
- **Fuente:** CSE 428, tercer ejercicio.
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** sí, en la página (verificada `union` sin repetidos: `union([a,b,c],[b,a,d],M)` da `[c,b,a,d]`)
- **SWISH:** sí
- **Enunciado:** Definir `member`, `subset`, `disjoint`, `union`, `intersection` y `difference` para listas con repetidos, sin repetidos y ordenadas de enteros.

### UNI-428-4 — Longitud
- **Fuente:** CSE 428.
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** sí, en la página
- **SWISH:** sí (con otro nombre)
- **Enunciado:** Definir `length(L, N)`.

### UNI-428-5 — Contar apariciones
- **Fuente:** CSE 428.
- **Tema:** 6, 7, 8
- **Dificultad:** 1
- **Solución:** sí, en la página (verificada: `occurrences(a,[a,b,a],N)` da una sola respuesta, `N = 2`, gracias a la negación en la tercera cláusula)
- **SWISH:** sí
- **Enunciado:** Definir `occurrences(X, L, N)`.

### UNI-428-6 — Elemento en la posición N
- **Fuente:** CSE 428.
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** sí, en la página (verificada)
- **SWISH:** sí
- **Enunciado:** Definir `occurs(N, L, X)`: X es el elemento en la posición N de L.
- **Notas:** El enunciado de la página nombra los argumentos como `occurs(L,N,X)`, pero la solución usa el orden `occurs(N,L,X)`.

### UNI-428-7 — Suma de una lista
- **Fuente:** CSE 428.
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** sí, en la página
- **SWISH:** sí (con otro nombre, porque `sumlist/2` existe en SWI)
- **Enunciado:** Definir `sumlist(L, N)`.

### UNI-428-8 — Sumas acumuladas
- **Fuente:** CSE 428.
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** sí, en la página (verificada: `[1,2,3,4]` da `[1,3,6,10]`)
- **SWISH:** sí
- **Enunciado:** Definir `add_up_list(L, K)`, donde cada elemento de K es la suma de los elementos de L hasta esa posición.

### UNI-428-9 — Quicksort
- **Fuente:** CSE 428.
- **Tema:** 5, 6, 7
- **Dificultad:** 2
- **Solución:** sí, en la página (verificada)
- **SWISH:** sí
- **Enunciado:** Definir `quicksort(L, K)` con un predicado auxiliar de partición.

### UNI-428-10 — Mezcla de listas ordenadas
- **Fuente:** CSE 428.
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** sí, en la página
- **SWISH:** sí
- **Enunciado:** Definir `merge(L, K, M)` para dos listas ordenadas de enteros, con y sin repetidos en el resultado.

### UNI-428-11 — Preorden y árbol de búsqueda balanceado
- **Fuente:** CSE 428.
- **Tema:** 3, 5, 6
- **Dificultad:** 2
- **Solución:** sí, en la página (verificada: `search_tree([5,3,1,4,2], T)` construye un árbol balanceado con raíz 3; se probó la primera respuesta)
- **SWISH:** sí
- **Enunciado:** Con árboles `emptybt` y `consbt(N, T1, T2)`, definir `preorder(T, L)` y `search_tree(L, T)`, que construye un árbol de búsqueda balanceado.

### UNI-428-12 — Caminos acíclicos en un grafo
- **Fuente:** CSE 428, último ejercicio.
- **Tema:** 4, 5, 6, 8
- **Dificultad:** 2
- **Solución:** sí, en la página (verificada: `path(a, d, P)` da `[a,b,d]`, `[a,c,d]` y `[a,b,c,d]`)
- **SWISH:** sí
- **Enunciado:** Con arcos `arc/2`, que pueden formar ciclos, definir `path(X, Y)` sin entrar en bucles y después `path(X, Y, P)`, que devuelva cada camino acíclico como lista. Dar las respuestas de `?- path(a, d, P).` con su árbol SLD.
- **Notas:** La lista de nodos visitados con `\+ member` es la técnica estándar contra los ciclos.
