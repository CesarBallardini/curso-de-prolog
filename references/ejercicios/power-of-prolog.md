# Triska: *The Power of Prolog*

- **Fuente:** Markus Triska, *The Power of Prolog*, libro en línea (desde 2005, se sigue actualizando).
- **URL:** https://www.metalevel.at/prolog. Fuente HTML: https://codeberg.org/triska/the-power-of-prolog
- **Licencia:** © 2005–2026 Markus Triska. El sitio y el repositorio no declaran una licencia abierta, así que el uso es solo como referencia: los enunciados de abajo están parafraseados en castellano y el texto completo está en el enlace de cada entrada.
- **Naturaleza:** no es un libro de ejercicios numerados. Este archivo reúne (a) los ejercicios y desafíos que el texto propone explícitamente ("Exercise", "left as an exercise", "Challenge") y (b) tareas tipo ejercicio que salen de los ejemplos: puzzles, programas de muestra y ejemplos que el autor invita a analizar. Cada entrada aclara de cuál de los dos tipos es.
- **Dialecto:** el libro usa Scryer Prolog (`library(clpz)` y `double_quotes` = `chars`). En SWI-Prolog y SWISH hacen falta dos ajustes: `:- use_module(library(clpfd)).` en lugar de `clpz`, y `:- set_prolog_flag(double_quotes, chars).` (o comillas invertidas) para que `"abc"` sea una lista y no un *string*. Verificado: sin ese ajuste, `list_length("abcd", N)` falla en SWI-Prolog.
- **Soluciones:** el libro no las publica. Las soluciones cortas de abajo son propias y se verificaron con SWI-Prolog 9.2.9 y `library(clpfd)`.
- **Total:** 26 entradas.

**Cantidad por tema** (un ejercicio puede tener más de un tema):

| Tema | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | A | X |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ejercicios | 0 | 0 | 2 | 4 | 6 | 9 | 8 | 6 | 1 | 0 | 0 | 0 | 2 | 13 |

---

## Conceptos básicos, aritmética y terminación

### POP-01 — Explorar la secuencia de Collatz
- **Fuente:** Triska, *Basic Concepts*, "Example: Collatz conjecture". https://www.metalevel.at/prolog/concepts#collatz
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** 2, 5, 7
- **Dificultad:** 2
- **Solución:** verificada: `?- hailstone(3, N).` da, por backtracking, 3, 10, 5, 16, 8, 4, 2, 1, 4, …
- **SWISH:** sí (con `library(clpfd)`)
- **Enunciado:** Cargar el predicado `hailstone/2`, que relaciona un número con los que le siguen en la secuencia de Collatz, y probar consultas en varias direcciones, incluida la más general `?- hailstone(X, Y).`, para interpretar las respuestas.
  ```prolog
  hailstone(N, N).
  hailstone(N0, N) :- N0 #= 2*N1, hailstone(N1, N).
  hailstone(N0, N) :- N0 #= 2*_ + 1, N1 #= 3*N0 + 1, hailstone(N1, N).
  ```
- **Notas:** Muestra una secuencia de acciones modelada como relación entre estados. La secuencia no termina: después del 1 vuelve a 4, 2, 1…

### POP-02 — Sumar en notación de sucesor: ¿importa el orden de los argumentos?
- **Fuente:** Triska, *CLP(FD) and CLP(Z)*, "Introduction", recuadro **Exercise**. https://www.metalevel.at/prolog/clpz
- **Tipo:** ejercicio explícito
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** propia, verificada. La versión del libro intercambia los dos primeros argumentos en la llamada recursiva y termina si cualquier argumento está instanciado. La versión "habitual", `nat_nat_sum(N, M, Sum)`, se lee con más naturalidad, pero `?- nat_nat_sum(X, s(0), Y), false.` no termina.
- **SWISH:** sí
- **Enunciado:** En la suma de Peano de abajo, analizar ventajas y desventajas de reemplazar la llamada recursiva `nat_nat_sum(M, N, Sum)` por `nat_nat_sum(N, M, Sum)`.
  ```prolog
  nat_nat_sum(0, M, M).
  nat_nat_sum(s(N), M, s(Sum)) :- nat_nat_sum(M, N, Sum).
  ```

### POP-03 — Hacer terminar `list_length(Ls, 3)`
- **Fuente:** Triska, *CLP(FD) and CLP(Z)*, "Example: Length of a list" ("left as an exercise"). https://www.metalevel.at/prolog/clpz#list_length
- **Tipo:** ejercicio explícito
- **Tema:** 5, 6, 7
- **Dificultad:** 2
- **Solución:** propia, verificada: agregar `Length #> 0` antes de la llamada recursiva. Con eso, `list_length(Ls, 3)` da una sola respuesta y termina.
  ```prolog
  list_length([], 0).
  list_length([_|Ls], Length) :-
      Length #> 0, Length #= Length0 + 1, list_length(Ls, Length0).
  ```
- **SWISH:** sí
- **Enunciado:** La versión con restricciones de `list_length/2` funciona en todas las direcciones, pero `?- list_length(Ls, 3), false.` no termina. Agregar un único objetivo para que termine.
- **Notas:** Muestra la diferencia entre `#=` y `is`: `#=` funciona aunque la longitud todavía no esté instanciada.

### POP-04 — Hacer terminar la versión con acumulador
- **Fuente:** Triska, *CLP(FD) and CLP(Z)*, "Example: Length of a list" (segundo "left as an exercise"). https://www.metalevel.at/prolog/clpz#list_length
- **Tipo:** ejercicio explícito
- **Tema:** 5, 6, 7
- **Dificultad:** 3
- **Solución:** propia, verificada: en la cláusula recursiva de `list_length_/3`, agregar `L #>= L1` después de calcular `L1`, para acotar la longitud final.
- **SWISH:** sí
- **Enunciado:** Lo mismo que POP-03, pero para la versión con acumulador `list_length_(Ls, L0, L)`.

### POP-05 — Un factorial que responde la consulta más general
- **Fuente:** Triska, *Prolog Coding Horror*, "Horror factorial". https://www.metalevel.at/prolog/horror
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** 7, 8
- **Dificultad:** 2
- **Solución:** propia, verificada: `n_factorial(N, F)` da 0-1, 1-1, 2-2, 3-6, … y `n_factorial(N, 720)` da `N = 6`.
  ```prolog
  n_factorial(0, 1).
  n_factorial(N, F) :- N #> 0, N1 #= N - 1, F #= N*F1, n_factorial(N1, F1).
  ```
- **SWISH:** sí
- **Enunciado:** El texto muestra un factorial con `!` y con `is` que pierde soluciones ante `?- f(N, F).` (y, sin el corte, lanza un error de instanciación). Explicar ambos defectos y escribir una versión pura con `#=` que funcione en todas las direcciones.
- **Notas:** Sirve para contrastar el uso relacional con el funcional y para mostrar el costo de un corte.

### POP-06 — Explicar la no terminación con *failure slicing*
- **Fuente:** Triska, *Nontermination*, "Failure slicing". https://www.metalevel.at/prolog/nontermination
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** texto, verificada: separar los hechos en `adjacent_/2` y definir `adjacent/2` con dos reglas no recursivas. Así, `?- adjacent(X, Y), false.` termina.
- **SWISH:** sí
- **Enunciado:** Insertando `false` en el programa, aislar el fragmento que explica por qué la versión "simétrica" de abajo no termina, y corregirla.
  ```prolog
  adjacent(a, b).
  adjacent(e, f).
  adjacent(X, Y) :- adjacent(Y, X).
  ```
- **Notas:** El error de definir la simetría con una regla recursiva sobre el mismo predicado es muy frecuente. Otra solución: `:- table adjacent/2.` (ver POP-15).

### POP-07 — Mejores nombres de variables para `append`
- **Fuente:** Triska, *Writing Prolog Programs*, "How to begin" ("left as an exercise"). https://www.metalevel.at/prolog/writing
- **Tipo:** ejercicio explícito
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** no (hay muchas respuestas válidas)
- **SWISH:** sí
- **Enunciado:** Después de derivar `list_list_together/3` (la concatenación de listas), elegir nombres de variables más claros para sus cláusulas.
  ```prolog
  list_list_together([], Bs, Bs).
  list_list_together([L|Ls], Bs, [L|Rest]) :- list_list_together(Ls, Bs, Rest).
  ```
- **Notas:** Buena ocasión para hablar de las convenciones de nombres: plurales para listas y `0`, `1`… para estados.

### POP-08 — Lectura declarativa de un predicado
- **Fuente:** Triska, *Reading Prolog Programs*, "Declarative reading". https://www.metalevel.at/prolog/reading#declarative
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** 2, 5, 6
- **Dificultad:** 1
- **Solución:** está en el texto
- **SWISH:** sí
- **Enunciado:** Leer en voz alta las cláusulas de `list_list_together/3` en forma declarativa ("si …, entonces …"), sin describir los pasos de ejecución, y comprobar esa lectura con consultas en distintas direcciones.

---

## Estructuras de datos y órdenes superiores

### POP-09 — Representación limpia de árboles binarios llenos
- **Fuente:** Triska, *Prolog Data Structures*, "Clean vs. defaulty representations". https://www.metalevel.at/prolog/data#clean
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con árboles representados como `leaf(L)` y `node(Left, Right)`, escribir un predicado que relacione un árbol con la lista de sus hojas. Explicar por qué omitir el envoltorio `leaf/1` produce una representación "defaulty".
- **Notas:** Refuerza que el functor principal permite distinguir los casos por unificación en la cabeza, sin `var/1` ni casos por defecto.

### POP-10 — Implementar `permutation/2`
- **Fuente:** Triska, *Sorting and Searching*, "Pruning the search" ("left as an exercise"). https://www.metalevel.at/prolog/sorting#pruning
- **Tipo:** ejercicio explícito
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** propia, verificada (6 permutaciones de `[1,2,3]`):
  ```prolog
  perm([], []).
  perm(Ls, [E|Ps]) :- select(E, Ls, Rs), perm(Rs, Ps).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir una relación entre una lista y cada una de sus permutaciones, que las genere por backtracking. Se usa para ordenar por "generar y comprobar".

### POP-11 — Intérprete para una base de reglas de un sistema experto
- **Fuente:** Triska, *Expert Systems in Prolog* ("It is a straight-forward exercise…"). https://www.metalevel.at/prolog/expertsystems
- **Tipo:** ejercicio explícito
- **Tema:** 3, 6, X
- **Dificultad:** 2
- **Solución:** parcial en el texto (el fragmento `animal/1` que le sigue)
- **SWISH:** sí (sin la parte interactiva de preguntas al usuario)
- **Enunciado:** Las reglas de identificación de animales se representan como datos: `animal(Nombre, [is_true("has fur"), …])`. Escribir un intérprete que identifique un animal cuando se cumplen todas sus condiciones.
  ```prolog
  animals([animal(dog, [is_true("has fur"), is_true("says woof")]),
           animal(duck, [is_true("has feathers"), is_true("says quack")])]).
  ```
- **Notas:** Introduce la idea de un lenguaje de dominio específico interpretado por Prolog.

---

## Gramáticas (DCG)

### POP-12 — Palíndromos a partir de `reversal//1`
- **Fuente:** Triska, *Prolog DCG Primer*, "List reversal, palindromes and other exercises" (**Challenge**). https://www.metalevel.at/prolog/dcg
- **Tipo:** ejercicio explícito
- **Tema:** A, 6
- **Dificultad:** 2
- **Solución:** propia, verificada (dos definiciones):
  ```prolog
  palindrome1(Ls) :- phrase(reversal(Ls), Ls).
  palindrome2 --> seq(Ls), reversal(Ls).
  palindrome2 --> seq(Ls), [_], reversal(Ls).
  seq([]) --> [].
  seq([E|Es]) --> [E], seq(Es).
  ```
- **SWISH:** sí (con `double_quotes` en `codes` o `chars`, o con comillas invertidas)
- **Enunciado:** Con la DCG de inversión de listas del texto, definir `palindrome//0` de dos maneras distintas.
  ```prolog
  reversal([]) --> [].
  reversal([L|Ls]) --> reversal(Ls), [L].
  ```

### POP-13 — Recorridos de un árbol con DCG
- **Fuente:** Triska, *Prolog DCG Primer*, "Relating trees to lists". https://www.metalevel.at/prolog/dcg
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** A, 3
- **Dificultad:** 1
- **Solución:** no (alcanza con mover el terminal `[Name]` dentro del cuerpo de la regla)
- **SWISH:** sí
- **Enunciado:** A partir de `tree_nodes//1`, que da el recorrido en orden simétrico (*in-order*) de un árbol `node(Name, Left, Right)` o `nil`, obtener el recorrido en preorden y en postorden.
- **Notas:** El texto sigue con el problema de la recursión a izquierda al usarla en sentido inverso. Eso ya es avanzado.

---

## Búsqueda, eficiencia y memoización

### POP-14 — ¿Por qué la profundización iterativa no es tan cara?
- **Fuente:** Triska, *Fun Facts about Prolog*, "Iterative deepening is often a good strategy" (**Exercise: Why?**). https://www.metalevel.at/prolog/fun
- **Tipo:** ejercicio explícito
- **Tema:** 4, X
- **Dificultad:** 2
- **Solución:** no (es un argumento matemático: la suma de b^j·(k+1−j) está dominada por el término b^k cuando b ≥ 2)
- **SWISH:** no corresponde
- **Enunciado:** Justificar por qué el total de visitas de la profundización iterativa hasta la profundidad k está dominado asintóticamente por las visitas del último nivel.
- **Notas:** En Prolog, la profundización iterativa se obtiene con `length(Path, _)` antes de buscar.

### POP-15 — Fibonacci con *tabling*
- **Fuente:** Triska, *Memoization*, "Tabling". https://www.metalevel.at/prolog/memoization#tabling
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** 5, 7, X
- **Dificultad:** 1
- **Solución:** texto, verificada: con `:- table fibonacci/2.`, `fibonacci(100, F)` da `F = 573147844013817084101` (con la convención F0 = F1 = 1).
- **SWISH:** sí (SWI-Prolog tiene `table/1` incorporado)
- **Enunciado:** Comprobar que la versión recursiva directa de Fibonacci agota la pila para n = 100 y que una directiva de *tabling* la vuelve instantánea.
- **Notas:** Se puede comparar con la solución con acumulador (END-3.4).

---

## Puzzles lógicos

### POP-16 — Caballeros y bribones
- **Fuente:** Triska, *Logic Puzzles with Prolog*, "Knights and Knaves". https://www.metalevel.at/prolog/puzzles
- **Tipo:** tarea derivada de un ejemplo (cinco casos resueltos en el texto)
- **Tema:** X
- **Dificultad:** 1
- **Solución:** texto, verificada: en el ejemplo 1, `sat(A =:= ~A+B)` da `A = 1, B = 1`; en el ejemplo 5, C es bribón.
- **SWISH:** sí (con `library(clpb)`)
- **Enunciado:** En una isla, los caballeros siempre dicen la verdad y los bribones siempre mienten. Traducir a restricciones booleanas lo que dicen los habitantes (por ejemplo, A dice "yo soy bribón o B es caballero") y deducir qué es cada uno.
- **Notas:** Conecta con la lógica proposicional del curso. Sin CLP(B) se puede resolver por generar y comprobar, con `member(X, [0,1])` y tablas de verdad escritas como hechos.

### POP-17 — ¿Cuál respuesta es correcta?
- **Fuente:** Triska, *Logic Puzzles with Prolog*, "Which answer is correct?". https://www.metalevel.at/prolog/puzzles
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** X
- **Dificultad:** 2
- **Solución:** en el texto (solo la opción 5 es consistente)
- **SWISH:** sí (con `library(clpb)`)
- **Enunciado:** Modelar con variables booleanas una pregunta de opción múltiple cuyas seis opciones se refieren unas a otras ("todas las de abajo", "ninguna de arriba", …) y encontrar la única asignación consistente.

### POP-18 — Silogismo de Lewis Carroll
- **Fuente:** Triska, *Logic Puzzles with Prolog*, "Lewis Carroll". https://www.metalevel.at/prolog/puzzles
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** X
- **Dificultad:** 3
- **Solución:** en el texto ("nunca vi una sirena")
- **SWISH:** sí (con `library(clpb)`)
- **Enunciado:** Traducir cuatro premisas en lenguaje natural a implicaciones proposicionales y encadenarlas hasta obtener la conclusión, usando una DCG que busca la cadena de implicaciones.
- **Notas:** El problema lógico es accesible; la implementación con DCG y `taut/2` no lo es.

### POP-19 — Criptoaritmética CP + IS + FUN = TRUE
- **Fuente:** Triska, *Logic Puzzles with Prolog*, "Cryptoarithmetic puzzles". https://www.metalevel.at/prolog/puzzles#cryptoarithmetic
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** X, 7
- **Dificultad:** 2
- **Solución:** texto, verificada: la primera solución es 12+83+579=674; con `T #\= 0`, el texto da 23+74+968=1065.
- **SWISH:** sí (con `library(clpfd)`)
- **Enunciado:** Asignar dígitos distintos a las letras para que se cumpla CP + IS + FUN = TRUE, usando `digits_number/2` y restricciones enteras. Después, agregar la restricción de que T no sea 0.
- **Notas:** El clásico SEND + MORE = MONEY (UNI-CAM-16.2) es equivalente.

### POP-20 — El acertijo de la cebra
- **Fuente:** Triska, *Logic Puzzles with Prolog*, "Zebra Puzzle". https://www.metalevel.at/prolog/puzzles
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** 4, X
- **Dificultad:** 3
- **Solución:** texto, verificada: el noruego bebe agua y el japonés tiene la cebra (`Water = 1, Zebra = 5`).
- **SWISH:** sí (con `library(clpfd)`)
- **Enunciado:** Cinco casas con color, nacionalidad, bebida, marca de cigarrillos y mascota distintos, y 14 pistas. ¿Quién bebe agua y quién tiene la cebra? Modelarlo con variables de posición 1..5 y restricciones del tipo `abs(H-N) #= 1` para "al lado de".
- **Notas:** Sin CLP(FD) se resuelve con una lista de 5 casas `house(Color, Nación, …)` y `member/2`, lo que ilustra la búsqueda del tema 4 (ver UNI-CAM-2.1).

### POP-21 — Cruce del río (lobo, cabra y repollo)
- **Fuente:** Triska, *Logic Puzzles with Prolog*, "Wolf and Goat etc.". https://www.metalevel.at/prolog/puzzles (ejemplo completo en https://www.metalevel.at/zurg/)
- **Tipo:** tarea derivada de un ejemplo (el texto solo describe el método)
- **Tema:** 4, 6
- **Dificultad:** 3
- **Solución:** no para el lobo, la cabra y el repollo; *Escape from Zurg* está resuelto en el enlace.
- **SWISH:** sí
- **Enunciado:** Representar los estados de un problema de cruce de río y una relación de transición entre estados, y encontrar la secuencia más corta de movimientos con profundización iterativa, usando `length/2` para generar listas de largo creciente.
- **Notas:** Es el patrón "pensar en estados". Se complementa con los misioneros y caníbales de UNI-CAM-13.3.

### POP-22 — Coloreo de mapas
- **Fuente:** Triska, *Combinatorial Optimization*, "Example: Map Colouring". https://www.metalevel.at/prolog/optimization#mapcolouring
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** 4, X
- **Dificultad:** 2
- **Solución:** en el texto (con CLP(B) y CLP(FD))
- **SWISH:** sí
- **Enunciado:** Colorear las regiones de un mapa con pocos colores de modo que dos regiones vecinas no compartan color.
- **Notas:** Para principiantes: versión con hechos `color(rojo)` y restricciones `\=` al final (generar y comprobar).

### POP-23 — N reinas
- **Fuente:** Triska, *N-queens* (showcase). https://www.metalevel.at/queens/
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** 4, X
- **Dificultad:** 3
- **Solución:** sí, en la página (con CLP(FD))
- **SWISH:** sí
- **Enunciado:** Ubicar N reinas en un tablero de N × N sin que se ataquen entre sí.
- **Notas:** La versión con `permutation/2` (generar y comprobar) está al alcance del curso y se vuelve lenta enseguida. La versión con restricciones queda fuera de alcance.

### POP-24 — Sudoku
- **Fuente:** Triska, *Sudoku* (showcase). https://www.metalevel.at/sudoku/
- **Tipo:** tarea derivada de un ejemplo
- **Tema:** X
- **Dificultad:** 3
- **Solución:** sí, en la página
- **SWISH:** sí (con `library(clpfd)`)
- **Enunciado:** Resolver sudokus expresando con restricciones que filas, columnas y bloques tengan valores distintos.

---

## Temas avanzados (fuera de alcance)

### POP-25 — Propiedad monótona de un resolvedor de dominios
- **Fuente:** Triska, *Attributed Variables*, **Exercise (hard)**. https://www.metalevel.at/prolog/attributedvariables
- **Tipo:** ejercicio explícito
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí (el código usa `put_attr/3` de SWI)
- **Enunciado:** Demostrar, o refutar con un contraejemplo, que en el resolvedor `domain/2` del texto quitar un objetivo de una consulta formada solo por `domain/2` y `=/2` nunca hace que la consulta sea más restrictiva.

### POP-26 — Restricción de ZDD con memoización
- **Fuente:** Triska, *Attributed Variables*, "left as an exercise". https://www.metalevel.at/prolog/attributedvariables
- **Tipo:** ejercicio explícito
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Hacer más eficiente `zdd_restriction/4`, que calcula la restricción de un diagrama de decisión (ZDD), usando memoización.
