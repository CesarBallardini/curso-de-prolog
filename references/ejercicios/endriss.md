# Endriss: *An Introduction to Prolog Programming*

- **Fuente:** Ulle Endriss, *An Introduction to Prolog Programming*, apuntes de clase, Institute for Logic, Language and Computation, Universiteit van Amsterdam. Versión del 20 de octubre de 2021 (80 páginas).
- **URL:** https://staff.fnwi.uva.nl/u.endriss/teaching/prolog/prolog.pdf (página del curso: https://staff.fnwi.uva.nl/u.endriss/teaching/prolog/)
- **Licencia:** © Ulle Endriss. Descarga gratuita, sin licencia abierta explícita (ni en el PDF ni en la página del curso). Por eso los enunciados están parafraseados y resumidos en castellano; el texto completo está en el PDF.
- **Soluciones oficiales:** **no hay.** Esta versión no trae apéndice de soluciones (el Apéndice A trata sobre programación recursiva). Las soluciones cortas que aparecen abajo son propias y se verificaron con SWI-Prolog 9.2.9.
- **Páginas:** las referencias "p. N" usan la numeración impresa del PDF.
- **Total:** 48 ejercicios.

**Cantidad por tema** (un ejercicio puede tener más de un tema):

| Tema | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | A | X |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ejercicios | 1 | 3 | 3 | 11 | 6 | 20 | 22 | 21 | 9 | 2 | 0 | 1 | 0 | 4 |

---

## Capítulo 1: The Basics (Sección 1.5, pp. 12–14)

### END-1.1 — Átomos, variables y unificación a mano
- **Fuente:** Endriss, cap. 1, Ejercicio 1.1, p. 12. https://staff.fnwi.uva.nl/u.endriss/teaching/prolog/prolog.pdf
- **Tema:** 1, 3
- **Dificultad:** 1
- **Solución:** propia, verificada: (a) átomos válidos: `f`, `'Hello'`, `this_is_it`; `loves(john,mary)` es compuesto y `Mary` y `_c1` son variables. (b) variables válidas: `A`, `Paul`, `_`, `_abc`. (c) `X = a, Y = b`. (d) sí: `John = mary, Mary = john`, porque dentro de la consulta son variables. (e) `false`: `X`, `Y` y `Z` quedan ligadas a `1` y `a(1, 100)` falla.
- **SWISH:** sí
- **Enunciado:** Primero a mano y después en el intérprete: distinguir átomos válidos de nombres de variable válidos, predecir la respuesta a `f(a, b) = f(X, Y)` y a `loves(mary, john) = loves(John, Mary)`, y explicar qué pasa con una cadena de consultas sobre el único hecho `a(B, B).`
  ```prolog
  a(B, B).
  ?- a(1, X), a(X, Y), a(Y, Z), a(Z, 100).
  ```
- **Notas:** Sirve para fijar que la mayúscula inicial es lo que convierte un nombre en variable y que las comillas simples crean átomos.

### END-1.2 — Seguir la unificación paso a paso
- **Fuente:** Endriss, cap. 1, Ejercicio 1.2, p. 13.
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** propia, verificada: (a) falla, porque `Y` no puede valer `1` y `2` a la vez. (b) tiene éxito con `Y = c` y `X` libre. (c) imprime `One ` y liga `X` al término `write('Two ')` sin ejecutarlo.
- **SWISH:** sí
- **Enunciado:** Explicar qué hace Prolog con tres consultas de unificación, entre ellas una que liga una variable a un término `write(...)` sin ejecutarlo.
  ```prolog
  ?- myFunctor(1, 2) = X, X = myFunctor(Y, Y).
  ?- f(a, _, c, d) = f(a, X, Y, _).
  ?- write('One '), X = write('Two ').
  ```
- **Notas:** El inciso (c) muestra que un término no es una llamada: `=` no ejecuta nada.

### END-1.3 — Relaciones familiares con reglas
- **Fuente:** Endriss, cap. 1, Ejercicio 1.3, pp. 13–14.
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** propia, verificada:
  ```prolog
  father(X, Y) :- parent(X, Y), male(X).
  sister(X, Y) :- parent(Z, X), parent(Z, Y), female(X), X \= Y.
  grandmother(X, Y) :- parent(X, Z), parent(Z, Y), female(X).
  cousin(X, Y) :- parent(P, X), parent(Q, Y), parent(G, P), parent(G, Q), P \= Q.
  ```
- **SWISH:** sí
- **Enunciado:** A partir de una base de hechos `male/1`, `female/1` y `parent/2` (en el PDF), dibujar el árbol genealógico y definir `father`, `sister`, `grandmother` y `cousin`. Se da como modelo la regla `brother/2`, que usa `\=`.
- **Notas:** `sister` y `cousin` devuelven respuestas repetidas, una por cada progenitor en común. Conviene usarlo para hablar de backtracking (y más adelante de `setof/3`). El `X \= Y` tiene que ir al final, cuando ambas variables ya están ligadas.

### END-1.4 — Cambiar el orden de los subobjetivos
- **Fuente:** Endriss, cap. 1, Ejercicio 1.4, p. 14.
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** no hay oficial. Idea: si la llamada recursiva queda primera en la regla transitiva de `is_bigger`, Prolog da las respuestas y después, al pedir más con `;`, entra en recursión infinita (desborde de pila).
- **SWISH:** sí (la pila se desborda y SWISH corta la ejecución)
- **Enunciado:** En el programa de los animales de la sección 1.1, invertir el orden de los dos subobjetivos de la regla recursiva, predecir y luego observar qué pasa con `?- is_bigger(A, donkey).` al pedir todas las soluciones, y explicarlo.
- **Notas:** Es un buen primer ejemplo de que la semántica declarativa no alcanza: el orden de los objetivos decide si el programa termina.

### END-1.5 — Releer el capítulo
- **Fuente:** Endriss, cap. 1, Ejercicio 1.5, p. 14.
- **Tema:** 0
- **Dificultad:** 1
- **Solución:** no corresponde
- **SWISH:** no corresponde
- **Enunciado:** Sugerencia de volver a leer el capítulo (sintaxis, unificación y ejecución de objetivos) unas semanas después.
- **Notas:** No es un ejercicio práctico. Figura solo para que la numeración quede completa.

---

## Capítulo 2: Working with Lists (Sección 2.4, pp. 19–21)

### END-2.1 — Mostrar cabeza y cola de una lista
- **Fuente:** Endriss, cap. 2, Ejercicio 2.1, p. 19.
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia, verificada:
  ```prolog
  analyse_list([]) :- write('This is an empty list.'), nl.
  analyse_list([H|T]) :- write('This is the head of your list: '), write(H), nl,
      write('This is the tail of your list: '), write(T), nl.
  ```
- **SWISH:** sí
- **Enunciado:** Escribir `analyse_list/1`: si recibe una lista no vacía, imprime la cabeza y la cola; si recibe la lista vacía, lo avisa; si el argumento no es una lista, falla.
- **Notas:** No hace falta ningún caso para "no es lista": alcanza con que ninguna cláusula unifique.

### END-2.2 — Reimplementar `member/2`
- **Fuente:** Endriss, cap. 2, Ejercicio 2.2, p. 19.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `membership(X, [X|_]).` y `membership(X, [_|T]) :- membership(X, T).`
- **SWISH:** sí
- **Enunciado:** Definir `membership/2`, que se comporte igual que `member/2` sin usarlo, con recursión sobre el patrón cabeza/cola.

### END-2.3 — Eliminar duplicados
- **Fuente:** Endriss, cap. 2, Ejercicio 2.3, p. 19.
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** propia, verificada (conserva la última aparición, como en el ejemplo `[b, a, c, d]`):
  ```prolog
  remove_duplicates([], []).
  remove_duplicates([H|T], R) :- member(H, T), !, remove_duplicates(T, R).
  remove_duplicates([H|T], [H|R]) :- remove_duplicates(T, R).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir `remove_duplicates/2`, que quite de una lista los elementos repetidos. Ejemplo: `[a,b,a,c,d,d]` da `[b,a,c,d]`.
- **Notas:** Sin corte (o sin `\+ member(H, T)` en la tercera cláusula), al pedir más respuestas con `;` aparecen soluciones incorrectas. Conviene volver a este ejercicio en el tema 8.

### END-2.4 — Invertir una lista
- **Fuente:** Endriss, cap. 2, Ejercicio 2.4, p. 19.
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** propia, verificada (con acumulador):
  ```prolog
  reverse_list(L, R) :- rev_acc(L, [], R).
  rev_acc([], A, A).
  rev_acc([H|T], A, R) :- rev_acc(T, [H|A], R).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir `reverse_list/2`, equivalente a `reverse/2`, sin usar el predicado predefinido.
- **Notas:** Permite comparar la versión "ingenua" con `append/3` (cuadrática) con la versión con acumulador (lineal).

### END-2.5 — ¿Qué calcula `whoami/1`?
- **Fuente:** Endriss, cap. 2, Ejercicio 2.5, pp. 19–20.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** propia: tiene éxito exactamente con las listas de longitud par.
- **SWISH:** sí
- **Enunciado:** Dado el programa, decir para qué argumentos tiene éxito `whoami(X)`.
  ```prolog
  whoami([]).
  whoami([_, _ | Rest]) :- whoami(Rest).
  ```

### END-2.6 — Último elemento, de dos maneras
- **Fuente:** Endriss, cap. 2, Ejercicio 2.6, p. 20.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `last1([X], X).  last1([_|T], X) :- last1(T, X).` y `last2(L, X) :- append(_, [X], L).`
- **SWISH:** sí
- **Enunciado:** (a) Definir `last1/2` con recursión y el patrón cabeza/cola. (b) Definir `last2/2` usando solo `append/3`, sin recursión explícita.
- **Notas:** El inciso (b) muestra cómo se usa `append/3` "al revés", para descomponer una lista.

### END-2.7 — Reemplazar todas las apariciones
- **Fuente:** Endriss, cap. 2, Ejercicio 2.7, p. 20.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** propia, verificada:
  ```prolog
  replace([], _, _, []).
  replace([X|T], X, Y, [Y|R]) :- !, replace(T, X, Y, R).
  replace([H|T], X, Y, [H|R]) :- replace(T, X, Y, R).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir `replace/4`, que reemplace en una lista todas las apariciones de un elemento por otro. Ejemplo: `replace([1,2,3,4,3,5,6,3], 3, x, L)`.
- **Notas:** Sin corte, o sin la condición `H \= X` en la tercera cláusula, al hacer backtracking aparecen soluciones con reemplazos parciales.

### END-2.8 — Conjunto potencia
- **Fuente:** Endriss, cap. 2, Ejercicio 2.8, p. 20.
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** propia, verificada (usa `findall/3`, que el libro presenta recién en el cap. 5):
  ```prolog
  power([], [[]]).
  power([H|T], P) :- power(T, PT), findall([H|S], member(S, PT), WithH), append(WithH, PT, P).
  ```
- **SWISH:** sí
- **Enunciado:** Dada una lista sin repetidos, vista como conjunto, calcular con `power/2` la lista de todos sus subconjuntos. El orden no importa.
- **Notas:** También se puede resolver sin `findall`, con un predicado auxiliar que agrega `H` a cada sublista.

### END-2.9 — ¿Es más larga? (sin aritmética)
- **Fuente:** Endriss, cap. 2, Ejercicio 2.9, p. 20.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `longer([], [_|_]).  longer([_|T1], [_|T2]) :- longer(T1, T2).`
- **SWISH:** sí
- **Enunciado:** Escribir `longer/2`, que tenga éxito si la segunda lista tiene más elementos que la primera, sin usar aritmética.

### END-2.10 — Aritmética unaria con listas
- **Fuente:** Endriss, cap. 2, Ejercicio 2.10, p. 21.
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** propia, verificada:
  ```prolog
  successor(N, [x|N]).
  plus([], N, N).
  plus([x|M], N, [x|R]) :- plus(M, N, R).
  times([], _, []).
  times([x|M], N, R) :- times(M, N, R1), plus(N, R1, R).
  ```
- **SWISH:** sí
- **Enunciado:** Representar los naturales como listas de `x` (cinco es `[x,x,x,x,x]` y cero es `[]`) e implementar `successor/2`, `plus/3` y `times/3` sin usar números ni `is`.
- **Notas:** Es la misma idea que la aritmética de Peano con `s(N)`. `plus/3` sirve además para restar si se lo consulta al revés.

---

## Capítulo 3: Working with Numbers (Sección 3.3, pp. 25–36)

### END-3.1 — Distancia entre dos puntos
- **Fuente:** Endriss, cap. 3, Ejercicio 3.1, p. 25.
- **Tema:** 7
- **Dificultad:** 1
- **Solución:** propia, verificada: `distance((X1,Y1), (X2,Y2), D) :- D is sqrt((X2-X1)**2 + (Y2-Y1)**2).`
- **SWISH:** sí
- **Enunciado:** Escribir `distance/3`, que calcule la distancia euclídea entre dos puntos del plano representados como pares `(X,Y)`.
- **Notas:** El par `(0,0)` es el término `','(0,0)`. Conviene aclararlo, porque se parece a la notación matemática pero es un término compuesto.

### END-3.2 — Imprimir un cuadrado de caracteres
- **Fuente:** Endriss, cap. 3, Ejercicio 3.2, pp. 25–26.
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí (la salida de `write/1` aparece en el panel de resultados)
- **Enunciado:** Escribir `square/2`, que imprima un cuadrado de n × n copias de un término dado.
- **Notas:** Son dos recursiones anidadas, una por filas y otra por columnas, cada una con su caso base.

### END-3.3 — Fibonacci
- **Fuente:** Endriss, cap. 3, Ejercicio 3.3, p. 26.
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** propia, verificada:
  ```prolog
  fibonacci(0, 0).
  fibonacci(1, 1).
  fibonacci(N, F) :- N > 1, N1 is N-1, N2 is N-2,
      fibonacci(N1, F1), fibonacci(N2, F2), F is F1+F2.
  ```
- **SWISH:** sí
- **Enunciado:** Escribir `fibonacci/2`, que devuelva el n-ésimo número de Fibonacci con F0 = 0 y F1 = 1.
- **Notas:** La guarda `N > 1` es imprescindible: sin ella, al pedir más respuestas con `;` la recursión baja a números negativos y no termina.

### END-3.4 — Fibonacci eficiente
- **Fuente:** Endriss, cap. 3, Ejercicio 3.4, pp. 26–27.
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** propia, verificada: F42 = 267914296 y F100 = 354224848179261915075.
  ```prolog
  fastfibo(N, F) :- fib_acc(N, 0, 1, F).
  fib_acc(0, A, _, A).
  fib_acc(N, A, B, F) :- N > 0, N1 is N-1, C is A+B, fib_acc(N1, B, C, F).
  ```
- **SWISH:** sí
- **Enunciado:** Explicar por qué la versión directa es exponencial y agota los recursos para n grandes. Escribir `fastfibo/2`, que calcule cualquiera de los 100 primeros números en menos de una centésima de segundo, e informar F42.
- **Notas:** Muestra la técnica del acumulador. SWI-Prolog maneja enteros de precisión arbitraria, así que F100 no desborda. Alternativa: `:- table fibonacci/2.`

### END-3.5 — n-ésimo elemento de una lista
- **Fuente:** Endriss, cap. 3, Ejercicio 3.5, p. 27.
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** propia, verificada: `element_at([X|_], 1, X).  element_at([_|T], N, X) :- N > 1, N1 is N-1, element_at(T, N1, X).`
- **SWISH:** sí
- **Enunciado:** Escribir `element_at/3`, que devuelva el n-ésimo elemento de una lista contando desde 1, y que falle si la lista es más corta.
- **Notas:** Es equivalente a `nth1/3`.

### END-3.6 — Media aritmética
- **Fuente:** Endriss, cap. 3, Ejercicio 3.6, p. 27.
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** propia, verificada: `mean(L, M) :- sum_list(L, S), length(L, N), N > 0, M is S / N.`
- **SWISH:** sí
- **Enunciado:** Escribir `mean/2`, que calcule la media de una lista de números.
- **Notas:** Como ejercicio de recursión, conviene pedir que la suma y la longitud se calculen a mano, sin `sum_list/2` ni `length/2`.

### END-3.7 — Mínimo de una lista
- **Fuente:** Endriss, cap. 3, Ejercicio 3.7, p. 27.
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** propia, verificada: `minimum([X], X).  minimum([H|T], M) :- T \= [], minimum(T, M1), M is min(H, M1).`
- **SWISH:** sí
- **Enunciado:** Escribir `minimum/2`, que encuentre el menor número de una lista, y discutir qué debería responder ante la lista vacía y por qué.
- **Notas:** Con la lista vacía debe fallar, porque no existe el mínimo. Da pie a hablar de fallo frente a error.

### END-3.8 — Rango de enteros
- **Fuente:** Endriss, cap. 3, Ejercicio 3.8, p. 28.
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** propia, verificada: `range(L, U, []) :- L > U.  range(L, U, [L|R]) :- L =< U, L1 is L+1, range(L1, U, R).`
- **SWISH:** sí
- **Enunciado:** Escribir `range/3`, que construya la lista de enteros entre una cota inferior y una superior, o la lista vacía si la inferior es mayor.
- **Notas:** Es equivalente a `numlist/3`.

### END-3.9 — Base de datos de fechas de nacimiento
- **Fuente:** Endriss, cap. 3, Ejercicio 3.9, pp. 28–29.
- **Tema:** 1, 2, 3, 7, 11
- **Dificultad:** 2
- **Solución:** propia, verificada: `older(X, Y)` da 28 soluciones porque son 8 personas con fechas distintas y cada par se cuenta una sola vez: C(8,2) = 28.
  ```prolog
  year(Y, P) :- born(P, date(_, _, Y)).
  before(date(D1,M1,Y1), date(D2,M2,Y2)) :-
      Y1 < Y2 ; Y1 =:= Y2, M1 < M2 ; Y1 =:= Y2, M1 =:= M2, D1 < D2.
  older(X, Y) :- born(X, DX), born(Y, DY), before(DX, DY).
  ```
- **SWISH:** sí
- **Enunciado:** Con hechos `born(Nombre, date(D,M,A))` (ocho personas, en el PDF): (a) `year/2` devuelve por backtracking quiénes nacieron en un año dado; (b) `before/2` compara dos fechas; (c) `older/2` dice si una persona es mayor que otra. Explicar por qué `older(X, Y)` tiene 28 soluciones.
  ```prolog
  born(jan, date(20,3,1977)).
  born(joris, date(17,3,1995)).
  % ... seis hechos más en el PDF
  ```
- **Notas:** Es una base de datos relacional en miniatura (tema 11): `year/2` equivale a una selección y `older/2` a un join de la tabla consigo misma.

### END-3.10 — Robot en una grilla
- **Fuente:** Endriss, cap. 3, Ejercicio 3.10, p. 29.
- **Tema:** 3, 5, 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Un robot parte de `(0,0)` mirando al norte y acepta los comandos `left`, `right` y `move`. Escribir `execute/5` (un comando), `status/5` (una lista de comandos desde un estado dado) y `status/3` (posición y orientación finales desde el estado inicial).
- **Notas:** Es un buen ejemplo de "estado explícito como argumentos": cada llamada recursiva recibe el estado nuevo, sin variables globales.

### END-3.11 — Suma de polinomios
- **Fuente:** Endriss, cap. 3, Ejercicio 3.11, p. 30.
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Representar un polinomio como una lista de pares `(Coeficiente, Exponente)` y escribir `poly_sum/3`, que los sume sin depender del orden de los pares. Sugerencia: usar `select/3`.

### END-3.12 — ¿Es primo?
- **Fuente:** Endriss, cap. 3, Ejercicio 3.12, p. 30.
- **Tema:** 7, 8
- **Dificultad:** 1
- **Solución:** propia, verificada: `prime(N) :- N > 1, \+ (between(2, N, D), D*D =< N, N mod D =:= 0).`
- **SWISH:** sí
- **Enunciado:** Escribir `prime/1`, que diga si un número es primo.
- **Notas:** Sin negación se puede resolver con un predicado recursivo auxiliar que pruebe divisores desde 2 hasta la raíz de N.

### END-3.13 — Conjetura de Goldbach
- **Fuente:** Endriss, cap. 3, Ejercicio 3.13, pp. 30–31.
- **Tema:** 4, 7
- **Dificultad:** 2
- **Solución:** propia, verificada: `goldbach(N, A+B) :- H is N // 2, between(2, H, A), prime(A), B is N - A, prime(B).` (da `7+23` para 30).
- **SWISH:** sí
- **Enunciado:** Escribir `goldbach/2`, que exprese un par mayor que 2 como suma de dos primos `A+B`. Sugerencia: elegir `A` entre 2 y N/2 con `between/3` y comprobar que `A` y `N-A` sean primos.
- **Notas:** Es el patrón "generar y comprobar". El término `A+B` se devuelve sin evaluar, lo que refuerza el tema 3.

### END-3.14 — Juego de letras de *Countdown*
- **Fuente:** Endriss, cap. 3, Ejercicio 3.14, pp. 31–32.
- **Tema:** 4, 6, 7, 9
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no (requiere cargar `words.pl`, un archivo de unas 350.000 palabras que se descarga aparte, http://tinyurl.com/prolog-words)
- **Enunciado:** Dadas nueve letras, encontrar la palabra inglesa más larga que se pueda formar con ellas. Se construye en etapas: `word_letters/2` (átomo a lista de letras), `cover/2` (multiconjunto contenido en otro), `solution/3` (palabra de un largo dado) y `topsolution/3`.
- **Notas:** Es un proyecto chico. Sirve para usar `atom_chars/2` y para buscar primero las palabras más largas.

### END-3.15 — Gráficos en modo texto
- **Fuente:** Endriss, cap. 3, Ejercicio 3.15, pp. 32–34.
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (salida con `write/1`; el alineado depende de que la fuente sea monoespaciada)
- **Enunciado:** Dada una relación `point(D, X, Y)`, escribir `next/3` (siguiente celda al recorrer la grilla de arriba hacia abajo), `plot/2` y `plot/1`, que dibujen con asteriscos los puntos de una grilla D × D que cumplen la relación.
  ```prolog
  point(_, X, Y) :- X =:= Y.
  ```
- **Notas:** Cambiando la definición de `point/3` se dibujan círculos o triángulos, y se ve que un predicado puede recibir el "dato" como regla.

### END-3.16 — Números romanos a arábigos
- **Fuente:** Endriss, cap. 3, Ejercicio 3.16, pp. 34–36.
- **Tema:** 5, 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar `roman2arabic/2` en etapas: `symbol/2` (valor de cada letra), `symbols2numbers/2` (con la notación sustractiva, por ejemplo XL = 40), `sum/2` y la composición final, usando `atom_chars/2` para descomponer el átomo.
- **Notas:** Para la notación sustractiva hay que mirar los dos primeros elementos de la lista a la vez.

---

## Capítulo 4: Working with Operators (Sección 4.3, pp. 41–45)

### END-4.1 — Operadores `plink` y `plonk`
- **Fuente:** Endriss, cap. 4, Ejercicio 4.1, pp. 41–42.
- **Tema:** 3, X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí (la directiva `op/3` funciona en el programa)
- **Enunciado:** Con `op(100, yfx, plink)` y `op(200, xfy, plonk)`, explicar el resultado de tres unificaciones. Después escribir `pp_analyse/1`, que muestre el operador principal y los dos subtérminos de una expresión.
- **Notas:** Precedencia y asociatividad de operadores definidos por el usuario. Excede lo básico, pero muestra que `a plink b` es solo otra forma de escribir `plink(a, b)`.

### END-4.2 — Operadores `the`, `a` y `has`
- **Fuente:** Endriss, cap. 4, Ejercicio 4.2, p. 42.
- **Tema:** 3, X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `the` y `a` como prefijos (100, `fx`) y `has` como infijo (200, `xfx`), dar la estructura con paréntesis de `claudia has a car`, predecir `the lion has hunger = Who has What` y explicar por qué `she has whatever has style` es un error de sintaxis.

### END-4.3 — Operadores para los conectivos lógicos
- **Fuente:** Endriss, cap. 4, Ejercicio 4.3, pp. 42–43.
- **Tema:** 3, X
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Declarar los operadores `neg`, `and`, `or` e `implies` con precedencias que respeten la jerarquía de la lógica proposicional: binarios asociativos a izquierda y doble negación sin paréntesis. Comprobarlo mirando qué paréntesis conserva Prolog al imprimir.
- **Notas:** Se conecta directamente con la parte de lógica proposicional del curso.

### END-4.4 — ¿Está en forma normal negativa?
- **Fuente:** Endriss, cap. 4, Ejercicio 4.4, pp. 43–44.
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `nnf/1`, que decida si una fórmula con `neg`, `and` y `or` está en FNN, es decir, si solo se niegan átomos. Desafío opcional: transformar cualquier fórmula a FNN con De Morgan.
  ```prolog
  ?- nnf((p or neg q) and neg r).   % true
  ?- nnf(neg neg p).                % false
  ```

### END-4.5 — ¿Está en forma normal conjuntiva?
- **Fuente:** Endriss, cap. 4, Ejercicio 4.5, p. 44.
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `cnf/1`, que decida si una fórmula, escrita con los operadores del ejercicio 4.3, está en FNC.

### END-4.6 — Pasar una fórmula a FNC
- **Fuente:** Endriss, cap. 4, Ejercicio 4.6, pp. 44–45.
- **Tema:** 3, 5, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Agregar el operador `iff` y escribir `cnf/2`, que calcule una FNC equivalente. Conviene eliminar primero `implies` e `iff`, después llevar a FNN y por último distribuir.
  ```prolog
  ?- cnf(p iff neg neg q, CNF).
  CNF = (neg p or q) and (neg q or p)
  ```

---

## Capítulo 5: Backtracking, Cuts and Negation (Sección 5.5, pp. 58–62)

### END-5.1 — Corte y retroceso en consultas
- **Fuente:** Endriss, cap. 5, Ejercicio 5.1, p. 58.
- **Tema:** 4, 8
- **Dificultad:** 1
- **Solución:** propia, verificada: las dos consultas fallan. El corte fija la primera alternativa (`a` en un caso, `X = a` en el otro) y después ya no se puede volver atrás para probar `b`.
- **SWISH:** sí
- **Enunciado:** Explicar qué pasa con estas consultas:
  ```prolog
  ?- (Result = a ; Result = b), !, Result = b.
  ?- member(X, [a, b, c]), !, X = b.
  ```

### END-5.2 — Leer un programa con corte
- **Fuente:** Endriss, cap. 5, Ejercicio 5.2, p. 58.
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** propia, verificada: `result([a,b,c,d,e,f,g], X)` da `X = [b,d,f]`, los elementos en posición par.
- **SWISH:** sí
- **Enunciado:** Predecir la respuesta de `result([a,b,c,d,e,f,g], X)` y explicar el programa: qué casos cubre el hecho, qué efecto tiene el corte y por qué se usa la variable anónima.
  ```prolog
  result([_, E | L], [E | M]) :- !, result(L, M).
  result(_, []).
  ```

### END-5.3 — Máximo común divisor (Euclides)
- **Fuente:** Endriss, cap. 5, Ejercicio 5.3, pp. 58–59.
- **Tema:** 5, 7, 8
- **Dificultad:** 1
- **Solución:** propia, verificada: `gcd(A, 0, A) :- !.  gcd(A, B, G) :- B > 0, R is A mod B, gcd(B, R, G).`
- **SWISH:** sí
- **Enunciado:** Implementar `gcd/3` con el algoritmo de Euclides y asegurarse de que no dé respuestas extra ni erróneas al pedir más con `;`.

### END-5.4 — Contar apariciones
- **Fuente:** Endriss, cap. 5, Ejercicio 5.4, p. 59.
- **Tema:** 6, 7, 8
- **Dificultad:** 1
- **Solución:** propia, verificada:
  ```prolog
  occurrences(_, [], 0).
  occurrences(X, [X|T], N) :- !, occurrences(X, T, N0), N is N0+1.
  occurrences(X, [_|T], N) :- occurrences(X, T, N).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir `occurrences/3`, que cuente cuántas veces aparece un elemento en una lista, sin dar soluciones alternativas incorrectas.
- **Notas:** Alternativa sin corte: `X \= H` en la tercera cláusula.

### END-5.5 — Divisores de un número
- **Fuente:** Endriss, cap. 5, Ejercicio 5.5, p. 59.
- **Tema:** 6, 7, 8
- **Dificultad:** 1
- **Solución:** propia, verificada (con `findall/3`): `divisors(N, Ds) :- findall(D, (between(1, N, D), N mod D =:= 0), Ds).`
- **SWISH:** sí
- **Enunciado:** Escribir `divisors/2`, que devuelva la lista de divisores de un natural, sin soluciones alternativas erróneas ni bucles al pedir más con `;`.

### END-5.6 — Factorización en primos
- **Fuente:** Endriss, cap. 5, Ejercicio 5.6, pp. 59–60.
- **Tema:** 5, 7, 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir `factor/2`, que dé la factorización en primos con la notación `[2^2, 3, 5^2]`, y aplicarlo a 7777777 y a 12345654321.

### END-5.7 — Poder de voto en la UE de 1957
- **Fuente:** Endriss, cap. 5, Ejercicio 5.7, pp. 60–62.
- **Tema:** 6, 7, 9
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con los pesos de voto de los seis países fundadores y un umbral de 12, escribir `winning/1`, `critical/2`, `sublist/2` y `voting_power/2` (número de coaliciones en las que un país es decisivo, usando `findall/3`). Calcular el poder de Alemania y de Luxemburgo e interpretarlo.
  ```prolog
  weight(france, 4).  weight(belgium, 2).  weight(luxembourg, 1).
  threshold(12).   % demás hechos en el PDF
  ```
- **Notas:** El resultado de Luxemburgo, que tiene poder 0, suele sorprender. La consigna exige que los datos estén solo en los hechos.

### END-5.8 — Revisar programas viejos con cortes
- **Fuente:** Endriss, cap. 5, Ejercicio 5.8, p. 62.
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** no corresponde
- **SWISH:** sí
- **Enunciado:** Revisar los programas de ejercicios anteriores para encontrar soluciones alternativas erróneas o bucles al pedir más con `;`, y corregirlos con cortes.

---

## Capítulo 6: Logic Foundations of Prolog (Sección 6.3, pp. 67–68)

### END-6.1 — Traducir un programa a lógica de primer orden
- **Fuente:** Endriss, cap. 6, Ejercicio 6.1, p. 67.
- **Tema:** 2, 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** no corresponde (es un ejercicio de papel)
- **Enunciado:** Traducir a fórmulas de primer orden un programa con hechos `parent/2`, `male/1` y `female/1` y reglas `father/2` y `sister/2`.
- **Notas:** Refuerza que `:-` es una implicación de derecha a izquierda, que la coma es conjunción y que las variables están cuantificadas universalmente.

### END-6.2 — `X = f(X)` y el *occurs check*
- **Fuente:** Endriss, cap. 6, Ejercicio 6.2, p. 67.
- **Tema:** 3
- **Dificultad:** 2
- **Solución:** propia, verificada: SWI-Prolog tiene éxito y crea un término cíclico (`X = f(X)`), mientras que `unify_with_occurs_check(X, f(X))` falla.
- **SWISH:** sí
- **Enunciado:** Ejecutar `?- X = f(X).` y explicar el resultado, averiguando qué es el *occurs check* y por qué la unificación de Prolog no coincide exactamente con la unificación lógica.

### END-6.3 — La prueba por resolución de Sócrates
- **Fuente:** Endriss, cap. 6, Ejercicio 6.3, pp. 67–68.
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** no corresponde (es un ejercicio de papel)
- **Enunciado:** Traducir a lógica de primer orden el ejemplo de Sócrates mortal del capítulo 1 junto con su consulta, construir la prueba por resolución y compararla con la ejecución de Prolog.
