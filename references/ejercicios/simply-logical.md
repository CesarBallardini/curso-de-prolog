# Simply Logical: *Intelligent Reasoning by Example* (edición interactiva en línea)

- **Fuente:** Peter Flach, *Simply Logical: Intelligent Reasoning by Example* (Wiley, 1994). Edición interactiva en línea de Peter Flach y Kacper Sokol, con celdas SWISH incrustadas.
- **URL:** https://book.simply-logical.space (índice: https://book.simply-logical.space/src/simply-logical.html). Código fuente: https://github.com/simply-logical/simply-logical (los enunciados están en `src/ex/*.md` y el código en `src/code/*.pl`).
- **Licencia:** CC BY-NC-SA 4.0 (archivo `LICENCE` del repositorio). Se permite adaptar con atribución, sin fines comerciales y compartiendo bajo la misma licencia. Aun así, los enunciados de este banco están parafraseados en castellano.
- **Soluciones:** el Apéndice C, *Answers to selected exercises*, resuelve 41 de los 73 ejercicios: https://book.simply-logical.space/src/text/appendices/c_0.html (subpáginas `c_1.html` a `c_9.html`, una por capítulo).
- **SWISH:** el libro trae los programas listos en celdas SWISH; cada entrada indica si el ejercicio es de programar o de papel (árboles de prueba o SLD).
- **Total:** 73 ejercicios. Los capítulos 1 y 3 son los más útiles para el curso; el 2 es teoría de lógica clausal; del 4 al 9 son temas de IA, casi todos fuera de alcance.

**Cantidad por tema** (un ejercicio puede tener más de un tema):

| Tema | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | A | X |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ejercicios | 0 | 1 | 1 | 5 | 20 | 7 | 7 | 4 | 8 | 3 | 1 | 0 | 4 | 34 |

URL base de las secciones: `https://book.simply-logical.space/src/text/<parte>/<sección>.html`, por ejemplo `.../1_part_i/1.3.html`.

---

## Parte I, Capítulo 1: A brief introduction to clausal logic

### SL-1.1 — Estaciones "no demasiado lejos"
- **Fuente:** Flach & Sokol, cap. 1 (introducción), Ejercicio 1.1. https://book.simply-logical.space/src/text/1_part_i/1.0.html
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** no está en el Apéndice C. Propia, verificada sobre los hechos `connected/3` del libro:
  ```prolog
  not_too_far(X, Y) :- connected(X, Y, _).
  not_too_far(X, Y) :- connected(X, Z, _), connected(Z, Y, _).
  ```
- **SWISH:** sí (celda `swish:1.0.4` con el esqueleto del predicado)
- **Enunciado:** Sobre el mapa del metro de Londres, `connected(Est1, Est2, Línea)`, definir `not_too_far/2`: dos estaciones están "no demasiado lejos" si hay a lo sumo una estación entre ellas, sin importar la línea.
- **Notas:** Se diferencia de `nearby/2` del libro en que no exige que ambos tramos sean de la misma línea. Por eso se reemplaza la variable compartida `L` por dos anónimas.

### SL-1.2 — Árboles de prueba para `nearby`
- **Fuente:** Flach & Sokol, sección 1.1, Ejercicio 1.2. https://book.simply-logical.space/src/text/1_part_i/1.1.html
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.1: https://book.simply-logical.space/src/text/appendices/c_1.html (seis respuestas)
- **SWISH:** no (se dibuja en papel; se puede comprobar la consulta en SWISH)
- **Enunciado:** Dibujar los árboles de prueba de `?- nearby(W, charing_cross).`

### SL-1.3 — Otro árbol de prueba y el orden de los hechos
- **Fuente:** Flach & Sokol, sección 1.2, Ejercicio 1.3. https://book.simply-logical.space/src/text/1_part_i/1.2.html
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (para comprobar qué respuesta sale primero)
- **Enunciado:** Dar un tercer árbol de prueba para la respuesta `W = leicester_square` de `reachable(bond_street, W)` y reordenar los hechos `connected/3` para que Prolog construya ese árbol antes que los otros.
- **Notas:** Muestra que el orden de las cláusulas determina el orden de las respuestas.

### SL-1.4 — Listas, listas pares y listas impares
- **Fuente:** Flach & Sokol, sección 1.3, Ejercicio 1.4. https://book.simply-logical.space/src/text/1_part_i/1.3.html
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.1 (verificada):
  ```prolog
  list([]).
  list([_First|Rest]) :- list(Rest).
  evenlist([]).
  evenlist([_First,_Second|Rest]) :- evenlist(Rest).
  oddlist([_First|Rest]) :- evenlist(Rest).
  ```
- **SWISH:** sí
- **Enunciado:** Definir `list/1`, que reconozca listas a partir de su definición recursiva, y adaptarlo para que acepte solo listas de longitud par y solo listas de longitud impar.

### SL-1.5 — Rutas con al menos dos estaciones intermedias
- **Fuente:** Flach & Sokol, sección 1.3, Ejercicio 1.5. https://book.simply-logical.space/src/text/1_part_i/1.3.html
- **Tema:** 1, 6
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.1 (verificada): `?- reachable(bond_street, piccadilly_circus, [S1,S2|Rest]).`
- **SWISH:** sí
- **Enunciado:** Con `reachable/3`, que devuelve la lista de estaciones intermedias, escribir una consulta que pida rutas de Bond Street a Piccadilly Circus con al menos dos estaciones intermedias.
- **Notas:** Se resuelve con un patrón de lista en la consulta, sin programar nada nuevo.

---

## Parte I, Capítulo 2: Clausal logic and resolution: theoretical backgrounds

### SL-2.1 — Traducir enunciados a cláusulas (proposicional)
- **Fuente:** Flach & Sokol, sección 2.1, Ejercicio 2.1. https://book.simply-logical.space/src/text/1_part_i/2.1.html
- **Tema:** X
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.2: https://book.simply-logical.space/src/text/appendices/c_2.html
- **SWISH:** no (lógica clausal general, con disyunción en la cabeza)
- **Enunciado:** Traducir a cláusulas, con los átomos `person`, `sad` y `happy`, cuatro enunciados como "las personas son felices o tristes" y "nadie es feliz y triste a la vez".
- **Notas:** Sirve de puente con la parte de lógica del curso. Algunas cláusulas no son de Horn.

### SL-2.2 — Consecuencia lógica en un programa proposicional
- **Fuente:** Flach & Sokol, sección 2.1, Ejercicio 2.2.
- **Tema:** X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.2
- **SWISH:** no
- **Enunciado:** Dado un programa con la cláusula indefinida `married;bachelor:-man,adult.`, decidir cuáles de cuatro cláusulas son consecuencia lógica suya.

### SL-2.3 — Interpretaciones de Herbrand que no son modelos
- **Fuente:** Flach & Sokol, sección 2.1, Ejercicio 2.3.
- **Tema:** X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.2
- **SWISH:** no
- **Enunciado:** Para el programa `married;bachelor:-man,adult.  has_wife:-man,married.`, que tiene 26 modelos, escribir las seis interpretaciones de Herbrand que no son modelos.

### SL-2.4 — Derivación por resolución
- **Fuente:** Flach & Sokol, sección 2.1, Ejercicio 2.4.
- **Tema:** 4, X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.2
- **SWISH:** no
- **Enunciado:** Derivar `friendly` por resolución a partir de un programa proposicional de cuatro cláusulas, dos de ellas indefinidas.

### SL-2.5 — Prueba por refutación
- **Fuente:** Flach & Sokol, sección 2.1, Ejercicio 2.5.
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.2
- **SWISH:** no
- **Enunciado:** Demostrar por refutación que `friendly:-has_friends` se deduce de `happy:-has_friends` y `friendly:-happy`.

### SL-2.6 — Contar modelos sobre un universo de Herbrand
- **Fuente:** Flach & Sokol, sección 2.2, Ejercicio 2.6. https://book.simply-logical.space/src/text/1_part_i/2.2.html
- **Tema:** X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.2
- **SWISH:** no
- **Enunciado:** Contar cuántos modelos tiene la cláusula `likes(peter,S):-student_of(S,peter)` sobre el universo de Herbrand {`peter`, `maria`}.

### SL-2.7 — Resolución con una cláusula nueva
- **Fuente:** Flach & Sokol, sección 2.2, Ejercicio 2.7.
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.2
- **SWISH:** no
- **Enunciado:** Escribir una cláusula que diga que Peter enseña todos los cursos de primer año y aplicarle resolución junto con el resolvente obtenido en el texto.

### SL-2.8 — Árbol de prueba para una respuesta
- **Fuente:** Flach & Sokol, sección 2.2, Ejercicio 2.8.
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí (programa `swish:2.2.8` para comprobar la respuesta)
- **Enunciado:** Para el programa en el que a Peter le gustan sus alumnos y las personas que a ellos les gustan, dibujar el árbol de prueba de la respuesta `N = paul` a `?- likes(peter, N).`

### SL-2.9 — Traducir a lógica clausal con cuantificadores
- **Fuente:** Flach & Sokol, sección 2.3, Ejercicio 2.9. https://book.simply-logical.space/src/text/1_part_i/2.3.html
- **Tema:** X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.2
- **SWISH:** no
- **Enunciado:** Traducir a lógica clausal "todo ratón tiene cola", "alguien ama a todos" y "todo par de números tiene un máximo".
- **Notas:** Obliga a introducir funciones de Skolem.

### SL-2.10 — Universo de Herbrand de `listlength`
- **Fuente:** Flach & Sokol, sección 2.3, Ejercicio 2.10.
- **Tema:** 3, X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.2
- **SWISH:** sí (el programa está en `swish:2.3.2`)
- **Enunciado:** Determinar el universo de Herbrand del programa `listlength/2`, que relaciona una lista con su longitud en notación `s(...)`, recordando que `[]` es una constante y `[X|Y]` es un término con functor binario.
  ```prolog
  listlength([], 0).
  listlength([_X|Y], s(L)) :- listlength(Y, L).
  ```

### SL-2.11 — Unificar pares de términos
- **Fuente:** Flach & Sokol, sección 2.3, Ejercicio 2.11.
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.2
- **SWISH:** sí (se puede comprobar con `=` y con `unify_with_occurs_check/2`)
- **Enunciado:** Unificar, si es posible, tres pares de términos. El tercer par solo "unifica" si no se hace el *occurs check*.
  ```prolog
  plus(X,Y,s(Y))          y  plus(s(V),W,s(s(V)))
  length([X|Y],s(0))      y  length([V],V)
  larger(s(s(X)),X)       y  larger(V,s(V))
  ```

### SL-2.12 — Árboles de prueba de tres derivaciones
- **Fuente:** Flach & Sokol, sección 2.4, Ejercicio 2.12. https://book.simply-logical.space/src/text/1_part_i/2.4.html
- **Tema:** 4, X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no
- **Enunciado:** Dibujar los árboles de prueba de las tres cláusulas que el texto deriva por resolución, por ejemplo `married(peter);bachelor(peter)`.

### SL-2.13 — "Inocente hasta que se pruebe lo contrario"
- **Fuente:** Flach & Sokol, sección 2.4, Ejercicio 2.13.
- **Tema:** X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.2
- **SWISH:** no
- **Enunciado:** Escribir una cláusula para "alguien es inocente salvo que se pruebe su culpa" y dar su modelo pretendido, suponiendo que `john` es el único individuo.
- **Notas:** Anticipa la negación por fallo y la hipótesis de mundo cerrado.

### SL-2.14 — De fórmulas de primer orden a cláusulas
- **Fuente:** Flach & Sokol, sección 2.5, Ejercicio 2.14. https://book.simply-logical.space/src/text/1_part_i/2.5.html
- **Tema:** X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.2
- **SWISH:** no
- **Enunciado:** Pasar a forma clausal las versiones formales, con cuantificadores, de las tres frases del ejercicio 2.9.

---

## Parte I, Capítulo 3: Logic Programming and Prolog

### SL-3.1 — Árboles de prueba de las ramas exitosas
- **Fuente:** Flach & Sokol, sección 3.1, Ejercicio 3.1. https://book.simply-logical.space/src/text/1_part_i/3.1.html
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no
- **Enunciado:** Dibujar los árboles de prueba correspondientes a las dos ramas exitosas del árbol SLD de la figura 3.1.

### SL-3.2 — Un árbol SLD infinito
- **Fuente:** Flach & Sokol, sección 3.1, Ejercicio 3.2.
- **Tema:** 4, 5
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.3: https://book.simply-logical.space/src/text/appendices/c_3.html
- **SWISH:** sí (celda `swish:2.3.2_3`)
- **Enunciado:** Dibujar el árbol SLD de `?- list(L).` para el programa de abajo.
  ```prolog
  list([]).
  list([_H|T]) :- list(T).
  ```
- **Notas:** Si se invierten las cláusulas, Prolog no da ninguna respuesta. Es un buen ejemplo de un árbol infinito con infinitas respuestas.

### SL-3.3 — Podar con corte en un árbol SLD
- **Fuente:** Flach & Sokol, sección 3.2, Ejercicio 3.3. https://book.simply-logical.space/src/text/1_part_i/3.2.html
- **Tema:** 4, 8
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.3
- **SWISH:** sí (celda `swish:3.2.ex3.3_2`)
- **Enunciado:** Dibujar el árbol SLD de `?- likes(A, B).`, agregar un corte que elimine una de las respuestas `A = peter, B = maria` y analizar si se puede hacer sin perder la tercera respuesta.
  ```prolog
  likes(peter, Y) :- friendly(Y).
  likes(T, S) :- student_of(S, T).
  student_of(maria, peter).
  student_of(paul, peter).
  friendly(maria).
  ```

### SL-3.4 — Un corte rojo en `max/3`
- **Fuente:** Flach & Sokol, sección 3.3, Ejercicio 3.4. https://book.simply-logical.space/src/text/1_part_i/3.3.html
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Mostrar, con un árbol SLD en el que se poda una rama exitosa, que el corte de esta versión de `max/3` es rojo.
  ```prolog
  max(M, N, M) :- M >= N, !.
  max(_M, N, N).
  ```
- **Notas:** El texto muestra además que `?- max(5, 3, 3).` tiene éxito, lo cual es incorrecto. Es el ejemplo clásico de un corte que cambia el significado del programa.

### SL-3.5 — `bachelor` con negación por fallo
- **Fuente:** Flach & Sokol, sección 3.3, Ejercicio 3.5.
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.3
- **SWISH:** sí (`swish:3.3.3`)
- **Enunciado:** Dibujar los árboles SLD de `?- bachelor(fred).` y `?- bachelor(peter).` para el programa de abajo.
  ```prolog
  bachelor(X) :- not(married(X)), man(X).
  man(fred).  man(peter).  married(fred).
  ```

### SL-3.6 — Orden de los objetivos y negación
- **Fuente:** Flach & Sokol, sección 3.3, Ejercicio 3.6.
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.3
- **SWISH:** sí (`swish:3.3.3a`)
- **Enunciado:** Con la versión corregida, en la que `man(X)` va antes de `not(married(X))`, mostrar con el árbol SLD de `?- bachelor(X).` que ahora la respuesta es correcta.
- **Notas:** Es la regla práctica de que el argumento de `\+` tiene que estar instanciado (*ground*) cuando se lo llama.

### SL-3.7 — Objetivos que se prueban dos veces
- **Fuente:** Flach & Sokol, sección 3.4, Ejercicio 3.7. https://book.simply-logical.space/src/text/1_part_i/3.4.html
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.3
- **SWISH:** sí (con `trace` se ve que `q` y `r` se ejecutan dos veces)
- **Enunciado:** Mostrar que `?- p.` tiene éxito, pero que `q` y `r` se prueban dos veces.
  ```prolog
  p :- q, r, s, !, t.
  p :- q, r, u.
  q.  r.  u.
  ```

### SL-3.8 — Si-entonces-si-no con un predicado auxiliar
- **Fuente:** Flach & Sokol, sección 3.4, Ejercicio 3.8.
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.3
- **SWISH:** sí
- **Enunciado:** Con la versión que usa un predicado auxiliar `if_s_then_t_else_u/0`, mostrar que ahora `q` y `r` se prueban una sola vez.
- **Notas:** Sirve de base para presentar `( C -> T ; E )`.

### SL-3.9 — Raíces de una ecuación cuadrática
- **Fuente:** Flach & Sokol, sección 3.5, Ejercicio 3.9. https://book.simply-logical.space/src/text/1_part_i/3.5.html
- **Tema:** 7
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.3, **pero tiene un error de precedencia**: escribe `/ 2*A`, que se lee `(… / 2) * A`. Versión corregida y verificada (con A=2, B=-6, C=4 da 2.0 y 1.0; la versión del libro da 8.0):
  ```prolog
  zero(A, B, C, X) :- X is (-B + sqrt(B*B - 4*A*C)) / (2*A).
  zero(A, B, C, X) :- X is (-B - sqrt(B*B - 4*A*C)) / (2*A).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir `zero(A, B, C, X)`, que calcule las dos soluciones de ax² + bx + c = 0, una por cada respuesta.
- **Notas:** Sirve para discutir la precedencia de operadores en `is/2` y la conveniencia de poner paréntesis.

### SL-3.10 — Árbol de prueba de `naive_length`
- **Fuente:** Flach & Sokol, sección 3.6, Ejercicio 3.10. https://book.simply-logical.space/src/text/1_part_i/3.6.html
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.3
- **SWISH:** sí (`swish:3.6.0`)
- **Enunciado:** Dibujar el árbol de prueba de `?- naive_length([a,b,c], N).`, la versión en la que el `is` va después de la llamada recursiva.
- **Notas:** El resolvente crece con la profundidad: la recursión no es de cola.

### SL-3.11 — Árbol de prueba con acumulador
- **Fuente:** Flach & Sokol, sección 3.6, Ejercicio 3.11.
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.3
- **SWISH:** sí (`swish:3.6.1`)
- **Enunciado:** Dibujar el árbol de prueba de `?- length_acc([a,b,c], N).` y compararlo con el del ejercicio anterior.

### SL-3.12 — Árbol de prueba de `naive_reverse`
- **Fuente:** Flach & Sokol, sección 3.6, Ejercicio 3.12.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí (`swish:3.6.2`)
- **Enunciado:** Dibujar el árbol de prueba de `?- naive_reverse([a,b,c], R).`
- **Notas:** Hace visible el costo cuadrático de las llamadas a `append/3`.

### SL-3.13 — Del `reverse` ingenuo a listas diferencia
- **Fuente:** Flach & Sokol, sección 3.6, Ejercicio 3.13.
- **Tema:** 6, X
- **Dificultad:** 3
- **Solución:** sí, Apéndice C.3
- **SWISH:** sí
- **Enunciado:** Reescribir `naive_reverse` representando el resultado como lista diferencia, usar `append_dl` en lugar de `append` y mostrar que, al desplegar `append_dl`, se obtiene `reverse_dl`.
- **Notas:** Las listas diferencia exceden un curso inicial.

### SL-3.14 — `rel/3` con `=..`
- **Fuente:** Flach & Sokol, sección 3.7, Ejercicio 3.14. https://book.simply-logical.space/src/text/1_part_i/3.7.html
- **Tema:** 3, 9
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.3 (verificada):
  ```prolog
  rel(_R, [], []).
  rel(R, [X|Xs], [Y|Ys]) :- Goal =.. [R, X, Y], call(Goal), rel(R, Xs, Ys).
  ```
- **SWISH:** sí
- **Enunciado:** Reescribir el predicado de segundo orden `rel/3` (que aplica una relación binaria a pares de elementos de dos listas) usando `=..` para construir el objetivo, en lugar de la notación `R(X,Y)`.
- **Notas:** En SWI-Prolog alcanza con `call(R, X, Y)`; `rel/3` es en esencia `maplist/3`.

### SL-3.15 — Ordenar y quitar duplicados con `setof`
- **Fuente:** Flach & Sokol, sección 3.7, Ejercicio 3.15.
- **Tema:** 9
- **Dificultad:** 1
- **Solución:** sí, Apéndice C.3 (verificada): `sort(List, Sorted) :- setof(X, element(X, List), Sorted).`, con `element/2` equivalente a `member/2`.
- **SWISH:** sí (conviene cambiar el nombre, porque `sort/2` es un predicado predefinido)
- **Enunciado:** Escribir, con `setof/3`, un programa que ordene una lista y le quite los duplicados.
- **Notas:** Con la lista vacía, `setof/3` falla en lugar de devolver `[]`. Es un detalle clásico.

### SL-3.16 — Árbol SLD de un metaprograma
- **Fuente:** Flach & Sokol, sección 3.8, Ejercicio 3.16. https://book.simply-logical.space/src/text/1_part_i/3.8.html
- **Tema:** X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (`swish:3.8.2`)
- **Enunciado:** Dibujar el árbol SLD de `?- derive(if tweety then is_bird).` para el metaprograma `derive/1`, que razona sobre reglas `if ... then ...`.

### SL-3.17 — Árbol SLD del metaintérprete `prove/1`
- **Fuente:** Flach & Sokol, sección 3.8, Ejercicio 3.17.
- **Tema:** 4, X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dibujar el árbol SLD de `?- prove(is_bird(X)).` para cuatro cláusulas sobre `tweety`, usando el metaintérprete `prove/1`, que se apoya en `clause/2`.

### SL-3.18 — Permutaciones con la metodología de la sección 3.9
- **Fuente:** Flach & Sokol, sección 3.9, Ejercicio 3.18. https://book.simply-logical.space/src/text/1_part_i/3.9.html
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.3, con `insert_somewhere/3`. **Cuidado:** tal como la da el apéndice, con `insert_somewhere` antes de la llamada recursiva, `permutation([1,2,3], P)` devuelve una sola respuesta y después no termina (verificado). Con la llamada recursiva primero da las 6 permutaciones y termina:
  ```prolog
  permutation([], []).
  permutation([H|T], P) :- permutation(T, P0), insert_somewhere(H, P0, P).
  insert_somewhere(X, L, [X|L]).
  insert_somewhere(X, [H|T], [H|R]) :- insert_somewhere(X, T, R).
  ```
- **SWISH:** sí (conviene renombrarlo, porque `permutation/2` es de biblioteca)
- **Enunciado:** Implementar `permutation(L, P)` siguiendo los cinco pasos del método: especificación, argumentos, esqueleto, cuerpos y salidas. Hace falta un predicado auxiliar.

### SL-3.19 — Quicksort con `partition/4`
- **Fuente:** Flach & Sokol, sección 3.9, Ejercicio 3.19.
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.3 (verificada)
- **SWISH:** sí (`partition/4` está en `swish:3.9.1`)
- **Enunciado:** Usando `partition/4` (separa los menores y los mayores o iguales que un pivote), implementar un método de ordenamiento alternativo al de inserción: quicksort.

---

## Parte II, Capítulo 4: Representing structured knowledge

### SL-4.1 — Dibujar el árbol que representa un término
- **Fuente:** Flach & Sokol, sección 4.1, Ejercicio 4.1. https://book.simply-logical.space/src/text/2_part_ii/4.1.html
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** no (el Apéndice C.4 solo dice que estos ejercicios "no deberían presentar mayores dificultades")
- **SWISH:** no (es un dibujo)
- **Enunciado:** Dibujar el árbol que representa el término `n1(n2(n4),n3(n5,n6))`.
- **Notas:** Ayuda a ver los términos compuestos como árboles.

### SL-4.2 — Construir un término árbol
- **Fuente:** Flach & Sokol, sección 4.1, Ejercicio 4.2.
- **Tema:** 3
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dar un término `Tree` que contenga el árbol del ejercicio 4.1 y tal que `?- term_path(Tree, Path).` tenga entre sus respuestas `Path = [n1,n2,n7,n8]`.

### SL-4.3 — Orden en que se encuentran los caminos
- **Fuente:** Flach & Sokol, sección 4.1, Ejercicio 4.3.
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Explicar el orden en que el programa de caminos en árboles del texto devuelve sus respuestas.

### SL-4.4 — Árbol SLD de `path/1`
- **Fuente:** Flach & Sokol, sección 4.2, Ejercicio 4.4. https://book.simply-logical.space/src/text/2_part_ii/4.2.html
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no
- **Enunciado:** Dibujar el árbol SLD de `?- path([n1|Path]).` para el grafo definido con `arc/2` en el texto.

### SL-4.5 — Árbol SLD de la versión alternativa
- **Fuente:** Flach & Sokol, sección 4.2, Ejercicio 4.5.
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no
- **Enunciado:** Dibujar el árbol SLD de la misma consulta para la versión alternativa de `path` que presenta el texto.

### SL-4.6 — Árbol SLD de un grafo generado por un predicado
- **Fuente:** Flach & Sokol, sección 4.2, Ejercicio 4.6.
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no
- **Enunciado:** Esbozar el árbol SLD de `?- br(paul, B).` para la definición de "hermano" del texto.

### SL-4.7 — Herencia múltiple
- **Fuente:** Flach & Sokol, sección 4.3, Ejercicio 4.7. https://book.simply-logical.space/src/text/2_part_ii/4.3.html
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar una estrategia de herencia múltiple para las jerarquías de herencia de la sección.

---

## Parte II, Capítulo 5: Searching graphs

### SL-5.1 — Reconstruir el camino en la búsqueda en profundidad
- **Fuente:** Flach & Sokol, sección 5.2, Ejercicio 5.1. https://book.simply-logical.space/src/text/2_part_ii/5.2.html
- **Tema:** 4, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Modificar `search_df_loop/3` para que, además de encontrar el objetivo, devuelva el camino que lleva hasta él.

### SL-5.2 — Escribir un árbol por niveles
- **Fuente:** Flach & Sokol, sección 5.3, Ejercicio 5.2. https://book.simply-logical.space/src/text/2_part_ii/5.3.html
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar `term_write_bf/1`, que escriba un árbol desde la raíz hacia abajo, con búsqueda en anchura y dos agendas: una para el nivel n y otra para el nivel n+1.

### SL-5.3 — `prove_bf` frente a Prolog con `brother/2`
- **Fuente:** Flach & Sokol, sección 5.3, Ejercicio 5.3.
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.5: https://book.simply-logical.space/src/text/appendices/c_5.html
- **SWISH:** sí
- **Enunciado:** Comparar cómo resuelven `?- brother(peter, adrian).` el metaintérprete en anchura y Prolog, y averiguar si algún reordenamiento de las cláusulas hace que Prolog tenga éxito.
  ```prolog
  brother(peter, paul).
  brother(adrian, paul).
  brother(X, Y) :- brother(Y, X).
  brother(X, Y) :- brother(X, Z), brother(Z, Y).
  ```
- **Notas:** Muestra que la búsqueda en profundidad de Prolog es incompleta cuando hay recursión a izquierda o simetría.

### SL-5.4 — Metaintérprete que devuelve árboles de prueba
- **Fuente:** Flach & Sokol, sección 5.3, Ejercicio 5.4.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Extender el metaintérprete en anchura para que devuelva un árbol de prueba, guardando en la agenda un árbol parcial junto con cada objetivo.

### SL-5.5 — Modelos restantes (encadenamiento hacia adelante)
- **Fuente:** Flach & Sokol, sección 5.4, Ejercicio 5.5. https://book.simply-logical.space/src/text/2_part_ii/5.4.html
- **Tema:** X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.5
- **SWISH:** no
- **Enunciado:** Dar los modelos del programa de la sección que `model/1` no construye (el texto muestra los dos mínimos).

### SL-5.6 — ¿`model/1` encuentra todos los modelos mínimos?
- **Fuente:** Flach & Sokol, sección 5.4, Ejercicio 5.6.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** sí, Apéndice C.5
- **SWISH:** no
- **Enunciado:** Decidir si el procedimiento de encadenamiento hacia adelante `model/1` construye siempre todos los modelos mínimos.

---

## Parte II, Capítulo 6: Informed search

### SL-6.1 — Mezclar hijos ordenados con la agenda
- **Fuente:** Flach & Sokol, sección 6.1, Ejercicio 6.1. https://book.simply-logical.space/src/text/2_part_ii/6.1.html
- **Tema:** 6, X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.6: https://book.simply-logical.space/src/text/appendices/c_6.html
- **SWISH:** sí
- **Enunciado:** Si `children/2` ya devuelve los hijos ordenados, escribir `merge/3`, que los mezcle directamente con la agenda ordenada.
- **Notas:** Aislado del contexto de búsqueda, es un buen ejercicio de listas: mezclar dos listas ordenadas.

### SL-6.2 — Heurística sin predicados de segundo orden
- **Fuente:** Flach & Sokol, sección 6.1, Ejercicio 6.2.
- **Tema:** 5, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reescribir `bLeftOfw/2`, que cuenta soluciones con `findall/3` y `length/2`, usando solo predicados de primer orden.

### SL-6.3 — Algoritmo A para el problema de las fichas
- **Fuente:** Flach & Sokol, sección 6.2, Ejercicio 6.3. https://book.simply-logical.space/src/text/2_part_ii/6.2.html
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Convertir el programa `tiles` en un algoritmo A que use el costo acumulado g, y mostrar que la búsqueda se vuelve menos eficiente.

### SL-6.4 — Una heurística demasiado pesimista
- **Fuente:** Flach & Sokol, sección 6.2, Ejercicio 6.4.
- **Tema:** X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.6
- **SWISH:** no
- **Enunciado:** Encontrar una posición del problema de las fichas para la cual la tercera heurística sobrestima el costo, es decir, no es admisible.

### SL-6.5 — Metaintérprete con búsqueda A
- **Fuente:** Flach & Sokol, sección 6.2, Ejercicio 6.5.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar un metaintérprete de Prolog con búsqueda A usando h(R) = número de literales del resolvente, y discutir si la heurística es admisible y monótona.

### SL-6.6 — Búsqueda en haz
- **Fuente:** Flach & Sokol, sección 6.3, Ejercicio 6.6. https://book.simply-logical.space/src/text/2_part_ii/6.3.html
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Extender el programa del ejercicio 6.3 con búsqueda en haz (agenda de tamaño fijo) y mostrar que deja de ser óptima.

---

## Parte III, Capítulo 7: Reasoning with natural language

### SL-7.1 — Árbol sintáctico como árbol de prueba SLD
- **Fuente:** Flach & Sokol, sección 7.1, Ejercicio 7.1. https://book.simply-logical.space/src/text/3_part_iii/7.1.html
- **Tema:** A, 4
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.7: https://book.simply-logical.space/src/text/appendices/c_7.html
- **SWISH:** no
- **Enunciado:** Redibujar un árbol sintáctico como árbol de prueba SLD, donde los "resolventes" son oraciones parcialmente analizadas y las "cláusulas" son reglas de la gramática.

### SL-7.2 — Espacio de búsqueda del análisis descendente
- **Fuente:** Flach & Sokol, sección 7.1, Ejercicio 7.2.
- **Tema:** A, 4
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.7
- **SWISH:** no
- **Enunciado:** Dibujar el espacio de búsqueda del análisis descendente de izquierda a derecha para la gramática de la sección, y compararlo con los árboles SLD.

### SL-7.3 — DCG para expresiones horarias
- **Fuente:** Flach & Sokol, sección 7.2, Ejercicio 7.3. https://book.simply-logical.space/src/text/3_part_iii/7.2.html
- **Tema:** A
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí (SWISH soporta DCG y `phrase/2`)
- **Enunciado:** Escribir una DCG que analice expresiones como "twenty minutes to four" y las convierta en términos como `3:40`.

### SL-7.4 — Agregar interpretación a reglas DCG
- **Fuente:** Flach & Sokol, sección 7.3, Ejercicio 7.4. https://book.simply-logical.space/src/text/3_part_iii/7.3.html
- **Tema:** A
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.7
- **SWISH:** sí
- **Enunciado:** Agregar a dos reglas de la gramática (`verb_phrase` y `transitive_verb` para *likes*) argumentos que construyan su interpretación lógica.

### SL-7.5 — Bucle guiado por fallo con `repeat`
- **Fuente:** Flach & Sokol, sección 7.3, Ejercicio 7.5.
- **Tema:** 10, 8
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no del todo: SWISH no tiene entrada interactiva por consola, y un bucle con `repeat` y `read/1` conviene hacerlo en `swipl` local
- **Enunciado:** Reescribir el intérprete interactivo `nl_shell/1`, hecho con recursión mutua, como bucle guiado por fallo con `repeat`, guardando los cambios en la base de reglas con `assert/1` y `retract/1`.
  ```prolog
  shell :- repeat, get_input(X), handle_input(X).
  handle_input(stop) :- !.
  handle_input(X) :- /* procesar X */ fail.
  ```
- **Notas:** Es de los pocos ejercicios del libro sobre la base de datos dinámica (tema 10).

---

## Parte III, Capítulo 8: Reasoning with incomplete information

### SL-8.1 — Modelos de un programa con excepción
- **Fuente:** Flach & Sokol, sección 8.1, Ejercicio 8.1. https://book.simply-logical.space/src/text/3_part_iii/8.1.html
- **Tema:** X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.8: https://book.simply-logical.space/src/text/appendices/c_8.html
- **SWISH:** no
- **Enunciado:** Dar los modelos del programa de Tweety el avestruz, interpretando la cláusula general como indefinida, y señalar cuál es el modelo pretendido.

### SL-8.2 — Modelos de P (mundo cerrado)
- **Fuente:** Flach & Sokol, sección 8.2, Ejercicio 8.2. https://book.simply-logical.space/src/text/3_part_iii/8.2.html
- **Tema:** X
- **Dificultad:** 2
- **Solución:** sí, Apéndice C.8
- **SWISH:** no
- **Enunciado:** Dar todos los modelos del programa P de la sección y compararlos con el único modelo de CWA(P).

### SL-8.3 — Compleción de predicados
- **Fuente:** Flach & Sokol, sección 8.2, Ejercicio 8.3.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** sí, Apéndice C.8
- **SWISH:** no
- **Enunciado:** Aplicar la compleción de predicados (*Predicate Completion*) al programa de la sección.

### SL-8.4 — Metaintérprete abductivo que no entra en bucle
- **Fuente:** Flach & Sokol, sección 8.3, Ejercicio 8.4. https://book.simply-logical.space/src/text/3_part_iii/8.3.html
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Modificar el metaintérprete abductivo para que `?- abduce(teacher(peter), E).` no entre en bucle con un programa que tiene recursión a través de la negación, agregando a la explicación todos los literales reunidos en la prueba.

### SL-8.5 — Árboles SLD con reglas por defecto
- **Fuente:** Flach & Sokol, sección 8.4, Ejercicio 8.5. https://book.simply-logical.space/src/text/3_part_iii/8.4.html
- **Tema:** 4, 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (para comprobar las respuestas)
- **Enunciado:** Dibujar los árboles SLD de `?- flies(X).` y `?- notflies(X).` para el programa de mamíferos, murciélagos y Drácula de la sección.

### SL-8.6 — Abducción sin las dos últimas cláusulas
- **Fuente:** Flach & Sokol, sección 8.4, Ejercicio 8.6.
- **Tema:** X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Quitar las dos últimas cláusulas del programa y volver a calcular las respuestas de `abduce(flies(X), E)` y `abduce(notflies(X), E)`.

---

## Parte III, Capítulo 9: Inductive reasoning

### SL-9.1 — `induce/3` con una lista de ejemplos
- **Fuente:** Flach & Sokol, cap. 9 (introducción), Ejercicio 9.1. https://book.simply-logical.space/src/text/3_part_iii/9.0.html
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Modificar `induce/3` para que trabaje con una lista de ejemplos y deje las cláusulas de la hipótesis sin instanciar, de modo que una misma cláusula pueda explicar varios ejemplos.

### SL-9.2 — Cobertura extensional
- **Fuente:** Flach & Sokol, sección 9.1, Ejercicio 9.2. https://book.simply-logical.space/src/text/3_part_iii/9.1.html
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `covers_ex/3`, que decida si una cláusula cubre extensionalmente un ejemplo dada una lista de ejemplos positivos.

### SL-9.3 — θ-LGG de dos cláusulas
- **Fuente:** Flach & Sokol, sección 9.1, Ejercicio 9.3.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** sí, Apéndice C.9: https://book.simply-logical.space/src/text/appendices/c_9.html
- **SWISH:** no
- **Enunciado:** Calcular la generalización menos general (θ-LGG) de dos cláusulas `reverse/3` dadas en el libro.

### SL-9.4 — Aprender `reverse/3` con acumulador
- **Fuente:** Flach & Sokol, sección 9.2, Ejercicio 9.4. https://book.simply-logical.space/src/text/3_part_iii/9.2.html
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Proponer otro criterio para excluir cláusulas tautológicas en la inducción y mostrar que con él se puede aprender `reverse/3` con acumulador.

### SL-9.5 — Búsqueda en haz para la inducción descendente
- **Fuente:** Flach & Sokol, sección 9.3, Ejercicio 9.5. https://book.simply-logical.space/src/text/3_part_iii/9.3.html
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Reemplazar la profundización iterativa de la inducción descendente por búsqueda en haz.
