# Bratko: *Prolog Programming for Artificial Intelligence* (4.ª ed.)

- **Fuente:** Ivan Bratko, *Prolog Programming for Artificial Intelligence*, 4.ª edición, Addison-Wesley / Pearson Education, 2012 (ISBN 978-0-321-41746-6).
- **URL del editor:** https://www.pearson.com/en-gb/subject-catalog/p/prolog-programming-for-artificial-intelligence/P200000003804/9780321417466
- **Índice público:** https://www.gbv.de/dms/ilmenau/toc/604026269.PDF (índice escaneado del catálogo GBV)
- **Licencia:** © Pearson Education, todos los derechos reservados.
- **Disponibilidad de los ejercicios:** **no hay listas de ejercicios publicadas legalmente.** El sitio complementario que menciona el libro ya no existe: las URLs `pearsoned.co.uk/bratko` redirigen a una página genérica de Pearson o no responden (verificado en septiembre de 2026). Las copias completas del libro que circulan en Scribd, GitHub y sitios de descarga no son legítimas y no se usaron.
- **Qué contiene este archivo:** siguiendo la consigna, solo los **temas por capítulo**, con el índice como base, y su correspondencia con el programa del curso. No hay enunciados. Cada entrada `BRA-` es un capítulo o una sección, no un ejercicio. Sirve para ubicar ejercicios en un ejemplar del libro (biblioteca).
- **Total:** 23 entradas: 11 de la Parte I (10 capítulos más la sección 3.3) y 12 de la Parte II (capítulos 11 a 25, algunos agrupados).

**Cantidad por tema** (entradas de capítulo o sección, no ejercicios):

| Tema | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | A | X |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Entradas | 1 | 1 | 1 | 3 | 4 | 2 | 2 | 1 | 1 | 1 | 1 | 0 | 1 | 17 |

---

## Parte I: The Prolog Language

### BRA-1 — Introducción a Prolog (cap. 1)
- **Fuente:** Bratko, cap. 1 "Introduction to Prolog", pp. 3–31: 1.1 relaciones con hechos; 1.2 relaciones con reglas; 1.3 reglas recursivas; 1.4 ejecución en un sistema Prolog; 1.5 cómo responde Prolog; 1.6 significado declarativo y procedural; 1.7 el mundo del robot; 1.8 crucigramas, mapas y horarios.
- **Tema:** 0, 1, 2, 5
- **Dificultad:** 1
- **Solución:** no disponible legalmente
- **SWISH:** sí (los ejercicios del capítulo suelen usar la base familiar `parent/2`)
- **Enunciado:** no se reproduce (sin fuente legal). Temas probables de los ejercicios, según el índice y sin cotejar con el libro: consultas y reglas de la familia (`parent`, `mother`, `grandparent`, `sister`, `predecessor`).
- **Notas:** Es el mismo tipo de material que END-1.3 y la sección 1.1 de Simply Logical.

### BRA-2 — Sintaxis y significado de los programas (cap. 2)
- **Fuente:** Bratko, cap. 2 "Syntax and Meaning of Prolog Programs", pp. 32–59: 2.1 objetos de datos; 2.2 unificación (*matching*); 2.3 significado declarativo; 2.4 significado procedural; 2.5 orden de cláusulas y objetivos; 2.6 relación entre Prolog y la lógica.
- **Tema:** 3, 4
- **Dificultad:** 1–2
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce. Temas probables, sin cotejar con el libro: unificación de términos estructurados (puntos, segmentos, triángulos) y el efecto del orden de cláusulas y objetivos sobre la terminación, con el ejemplo del mono y la banana.

### BRA-3 — Listas, operadores y aritmética (cap. 3)
- **Fuente:** Bratko, cap. 3 "Lists, Operators, Arithmetic", pp. 60–85: 3.1 representación de listas; 3.2 operaciones sobre listas; 3.3 notación de operadores; 3.4 aritmética.
- **Tema:** 6, 7, 5
- **Dificultad:** 1–2
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce. Temas probables, sin cotejar con el libro: `conc`, `member`, `del`, `insert`, `sublist`, `permutation`, predicados de longitud par o impar, `reverse`, `op/3` y `is`, y predicados como `max`, `sumlist` y `ordered`.

### BRA-3.3 — Notación de operadores (sección 3.3)
- **Fuente:** Bratko, sección 3.3, pp. 74–79.
- **Tema:** 3, X
- **Dificultad:** 2
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce. El tema es definir operadores con `op/3`, con precedencia y asociatividad. Equivale a END-4.1 a END-4.3.

### BRA-4 — Ejemplos de programación (cap. 4)
- **Fuente:** Bratko, cap. 4 "Programming Examples", pp. 86–125: 4.1 caminos en un grafo; 4.2 planificación de tareas de un robot; 4.3 planificación de viajes; 4.4 criptoaritmética; 4.5 las ocho reinas; 4.6 ontología WordNet.
- **Tema:** 4, 6, X
- **Dificultad:** 2–3
- **Solución:** no disponible legalmente
- **SWISH:** sí (excepto lo de WordNet, que necesita la base de datos)
- **Enunciado:** no se reproduce.
- **Notas:** Las ocho reinas y la criptoaritmética tienen equivalentes libres en POP-23, POP-19 y UNI-CAM-7.3.

### BRA-5 — Control del backtracking (cap. 5)
- **Fuente:** Bratko, cap. 5 "Controlling Backtracking", pp. 126–142: 5.1 evitar el backtracking; 5.2 ejemplos de uso del corte; 5.3 negación por fallo; 5.4 hipótesis de mundo cerrado y problemas del corte y la negación.
- **Tema:** 8, 4
- **Dificultad:** 2
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce. Temas probables, sin cotejar con el libro: el corte verde y el rojo, `max/3`, la clasificación en función de rangos (*step function*) y `\+`.

### BRA-6 — Predicados predefinidos (cap. 6)
- **Fuente:** Bratko, cap. 6 "Built-in Predicates", pp. 143–176: 6.1 tipos de términos; 6.2 construcción y descomposición de términos (`=..`, `functor`, `arg`, `name`); 6.3 igualdad y comparación; 6.4 manipulación de la base de datos; 6.5 control; 6.6 `bagof`, `setof` y `findall`; 6.7 entrada y salida.
- **Tema:** 3, 9, 10
- **Dificultad:** 2
- **Solución:** no disponible legalmente
- **SWISH:** sí en general. La sección 6.7 (E/S con archivos) conviene hacerla en `swipl` local.
- **Enunciado:** no se reproduce.
- **Notas:** Es el capítulo de Bratko que más se acerca a los temas 9 y 10.

### BRA-7 — Programación lógica con restricciones (cap. 7)
- **Fuente:** Bratko, cap. 7 "Constraint Logic Programming", pp. 177–196: CLP(R), CLP(Q) y CLP(FD).
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí (con `clpfd` y `clpqr`)
- **Enunciado:** no se reproduce.

### BRA-8 — Estilo y técnica (cap. 8)
- **Fuente:** Bratko, cap. 8 "Programming Style and Technique", pp. 197–220: principios generales; cómo pensar los programas; estilo; depuración; eficiencia (incluye listas diferencia y acumuladores).
- **Tema:** X
- **Dificultad:** 2–3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.

### BRA-9 — Operaciones sobre estructuras de datos (cap. 9)
- **Fuente:** Bratko, cap. 9 "Operations on Data Structures", pp. 221–245: 9.1 ordenamiento de listas; 9.2 conjuntos como árboles binarios; 9.3 inserción y borrado en un diccionario binario; 9.4 mostrar árboles; 9.5 grafos.
- **Tema:** X
- **Dificultad:** 2–3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.
- **Notas:** La sección 9.1 (burbuja, inserción, quicksort) está al alcance del tema 6. Equivalentes libres: SL-3.19 y UNI-CAM-14.3 a 14.8.

### BRA-10 — Árboles balanceados (cap. 10)
- **Fuente:** Bratko, cap. 10 "Balanced Trees", pp. 246–257: árboles 2-3 y AVL.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.

---

## Parte II: Prolog in Artificial Intelligence (fuera de alcance)

### BRA-11 — Resolución de problemas como búsqueda (cap. 11)
- **Fuente:** Bratko, cap. 11 "Problem-Solving as Search", pp. 261–279: búsqueda en profundidad, profundización iterativa y búsqueda en anchura.
- **Tema:** 4, X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.

### BRA-12 — Búsqueda heurística y A* (cap. 12)
- **Fuente:** Bratko, cap. 12, pp. 280–299.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.

### BRA-13 — Búsqueda primero el mejor con poco tiempo y espacio (cap. 13)
- **Fuente:** Bratko, cap. 13 (IDA*, RBFS, RTA*), pp. 301–317.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.

### BRA-14 — Descomposición de problemas y grafos Y/O (cap. 14)
- **Fuente:** Bratko, cap. 14, pp. 318–342.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.

### BRA-15 — Representación del conocimiento y sistemas expertos (cap. 15)
- **Fuente:** Bratko, cap. 15, pp. 343–368: reglas si-entonces, encadenamiento hacia adelante y hacia atrás, explicaciones, incertidumbre, redes semánticas y marcos.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.
- **Notas:** Equivalente libre: POP-11.

### BRA-16 — Redes bayesianas (cap. 16)
- **Fuente:** Bratko, cap. 16, pp. 370–383.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.

### BRA-17 — Planificación (cap. 17)
- **Fuente:** Bratko, cap. 17, pp. 385–404.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.

### BRA-18 — Planificación de orden parcial y GRAPHPLAN (cap. 18)
- **Fuente:** Bratko, cap. 18, desde p. 406.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.

### BRA-19 — Scheduling, simulación y control con CLP (cap. 19)
- **Fuente:** Bratko, cap. 19 "Scheduling, Simulation and Control with CLP".
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí (con `clpfd` y `clpqr`)
- **Enunciado:** no se reproduce.

### BRA-20 — Aprendizaje automático, ILP y razonamiento cualitativo (caps. 20–22)
- **Fuente:** Bratko, cap. 20 "Machine Learning" (incluye árboles de decisión), cap. 21 "Inductive Logic Programming" (programa HYPER) y cap. 22 "Qualitative Reasoning".
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.

### BRA-21 — Procesamiento de lenguaje con reglas gramaticales (cap. 23)
- **Fuente:** Bratko, cap. 23 "Language Processing with Grammar Rules": 23.1 reglas gramaticales en Prolog (DCG); 23.2 manejo del significado; 23.3 definir el significado del lenguaje natural.
- **Tema:** A
- **Dificultad:** 2–3
- **Solución:** no disponible legalmente
- **SWISH:** sí (SWISH soporta DCG y `phrase/2`)
- **Enunciado:** no se reproduce.
- **Notas:** Es el único capítulo de Bratko sobre DCG. Equivalentes libres: POP-12, POP-13 y SL-7.3.

### BRA-22 — Juegos y metaprogramación (caps. 24–25)
- **Fuente:** Bratko, cap. 24 "Game Playing" (minimax, alfa-beta, *Advice Language*) y cap. 25 "Meta-Programming" (metaintérpretes de Prolog y de CLP).
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no disponible legalmente
- **SWISH:** sí
- **Enunciado:** no se reproduce.
