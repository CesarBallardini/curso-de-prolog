# Ejercicios: Clocksin & Mellish, *Programming in Prolog* (5.ª ed.)

- **Fuente:** W. F. Clocksin y C. S. Mellish, *Programming in Prolog: Using the ISO Standard*, 5.ª ed., Springer, 2003. Las páginas son páginas del PDF (`books/William F. Clocksin, Christopher S. Mellish-Programming in Prolog-Springer (2003).pdf`, marcas `<!-- page N -->` en `books/programming-in-prolog/`); la numeración impresa es 14 páginas menor (p. ej. PDF 37 = p. 23 impresa).
- **Alcance:** todos los ejercicios numerados del libro (1.1–9.4), las preguntas "resolvé vos" que aparecen dentro del texto, el ejercicio que el Apéndice B deja al lector, los 26 proyectos del capítulo 11 y los ejemplos resueltos que sirven como ejercicio (marcados "adaptado del ejemplo"). Las entradas se numeran en orden de aparición dentro de cada capítulo; la correspondencia con la numeración del libro figura en **Fuente**.
- **Enunciados:** redactados en castellano con palabras propias y condensados; no son traducciones. Consultar la página indicada para el original. El código de los enunciados corrige los errores de OCR del texto convertido (`O`/`0`, `l`/`1`, `tikes`→`likes`, etc.).
- **Soluciones:** "en el libro" remite al Apéndice A o al ejemplo resuelto en el texto; las soluciones escritas aquí se verificaron con SWI-Prolog 9.2.9.
- **Diferencias con SWI-Prolog que se repiten:** el libro usa Prolog estándar ISO; SWI-Prolog responde `true`/`false` en lugar de `yes`/`no`; una consulta a un predicado inexistente da error de existencia (no `no`); `[]` no es un átomo y el functor de las listas es `'[|]'`, no `'.'`; no se pueden redefinir `sort/2`, `findall/3`, `\+/1`, `->/2`, pero sí los predicados de biblioteca (`member/2`, `append/3`, `last/2`, `delete/3`, `gensym/2`, `maplist/3`...), aunque conviene renombrarlos para no confundirse.
- **Etiquetas de tema:** 0 Entorno · 1 Hechos, consultas, variables · 2 Reglas y conjunciones · 3 Términos y unificación · 4 Búsqueda, resolución, backtracking · 5 Recursión · 6 Listas · 7 Aritmética · 8 Corte y negación · 9 Todas las soluciones y orden superior · 10 Base de datos dinámica · 11 Prolog y SQL · A DCG/gramáticas · X Avanzado/fuera de alcance.

**Total: 167 entradas.** 24 ejercicios numerados del libro (1.1–1.4, 2.1, 3.1, 4.1, 5.1–5.2, 6.1, 7.1–7.9, 8.1, 9.1–9.4), 7 propuestas dentro del texto o del Apéndice B, 26 proyectos del capítulo 11 y 110 ejemplos adaptados (dos de ellos, CM-7.28 y CM-7.29, incluyen además propuestas del texto).

| Tema | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | A | X |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Entradas | 12 | 6 | 10 | 26 | 25 | 26 | 38 | 24 | 20 | 10 | 8 | 0 | 18 | 31 |

Una entrada con varios temas cuenta en cada uno. Dificultad: 47 de nivel 1, 88 de nivel 2, 32 de nivel 3. SWISH: 144 sí, 7 parcial, 11 no (E/S de caracteres o archivos, `consult`), 5 no aplica (ejercicios de papel del capítulo 10). El libro no trata Prolog y SQL (tema 11); lo más cercano son las bases de hechos de los capítulos 1–2 y CM-11.26.

## Capítulo 1: Introducción tutorial

### CM-1.1 — Traducir frases a hechos
- **Fuente:** Clocksin & Mellish, cap. 1 §1.4, p. 18–20 (adaptado del ejemplo)
- **Tema:** 1
- **Dificultad:** 1
- **Solución:** en el libro (p. 19–20)
- **SWISH:** sí
- **Enunciado:** Escribir como hechos Prolog: "el oro es valioso", "Jane es mujer", "Jane tiene oro", "John es el padre de Mary", "John le da el libro a Mary" y "John y Mary juegan al fútbol". Fijar por escrito, para cada predicado, qué significa cada argumento.
- **Notas:** Los nombres de predicados y constantes empiezan con minúscula. Lo importante es elegir un orden de argumentos y respetarlo: `father(john, mary)` y `father(mary, john)` son hechos distintos.

### CM-1.2 — Preguntas de sí o no
- **Fuente:** Clocksin & Mellish, cap. 1 §1.5, p. 21 (adaptado del ejemplo)
- **Tema:** 1
- **Dificultad:** 1
- **Solución:** en el libro (p. 21)
- **SWISH:** sí
- **Enunciado:** Cargar la base siguiente y predecir, antes de ejecutarlas, la respuesta a `likes(joe, money)`, `likes(mary, joe)`, `likes(mary, book)` y `king(john, france)`.
  ```prolog
  likes(joe, fish).   likes(joe, mary).    likes(mary, book).
  likes(john, book).  likes(john, france).
  ```
- **Notas:** SWI-Prolog responde `true`/`false`. Para `king/2`, que no tiene cláusulas, SWI no responde `false`: lanza un error "Unknown procedure". Un error frecuente es escribir `Likes(...)`: con mayúscula es un error de sintaxis.

### CM-1.3 — No demostrable no es lo mismo que falso
- **Fuente:** Clocksin & Mellish, cap. 1 §1.5, p. 21–22 (adaptado del ejemplo)
- **Tema:** 1
- **Dificultad:** 1
- **Solución:** en el libro (p. 21–22)
- **SWISH:** sí
- **Enunciado:** Con la base de abajo, consultar `athenian(socrates)`, `athenian(aristotle)` y `greek(socrates)`. Explicar por qué la segunda respuesta no significa que Aristóteles no haya sido ateniense y qué pasa con la tercera.
  ```prolog
  human(socrates).  human(aristotle).  athenian(socrates).
  ```
- **Notas:** Introduce la suposición de mundo cerrado. En SWI `greek/1` produce un error de existencia; se puede declarar `:- dynamic greek/1.` para que simplemente falle.

### CM-1.4 — Variables y respuestas múltiples
- **Fuente:** Clocksin & Mellish, cap. 1 §1.6, p. 22–24 (adaptado del ejemplo)
- **Tema:** 1, 4
- **Dificultad:** 1
- **Solución:** en el libro (p. 24)
- **SWISH:** sí
- **Enunciado:** Con `likes(john, flowers). likes(john, mary). likes(paul, mary).`, preguntar qué le gusta a John y quién quiere a Mary, pidiendo todas las respuestas con `;`. Explicar en qué orden aparecen y por qué.
- **Notas:** Las respuestas siguen el orden textual de los hechos. En SWISH se piden más soluciones con el botón *Next*.

### CM-1.5 — Conjunciones en una consulta
- **Fuente:** Clocksin & Mellish, cap. 1 §1.7, p. 24–25 (adaptado del ejemplo)
- **Tema:** 2, 4
- **Dificultad:** 1
- **Solución:** en el libro (p. 25–27)
- **SWISH:** sí
- **Enunciado:** Con la base de abajo, escribir una consulta que pregunte si John y Mary se gustan mutuamente y otra que pregunte qué cosa les gusta a ambos.
  ```prolog
  likes(mary, food).  likes(mary, wine).  likes(john, wine).  likes(john, mary).
  ```
- **Notas:** La coma es "y"; la variable compartida `X` en `likes(mary, X), likes(john, X)` obliga a que ambos objetivos se refieran al mismo objeto.

### CM-1.6 — Continuar la simulación a mano (Ejercicio 1.1)
- **Fuente:** Clocksin & Mellish, cap. 1 §1.7, p. 30 (Exercise 1.1)
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** Tras `X = wine`, al pedir otra respuesta se reintenta `likes(john, wine)` desde su marca: no hay otro hecho que unifique y falla. Se vuelve a `likes(mary, X)`, se olvida `X = wine` y se busca después de `likes(mary, wine)`: `likes(john, wine)` y `likes(john, mary)` no unifican con `likes(mary, X)`. El primer objetivo falla, la conjunción falla y Prolog responde `false`.
- **SWISH:** sí
- **Enunciado:** Con la base y la consulta `likes(mary, X), likes(john, X)` de CM-1.5, continuar la simulación con lápiz y papel (marcas de posición y ligaduras) a partir de la primera respuesta, cuando el usuario pide otra con `;`.
- **Notas:** Conviene confirmar la simulación con `trace.` en `swipl` (o el trazador gráfico de SWISH).

### CM-1.7 — De reglas en castellano a reglas Prolog
- **Fuente:** Clocksin & Mellish, cap. 1 §1.8, p. 30–31 (adaptado del ejemplo)
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** en el libro (p. 31)
- **SWISH:** sí
- **Enunciado:** Escribir en Prolog: "a John le gusta cualquiera a quien le guste el vino", "a John le gusta quien guste del vino y de la comida", "a John le gusta toda mujer a la que le guste el vino" y "X es un pájaro si es un animal y tiene plumas".
- **Notas:** Dentro de una cláusula, todas las apariciones de una variable denotan el mismo objeto; en otra cláusula (o en otro uso de la misma) es otra variable.

### CM-1.8 — Seguir `sister_of` paso a paso
- **Fuente:** Clocksin & Mellish, cap. 1 §1.8, p. 32–34 (adaptado del ejemplo)
- **Tema:** 0, 2
- **Dificultad:** 1
- **Solución:** en el libro (p. 33–34)
- **SWISH:** sí
- **Enunciado:** Cargar la base de la familia de la reina Victoria y la regla `sister_of`; activar `trace` y seguir `sister_of(alice, edward)` y luego `sister_of(alice, X)`, anotando qué variable se liga en cada paso.
  ```prolog
  male(albert).  male(edward).  female(alice).  female(victoria).
  parents(edward, victoria, albert).  parents(alice, victoria, albert).
  sister_of(X, Y) :- female(X), parents(X, M, F), parents(Y, M, F).
  ```
- **Notas:** `parents(X, M, F)` significa "los padres de X son M (madre) y F (padre)". Buen primer contacto con `trace.` (teclas: Enter avanza, `s` salta, `a` aborta).

### CM-1.9 — Todas las hermanas (Ejercicio 1.2)
- **Fuente:** Clocksin & Mellish, cap. 1 §1.9, p. 37 (Exercise 1.2)
- **Tema:** 2, 4
- **Dificultad:** 2
- **Solución:** `sister_of(alice, X)` da `X = edward` y, al pedir otra, `X = alice`: el tercer objetivo `parents(Y, victoria, albert)` también unifica con el hecho de Alice. `sister_of(X, Y)` da `alice-edward` y `alice-alice` (verificado en SWI-Prolog 9.2.9).
- **SWISH:** sí
- **Enunciado:** Con la base y la regla de CM-1.8, explicar cómo se obtienen todas las respuestas de `sister_of(alice, X)` al pedir más soluciones y cuáles son.
- **Notas:** La respuesta "Alice es hermana de sí misma" motiva el ejercicio CM-1.12.

### CM-1.10 — ¿Por qué John puede robar a Mary?
- **Fuente:** Clocksin & Mellish, cap. 1 §1.8, p. 34–36 (adaptado del ejemplo)
- **Tema:** 2, 4
- **Dificultad:** 2
- **Solución:** en el libro (p. 35–36)
- **SWISH:** sí
- **Enunciado:** Con el programa de abajo, consultar `may_steal(john, X)` y explicar, cláusula por cláusula, cómo se llega a `X = mary`. ¿Qué hecho no interviene?
  ```prolog
  thief(john).
  likes(mary, chocolate).
  likes(mary, wine).
  likes(john, X) :- likes(X, wine).
  may_steal(X, Y) :- thief(X), likes(X, Y).
  ```
- **Notas:** Muestra que un programa correcto en lo lógico puede dar conclusiones inesperadas, y que la `X` de cada cláusula es independiente de la `X` de las otras.

### CM-1.11 — Relaciones familiares (Ejercicio 1.3)
- **Fuente:** Clocksin & Mellish, cap. 1 §1.9, p. 37–38 (Exercise 1.3)
- **Tema:** 2
- **Dificultad:** 2
- **Solución:** en el libro (Apéndice A, p. 281)
- **SWISH:** sí
- **Enunciado:** Suponiendo definidos `father/2`, `mother/2`, `male/1`, `female/1`, `parent/2` y `diff/2` (dos objetos distintos), definir `is_mother/1`, `is_father/1`, `is_son/1`, `sister_of/2`, `grandpa_of/2` y `sibling/2`.
- **Notas:** Para probarlo hay que inventar una pequeña base familiar y definir `diff(X, Y) :- X \= Y.` (o usar `dif/2`). El apéndice escribe `granpa_of`; `is_son/1` repite respuestas si ambos padres están en la base.

### CM-1.12 — Nadie es su propia hermana (Ejercicio 1.4)
- **Fuente:** Clocksin & Mellish, cap. 1 §1.9, p. 38 (Exercise 1.4)
- **Tema:** 2, 8
- **Dificultad:** 2
- **Solución:** El cuerpo no exige que X e Y sean distintos, así que Y puede tomar el mismo valor que X. Corrección (verificada: solo queda `alice-edward`):
  ```prolog
  sister_of(X, Y) :- female(X), parents(X, M, F), parents(Y, M, F), X \= Y.
  ```
- **SWISH:** sí
- **Enunciado:** Explicar por qué, con la regla `sister_of` del texto, alguien puede resultar hermana de sí misma, y modificarla para evitarlo usando `diff/2`.
- **Notas:** `X \= Y` es "no unificables": debe ir al final, cuando ambas variables ya están ligadas; con variables libres fallaría siempre. `dif/2` no tiene esa restricción.

## Capítulo 2: Una mirada más de cerca

### CM-2.1 — ¿Átomo, número, variable o nada?
- **Fuente:** Clocksin & Mellish, cap. 2 §2.1, p. 40–41 (adaptado del ejemplo)
- **Tema:** 1, 3
- **Dificultad:** 1
- **Solución:** en el libro (p. 40–41)
- **SWISH:** sí
- **Enunciado:** Clasificar cada término como átomo, número, variable o "no es átomo": `a`, `void`, `=`, `'george-smith'`, `-->`, `george_smith`, `ieh2304`, `2304ieh`, `george-smith`, `Void`, `_alpha`, `-17`, `6.02e-23`. Comprobar con `atom/1`, `number/1` y `var/1`.
- **Notas:** `george-smith` es un término válido, pero compuesto (`-(george, smith)`); `2304ieh` es un error de sintaxis. `_alpha` es una variable, no la variable anónima.

### CM-2.2 — Estructuras dentro de hechos
- **Fuente:** Clocksin & Mellish, cap. 2 §2.1.3, p. 42–43 (adaptado del ejemplo)
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** en el libro (p. 42–43)
- **SWISH:** sí
- **Enunciado:** Representar con estructuras que John tiene *Wuthering Heights* de Emily Brontë y *Ulysses* de James Joyce (ejemplar 3129). Consultar si John tiene algún libro de alguna Brontë, primero obteniendo título y nombre y luego con variables anónimas.
- **Notas:** Cada `_` es una variable distinta. Una estructura no se "evalúa": `book(...)` es solo un dato.

### CM-2.3 — Operadores, precedencia y asociatividad
- **Fuente:** Clocksin & Mellish, cap. 2 §2.3, p. 44–46 (adaptado del ejemplo)
- **Tema:** 3, 7
- **Dificultad:** 1
- **Solución:** Verificado con `write_canonical/1`: `a-b/c` es `-(a,/(b,c))`; `5+8/2/2` es `+(5,/(/(8,2),2))`; `X is 8/2/2` da `2`.
- **SWISH:** sí
- **Enunciado:** Dibujar el árbol de `x + y * z`, `a - b / c`, `8 / 2 / 2` y `5 + 8 / 2 / 2`, y confirmarlo con `write_canonical/1`. Explicar por qué `3 + 4` no es lo mismo que `7`.
- **Notas:** Los operadores aritméticos son asociativos a izquierda (`yfx`). `3+4` es la estructura `+(3,4)`; solo `is` la evalúa.

### CM-2.4 — ¿Unifican? (Ejercicio 2.1)
- **Fuente:** Clocksin & Mellish, cap. 2 §2.4, p. 47 (Exercise 2.1)
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** (verificada) 1) no; 2) sí, `X = X1, Y = Y1, Z = Z1`; 3) no; 4) no; 5) sí, sin ligaduras; 6) no; 7) sí, `X = b, Z = b`.
- **SWISH:** sí
- **Enunciado:** Decir si cada objetivo tiene éxito y qué ligaduras produce:
  ```prolog
  pilots(A, london) = pilots(london, paris)
  point(X, Y, Z) = point(X1, Y1, Z1)
  letter(C) = word(letter)
  noun(alpha) = alpha
  'student' = student
  f(X, X) = f(a, b)
  f(X, a(b, c)) = f(Z, a(Z, c))
  ```
- **Notas:** El texto OCR dice `pans` y `'studenf`: son `paris` y `'student'`. En el último caso, `Z = b` sale de `a(b,c) = a(Z,c)` y se propaga a `X` porque `X = Z`.

### CM-2.5 — Príncipes de Gales
- **Fuente:** Clocksin & Mellish, cap. 2 §2.5, p. 48–49 (adaptado del ejemplo)
- **Tema:** 7
- **Dificultad:** 1
- **Solución:** en el libro (p. 49)
- **SWISH:** sí
- **Enunciado:** Dada una tabla `reigns(Principe, Desde, Hasta)`, definir `prince(X, Y)`: X reinaba en el año Y. Probar `prince(cadwallon, 986)`, `prince(X, 900)` y `prince(X, 979)`.
  ```prolog
  reigns(rhodri, 844, 878).        reigns(anarawd, 878, 916).
  reigns(hywel_dda, 916, 950).     reigns(lago_ap_idwal, 950, 979).
  reigns(hywel_ap_ieuaf, 979, 985). reigns(cadwallon, 985, 986).
  reigns(maredudd, 986, 999).
  ```
- **Notas:** En el OCR los nombres aparecen con mayúscula (`Lago_apJdwal`), lo que los convertiría en variables. Los comparadores (`>=`, `=<`) exigen argumentos ya ligados: `prince(X, Y)` con `Y` libre da error de instanciación.

### CM-2.6 — Densidad de población
- **Fuente:** Clocksin & Mellish, cap. 2 §2.5, p. 50–51 (adaptado del ejemplo)
- **Tema:** 7
- **Dificultad:** 1
- **Solución:** en el libro (p. 50–51)
- **SWISH:** sí
- **Enunciado:** Con `pop(País, Millones)` y `area(País, MillonesDeMillas2)`, definir `density(País, D)` y consultarla para todos los países. ¿Qué pasa con un país sin datos?
  ```prolog
  pop(usa, 203). pop(india, 548). pop(china, 800). pop(brazil, 108).
  area(usa, 3).  area(india, 1).  area(china, 4).  area(brazil, 3).
  ```
- **Notas:** En SWI `/` da entero si la división es exacta (`800/4` → `200`) y real si no (`203/3` → `67.666…`); `//` es división entera (trunca hacia cero) y `mod` el resto.

### CM-2.7 — El flujo de satisfacción
- **Fuente:** Clocksin & Mellish, cap. 2 §2.6, p. 52–57 (adaptado del ejemplo)
- **Tema:** 0, 4
- **Dificultad:** 2
- **Solución:** en el libro (p. 52–57, figuras 2.1–2.6)
- **SWISH:** sí
- **Enunciado:** Con el programa de abajo, dibujar las "cajas" de la consulta `female(mary), parent(mary, M, F), parent(john, M, F)` y marcar en qué punto se elige cada cláusula y se ligan `M` y `F`. Luego suponer que el último objetivo falla y describir el retroceso. Contrastar con `trace`.
  ```prolog
  female(mary).
  parent(C, M, F) :- mother(C, M), father(C, F).
  mother(john, ann). mother(mary, ann).
  father(mary, fred). father(john, fred).
  ```
- **Notas:** Al reintentar un objetivo se deshacen las ligaduras que ese objetivo había hecho.

### CM-2.8 — ¿Qué hecho unifica con `sum(2+3)`?
- **Fuente:** Clocksin & Mellish, cap. 2 §2.6.3, p. 58–59 (adaptado del ejemplo)
- **Tema:** 3, 7
- **Dificultad:** 1
- **Solución:** en el libro (p. 59); verificado: solo unifica `sum(X + Y)`, con `X = 2, Y = 3`.
- **SWISH:** sí
- **Enunciado:** Con los hechos `sum(5). sum(3). sum(X + Y).`, decir cuál unifica con la consulta `sum(2 + 3)` y con qué ligaduras. Luego definir `add(X, Y, Z)` que calcule la suma de verdad.
- **Notas:** Error típico: creer que `sum(2+3)` unifica con `sum(5)`. `add(X, Y, Z) :- Z is X + Y.` necesita `X` e `Y` ligados.

## Capítulo 3: Uso de estructuras de datos

### CM-3.1 — Estructuras como árboles
- **Fuente:** Clocksin & Mellish, cap. 3 §3.1, p. 61–64 (adaptado del ejemplo)
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** en el libro (p. 61–64)
- **SWISH:** sí
- **Enunciado:** Dibujar el árbol de `parents(charles, elizabeth, philip)`, `a+b*c`, `book(moby_dick, author(herman, melville))` y `sentence(noun(john), verb_phrase(verb(likes), noun(mary)))`. Para `f(X, g(X, a))`, indicar cómo se ve que las dos `X` son la misma variable.
- **Notas:** Dos estructuras distintas pueden tener árboles de la misma forma; la unificación compara forma y hojas.

### CM-3.2 — Cabeza y cola de listas
- **Fuente:** Clocksin & Mellish, cap. 3 §3.2, p. 64–67 (adaptado del ejemplo, tablas 3.1 y 3.2)
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** en el libro (p. 66–67)
- **SWISH:** sí
- **Enunciado:** Dar cabeza y cola de `[a,b,c]`, `[]`, `[[the,cat],sat]`, `[the,[cat,sat]]` y `[X+Y, x+y]`. Decir si unifican y con qué ligaduras: `[X,Y,Z]` con `[john,likes,fish]`; `[cat]` con `[X|Y]`; `[X,Y|Z]` con `[mary,likes,wine]`; `[[the,Y]|Z]` con `[[X,hare],[is,here]]`; `[golden|T]` con `[golden,norfolk]`; `[vale,horse]` con `[horse,X]`; `[white|Q]` con `[P|horse]`.
- **Notas:** `[white|horse]` es un término válido pero no una lista propia (su cola no es lista): `is_list([white|horse])` falla. `[]` no tiene cabeza ni cola.

### CM-3.3 — Pertenencia a una lista
- **Fuente:** Clocksin & Mellish, cap. 3 §3.3, p. 67–69 (adaptado del ejemplo)
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** en el libro (p. 68–69)
- **SWISH:** sí
- **Enunciado:** Definir `member(X, L)` con un caso base y un caso recursivo, identificar las dos condiciones de corte de la recursión y seguir a mano `member(clygate, [curragh_tip, music_star, park_mill, portland])`.
- **Notas:** `member/2` ya existe en SWI (biblioteca `lists`); definirlo en el propio archivo lo reemplaza, pero conviene llamarlo `pertenece/2` o `mem/2` para no confundirse.

### CM-3.4 — Definiciones circulares y recursión a izquierda
- **Fuente:** Clocksin & Mellish, cap. 3 §3.3, p. 70 (adaptado del ejemplo)
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** en el libro (p. 70). Verificado: con el hecho primero se obtienen algunas respuestas (`adam`, …) pero al pedir más se entra igual en recursión infinita.
- **SWISH:** sí
- **Enunciado:** Explicar por qué `parent(X,Y) :- child(Y,X).` junto con `child(A,B) :- parent(B,A).` nunca termina. Luego, con el programa de abajo, explicar qué pasa con `person(X)` según el orden de las cláusulas y si alcanza con poner el hecho primero.
  ```prolog
  person(adam).
  person(X) :- person(Y), mother(X, Y).
  mother(cain, eve).  mother(seth, adam).
  ```
- **Notas:** El OCR repite la regla antes del hecho en la versión "corregida"; el libro quiso poner el hecho primero. La solución real es reordenar los objetivos: `person(X) :- mother(X, Y), person(Y).` En SWI la recursión infinita termina con "Stack limit exceeded".

### CM-3.5 — `islist` y la variable libre
- **Fuente:** Clocksin & Mellish, cap. 3 §3.3, p. 70–71 (adaptado del ejemplo)
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** en el libro (p. 71)
- **SWISH:** sí
- **Enunciado:** Con `islist([_|B]) :- islist(B).` seguida de `islist([]).`, probar `islist([a,b,c,d])`, `islist([])`, `islist(f(1,2,3))` e `islist(X)`, y explicar el cuelgue del último caso. Comparar con `weak_islist([]). weak_islist([_|_]).`
- **Notas:** SWI trae `is_list/1`, que no enumera listas: con una variable falla.

### CM-3.6 — Transformar oraciones (`alter`)
- **Fuente:** Clocksin & Mellish, cap. 3 §3.4, p. 71–74 (adaptado del ejemplo)
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** en el libro (p. 73–74); verificado: pidiendo más respuestas aparecen también `[i,are,a,computer]`, `[you,[am,not],a,computer]` y `[you,are,a,computer]`.
- **SWISH:** sí
- **Enunciado:** Definir `alter(Lista, Nueva)` que reemplace cada palabra según una tabla `change/2` con una cláusula comodín `change(X, X)` al final. Probar `alter([you,are,a,computer], Z)`, pedir más respuestas y explicar por qué aparecen.
  ```prolog
  change(you, i).  change(are, [am,not]).  change(french, german).
  change(do, no).  change(X, X).
  ```
- **Notas:** El comodín también unifica con palabras que tienen cambio; al retroceder se obtienen versiones parcialmente sin cambiar. Se arregla con un corte o con una condición en el comodín (ver capítulo 4).

### CM-3.7 — Consumo significativamente mejor (Ejercicio 3.1)
- **Fuente:** Clocksin & Mellish, cap. 3 §3.5, p. 74–77 (Exercise 3.1)
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** Tomando "significativamente mejor" como al menos 10 % menos consumo (verificado: la relación `prefer` pasa de 6 pares a 4):
  ```prolog
  significantly_better(Good, Bad) :- Good < Bad * 0.9.
  sometimes_sig_better([C1|_], [C2|_]) :- significantly_better(C1, C2), !.
  sometimes_sig_better([_|T1], [_|T2]) :- sometimes_sig_better(T1, T2).
  prefer(A, B) :- fuel_consumed(A, CA), fuel_consumed(B, CB), A \= B,
                  sometimes_sig_better(CA, CB).
  ```
- **SWISH:** sí
- **Enunciado:** Con `fuel_consumed(Auto, Consumos)` y `sometimes_better/2` (algún recorrido con consumo igual o mejor), casi cualquier auto resulta preferible a otro. Cambiar el programa para preferir un auto si es *significativamente* mejor en al menos un recorrido, definiendo qué significa "significativamente".
  ```prolog
  fuel_consumed(waster,   [3.1, 10.4, 15.9, 10.3]).
  fuel_consumed(guzzler,  [3.2,  9.9, 13.0, 11.6]).
  fuel_consumed(prodigal, [2.8,  9.8, 13.1, 10.4]).
  ```
- **Notas:** Sin el corte, cada recorrido mejor genera una respuesta repetida. El libro define "igual o mejor" como menos de 5 % sobre el promedio (p. 75).

### CM-3.8 — `append` en todas las direcciones
- **Fuente:** Clocksin & Mellish, cap. 3 §3.6, p. 77–78 (adaptado del ejemplo)
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** en el libro (p. 77–78)
- **SWISH:** sí
- **Enunciado:** Definir `append/3` y usarlo para concatenar `[alpha,beta]` y `[gamma,delta]`, para hallar `X` en `append(X, [b,c,d], [a,b,c,d])` y para enumerar todas las formas de partir `[a,b,c]` en dos.
- **Notas:** Ya existe en SWI; si se redefine, conviene llamarlo `concatenar/3` o `app/3`.

### CM-3.9 — Partes de una bicicleta
- **Fuente:** Clocksin & Mellish, cap. 3 §3.6, p. 78–80 (adaptado del ejemplo)
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** en el libro (p. 80); verificado: `partsof(wheel, P)` da `[spoke,rim,gears,bolt,nut]`.
- **SWISH:** sí
- **Enunciado:** Con hechos `basicpart/1` y `assembly(Ensamble, Subpartes)`, definir `partsof(X, P)`: P es la lista de piezas básicas necesarias para armar X (con repeticiones). Usar un predicado auxiliar que recorra la lista de subpartes.
  ```prolog
  basicpart(rim). basicpart(spoke). basicpart(rearframe). basicpart(handles).
  basicpart(gears). basicpart(bolt). basicpart(nut). basicpart(fork).
  assembly(bike, [wheel, wheel, frame]).  assembly(wheel, [spoke, rim, hub]).
  assembly(frame, [rearframe, frontframe]). assembly(frontframe, [fork, handles]).
  assembly(hub, [gears, axle]).           assembly(axle, [bolt, nut]).
  ```
- **Notas:** Recursión mutua entre `partsof/2` y `partsoflist/2`. El OCR escribe `fTontframe`.

### CM-3.10 — Generar oraciones con el inventario de partes
- **Fuente:** Clocksin & Mellish, cap. 3 §3.6, p. 80–81 (propuesta dentro del texto)
- **Tema:** 6, A
- **Dificultad:** 2
- **Solución:** Reutilizando `partsof/2` de CM-3.9 con esta "gramática" se generan 16 oraciones, entre ellas `[the,apple,is,a,fruit]` (verificado):
  ```prolog
  assembly(sentence, [noun_phrase, verb_phrase]).
  assembly(noun_phrase, [determiner, noun]).
  assembly(verb_phrase, [verb, noun_phrase]).
  assembly(determiner, [the]).  assembly(determiner, [a]).
  assembly(noun, [apple]).      assembly(noun, [fruit]).
  assembly(verb, [is]).
  basicpart(the). basicpart(a). basicpart(apple). basicpart(fruit). basicpart(is).
  ```
- **SWISH:** sí
- **Enunciado:** Usar el programa de partes como generador de oraciones: tratar las categorías gramaticales como ensambles y las palabras como piezas básicas, y comprobar que al retroceder salen todas las oraciones que admite la gramática (por ejemplo, "the apple is a fruit").
- **Notas:** Anticipa las gramáticas del capítulo 9. El OCR escribe `basicpart(apples)`: debe coincidir con la palabra usada (`apple`).

### CM-3.11 — Largo de una lista, con y sin acumulador
- **Fuente:** Clocksin & Mellish, cap. 3 §3.7, p. 81–82 (adaptado del ejemplo)
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** en el libro (p. 81–82)
- **SWISH:** sí
- **Enunciado:** Definir `listlen(L, N)` de dos maneras: sumando 1 a la longitud de la cola y con un acumulador `lenacc(L, Acumulado, N)`. Escribir la secuencia de objetivos `lenacc` para `[a,b,c,d,e]`.
- **Notas:** En la versión sin acumulador, `N is N1 + 1` debe ir después de la llamada recursiva. SWI trae `length/2`.

### CM-3.12 — Inventario con acumulador
- **Fuente:** Clocksin & Mellish, cap. 3 §3.7, p. 83–84 (adaptado del ejemplo)
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** en el libro (p. 83–84); verificado: `[nut,bolt,gears,rim,spoke]` para `wheel`.
- **SWISH:** sí
- **Enunciado:** Reescribir `partsof/2` de CM-3.9 sin `append/3`, pasando como acumulador la lista de partes ya encontradas. Comparar el orden del resultado con el de la versión original y explicar la diferencia.
- **Notas:** Con acumulador los elementos quedan en orden inverso; para oraciones (CM-3.10) eso es un problema.

### CM-3.13 — Inventario con listas de diferencia
- **Fuente:** Clocksin & Mellish, cap. 3 §3.8, p. 84–86 (adaptado del ejemplo)
- **Tema:** 6
- **Dificultad:** 3
- **Solución:** en el libro (p. 86); verificado: recupera el orden original `[spoke,rim,gears,bolt,nut]`.
- **SWISH:** sí
- **Enunciado:** Reescribir `partsof/2` con listas de diferencia (`partsacc(X, Lista, Hueco)`) para evitar `append/3` y conservar el orden original. Explicar qué produce la consulta `Res = [a,b,c|X], p(X, H), H = [z]` con `p([d|H], H).`
- **Notas:** El OCR escribe `NewHole - [z]` y `Hole= f]`: son `NewHole = [z]` y `Hole = []`. Es la técnica que usan internamente las DCG.

## Capítulo 4: Retroceso y el corte

### CM-4.1 — Orden de las soluciones
- **Fuente:** Clocksin & Mellish, cap. 4 §4.1, p. 88–90 (adaptado del ejemplo)
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** en el libro (p. 88–90)
- **SWISH:** sí
- **Enunciado:** Con los hechos `father(Hijo, Padre)` de abajo, predecir en orden todas las respuestas de `father(X, Y)`, `father(_, X)`, `child(X, Y)` con `child(X, Y) :- father(Y, X).` y `person(X)` para el programa `person` mezclado. ¿Por qué `george` aparece dos veces?
  ```prolog
  father(mary, george). father(john, george). father(sue, harry). father(george, edward).
  person(adam).
  person(X) :- mother(X, _).
  person(eve).
  mother(cain, eve). mother(abel, eve). mother(jabal, adah). mother(tubalcain, zillah).
  ```
- **Notas:** Prolog no recuerda respuestas anteriores: dos demostraciones distintas del mismo hecho son dos respuestas. SWI avisa que las cláusulas de `person/1` no están juntas ("discontiguous"); se silencia con `:- discontiguous person/1.`

### CM-4.2 — Parejas de baile
- **Fuente:** Clocksin & Mellish, cap. 4 §4.1, p. 90–91 (adaptado del ejemplo)
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** en el libro (p. 90–91)
- **SWISH:** sí
- **Enunciado:** Definir `possible_pair(X, Y) :- boy(X), girl(Y).` con cuatro chicos y tres chicas, predecir el orden de las 12 respuestas y explicar qué objetivo se reintenta en cada paso.
- **Notas:** El objetivo de más a la derecha "gira más rápido", como el dígito menos significativo de un contador.

### CM-4.3 — Un generador infinito
- **Fuente:** Clocksin & Mellish, cap. 4 §4.1, p. 91–93 (adaptado del ejemplo)
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** en el libro (p. 91–93)
- **SWISH:** sí
- **Enunciado:** Con `is_integer(0).` y `is_integer(X) :- is_integer(Y), X is Y + 1.`, explicar por qué `is_integer(X)` genera 0, 1, 2, … al pedir más respuestas, dibujando las elecciones que llevan a las tres primeras. ¿Qué pasa con `is_integer(-1)`?
- **Notas:** `is_integer(-1)` no termina: el generador nunca se agota. SWI trae `between(0, inf, X)`, que hace lo mismo.

### CM-4.4 — `member` como generador
- **Fuente:** Clocksin & Mellish, cap. 4 §4.1, p. 94 (propuesta dentro del texto)
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** Verificado: `member(a, X)` da `[a|_]`, `[_,a|_]`, `[_,_,a|_]`, …; `member(a, [a,b,r,a,c,a,d,a,b,r,a])` tiene éxito 5 veces, una por cada `a`.
- **SWISH:** sí
- **Enunciado:** Explicar qué valores sucesivos toma `X` en `member(a, X)` y por qué `member(a, [a,b,r,a,c,a,d,a,b,r,a])` tiene éxito más de una vez. ¿Cuántas?
- **Notas:** Si solo interesa saber si está, SWI ofrece `memberchk/2`, que no deja puntos de elección.

### CM-4.5 — Servicios de la biblioteca
- **Fuente:** Clocksin & Mellish, cap. 4 §4.2, p. 94–98 (adaptado del ejemplo)
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** en el libro (p. 96–98)
- **SWISH:** sí
- **Enunciado:** Una persona con un libro vencido solo tiene acceso a los servicios básicos; el resto accede también a los adicionales. Programarlo con un corte, consultar `client(X), facility(X, Y)` y explicar qué alternativas descarta el corte.
  ```prolog
  facility(Pers, Fac) :- book_overdue(Pers, _Book), !, basic_facility(Fac).
  facility(_Pers, Fac) :- general_facility(Fac).
  ```
- **Notas:** El corte fija la elección de la primera cláusula y del primer libro vencido encontrado, pero no impide retroceder dentro de `basic_facility/1`, que está a su derecha.

### CM-4.6 — `sum_to` sin corte (Ejercicio 4.1)
- **Fuente:** Clocksin & Mellish, cap. 4 §4.3.1, p. 99–101 (Exercise 4.1)
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** La primera respuesta sigue siendo `15`. Al retroceder, `sum_to(1, X)` también unifica con la segunda cláusula, que llama a `sum_to(0, _)`, `sum_to(-1, _)`, … sin fin: no hay respuestas alternativas, solo recursión infinita (en SWI 9.2.9, "Stack limit (1.0Gb) exceeded").
- **SWISH:** sí
- **Enunciado:** Con la versión de abajo sin el corte, ¿qué pasa si el retroceso vuelve a `sum_to(1, X)`? ¿Hay resultados alternativos? ¿Por qué?
  ```prolog
  sum_to(1, 1).
  sum_to(N, Res) :- N1 is N - 1, sum_to(N1, Res1), Res is Res1 + N.
  ```
- **Notas:** Probar con `sum_to(5, X)` y pedir otra respuesta con `;`.

### CM-4.7 — Cambiar el corte por una condición
- **Fuente:** Clocksin & Mellish, cap. 4 §4.3.1, p. 101–103 (adaptado del ejemplo)
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** en el libro (p. 101–102)
- **SWISH:** sí
- **Enunciado:** Escribir tres versiones de `sum_to/2`: con `N =< 1, !` en el caso base, con `\+ N = 1` en el caso recursivo y con `N > 1`. Comparar qué hace cada una con `sum_to(0, X)` y al pedir más respuestas.
- **Notas:** Con la condición explícita la segunda cláusula tiene sentido por sí sola; con el corte depende del orden de las cláusulas.

### CM-4.8 — El contribuyente promedio (corte-fail)
- **Fuente:** Clocksin & Mellish, cap. 4 §4.3.2, p. 104–106 (adaptado del ejemplo)
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** en el libro (p. 105–106)
- **SWISH:** sí
- **Enunciado:** Un extranjero nunca es contribuyente promedio. Explicar por qué `average_taxpayer(X) :- foreigner(X), fail.` seguida de la regla general no lo excluye, corregirlo con `!, fail` y luego reescribirlo con `\+`.
- **Notas:** La combinación `!, fail` significa "si llegaste acá, el objetivo padre falla". La versión con `\+` suele ser más clara.

### CM-4.9 — Definir la negación con corte-fail
- **Fuente:** Clocksin & Mellish, cap. 4 §4.3.2, p. 105–106 (adaptado del ejemplo)
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** en el libro (p. 106)
- **SWISH:** sí
- **Enunciado:** Definir `no(P)`, que tenga éxito exactamente cuando el objetivo `P` falla, usando `call/1`, el corte y `fail`. Probarlo con objetivos que tienen éxito y que fallan.
- **Notas:** `\+` no se puede redefinir en SWI ("No permission to modify static procedure"): hay que usar otro nombre. Es negación por falla, no negación lógica: `no(member(X, [a]))` falla aunque haya valores de `X` que no pertenecen.

### CM-4.10 — Ta-te-tí: jugada forzada
- **Fuente:** Clocksin & Mellish, cap. 4 §4.3.3, p. 106–109 (adaptado del ejemplo)
- **Tema:** 3, 8
- **Dificultad:** 2
- **Solución:** en el libro (p. 107–109); verificado con `b(e,x,o,e,x,e,e,e,o)` (hay jugada forzada).
- **SWISH:** sí
- **Enunciado:** Representar el tablero como `b(C1,…,C9)` con `x`, `o` o `e` (vacío) y definir las 8 líneas con `line(Tablero, A, B, C)`. Escribir `forced_move(Tablero)`, que tiene éxito si `x` amenaza completar alguna línea, y explicar dónde va el corte y para qué.
  ```prolog
  line(b(X,Y,Z,_,_,_,_,_,_), X, Y, Z).
  line(b(X,_,_,Y,_,_,Z,_,_), X, Y, Z).
  line(b(X,_,_,_,Y,_,_,_,Z), X, Y, Z).
  % ... completar las otras cinco líneas
  threatening(e, x, x).  threatening(x, e, x).  threatening(x, x, e).
  ```
- **Notas:** Patrón "generar y probar": `line/4` genera, `threatening/3` prueba y el corte final impide buscar otras amenazas. En el OCR las cláusulas de `line/4` están ilegibles.

### CM-4.11 — División entera por generar y probar
- **Fuente:** Clocksin & Mellish, cap. 4 §4.3.3, p. 109–110 (adaptado del ejemplo)
- **Tema:** 7, 8
- **Dificultad:** 2
- **Solución:** en el libro (p. 109–110); verificado: `divide(27, 6, R)` da `R = 4`.
- **SWISH:** sí
- **Enunciado:** Definir `divide(N1, N2, R)` usando solo suma y producto: generar candidatos con `is_integer/1` (CM-4.3) y probar `R*N2 =< N1 < (R+1)*N2`. Explicar qué pasa si falta el corte final y se piden más respuestas.
- **Notas:** Sin el corte, el generador sigue produciendo candidatos para siempre.

### CM-4.12 — Un corte que rompe `append`
- **Fuente:** Clocksin & Mellish, cap. 4 §4.4, p. 110 (adaptado del ejemplo)
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** en el libro (p. 110); verificado: con el corte, `app(X, Y, [a,b,c])` da solo `X = [], Y = [a,b,c]`.
- **SWISH:** sí
- **Enunciado:** Agregar un corte a la cláusula base de `append` (`app([], X, X) :- !.`) y comparar las respuestas de `app([a,b], [c], L)` y de `app(X, Y, [a,b,c])` con las de la versión sin corte.
- **Notas:** Un corte pensado para un modo de uso (primer argumento conocido) cambia el significado en otro modo.

### CM-4.13 — ¿Cuántos padres tiene Eva?
- **Fuente:** Clocksin & Mellish, cap. 4 §4.4, p. 111–112 (propuesta dentro del texto)
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** `number_of_parents(eve, 2)` no unifica con la cláusula de `eve` (el 0 no coincide con 2), así que nunca llega a su corte y la tercera cláusula tiene éxito. El libro da dos correcciones: `number_of_parents(eve, N) :- !, N = 0.` o una tercera cláusula con `\+ X = adam, \+ X = eve` (p. 111–112). Verificado en SWI: responde `true`.
- **SWISH:** sí
- **Enunciado:** Con el programa de abajo, explicar por qué `number_of_parents(eve, 2)` tiene éxito y corregirlo. ¿Funcionan las correcciones con `number_of_parents(X, Y)`?
  ```prolog
  number_of_parents(adam, 0) :- !.
  number_of_parents(eve, 0) :- !.
  number_of_parents(_, 2).
  ```
- **Notas:** Moraleja del libro: un corte solo es confiable si se sabe con qué argumentos ligados se va a llamar el predicado.

## Capítulo 5: Entrada y salida

### CM-5.1 — Buscar en titulares históricos
- **Fuente:** Clocksin & Mellish, cap. 5, p. 113–114 (adaptado del ejemplo)
- **Tema:** 1, 6
- **Dificultad:** 1
- **Solución:** en el libro (p. 114)
- **SWISH:** sí
- **Enunciado:** Guardar titulares como `event(Año, ListaDePalabras)` y definir `when(X, Año)`: la palabra X aparece en un titular de ese año. Consultar `when('Denmark', D)`.
  ```prolog
  event(1505, ['Euclid', translated, into, 'Latin']).
  event(1523, ['Christian', 'II', flees, from, 'Denmark']).
  ```
- **Notas:** Las palabras con mayúscula van entre comillas simples; si no, serían variables.

### CM-5.2 — Imprimir listas con sangría
- **Fuente:** Clocksin & Mellish, cap. 5 §5.1.2, p. 115–117 (adaptado del ejemplo)
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** en el libro (p. 116–117); verificado con `pp([1,2,[3,4],5,6], 0)`.
- **SWISH:** sí
- **Enunciado:** Definir `pp(Lista, Columna)` que escriba un elemento por línea y las sublistas desplazadas 3 columnas a la derecha, con un auxiliar `spaces(N)` que escriba N espacios.
- **Notas:** El OCR escribe `spaces(O)`, `write('')` y `PPX([L_)-`: son `spaces(0) :- !.`, `write(' ')` y `ppx([], _).`. SWI ofrece `tab(N)` en lugar de `spaces/1`.

### CM-5.3 — `write` y `write_canonical`
- **Fuente:** Clocksin & Mellish, cap. 5 §5.1.2, p. 117–118 (adaptado del ejemplo)
- **Tema:** 3, 6
- **Dificultad:** 1
- **Solución:** en el libro (p. 117–118)
- **SWISH:** sí
- **Enunciado:** Definir `phh(Lista)` que imprima una lista de palabras separadas por espacios y usarlo para mostrar todos los titulares que mencionan `'England'`. Comparar la salida de `write(a+b*c*c)` y `write_canonical(a+b*c*c)`.
- **Notas:** `write_canonical/1` es útil para ver cómo quedaron agrupados los operadores. Varios Prolog viejos llaman `display/1` a algo parecido.

### CM-5.4 — Leer una fecha con `read/1`
- **Fuente:** Clocksin & Mellish, cap. 5 §5.1, p. 114–118 (adaptado del ejemplo)
- **Tema:** X
- **Dificultad:** 1
- **Solución:** en el libro (p. 115 y 118)
- **SWISH:** parcial (SWISH pide la entrada en un cuadro de diálogo; en `swipl` es más natural)
- **Enunciado:** Escribir `hello2`, que pregunte qué fecha interesa, lea un año con `read/1` y muestre con `phh/1` el titular correspondiente. ¿Qué pasa con `read/1` al retroceder?
- **Notas:** El término leído debe terminar con punto (`1523.`). `read/1` no se reintenta al retroceder: falla.

### CM-5.5 — Detector de errores de tipeo
- **Fuente:** Clocksin & Mellish, cap. 5 §5.2.1, p. 119–120 (adaptado del ejemplo)
- **Tema:** X
- **Dificultad:** 2
- **Solución:** en el libro (p. 119–120); verificado leyendo desde un string con `open_string/2`.
- **SWISH:** no (lee caracteres de la entrada estándar)
- **Enunciado:** Escribir `check_line(OK)` que lea una línea carácter por carácter con `get_char/1` y devuelva `no` si aparece algún par de caracteres consecutivos registrado como error (`qw`, `cv`), y `yes` si no.
- **Notas:** El truco es pasar en cada llamada el carácter anterior y el actual. Para probarlo sin teclear: `open_string("texto\n", S), set_input(S), check_line(X)`.

### CM-5.6 — Corrector de errores de tipeo
- **Fuente:** Clocksin & Mellish, cap. 5 §5.2.2, p. 120–122 (adaptado del ejemplo)
- **Tema:** X
- **Dificultad:** 2
- **Solución:** en el libro (p. 121–122)
- **SWISH:** no (lee caracteres de la entrada estándar)
- **Enunciado:** Modificar `check_line` para que copie la línea a la salida con `put_char/1` reemplazando cada par erróneo por su corrección, según una tabla `typing_correction(A, B, Correccion)`.
- **Notas:** Un carácter solo se puede escribir cuando ya se leyó el siguiente y se sabe que no forman un error.

### CM-5.7 — ¿Por qué se pierden caracteres?
- **Fuente:** Clocksin & Mellish, cap. 5 §5.3, p. 122–123 (adaptado del ejemplo)
- **Tema:** 4, X
- **Dificultad:** 2
- **Solución:** en el libro (p. 123)
- **SWISH:** no (lee caracteres de la entrada estándar)
- **Enunciado:** Explicar por qué este programa, que pretende cambiar las `a` por `b`, pierde caracteres y a veces escribe `a`:
  ```prolog
  do_a_character :- get_char(X), X = a, !, put_char(b).
  do_a_character :- get_char(X), put_char(X).
  ```
- **Notas:** Leer consume la entrada y eso no se deshace al retroceder: la segunda cláusula lee *otro* carácter. Hay que leer una sola vez y decidir en otra cláusula.

### CM-5.8 — Las variables de `read_in` (Ejercicio 5.1)
- **Fuente:** Clocksin & Mellish, cap. 5 §5.3, p. 122–125 (Exercise 5.1)
- **Tema:** X
- **Dificultad:** 2
- **Solución:** En `read_in([W|Ws])`: `C` es el primer carácter, `W` la primera palabra, `C1` el carácter que sigue a esa palabra y `Ws` el resto. En `restsent(W, C, Ws)`: `W` es la palabra anterior (para ver si terminó la oración), `C` el carácter pendiente. En `readword(C, W, C2)`: `C` es el carácter inicial, `NewC` ese carácter pasado a minúscula, `Cs` los caracteres restantes de la palabra, `W` el átomo formado y `C2` el primer carácter después de la palabra, que se devuelve porque puede iniciar la palabra siguiente. Verificado: con la oración del libro devuelve `[the,man,',',who,is,old,',',saw,'joe''s',hat,'.']`.
- **SWISH:** no (lee caracteres de la entrada estándar)
- **Enunciado:** Explicar para qué sirve cada variable del programa `read_in/1` (p. 123–125), que lee una oración y la convierte en lista de átomos en minúscula.
- **Notas:** En SWI se puede reemplazar la tabla `letter/2` por `char_type(C, upper), downcase_atom(C, L)`. El OCR del listado tiene muchos errores (`letterQ, 'J)`, `digit('O')`, `lastword(T)`).

### CM-5.9 — Cambiar `a` por `b` (Ejercicio 5.2)
- **Fuente:** Clocksin & Mellish, cap. 5 §5.3, p. 125 (Exercise 5.2)
- **Tema:** 8, X
- **Dificultad:** 2
- **Solución:** en el libro (Apéndice A, p. 281–282)
- **SWISH:** no (lee caracteres de la entrada estándar)
- **Enunciado:** Escribir un programa que lea caracteres indefinidamente y los vuelva a escribir cambiando cada `a` por `b`.
- **Notas:** La solución del apéndice usa `put(X)` en la segunda cláusula: debe ser `put_char(X)`. Tampoco trata el fin de archivo; en SWI conviene agregar `deal_with(end_of_file) :- !.` y cortar el `repeat` al leerlo. El corte en `deal_with(a)` es necesario para que no se escriba también la `a`.

### CM-5.10 — Leer todos los términos de un archivo
- **Fuente:** Clocksin & Mellish, cap. 5 §5.4, p. 125–129 (adaptado del ejemplo)
- **Tema:** X
- **Dificultad:** 2
- **Solución:** Verificado leyendo un archivo `.pl`:
  ```prolog
  mostrar_terminos(Archivo) :-
      open(Archivo, read, S), read(S, T), procesar(T, S), close(S).
  procesar(end_of_file, _) :- !.
  procesar(T, S) :- print(T), nl, read(S, T2), procesar(T2, S).
  ```
- **SWISH:** no (acceso a archivos)
- **Enunciado:** Escribir `mostrar_terminos(Archivo)`, que abra el archivo, lea y muestre cada término hasta el fin de archivo y lo cierre. Hacer una variante que use `set_input/1` y restaure la entrada anterior.
- **Notas:** Al fin de archivo `read/1` devuelve el átomo `end_of_file`. Si el procesamiento puede fallar o lanzar un error, el archivo queda abierto; SWI ofrece `setup_call_cleanup/3` para evitarlo.

### CM-5.11 — Consultar archivos
- **Fuente:** Clocksin & Mellish, cap. 5 §5.4.3, p. 129; cap. 6 §6.1, p. 134–135 (adaptado del ejemplo)
- **Tema:** 0, 5
- **Dificultad:** 1
- **Solución:** en el libro (p. 129)
- **SWISH:** no (en SWISH el programa se escribe en el editor)
- **Enunciado:** Cargar dos archivos con `consult/1` y con la notación `[f1, f2]`. Definir `consultall(Lista)`, que consulte cada archivo de una lista, y comprobar que equivale a la notación de lista.
- **Notas:** En SWI, volver a consultar un archivo reemplaza las cláusulas que venían de él; `make.` recarga los archivos modificados. `consult(user)` (o `[user].`) permite escribir cláusulas en la terminal y terminar con Ctrl-D (Ctrl-Z en Windows).

### CM-5.12 — Declarar operadores
- **Fuente:** Clocksin & Mellish, cap. 5 §5.5, p. 130–132 (adaptado del ejemplo)
- **Tema:** 3
- **Dificultad:** 2
- **Solución:** Verificado: con `:- op(700, xfx, likes).` se puede escribir `john likes mary.` y `write_canonical` muestra `likes(john,mary)`; `no no a` se lee si `no` es `fy`, pero da "Operator priority clash" si es `fx`.
- **SWISH:** sí
- **Enunciado:** Declarar `likes` como operador infijo y escribir hechos con él. Declarar un operador prefijo `no` como `fy` y otro como `fx`, y comprobar cuál permite escribir `no no a`. Explicar por qué `a + b + c` se lee `(a + b) + c`.
- **Notas:** `op/3` cambia la sintaxis, no el significado: `john likes mary` sigue siendo la estructura `likes(john, mary)`. Los operadores declarados en un archivo afectan todo lo que se lea después.

## Capítulo 6: Predicados predefinidos

### CM-6.1 — Recorrer todas las soluciones con `fail`
- **Fuente:** Clocksin & Mellish, cap. 6 §6.2, p. 135–136 (adaptado del ejemplo)
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** en el libro (p. 136)
- **SWISH:** sí
- **Enunciado:** Con la base `event/2` de CM-5.1 y `phh/1` de CM-5.3, escribir una consulta que imprima todos los titulares sin pedir respuestas con `;`. ¿Qué responde Prolog al final y por qué?
- **Notas:** El "bucle guiado por la falla" termina fallando. `forall(event(_, L), phh(L))` hace lo mismo y termina con éxito.

### CM-6.2 — Clasificar términos en ejecución
- **Fuente:** Clocksin & Mellish, cap. 6 §6.3, p. 136–137 (adaptado del ejemplo)
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** en el libro (p. 136–137)
- **SWISH:** sí
- **Enunciado:** Predecir y comprobar: `var(X)`, `var(23)`, `X = Y, Y = 23, var(X)`, `atom(23)`, `atom(apples)`, `atom('/us/chris/pl.123')`, `atom(X)`, `atom(book(bronte, w_h, X))`, `atomic(3.5)`, `atom([])`. Definir `atomic/1` a partir de `atom/1` y `number/1`.
- **Notas:** En SWI-Prolog 7 y posteriores `atom([])` falla: `[]` es una constante especial, distinta del átomo `'[]'`.

### CM-6.3 — Las cláusulas también son términos
- **Fuente:** Clocksin & Mellish, cap. 6 §6.4, p. 137–139 (adaptado del ejemplo)
- **Tema:** 3, X
- **Dificultad:** 2
- **Solución:** en el libro (p. 138)
- **SWISH:** sí
- **Enunciado:** Escribir en notación funcional (sin operadores) la regla `grandparent(X, Z) :- parent(X, Y), parent(Y, Z)` y comprobarlo con `write_canonical/1`. ¿Cuáles son el functor principal y los argumentos?
- **Notas:** Hay que poner la cláusula entre paréntesis: `write_canonical((a :- b, c))`. Resultado: `:-(grandparent(X,Z), ','(parent(X,Y), parent(Y,Z)))`.

### CM-6.4 — `listing` encuentra un error
- **Fuente:** Clocksin & Mellish, cap. 6 §6.4, p. 139–140 (adaptado del ejemplo)
- **Tema:** 0
- **Dificultad:** 1
- **Solución:** en el libro (p. 139–140)
- **SWISH:** sí
- **Enunciado:** Escribir `reverse/2` con `append/3` pero con un error de tipeo en el nombre (`appenD`). Ejecutar `listing(reverse)` y encontrar el error. ¿Qué mensaje da SWI al ejecutar la consulta?
- **Notas:** El libro muestra que la consulta falla en silencio; SWI, en cambio, lanza "Unknown procedure: appenD/3". Leer los avisos al consultar (por ejemplo "Singleton variables") ahorra mucho tiempo.

### CM-6.5 — Recuperar cláusulas con `clause/2`
- **Fuente:** Clocksin & Mellish, cap. 6 §6.4, p. 140 (adaptado del ejemplo)
- **Tema:** X
- **Dificultad:** 2
- **Solución:** en el libro (p. 140); verificado con una copia `app/3` de `append/3`.
- **SWISH:** sí (el sandbox permite `clause/2` sobre los predicados del programa)
- **Enunciado:** Definir `app/3` como `append/3` y consultar `clause(app(A, B, C), Cuerpo)`, pidiendo todas las respuestas. ¿Qué cuerpo tiene un hecho?
- **Notas:** Los hechos tienen cuerpo `true`. En SWI `clause/2` no funciona sobre predicados del sistema.

### CM-6.6 — `functor`, `arg` y `=..`
- **Fuente:** Clocksin & Mellish, cap. 6 §6.5, p. 141–145 (adaptado del ejemplo)
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** en el libro (p. 142–145)
- **SWISH:** sí
- **Enunciado:** Predecir y comprobar: `functor(f(a, b, g(Z)), F, N)`, `functor(a + b, F, N)`, `functor(apple, F, N)`, `arg(2, related(john, mother(jane)), X)`, `arg(1, a+(b+c), X)`, `foo(a,b,c) =.. X`, `(a+b) =.. L` y `X =.. [append, [a,b], [c], [a,b,c]]`.
- **Notas:** Con listas SWI difiere del libro: `functor([a,b,c], F, N)` da `F = '[|]'`, no `'.'`, y `[a,b,c,d] =.. L` da `['[|]', a, [b,c,d]]`.

### CM-6.7 — Copia vacía de una estructura
- **Fuente:** Clocksin & Mellish, cap. 6 §6.5, p. 142–143 (adaptado del ejemplo)
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** en el libro (p. 143); verificado: `copy(sentence(np(n(john)), v(eats)), X)` da `X = sentence(_, _)`.
- **SWISH:** sí
- **Enunciado:** Definir `copy(Viejo, Nuevo)` con dos llamadas a `functor/3`, de modo que `Nuevo` tenga el mismo functor y aridad que `Viejo` pero variables nuevas como argumentos.
- **Notas:** La primera llamada usa `functor/3` para descomponer y la segunda para construir. No confundir con `copy_term/2`, que copia todo el término.

### CM-6.8 — Acceder a una estructura de 14 campos
- **Fuente:** Clocksin & Mellish, cap. 6 §6.5, p. 144 (adaptado del ejemplo)
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** en el libro (p. 144)
- **SWISH:** sí
- **Enunciado:** Un libro se representa con `book/14` (título, autor, editorial, …). Definir `is_a_book/1`, `title/2` y `author/2` con `functor/3` y `arg/3`, sin escribir los 14 argumentos.
- **Notas:** El OCR dice `author(X, A) :- is_a_book(X), arg(2, X, T).`: la variable debe ser `A`, no `T`.

### CM-6.9 — Átomos, números y caracteres
- **Fuente:** Clocksin & Mellish, cap. 6 §6.5, p. 145–146 (adaptado del ejemplo)
- **Tema:** 3, 7
- **Dificultad:** 1
- **Solución:** en el libro (p. 145–146); verificado: `atom_chars(X, ['1','2','3'])` da el átomo `'123'` y `number_chars(X, ['1','2','3'])` el número `123`.
- **SWISH:** sí
- **Enunciado:** Usar `atom_chars/2` en ambas direcciones con `apple`, y explicar la diferencia entre `atom_chars(X, ['1','2','3'])` y `number_chars(X, ['1','2','3'])`. Comprobar con `atom/1` y `number/1`.
- **Notas:** `'123'` y `123` se ven parecidos al imprimirlos pero son de tipos distintos: `'123' + 1` da error.

### CM-6.10 — Cómo funciona `repeat`
- **Fuente:** Clocksin & Mellish, cap. 6 §6.6, p. 146–148 (propuesta dentro del texto)
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** Con `rep :- rep.` antes de `rep.`, la primera llamada entra en la regla, que vuelve a llamar a la regla, y nunca llega al hecho: recursión infinita sin ningún éxito (el mismo problema de CM-3.4).
- **SWISH:** sí
- **Enunciado:** `repeat` se comporta como `repeat. repeat :- repeat.` Explicar por qué tiene éxito infinitas veces al retroceder y qué pasaría si el hecho estuviera después de la regla.
- **Notas:** `repeat` no se puede redefinir en SWI; para experimentar, usar otro nombre (`rep/0`).

### CM-6.11 — Saltear espacios (Ejercicio 6.1)
- **Fuente:** Clocksin & Mellish, cap. 6 §6.6, p. 147–148 (Exercise 6.1)
- **Tema:** 4, 8
- **Dificultad:** 2
- **Solución:** Si `X` ya está ligado (por ejemplo a `b`), `get_char(b)` falla con cualquier otro carácter y `repeat` sigue leyendo: se descartan también caracteres que no son espacios hasta encontrar una `b`, en vez de fallar si el siguiente carácter no blanco no es `b`. Corrección: leer en una variable nueva y unificar al final (verificado con `open_string/2`):
  ```prolog
  get_non_space(X) :- new_get(C), C \= ' ', !, X = C.
  ```
- **SWISH:** no (lee caracteres de la entrada estándar)
- **Enunciado:** Con `new_get(X) :- repeat, get_char(X).` y `get_non_space(X) :- new_get(X), \+ X = ' ', !.`, explicar por qué `get_non_space(X)` no funciona bien si se llama con `X` ya ligado.
- **Notas:** Regla general para E/S: leer siempre en una variable libre y comparar después.

### CM-6.12 — Disyunción y cláusulas separadas
- **Fuente:** Clocksin & Mellish, cap. 6 §6.7, p. 148–149 (adaptado del ejemplo)
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** en el libro (p. 149)
- **SWISH:** sí
- **Enunciado:** Reescribir `person(X) :- (X = adam ; X = eve ; mother(X, _)).` como varias cláusulas sin `;`, y comprobar que dan las mismas respuestas en el mismo orden.
- **Notas:** `;` es asociativo a derecha y tiene menor prioridad que `,`: conviene encerrar la disyunción entre paréntesis.

### CM-6.13 — Doble negación
- **Fuente:** Clocksin & Mellish, cap. 6 §6.7, p. 150 (adaptado del ejemplo)
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** en el libro (p. 150); verificado: la primera consulta escribe `a`, la segunda una variable (`_123`).
- **SWISH:** sí
- **Enunciado:** Explicar la diferencia entre las salidas de `member(X, [a,b,c]), write(X)` y `\+ \+ member(X, [a,b,c]), write(X)`.
- **Notas:** `\+` nunca deja ligaduras: si el objetivo interno tiene éxito, `\+` falla y se deshace todo. `\+ \+ G` sirve para probar `G` sin ligar variables.

### CM-6.14 — `=` frente a `==`
- **Fuente:** Clocksin & Mellish, cap. 6 §6.8, p. 150–151 (adaptado del ejemplo)
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** en el libro (p. 151)
- **SWISH:** sí
- **Enunciado:** Predecir y comprobar: `X == Y`, `X = Y, X == Y`, `append([A|B], C) == append(X, Y)` y `append([A|B], C) == append([A|B], C)`. ¿Cuándo `X == Y` implica `X = Y`?
- **Notas:** El OCR muestra `=` en la tercera consulta: es `==` (con `=` tendría éxito). `==` no liga variables: compara la forma actual de los términos.

### CM-6.15 — Orden estándar de términos
- **Fuente:** Clocksin & Mellish, cap. 6 §6.12, p. 155–157 (adaptado del ejemplo)
- **Tema:** 3
- **Dificultad:** 2
- **Solución:** en el libro (p. 156). Verificado en SWI: `g(X) @< f(X, Y)`, `f(Z, b) @< f(a, A)` y `123 @< 124` tienen éxito, pero `123.5 @< 2` falla.
- **SWISH:** sí
- **Enunciado:** Aplicar las reglas del orden estándar (variables < números < átomos < estructuras; estructuras por aridad, luego nombre, luego argumentos) para decidir `g(X) @< f(X, Y)`, `f(Z, b) @< f(a, A)`, `123 @< 124` y `123.5 @< 2`. Comprobar en SWI.
- **Notas:** El libro sigue ISO (todos los reales antes que todos los enteros). SWI compara los números por valor y solo si son iguales pone el real primero (`2.0 @< 2`), por eso `123.5 @< 2` falla. `msort/2` y `sort/2` usan este orden.

### CM-6.16 — Mirar un programa en ejecución
- **Fuente:** Clocksin & Mellish, cap. 6 §6.13, p. 157–158 (adaptado del ejemplo)
- **Tema:** 0
- **Dificultad:** 1
- **Solución:** en el libro (p. 157–158)
- **SWISH:** parcial (SWISH tiene un trazador gráfico; `spy/1` y `debugging/0` son de `swipl`)
- **Enunciado:** Con cualquier programa recursivo cargado, usar `trace/0` y `notrace/0`; poner un punto espía con `spy(append/3)`, ver los activos con `debugging/0` y quitarlos con `nospy/1` y `nodebug/0`.
- **Notas:** En `swipl`, `spy/1` activa el modo depuración: la ejecución se detiene solo al llegar al predicado espiado.

## Capítulo 7: Más programas de ejemplo

### CM-7.1 — Diccionario en árbol ordenado
- **Fuente:** Clocksin & Mellish, cap. 7 §7.1, p. 159–162 (adaptado del ejemplo)
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** en el libro (p. 162)
- **SWISH:** sí
- **Enunciado:** Representar un diccionario de caballos y ganancias como árbol `w(Clave, Valor, Menores, Mayores)` y definir `lookup(Clave, Arbol, Valor)` comparando claves con `@<` y `@>`. Explicar por qué `lookup(abaris, X, 582), lookup(maloja, X, 356)` *construye* un árbol.
  ```prolog
  lookup(H, w(H, G, _, _), G1) :- !, G = G1.
  lookup(H, w(H1, _, Before, _), G) :- H @< H1, lookup(H, Before, G).
  lookup(H, w(H1, _, _, After), G) :- H @> H1, lookup(H, After, G).
  ```
- **Notas:** Los subárboles vacíos son variables libres: buscar una clave ausente la inserta en el primer hueco. Es una estructura "incompleta" que se va llenando por unificación.

### CM-7.2 — Orden de inserción (Ejercicio 7.1)
- **Fuente:** Clocksin & Mellish, cap. 7 §7.1, p. 162 (Exercise 7.1)
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** Verificado. Orden massinga, braemar, nettleweed, panorama: `massinga` en la raíz, `braemar` a la izquierda, `nettleweed` a la derecha y `panorama` a la derecha de `nettleweed` (árbol bastante equilibrado). Orden adela, braemar, nettleweed, massinga: `adela` → `braemar` → `nettleweed` encadenados a la derecha y `massinga` a la izquierda de `nettleweed`, casi una lista, con búsquedas más largas.
- **SWISH:** sí
- **Enunciado:** Con `lookup/3` de CM-7.1, construir el árbol insertando en el orden massinga, braemar, nettleweed, panorama y luego en el orden adela, braemar, nettleweed, massinga. Dibujar ambos árboles y comparar.
- **Notas:** Para imprimir el árbol: `print(T)`; las variables libres aparecen como `_123`.

### CM-7.3 — Buscar el teléfono en una casa
- **Fuente:** Clocksin & Mellish, cap. 7 §7.2, p. 162–166 (adaptado del ejemplo)
- **Tema:** 5, 8
- **Dificultad:** 2
- **Solución:** en el libro (p. 164–166)
- **SWISH:** sí
- **Enunciado:** Con las puertas de abajo (de doble mano) y `hasphone(g)`, definir `go(Desde, Hasta, Visitadas)` que recorra habitaciones sin repetir ninguna. Comparar las consultas `go(a, X, []), hasphone(X)` y `hasphone(X), go(a, X, [])`, y buscar el teléfono sin pasar por `d` ni `f`.
  ```prolog
  d(a, b). d(b, e). d(b, c). d(d, e). d(c, d). d(e, f). d(g, e).
  ```
- **Notas:** La doble mano se puede expresar con `(d(X, Z) ; d(Z, X))`, con una segunda cláusula o duplicando los hechos. `\+ member(Z, T)` evita los ciclos.

### CM-7.4 — Mensajes durante la búsqueda (Ejercicio 7.2)
- **Fuente:** Clocksin & Mellish, cap. 7 §7.2, p. 166 (Exercise 7.2)
- **Tema:** 5
- **Dificultad:** 1
- **Solución:** Verificado con `hasphone(R), go(a, R, [a])`:
  ```prolog
  door(X, Y) :- d(X, Y) ; d(Y, X).
  go(X, X, _) :- format("found telephone in room ~w~n", [X]).
  go(X, Y, T) :- door(X, Z), \+ member(Z, T),
                 format("entering room ~w~n", [Z]), go(Z, Y, [Z|T]).
  ```
- **SWISH:** sí
- **Enunciado:** Modificar el programa de CM-7.3 para que escriba "entering room Y" al entrar en cada habitación y "found telephone in room Y" al encontrar el teléfono.
- **Notas:** Los mensajes muestran también los caminos sin salida: una escritura no se deshace al retroceder.

### CM-7.5 — Caminos alternativos (Ejercicio 7.3)
- **Fuente:** Clocksin & Mellish, cap. 7 §7.2, p. 166 (Exercise 7.3)
- **Tema:** 4, 8
- **Dificultad:** 2
- **Solución:** Sí: al pedir más respuestas se obtienen otros caminos (verificado: de `a` a `g` hay dos, `[a,b,e,g]` y `[a,b,c,d,e,g]`). Para quedarse con uno, el corte va después de la prueba completa, por ejemplo `phone_path(R) :- hasphone(R), go(a, R, [a]), !.`
- **SWISH:** sí
- **Enunciado:** ¿Puede el programa de CM-7.3 encontrar caminos alternativos? Si es así, ¿dónde se pone un corte para obtener uno solo?
- **Notas:** Para ver los caminos hay que devolverlos en un argumento (por ejemplo, la lista de visitadas invertida al final).

### CM-7.6 — ¿En qué orden se recorren las habitaciones? (Ejercicio 7.4)
- **Fuente:** Clocksin & Mellish, cap. 7 §7.2, p. 166 (Exercise 7.4)
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** El orden de los hechos `d/2` en el programa (y, en la versión de doble mano, que primero se prueben las puertas `d(X, Z)` y después las `d(Z, X)`), junto con la búsqueda en profundidad: se sigue cada camino hasta el final antes de volver atrás.
- **SWISH:** sí
- **Enunciado:** ¿Qué determina el orden en que el programa de CM-7.3 visita las habitaciones? Comprobarlo cambiando el orden de los hechos.
- **Notas:** Relacionarlo con la estrategia de Prolog: cláusulas de arriba hacia abajo, objetivos de izquierda a derecha.

### CM-7.7 — Torres de Hanoi
- **Fuente:** Clocksin & Mellish, cap. 7 §7.3, p. 166–167 (adaptado del ejemplo)
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** en el libro (p. 167); verificado con `hanoi(2)`.
- **SWISH:** sí
- **Enunciado:** Escribir `hanoi(N)`, que imprima los movimientos para pasar N discos del poste izquierdo al central usando el derecho como auxiliar, siguiendo la estrategia recursiva: mover N−1 al auxiliar, mover un disco, mover N−1 al destino.
- **Notas:** El OCR escribe `move(0, _, _):-!.`: el caso base tiene cuatro argumentos, `move(0, _, _, _) :- !.` Para 3 discos salen 7 movimientos; en general 2^N − 1.

### CM-7.8 — Inventario con cantidades
- **Fuente:** Clocksin & Mellish, cap. 7 §7.4, p. 167–169 (adaptado del ejemplo)
- **Tema:** 6, 7
- **Dificultad:** 3
- **Solución:** en el libro (p. 168–169); verificado: para una bicicleta con 32 rayos por rueda se listan 64 `spoke`, 2 `rim`, etc.
- **SWISH:** sí
- **Enunciado:** Cambiar el inventario de CM-3.9 para que cada ensamble indique cantidades (`assembly(bike, [quant(wheel,2), quant(frame,1)])`) y escribir `partlist(X)`, que imprima cada pieza básica una sola vez con la cantidad total. Hace falta `collect/2`, que suma las cantidades de piezas repetidas.
- **Notas:** En el OCR la variable `O` (otras piezas) aparece como `0`, lo que cambia el significado; usar un nombre como `Otras`.

### CM-7.9 — `last`, `nextto` y `member` a partir de `append`
- **Fuente:** Clocksin & Mellish, cap. 7 §7.5, p. 169–170 (adaptado del ejemplo)
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** en el libro (p. 170)
- **SWISH:** sí
- **Enunciado:** Definir recursivamente `last(X, L)` (X es el último de L) y `nextto(X, Y, L)` (X e Y consecutivos en L). Después definir `last`, `nextto` y `member` en una línea cada uno usando `append/3`.
- **Notas:** SWI trae `last/2` con los argumentos al revés, `last(Lista, Ultimo)`, y `nextto/3`. Conviene usar otros nombres (`ultimo/2`).

### CM-7.10 — Invertir una lista
- **Fuente:** Clocksin & Mellish, cap. 7 §7.5, p. 170–171 (adaptado del ejemplo)
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** en el libro (p. 171)
- **SWISH:** sí
- **Enunciado:** Definir `rev(L, R)` usando `append/3` y `rev2(L, R)` con un acumulador. Comparar cuántos pasos hace cada uno para una lista de largo n (probar con `time/1` y listas de 1000 y 2000 elementos).
- **Notas:** La primera versión es cuadrática; la segunda, lineal. SWI trae `reverse/2`.

### CM-7.11 — Borrar y sustituir elementos
- **Fuente:** Clocksin & Mellish, cap. 7 §7.5, p. 171–172 (adaptado del ejemplo)
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** en el libro (p. 171–172)
- **SWISH:** sí
- **Enunciado:** Definir `efface(X, L, R)` (borra la primera aparición de X), `delete(X, L, R)` (borra todas) y `subst(X, L, A, M)` (reemplaza cada X por A). Explicar para qué está el corte en cada caso.
- **Notas:** SWI trae `delete/3` con otro orden, `delete(Lista, Elem, Resto)`: redefinirla confunde; mejor `borrar_todos/3`. Sin los cortes, al retroceder aparecen respuestas incorrectas (por ejemplo, listas con elementos no borrados).

### CM-7.12 — Sublistas
- **Fuente:** Clocksin & Mellish, cap. 7 §7.5, p. 172 (adaptado del ejemplo)
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** en el libro (p. 172); verificado con `[of,the,club]` dentro de `[meetings,of,the,club,will,be,held]`.
- **SWISH:** sí
- **Enunciado:** Definir `sublist(X, Y)`: los elementos de X aparecen en Y consecutivos y en el mismo orden. Usar un auxiliar `prefix(X, Y)`. Luego escribir otra versión con dos llamadas a `append/3`.
- **Notas:** Con `append/3`: `sublist(S, L) :- append(_, Resto, L), append(S, _, Resto).`

### CM-7.13 — Quitar repetidos
- **Fuente:** Clocksin & Mellish, cap. 7 §7.5, p. 172 (adaptado del ejemplo)
- **Tema:** 6, 8
- **Dificultad:** 1
- **Solución:** en el libro (p. 172); verificado: `remdup([a,b,a,c,b], R)` da `[c,b,a]`.
- **SWISH:** sí
- **Enunciado:** Definir `remdup(L, M)`, que deja una sola copia de cada elemento, usando un acumulador. ¿En qué orden quedan los elementos? Modificarlo para conservar el orden de la primera aparición.
- **Notas:** SWI trae `list_to_set/2`, que conserva el orden original.

### CM-7.14 — Conjuntos como listas
- **Fuente:** Clocksin & Mellish, cap. 7 §7.6, p. 173–174 (adaptado del ejemplo)
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** en el libro (p. 174); verificado: intersección de `[r,a,p,i,d]` y `[p,i,c,t,u,r,e]` = `[r,p,i]`; unión de `[a,b,c]` y `[c,d,e]` = `[a,b,c,d,e]`.
- **SWISH:** sí
- **Enunciado:** Representando conjuntos como listas sin repetidos, definir `subset/2`, `intersection/3` y `union/3`, y probarlos con los ejemplos del libro.
- **Notas:** El OCR escribe `intersection^], X, [])` y omite el corte de la segunda cláusula: sin él, al retroceder aparecen intersecciones incompletas. SWI trae estos tres predicados en `library(lists)`.

### CM-7.15 — Ordenamiento ingenuo
- **Fuente:** Clocksin & Mellish, cap. 7 §7.7, p. 175–176 (adaptado del ejemplo)
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** en el libro (p. 175); verificado con `[3,6,2,9,20]`.
- **SWISH:** sí
- **Enunciado:** Ordenar una lista generando permutaciones hasta encontrar una ordenada (`permutation/2` como generador, `sorted/1` como prueba). ¿Cuántas permutaciones puede tener que probar para una lista de 10 elementos?
- **Notas:** No se puede llamar `sort/2`: es un predicado del sistema ("No permission to modify static procedure `sort/2`"); usar `naive_sort/2`. En el peor caso prueba n! permutaciones.

### CM-7.16 — Inserción, con el orden como parámetro
- **Fuente:** Clocksin & Mellish, cap. 7 §7.7, p. 176 (adaptado del ejemplo)
- **Tema:** 6, 9
- **Dificultad:** 2
- **Solución:** en el libro (p. 176)
- **SWISH:** sí
- **Enunciado:** Escribir el ordenamiento por inserción `insort(L, S)` con un predicado `order/2`. Luego agregar un tercer argumento con el nombre del orden y construir la comparación con `=..` y `call/1`, para usar `insort(L, S, '<')` o `insort(L, S, '@<')`.
- **Notas:** En SWI es más directo `call(Orden, A, X)` que armar el objetivo con `=..`. Primer contacto con predicados de orden superior.

### CM-7.17 — Ordenamiento burbuja
- **Fuente:** Clocksin & Mellish, cap. 7 §7.7, p. 176–177 (adaptado del ejemplo)
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** en el libro (p. 176–177)
- **SWISH:** sí
- **Enunciado:** Definir `busort(L, S)`: buscar con `append/3` dos elementos consecutivos desordenados, intercambiarlos y repetir hasta que no haya ninguno. Explicar por qué aquí `append/3` no debe llevar corte.
- **Notas:** Verificado: si `order/2` no es estricto (usa `=<`), con elementos repetidos el programa se cuelga intercambiando dos iguales para siempre. `order` debe ser `<`.

### CM-7.18 — Quicksort
- **Fuente:** Clocksin & Mellish, cap. 7 §7.7, p. 177 (adaptado del ejemplo)
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** en el libro (p. 177); verificado contra `msort/2`.
- **SWISH:** sí
- **Enunciado:** Definir `split(H, L, Menores, Mayores)` y `quisort/2`. Después escribir `quisortx(L, S, Resto)` que incorpore el `append` usando el tercer argumento como lista de diferencia.
- **Notas:** El OCR escribe `quisortx(A, S, [H|Y]>,` y `split(H, X, Y, I)`: son `quisortx(A, S, [H|Y]),` y `split(H, X, Y, Z)`.

### CM-7.19 — Orden de las permutaciones (Ejercicio 7.5)
- **Fuente:** Clocksin & Mellish, cap. 7 §7.7, p. 178 (Exercise 7.5)
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** Verificado: para `[a,b,c]` salen `[a,b,c]`, `[a,c,b]`, `[b,a,c]`, `[b,c,a]`, `[c,a,b]`, `[c,b,a]`. El primer `append(V, [H|U], L)` elige como cabeza cada elemento de L en orden, y la recursión hace lo mismo con el resto: sale en orden lexicográfico según las posiciones originales, cada permutación una vez si no hay elementos repetidos.
- **SWISH:** sí
- **Enunciado:** Comprobar que, con L1 conocida, la `permutation(L1, L2)` del libro genera cada permutación una sola vez. ¿En qué orden?
- **Notas:** Con elementos repetidos (`[a,a,b]`) las permutaciones iguales aparecen repetidas.

### CM-7.20 — Ordenamiento híbrido (Ejercicio 7.6)
- **Fuente:** Clocksin & Mellish, cap. 7 §7.7, p. 178 (Exercise 7.6)
- **Tema:** 6, 7
- **Dificultad:** 3
- **Solución:** Verificado con una lista invertida de 2000 elementos y contra `msort/2`. `split3` parte la lista y cuenta el tamaño de cada parte; `insort/2` es el de CM-7.16:
  ```prolog
  hsort(L, S) :- length(L, N), hsort(L, N, S).
  hsort(L, N, S) :- N =< 4, !, insort(L, S).
  hsort([H|T], _, S) :- split3(H, T, A, NA, B, NB),
      hsort(A, NA, SA), hsort(B, NB, SB), append(SA, [H|SB], S).
  split3(_, [], [], 0, [], 0).
  split3(H, [X|Xs], [X|A], NA, B, NB) :- X =< H, !,
      split3(H, Xs, A, NA0, B, NB), NA is NA0 + 1.
  split3(H, [X|Xs], A, NA, [X|B], NB) :-
      split3(H, Xs, A, NA, B, NB0), NB is NB0 + 1.
  ```
- **SWISH:** sí
- **Enunciado:** Escribir un ordenamiento que use quicksort para las particiones grandes y cambie a inserción cuando una partición es chica. Aprovechar que `split` recorre la lista para contar su largo.
- **Notas:** El umbral (aquí 4) es arbitrario; medir con `time/1` distintos valores.

### CM-7.21 — Números pseudoaleatorios con una semilla
- **Fuente:** Clocksin & Mellish, cap. 7 §7.8.1, p. 178–179 (adaptado del ejemplo)
- **Tema:** 7, 10
- **Dificultad:** 2
- **Solución:** en el libro (p. 179); verificado (con semilla 13 la secuencia para `R = 10` empieza 4, 7, 8, 5, 6, 9).
- **SWISH:** sí
- **Enunciado:** Guardar la semilla en un hecho dinámico `seed/1` y definir `random(R, N)`: N es un entero entre 1 y R calculado con la semilla, que luego se reemplaza por `(125*S + 1) mod 4096`. Imprimir números hasta que salga un 5 usando `repeat`.
- **Notas:** Hace falta `:- dynamic seed/1.` SWI ya tiene `random/1` y `random_between/3`; conviene llamar al propio `mi_random/2`. El estado sobrevive al retroceso porque vive en la base de datos, no en variables.

### CM-7.22 — Generar átomos nuevos (`gensym`)
- **Fuente:** Clocksin & Mellish, cap. 7 §7.8.2, p. 179–181 (adaptado del ejemplo)
- **Tema:** 10
- **Dificultad:** 2
- **Solución:** en el libro (p. 180–181); verificado: `student1`, `student2`, `teacher1`.
- **SWISH:** sí
- **Enunciado:** Definir `gensym(Raiz, Atomo)`, que devuelve `student1`, `student2`, … en llamadas sucesivas (no al retroceder), guardando el último número de cada raíz en un hecho dinámico `current_num/2`.
- **Notas:** SWI trae `gensym/2` (biblioteca `gensym`); usar otro nombre. Con `atomic_list_concat([Raiz, N], Atomo)` se evita pasar por listas de caracteres.

### CM-7.23 — Implementar `findall` con la base de datos
- **Fuente:** Clocksin & Mellish, cap. 7 §7.8.3, p. 181–182 (adaptado del ejemplo)
- **Tema:** 9, 10
- **Dificultad:** 3
- **Solución:** en el libro (p. 182); verificado con llamadas anidadas: `[1-[x,y], 2-[x,y]]`.
- **SWISH:** sí
- **Enunciado:** Definir `my_findall(X, G, L)` guardando cada solución con `asserta(found(result(X)))` en un bucle guiado por la falla y recogiéndolas después con `retract/1`. Explicar para qué sirve la marca `found(mark)` y comprobar que funciona anidado.
- **Notas:** `findall/3` no se puede redefinir en SWI ("No permission to modify static procedure"). El OCR pierde el corte de `collect_found`.

### CM-7.24 — Elegir un elemento al azar (Ejercicio 7.7)
- **Fuente:** Clocksin & Mellish, cap. 7 §7.8, p. 182 (Exercise 7.7)
- **Tema:** 6, 10
- **Dificultad:** 2
- **Solución:** Con el generador de CM-7.21 renombrado `rand/2` (verificado):
  ```prolog
  nth(1, [X|_], X) :- !.
  nth(N, [_|T], X) :- N > 1, N1 is N - 1, nth(N1, T, X).
  random_pick(L, E) :- length(L, Len), rand(Len, N), nth(N, L, E).
  ```
- **SWISH:** sí
- **Enunciado:** Definir `random_pick(L, E)`, que liga E a un elemento de L elegido al azar, usando el generador de números aleatorios y un predicado que devuelva el N-ésimo elemento de una lista.
- **Notas:** SWI ofrece `nth1/3` y `random_member/2`.

### CM-7.25 — `findall` con variables libres (Ejercicio 7.8)
- **Fuente:** Clocksin & Mellish, cap. 7 §7.8, p. 183 (Exercise 7.8)
- **Tema:** 9
- **Dificultad:** 2
- **Solución:** Las variables de G que no aparecen en X no quedan ligadas después de `findall` y se comportan como "para algún valor": se recogen todas las soluciones juntas, sin agrupar. Verificado: con `parents(cain,eve,adam)`, … `findall(X, parents(X, Y, _), L)` da todos los hijos y deja `Y` libre, mientras que `bagof(X, F^parents(X, M, F), L)` da una lista por cada madre `M`.
- **SWISH:** sí
- **Enunciado:** En `findall(X, G, L)`, ¿qué pasa con las variables de G que no comparten nada con X? Comparar con `bagof/3` y `setof/3`.
- **Notas:** En `bagof`/`setof`, `Var^Objetivo` indica qué variables no deben agrupar.

### CM-7.26 — Grafos dirigidos y ciclos
- **Fuente:** Clocksin & Mellish, cap. 7 §7.9, p. 183–184 (adaptado del ejemplo)
- **Tema:** 5
- **Dificultad:** 2
- **Solución:** en el libro (p. 183–184)
- **SWISH:** sí
- **Enunciado:** Con arcos `a(X, Y)`, definir `go(X, Y)` (hay camino de X a Y siguiendo los arcos). Agregar el arco `a(d, a)` para formar un ciclo, ver qué pasa y corregirlo con una lista de nodos visitados y un predicado `legal(Z, Visitados)` de no pertenencia.
  ```prolog
  a(g,h). a(g,d). a(e,d). a(h,f). a(e,f). a(a,e). a(a,b). a(b,f). a(b,c). a(f,c).
  ```
- **Notas:** El predicado del arco se llama `a` y hay un nodo `a`: no hay conflicto, porque uno es un predicado de aridad 2 y el otro una constante.

### CM-7.27 — Devolver la ruta encontrada
- **Fuente:** Clocksin & Mellish, cap. 7 §7.9, p. 184–185 (adaptado del ejemplo)
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** en el libro (p. 185); verificado: `go(darlington, workington, R)` da primero `[darlington,newcastle,carlisle,penrith,workington]`.
- **SWISH:** sí
- **Enunciado:** Con las rutas de abajo (de doble mano) y `a(X, Y) :- a(X, Y, _).`, definir `go(Inicio, Destino, Ruta)`, que devuelva la ruta en orden, invirtiendo al final la lista de visitados.
  ```prolog
  a(newcastle, carlisle, 58).  a(carlisle, penrith, 23).
  a(darlington, newcastle, 40). a(penrith, darlington, 52).
  a(workington, carlisle, 33). a(workington, penrith, 39).
  ```
- **Notas:** En el OCR aparecen `Carlisle`, `Workington` y `dartington`: con mayúscula serían variables y rompen el programa.

### CM-7.28 — Profundidad frente a amplitud
- **Fuente:** Clocksin & Mellish, cap. 7 §7.9, p. 185–187 (adaptado del ejemplo, con dos propuestas del texto)
- **Tema:** 9
- **Dificultad:** 3
- **Solución:** en el libro (p. 185–187); verificado: la versión en amplitud da `[darlington,penrith,workington]` primero.
- **SWISH:** sí
- **Enunciado:** Reescribir la búsqueda manteniendo explícitamente la lista de caminos pendientes y extendiendo el primero con `findall/3`. Poner los caminos nuevos al principio (profundidad) y luego al final (amplitud), y comparar el orden de las rutas. Responder las dos preguntas del texto: ¿por qué la versión en profundidad recorre en el mismo orden que la recursiva?, y ¿por qué, si siempre hay solución y solo interesa la primera, la versión en amplitud no necesita controlar ciclos?
- **Notas:** La diferencia entre ambas estrategias es solo el orden de los argumentos de un `append/3`.

### CM-7.29 — Búsqueda "el mejor primero" con distancias
- **Fuente:** Clocksin & Mellish, cap. 7 §7.9, p. 187–188 (adaptado del ejemplo, con propuesta del texto)
- **Tema:** 7, 9
- **Dificultad:** 3
- **Solución:** en el libro (p. 187–188). La variante que informa la longitud (propuesta del texto) devuelve `r(Km, Ruta)` en la cláusula final de `proceed`; verificado: `91-[darlington,penrith,workington]`, `108-…`, `131-…`, `160-…`.
- **SWISH:** sí
- **Enunciado:** Representar cada camino pendiente como `r(Distancia, Lugares)` y extender siempre el más corto, para obtener las rutas en orden de kilometraje. Modificar el programa para que también informe la longitud de cada ruta.
- **Notas:** En `shortest/3` el OCR pierde el corte final de la primera cláusula; sin él, al retroceder se eligen caminos que no son los más cortos.

### CM-7.30 — Criba de Eratóstenes
- **Fuente:** Clocksin & Mellish, cap. 7 §7.10, p. 188–190 (adaptado del ejemplo)
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** en el libro (p. 189–190); verificado: `primes(30, P)` da `[2,3,5,7,11,13,17,19,23,29]`.
- **SWISH:** sí
- **Enunciado:** Definir `primes(N, L)`: generar la lista de enteros de 2 a N, tomar el primero como primo, quitar sus múltiples y repetir con lo que queda.
- **Notas:** SWI trae `numlist/3` para generar la lista inicial y `exclude/3` para quitar los múltiplos.

### CM-7.31 — Primos con acumulador, MCD y MCM
- **Fuente:** Clocksin & Mellish, cap. 7 §7.10, p. 190 (adaptado del ejemplo)
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** en el libro (p. 190); verificado: `gcd(12, 18, G)` da 6 y `lcm(4, 6, L)` da 12.
- **SWISH:** sí
- **Enunciado:** Escribir otra versión de los primos que recorra los candidatos y acumule los primos ya hallados, agregando un candidato si ninguno lo divide. Definir `gcd/3` con el algoritmo de Euclides y `lcm/3` a partir de él. ¿Qué argumentos deben estar ligados?
- **Notas:** El OCR escribe `gcd(I, 0,1)`: es `gcd(I, 0, I) :- !.` No son reversibles: `gcd(X, 18, 6)` da error de instanciación.

### CM-7.32 — Ternas pitagóricas (Ejercicio 7.9)
- **Fuente:** Clocksin & Mellish, cap. 7 §7.10, p. 190–191 (Exercise 7.9)
- **Tema:** 4, 7
- **Dificultad:** 3
- **Solución:** en el libro (Apéndice A, p. 282)
- **SWISH:** sí
- **Enunciado:** Definir `pythag(X, Y, Z)` que, pidiendo más respuestas, genere todas las ternas con X² + Y² = Z². Sugerencia: usar un generador de enteros como `is_integer/1` de CM-4.3.
- **Notas:** Verificado: la solución del apéndice genera primero ternas triviales con 0 (`0-0-0`, `1-0-1`, …); conviene exigir X, Y > 0. El problema es garantizar que toda terna aparezca: no sirve generar X, Y, Z con tres generadores infinitos anidados. Con SWI: `between(1, inf, Z), between(1, Z, Y), between(1, Y, X), Z*Z =:= X*X + Y*Y`.

### CM-7.33 — Derivación simbólica
- **Fuente:** Clocksin & Mellish, cap. 7 §7.11, p. 191–192 (adaptado del ejemplo)
- **Tema:** 3, 7
- **Dificultad:** 2
- **Solución:** en el libro (p. 192); verificado: `d(x+1, x, D)` da `1+0` y `d(x*x-2, x, D)` da `1*x+1*x-0`.
- **SWISH:** sí
- **Enunciado:** Escribir `d(E, X, D)`: D es la derivada de la expresión E respecto de X, con una cláusula por regla (constante, suma, resta, producto por constante, producto, cociente, potencia, logaritmo).
- **Notas:** En SWI `^` ya es operador; no hace falta declararlo. El resultado no queda simplificado: ver CM-7.35.

### CM-7.34 — `maplist` y `applist` propios
- **Fuente:** Clocksin & Mellish, cap. 7 §7.12, p. 193–194 (adaptado del ejemplo)
- **Tema:** 9
- **Dificultad:** 2
- **Solución:** en el libro (p. 193–194); verificado: `my_maplist(change, [you,are,a,computer], Z)` da `[i,[am,not],a,computer]`.
- **SWISH:** sí
- **Enunciado:** Definir `my_maplist(P, L, M)`, que aplica el predicado de dos argumentos P a cada elemento de L, y `applist(P, L)`, que aplica un predicado de un argumento sin construir lista. Rehacer `alter/2` (CM-3.6) y `phh/1` (CM-5.3) con ellos.
- **Notas:** El libro arma el objetivo con `=..` y `call/1`; en SWI se escribe `call(P, X, Y)`. SWI trae `maplist/2..7`, `foldl/4..6`, `include/3` y `exclude/3`.

### CM-7.35 — Simplificar expresiones
- **Fuente:** Clocksin & Mellish, cap. 7 §7.12, p. 194–196 (adaptado del ejemplo)
- **Tema:** 3, 7
- **Dificultad:** 2
- **Solución:** en el libro (p. 194–195); verificado: con las reglas de plegado `simp(3*4+a, S)` da `12+a`, `simp(2*3*a, S)` da `6*a` y la regla extra permite `simp(a*2*3, S)` = `a*6`.
- **SWISH:** sí
- **Enunciado:** Definir `simp(E, F)`, que simplifica recursivamente los dos argumentos de E y consulta una tabla `s(Op, Izq, Der, Resultado)` con reglas como `x+0 = x` y `1*x = x`, más una regla comodín por operador. Agregar el plegado de constantes (`3*4` → `12`) y explicar por qué `a*2*3` no se simplifica sin una regla adicional.
- **Notas:** Las reglas comodín van al final; al pedir más respuestas aparecen formas menos simplificadas. Aplicarlo al resultado de CM-7.33.

### CM-7.36 — Un `listing` casero
- **Fuente:** Clocksin & Mellish, cap. 7 §7.13, p. 196 (adaptado del ejemplo)
- **Tema:** X
- **Dificultad:** 2
- **Solución:** en el libro (p. 196); verificado con `app/3`.
- **SWISH:** sí
- **Enunciado:** Definir `list1(X)`, que imprima todas las cláusulas cuya cabeza unifica con X usando `clause/2` y un bucle guiado por la falla; los hechos se imprimen sin `:- true`.
- **Notas:** El corte en `output_clause(X, true) :- !, write(X).` es imprescindible: sin él los hechos se imprimirían dos veces al retroceder. `portray_clause/1` de SWI hace esto con mejor formato.

### CM-7.37 — Un intérprete de Prolog en Prolog
- **Fuente:** Clocksin & Mellish, cap. 7 §7.13, p. 197 (adaptado del ejemplo)
- **Tema:** X
- **Dificultad:** 3
- **Solución:** en el libro (p. 197); verificado: `interpret(rev([a,b,c], R))` da `[c,b,a]` y `interpret(app(X, Y, [1,2]))` enumera las tres particiones.
- **SWISH:** sí
- **Enunciado:** Definir `interpret(G)` con tres cláusulas: `true`, conjunción y objetivo simple (buscar una cláusula con `clause/2` e interpretar su cuerpo). Probarlo con `rev/2` y `app/3` propios. ¿Por qué no funciona con `is/2` o con el corte?
- **Notas:** Los predicados del sistema no tienen cláusulas accesibles; se puede agregar una cláusula que los llame directamente con `predicate_property(G, built_in)`.

### CM-7.38 — `retractall` y `consult` escritos en Prolog
- **Fuente:** Clocksin & Mellish, cap. 7 §7.13, p. 197–199 (adaptado del ejemplo)
- **Tema:** 10, X
- **Dificultad:** 3
- **Solución:** en el libro (p. 197–198); verificado `my_retractall/1` con un predicado dinámico que tiene hechos y reglas.
- **SWISH:** no (`consult` lee archivos; además el sandbox no permite agregar ni quitar reglas, solo hechos)
- **Enunciado:** Definir `my_retractall(X)`, que borre todos los hechos y reglas cuya cabeza unifica con X, y un `consult` simplificado que lea un archivo término a término, borre las definiciones previas la primera vez que aparece cada predicado y agregue las cláusulas con `assertz/1`.
- **Notas:** Usa `repeat`, `read/1`, `functor/3` y el truco de guardar `done(foo(_,_))` para cada predicado ya visto. SWI trae `retractall/1` y no permite redefinirlo; usar otro nombre.

## Capítulo 8: Depuración de programas

### CM-8.1 — Igualdad de conjuntos
- **Fuente:** Clocksin & Mellish, cap. 8 §8.1, p. 202 (adaptado del ejemplo)
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** en el libro (p. 202); verificado: `eqset([a,b,c], [c,a,b])` tiene éxito.
- **SWISH:** sí
- **Enunciado:** Definir `eqset(X, Y)`: las listas X e Y tienen los mismos elementos en cualquier orden, usando un auxiliar que borre de Y cada elemento de X. Explicar qué aporta la primera cláusula `eqset(X, X) :- !.`
- **Notas:** El libro llama `delete/3` al auxiliar que borra una aparición; en SWI conviene otro nombre (ver CM-7.11). El ejemplo está en el libro para mostrar cómo disponer las cláusulas en el papel.

### CM-8.2 — Autoevaluación de notación de listas
- **Fuente:** Clocksin & Mellish, cap. 8 §8.2, p. 206 (adaptado del ejemplo)
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** en el libro (p. 206)
- **SWISH:** sí
- **Enunciado:** Responder y comprobar: ¿cómo unifican `[a,b,c]` y `[X|Y]`? ¿`[a]` y `[X|Y]`? ¿`[]` y `[X|Y]`? ¿Tienen sentido `[X,Y|Z]`, `[X|Y,Z]` y `[X|[Y|Z]]`? ¿Cómo unifican `[a,b]` y `[A|B]` y hay más de una forma?
- **Notas:** La unificación de dos términos da a lo sumo un resultado; las distintas particiones de `append/3` salen del retroceso, no de la unificación.

### CM-8.3 — Una coma o un punto de más
- **Fuente:** Clocksin & Mellish, cap. 8 §8.2, p. 206–207 (propuesta dentro del texto)
- **Tema:** 0, 2
- **Dificultad:** 2
- **Solución:** en el libro (p. 207)
- **SWISH:** sí
- **Enunciado:** En la definición de `eq/2` (igualdad de listas con un auxiliar `del/3`), la segunda cláusula termina con coma en vez de punto; en otra versión, sus dos objetivos están separados por un punto. Explicar qué programa lee Prolog en cada caso y por qué no hay error de sintaxis.
  ```prolog
  eq([], []).
  eq([X|L], M) :- del(X, M, N), eq(L, N),
  del(X, [X|Y], Y).
  del(X, [Y|L1], [Y|L2]) :- del(X, L1, L2).
  ```
- **Notas:** SWI ayuda: avisa "Singleton variables" y, en el segundo caso, que las cláusulas de `eq/2` no están juntas. Leer siempre los avisos al consultar.

### CM-8.4 — Seguir la traza de `descendant`
- **Fuente:** Clocksin & Mellish, cap. 8 §8.3, p. 208–214 (adaptado del ejemplo)
- **Tema:** 0, 4
- **Dificultad:** 2
- **Solución:** en el libro (p. 209–214)
- **SWISH:** sí
- **Enunciado:** Con el programa de abajo, escribir a mano los eventos CALL, EXIT, REDO y FAIL de `descendant(abraham, A), fail` y compararlos con la salida de `trace` en `swipl`.
  ```prolog
  descendant(X, Y) :- offspring(X, Y).
  descendant(X, Z) :- offspring(X, Y), descendant(Y, Z).
  offspring(abraham, ishmael). offspring(abraham, isaac).
  offspring(isaac, esau).      offspring(isaac, jacob).
  ```
- **Notas:** El listado del libro omite `offspring(isaac, jacob)`, que sí aparece en la traza. SWI muestra los mismos puertos (Call, Exit, Redo, Fail) con la profundidad entre paréntesis en lugar del número de invocación.

### CM-8.5 — El corte en el modelo de cajas (Ejercicio 8.1)
- **Fuente:** Clocksin & Mellish, cap. 8 §8.3, p. 214 (Exercise 8.1)
- **Tema:** 0, 8
- **Dificultad:** 3
- **Solución:** El corte, al llamarse (CALL), sale de inmediato (EXIT). Si luego el retroceso vuelve a él (REDO), no se reintenta: falla y además hace fallar enseguida al objetivo padre (el que eligió la cláusula con el corte), sin pasar por REDO de los objetivos que están a su izquierda en el cuerpo ni probar las cláusulas restantes del padre. En el diagrama, la flecha que vuelve a la caja del corte sale directamente por el FAIL de la caja del padre.
- **SWISH:** sí
- **Enunciado:** El modelo CALL/EXIT/REDO/FAIL no dice cómo se trata el corte. Extenderlo para explicar su efecto.
- **Notas:** Comprobarlo con `trace` sobre `sum_to/2` de CM-4.6 con el corte puesto: después del corte no aparecen REDO de los objetivos anteriores.

### CM-8.6 — Trazar `append` y adaptar la impresión
- **Fuente:** Clocksin & Mellish, cap. 8 §8.4, p. 214–218 (adaptado del ejemplo)
- **Tema:** 0
- **Dificultad:** 1
- **Solución:** en el libro (p. 216–218)
- **SWISH:** parcial (el trazador gráfico de SWISH no usa `portray/1`)
- **Enunciado:** Cargar una copia `app/3` de `append/3`, activar `trace` y seguir `app([a], [b], X)` y `app(X, Y, [a])`, pidiendo todas las respuestas. Después definir una cláusula `portray/1` que oculte el tercer argumento de `app/3` y repetir la traza.
- **Notas:** En SWI se usa `leash(-all)` para una traza sin paradas y `leash(+all)` para volver a detenerse en cada puerto.

### CM-8.7 — Ancestros de un objetivo
- **Fuente:** Clocksin & Mellish, cap. 8 §8.4.2, p. 219–220 (propuesta dentro del texto)
- **Tema:** 0, 4
- **Dificultad:** 2
- **Solución:** en el libro (p. 219–220)
- **SWISH:** sí
- **Enunciado:** Con `rev/2` definido con `append/3`, cuando se está resolviendo `append([c], [b], Y)` dentro de `rev([a,b,c,d], X)`, listar sus objetivos ancestros y explicar por qué son esos y no otros (por ejemplo, por qué `append(Z, [a], X)` no es ancestro).
- **Notas:** En el trazador de `swipl` la opción `g` (goals) muestra la pila de ancestros.

### CM-8.8 — Moverse por la ejecución con el trazador
- **Fuente:** Clocksin & Mellish, cap. 8 §8.4.3–8.4.4, p. 220–223 (adaptado del ejemplo)
- **Tema:** 0
- **Dificultad:** 1
- **Solución:** en el libro (p. 222–223)
- **SWISH:** parcial (el trazador gráfico tiene botones equivalentes a algunas opciones)
- **Enunciado:** Trazar `member(X, [a,b,c]), member(X, [d,c,e])` en `swipl` y practicar las opciones del trazador: avanzar (*creep*), saltear un objetivo (*skip*), forzar la falla (*fail*) y reintentarlo (*retry*).
- **Notas:** Teclas en SWI: Enter o `c` avanza, `s` saltea, `f` falla, `r` reintenta, `a` aborta, `h` ayuda.

### CM-8.9 — La sesión del programador descuidado
- **Fuente:** Clocksin & Mellish, cap. 8 §8.5, p. 224–226 (adaptado del ejemplo)
- **Tema:** 0
- **Dificultad:** 1
- **Solución:** en el libro (p. 226)
- **SWISH:** no (usa `consult(user)`)
- **Enunciado:** En una sesión, alguien carga con `consult(user)` un `append/3` con un error y luego lo "corrige" varias veces desde la terminal. Encontrar el error de la primera versión y explicar por qué, tras la segunda carga, `reverse/2` sigue sin funcionar.
  ```prolog
  append([A|B], C, [A|D]) :- append(A, C, D).
  append([], X, X).
  ```
- **Notas:** Volver a consultar reemplaza todas las cláusulas del predicado: si la nueva carga trae solo una cláusula, la otra se pierde. Moraleja: corregir el archivo y recargarlo (`make.` en SWI).

## Capítulo 9: Reglas gramaticales

### CM-9.1 — Un reconocedor con `append`
- **Fuente:** Clocksin & Mellish, cap. 9 §9.2, p. 230–233 (adaptado del ejemplo)
- **Tema:** 6, A
- **Dificultad:** 2
- **Solución:** en el libro (p. 231–232)
- **SWISH:** sí
- **Enunciado:** Para la gramática "oración → frase nominal + frase verbal; frase nominal → determinante + sustantivo; frase verbal → verbo | verbo + frase nominal", con las palabras `the`, `man`, `apple`, `eats`, `sings`, escribir `sentence(L)` partiendo la lista con `append/3`. Contar cuántas particiones prueba para `[the,man,eats,the,apple]`.
- **Notas:** Funciona, pero `append/3` propone particiones a ciegas; motiva la versión con listas de diferencia.

### CM-9.2 — De listas de diferencia a DCG
- **Fuente:** Clocksin & Mellish, cap. 9 §9.2–9.3, p. 233–237 (adaptado del ejemplo)
- **Tema:** A
- **Dificultad:** 2
- **Solución:** en el libro (p. 235–237)
- **SWISH:** sí
- **Enunciado:** Reescribir el reconocedor de CM-9.1 con dos argumentos por categoría (lista de entrada y lo que sobra), por ejemplo `noun_phrase(S0, S) :- determiner(S0, S1), noun(S1, S).` Luego escribir la misma gramática con `-->` y comprobar con `listing/1` que la traducción es la misma.
- **Notas:** Con DCG se consulta con `phrase(sentence, [the,man,eats,the,apple])` o `sentence([the,man,...], [])`. `noun_phrase([the,man,sings], X)` devuelve lo que sobra.

### CM-9.3 — Concordancia de número
- **Fuente:** Clocksin & Mellish, cap. 9 §9.4, p. 237–239 (adaptado del ejemplo)
- **Tema:** A
- **Dificultad:** 2
- **Solución:** en el libro (p. 239); verificado: acepta "the boys eat the apple" y rechaza "the boys eats the apple".
- **SWISH:** sí
- **Enunciado:** Agregar a las categorías un argumento `singular`/`plural` para que el sujeto concuerde con el verbo (`boy`/`boys`, `eats`/`eat`), sin duplicar reglas. ¿Qué número tiene `the`?
- **Notas:** `determiner(_) --> [the].` deja libre el número. En la segunda regla de frase verbal, el número viene del verbo, no del objeto.

### CM-9.4 — Construir el árbol de análisis
- **Fuente:** Clocksin & Mellish, cap. 9 §9.4, p. 239–241 (adaptado del ejemplo)
- **Tema:** A
- **Dificultad:** 2
- **Solución:** en el libro (p. 240); verificado.
- **SWISH:** sí
- **Enunciado:** Agregar a cada categoría un argumento que devuelva su árbol, de modo que "the man eats the apple" produzca `sentence(noun_phrase(determiner(the), noun(man)), verb_phrase(verb(eats), noun_phrase(...)))`. Escribir la cláusula Prolog en que se traduce la regla de `sentence`.
- **Notas:** Los dos argumentos de la lista se agregan al final: `sentence(X, T) --> …` se traduce a `sentence(X, T, S0, S)`.

### CM-9.5 — Traducir reglas gramaticales (Ejercicio 9.1)
- **Fuente:** Clocksin & Mellish, cap. 9 §9.4, p. 241 (Exercise 9.1)
- **Tema:** A, X
- **Dificultad:** 3
- **Solución:** en el libro (Apéndice A, p. 282–284); la versión simple se verificó con `sentence --> noun_phrase, verb_phrase` y `determiner --> [the]`.
- **SWISH:** sí
- **Enunciado:** Definir `translate(Regla, Clausula)`, que convierta una regla gramatical sin argumentos extra (`X --> Y`) en la cláusula Prolog correspondiente, agregando los dos argumentos de lista.
- **Notas:** El apéndice declara `op(1199, xfx, -->)`; en SWI `-->` ya es operador y la declaración sobra. Para que SWI no traduzca la regla al leerla, se pasa como argumento: `translate((a --> b, c), C)`.

### CM-9.6 — `phrase` con argumentos extra (Ejercicio 9.2)
- **Fuente:** Clocksin & Mellish, cap. 9 §9.4, p. 241 (Exercise 9.2)
- **Tema:** 9, A
- **Dificultad:** 2
- **Solución:** en el libro (Apéndice A, p. 284); verificado como `my_phrase(sentence(T), [the,man,sings])`.
- **SWISH:** sí
- **Enunciado:** Escribir una versión de `phrase/2` que acepte categorías con argumentos, como `phrase(sentence(X), [the,man,sings])`, agregando las dos listas al final del objetivo con `=..`.
- **Notas:** El `phrase/2` de SWI ya acepta argumentos extra; usar otro nombre. Con `call/N`: `my_phrase(G, L) :- call(G, L, []).`

### CM-9.7 — Diccionario con objetivos entre llaves
- **Fuente:** Clocksin & Mellish, cap. 9 §9.5, p. 241–243 (adaptado del ejemplo)
- **Tema:** A
- **Dificultad:** 2
- **Solución:** en el libro (p. 242–243)
- **SWISH:** sí
- **Enunciado:** Escribir una sola regla para los sustantivos, `noun(N, noun(W)) --> [W], {is_noun(W, N)}.`, con los datos en hechos `is_noun/2`. Agregar una regla para plurales regulares (singular + `s`) que use `atom_chars/2` y `append/3` dentro de las llaves.
- **Notas:** El OCR confunde las variables de la regla de plurales; la idea es separar el átomo en caracteres y comprobar que termina en `s`. Verificado: esa versión falla con error de instanciación si se usa para *generar* oraciones (la palabra aún no está ligada); `{is_noun(Raiz, singular), atom_concat(Raiz, s, W)}` funciona en los dos sentidos. La regla acepta plurales falsos como `mans`.

### CM-9.8 — Agregar palabras a la entrada
- **Fuente:** Clocksin & Mellish, cap. 9 §9.6, p. 244–245 (adaptado del ejemplo)
- **Tema:** A
- **Dificultad:** 2
- **Solución:** en el libro (p. 245); verificado con `listing(imperative//0)`.
- **SWISH:** sí
- **Enunciado:** Analizar "eat your supper" como si dijera "you eat your supper", con una regla cuya cabeza inserta `you` en la entrada: `imperative, [you] --> [].` Mostrar en qué cláusula se traduce.
- **Notas:** SWI la traduce a `imperative(A, [you|B]) :- A = B.`; la lista "sobrante" es más larga que la de entrada.

### CM-9.9 — Una gramática de gramáticas que no sirve (Ejercicio 9.3)
- **Fuente:** Clocksin & Mellish, cap. 9 §9.6, p. 244–245 (Exercise 9.3)
- **Tema:** 5, A
- **Dificultad:** 2
- **Solución:** Reglas como `grammar_body --> grammar_body, [','], grammar_body.` son recursivas a izquierda: para reconocer un `grammar_body` Prolog primero intenta reconocer otro `grammar_body` sin consumir nada, y entra en recursión infinita. Además la gramática es ambigua (no fija cómo agrupar `,` y `;`) e ignora las precedencias de los operadores.
- **SWISH:** sí
- **Enunciado:** La definición de las reglas gramaticales dada como gramática (p. 244), aunque se completara, no serviría como analizador de una secuencia de símbolos. ¿Por qué?
- **Notas:** Relacionar con CM-3.4: la recursión a izquierda también cuelga a las DCG.

### CM-9.10 — De oraciones a fórmulas lógicas (Ejercicio 9.4)
- **Fuente:** Clocksin & Mellish, cap. 9 §9.7, p. 245–247 (Exercise 9.4)
- **Tema:** A
- **Dificultad:** 3
- **Solución:** Verificado (con `=>` en lugar de `->`): "every man loves a woman" da `all(A, man(A) => exists(B, woman(B) & loves(A, B)))`; "every man that lives loves a woman" da `all(A, man(A) & lives(A) => exists(B, woman(B) & loves(A, B)))`; "every man that loves a woman lives" da `all(A, man(A) & exists(B, woman(B) & loves(A, B)) => lives(A))`. La lectura ambigua con una única mujer para todos no aparece: el programa compone los significados en el orden de la oración, y el cuantificador del sujeto siempre abarca al del objeto.
- **SWISH:** sí
- **Enunciado:** Estudiar el programa que traduce oraciones como "every man loves a woman" a cálculo de predicados, ejecutarlo con las tres oraciones del libro y explicar por qué no produce las dos lecturas de "every man loves a woman". ¿Qué supuesto hace sobre cómo se arma el significado?
- **Notas:** El libro declara `op(600, xfy, ->)`: en SWI eso cambia la prioridad del si-entonces-sino y rompe `( C -> A ; B )` en todo lo que se lea después (verificado: "Operator priority clash"). Usar `:- op(600, xfy, =>).` y `:- op(500, xfy, &).`

### CM-9.11 — DCG para llevar otro estado
- **Fuente:** Clocksin & Mellish, cap. 9 §9.8, p. 247–249 (adaptado del ejemplo)
- **Tema:** A, X
- **Dificultad:** 3
- **Solución:** en el libro (p. 248–249), pero no funciona así en SWI (ver notas).
- **SWISH:** sí
- **Enunciado:** Usar la notación DCG para pasar un contador en lugar de una lista: reescribir `listlen/2` (CM-3.11) de modo que cada elemento recorrido sume 1 al estado oculto.
- **Notas:** El libro redefine `'C'/3`, el predicado con que algunos sistemas traducen los terminales. SWI no usa `'C'/3`: traduce `[1]` como unificación con una lista, así que el truco no funciona. Alternativa verificada: un no terminal escrito a mano, `inc(N0, N) :- N is N0 + 1.`, y `len([_|T]) --> inc, len(T).`, llamado como `len([a,b,c], 0, N)` (`phrase/3` exige listas).

## Capítulo 10: Prolog y la lógica

> El capítulo no tiene ejercicios numerados. Las entradas siguientes adaptan sus ejemplos; son la conexión directa con los contenidos de lógica de la materia.

### CM-10.1 — Formalizar en cálculo de predicados
- **Fuente:** Clocksin & Mellish, cap. 10 §10.1, p. 251–254 (adaptado del ejemplo)
- **Tema:** X
- **Dificultad:** 1
- **Solución:** en el libro (p. 253–254)
- **SWISH:** no aplica (ejercicio de papel)
- **Enunciado:** Escribir con la notación del libro (`~`, `&`, `#`, `->`, `<->`, `all(X, P)`, `exists(X, P)`): "Fred es hombre o mujer", "si John es hombre, es humano", "todo hombre es humano", "John tiene una hija" y "todo animal tiene madre".
- **Notas:** Distinguir símbolos de función (arman términos, como `wife(henry)`) de símbolos de predicado (arman proposiciones); en Prolog ambos se escriben igual.

### CM-10.2 — Pasar a forma clausal
- **Fuente:** Clocksin & Mellish, cap. 10 §10.2, p. 254–260 (adaptado del ejemplo)
- **Tema:** X
- **Dificultad:** 2
- **Solución:** en el libro (p. 259–260); verificado con el programa del Apéndice B (CM-B.2): `person(f1(x)); king(x) :- .` y `king(x) :- respects(f1(x), x).`
- **SWISH:** no aplica (ejercicio de papel)
- **Enunciado:** Aplicar las seis etapas (eliminar implicaciones, llevar la negación adentro, skolemizar, sacar los universales, distribuir `&` sobre `#`, separar en cláusulas) a `all(X, all(Y, person(Y) -> respects(Y, X)) -> king(X))` y a `all(X, human(X) -> exists(Y, motherof(X, Y)))`.
- **Notas:** Al skolemizar un existencial dentro de un universal hay que usar una función de la variable universal (`g2(X)`), no una constante.

### CM-10.3 — Notación de cláusulas y cláusulas de Horn
- **Fuente:** Clocksin & Mellish, cap. 10 §10.3 y §10.5, p. 260–261 y 265–266 (adaptado del ejemplo)
- **Tema:** 2, X
- **Dificultad:** 2
- **Solución:** en el libro (p. 261)
- **SWISH:** no aplica (ejercicio de papel)
- **Enunciado:** Escribir en la notación `P1; …; Pm :- Q1, …, Qn` las cláusulas del ejemplo de Adán y Eva y las del ejemplo de las vacaciones. ¿Cuáles son cláusulas de Horn y se pueden escribir directamente en Prolog? ¿Por qué `holiday(X); work(chris, X) :- .` no?
- **Notas:** Una cláusula de Horn tiene a lo sumo un literal positivo: los hechos y reglas de Prolog tienen uno, y la consulta `?- A1, …, An` es la cláusula sin cabeza `:- A1, …, An`.

### CM-10.4 — Una demostración por resolución
- **Fuente:** Clocksin & Mellish, cap. 10 §10.4, p. 262–265 (adaptado del ejemplo)
- **Tema:** 4, X
- **Dificultad:** 2
- **Solución:** en el libro (p. 263–265)
- **SWISH:** no aplica (ejercicio de papel)
- **Enunciado:** Con las cláusulas de abajo, demostrar por refutación que Arturo es rey: agregar `:- king(arthur).` y derivar la cláusula vacía, indicando en cada paso qué literales se resuelven y qué unificador se usa.
  ```prolog
  person(f1(X)); king(X) :- .
  king(Y) :- respects(f1(Y), Y).
  respects(Z, arthur) :- person(Z).
  ```
- **Notas:** No se puede cargar en Prolog: la primera cláusula tiene dos literales positivos (no es de Horn).

### CM-10.5 — Un paso de resolución a la manera de Prolog
- **Fuente:** Clocksin & Mellish, cap. 10 §10.6, p. 266–268 (adaptado del ejemplo)
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** en el libro (p. 267): `:- parent(john, X), female(X), mother(X, Y).`
- **SWISH:** no aplica (ejercicio de papel)
- **Enunciado:** Resolver el objetivo `:- mother(john, X), mother(X, Y).` con la cláusula `mother(U, V) :- parent(U, V), female(V).` tal como lo hace Prolog: ¿qué literal se elige, qué unificador se usa y dónde se colocan los nuevos objetivos?
- **Notas:** Prolog elige siempre el primer literal del objetivo, prueba las cláusulas en orden y explora en profundidad; por eso puede no terminar aunque haya demostración.

### CM-10.6 — La verificación de ocurrencia
- **Fuente:** Clocksin & Mellish, cap. 10 §10.6, p. 268–269 (adaptado del ejemplo)
- **Tema:** 3
- **Dificultad:** 2
- **Solución:** en el libro (p. 268). En SWI, `equal(foo(Y), Y)` con `equal(X, X).` tiene éxito y crea el término cíclico `Y = foo(Y)`; `unify_with_occurs_check(foo(Y), Y)` falla.
- **SWISH:** sí
- **Enunciado:** Con `equal(X, X).`, consultar `equal(foo(Y), Y)` y explicar qué término representa Y. Repetir con `unify_with_occurs_check/2` y explicar por qué la unificación de la lógica debería fallar.
- **Notas:** SWI puede imprimir términos cíclicos. Con `set_prolog_flag(occurs_check, true)` toda unificación verifica ocurrencia (más lento).

### CM-10.7 — Lectura declarativa y lectura procedural
- **Fuente:** Clocksin & Mellish, cap. 10 §10.7, p. 268–271 (adaptado del ejemplo)
- **Tema:** 8, X
- **Dificultad:** 2
- **Solución:** en el libro (p. 270–271)
- **SWISH:** sí
- **Enunciado:** Dar una lectura lógica de `mother(X, Y) :- parent(X, Y), female(Y).` y de `append/3`. Luego explicar por qué no hay lectura lógica simple para cláusulas que usan `var/1`, el corte, `write/1` o `asserta/1`.
- **Notas:** Estrategia del libro: aislar las partes no lógicas en pocos predicados (como `\+`, `gensym`, `findall`) y escribir el resto en estilo declarativo.

## Apéndice B: Programa de forma clausal

### CM-B.1 — Sustituir una variable en una fórmula
- **Fuente:** Clocksin & Mellish, Apéndice B, p. 287–288 ("left as an exercise for the reader")
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** Verificado: `subst(x, g1, loves(x, f(x, y)), R)` da `loves(g1, f(g1, y))`.
  ```prolog
  subst(V1, V2, F1, V2) :- F1 == V1, !.
  subst(_, _, F1, F1) :- atomic(F1), !.
  subst(V1, V2, F1, F2) :- F1 =.. [Op|Args1],
      subst_list(V1, V2, Args1, Args2), F2 =.. [Op|Args2].
  subst_list(_, _, [], []).
  subst_list(V1, V2, [A|As], [B|Bs]) :-
      subst(V1, V2, A, B), subst_list(V1, V2, As, Bs).
  ```
- **SWISH:** sí
- **Enunciado:** Definir `subst(V1, V2, F1, F2)`: F2 es la fórmula F1 con cada aparición de V1 reemplazada por V2. (En el programa del apéndice las variables del cálculo de predicados son átomos como `x`, `y`.)
- **Notas:** Recorrido genérico de términos con `=..`. Usar `==` y no `=` para comparar, para no ligar variables por accidente.

### CM-B.2 — El programa completo de forma clausal
- **Fuente:** Clocksin & Mellish, Apéndice B, p. 285–290 (adaptado del ejemplo)
- **Tema:** X
- **Dificultad:** 3
- **Solución:** en el libro (p. 285–290); verificado en SWI con los ejemplos del capítulo 10 (reproduce las cláusulas del libro).
- **SWISH:** sí (con `=>` en lugar de `->`)
- **Enunciado:** Armar el programa `translate/1` del apéndice (seis etapas más la impresión) con `subst/4` de CM-B.1, y usarlo para verificar las formas clausales de CM-10.2 y CM-10.3.
- **Notas:** Como en CM-9.10, `op(700, xfy, ->)` rompe el si-entonces-sino de SWI: usar `=>` y `<=>`. `gensym/2` ya existe en SWI. El OCR tiene errores (`imptout`, `impk>ut`, `putin(X,[Y|L]r[Y|L1])`).

## Capítulo 11: Proyectos

> CM-11.1 a CM-11.10 son los "proyectos fáciles" (§11.1, mismos números que en el libro); CM-11.11 a CM-11.26 son los proyectos avanzados 1 a 16 (§11.2). Los avanzados son abiertos y sirven como trabajos finales; el libro no da soluciones de ninguno.

### CM-11.1 — Aplanar una lista
- **Fuente:** Clocksin & Mellish, cap. 11 §11.1 proyecto 1, p. 273
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** Verificado: `aplanar([a,[b,c],[[d],[],e]], F)` da `[a,b,c,d,e]`.
  ```prolog
  aplanar([], []) :- !.
  aplanar([H|T], F) :- !, aplanar(H, FH), aplanar(T, FT), append(FH, FT, F).
  aplanar(X, [X]).
  ```
- **SWISH:** sí
- **Enunciado:** Definir un predicado que "aplane" una lista: el resultado contiene todos los átomos de la original, en orden, y ninguna sublista. El libro afirma que hay al menos seis formas de escribirlo; intentar más de una (por ejemplo, con acumulador o con listas de diferencia).
- **Notas:** SWI trae `flatten/2`. Sin los cortes, al retroceder `[]` y las listas se tratarían también como elementos.

### CM-11.2 — Días entre dos fechas
- **Fuente:** Clocksin & Mellish, cap. 11 §11.1 proyecto 2, p. 273–274
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** Verificado: `interval(3-march, 7-april, N)` da `35`.
  ```prolog
  month(1, january, 31).  month(2, february, 28).  month(3, march, 31).
  month(4, april, 30).    % ... hasta month(12, december, 31).
  days_before(1, 0).
  days_before(N, B) :- N > 1, N1 is N - 1, days_before(N1, B1),
                       month(N1, _, D), B is B1 + D.
  day_of_year(D-M, N) :- month(I, M, _), days_before(I, B), N is B + D.
  interval(F1, F2, N) :- day_of_year(F1, N1), day_of_year(F2, N2), N is N2 - N1.
  ```
- **SWISH:** sí
- **Enunciado:** Calcular la cantidad de días entre dos fechas del mismo año no bisiesto, escritas como `Dia-Mes`, de modo que `interval(3-march, 7-april, 35)` tenga éxito.
- **Notas:** `3-march` no es una resta: es la estructura `-(3, march)`, que se desarma por unificación.

### CM-11.3 — Derivar funciones trigonométricas
- **Fuente:** Clocksin & Mellish, cap. 11 §11.1 proyecto 3, p. 274
- **Tema:** 3, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Extender el derivador (CM-7.33) y el simplificador (CM-7.35) para expresiones con funciones trigonométricas (y, opcionalmente, operadores vectoriales como div, grad y rot).
- **Notas:** Cada regla nueva es una cláusula, por ejemplo `d(sin(U), X, cos(U)*A) :- d(U, X, A).` (regla de la cadena).

### CM-11.4 — Negar una expresión proposicional
- **Fuente:** Clocksin & Mellish, cap. 11 §11.1 proyecto 4, p. 274
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** Verificado: `negate(p implies (q and not r), N)` da `p and (not q or r)`.
  ```prolog
  :- op(700, xfy, implies).  :- op(600, xfy, or).
  :- op(500, xfy, and).      :- op(400, fy, not).
  negate(P implies Q, P1 and Q1) :- !, pos(P, P1), negate(Q, Q1).
  negate(P and Q, P1 or Q1) :- !, negate(P, P1), negate(Q, Q1).
  negate(P or Q, P1 and Q1) :- !, negate(P, P1), negate(Q, Q1).
  negate(not P, P1) :- !, pos(P, P1).
  negate(P, not P).
  pos(P implies Q, P1 or Q1) :- !, negate(P, P1), pos(Q, Q1).
  pos(P and Q, P1 and Q1) :- !, pos(P, P1), pos(Q, Q1).
  pos(P or Q, P1 or Q1) :- !, pos(P, P1), pos(Q, Q1).
  pos(not P, P1) :- !, negate(P, P1).
  pos(P, P).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir un programa que niegue una expresión proposicional formada con átomos, `not`, `and`, `or` e `implies` (declarados como operadores), dejando `not` aplicado solo a átomos. Por ejemplo, la negación de `p implies (q and not(r))` es `p and (not(q) or r)`.
- **Notas:** `pos/2` lleva la fórmula a la misma forma sin negarla; hace falta porque `~(P -> Q)` equivale a `P & ~Q`. Relacionar con la etapa 2 de CM-10.2.

### CM-11.5 — Concordancia de palabras
- **Fuente:** Clocksin & Mellish, cap. 11 §11.1 proyecto 5, p. 274
- **Tema:** 6, 9
- **Dificultad:** 2
- **Solución:** Verificado: `concordance([the,cat,sat,on,the,mat], C)` da `[cat-1,mat-1,on-1,sat-1,the-2]`.
  ```prolog
  concordance(Words, C) :- msort(Words, Sorted), clumped(Sorted, C).
  ```
- **SWISH:** sí
- **Enunciado:** Producir una concordancia de un texto: la lista de sus palabras en orden alfabético, cada una con la cantidad de veces que aparece. Escribirla primero sin predicados de biblioteca (ordenamiento del capítulo 7 más un recorrido que cuente repetidos consecutivos).
- **Notas:** El libro representa las palabras como listas de códigos ASCII; en SWI es más cómodo usar átomos (una cadena `"..."` es otro tipo de dato). `msort/2` conserva repetidos; `sort/2` los elimina.

### CM-11.6 — Diálogo "X es un Y"
- **Fuente:** Clocksin & Mellish, cap. 11 §11.1 proyecto 6, p. 274–275
- **Tema:** 10, A
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** parcial (lee con `read/1`; en SWISH no se pueden agregar reglas con `assert`, solo hechos)
- **Enunciado:** Escribir un programa que entienda oraciones de las formas "John is a man", "A man is a person" e "Is John a person?", responda `ok`, `yes`, `no` o `unknown`, y guarde cada afirmación como hecho o regla (`man(john).`, `person(X) :- man(X).`).
- **Notas:** El libro sugiere un bucle `talk :- repeat, read(S), parse(S, C), respond_to(C), C = stop.` y reglas gramaticales para `parse/2`. Para distinguir "no" de "unknown" hay que decidir qué se sabe que es falso.

### CM-11.7 — Poda alfa-beta
- **Fuente:** Clocksin & Mellish, cap. 11 §11.1 proyecto 7, p. 275
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar el algoritmo alfa-beta de búsqueda en árboles de juego.
- **Notas:** Conviene empezar por minimax sobre un árbol dado como hechos, y aplicarlo luego al ta-te-tí de CM-4.10.

### CM-11.8 — Las N reinas
- **Fuente:** Clocksin & Mellish, cap. 11 §11.1 proyecto 8, p. 275
- **Tema:** 4, 7
- **Dificultad:** 2
- **Solución:** Verificado: para 4 hay 2 soluciones, `[2,4,1,3]` y `[3,1,4,2]`; para 8, 92.
  ```prolog
  queens(N, Qs) :- numlist(1, N, Ns), permutation(Ns, Qs), safe(Qs).
  safe([]).
  safe([Q|Qs]) :- no_attack(Q, Qs, 1), safe(Qs).
  no_attack(_, [], _).
  no_attack(Q, [Q1|Qs], D) :- Q =\= Q1 + D, Q =\= Q1 - D,
                              D1 is D + 1, no_attack(Q, Qs, D1).
  ```
- **SWISH:** sí
- **Enunciado:** Encontrar todas las formas de ubicar 4 reinas en un tablero de 4×4 sin que se ataquen, generando permutaciones y descartando las que ponen dos reinas en la misma diagonal.
- **Notas:** La permutación garantiza una reina por fila y por columna: solo falta controlar las diagonales. Es "generar y probar" (CM-4.10); para N grande conviene probar mientras se genera.

### CM-11.9 — Todo con NAND
- **Fuente:** Clocksin & Mellish, cap. 11 §11.1 proyecto 9, p. 275
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** Con los operadores de CM-11.4 más `:- op(650, xfy, nand).` (verificado: `p and q` da `(p nand q) nand (p nand q)`):
  ```prolog
  to_nand(P, P) :- atom(P), !.
  to_nand(not P, N nand N) :- !, to_nand(P, N).
  to_nand(P and Q, (A nand B) nand (A nand B)) :- !, to_nand(P, A), to_nand(Q, B).
  to_nand(P or Q, (A nand A) nand (B nand B)) :- !, to_nand(P, A), to_nand(Q, B).
  to_nand(P implies Q, A nand (B nand B)) :- to_nand(P, A), to_nand(Q, B).
  ```
- **SWISH:** sí
- **Enunciado:** Reescribir expresiones proposicionales (como en CM-11.4) reemplazando `and`, `or`, `implies` y `not` por el único conectivo `nand`, definido por `(a nand b) = not(a and b)`.
- **Notas:** Se puede verificar evaluando ambas fórmulas en todas las asignaciones de verdad.

### CM-11.10 — Aritmética de Peano
- **Fuente:** Clocksin & Mellish, cap. 11 §11.1 proyecto 10, p. 275–276
- **Tema:** 5
- **Dificultad:** 2
- **Solución:** Verificado: `plus(s(s(0)), s(s(s(0))), X)` da `s(s(s(s(s(0)))))` y `plus(X, Y, s(s(0)))` enumera las tres descomposiciones.
  ```prolog
  plus(0, Y, Y).
  plus(s(X), Y, s(Z)) :- plus(X, Y, Z).
  times(0, _, 0).
  times(s(X), Y, Z) :- times(X, Y, W), plus(W, Y, Z).
  minus(X, Y, Z) :- plus(Y, Z, X).   % falla si Y > X
  less(0, s(_)).
  less(s(X), s(Y)) :- less(X, Y).
  ```
- **SWISH:** sí
- **Enunciado:** Representando los naturales como `0`, `s(0)`, `s(s(0))`, …, definir suma, producto, resta y "menor que". ¿Qué argumentos deben estar ligados para que funcionen y qué pasa en los otros casos? Comparar con `is/2`. Intentar después división entera y raíz cuadrada.
- **Notas:** A diferencia de `is/2`, `plus/3` funciona "al revés" y sirve para restar. `times(X, Y, s(s(s(s(0)))))` con X e Y libres encuentra soluciones pero no termina al pedir más.

### CM-11.11 — Planificar un viaje con horarios
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 1, p. 276
- **Tema:** 7, 9
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dado un mapa de rutas con distancia, estado del camino, tránsito, pendientes y estaciones de servicio, planificar un recorrido entre dos ciudades con un horario estimado.
- **Notas:** Extensión natural de CM-7.29 (búsqueda "el mejor primero").

### CM-11.12 — Aritmética de números racionales
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 2, p. 276
- **Tema:** 7
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir un paquete de aritmética de racionales representados como fracciones (o como mantisa y exponente).
- **Notas:** Usar `gcd/3` de CM-7.31 para simplificar. SWI ya tiene racionales nativos (`1r3`, `rational/1`), útiles para verificar resultados.

### CM-11.13 — Matrices
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 3, p. 276
- **Tema:** 6, 7, 9
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir predicados para multiplicar e invertir matrices.
- **Notas:** Representar una matriz como lista de filas; `maplist/N`, `foldl/4` y `transpose/2` (de `library(clpfd)`) simplifican mucho el código.

### CM-11.14 — Un compilador de expresiones
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 4, p. 276
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir un compilador que transforme árboles sintácticos: primero expresiones aritméticas a código para una máquina de pila, luego estructuras de control como si-entonces-sino.
- **Notas:** Combina transformación de árboles (CM-7.35) y, para el análisis sintáctico, DCG.

### CM-11.15 — Juegos de tablero complejos
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 5, p. 276
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Diseñar una representación para ajedrez o go y estudiar cómo usar la unificación de Prolog para reconocer patrones y aplicar estrategias.
- **Notas:** Proyecto abierto; partir de CM-4.10 y CM-11.7.

### CM-11.16 — Demostrador para una teoría axiomática
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 6, p. 276
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Diseñar un formalismo para axiomas de algún dominio (teoría de grupos, geometría euclídea, semántica denotacional) y escribir un demostrador de teoremas para él.
- **Notas:** Ver capítulo 10 y CM-11.23.

### CM-11.17 — Intérprete con otro orden de ejecución
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 7, p. 276–277
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Partiendo del intérprete de CM-7.37, escribir uno con otra semántica de ejecución, por ejemplo un orden de objetivos más flexible que izquierda a derecha, usando una agenda.
- **Notas:** Una variante accesible: un intérprete con límite de profundidad o en amplitud, que termine donde Prolog se cuelga (CM-3.4).

### CM-11.18 — Generador de planes
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 8, p. 277
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Consultar la literatura de inteligencia artificial sobre planificación e implementar un generador de planes.
- **Notas:** El mundo de bloques con acciones de precondiciones y efectos (estilo STRIPS) es un buen punto de partida.

### CM-11.19 — Interpretar dibujos de líneas
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 9, p. 277
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Expresar la interpretación de un dibujo de líneas como problema de restricciones: los rasgos del dibujo son variables que representan rasgos de la escena y deben satisfacer ciertas condiciones.
- **Notas:** Relacionado con el etiquetado de Waltz; puede resolverse con generar y probar o con `library(clpfd)`.

### CM-11.20 — Voz pasiva y verbos de control
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 10, p. 277
- **Tema:** A
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir con reglas gramaticales un analizador para oraciones como "Fred saw John", "Mary was seen by John", "Fred told Mary to see John" y "Was John believed to have told Mary to see Fred?".
- **Notas:** Partir de CM-9.3 y CM-9.4; la voz pasiva y las preguntas requieren argumentos extra para rastrear constituyentes desplazados.

### CM-11.21 — Sistema de reglas de producción
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 11, p. 277–278
- **Tema:** 10, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** parcial (necesita preguntar al usuario)
- **Enunciado:** Escribir un intérprete de reglas "si situación entonces acción" y aplicarlo a identificar plantas o animales por sus características, preguntando al usuario lo que no sabe ("¿el tallo es cuadrado?").
- **Notas:** Guardar las respuestas del usuario con `assert/1` para no repetir preguntas.

### CM-11.22 — Traducir un corpus al cálculo de predicados
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 12, p. 278
- **Tema:** A, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir un programa que traduzca un conjunto de oraciones en inglés (o castellano) a fórmulas del cálculo de predicados.
- **Notas:** Extensión de CM-9.10.

### CM-11.23 — Demostrador de teoremas
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 13, p. 278
- **Tema:** X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Escribir un programa que demuestre teoremas del cálculo de predicados.
- **Notas:** Combinar la forma clausal (CM-B.2) con resolución (CM-10.4), usando `unify_with_occurs_check/2` para que sea correcto.

### CM-11.24 — Un psiquiatra simulado
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 14, p. 278
- **Tema:** 6, A
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** parcial (entrada interactiva)
- **Enunciado:** Escribir un programa de diálogo que responda según palabras clave de lo que escribe el usuario (por ejemplo, ante "mother" pregunta por la familia; si no hay palabra clave, dice "I see. Please continue."), al estilo de ELIZA.
- **Notas:** Generaliza `alter/2` (CM-3.6); `read_in/1` (CM-5.8) sirve para leer oraciones sin comillas.

### CM-11.25 — Resumen de oraciones sobre una oficina
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 15, p. 278–279
- **Tema:** 10, A
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Analizar con reglas gramaticales oraciones como "Smith will be in his office at 3 pm for a meeting", imprimir un resumen (quién, qué, dónde, cuándo), guardarlo en la base de datos y responder preguntas como "Where is Smith at 3 pm?".
- **Notas:** Las respuestas son consultas sobre los hechos guardados.

### CM-11.26 — Preguntas en lenguaje natural sobre archivos
- **Fuente:** Clocksin & Mellish, cap. 11 §11.2 proyecto 16, p. 279
- **Tema:** A, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no (consulta el sistema de archivos)
- **Enunciado:** Escribir una interfaz en lenguaje natural para el sistema de archivos que responda preguntas como "How many files does David own?" o "When did Bill change the file VIDEO.C?".
- **Notas:** Para practicar sin acceder al disco, representar los archivos como hechos `file(Nombre, Dueño, Fecha)`: queda un ejercicio de DCG más consultas a una base de datos (tema 11).
