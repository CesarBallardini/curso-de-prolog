# Ejercicios: Sterling & Shapiro, *The Art of Prolog* (2.ª ed.)

- **Fuente:** L. Sterling y E. Shapiro, *The Art of Prolog*, 2.ª ed., MIT Press, 1994. Las páginas indicadas son páginas del PDF (`books/the-art-of-prolog-end-ed1408.pdf`); la numeración impresa del libro es unas 41 páginas menor.
- **Alcance:** todas las listas "Exercises for Section X.Y" de las Partes I y II (caps. 1–13; el cap. 1 no tiene ejercicios) y las de las Partes III–IV (caps. 14–24). Los ejercicios de las Partes III–IV fuera del alcance de un principiante se etiquetan **X** y se listan brevemente. Al final hay programas clásicos del libro que conviene convertir en ejercicios ("adaptado del Programa N.M").
- **Enunciados:** redactados en castellano con palabras propias y condensados; no son traducciones literales. Consultar la página indicada para ver el original.
- **Notación del libro:** usa `←` en lugar de `:-` y termina las consultas con `?` (p. ej. `father(abraham,X)?`); en SWI-Prolog se escribe `?- father(abraham,X).`. Usa `≠` (en SWI: `\=` o `dif/2`), `not G` (en SWI: `\+ G`) y los naturales de Peano `0, s(0), s(s(0))…`.
- **Etiquetas de tema:** 0 Entorno · 1 Hechos, consultas, variables · 2 Reglas y conjunciones · 3 Términos y unificación · 4 Búsqueda, resolución, backtracking · 5 Recursión (incl. Peano) · 6 Listas · 7 Aritmética · 8 Corte y negación · 9 Todas las soluciones y orden superior · 10 Base de datos dinámica · 11 Prolog y SQL / bases de datos · A DCG/gramáticas · X Avanzado/fuera de alcance.

## Conteos

- **Fichas:** 167 en total. 146 salen de las listas de ejercicios del libro. Las otras 21 están adaptadas de programas del libro: AoP-2.4-P, que va dentro del cap. 2, y las 20 fichas `AoP-P-…` de la sección final.
- Las 146 fichas del libro cubren 162 ejercicios. Seis fichas X agrupan varios ejercicios: 17.2 (5), 17.4 (3), 18.x (4), 19.2 (3), cap. 23 (5) y cap. 24 (2). Hay 125 fichas accesibles y 21 fichas X, que suman 37 ejercicios.
- **Fichas con solución verificada** en SWI-Prolog 9.2.9: 31.
- **Fichas por tema.** Una ficha con varias etiquetas cuenta una vez en cada una. La columna "Fichas del libro" incluye AoP-2.4-P.

| Tema | Fichas del libro | Adaptadas (P) |
|---|---|---|
| 0 Entorno | 3 | 0 |
| 1 Hechos, consultas, variables | 3 | 2 |
| 2 Reglas y conjunciones | 8 | 2 |
| 3 Términos y unificación | 29 | 3 |
| 4 Búsqueda, resolución, backtracking | 33 | 5 |
| 5 Recursión (incl. Peano) | 37 | 6 |
| 6 Listas | 52 | 9 |
| 7 Aritmética | 28 | 2 |
| 8 Corte y negación | 9 | 2 |
| 9 Todas las soluciones y orden superior | 3 | 2 |
| 10 Base de datos dinámica | 3 | 0 |
| 11 Prolog y SQL / bases de datos | 8 | 3 |
| A DCG/gramáticas | 5 | 1 |
| X Avanzado/fuera de alcance | 21 | 1 |

- **Tema principal** (primera etiqueta de cada ficha, contando libro y adaptadas): 0: 3 · 1: 5 · 2: 7 · 3: 30 · 4: 32 · 5: 23 · 6: 25 · 7: 1 · 8: 7 · 9: 5 · 10: 1 · A: 6 · X: 22. El tema 11 no aparece como principal porque en el cap. 2 va siempre como segunda etiqueta, pero los 10 ejercicios del cap. 2 y las fichas AoP-2.4-P, AoP-P-2.2, AoP-P-14.10 y AoP-P-16.2 son el material de la unidad 11.
- **Tener en cuenta:** el libro reparte poco material en las unidades 1, 2, 8, 9 y 10. Para esas unidades conviene complementar con otras fuentes. Las unidades 3 a 7 están muy bien cubiertas.

## Capítulo 2: Programación de bases de datos (unidad 11, Prolog y SQL)

> Todo el capítulo 2 es material central para la unidad **11 (Prolog y SQL)**: presenta los hechos como tablas, las reglas como vistas y (§2.4, p. 83–84) traduce las operaciones del álgebra relacional (unión, diferencia, producto cartesiano, proyección, selección, intersección, join natural) a cláusulas Prolog.

### AoP-2.1-1 — Hermana, sobrina y hermanos completos
- **Fuente:** Sterling & Shapiro, §2.1, ej. (i), p. 75
- **Tema:** 2, 11
- **Dificultad:** 1
- **Solución:** sí (verificada en SWI-Prolog 9.2.9 con la base bíblica del cap. 1)
  ```prolog
  sister(Si,S) :- parent(P,Si), parent(P,S), female(Si), Si \= S.
  sibling(A,B) :- parent(P,A), parent(P,B), A \= B.
  niece(N,X)   :- parent(Q,N), sibling(Q,X), female(N).
  full_sibling(A,B) :- father(F,A), father(F,B),
                       mother(M,A), mother(M,B), A \= B.
  ```
- **SWISH:** sí
- **Enunciado:** A partir de la regla de `brother` (p. 62) y de las reglas `uncle` y `sibling` del Programa 2.1 (base familiar bíblica), escribir: (a) una regla para `sister`; (b) una regla para `niece` (sobrina); (c) una versión de `sibling` que solo reconozca hermanos de padre y madre.
- **Notas:** El libro escribe `Sib1 ≠ Sib2`; en SWI-Prolog se usa `\=` (y debe ir al final, con ambos argumentos ya ligados) o `dif/2`. Buen primer ejercicio de conjunciones con variables compartidas.

### AoP-2.1-2 — Relaciones políticas: suegra, cuñado, yerno
- **Fuente:** Sterling & Shapiro, §2.1, ej. (ii), p. 75
- **Tema:** 2, 11
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Usando un predicado `married_couple(Esposa, Esposo)` junto con la base familiar, definir `mother_in_law`, `brother_in_law` y `son_in_law`.
- **Notas:** Obliga a decidir el orden de los argumentos y a considerar ambos lados del matrimonio (cuñado puede ser hermano del cónyuge o cónyuge de la hermana): aparece la disyunción como varias cláusulas.

### AoP-2.1-3 — Naturaleza muerta: izquierda/derecha, arriba/abajo
- **Fuente:** Sterling & Shapiro, §2.1, ej. (iii), p. 75 (Figura 2.3)
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Describir con hechos `left_of/2` y `above/2` la disposición de los objetos de la Figura 2.3 (un dibujo con bicicleta, pez, etc.), y definir `right_of/2` y `below/2` a partir de ellos.
- **Notas:** Hace falta ver la figura (p. 75) o dar al alumno una escena propia. Muestra que una relación inversa es solo intercambiar argumentos.

### AoP-2.2-1 — Consultas sobre cursos: ubicación, ocupado, no pueden reunirse
- **Fuente:** Sterling & Shapiro, §2.2, ej. (i), p. 79
- **Tema:** 2, 3, 11
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Sobre la base de cursos del Programa 2.4 (hechos `course/4` con términos estructurados `time(Día,Inicio,Fin)`, `lecturer(Nombre,Apellido)`, `location(Edificio,Aula)`), agregar reglas `location(Curso,Edificio)`, `busy(Docente,Horario)` y `cannot_meet(Docente1,Docente2)`, y probarlas con cursos propios.
- **Notas:** Muy cercano a SQL: `busy` es una proyección/join; `cannot_meet` requiere comparar franjas horarias. Introduce datos estructurados (unidad 3) como "registros".

### AoP-2.2-2 — Conflicto de horarios
- **Fuente:** Sterling & Shapiro, §2.2, ej. (ii), p. 79
- **Tema:** 2, 7, 11
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `schedule_conflict(Horario, Lugar, Curso1, Curso2)`: dos cursos distintos que se dictan en el mismo lugar con horarios superpuestos (pueden usarse las relaciones del ejercicio anterior).
- **Notas:** La superposición de intervalos necesita comparaciones aritméticas (`<`, `=<`); cuidar de no reportar cada par dos veces ni un curso consigo mismo.

### AoP-2.2-3 — Requisitos de graduación
- **Fuente:** Sterling & Shapiro, §2.2, ej. (iii), p. 79
- **Tema:** 2, 11
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Modelar con hechos las materias cursadas por un estudiante y sus notas, y escribir reglas que verifiquen si cumple los requisitos para recibirse.
- **Notas:** Enunciado abierto; conviene fijar requisitos concretos (p. ej. materias obligatorias aprobadas y cierta cantidad de optativas). Contar optativas lleva a `aggregate_all/3` o `findall/3` (unidad 9); la versión sin conteo cabe en la unidad 11.

### AoP-2.2-4 — Base de datos propia
- **Fuente:** Sterling & Shapiro, §2.2, ej. (iv), p. 79
- **Tema:** 1, 2, 11
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Diseñar una pequeña base de datos para una aplicación elegida por el alumno, con un único predicado para la información, e inventar reglas útiles sobre ella.
- **Notas:** Bueno como trabajo integrador de la unidad 11: pedir además las consultas SQL equivalentes.

### AoP-2.3-1 — Pila de bloques: `above` como clausura transitiva de `on`
- **Fuente:** Sterling & Shapiro, §2.3, ej. (i), p. 82
- **Tema:** 5, 11
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  above(X,Y) :- on(X,Y).
  above(X,Y) :- on(X,Z), above(Z,Y).
  ```
- **SWISH:** sí
- **Enunciado:** Una pila de bloques se describe con hechos `on(B1,B2)` (B1 está apoyado sobre B2). Definir `above(B1,B2)`, verdadero si B1 está en algún lugar por encima de B2.
- **Notas:** Primera regla recursiva, análoga a `ancestor` (Programa 2.5). Equivale a una consulta SQL recursiva (`WITH RECURSIVE`). Advertir que escribir `above(X,Y) :- above(X,Z), on(Z,Y).` primero produce recursión izquierda infinita.

### AoP-2.3-2 — Versiones recursivas de `left_of`/`above` y `higher`
- **Fuente:** Sterling & Shapiro, §2.3, ej. (ii), p. 83
- **Tema:** 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Agregar reglas recursivas a `left_of` y `above` del ejercicio AoP-2.1-3, y definir `higher(O1,O2)`: O1 está en una fila más alta que O2 en la Figura 2.3 (por ejemplo, la bicicleta está más alta que el pez).
- **Notas:** Requiere la figura. Separar hechos básicos de relaciones derivadas (p. ej. `left_of_fact/2` y `left_of/2`) para no generar bucles.

### AoP-2.3-3 — Tamaño del árbol de prueba de `connected`
- **Fuente:** Sterling & Shapiro, §2.3, ej. (iii), p. 83
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (para comprobar con `trace/0`)
- **Enunciado:** Con el grafo del Programa 2.6 (`edge/2`: a→b, a→c, b→d, c→d, d→e, f→g) y la clausura transitiva reflexiva del Programa 2.7 (`connected/2`), contar los nodos del árbol de prueba de `connected(a,e)`. En general, ¿cuántos nodos tiene el árbol de prueba cuando el camino tiene n nodos intermedios?
- **Notas:** Ejercicio teórico (árboles de prueba, cap. 1). El Programa 2.7 es `connected(N,N).` y `connected(N1,N2) :- edge(N1,L), connected(L,N2).`

### AoP-2.4-P — Álgebra relacional en Prolog (adaptado de §2.4)
- **Fuente:** Sterling & Shapiro, §2.4, p. 83–84 (sin ejercicios en el libro; adaptado del texto)
- **Tema:** 2, 8, 11
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dadas dos relaciones de hechos `r/3` y `s/3` y una relación `t/2`, escribir en Prolog la unión, la diferencia, la intersección, el producto cartesiano de `r` con `t`, una proyección, una selección (p. ej. tercer campo mayor que el segundo) y un join natural. Escribir al lado la consulta SQL equivalente.
- **Notas:** El libro da las definiciones generales en §2.4; la diferencia usa `not` (en SWI `\+`), por lo que el ejercicio adelanta la negación por falla (unidad 8), segura aquí porque todo está instanciado.


## Capítulo 3: Programación recursiva

> Nota general para SWI-Prolog: redefinir en un archivo propio `append/3`, `member/2`, `reverse/2`, `select/3`, `plus/3`, etc. funciona (la definición local tapa la de biblioteca), pero **`length/2` es un predicado del sistema y no se puede redefinir** ("No permission to modify static procedure"). Conviene pedir nombres propios (`largo/2`, `my_length/2`). El libro escribe `≤` (Programa 3.2) como predicado infijo; en SWI conviene llamarlo `leq/2`.

### AoP-3.1-1 — `<`, `>` y `≥` sobre naturales de Peano
- **Fuente:** Sterling & Shapiro, §3.1, ej. (i), p. 96
- **Tema:** 5
- **Dificultad:** 1
- **Solución:** sí, para `<` (verificada)
  ```prolog
  lt(0, s(X))    :- natural_number(X).
  lt(s(X), s(Y)) :- lt(X, Y).
  ```
- **SWISH:** sí
- **Enunciado:** Adaptando el Programa 3.2 (`≤` sobre naturales de Peano), axiomatizar `<`, `>` y `≥`. Discutir los distintos usos (qué argumentos pueden quedar sin instanciar).
- **Notas:** `lt(X, s(s(0)))` genera `0` y `s(0)`: una "comparación" también sirve para enumerar.

### AoP-3.1-2 — Corrección y completitud de `≤`
- **Fuente:** Sterling & Shapiro, §3.1, ej. (ii), p. 96
- **Tema:** 5 (teoría)
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no (demostración en papel)
- **Enunciado:** Demostrar que el Programa 3.2 es una axiomatización correcta y completa de `≤` sobre los naturales (su significado coincide con el significado pretendido).
- **Notas:** Ejercicio de lógica, no de programación: inducción en cada dirección, con las definiciones de corrección y completitud del cap. 1.

### AoP-3.1-3 — Tamaño del árbol de prueba de `sⁿ(0) ≤ sᵐ(0)`
- **Fuente:** Sterling & Shapiro, §3.1, ej. (iii), p. 96
- **Tema:** 4, 5 (teoría)
- **Dificultad:** 2
- **Solución:** no (esbozo: n nodos recursivos, un nodo `0 ≤ s^(m-n)(0)` y m−n+1 nodos de `natural_number`, en total m+2)
- **SWISH:** no (papel)
- **Enunciado:** Demostrar que el árbol de prueba de `sⁿ(0) ≤ sᵐ(0)` con el Programa 3.2 tiene m+2 nodos.

### AoP-3.1-4 — Par e impar
- **Fuente:** Sterling & Shapiro, §3.1, ej. (iv), p. 96
- **Tema:** 5
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  even(0).
  even(s(s(X))) :- even(X).
  odd(s(0)).
  odd(s(s(X))) :- odd(X).
  ```
- **SWISH:** sí
- **Enunciado:** Definir `even/1` y `odd/1` sobre naturales de Peano, modificando el Programa 3.1 (`natural_number/1`).
- **Notas:** Variante: recursión mutua (`odd(s(X)) :- even(X).` y viceversa).

### AoP-3.1-5 — Fibonacci en Peano
- **Fuente:** Sterling & Shapiro, §3.1, ej. (v), p. 96
- **Tema:** 5
- **Dificultad:** 1
- **Solución:** sí (verificada: fib(6) = 8)
  ```prolog
  fib(0, 0).
  fib(s(0), s(0)).
  fib(s(s(N)), F) :- fib(s(N), F1), fib(N, F2), plus(F1, F2, F).
  ```
  (`plus/3` es el del Programa 3.3.)
- **SWISH:** sí
- **Enunciado:** Escribir `fib(N,F)`: F es el N-ésimo número de Fibonacci.
- **Notas:** Rehacerlo con `is/2` en el cap. 8 y comparar. La versión doblemente recursiva es exponencial.

### AoP-3.1-6 — Cociente entero por restas sucesivas
- **Fuente:** Sterling & Shapiro, §3.1, ej. (vi), p. 96
- **Tema:** 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** `times/3` (Programa 3.4) solo resuelve divisiones exactas: `times(s(s(0)),X,s(s(s(0))))` (3/2) no tiene solución. Escribir un predicado de cociente entero (3/2 = 1) sobre Peano usando restas repetidas.

### AoP-3.1-7 — MCD por restas
- **Fuente:** Sterling & Shapiro, §3.1, ej. (vii), p. 96
- **Tema:** 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Modificar el Programa 3.10 (MCD de Euclides con `mod`) para que reste el menor del mayor repetidamente hasta que sean iguales, sin usar `mod`.

### AoP-3.1-8 — Naturales como sumas de unos
- **Fuente:** Sterling & Shapiro, §3.1, ej. (viii), p. 96–97
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir los programas del §3.1 representando cada natural como suma de unos (`1`, `1+1`, `1+(1+1)`…), sin el 0. P. ej. `natural_number(1).` y `natural_number(1+X) :- natural_number(X).`
- **Notas:** Muestra que `+` es solo un functor: `1+1 = 2` falla en Prolog. Muy útil para alumnos que vienen de C.

### AoP-3.2-1 — `subsequence` frente a `sublist`
- **Fuente:** Sterling & Shapiro, §3.2, ej. (i), p. 105
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Explicar por qué esta variante tiene un significado distinto del de `sublist` (Programa 3.14):
  ```prolog
  subsequence([X|Xs], [X|Ys]) :- subsequence(Xs, Ys).
  subsequence(Xs, [_|Ys])     :- subsequence(Xs, Ys).
  subsequence([], _).
  ```
- **Notas:** `subsequence` admite elementos no contiguos (`[a,c]` en `[a,b,c]`); `sublist` no.

### AoP-3.2-2 — `adjacent` y `last` recursivos
- **Fuente:** Sterling & Shapiro, §3.2, ej. (ii), p. 106
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  last(X, [X]).
  last(X, [_|Xs]) :- last(X, Xs).
  adjacent(X, Y, [X,Y|_]).
  adjacent(X, Y, [_|Zs]) :- adjacent(X, Y, Zs).
  ```
- **SWISH:** sí
- **Enunciado:** El texto define `adjacent(X,Y,Zs)` y `last(X,Xs)` con `append/3`. Escribir versiones recursivas directas con el mismo significado.

### AoP-3.2-3 — Duplicar cada elemento
- **Fuente:** Sterling & Shapiro, §3.2, ej. (iii), p. 106
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  double([], []).
  double([X|Xs], [X,X|Ys]) :- double(Xs, Ys).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir `double(Lista,ListaDoble)`, donde cada elemento aparece dos veces seguidas; p. ej. `double([1,2,3],[1,1,2,2,3,3])`.
- **Notas:** Probarlo "al revés": `double(X,[a,a,b,b])`.

### AoP-3.2-4 — Tamaño del árbol de prueba de `reverse`
- **Fuente:** Sterling & Shapiro, §3.2, ej. (iv), p. 106
- **Tema:** 4, 6 (teoría)
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (para medir con `time/1`)
- **Enunciado:** Calcular el tamaño del árbol de prueba, en función del largo de la lista, para el `reverse` ingenuo (Programa 3.16a) y el `reverse` con acumulador (Programa 3.16b).
- **Notas:** Cuadrático frente a lineal. `time/1` sobre listas de 100, 200 y 400 elementos lo muestra empíricamente.

### AoP-3.2-5 — Suma de una lista de naturales
- **Fuente:** Sterling & Shapiro, §3.2, ej. (v), p. 106
- **Tema:** 5, 6
- **Dificultad:** 1 (a) / 2 (b)
- **Solución:** sí (verificada)
  ```prolog
  % (a) con plus/3
  sum([], 0).
  sum([X|Xs], S) :- sum(Xs, S0), plus(X, S0, S).
  % (b) sin auxiliares: tres cláusulas
  sum2([], 0).
  sum2([0|Xs], S) :- sum2(Xs, S).
  sum2([s(X)|Xs], s(S)) :- sum2([X|Xs], S).
  ```
- **SWISH:** sí
- **Enunciado:** Definir `sum(ListaDeNaturales,Suma)` (a) con `plus/3`; (b) sin ningún predicado auxiliar.
- **Notas:** Números de Peano; la versión con `is/2` va en el cap. 8.

### AoP-3.3-1 — Sustituir todas las apariciones
- **Fuente:** Sterling & Shapiro, §3.3, ej. (i), p. 112
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  substitute(_, _, [], []).
  substitute(X, Y, [X|Xs], [Y|Ys]) :- substitute(X, Y, Xs, Ys).
  substitute(X, Y, [Z|Xs], [Z|Ys]) :- X \= Z, substitute(X, Y, Xs, Ys).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir `substitute(X,Y,L1,L2)`: L2 es L1 con cada X reemplazada por Y. `substitute(a,x,[a,b,a,c],[x,b,x,c])` es verdadero; `substitute(a,x,[a,b,a,c],[a,b,x,c])`, falso.
- **Notas:** Sin `X \= Z` aparecen respuestas erróneas al pedir más soluciones. Se retoma en AoP-9.2-5 y AoP-11.4-1.

### AoP-3.3-2 — Significado de una variante de `select`
- **Fuente:** Sterling & Shapiro, §3.3, ej. (ii), p. 112
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** ¿Qué relación define esta variante de `select/3`?
  ```prolog
  select(X, [X|Xs], Xs).
  select(X, [Y|Ys], [Y|Zs]) :- X \= Y, select(X, Ys, Zs).
  ```
- **Notas:** Quita solo la primera aparición. El libro escribe `X ≠ Y`. Renombrarlo (`select_first/3`) para no chocar con la biblioteca.

### AoP-3.3-3 — Eliminar duplicados
- **Fuente:** Sterling & Shapiro, §3.3, ej. (iii), p. 112
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `no_doubles(L1,L2)`: L2 es L1 sin repetidos, conservando la última aparición de cada elemento; p. ej. `no_doubles([a,b,c,b],[a,c,b])`. Sugerencia: usar `member/2`.
- **Notas:** "X no aparece en el resto" pide negación (`\+ member(X,Xs)`, cap. 11) o un `nonmember/2` recursivo con `\=`.

### AoP-3.3-4 — Permutaciones pares e impares
- **Fuente:** Sterling & Shapiro, §3.3, ej. (iv), p. 112
- **Tema:** 6
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `even_permutation(Xs,Ys)` y `odd_permutation(Xs,Ys)`; p. ej. `even_permutation([1,2,3],[2,3,1])` y `odd_permutation([1,2,3],[2,1,3])` son verdaderos.

### AoP-3.3-5 — Merge sort
- **Fuente:** Sterling & Shapiro, §3.3, ej. (v), p. 112
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir un programa de ordenamiento por fusión.
- **Notas:** Complementa el quicksort (Programa 3.22) y la inserción (Programa 3.21).

### AoP-3.3-6 — k-ésimo mayor en tiempo lineal
- **Fuente:** Sterling & Shapiro, §3.3, ej. (vi), p. 112
- **Tema:** 6, 7
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar `kthlargest(Xs,K)` con el algoritmo lineal de la mediana de medianas (grupos de cinco, mediana de cada grupo, mediana de medianas recursiva, partición y recursión en la parte adecuada).
- **Notas:** Desafío algorítmico. Versión para principiantes: ordenar y tomar el k-ésimo.

### AoP-3.3-7 — La mejor mano de póker
- **Fuente:** Sterling & Shapiro, §3.3, ej. (vii), p. 113
- **Tema:** 3, 6
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `better_poker_hand(Mano1,Mano2,Mejor)`. Una mano es una lista de cinco `card(Palo,Valor)`; el libro da el orden de valores, la jerarquía de jugadas y el desempate por valor, y sugiere auxiliares como `has_flush/1`, `has_full_house/1`, `has_straight/1` y ordenar la mano primero.
- **Notas:** Proyecto integrador. La jerarquía del libro pone color por debajo de escalera, al revés que el póker usual: aclararlo.

### AoP-3.4-1 — Subárbol
- **Fuente:** Sterling & Shapiro, §3.4, ej. (i), p. 118
- **Tema:** 3, 5
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  subtree(T, T).
  subtree(S, tree(_, L, _)) :- subtree(S, L).
  subtree(S, tree(_, _, R)) :- subtree(S, R).
  ```
- **SWISH:** sí
- **Enunciado:** Con árboles `tree(Elem,Izq,Der)` y `void` como vacío, definir `subtree(S,T)`: S es subárbol de T.

### AoP-3.4-2 — Suma de un árbol
- **Fuente:** Sterling & Shapiro, §3.4, ej. (ii), p. 118
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  sum_tree(void, 0).
  sum_tree(tree(X, L, R), S) :-
      sum_tree(L, SL), sum_tree(R, SR), S is X + SL + SR.
  ```
- **SWISH:** sí
- **Enunciado:** Definir `sum_tree(Arbol,Suma)` para un árbol binario de enteros.
- **Notas:** En ese punto del libro todavía no se vio `is/2`: resolver con Peano o posponer al cap. 8.

### AoP-3.4-3 — Árbol binario de búsqueda ordenado
- **Fuente:** Sterling & Shapiro, §3.4, ej. (iii), p. 118–119
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `ordered(Arbol)`: en cada nodo, el subárbol izquierdo tiene solo elementos menores y el derecho solo mayores. Sugerencia: auxiliares `ordered_left(X,T)` y `ordered_right(X,T)`.

### AoP-3.4-4 — Insertar en un ABB
- **Fuente:** Sterling & Shapiro, §3.4, ej. (iv), p. 119
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  tree_insert(X, void, tree(X, void, void)).
  tree_insert(X, tree(X, L, R), tree(X, L, R)).
  tree_insert(X, tree(Y, L, R), tree(Y, L1, R)) :- X < Y, tree_insert(X, L, L1).
  tree_insert(X, tree(Y, L, R), tree(Y, L, R1)) :- X > Y, tree_insert(X, R, R1).
  ```
- **SWISH:** sí
- **Enunciado:** Definir `tree_insert(X,T,T1)`: T1 es el árbol ordenado que resulta de insertar X en T (si X ya está, T1 = T). Alcanzan cuatro cláusulas.
- **Notas:** Análogo a la inserción en un ABB en C, pero sin punteros: se construye un árbol nuevo.

### AoP-3.4-5 — Camino a un nodo
- **Fuente:** Sterling & Shapiro, §3.4, ej. (v), p. 119
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `path(X,Arbol,Camino)`: Camino es la lista de nodos desde la raíz hasta X.

### AoP-3.5-1 — Suma normalizada
- **Fuente:** Sterling & Shapiro, §3.5, ej. (i), p. 125
- **Tema:** 3, 5
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reconocer si un término suma está normalizado: de la forma `A + B` con A constante y B a su vez normalizada (asociada a la derecha).
- **Notas:** `a+b+c` se lee `(a+b)+c`; `write_canonical/1` lo muestra.

### AoP-3.5-2 — Tipo de las fórmulas booleanas
- **Fuente:** Sterling & Shapiro, §3.5, ej. (ii), p. 125
- **Tema:** 3, 5
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir una definición de tipo (reconocedor recursivo) para fórmulas booleanas.
- **Notas:** Conecta con la lógica proposicional del curso.

### AoP-3.5-3 — ¿Forma normal conjuntiva?
- **Fuente:** Sterling & Shapiro, §3.5, ej. (iii), p. 125
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reconocer si una fórmula está en FNC: conjunción de disyunciones de literales (átomo o su negación).

### AoP-3.5-4 — Negaciones hacia adentro
- **Fuente:** Sterling & Shapiro, §3.5, ej. (iv), p. 125
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `negation_inwards(F1,F2)`: F2 resulta de empujar todas las negaciones de F1 hacia adentro de conjunciones y disyunciones.
- **Notas:** De Morgan y doble negación.

### AoP-3.5-5 — Pasaje a FNC
- **Fuente:** Sterling & Shapiro, §3.5, ej. (v), p. 125
- **Tema:** 3, 5
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Convertir cualquier fórmula lógica a forma normal conjuntiva.
- **Notas:** Encadena AoP-3.5-4 con la distributividad. Muy buen puente entre teoría y programación.

### AoP-3.5-6 — Multiconjuntos (bags)
- **Fuente:** Sterling & Shapiro, §3.5, ej. (vi), p. 125
- **Tema:** 3, 5, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con la representación `bag(Elem,Multiplicidad,Resto)` y `void` (p. ej. `bag(a,3,bag(b,2,void))`), escribir: (a) unión, (b) intersección, (c) sustitución de un elemento, (d) conversión de lista a bag, (e) conversión de árbol binario a bag.
- **Notas:** Se puede dividir en cinco ejercicios cortos.

## Capítulo 4: El modelo de cómputo de los programas lógicos

### AoP-4.1-1 — Unificador más general para `append`
- **Fuente:** Sterling & Shapiro, §4.1, ej. (i), p. 132
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** sí (verificada con `=/2`): `{X = b, Xs = [], Ys = [c,d], L = [b|Zs]}`
- **SWISH:** sí (para comprobar con `T1 = T2`)
- **Enunciado:** Aplicando a mano el algoritmo de unificación de la Figura 4.1 (pila de ecuaciones), calcular el unificador más general de `append([b],[c,d],L)` y `append([X|Xs],Ys,[X|Zs])`.
- **Notas:** Primero en papel y después comprobar en SWI-Prolog. Ejercicio clave para entender el "pasaje de parámetros" por unificación.

### AoP-4.1-2 — Unificador más general para `hanoi`
- **Fuente:** Sterling & Shapiro, §4.1, ej. (ii), p. 132
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** sí (verificada): `{N = s(0), A = a, B = b, C = c, Ms = Xs}`
- **SWISH:** sí
- **Enunciado:** Con el mismo algoritmo, calcular el unificador más general de `hanoi(s(N),A,B,C,Ms)` y `hanoi(s(s(0)),a,b,c,Xs)`.
- **Notas:** Muestra la unificación de dos variables entre sí (`Ms = Xs`).

### AoP-4.2-1 — Trazar tres algoritmos de ordenamiento
- **Fuente:** Sterling & Shapiro, §4.2, ej. (i), p. 139
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (`trace/0` o el depurador gráfico)
- **Enunciado:** Trazar la consulta `sort([3,1,2],Xs)` con el ordenamiento por permutaciones (Programa 3.20), por inserción (Programa 3.21) y el quicksort (Programa 3.22), uno por vez.
- **Notas:** Renombrar `sort/2` (es predicado del sistema en SWI) a, p. ej., `psort/2`, `isort/2`, `qsort/2`. Hacer primero la traza a mano con la notación del libro y después compararla con `trace`.

### AoP-4.2-2 — Traza de una derivada simbólica
- **Fuente:** Sterling & Shapiro, §4.2, ej. (ii), p. 139
- **Tema:** 3, 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dar la traza de `derivative(3*sin(x)-4*cos(x),x,D)` con el Programa 3.30 (derivación simbólica).
- **Notas:** Requiere cargar el Programa 3.30 (p. 121). En SWI, `^` y `*` son functores normales: la derivada queda sin simplificar.

### AoP-4.2-3 — Practicar trazas
- **Fuente:** Sterling & Shapiro, §4.2, ej. (iii), p. 139
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Trazar a gusto otras computaciones conocidas.
- **Notas:** Ejercicio abierto; conviene fijar una lista (p. ej. `append(X,Y,[a,b])` pidiendo todas las soluciones).

## Capítulo 5: Teoría de los programas lógicos

### AoP-5.2-1 — Dominio de terminación de `plus`
- **Fuente:** Sterling & Shapiro, §5.2, ej. (i), p. 149
- **Tema:** 4, 5 (teoría)
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (para experimentar)
- **Enunciado:** Dar un dominio (conjunto de consultas) sobre el cual el Programa 3.3 (`plus/3` en Peano) termina.
- **Notas:** P. ej., las consultas cuyo primer o tercer argumento es un natural completo. Contrastar con `plus(X,Y,Z)` todo libre (infinitas respuestas).

### AoP-5.2-2 — Árboles completos e incompletos
- **Fuente:** Sterling & Shapiro, §5.2, ej. (ii), p. 149
- **Tema:** 3, 5 (teoría)
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no (definición en papel)
- **Enunciado:** Por analogía con las definiciones de listas completas e incompletas del §5.2, definir árboles binarios completos e incompletos.

### AoP-5.3-1 — Complejidad lineal de `append`
- **Fuente:** Sterling & Shapiro, §5.3, ej. (i), p. 150–151
- **Tema:** 4, 6 (teoría)
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no (papel)
- **Enunciado:** Mostrar que un objetivo de `append` que une una lista de largo n con otra de largo m tiene tamaño 4n + 4m + 4 (tamaño = cantidad de símbolos), que su árbol de prueba tiene m+1 nodos (así lo dice el libro) y que, por lo tanto, `append` tiene complejidad lineal. ¿Cambiaría la complejidad si se agregara la condición de tipo (verificar que el segundo argumento es una lista)?
- **Notas:** Posible errata: la recursión recorre la primera lista (largo n), así que el árbol tiene n+1 nodos. Puede proponerse a los alumnos detectarla.

### AoP-5.3-2 — Complejidad lineal de `plus`
- **Fuente:** Sterling & Shapiro, §5.3, ej. (ii), p. 151
- **Tema:** 5 (teoría)
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no (papel)
- **Enunciado:** Mostrar que el Programa 3.3 para `plus` tiene complejidad (de longitud de prueba) lineal.

### AoP-5.3-3 — Complejidad de otros programas
- **Fuente:** Sterling & Shapiro, §5.3, ej. (iii), p. 151
- **Tema:** 4 (teoría)
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no
- **Enunciado:** Discutir la complejidad de otros programas lógicos (p. ej. `times`, los dos `reverse`, los ordenamientos del cap. 3).

### AoP-5.4-1 — De trazas a árboles de búsqueda
- **Fuente:** Sterling & Shapiro, §5.4, ej. (i), p. 153
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no (dibujo en papel; SWISH puede ayudar con el tracer)
- **Enunciado:** Convertir en árboles de búsqueda las trazas de las Figuras 4.3 (`append`) y 4.5 (`hanoi`).
- **Notas:** Excelente para fijar el modelo de backtracking: nodos de éxito, de falla y el orden de exploración en profundidad.

### AoP-5.4-2 — Árbol de búsqueda del ordenamiento por permutaciones
- **Fuente:** Sterling & Shapiro, §5.4, ej. (ii), p. 153
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no (papel)
- **Enunciado:** Dibujar el árbol de búsqueda de `sort([2,4,1],Xs)` con el ordenamiento por permutaciones (Programa 3.20).
- **Notas:** Muestra por qué "generar y probar" es costoso: muchas ramas de falla antes del éxito.

## Capítulo 6: Prolog puro

### AoP-6.1-1 — Trazar `daughter(X,haran)`
- **Fuente:** Sterling & Shapiro, §6.1, ej. (i), p. 165
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Trazar la ejecución de `daughter(X,haran)` con el Programa 1.2 (base familiar bíblica con reglas `daughter`/`son`).
- **Notas:** Primer contacto con el tracer: puertos call/exit/redo/fail.

### AoP-6.1-2 — Trazar el ordenamiento por inserción
- **Fuente:** Sterling & Shapiro, §6.1, ej. (ii), p. 165
- **Tema:** 4, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Trazar la ejecución de `sort([3,1,2],Xs)` con el Programa 3.21 (inserción), siguiendo la estrategia real de Prolog.
- **Notas:** Renombrar `sort/2` (predicado del sistema en SWI).

### AoP-6.1-3 — Trazar el ordenamiento por permutaciones
- **Fuente:** Sterling & Shapiro, §6.1, ej. (iii), p. 165
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Trazar la ejecución de `sort([3,1,2],Xs)` con el Programa 3.20 (permutaciones), marcando cada retroceso.
- **Notas:** Distinguir retroceso superficial y profundo (definidos en la p. 165).

## Capítulo 7: Programación en Prolog puro

### AoP-7.1-1 — Orden de las soluciones de `ancestor(abraham,X)`
- **Fuente:** Sterling & Shapiro, §7.1, ej. (i), p. 172
- **Tema:** 4, 5
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Comprobar el orden en que aparecen las soluciones de `ancestor(abraham,X)` con el Programa 7.1 y con la variante que intercambia el orden de las reglas de `ancestor`, tal como se afirma en el texto.
- **Notas:** El orden de las cláusulas cambia el orden del recorrido, no el árbol de búsqueda. Buen ejercicio para empezar a predecir la salida.

### AoP-7.1-2 — Orden de las soluciones de `ancestor(X,benjamin)`
- **Fuente:** Sterling & Shapiro, §7.1, ej. (ii), p. 172
- **Tema:** 4, 5
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** ¿En qué orden salen las soluciones de `ancestor(X,benjamin)` con el Programa 7.1? ¿Y si se intercambian las reglas?

### AoP-7.2-1 — Terminación de `prefix` y `suffix`
- **Fuente:** Sterling & Shapiro, §7.2, ej. (i), p. 174
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Analizar para qué patrones de instanciación terminan los dos programas del Programa 3.13 (`prefix/2` y `suffix/2`).
- **Notas:** Usar la idea de lista completa/incompleta del §5.2. Probar `prefix(X,[a,b])`, `prefix([a],Y)`, `suffix(X,Y)`.

### AoP-7.2-2 — Terminación de `sublist`
- **Fuente:** Sterling & Shapiro, §7.2, ej. (ii), p. 174
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Analizar la terminación del Programa 3.14c para `sublist/2`.
- **Notas:** El Programa 3.14 tiene varias versiones (a–e) con `prefix`, `suffix` y `append`; ver p. 101 para identificar la versión c.

### AoP-7.3-1 — Orden de objetivos en `sublist` con `append`
- **Fuente:** Sterling & Shapiro, §7.3, ej. (i), p. 177
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** El Programa 3.14e define `sublist` como sufijo de un prefijo, usando dos llamadas a `append`. Explicar por qué el orden de esas dos llamadas es el adecuado (sugerencia: probar `sublist(Xs,[a,b,c])` con ambos órdenes).
- **Notas:** Con el orden invertido la primera llamada tiene infinitas soluciones y la consulta no termina.

### AoP-7.3-2 — Orden de cláusulas y objetivos en `substitute`
- **Fuente:** Sterling & Shapiro, §7.3, ej. (ii), p. 177
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Discutir el orden de las cláusulas, el orden de los objetivos y la terminación de `substitute/4` (AoP-3.3-1).
- **Notas:** Poner la prueba `X \= Z` antes de la llamada recursiva ("fallar lo antes posible").

### AoP-7.5-1 — `no_doubles` construyendo el resultado de abajo hacia arriba
- **Fuente:** Sterling & Shapiro, §7.5, ej. (i), p. 188
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir el Programa 7.9 (`no_doubles/2`, que construye la lista resultado de arriba hacia abajo) para que la construya de abajo hacia arriba, con un acumulador.
- **Notas:** Compara recursión "de cola" con acumulador y recursión que arma el resultado a la vuelta; el orden de los elementos cambia.

## Capítulo 8: Aritmética

> En SWI-Prolog `between/3` ya existe como predicado del sistema: renombrar las versiones propias (p. ej. `between_desc/3`, `my_between/3`). `length/2` no se puede redefinir.

### AoP-8.2-1 — Números triangulares
- **Fuente:** Sterling & Shapiro, §8.2, ej. (i), p. 194
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** sí (verificada: triangle(4) = 10)
  ```prolog
  triangle(0, 0).
  triangle(N, T) :- N > 0, N1 is N-1, triangle(N1, T1), T is T1 + N.
  ```
- **SWISH:** sí
- **Enunciado:** El N-ésimo número triangular es 1 + 2 + … + N. Escribir `triangle(N,T)` adaptando el factorial del Programa 8.2.
- **Notas:** Primer contacto con `is/2`. Señalar la guarda `N > 0`, sin la cual `triangle(3,T)` entra en bucle al pedir más soluciones.

### AoP-8.2-2 — Potencia
- **Fuente:** Sterling & Shapiro, §8.2, ej. (ii), p. 195
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** sí (verificada: 2^10 = 1024)
  ```prolog
  power(_, 0, 1).
  power(X, N, V) :- N > 0, N1 is N-1, power(X, N1, V1), V is X*V1.
  ```
- **SWISH:** sí
- **Enunciado:** Escribir `power(X,N,V)` con V = Xᴺ, siguiendo el modelo de `exp` del Programa 3.5. ¿En qué sentidos puede usarse?
- **Notas:** A diferencia de la versión de Peano, solo funciona con X y N instanciados (`is/2` no es reversible): discutirlo explícitamente.

### AoP-8.2-3 — Pasar a aritmética los programas del §3.1
- **Fuente:** Sterling & Shapiro, §8.2, ej. (iii), p. 195
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir con la aritmética de Prolog los demás programas de aritmética del §3.1 y sus ejercicios (par/impar, Fibonacci, cociente entero, MCD por restas, etc.).
- **Notas:** Ideal para contrastar Peano (reversible, lento) con `is/2` (rápido, unidireccional).

### AoP-8.2-4 — Árbol de codificación de Huffman
- **Fuente:** Sterling & Shapiro, §8.2, ej. (iv), p. 195
- **Tema:** 6, 7
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dada una lista de símbolos con sus frecuencias relativas, generar el árbol de codificación de Huffman.
- **Notas:** Requiere mantener una lista ordenada por peso (inserción ordenada) y combinar los dos menores. El libro remite a Abelson y Sussman (1985).

### AoP-8.3-1 — `triangle` iterativo
- **Fuente:** Sterling & Shapiro, §8.3, ej. (i), p. 202
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  triangle_it(N, T) :- triangle_it(0, N, 0, T).
  triangle_it(I, N, T, T) :- I >= N.
  triangle_it(I, N, Acc, T) :-
      I < N, I1 is I+1, Acc1 is Acc + I1, triangle_it(I1, N, Acc1, T).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir una versión iterativa (con acumulador, recursión de cola) de `triangle/2` (AoP-8.2-1).
- **Notas:** Es el `for` con variable acumuladora de C escrito en Prolog.

### AoP-8.3-2 — `power` iterativo
- **Fuente:** Sterling & Shapiro, §8.3, ej. (ii), p. 202
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  power_it(X, N, V) :- power_it(X, N, 1, V).
  power_it(_, 0, V, V).
  power_it(X, N, Acc, V) :- N > 0, N1 is N-1, Acc1 is Acc*X, power_it(X, N1, Acc1, V).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir una versión iterativa de `power/3` (AoP-8.2-2).

### AoP-8.3-3 — `between` en orden descendente
- **Fuente:** Sterling & Shapiro, §8.3, ej. (iii), p. 202
- **Tema:** 4, 7
- **Dificultad:** 1
- **Solución:** sí (verificada: da 3, 2, 1)
  ```prolog
  between_desc(I, J, J) :- J >= I.
  between_desc(I, J, K) :- J > I, J1 is J-1, between_desc(I, J1, K).
  ```
- **SWISH:** sí
- **Enunciado:** Reescribir el Programa 8.5 (`between(I,J,K)`, que genera los enteros de I a J al reintentar) para que los genere en orden descendente.
- **Notas:** Un generador por backtracking: equivale a un `for` descendente. `between/3` es predicado del sistema en SWI: usar otro nombre.

### AoP-8.3-4 — Producto de una lista, iterativo
- **Fuente:** Sterling & Shapiro, §8.3, ej. (iv), p. 202
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  timeslist(Xs, P) :- timeslist(Xs, 1, P).
  timeslist([], P, P).
  timeslist([X|Xs], Acc, P) :- Acc1 is Acc*X, timeslist(Xs, Acc1, P).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir `timeslist(ListaDeEnteros,Producto)` en forma iterativa, análoga a `sumlist` del Programa 8.6b.

### AoP-8.3-5 — Área de un polígono, iterativa
- **Fuente:** Sterling & Shapiro, §8.3, ej. (v), p. 203
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir en forma iterativa el Programa 8.8, que calcula el área encerrada por un polígono dado como lista de puntos.
- **Notas:** Ver el Programa 8.8 (p. 200).

### AoP-8.3-6 — Mínimo de una lista
- **Fuente:** Sterling & Shapiro, §8.3, ej. (vi), p. 203
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  minlist([X|Xs], M) :- minlist(Xs, X, M).
  minlist([], M, M).
  minlist([X|Xs], M0, M) :- M1 is min(X, M0), minlist(Xs, M1, M).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir un programa que encuentre el mínimo de una lista de enteros.
- **Notas:** Variante sin `min/2`: dos cláusulas con `X < M0` y `X >= M0`. La lista vacía no tiene mínimo: el predicado falla.

### AoP-8.3-7 — Largo de una lista, iterativo
- **Fuente:** Sterling & Shapiro, §8.3, ej. (vii), p. 203
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  len(Xs, N) :- len(Xs, 0, N).
  len([], N, N).
  len([_|Xs], N0, N) :- N1 is N0+1, len(Xs, N1, N).
  ```
- **SWISH:** sí
- **Enunciado:** Reescribir el Programa 8.11 (largo de una lista con `is/2`) para que sea iterativo, usando un contador como en el Programa 8.3.
- **Notas:** En SWI no se puede redefinir `length/2`: usar otro nombre.

### AoP-8.3-8 — `range` construido de abajo hacia arriba
- **Fuente:** Sterling & Shapiro, §8.3, ej. (viii), p. 203
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí (verificada: range(1,4) = [1,2,3,4])
  ```prolog
  range_bu(M, N, Ns) :- range_bu(M, N, [], Ns).
  range_bu(M, N, Acc, [N|Acc]) :- N =:= M.
  range_bu(M, N, Acc, Ns) :- N > M, N1 is N-1, range_bu(M, N1, [N|Acc], Ns).
  ```
- **SWISH:** sí
- **Enunciado:** Reescribir el Programa 8.12 (`range(M,N,Ns)`: lista de enteros de M a N) para que la lista se construya de abajo hacia arriba (con acumulador) en lugar de arriba hacia abajo.
- **Notas:** Para obtener la lista en orden creciente con acumulador hay que recorrer de N hacia M.

## Capítulo 9: Inspección de estructuras

### AoP-9.1-1 — `flatten` con acumulador
- **Fuente:** Sterling & Shapiro, §9.1, ej. (i), p. 208
- **Tema:** 3, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir el Programa 9.1a (`flatten(Xs,Ys)`, doblemente recursivo con `append`) para que use un acumulador en lugar de `append`, manteniendo la doble recursión.
- **Notas:** Usa predicados de tipo (`constant/1` del libro; en SWI `atomic/1`) y distinguir `[]` de un átomo. `flatten/2` existe en SWI: renombrar.

### AoP-9.2-1 — Contar apariciones de un subtérmino
- **Fuente:** Sterling & Shapiro, §9.2, ej. (i), p. 214
- **Tema:** 3, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `occurrences(Sub,Term,N)`: N es la cantidad de veces que Sub aparece como subtérmino de Term (Term es básico, sin variables).
- **Notas:** Recorrer los argumentos con `functor/3` y `arg/3` (o `=../2`). Se usa en el resolvedor de ecuaciones del cap. 23.

### AoP-9.2-2 — Posición de un subtérmino
- **Fuente:** Sterling & Shapiro, §9.2, ej. (ii), p. 214–215
- **Tema:** 3, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `position(Sub,Term,Pos)`: Pos es la lista de índices de argumento que llevan desde la raíz de Term hasta Sub. Por ejemplo, la posición de `X` en `2*sin(X)` es `[2,1]`. Sugerencia: agregar un argumento al Programa 9.2 (`subterm/2`) y construir la lista de arriba hacia abajo.

### AoP-9.2-3 — `=..` contando hacia abajo
- **Fuente:** Sterling & Shapiro, §9.2, ej. (iii), p. 215
- **Tema:** 3, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** El Programa 9.5a construye la lista `[F|Args]` de un término recorriendo sus argumentos con un contador ascendente. Reescribirlo para que cuente hacia abajo, usando un acumulador.

### AoP-9.2-4 — `functor` y `arg` a partir de `univ`
- **Fuente:** Sterling & Shapiro, §9.2, ej. (iv), p. 215
- **Tema:** 3, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `functor/3` y `arg/3` en términos de `=../2`. ¿En qué modos pueden usarse las definiciones obtenidas?
- **Notas:** Usar nombres propios (`my_functor/3`, `my_arg/3`). Para `arg`, `nth1/3` sobre la lista de argumentos.

### AoP-9.2-5 — `substitute` en términos con `univ`
- **Fuente:** Sterling & Shapiro, §9.2, ej. (v), p. 215
- **Tema:** 3, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir el Programa 9.3 (`substitute(Viejo,Nuevo,Term,Term1)`, reemplazo de un subtérmino en todo un término, implementado con `functor`/`arg`) para que use `=..` y una función sobre la lista de argumentos.
- **Notas:** Con `=..` el recorrido de los argumentos se vuelve un recorrido de lista (anticipa `maplist/3`, unidad 9).

## Capítulo 10: Predicados metalógicos

### AoP-10.1-1 — `range` con varios modos de uso
- **Fuente:** Sterling & Shapiro, §10.1, ej. (i), p. 220
- **Tema:** 3, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir una versión del Programa 8.12 (`range(M,N,Ns)`) que funcione en varios modos: generar la lista dados M y N, y también recuperar M y N dada la lista.
- **Notas:** Se elige la cláusula según qué argumentos estén instanciados, con `var/1`, `nonvar/1` o `integer/1`.

### AoP-10.1-2 — `plus` que también descompone un número
- **Fuente:** Sterling & Shapiro, §10.1, ej. (ii), p. 220
- **Tema:** 3, 4, 7
- **Dificultad:** 2
- **Solución:** sí (verificada: `plus3(P,Q,3)` da 0-3, 1-2, 2-1, 3-0)
  ```prolog
  plus3(X, Y, Z) :- integer(X), integer(Y), !, Z is X+Y.
  plus3(X, Y, Z) :- integer(X), integer(Z), !, Y is Z-X.
  plus3(X, Y, Z) :- integer(Y), integer(Z), !, X is Z-Y.
  plus3(X, Y, Z) :- integer(Z), between(0, Z, X), Y is Z-X.
  ```
- **SWISH:** sí
- **Enunciado:** El Programa 10.1 define `plus/3` con `nonvar/1` para sumar o restar según qué argumentos estén dados. Extenderlo para que, dado solo el resultado, enumere todas las formas de partirlo en dos sumandos naturales. Sugerencia: usar `between/3`.
- **Notas:** La solución usa cortes (cap. 11) para que los tres primeros casos sean deterministas; sin ellos, basta con condiciones excluyentes. `plus/3` existe en SWI: renombrar.

## Capítulo 11: Cortes y negación

### AoP-11.1-1 — Cortes verdes en `partition`
- **Fuente:** Sterling & Shapiro, §11.1, ej. (i), p. 236
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Agregar cortes al `partition/4` del quicksort (Programa 3.22) sin cambiar su significado.
- **Notas:** Poner el corte después de la comparación `X =< Y`. Verificar que el conjunto de respuestas no cambia (corte "verde").

### AoP-11.1-2 — Cortes en la derivación simbólica
- **Fuente:** Sterling & Shapiro, §11.1, ej. (ii), p. 236
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Agregar cortes al programa de derivación del Programa 3.30.
- **Notas:** Discutir cuáles son verdes: dos cláusulas pueden unificar con la misma cabeza (p. ej. `x` y una constante).

### AoP-11.1-3 — Cortes en el ordenamiento por inserción
- **Fuente:** Sterling & Shapiro, §11.1, ej. (iii), p. 236
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Agregar cortes al ordenamiento por inserción (Programa 3.21).

### AoP-11.3-1 — `\==` con corte y falla
- **Fuente:** Sterling & Shapiro, §11.3, ej. (i), p. 243
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  not_identical(X, Y) :- X == Y, !, fail.
  not_identical(_, _).
  ```
- **SWISH:** sí
- **Enunciado:** Definir el predicado del sistema `\==` usando `==` y la combinación corte-falla.
- **Notas:** Es el esquema general de `\+` (Programa 11.6). Mostrar que el orden de las cláusulas es esencial.

### AoP-11.3-2 — `nonvar` con corte y falla
- **Fuente:** Sterling & Shapiro, §11.3, ej. (ii), p. 243
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  my_nonvar(X) :- var(X), !, fail.
  my_nonvar(_).
  ```
- **SWISH:** sí
- **Enunciado:** Definir `nonvar/1` usando `var/1` y la combinación corte-falla.

### AoP-11.4-1 — Dónde cortar en `substitute`
- **Fuente:** Sterling & Shapiro, §11.4, ej. (i), p. 247
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Analizar dónde podrían ponerse cortes en el Programa 9.3 (`substitute/4` sobre términos). ¿Sirve una combinación corte-falla? ¿Pueden omitirse condiciones explícitas (cortes rojos)?

### AoP-11.4-2 — `select` con un solo corte
- **Fuente:** Sterling & Shapiro, §11.4, ej. (ii), p. 247
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Comparar `select/3` del Programa 3.19 con la versión que agrega un corte en la primera cláusula:
  ```prolog
  select(X, [X|Xs], Xs) :- !.
  select(X, [Y|Ys], [Y|Zs]) :- select(X, Ys, Zs).
  ```
  Sugerencia: pensar en las variantes de `select` (p. ej. AoP-3.3-2).
- **Notas:** El corte es rojo: la nueva versión borra solo la primera aparición y, con X libre, devuelve únicamente el primer elemento. Renombrar para no chocar con la biblioteca.

## Capítulo 12: Predicados extralógicos

### AoP-12.1-1 — Leer también números
- **Fuente:** Sterling & Shapiro, §12.1, ej. (i), p. 259
- **Tema:** 0, 3
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no (lee de la entrada estándar carácter a carácter; usar swipl local)
- **Enunciado:** Extender el Programa 12.2 (`read_word_list/1`, que lee una línea y la parte en palabras) para que acepte una variedad mayor de entradas, por ejemplo números.
- **Notas:** El libro usa `get_char/1` y `atom_list/2`; en SWI, `atom_chars/2` y `number_chars/2`. Hoy es más simple leer la línea con `read_line_to_string/2` y usar `split_string/4`, pero se pierde el ejercicio de anticipar un carácter.

### AoP-12.3-1 — Juego de llegar a 20 con funciones memo
- **Fuente:** Sterling & Shapiro, §12.3, ej. (i), p. 263
- **Tema:** 7, 10
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dos jugadores dicen por turnos un número entre 1 y 3; se lleva la suma y gana quien la hace llegar a 20. Escribir un programa que juegue para ganar, usando funciones memo (guardar con `assert` los resultados de posiciones ya analizadas, como el `lemma/1` del Programa 12.3).
- **Notas:** Buena introducción a `assert` con un propósito claro (memoización). Declarar el predicado memo con `:- dynamic`. En SWI moderno, el *tabling* (`:- table`) hace lo mismo sin `assert`.

### AoP-12.4-1 — Ampliar el editor de líneas
- **Fuente:** Sterling & Shapiro, §12.4, ej. (i), p. 270
- **Tema:** 0, 10
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no (programa interactivo con `read/1`)
- **Enunciado:** Agregar al editor del Programa 12.5 comandos para: (a) bajar el cursor N líneas; (b) borrar N líneas; (c) ir a una línea que contenga un término dado; (d) reemplazar un término por otro; (e) otro comando a elección.
- **Notas:** Requiere estudiar el Programa 12.5 (editor sobre un par de listas). Proyecto más que ejercicio.

### AoP-12.4-2 — Registro de sesión en un archivo elegido
- **Fuente:** Sterling & Shapiro, §12.4, ej. (ii), p. 270
- **Tema:** 0
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no (escribe archivos)
- **Enunciado:** Modificar el shell con registro del Programa 12.7 para que el usuario indique el archivo donde se guarda la salida registrada.
- **Notas:** Usar `open/3`, `with_output_to/2` o `format/3` con un stream en SWI; el libro usa el modelo de E/S de Edimburgo (`tell/1`, `told/0`).

### AoP-12.5-1 — Implementar `abolish`
- **Fuente:** Sterling & Shapiro, §12.5, ej. (i), p. 272
- **Tema:** 10
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  my_abolish(F, N) :- functor(T, F, N), retract((T :- _)), fail.
  my_abolish(_, _).
  ```
- **SWISH:** sí (con predicados `:- dynamic`)
- **Enunciado:** Escribir una versión propia de `abolish(F,N)`, que retira todas las cláusulas del procedimiento F de aridad N.
- **Notas:** Bucle guiado por falla (§12.5). Alternativa en SWI: `retractall/1`. A diferencia del `abolish/1` real, esta versión deja el predicado declarado.

## Capítulo 13: Desarrollo de programas

### AoP-13.3-1 — Diferencia de listas con el esquema del Programa 13.3
- **Fuente:** Sterling & Shapiro, §13.3, ej. (i), p. 285
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Mejorar el Programa 13.3 para que construya la lista de los elementos que están en la primera lista pero no en la segunda.
- **Notas:** Ejercicio de "mejora por técnicas" (esqueleto + técnica): el Programa 13.3 (p. 282) calcula unión e intersección de dos listas.

### AoP-13.3-2 — Reemplazar cada nodo por el máximo, en una sola pasada
- **Fuente:** Sterling & Shapiro, §13.3, ej. (ii), p. 285
- **Tema:** 3, 5, 7
- **Dificultad:** 3
- **Solución:** sí (verificada; supone enteros positivos)
  ```prolog
  repmax(T, R) :- repmax(T, M, M, R).
  repmax(void, _, 0, void).
  repmax(tree(X,L,R), M, Max, tree(M,L1,R1)) :-
      repmax(L, M, ML, L1), repmax(R, M, MR, R1),
      Max is max(X, max(ML, MR)).
  ```
- **SWISH:** sí
- **Enunciado:** Dado un árbol binario de enteros positivos, construir un árbol con la misma forma en el que cada nodo lleva el valor máximo del árbol original, recorriendo el árbol una sola vez. Sugerencia: partir del esqueleto del Programa 3.23.
- **Notas:** El truco es la variable lógica M: se coloca en todos los nodos antes de conocer su valor y se liga al final. Imposible de hacer igual en C; muestra el poder de la variable lógica.

### AoP-13.3-3 — Media y moda en una pasada
- **Fuente:** Sterling & Shapiro, §13.3, ej. (iii), p. 285
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Calcular la media y la moda de una lista ordenada de números recorriéndola una sola vez.
- **Notas:** Varios acumuladores a la vez (suma, cantidad, racha actual, mejor racha).

## Parte III: Técnicas avanzadas (caps. 14–20)

> Selección: los ejercicios accesibles para un alumno de nivel inicial o intermedio tienen ficha completa; el resto se etiqueta **X** con ficha abreviada.

## Capítulo 14: Programación no determinista

### AoP-14.1-1 — Raíz cuadrada entera por generar y probar
- **Fuente:** Sterling & Shapiro, §14.1, ej. (i), p. 302
- **Tema:** 4, 7
- **Dificultad:** 1
- **Solución:** sí (verificada: isqrt(17) = 4, isqrt(16) = 4)
  ```prolog
  isqrt(N, I) :- between(0, N, I), I*I =< N, (I+1)*(I+1) > N.
  ```
- **SWISH:** sí
- **Enunciado:** Calcular la raíz cuadrada entera de un natural N (el I tal que I² ≤ N < (I+1)²), generando candidatos con `between/3` (Programa 8.5) y probándolos.
- **Notas:** Ejemplo mínimo del esquema "generar y probar". Tras la primera respuesta queda un punto de elección: pedir más soluciones lleva a recorrer hasta N.

### AoP-14.1-2 — Matrimonios estables
- **Fuente:** Sterling & Shapiro, §14.1, ej. (ii), p. 302–303
- **Tema:** 4, 6
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Hay N hombres y N mujeres, cada uno con una lista de preferencias sobre el otro grupo. Encontrar un conjunto de matrimonios estable: que no exista un hombre y una mujer que se prefieran mutuamente por sobre sus cónyuges. Probarlo con los datos de cinco parejas que da el libro (p. 302–303).
- **Notas:** Con generar y probar (permutaciones + chequeo de estabilidad) es sencillo de escribir; con 5 parejas son 120 permutaciones. El algoritmo de Gale-Shapley es la versión eficiente.

### AoP-14.1-3 — Colorear el mapa de Europa occidental
- **Fuente:** Sterling & Shapiro, §14.1, ej. (iii), p. 303
- **Tema:** 4, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Usar el programa de coloreo de mapas (Programa 14.4) para colorear el mapa de Europa occidental, cuyos países y vecinos da el Programa 14.5.
- **Notas:** Clásico de backtracking. Si no se quiere depender de los programas del libro, dar el mapa de las provincias argentinas como hechos `vecino/2`.

### AoP-14.1-4 — N reinas por instanciación de una estructura
- **Fuente:** Sterling & Shapiro, §14.1, ej. (iv), p. 303
- **Tema:** 4, 6
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Diseñar una estructura de datos para el problema de las N reinas que se resuelva instanciándola (filas, columnas y diagonales como listas de variables compartidas) y escribir el programa correspondiente.
- **Notas:** El ejercicio siguiente (AoP-14.1-5) es precisamente una solución de este tipo.

### AoP-14.1-5 — Explicar un programa rápido de N reinas
- **Fuente:** Sterling & Shapiro, §14.1, ej. (v), p. 303
- **Tema:** 3, 4
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Explicar por qué el programa de la p. 303 (`queens/2` con `gen_list/2`, `place_queens/4` y `place_queen/4`, que usa dos listas de variables para las diagonales "Ups" y "Downs") resuelve el problema de las N reinas.
- **Notas:** Programa corto (unas 8 cláusulas) pero muy sutil: las restricciones de diagonal se logran solo compartiendo variables. Excelente ejercicio de lectura de código sobre unificación.

### AoP-14.1-6 — El acertijo de la cebra
- **Fuente:** Sterling & Shapiro, §14.1, ej. (vi), p. 303–304
- **Tema:** 3, 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Cinco casas de distinto color, con habitantes de distinta nacionalidad, mascota, bebida y marca de cigarrillos; catorce pistas (el libro las da en p. 303–304). ¿Quién tiene la cebra? ¿Quién bebe agua?
- **Notas:** Clásico. Representar las casas como una lista de cinco `casa(Color,Nac,Mascota,Bebida,Cigarrillo)` y cada pista con `member/2`, `nextto/3` o una relación "a la derecha de". Sirve de modelo el marco del Programa 14.6/14.7 (acertijos lógicos).

### AoP-14.1-7 — Planaridad de grafos (Hopcroft-Tarjan) — X
- **Fuente:** Sterling & Shapiro, §14.1, ej. (vii), p. 304
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Probar si un grafo es planar con el algoritmo de Hopcroft y Tarjan.

### AoP-14.2-1 — Otro problema del mundo de bloques
- **Fuente:** Sterling & Shapiro, §14.2, ej. (i), p. 311
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Usar el planificador en profundidad del Programa 14.11 para resolver otro problema sencillo del mundo de bloques.
- **Notas:** Requiere estudiar primero el Programa 14.11 (búsqueda en profundidad con historial de estados).

### AoP-14.2-2 — Planificar operaciones de un acumulador — X
- **Fuente:** Sterling & Shapiro, §14.2, ej. (ii), p. 311
- **Tema:** X (4)
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Adaptar el Programa 14.11 para planificar secuencias de instrucciones `load`, `store`, `add`, `subtract` de una máquina de un acumulador que lleven a estados finales dados (p. ej. acumulador con (c1 − c2) + (c3 − c4)).

### AoP-14.3-1 — Nuevos problemas de analogía
- **Fuente:** Sterling & Shapiro, §14.3, ej. (i), p. 319 (Figura 14.8, p. 320)
- **Tema:** 3, 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Extender el programa ANALOGY (Programa 14.13: figuras como términos `inside/2`, `above/2`, y una relación `match/3` entre pares) para resolver los tres problemas de analogía geométrica de la Figura 14.8.
- **Notas:** Lo interesante es decidir la representación de las figuras como términos y las nuevas operaciones.

### AoP-14.3-2 — Nuevos patrones para ELIZA
- **Fuente:** Sterling & Shapiro, §14.3, ej. (ii), p. 319
- **Tema:** 3, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Agregar nuevos pares estímulo/respuesta al ELIZA simplificado del Programa 14.15.
- **Notas:** Atractivo para los alumnos; las reglas son hechos con listas de palabras y variables (unificación de patrones). Puede hacerse en castellano.

### AoP-14.3-3 — ELIZA con cambio de persona
- **Fuente:** Sterling & Shapiro, §14.3, ej. (iii), p. 319
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Si se le dice a ELIZA "I like teasing my father", responde "Does any one else in your family like teasing my father". Modificar el Programa 14.15 para que convierta los pronombres de primera persona en segunda (I → you, my → your, etc.) al armar la respuesta.
- **Notas:** Es un `map` sobre la lista de palabras con una tabla de hechos.

### AoP-14.3-4 — McSAM con estructuras — X
- **Fuente:** Sterling & Shapiro, §14.3, ej. (iv), p. 319
- **Tema:** X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir McSAM (Programa 14.16) para que use estructuras en lugar de listas.

### AoP-14.3-5 — Reconstruir otro clásico de IA (GPS) — X
- **Fuente:** Sterling & Shapiro, §14.3, ej. (v), p. 319
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reconstruir en Prolog otro programa clásico de IA; se sugiere el General Problem Solver.

## Capítulo 15: Estructuras de datos incompletas

> Las listas diferencia son una técnica intermedia-avanzada: accesible después de dominar listas y acumuladores. Se marcan con tema 6 las más directas y X el resto.

### AoP-15.1-1 — Aplanar con listas diferencia en orden inverso
- **Fuente:** Sterling & Shapiro, §15.1, ej. (i), p. 331
- **Tema:** 6
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir el Programa 15.2 (aplanar una lista de listas con listas diferencia) para que la lista final tenga los elementos en orden inverso al de aparición.

### AoP-15.1-2 — Recorridos de árboles con listas diferencia
- **Fuente:** Sterling & Shapiro, §15.1, ej. (ii), p. 331–332
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir `preorder/2`, `inorder/2` y `postorder/2` del Programa 3.27 usando listas diferencia, sin llamar a `append`.
- **Notas:** El mejor primer ejercicio de listas diferencia: la versión con `append` es cuadrática; la otra, lineal.

### AoP-15.1-3 — Torres de Hanoi con lista diferencia — X
- **Fuente:** Sterling & Shapiro, §15.1, ej. (iii), p. 332
- **Tema:** X (6)
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir el Programa 12.3 (Hanoi con funciones memo) para que la lista de movimientos se construya como lista diferencia.

### AoP-15.2-1 — Reconocer una suma normalizada
- **Fuente:** Sterling & Shapiro, §15.2, ej. (i), p. 334
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `normalized_sum(Expr)`, verdadero si Expr es una suma normalizada (asociada a la derecha).
- **Notas:** Casi igual a AoP-3.5-1.

### AoP-15.2-2 — Normalización de sumas: variantes — X
- **Fuente:** Sterling & Shapiro, §15.2, ej. (ii), p. 334
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir el Programa 15.7 (normalización con "sumas diferencia") para que (a) construya la suma de abajo hacia arriba; (b) invierta el orden de los sumandos.

### AoP-15.2-3 — Normalización de sumas con constantes — X
- **Fuente:** Sterling & Shapiro, §15.2, ej. (iii), p. 334
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Mejorar el Programa 15.7 para que sume los números que aparecen entre los sumandos y los ponga primero: (3 + x) + 2 + (y + 4) queda 9 + (x + y).

### AoP-15.2-4 — Productos diferencia — X
- **Fuente:** Sterling & Shapiro, §15.2, ej. (iv), p. 334
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Normalizar productos usando "productos diferencia", por analogía con las sumas diferencia.

## Capítulo 16: Programación de segundo orden

### AoP-16.1-1 — Intersección con `findall`
- **Fuente:** Sterling & Shapiro, §16.1, ej. (i), p. 345–346
- **Tema:** 9
- **Dificultad:** 1
- **Solución:** sí (verificada)
  ```prolog
  intersect(Xs, Ys, Zs) :- findall(X, (member(X, Xs), member(X, Ys)), Zs).
  ```
- **SWISH:** sí
- **Enunciado:** Definir `intersect(Xs,Ys,Zs)` con un predicado de todas las soluciones. ¿Qué pasa si las listas no tienen elementos en común? Comparar con una definición recursiva.
- **Notas:** Con `findall` se obtiene `[]`; con `bagof`/`setof`, falla. Buen ejercicio para distinguir los tres predicados.

### AoP-16.2-1 — Algoritmo de Lee con otros obstáculos — X
- **Fuente:** Sterling & Shapiro, §16.2, ej. (i), p. 355
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Modificar el Programa 16.6 (ruteo de Lee) para aceptar obstáculos que no sean rectángulos.

### AoP-16.2-2 — Índice KWIC sobre líneas de texto
- **Fuente:** Sterling & Shapiro, §16.2, ej. (ii), p. 355
- **Tema:** 9, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Adaptar el Programa 16.7 (índice "palabra clave en contexto", construido con `setof`) para extraer las palabras clave de líneas de texto.
- **Notas:** En SWI, `split_string/4` o `atomic_list_concat/3` convierten una línea en lista de palabras.

### AoP-16.2-3 — Rotación de listas con listas diferencia — X
- **Fuente:** Sterling & Shapiro, §16.2, ej. (iii), p. 355
- **Tema:** X (6)
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Modificar la rotación de una lista (usada en el KWIC) para que use listas diferencia.

### AoP-16.2-4 — Árbol generador mínimo
- **Fuente:** Sterling & Shapiro, §16.2, ej. (iv), p. 355
- **Tema:** 9, 6
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir un programa que encuentre un árbol generador mínimo de un grafo con pesos.
- **Notas:** Prim o Kruskal con `setof/3` para elegir la arista más barata.

### AoP-16.2-5 — Flujo máximo (Ford-Fulkerson) — X
- **Fuente:** Sterling & Shapiro, §16.2, ej. (v), p. 355
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Encontrar el flujo máximo de una red con el algoritmo de Ford-Fulkerson.

### AoP-16.3-1 — Reducción beta — X
- **Fuente:** Sterling & Shapiro, §16.3, ej. (i), p. 358
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir un programa que realice reducción beta sobre expresiones lambda.

## Capítulo 17: Intérpretes

### AoP-17.1-1 — Autómata finito para ab*c
- **Fuente:** Sterling & Shapiro, §17.1, ej. (i), p. 364
- **Tema:** 1, 5, 6
- **Dificultad:** 1
- **Solución:** sí (verificada: acepta `[a,c]` y `[a,b,b,c]`; rechaza `[a,b]` y `[b,c]`)
  ```prolog
  % Intérprete de autómatas (Programa 17.1)
  accept(S) :- initial(Q), accept(Q, S).
  accept(Q, [X|Xs]) :- delta(Q, X, Q1), accept(Q1, Xs).
  accept(Q, []) :- final(Q).
  % Autómata para a b* c
  initial(q0).  final(q2).
  delta(q0, a, q1).  delta(q1, b, q1).  delta(q1, c, q2).
  ```
- **SWISH:** sí
- **Enunciado:** Definir, como hechos para el intérprete de autómatas del Programa 17.1, un autómata finito no determinista que acepte el lenguaje ab*c.
- **Notas:** Muy recomendable para la cátedra: une la teoría de autómatas con programación en Prolog y solo requiere hechos y recursión.

### AoP-17.1-2 — Autómata de pila para aⁿbⁿ
- **Fuente:** Sterling & Shapiro, §17.1, ej. (ii), p. 364
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir, para el intérprete de autómatas de pila del Programa 17.3, un autómata que acepte aⁿbⁿ.

### AoP-17.1-3 — Intérprete de máquinas de Turing
- **Fuente:** Sterling & Shapiro, §17.1, ej. (iii), p. 364
- **Tema:** 5, 6
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir un intérprete de máquinas de Turing en el estilo de los Programas 17.1 y 17.3.
- **Notas:** Representar la cinta con dos listas (izquierda invertida y derecha). Muestra que Prolog es Turing-completo.

### AoP-17.2-1 a AoP-17.2-5 — Metaintérpretes — X
- **Fuente:** Sterling & Shapiro, §17.2, ej. (i)–(v), p. 372
- **Tema:** X
- **Dificultad:** 2–3
- **Solución:** no
- **SWISH:** sí (con `clause/2` sobre predicados dinámicos)
- **Enunciado:** A partir del metaintérprete "vanilla" (Programa 17.5): (i) contar cuántas veces se llama a un procedimiento en una computación exitosa; (ii) hallar la profundidad máxima alcanzada; (iii) extender el Programa 17.6 para que haga de traza y arme el árbol de prueba; (iv) extender `solve_trace/2` (Programa 17.7) para que muestre los objetivos que fallan; (v) cambiar la representación del árbol de prueba del Programa 17.8.
- **Notas:** Se agrupan en una ficha. El (i) y el (ii) son abordables al final del curso si se presentó el vanilla de tres cláusulas.

### AoP-17.4-1 a AoP-17.4-3 — Shell de explicaciones — X
- **Fuente:** Sterling & Shapiro, §17.4, ej. (i)–(iii), p. 390
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** (i) Explicar también los objetivos preguntados al usuario en el explicador del Programa 17.22; (ii) permitir ejecutar predicados predefinidos en el shell de explicaciones; (iii) escribir un metaintérprete de dos niveles que halle la profundidad máxima de cualquier computación.

## Capítulo 18: Transformación de programas

### AoP-18.1-1, AoP-18.2-1, AoP-18.2-2, AoP-18.3-1 — Evaluación parcial — X
- **Fuente:** Sterling & Shapiro, §18.1 ej. (i), p. 401; §18.2 ej. (i)–(ii), p. 406; §18.3 ej. (i), p. 414
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** (18.1-i) Especializar el intérprete de autómatas del Programa 17.1 a un autómata concreto mediante unfold/fold. (18.2-i) Extender el reductor parcial del Programa 18.3 para que maneje predicados predefinidos. (18.2-ii) Aplicar el Programa 18.3 al intérprete de reglas de dos niveles del Programa 17.20. (18.3-i) Aplicar el Programa 18.6 a alguno de los ejercicios del §13.3.

## Capítulo 19: Gramáticas lógicas

### AoP-19.1-1 — Traductor de DCG completo — X
- **Fuente:** Sterling & Shapiro, §19.1, ej. (i), p. 421
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Extender el Programa 18.9 para que traduzca a Prolog gramáticas de cláusulas definidas completas (con argumentos y `{}`), no solo gramáticas libres de contexto.

### AoP-19.1-2 — Pascal: declaraciones de etiquetas y funciones
- **Fuente:** Sterling & Shapiro, §19.1, ej. (ii), p. 421
- **Tema:** A
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Agregar al Programa 19.3 (DCG para la parte declarativa de un bloque Pascal) el manejo correcto de declaraciones de etiquetas y de funciones.

### AoP-19.1-3 — Pascal: devolver las variables declaradas
- **Fuente:** Sterling & Shapiro, §19.1, ej. (iii), p. 421
- **Tema:** A
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Mejorar el Programa 19.3 para que devuelva la lista de variables declaradas en la parte declarativa.
- **Notas:** Primer ejercicio de DCG con argumentos que "devuelven" información.

### AoP-19.1-4 — Un analizador para un lenguaje a elección
- **Fuente:** Sterling & Shapiro, §19.1, ej. (iv), p. 421
- **Tema:** A
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir, en el estilo del Programa 19.3, un analizador sintáctico para un lenguaje a elección.
- **Notas:** Sugerencias acotadas: expresiones aritméticas, fechas, JSON simple o un subconjunto de C (declaraciones de variables), que los alumnos conocen.

### AoP-19.2-1 a AoP-19.2-3 — Intérprete de DCG — X
- **Fuente:** Sterling & Shapiro, §19.2, ej. (i)–(iii), p. 422–423
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** (i) Escribir como DCG el intérprete de gramáticas del Programa 19.4; (ii) usar el reductor parcial (Programa 18.3) para especializar ese intérprete a una gramática dada; (iii) extender el Programa 19.4 para que construya el árbol de análisis.

### AoP-19.3-1 — Gramática del francés con concordancia de género
- **Fuente:** Sterling & Shapiro, §19.3, ej. (i), p. 429
- **Tema:** A
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir una gramática sencilla del francés que muestre la concordancia de género (artículo, sustantivo y adjetivo).
- **Notas:** Adaptarlo al castellano ("el gato negro" / "la gata negra") es natural: los no terminales llevan un argumento de género, y se agrega número como extensión.

### AoP-19.3-2 — Números en inglés hasta un millón
- **Fuente:** Sterling & Shapiro, §19.3, ej. (ii), p. 429
- **Tema:** A, 7
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Extender el Programa 19.9 (DCG que analiza números escritos en inglés) para cubrir todos los números menores que un millón, aceptando formas como "thirty-five hundred" y rechazando "thirty hundred".
- **Notas:** Versión en castellano: "mil novecientos ochenta y cuatro" → 1984, con la complicación de "cien/ciento", "quinientos", etc.

## Capítulo 20: Técnicas de búsqueda

### AoP-20.1-1 — Jarras de agua con dos operaciones
- **Fuente:** Sterling & Shapiro, §20.1, ej. (i), p. 439
- **Tema:** 4, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Rehacer el programa de las jarras de agua (Programa 20.3, p. 435, sobre el marco de búsqueda en profundidad del Programa 20.1) usando solo dos operaciones: llenar y trasvasar.
- **Notas:** Requiere el marco del Programa 20.1 (`solve_dfs/3` con `move/2`, `update/3`, `legal/1` e historial de estados).

### AoP-20.1-2 — Misioneros y caníbales
- **Fuente:** Sterling & Shapiro, §20.1, ej. (ii), p. 439
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Tres misioneros y tres caníbales deben cruzar un río en un bote de una o dos plazas; en ninguna orilla puede haber más misioneros que caníbales (en la versión del libro, si hay más misioneros, "convierten" a los caníbales). Encontrar una secuencia de cruces segura.
- **Notas:** Clásico de búsqueda en espacio de estados. Estado: `estado(MisIzq,CanIzq,OrillaBote)`. Controlar el historial para evitar ciclos.

### AoP-20.1-3 — Los cinco maridos celosos
- **Fuente:** Sterling & Shapiro, §20.1, ej. (iii), p. 442
- **Tema:** 4, 6
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Cinco matrimonios deben cruzar en un bote de tres plazas; ninguna esposa puede estar (en el bote o en una orilla) con otro hombre si su esposo no está presente. Encontrar una forma de cruzar (Dudeney, 1917).
- **Notas:** Como el anterior pero con un espacio de estados mayor y restricciones más finas.

### AoP-20.1-4 — Marco de búsqueda en anchura — X
- **Fuente:** Sterling & Shapiro, §20.1, ej. (iv), p. 442
- **Tema:** X (9)
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Construir un marco general de resolución de problemas con búsqueda en anchura, análogo al Programa 20.1, basado en los programas del §16.2.

### AoP-20.1-5 — Ocho reinas en el marco de búsqueda informada — X
- **Fuente:** Sterling & Shapiro, §20.1, ej. (v), p. 442
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Expresar el problema de las ocho reinas en el marco de búsqueda (primero el mejor) y encontrar una función de evaluación.

## Parte IV: Aplicaciones (caps. 21–24)

> Los caps. 21 (juegos) y 22 (sistema experto) no tienen ejercicios. Los de los caps. 23 y 24 extienden programas de varios cientos de líneas: todos **X**.

### AoP-23-1 a AoP-23-5 — Resolvedor de ecuaciones PRESS — X
- **Fuente:** Sterling & Shapiro, cap. 23, ej. (i)–(v), p. 497–498
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Sobre el Programa 23.1: (i) agregar axiomas de aislamiento para cocientes y resolver x/2 = 5; (ii) resolver ecuaciones lineales y cuadráticas "disfrazadas" (2·x³ − 8 = x³; x⁴ − 5·x² + 6 = 0); (iii) resolver cos(2·x) − sin(x) = 0 como cuadrática en sin(x); (iv) reescribir `free_of(Term,X)` para que falle apenas encuentre X; (v) resolver sistemas simples de ecuaciones.
- **Notas:** El (iv) es aislable y accesible: es un recorrido de términos con `=..` (tema 3) y puede proponerse suelto.

### AoP-24-1, AoP-24-2 — Compilador de PL — X
- **Fuente:** Sterling & Shapiro, cap. 24, ej. (i)–(ii), p. 519
- **Tema:** X (A)
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Extender el compilador del cap. 24 (lenguaje PL tipo Pascal): (i) agregar el ciclo `repeat … until` en el analizador y en el generador de código, probándolo con un programa que imprima del 1 al 10; (ii) permitir expresiones aritméticas arbitrarias, lo que obliga a manejar varias variables temporales.

## Programas clásicos del libro para convertir en ejercicios

> Ejercicios propuestos por nosotros a partir de programas del libro, no de las listas "Exercises". El formato del enunciado es "escribir el predicado X que…"; los alumnos lo resuelven y después comparan con el programa del libro. Las páginas son del PDF.

### AoP-P-1.1 — Base de datos familiar bíblica (adaptado de los Programas 1.1 y 1.2)
- **Fuente:** Sterling & Shapiro, Programas 1.1 (p. 53) y 1.2 (p. 64)
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Cargar hechos `father/2`, `mother/2`, `male/1`, `female/1` sobre la familia de Abraham y hacer consultas con y sin variables. Luego definir `son/2`, `daughter/2`, `parent/2` y `grandparent/2`.
- **Notas:** Punto de partida natural de las unidades 1 y 2; muchos ejercicios de los caps. 2, 6 y 7 lo suponen cargado.

### AoP-P-2.2 — Circuito lógico como base de datos (adaptado del Programa 2.2)
- **Fuente:** Sterling & Shapiro, Programa 2.2, p. 74
- **Tema:** 2, 11
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con hechos `resistor(Ext1,Ext2)` y `transistor(Compuerta,Fuente,Drenaje)` que describen un circuito, definir reglas `inverter/2`, `nand_gate/3` y `and_gate/3` que reconozcan esos componentes a partir de las conexiones (variables compartidas). Extensión: agregar un primer argumento que nombre la estructura del componente, como en el Programa 2.3.
- **Notas:** Excelente ejemplo de join por variables compartidas; atractivo para estudiantes de ingeniería.

### AoP-P-3.3 — Aritmética de Peano (adaptado de los Programas 3.1–3.10)
- **Fuente:** Sterling & Shapiro, Programas 3.1–3.10, p. 88–96
- **Tema:** 5
- **Dificultad:** 1–2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con naturales `0, s(0), s(s(0))…`, escribir sucesivamente: `natural_number/1`, `leq/2`, `plus/3`, `times/3`, `exp/3`, `factorial/2`, `minimum/3`, `mod/3`, la función de Ackermann y el MCD de Euclides. Probar cada uno en todos los modos posibles (p. ej. `plus(X,Y,s(s(0)))`).
- **Notas:** La serie de ejercicios de recursión más limpia que existe: sin aritmética de máquina y reversible.

### AoP-P-3.12 — Predicados básicos de listas (adaptado de los Programas 3.12–3.19)
- **Fuente:** Sterling & Shapiro, Programas 3.12 (p. 99), 3.13 (p. 100), 3.14 (p. 101), 3.15 (p. 101), 3.16 (p. 103), 3.17 (p. 105), 3.19 (p. 108)
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `member/2`, `prefix/2`, `suffix/2`, `sublist/2`, `append/3`, `reverse/2` (ingenuo y con acumulador), el largo de una lista en Peano y `select/3`. Para cada uno, explorar los usos no previstos (p. ej. `append(X,Y,[a,b,c])`).
- **Notas:** Usar nombres propios para evitar choques con la biblioteca de SWI (obligatorio para `length/2`).

### AoP-P-3.20 — Tres ordenamientos (adaptado de los Programas 3.20–3.22)
- **Fuente:** Sterling & Shapiro, Programas 3.20 (p. 110), 3.21 (p. 111), 3.22 (p. 111)
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir el ordenamiento por permutaciones (generar y probar), por inserción y el quicksort con `partition/4`; comparar su eficiencia con `time/1`.
- **Notas:** El libro usa números de Peano o comparaciones `<`; en SWI se usan enteros. No llamarlos `sort/2`.

### AoP-P-3.23 — Árboles binarios (adaptado de los Programas 3.23–3.27)
- **Fuente:** Sterling & Shapiro, Programas 3.23 (p. 114), 3.25 (p. 115), 3.27 (p. 117)
- **Tema:** 3, 5
- **Dificultad:** 1–2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `tree(Elem,Izq,Der)` y `void`, escribir: el reconocedor de árboles binarios, `tree_member/2`, `isotree/2` (árboles isomorfos intercambiando hijos) y los recorridos en preorden, inorden y postorden.
- **Notas:** Paralelo directo con estructuras recursivas de C, sin punteros.

### AoP-P-3.29 — Polinomios y derivadas simbólicas (adaptado de los Programas 3.29 y 3.30)
- **Fuente:** Sterling & Shapiro, Programas 3.29 (p. 120) y 3.30 (p. 121)
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `polynomial(Expr,X)`, que reconoce si una expresión es un polinomio en X, y `derivative(Expr,X,DExpr)` con las reglas de derivación usuales.
- **Notas:** Muestra que las expresiones aritméticas son términos (árboles) y no se evalúan. Extensión: simplificar el resultado.

### AoP-P-3.31 — Torres de Hanoi (adaptado del Programa 3.31)
- **Fuente:** Sterling & Shapiro, Programa 3.31, p. 123
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `hanoi(N,A,B,C,Movs)`: Movs es la lista de movimientos `De to Hacia` para pasar N discos de A a B usando C.
- **Notas:** Requiere declarar `to` como operador (`:- op(700, xfx, to).`) o usar un término `move(De,Hacia)`.

### AoP-P-3.32 — Satisfacibilidad de fórmulas booleanas (adaptado del Programa 3.32)
- **Fuente:** Sterling & Shapiro, Programa 3.32, p. 124
- **Tema:** 3, 4, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `satisfiable(F)` para fórmulas con `true`, `false`, `and`, `or` y `not`, donde las variables de la fórmula son variables de Prolog: Prolog busca una asignación que haga verdadera la fórmula.
- **Notas:** Une la lógica proposicional del curso con el backtracking. Complemento natural de AoP-3.5-2 a 3.5-5.

### AoP-P-7.2 — Fusión de listas ordenadas (adaptado del Programa 7.2 y 11.1–11.2)
- **Fuente:** Sterling & Shapiro, Programas 7.2 (p. 179), 11.1 (p. 231) y 11.2 (p. 233)
- **Tema:** 6, 7, 8
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `merge(Xs,Ys,Zs)` que fusiona dos listas ordenadas de enteros sin producir soluciones redundantes; después, agregarle cortes verdes y comparar.

### AoP-P-8.9 — Máximo de una lista (adaptado del Programa 8.9)
- **Fuente:** Sterling & Shapiro, Programa 8.9, p. 201
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `maxlist(Xs,M)` con acumulador. Variante: el producto interno de dos vectores (Programas 8.7a/b), recursivo e iterativo.

### AoP-P-11.6 — Negación por falla y reglas por defecto (adaptado de los Programas 11.6 y 11.11)
- **Fuente:** Sterling & Shapiro, Programas 11.6 (p. 239) y 11.11a/b (p. 248)
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con una base de pensiones (hechos `invalid/1`, `over_65/1`, `paid_up/1` y reglas `pension/2`), agregar el caso "no le corresponde nada". Hacerlo primero con cortes y un hecho por defecto, mostrar consultas que dan respuestas incorrectas (p. ej. preguntar quién cobra jubilación) y corregirlo con una relación nueva `entitlement/2` que use `\+`.
- **Notas:** El mejor ejemplo del libro de por qué los cortes rojos rompen la lectura lógica. Muy recomendable para la unidad 8.

### AoP-P-14.4 — Coloreo de mapas y acertijos lógicos (adaptado de los Programas 14.4–14.7)
- **Fuente:** Sterling & Shapiro, Programas 14.4 (p. 297), 14.6 y 14.7 (p. 300–301)
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir un coloreador de mapas por generar y probar (cada región con un color distinto al de sus vecinas) y resolver un acertijo lógico de pistas describiendo a las personas como estructuras dentro de una lista.
- **Notas:** Ver también AoP-14.1-3 y AoP-14.1-6.

### AoP-P-14.10 — Caminos en grafos con ciclos (adaptado de los Programas 14.8–14.10)
- **Fuente:** Sterling & Shapiro, Programas 14.8–14.10, p. 306–307
- **Tema:** 4, 6, 11
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Sobre hechos `edge/2`, escribir `connected/2` para un grafo acíclico y luego `path(X,Y,Camino)` que funcione también con ciclos, llevando la lista de nodos visitados.
- **Notas:** Continúa AoP-2.3-1 (`connected/2` del cap. 2) y muestra la no terminación con ciclos. Paralelo con consultas SQL recursivas.

### AoP-P-16.2 — Predicados de todas las soluciones sobre una base de datos (adaptado de los Programas 16.1 y 16.2)
- **Fuente:** Sterling & Shapiro, Programas 16.1 (p. 343) y 16.2 (p. 344)
- **Tema:** 9, 11
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Sobre una pequeña base de hechos (p. ej. `father/2`), obtener con `findall/3`, `bagof/3` y `setof/3` la lista de hijos de alguien, la de todos los padres y la de padres con sus hijos agrupados; comparar el comportamiento con variables libres y con `^`.
- **Notas:** Equivale a `SELECT … GROUP BY` en SQL: muy útil para la unidad 11.

### AoP-P-16.8 — `map_list` y `has_property` (adaptado del Programa 16.8)
- **Fuente:** Sterling & Shapiro, Programa 16.8 y Figura 16.4, p. 356–357
- **Tema:** 9
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `has_property(Xs,P)` (todos los elementos cumplen P) y `map_list(Xs,P,Ys)` usando `call/N`, y comparar con `maplist/2,3` de SWI.
- **Notas:** El libro usa `=..` o un `apply` propio; en SWI alcanza con `call(P,X)`.

### AoP-P-17.1 — Autómatas en Prolog (adaptado de los Programas 17.1–17.3)
- **Fuente:** Sterling & Shapiro, Programas 17.1–17.3 (p. 361–363)
- **Tema:** 1, 5, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir un intérprete de autómatas finitos no deterministas (hechos `initial/1`, `final/1`, `delta/3`) y usarlo con autómatas propios; luego extenderlo a autómatas de pila.
- **Notas:** Ver AoP-17.1-1 y 17.1-2.

### AoP-P-17.5 — Metaintérprete "vanilla" (adaptado del Programa 17.5)
- **Fuente:** Sterling & Shapiro, Programa 17.5, p. 365
- **Tema:** X (4)
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí (predicados interpretados declarados `:- dynamic`)
- **Enunciado:** Escribir `solve/1` con tres cláusulas (`true`, conjunción, y `clause/2` para el resto) y extenderlo para contar pasos de resolución.
- **Notas:** Cierre ideal del tema 4: el modelo de resolución escrito en el propio Prolog.

### AoP-P-19.6 — Gramática del castellano con DCG (adaptado de los Programas 19.6–19.8)
- **Fuente:** Sterling & Shapiro, Programas 19.6 (p. 424), 19.7 y 19.8 (p. 425–426)
- **Tema:** A
- **Dificultad:** 1–2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir una DCG para un fragmento del castellano (oración → sintagma nominal + sintagma verbal), luego agregar un argumento que construya el árbol sintáctico y otro para la concordancia de número.
- **Notas:** Probar con `phrase/2`. Continúa en AoP-19.3-1.

### AoP-P-20.2 — Problemas de cruce del río (adaptado de los Programas 20.1–20.3)
- **Fuente:** Sterling & Shapiro, Programas 20.1 (p. 431), 20.2 (p. 433) y 20.3 (p. 435)
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con el esquema de búsqueda en profundidad en espacio de estados (`move/2`, `update/3`, `legal/1`, historial de estados visitados), resolver el problema del lobo, la cabra y el repollo, y luego el de las jarras de agua.
- **Notas:** Prepara AoP-20.1-1 a 20.1-3.
