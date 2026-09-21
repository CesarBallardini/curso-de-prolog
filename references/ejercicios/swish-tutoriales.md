# SWISH: notebooks y ejemplos

- **Fuente:** material publicado en SWISH (https://swish.swi-prolog.org), de cuatro orígenes:
  1. **"Tutorial de prolog"** (notebook en castellano). Autor según los metadatos del notebook: Ramón Carreño Puertas (campo `author` de la última versión guardada; en SWISH, cualquier usuario puede hacer un *fork* y guardar, así que ese campo indica quién guardó, no necesariamente quién escribió el contenido original). URL: https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
  2. **"Prolog Intro Exercise Notebook"**, de Brandon Bennett (fechado 2024-11-11). URL: https://swish.swi-prolog.org/p/BB_Prolog_Intro.swinb
  3. **"An introduction to Prolog for SQL programers"**, de Robert Laing. URL: https://swish.swi-prolog.org/p/sql2prolog.swinb
  4. **Ejemplos y tutoriales oficiales de SWISH** (menú *Examples*): índice https://swish.swi-prolog.org/example/examples.swinb; tutoriales https://swish.swi-prolog.org/example/prolog_tutorials.swinb y https://swish.swi-prolog.org/example/swish_tutorials.swinb
- **Licencias:**
  - Ejemplos oficiales (grupo 4): forman parte del repositorio de SWISH (https://github.com/SWI-Prolog/swish, directorio `examples/`), bajo la licencia **BSD simplificada (2 cláusulas)**. Se pueden reutilizar y modificar citando la fuente. Algunos archivos llevan `@author` propio (R. A. O'Keefe en `eliza.pl` y `queens.pl`, M. Triska en `clpfd_queens.pl` y `clpfd_sudoku.pl`). El encabezado de `movies.pl` dice que sus ejercicios fueron "modificados de ejercicios encontrados en la web", sin autor conocido.
  - Notebooks de usuarios (grupos 1 a 3): son públicos en SWISH, pero **no declaran licencia**. Por eso los enunciados están parafraseados y resumidos en castellano, con atribución y enlace.
- **Soluciones:** las que están marcadas como verificadas se probaron con SWI-Prolog 9.2.9 local, copiando el código de las celdas.
- **Cómo arma SWISH el programa de una consulta** (según el tutorial oficial https://swish.swi-prolog.org/example/notebook.swinb): una consulta usa (a) todas las celdas de programa *globales* (ícono de globo, `data-background="true"`), (b) las celdas *below* que están por encima de ella y (c) la última celda *local* que está por encima, siempre que no haya otra celda de programa en el medio. Esto explica varios de los problemas del tutorial en castellano (ver SWISH-7 y SWISH-20).
- **Total:** 65 entradas (SWISH-1 a SWISH-65). Por dificultad: 1: 42, 2: 20, 3: 3.

**Cantidad por tema** (una entrada puede tener más de un tema):

| Tema | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | A | X |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Entradas | 4 | 7 | 14 | 7 | 7 | 5 | 14 | 11 | 8 | 8 | 3 | 18 | 1 | 7 |

---

## 1. "Tutorial de prolog" (castellano)

El notebook tiene 14 secciones: introducción, base de conocimiento, términos, expresiones, cláusulas, hechos, reglas, consultas, resolución, listas, pros y contras, aplicaciones, ejercicios y enlaces. **La sección "13. Ejercicios" está vacía.** El único ejercicio explícito es el del árbol n-ario (SWISH-21); las demás entradas convierten sus ejemplos en ejercicios de "predecir y verificar". Las imágenes del notebook (árboles, tabla de pros y contras) se cargan desde Dropbox.

### SWISH-1 — Cargar un programa con `consult/1`
- **Fuente:** "Tutorial de prolog", §2 Base de Conocimiento. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 0
- **Dificultad:** 1
- **Solución:** no corresponde.
- **SWISH:** no (en SWISH no hay archivos locales: el programa se escribe en celdas); sí en `swipl`
- **Enunciado:** Guardar una base de hechos en un archivo `.pl` y cargarla con `consult('nombre_archivo.pl').` (o `[nombre_archivo].`) antes de hacerle consultas.
- **Notas:** En `swipl` sobre Windows conviene usar `/` en las rutas, o bien `working_directory/2`. En SWISH, la celda `consult(...)` del notebook falla porque el archivo no existe en el servidor.

### SWISH-2 — Átomos, números y variables
- **Fuente:** "Tutorial de prolog", §3 Términos. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 1, 3
- **Dificultad:** 1
- **Solución:** verificada: todos los ejemplos (`luis`, `'pedro'`, `2`, `-5.0`, `2e10`, `X`, `_`, `_var`) son términos válidos. `2e10` se lee como el número de punto flotante `2.0e10`.
- **SWISH:** sí
- **Enunciado:** Con los ejemplos del notebook (`atomo(luis).`, `numero(1.54521).`, `variable(X).`, ...), clasificar cada término y comprobarlo con `atom/1`, `number/1`, `integer/1`, `float/1` y `var/1`.
- **Notas:** **Error conceptual en la fuente:** los "hechos" `variable(X).` y `variable(_).` no dicen que `X` sea una variable. Dicen que `variable/1` vale **para cualquier término**: `variable(hola)` y `variable(42)` dan true (verificado). SWI-Prolog además avisa *singleton variables* para `X`, `Variable` y `_var`. Conviene usar el ejemplo para enseñar que las variables de un hecho están cuantificadas universalmente.

### SWISH-3 — Estructuras: functor, aridad, argumentos
- **Fuente:** "Tutorial de prolog", §3 Términos (Estructuras). https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** propia: `padre(luis)` es `padre/1`, `edad(luis,30)` es `edad/2` y `color(X)` es `color/1` con un argumento variable. Se comprueba con `functor/3`.
- **SWISH:** sí
- **Enunciado:** Dar el functor, la aridad y los argumentos de `padre(luis)`, `edad(luis,30)` y `color(X)`.
- **Notas:** **Imprecisiones en la fuente:** (1) llama "átomo o functor" a los átomos y dice que "al nombre del átomo también se le llama predicado". En realidad el nombre de un término compuesto es su *functor* (nombre más aridad), y *predicado* es el conjunto de cláusulas con la misma cabeza `nombre/aridad`. (2) Como en SWISH-2, el hecho `color(X).` vuelve "color" a cualquier cosa.

### SWISH-4 — Operadores aritméticos y de comparación
- **Fuente:** "Tutorial de prolog", §4 Expresiones. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 3, 7
- **Dificultad:** 1
- **Solución:** verificada: `X is 10+2` da 12; `10+2 =:= 5+7`, `10+2 =\= 5+8`, `11*3 > 3^2`, `99.0 >= 0`, `-15 =< 15`, `10+2 == 10+2` y `10+2 \== 5+7` dan true; `2**10 < 5*2` da false; `bananon @> bananin`, `parse @< tree`, `ser @>= humano` y `raton @=< teclado` dan true.
- **SWISH:** sí
- **Enunciado:** Predecir el resultado de cada ejemplo de las tablas de operadores del notebook, con y sin evaluación, y verificarlo.
- **Notas:** La tabla del orden estándar de términos está incompleta. En SWI-Prolog el orden es Var < Number < Atom < String < Compound. Entre números se compara por valor, y ante igual valor el float va primero (`1.0 @< 1` da true, verificado). Llamar "Unificación" a `is` confunde: `is` **evalúa** el lado derecho y después unifica.

### SWISH-5 — Predicados de listas de la biblioteca
- **Fuente:** "Tutorial de prolog", §4 Expresiones (Operadores de listas). https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** autoverificable; por ejemplo, `sort([4,a,3],X)` da `X = [3,4,a]` (verificado) y `append(X,Y,[h,o,l,a])` da 5 soluciones.
- **SWISH:** sí
- **Enunciado:** Ejecutar y explicar los ejemplos de `=`, `member/2`, `append/3` (en sus cuatro modos), `length/2`, `sort/2` e `is_list/1` que da el notebook.
- **Notas:** `sort/2` además **elimina duplicados**, algo que el notebook no menciona. Para conservarlos está `msort/2`.

### SWISH-6 — Cláusulas de Horn con disyunción: `come/2`
- **Fuente:** "Tutorial de prolog", §5 Cláusulas. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** propia: la regla equivale a dos cláusulas, `come(A,B) :- carnivoro(A), animal(B), masDebil(B,A).` y `come(A,B) :- herbivoro(A), plantaComestible(B).`
- **SWISH:** sí
- **Enunciado:** Reescribir `come/2` (una sola regla con `;`) como dos cláusulas sin `;` y leerla en lenguaje natural.
- **Notas:** `,` liga más fuerte que `;`, así que no hacen falta paréntesis. Hay que distinguir hecho, regla y consulta, como hace la sección 5.

### SWISH-7 — Hechos: propiedades contra relaciones
- **Fuente:** "Tutorial de prolog", §6 Hechos y §8 Consultas. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 1
- **Dificultad:** 1
- **Solución:** no corresponde.
- **SWISH:** sí
- **Enunciado:** Con los hechos del notebook (`color(azul).`, `padre(juan).`, `padrede(juan,maria).`, `edad(juan,30).`, `amigos(pedro,antonio).`), hacer consultas cerradas (`padrede(juan,maria).`) y abiertas (`edad(X,30).`).
- **Notas:** **Inconsistencia en la fuente:** hay tres usos distintos de `padre`. La celda global `p24` define `padre/2` con el orden `padre(juan,alberto)`, que por los datos parece "el padre de juan es alberto"; la celda global `p5` define la propiedad `padre/1`; y la celda de §9 define `padre(pablo,juan)` con el orden contrario, "pablo es padre de juan". Como `p24` y `p5` son globales, se cargan en **todas** las consultas y se mezclan con los ejemplos. Arreglo: usar nombres distintos (`es_padre/1`, `padre_de/2`) y un solo orden de argumentos.

### SWISH-8 — Reglas: `hijode/2` y `abuelode/2`
- **Fuente:** "Tutorial de prolog", §7 Reglas. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** en el notebook (`hijode(A,B) :- padrede(B,A).` y `abuelode(A,B) :- padrede(A,C), padrede(C,B).`); con sus datos, `abuelode(pablo,maria)` da true (verificado).
- **SWISH:** sí
- **Enunciado:** Leer las dos reglas en lenguaje natural y consultar `hijode(X,juan)` y `abuelode(pablo,X)`.

### SWISH-9 — Conjunción: `hermano/2`
- **Fuente:** "Tutorial de prolog", §7 Reglas (Conjunciones). https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 2, 8
- **Dificultad:** 1
- **Solución:** propia, verificada: `hermano(X,Y) :- padrede(Z,X), padrede(Z,Y), X \== Y.`
- **SWISH:** sí
- **Enunciado:** Analizar la regla del notebook `hermano(X,Y) :- padre(Z), padrede(Z,X), padrede(Z,Y).` y corregirla.
- **Notas:** Tiene dos problemas: (1) la meta `padre(Z)` (`padre/1`) sobra, porque `padrede(Z,X)` ya implica que Z es padre; (2) sin `X \== Y`, todos resultan hermanos de sí mismos (con los datos del notebook, `hermano(maria,maria)` da true). Es el mismo defecto que LPN-10.5.

### SWISH-10 — Disyunción: `familiarde/2`
- **Fuente:** "Tutorial de prolog", §7 Reglas (Disyunciones). https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** verificada: tal como está, `familiarde(juan,X)` da `maria`, `pablo` y después **error** `existence_error(procedure, hermanode/2)`. Arreglo: definir `hermanode/2`, por ejemplo con la regla corregida de SWISH-9.
- **SWISH:** sí
- **Enunciado:** Consultar `familiarde(juan,X)` con la regla `familiarde(A,B) :- padrede(A,B); hijode(A,B); hermanode(A,B).`, explicar el error y corregirlo.
- **Notas:** Es un buen ejemplo para leer mensajes de error: el predicado `hermanode/2` nunca se definió (el notebook define `hermano/2`).

### SWISH-11 — Antecesor: versión "iterativa" contra recursiva
- **Fuente:** "Tutorial de prolog", §7 Reglas (Reglas recursivas). https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 5
- **Dificultad:** 1
- **Solución:** en el notebook: `antecesor_de(X,Y) :- padrede(X,Y).` y `antecesor_de(X,Y) :- padrede(X,Z), antecesor_de(Z,Y).`
- **SWISH:** sí
- **Enunciado:** Comparar la definición con una cláusula por generación (padre, abuelo, bisabuelo) con la definición recursiva, y explicar por qué la recursiva cubre cualquier cantidad de generaciones.
- **Notas:** Es el mismo esquema que `descend/2` de LPN cap. 3. Se puede agregar la variante recursiva por la izquierda para mostrar que no termina (LPN-3.1).

### SWISH-12 — Factorial
- **Fuente:** "Tutorial de prolog", §7 Reglas (Reglas recursivas). https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** propia, verificada: `factorial(0,1).` y `factorial(N,F) :- N > 0, N1 is N-1, factorial(N1,F1), F is N*F1.`
- **SWISH:** sí
- **Enunciado:** Consultar `factorial(4,Y)` y seguir la recursión con `trace`.
- **Notas:** **Error en la fuente:** la celda tiene el hecho `factorial(0, 1).` **duplicado**, así que `factorial(4,Y)` da `Y = 24` dos veces (verificado). La consulta además no termina en punto (`factorial(4, Y)`), algo que SWISH tolera.

### SWISH-13 — Resolución paso a paso: `hermano(juan,andres)`
- **Fuente:** "Tutorial de prolog", §9 Resolución de consultas, Ejemplo 1. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** en el notebook (desarrollo paso a paso); verificada: true.
- **SWISH:** sí (`trace, hermano(juan,andres).`)
- **Enunciado:** Con `padre(pablo,juan).`, `padre(pablo,andres).` y `hermano(A,B) :- padre(C,A), padre(C,B).`, seguir a mano la unificación y la resolución de `hermano(juan,andres)` y compararla con la traza.
- **Notas:** En SWISH esta consulta ve también los `padre/2` de la celda global `p24` (SWISH-7). La consulta abierta `hermano(X,Y)` da, entre otras, `alberto-alberto` (dos veces), `juan-juan` y `andres-andres` (verificado).

### SWISH-14 — Traza de un programa abstracto `p/q/r`
- **Fuente:** "Tutorial de prolog", §9, Ejemplo 2. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 3, 4
- **Dificultad:** 2
- **Solución:** verificada: `p(a,X)` da `X = b ; X = n(n(b,a),b)`.
- **SWISH:** sí
- **Enunciado:** Con el programa de abajo, predecir todas las respuestas de `p(a,X)` y comprobarlas con `trace`.
  ```prolog
  p(a, b).
  p(a, n(T, b)) :- q(_,b,a), r(T,b).
  q(c, b, a).
  q(a,b,c) :- r(g(a,b),d).
  r(n(b,a),b).
  ```
- **Notas:** Es un buen ejercicio de unificación con términos anidados.

### SWISH-15 — Traza de `come(X,Y)`
- **Fuente:** "Tutorial de prolog", §9, Ejemplo 3. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** verificada: `perro-conejo` y `conejo-lechuga`.
- **SWISH:** sí
- **Enunciado:** Con los hechos de animales (`animal/1`, `carnivoro/1`, `masDebil/2`, `herbivoro/1`, `plantaComestible/1`) y la regla `come/2` de SWISH-6, obtener todas las respuestas de `come(X,Y)` siguiendo la traza.

### SWISH-16 — Último elemento de una lista
- **Fuente:** "Tutorial de prolog", §10 Listas, Ejemplo 1. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** en el notebook (`ultimo([R],R).` y `ultimo([_|L],R) :- ultimo(L,R).`); `ultimo([a,[b,c],2],U)` da `U = 2`.
- **SWISH:** sí
- **Enunciado:** Definir `ultimo/2`, que da el último elemento de una lista.
- **Notas:** Igual a P99-01 y LPN-6.4.

### SWISH-17 — K-ésimo elemento (desde 0)
- **Fuente:** "Tutorial de prolog", §10 Listas, Ejemplo 2. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** en el notebook; verificada: `elemento_k([a,[b,c],2],2,E)` da `E = 2`.
- **SWISH:** sí
- **Enunciado:** Definir `elemento_k(Lista,K,E)` con la numeración empezando en 0.
- **Notas:** P99-03 numera desde 1 (como `nth1/3`); esta versión equivale a `nth0/3`. Conviene hacer notar la diferencia.

### SWISH-18 — Palíndromo con `reverse/2`
- **Fuente:** "Tutorial de prolog", §10 Listas, Ejemplo 3. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** en el notebook: `es_palindromo(L) :- reverse(L,L).`
- **SWISH:** sí
- **Enunciado:** Decidir si una lista es palíndromo.
- **Notas:** Igual a LPN-6.2 y P99-06.

### SWISH-19 — Máximo de una lista
- **Fuente:** "Tutorial de prolog", §10 Listas, Ejemplo 4. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** en el notebook; verificada: `max_list([0,5,80],M)` da `M = 80`.
- **SWISH:** sí
- **Enunciado:** Definir recursivamente el máximo de una lista no vacía de números.
- **Notas:** El nombre `max_list/2` coincide con el de `library(lists)`. En SWI-Prolog, la definición local tapa a la de la biblioteca sin avisar; conviene usar otro nombre (`maximo/2`). Con la lista vacía falla. La versión con acumulador es LPN §5.4.

### SWISH-20 — Árbol binario y sus tres recorridos
- **Fuente:** "Tutorial de prolog", §10 Listas, Ejemplo 5. https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 3, 5, 6
- **Dificultad:** 2
- **Solución:** en el notebook; verificada: con `mi_arbol_binario/1`, el preorden da `[6,4,2,5,9,7]`, el inorden `[2,4,5,6,7,9]` y el postorden `[2,5,4,7,9,6]`.
- **SWISH:** sí (con la salvedad de la nota)
- **Enunciado:** Con árboles `nil` / `t(Izq,Valor,Der)`, definir `es_arbol_binario/1`, `preorder/2`, `inorder/2` y `postorder/2`, y aplicarlos al árbol de ejemplo.
- **Notas:** El error "`mi_arbol_binario/1` no definido" se debe a cómo SWISH arma el programa. Localmente, la celda `p20` sí define `mi_arbol_binario/1` y la consulta `q10` está justo debajo, así que funciona. El error aparece si la consulta se ejecuta sin esa celda: si se la copia a otra celda o a `swipl`, o si queda otra celda de programa entre las dos. Arreglo robusto: poner los datos y los predicados en una celda *global*, o repetir el hecho en la celda de la consulta. Además, el nodo es `t(Izq,Valor,Der)`, distinto del `t(Valor,Izq,Der)` de P-99. Y `es_arbol_binario/1` no verifica el valor del nodo.

### SWISH-21 — Ejercicio: árbol n-ario y su preorden
- **Fuente:** "Tutorial de prolog", §10 Listas, "Ejercicio". https://swish.swi-prolog.org/p/Tutorial%20de%20prolog.swinb
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** en el notebook (árbol como lista `[Raiz|Hijos]`); verificada: `mi_arbol_n_ario(A), preorder(A,R)` da `R = [5,8,7,9,10,11,1]`.
- **SWISH:** sí
- **Enunciado:** Diseñar una representación para árboles n-arios y escribir su recorrido en preorden.
- **Notas:** La solución **reutiliza el nombre `preorder/2`** del ejemplo binario. En celdas locales separadas no molesta, pero si se juntan las dos en un archivo, SWI-Prolog avisa "Clauses of preorder/2 are not together" y el predicado mezcla las cláusulas de ambos tipos de árbol (verificado). Además, `es_arbol_n_ario([])` acepta la lista vacía como árbol. P-99 usa otra representación, `t(X,Bosque)` (ver P99-70B a P99-73).

## 2. "Prolog Intro Exercise Notebook" (Brandon Bennett)

Base usada en las entradas SWISH-22 a SWISH-27 (celda global del notebook):

```prolog
male(john). male(sirus). male(sam).
female(jill). female(mary).
parent_of(sirus,john). parent_of(john,mary). parent_of(mary,tom).
parent_of(mary,sue).   parent_of(john,sam).  parent_of(sam,jill).
grandfather_of(X,Y) :- male(X), parent_of(X,Z), parent_of(Z,Y).
sibling_of(X,Y) :- parent_of(Z,X), parent_of(Z,Y), \+ (X = Y).
```

### SWISH-22 — Consultas sobre la base familiar
- **Fuente:** Brandon Bennett, "Prolog Intro Exercise Notebook", §1 tarea (a). https://swish.swi-prolog.org/p/BB_Prolog_Intro.swinb
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** verificada: `grandfather_of(X,Y)` da `john-tom`, `john-sue`, `john-jill`, `sirus-mary` y `sirus-sam`.
- **SWISH:** sí
- **Enunciado:** Ejecutar y explicar `parent_of(mary,X)`, `parent_of(X,Y)`, `grandfather_of(X,sue)` y `grandfather_of(X,Y)`.
- **Notas:** El notebook también enseña el comentario `/** <examples> ... */`, que llena el menú *Examples* de SWISH (tema 0).

### SWISH-23 — Ampliar la base de hechos
- **Fuente:** Bennett, §1 tarea (b). https://swish.swi-prolog.org/p/BB_Prolog_Intro.swinb
- **Tema:** 1
- **Dificultad:** 1
- **Solución:** no corresponde.
- **SWISH:** sí (para guardar cambios hay que iniciar sesión y hacer *Fork*, como explica el notebook)
- **Enunciado:** Agregar personas y relaciones nuevas, incluidos hechos `married/2` u otros, y repetir las consultas anteriores.
- **Notas:** Faltan hechos `male/1` y `female/1` para `tom` y `sue`: conviene completarlos antes de hacer SWISH-24 a SWISH-27.

### SWISH-24 — Definir `mother_of/2`
- **Fuente:** Bennett, §1 tarea (c).1. https://swish.swi-prolog.org/p/BB_Prolog_Intro.swinb
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** propia, verificada: `mother_of(X,Y) :- female(X), parent_of(X,Y).` Da `mary-tom` y `mary-sue`.
- **SWISH:** sí
- **Enunciado:** Definir `mother_of/2` a partir de `female/1` y `parent_of/2`, y probarla.

### SWISH-25 — Definir `brother_of/2`
- **Fuente:** Bennett, §1 tarea (c).2. https://swish.swi-prolog.org/p/BB_Prolog_Intro.swinb
- **Tema:** 2, 8
- **Dificultad:** 1
- **Solución:** propia, verificada: `brother_of(X,Y) :- male(X), sibling_of(X,Y).` Da `sam-mary`.
- **SWISH:** sí
- **Enunciado:** Definir `brother_of/2` (X es hermano varón de Y).
- **Notas:** `sibling_of/2` ya usa `\+ (X = Y)`: es la negación por falla del tema 8, que va al final de la regla, cuando X e Y ya están ligadas.

### SWISH-26 — Definir `uncle_of/2`
- **Fuente:** Bennett, §1 tarea (c).3. https://swish.swi-prolog.org/p/BB_Prolog_Intro.swinb
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** propia, verificada: `uncle_of(X,Y) :- brother_of(X,Z), parent_of(Z,Y).` Da `sam-tom` y `sam-sue`.
- **SWISH:** sí
- **Enunciado:** Definir `uncle_of/2` (X es tío de Y) reutilizando `brother_of/2`.

### SWISH-27 — Definir `cousin_of/2`
- **Fuente:** Bennett, §1 tarea (c).4. https://swish.swi-prolog.org/p/BB_Prolog_Intro.swinb
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** propia, verificada: `cousin_of(X,Y) :- parent_of(P,X), parent_of(Q,Y), sibling_of(P,Q).` Da `tom-jill`, `sue-jill`, `jill-tom` y `jill-sue`.
- **SWISH:** sí
- **Enunciado:** Definir `cousin_of/2` (X e Y son primos).

### SWISH-28 — Explorar predicados de listas
- **Fuente:** Bennett, §2 "Matching and Manipulating Lists". https://swish.swi-prolog.org/p/BB_Prolog_Intro.swinb
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** no corresponde (exploración).
- **SWISH:** sí
- **Enunciado:** Probar las consultas del notebook con `member/2` (incluida la intersección `member(X,L1), member(X,L2)`), `append/3` para concatenar y partir, `nth1/3`, `last/2`, `length/2` (también `length(L,5)` y `length(L,N)`), `select/3` y `permutation/2`, y explicar cada resultado. Pregunta del notebook: ¿por qué se llama `nth1` y no `nth`?
- **Notas:** El notebook deja una celda de consulta rota (`select/3 is a predicate I`) que da error de sintaxis. `nth1(N,List,X)` con todo libre genera listas cada vez más largas sin terminar.

### SWISH-29 — `get_two/3` con `select/3`
- **Fuente:** Bennett, §2 (ejercicio `get_two`). https://swish.swi-prolog.org/p/BB_Prolog_Intro.swinb
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `get_two(L,X,Y) :- select(X,L,R), member(Y,R).` Con `[a,b,c,c]` da 12 pares (entre ellos `c-c`, dos veces); con `[a]` falla.
- **SWISH:** sí
- **Enunciado:** Usando `select/3`, definir `get_two(Lista,X,Y)`, que se cumple cuando X e Y son dos miembros de la lista; X e Y solo pueden ser iguales si ese elemento aparece dos o más veces. Probarlo, también con una lista de un solo elemento.
- **Notas:** **Inconsistencia en la fuente:** el enunciado pide `get_two(List,X,Y)`, pero las celdas de consulta del notebook lo llaman como `get_two(X,Y,[a,b,c,c])`, con la lista al final. Hay que elegir un orden y corregir las consultas.

### SWISH-30 — `mixup/4` y `allmixes/3`
- **Fuente:** Bennett, §2 (ejemplo `mixup`). https://swish.swi-prolog.org/p/BB_Prolog_Intro.swinb
- **Tema:** 6, 9
- **Dificultad:** 2
- **Solución:** en el notebook (código completo).
- **SWISH:** sí
- **Enunciado:** Leer y explicar `mixup/4`, que reparte los elementos de dos listas en otras dos de los mismos largos combinando `length/2`, `append/3` y `permutation/2`, y `allmixes/3`, que los junta con `setof/3`. Predecir cuántos resultados da `allmixes([angel,ghost,bird,dragon],[knife,fork,spoon],M)`.
- **Notas:** Es un buen ejemplo de "especificar en lugar de programar" y de lo caro que puede resultar (`permutation/2` es O(n!)).

### SWISH-31 — Cabeza y cola: `[H|T]`
- **Fuente:** Bennett, §3 "Heads and Tails". https://swish.swi-prolog.org/p/BB_Prolog_Intro.swinb
- **Tema:** 3, 6
- **Dificultad:** 1
- **Solución:** autoverificable.
- **SWISH:** sí
- **Enunciado:** Ejecutar `[H|T] = [head,followed,by,the,tail].`, `[H1,H2,H3|T] = [...]` y `List = [one,two,three], NewList = [zero|List].`, y explicar por qué `[one,two,three] = List, [zero|List] = NewList` da lo mismo.
- **Notas:** Muestra que `=` es unificación simétrica, no asignación.

### SWISH-32 — El corte: ¿el cianuro es seguro?
- **Fuente:** Bennett, §4 "The Cut Operator". https://swish.swi-prolog.org/p/BB_Prolog_Intro.swinb
- **Tema:** 4, 8
- **Dificultad:** 2
- **Solución:** en el notebook (versión con corte); verificada: sin corte, `alert(cyanide,C)` da `red` y también `green`, por lo que `safe(cyanide)` da **true**. Con `alert(X,Code) :- poison(X), !, Code = red.` (y lo mismo para `yellow`), `safe(cyanide)` da false.
- **SWISH:** sí
- **Enunciado:** Con el programa de abajo, explicar por qué `safe(cyanide)` tiene éxito y arreglarlo con cortes.
  ```prolog
  poison(cyanide).   flamable(oil).
  alert(X, red)    :- poison(X).
  alert(X, yellow) :- flamable(X).
  alert(_, green).
  safe(X) :- alert(X, green).
  ```
- **Notas:** Es un ejemplo excelente de la regla "salida después del corte": la versión corregida unifica `Code` **después** del `!`. Si se deja `alert(X,red) :- poison(X), !.`, la llamada `alert(cyanide,green)` salta la primera cláusula y el error vuelve.

## 3. "An introduction to Prolog for SQL programers" (Robert Laing)

El notebook traduce a Prolog las consultas SQL del curso de bases de datos de Stanford (Jennifer Widom, en edX), sobre tres tablas: `college(CName,State,Enrollment)`, `student(SID,SName,GPA,SizeHS)` y `apply(SID,CName,Major,Decision)`. Cada celda de consulta tiene la solución en Prolog. Como ejercicio, conviene mostrar solo el SQL y pedir la traducción. Todas las entradas usan los datos de la celda global del notebook y se verificaron localmente copiando esos datos.

### SWISH-33 — Selección y proyección
- **Fuente:** Robert Laing, "An introduction to Prolog for SQL programers", "Basic selection". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 1, 7, 11
- **Dificultad:** 1
- **Solución:** en el notebook; verificada: `student(SID,SName,GPA,_SizeHS), GPA > 3.6.` da 6 filas.
- **SWISH:** sí
- **Enunciado:** Traducir `select sID, sName, GPA from Student where GPA > 3.6;` y después la misma consulta sin mostrar GPA.
- **Notas:** El truco que se aprende: una variable que empieza con `_` (`_GPA`) conecta metas, pero SWISH no la muestra en la respuesta.

### SWISH-34 — Join y DISTINCT
- **Fuente:** Laing, "Table joins". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 2, 11
- **Dificultad:** 1
- **Solución:** en el notebook; verificada: `student(_ID,SName,_,_), apply(_ID,_,Major,_)` da 19 filas, y con `distinct([SName,Major], (...))` quedan 13.
- **SWISH:** sí
- **Enunciado:** Traducir el join entre Student y Apply por `sID`, primero con repetidos y después con `select distinct`.
- **Notas:** El join es simplemente **la misma variable** en las dos metas. `distinct/2` es de `library(solution_sequences)`.

### SWISH-35 — Join con condiciones
- **Fuente:** Laing, "Table joins" (sizeHS < 1000, CS, Stanford). https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 7, 11
- **Dificultad:** 1
- **Solución:** en el notebook; verificada: da `Helen 3.7 Y` e `Irene 3.9 N`.
- **SWISH:** sí
- **Enunciado:** Nombre, GPA y decisión de los estudiantes con sizeHS < 1000 que se postularon a CS en Stanford.

### SWISH-36 — Campus grandes con postulantes a CS
- **Fuente:** Laing, "Table joins". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 11
- **Dificultad:** 1
- **Solución:** en el notebook; verificada: `Berkeley` y `Cornell`.
- **SWISH:** sí
- **Enunciado:** Traducir `select distinct College.cName ... where enrollment > 20000 and major = 'CS'`.

### SWISH-37 — ORDER BY
- **Fuente:** Laing, "order by". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 9, 11
- **Dificultad:** 2
- **Solución:** en el notebook: `order_by([desc(GPA)], Goal)` y `order_by([desc(GPA), asc(Enrollment)], Goal)`.
- **SWISH:** sí
- **Enunciado:** Traducir un join de tres tablas ordenado por GPA descendente y, como desempate, por inscripción ascendente.
- **Notas:** `order_by/2` es de `library(solution_sequences)`. La alternativa clásica es `findall/3` más `sort/4`.

### SWISH-38 — LIKE con `sub_atom/5`
- **Fuente:** Laing, "Searching for substrings". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 11
- **Dificultad:** 1
- **Solución:** en el notebook; verificada: `apply(SID,_,Major,_), sub_atom(Major,_,_,_,bio)` da 5 filas.
- **SWISH:** sí
- **Enunciado:** Traducir `where major like '%bio%'`.
- **Notas:** Hace falta conocer `sub_atom/5`, que va más allá del núcleo del curso.

### SWISH-39 — Columna calculada
- **Fuente:** Laing, "Arithmetic Functions". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 7, 11
- **Dificultad:** 1
- **Solución:** en el notebook: `student(SID,SName,GPA,SizeHS), ScaledGPA is GPA*(SizeHS/1000).`
- **SWISH:** sí
- **Enunciado:** Traducir `select ..., GPA*(sizeHS/1000.0) as scaledGPA from Student;`.

### SWISH-40 — Self-join
- **Fuente:** Laing, "Self joins". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 11
- **Dificultad:** 1
- **Solución:** en el notebook; verificada: 8 pares.
- **SWISH:** sí
- **Enunciado:** Pares de estudiantes con el mismo GPA (`S1.sID < S2.sID`).
- **Notas:** En SQL se usan dos alias de la misma tabla; en Prolog, dos metas `student/4` con distintas variables y la misma para GPA.

### SWISH-41 — UNION, INTERSECT y EXCEPT
- **Fuente:** Laing, "Union", "Intersection", "Except". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 2, 8, 11
- **Dificultad:** 2
- **Solución:** en el notebook; verificada: la unión con `;`; la intersección con `,` (con `distinct` da `[123,345]`); la diferencia con `\+`: `apply(SID,_,'CS',_), \+ apply(SID,_,'EE',_)`.
- **SWISH:** sí
- **Enunciado:** Traducir la unión de nombres de colegios y estudiantes, los que se postularon a CS **y** a EE, y los que se postularon a CS **pero no** a EE.
- **Notas:** Muestra la correspondencia unión ↔ `;`, intersección ↔ `,` y diferencia ↔ `\+`. La diferencia devuelve repetidos (987 aparece dos veces).

### SWISH-42 — Subconsultas IN, EXISTS y NOT EXISTS
- **Fuente:** Laing, "Subqueries in the where clause". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 8, 9, 11
- **Dificultad:** 2
- **Solución:** en el notebook; verificada: el colegio más grande, `college(C,_,E1), \+ (college(_,_,E2), E2 > E1)`, da `Berkeley`.
- **SWISH:** sí
- **Enunciado:** Traducir (a) estudiantes que se postularon a CS (`in`), (b) colegios con otro colegio en el mismo estado (`exists`) y (c) el colegio más grande (`not exists`).
- **Notas:** El notebook resuelve (a) y (b) con `findall/3` más `memberchk/2`; basta con un join y `distinct`. El patrón de (c), máximo como "no existe uno mayor", es un clásico de la negación por falla.

### SWISH-43 — Subconsulta en FROM
- **Fuente:** Laing, "Subqueries in the from clause". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 7, 11
- **Dificultad:** 1
- **Solución:** en el notebook; verificada: 7 estudiantes con |scaledGPA − GPA| > 1.
- **SWISH:** sí
- **Enunciado:** Estudiantes cuyo GPA escalado difiere del GPA en más de 1.
- **Notas:** En Prolog la "tabla derivada" es solo una conjunción más.

### SWISH-44 — Subconsulta en SELECT (máximo GPA por colegio)
- **Fuente:** Laing, "Subqueries in the select clause". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 9, 11
- **Dificultad:** 2
- **Solución:** **la del notebook es incorrecta:** compara el GPA del postulante con el de **todos** los estudiantes, no con el de los postulantes a ese colegio. Con los datos originales el resultado coincide por casualidad (todos tienen un postulante con 3.9). Si se agrega `college('Rice','TX',4000)` y `apply(789,'Rice','CS','Y')`, Rice no aparece (verificado). Versión correcta, verificada: `college(C,_,_), aggregate_all(max(G), (apply(S,C,_,_), student(S,_,G,_)), Max).`
- **SWISH:** sí
- **Enunciado:** Para cada colegio, dar el mayor GPA entre sus postulantes.
- **Notas:** Es un buen ejercicio de "encontrar el error": hace falta un caso de prueba que distinga las dos lecturas.

### SWISH-45 — Inner, natural y three-way join
- **Fuente:** Laing, "Inner Join", "Three-way Inner Join", "Natural Join With Additional Conditions". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 11
- **Dificultad:** 1
- **Solución:** en el notebook.
- **SWISH:** sí
- **Enunciado:** Traducir las variantes `inner join ... on`, `natural join`, `join ... using` y un join de las tres tablas.
- **Notas:** En Prolog todas se escriben igual: la sintaxis de SQL cambia, pero la consulta lógica es la misma.

### SWISH-46 — Outer joins y `null`
- **Fuente:** Laing, "Left Outer Join", "Right Outer Join", "Full Outer Join". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 8, 10, 11
- **Dificultad:** 2
- **Solución:** en el notebook: una regla por caso, con `\+` para las filas sin pareja, y `assertz/1` para agregar postulaciones de un SID inexistente.
- **SWISH:** sí
- **Enunciado:** Incluir estudiantes que no se postularon (left join), postulaciones sin estudiante (right join) y ambos casos (full join), usando el átomo `null`.
- **Notas:** `null` es un átomo común, sin semántica especial. En SWISH, los `assertz` hechos en una celda `:-` duran solo esa consulta.

### SWISH-47 — Agregación: AVG, MIN y COUNT (DISTINCT)
- **Fuente:** Laing, "Aggregation". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 9, 11
- **Dificultad:** 2
- **Solución:** en el notebook; verificada: el promedio de GPA da 3.5666...; cuántos estudiantes se postularon a Cornell, con `aggregate_all(count, SID, apply(SID,'Cornell',_,_), N)`, da 3, y sin discriminador da 6.
- **SWISH:** sí
- **Enunciado:** Traducir el promedio de GPA, el mínimo GPA de los postulantes a CS, el promedio sin repetidos, la cantidad de colegios con más de 15000 alumnos y `count(distinct sID)` para Cornell.
- **Notas:** Es la misma trampa que en SQL: sin el discriminador se cuentan postulaciones, no estudiantes. `aggregate_all/3,4` es de `library(aggregate)`.

### SWISH-48 — GROUP BY y HAVING
- **Fuente:** Laing, "group by queries", "having". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 9, 11
- **Dificultad:** 2
- **Solución:** en el notebook; verificada: colegios con menos de 5 postulaciones: `Berkeley` (3) y `MIT` (4).
- **SWISH:** sí
- **Enunciado:** Traducir conteos por colegio, mínimo y máximo GPA por colegio y carrera, conteos por estudiante (incluidos los ceros) y filtros `having count(*) < 5`.
- **Notas:** El patrón es enumerar primero el grupo (`college(C,_,_)`) y después agregar con `aggregate_all/3`. Así los grupos vacíos dan 0, lo que en SQL requiere una unión aparte.

### SWISH-49 — `null` y comparaciones
- **Fuente:** Laing, "null". https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 3, 7, 11
- **Dificultad:** 2
- **Solución:** en el notebook: filtrar con `number(GPA), GPA > 3.5`, o comparar con `@>` en el orden estándar.
- **SWISH:** sí
- **Enunciado:** Después de insertar estudiantes con GPA `null`, listar los que tienen GPA > 3.5 sin que la consulta dé error.
- **Notas:** `null > 3.5` lanza un error de tipo: los átomos no se evalúan. Es una buena ocasión para ver la diferencia entre comparación aritmética y comparación de términos.

### SWISH-50 — Insertar y borrar filas
- **Fuente:** Laing, "Data Modification" (insert, delete). https://swish.swi-prolog.org/p/sql2prolog.swinb
- **Tema:** 9, 10, 11
- **Dificultad:** 2
- **Solución:** en el notebook: `assertz/1` dentro de `forall/2` para `insert ... select`, y `retract/1` dentro de `forall/2` para `delete`.
- **SWISH:** sí (los cambios duran solo una consulta)
- **Enunciado:** Traducir la inserción de un colegio nuevo, la postulación masiva de quienes no se postularon a ningún lado, la admisión en EE de los rechazados en EE, y el borrado de los estudiantes que se postularon a más de dos carreras.
- **Notas:** Las tablas deben declararse `:- dynamic college/3, student/4, apply/4.`

## 4. Ejemplos y tutoriales oficiales de SWISH

Casi todos son programas de demostración, con consultas sugeridas en un comentario `/** <examples> ... */`. Las entradas los convierten en consignas de exploración o de modificación. El único que trae ejercicios explícitos es `movies.pl` (SWISH-53 y SWISH-54).

### SWISH-51 — Primera base de conocimiento: `kb.pl`
- **Fuente:** SWISH, ejemplo "Knowledge bases" (menú *Examples* → *First steps*). https://swish.swi-prolog.org/example/kb.pl
- **Tema:** 1, 2, 8
- **Dificultad:** 1
- **Solución:** verificada: `jealous(X,Y)` da 6 pares, entre ellos `vincent-vincent` y `pumpkin-pumpkin`.
- **SWISH:** sí
- **Enunciado:** Ejecutar `loves(X,mia)` y `jealous(X,Y)` sobre los cuatro hechos `loves/2`, explicar por qué aparecen personas celosas de sí mismas y corregir `jealous/2`.
- **Notas:** Es KB5 de LPN cap. 1; la corrección es LPN-10.5 (`X \== Y`).

### SWISH-52 — Sublistas y *naive reverse*: `lists.pl`
- **Fuente:** SWISH, ejemplo "Lists". https://swish.swi-prolog.org/example/lists.pl
- **Tema:** 0, 6
- **Dificultad:** 2
- **Solución:** no corresponde (exploración).
- **SWISH:** sí
- **Enunciado:** Con `suffix/2`, `prefix/2` y `sublist/2` definidos mediante `append/3`, y con `nrev/2`, ejecutar las consultas sugeridas, explicar por qué `sublist(Xs,Ys)` con ambos argumentos libres no termina, y medir `nrev` sobre 1000 elementos con `time/1`.
- **Notas:** Complementa LPN-PS6.1. El `time/1` muestra las inferencias: *naive reverse* es cuadrático.

### SWISH-53 — Base de películas: consultas
- **Fuente:** SWISH, ejemplo "Movie database", comentario "EXERCISES, Part 1". https://swish.swi-prolog.org/example/movies.pl
- **Tema:** 1, 2, 7
- **Dificultad:** 1
- **Solución:** en el mismo archivo (bloque `<examples>`, que el autor sugiere borrar antes de dárselo a los estudiantes); verificada: `movie(american_beauty,Y)` da 1999; hay 3 películas del año 2000; la película con John Goodman y Jeff Bridges es `the_big_lebowski`.
- **SWISH:** sí
- **Enunciado:** Sobre una base con miles de hechos `movie/2`, `director/2`, `actor/3` y `actress/3`, escribir consultas para responder nueve preguntas: año de estreno de *American Beauty*, películas de 2000, anteriores a 2000, posteriores a 1990, un actor con más de una película, un director de una película con Scarlett Johansson, un actor que también dirigió, un actor o actriz que también dirigió, y la película en la que coinciden John Goodman y Jeff Bridges.
- **Notas:** Es la mejor práctica de consultas conjuntivas con variables compartidas que hay en estas fuentes. Sirve de puente al tema 11: cada predicado es una tabla.

### SWISH-54 — Base de películas: reglas
- **Fuente:** SWISH, `movies.pl`, "EXERCISES, Part 2". https://swish.swi-prolog.org/example/movies.pl
- **Tema:** 2, 7, 8
- **Dificultad:** 1
- **Solución:** propia, verificada: `released_after(M,Y) :- movie(M,Y1), Y1 > Y.` (y lo mismo para `released_before/2`), `same_year(M1,M2) :- movie(M1,Y), movie(M2,Y), M1 \== M2.` y `co_star(A1,A2) :- performer(M,A1), performer(M,A2), A1 \== A2.`, con `performer(M,A) :- actor(M,A,_) ; actress(M,A,_).`
- **SWISH:** sí
- **Enunciado:** Agregar cuatro reglas a la base: `released_after/2`, `released_before/2`, `same_year/2` y `co_star/2` (dos intérpretes que trabajaron en la misma película).
- **Notas:** El comentario del archivo reconoce que los ejercicios fueron "modificados de ejercicios encontrados en la web", sin autor conocido.

### SWISH-55 — `assert` y `retract`: `database.pl`
- **Fuente:** SWISH, ejemplo "Assert and retract". https://swish.swi-prolog.org/example/database.pl
- **Tema:** 9, 10
- **Dificultad:** 1
- **Solución:** no corresponde.
- **SWISH:** sí
- **Enunciado:** Ejecutar `assert_and_retract`, que agrega `p(1)`...`p(10)` y los retira imprimiéndolos, y `assert_many/1` con tamaños crecientes. Explicar el uso de `forall/2` y observar el límite de memoria de SWISH.
- **Notas:** La consulta `assert_many(1 000 000)` usa dígitos separados por espacio, una sintaxis propia de SWI-Prolog 7+.

### SWISH-56 — Lectura y escritura: `io.pl`
- **Fuente:** SWISH, ejemplo "Read and write". https://swish.swi-prolog.org/example/io.pl
- **Tema:** 0, X
- **Dificultad:** 1
- **Solución:** no corresponde.
- **SWISH:** sí (SWISH muestra un cuadro para `read/1`)
- **Enunciado:** Ejecutar `read_and_write`, que lee términos hasta leer `stop` y los reimprime, y `hello_world`, que imprime sin fin cada segundo y hay que detenerlo. Explicar cómo termina cada uno.
- **Notas:** Muestra la estructura `( Cond -> Then ; Else )` y la recursión como bucle.

### SWISH-57 — Metaintérprete y sistema experto: `expert_system.pl`
- **Fuente:** SWISH, ejemplo "Expert system". https://swish.swi-prolog.org/example/expert_system.pl
- **Tema:** 4, X
- **Dificultad:** 3
- **Solución:** no corresponde.
- **SWISH:** sí
- **Enunciado:** Ejecutar `prove(good_pet(tweety))`, que pregunta al usuario los hechos "askable", y explicar cómo `prove/1` reproduce la resolución de Prolog usando `clause/2`.
- **Notas:** Queda fuera del alcance del curso, pero es un gran ejemplo para mostrar que el mecanismo de resolución del tema 4 cabe en cuatro cláusulas.

### SWISH-58 — Eliza: `eliza.pl`
- **Fuente:** SWISH, ejemplo "Eliza" (R. A. O'Keefe, *The Craft of Prolog*). https://swish.swi-prolog.org/example/eliza.pl
- **Tema:** 6, X
- **Dificultad:** 2
- **Solución:** verificada: `eliza([i,am,very,hungry],R)` da `[why,are,you,very,hungry,?]` y `eliza([i,love,you],R)` da `[why,do,you,love,me,?]`.
- **SWISH:** sí
- **Enunciado:** Ejecutar las consultas de ejemplo y agregar plantillas nuevas a `template/2`, por ejemplo para "i feel ...".
- **Notas:** Muestra el emparejamiento de patrones sobre listas con `append/3`.

### SWISH-59 — Gramática del inglés con árbol: `grammar.pl`
- **Fuente:** SWISH, ejemplo "English grammar". https://swish.swi-prolog.org/example/grammar.pl
- **Tema:** A
- **Dificultad:** 2
- **Solución:** verificada: `phrase(s(T),[john,saw,a,man,with,a,telescope])` da **2** árboles, porque la oración es ambigua.
- **SWISH:** sí (SWISH dibuja el árbol en SVG)
- **Enunciado:** Analizar la oración de ejemplo, explicar por qué hay dos análisis, generar oraciones con `phrase(s(_),S)` y extender el léxico.
- **Notas:** Es un modelo terminado de lo que piden LPN-8.1 y LPN-PS8.2: concordancia de número y construcción del árbol.

### SWISH-60 — Acertijo de Einstein (cebra): `houses_puzzle.pl`
- **Fuente:** SWISH, ejemplo "Einstein's Riddle". https://swish.swi-prolog.org/example/houses_puzzle.pl
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** en el mismo archivo; verificada: `zebra_owner(O)` da `japanese` y `water_drinker(W)` da `norwegian`.
- **SWISH:** sí (SWISH muestra la solución como tabla)
- **Enunciado:** Leer cómo se codifica cada una de las 15 pistas con `member/2`, `next/3` y unificación con patrones de lista, y resolver el acertijo.
- **Notas:** Es la versión completa de LPN-6.6. En el comentario, la pista 7 dice "serpent" y el código usa `snake`, lo que no afecta al resultado.

### SWISH-61 — N reinas con backtracking: `queens.pl`
- **Fuente:** SWISH, ejemplo "N-Queens (traditional)" (R. A. O'Keefe). https://swish.swi-prolog.org/example/queens.pl
- **Tema:** 4, X
- **Dificultad:** 3
- **Solución:** en el mismo archivo.
- **SWISH:** sí (dibuja el tablero)
- **Enunciado:** Ejecutar `queens(8,Qs)` y compararlo con la solución de P99-90.
- **Notas:** La técnica de O'Keefe (variables compartidas en términos `functor/3` y `arg/3`) es avanzada; conviene usarlo solo como demostración.

### SWISH-62 — N reinas y sudoku con CLP(FD)
- **Fuente:** SWISH, ejemplos "N-Queens (clp(fd))" y "Sudoku (clp(fd))" (M. Triska). https://swish.swi-prolog.org/example/clpfd_queens.pl y https://swish.swi-prolog.org/example/clpfd_sudoku.pl
- **Tema:** X
- **Dificultad:** 3
- **Solución:** en los mismos archivos.
- **SWISH:** sí
- **Enunciado:** Resolver 8, 24 y 100 reinas con `n_queens/2` más `labeling/2`, y el sudoku de ejemplo. Comparar los tiempos con P99-90 y P99-97.
- **Notas:** La programación con restricciones está fuera del alcance del curso; sirve para mostrar hacia dónde sigue Prolog.

### SWISH-63 — Caballeros y bribones con CLP(B)
- **Fuente:** SWISH, ejemplo "Knights and Knaves (clp(b))". https://swish.swi-prolog.org/example/knights_and_knaves.pl
- **Tema:** X
- **Dificultad:** 2
- **Solución:** en el mismo archivo; verificada: ejemplo 1: `A = 1, B = 1`; ejemplo 2: `A = 0, B = 0`; ejemplo 3: `A = 1, B = 0`; ejemplo 4: `[0,1,0]`; ejemplo 5: `C = 0`.
- **SWISH:** sí
- **Enunciado:** Cada habitante es caballero (siempre dice la verdad) o bribón (siempre miente). Con `sat/1` de `library(clpb)`, modelar lo que dice cada uno (por ejemplo, "A dice: o yo soy bribón o B es caballero") y deducir quién es qué.
- **Notas:** Vale la pena para la parte de lógica proposicional de la materia: cada enunciado se modela como `A =:= Formula`, es decir, el que habla es caballero si y solo si lo que dice es verdad. Los acertijos son de R. Smullyan.

### SWISH-64 — *Tabling*: Fibonacci y recursión por la izquierda
- **Fuente:** SWISH, tutorial "Using tabling in SWI-Prolog" (menú *Prolog tutorials*). https://swish.swi-prolog.org/example/tabling.swinb
- **Tema:** 5, X
- **Dificultad:** 2
- **Solución:** en el notebook.
- **SWISH:** sí
- **Enunciado:** Comparar con `time/1` el Fibonacci ingenuo contra el mismo código con `:- table fib/2.`, y ver que con *tabling* la relación `connection/2`, recursiva por la izquierda y simétrica, termina.
- **Notas:** Resuelve de otra manera el problema de no terminación de LPN-3.1 y LPN-PS3.1, y la memorización manual de LPN-11.3.

### SWISH-65 — Cómo arma SWISH el programa de cada consulta
- **Fuente:** SWISH, tutorial "How is the program assembled for a specific query?" (menú *SWISH tutorials*). https://swish.swi-prolog.org/example/notebook.swinb
- **Tema:** 0
- **Dificultad:** 1
- **Solución:** no corresponde.
- **SWISH:** sí
- **Enunciado:** Cambiar el tipo de las celdas de programa (global, below, local) del notebook y observar, con la línea azul que SWISH marca a la izquierda, qué celdas se cargan para cada consulta.
- **Notas:** Es imprescindible antes de trabajar con notebooks: explica los problemas de SWISH-7 y SWISH-20.
