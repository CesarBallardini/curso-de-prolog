# Ejercicios candidatos: Derek Banas, "Learn Prolog in One Video" (New Think Tank)

- **Página:** <https://www.newthinktank.com/2015/08/learn-prolog-one-video/> (Derek Banas, 12/08/2015). La página tiene un "cheat sheet" con todo el código del video.
- **Video:** <https://www.youtube.com/watch?v=SykxWpFwMGs> ("Prolog Tutorial", 1:03:37).
- **Capítulos del video** (según la descripción de YouTube): Instalación 01:08 · Introducción 05:40 · Hechos 09:55 · Reglas 12:00 · Variables 15:30 · "If" 23:54 · Términos compuestos 25:56 · Format 28:38 · Comparación 31:13 · Trace 33:36 · Recursión 36:16 · Matemática 39:10 · Consola 44:08 · Archivos 46:10 · Bucles 49:29 · Modificar la base 53:31 · Listas 56:51 · Strings 1:00:47.
- **Sistema Prolog del video:** probablemente **GNU Prolog**. Lo deduzco de las respuestas `yes`/`no` y del formato de traza `1 1 Call: ...`; no lo confirmé mirando el segmento de instalación. SWI-Prolog responde `true`/`false` y muestra la traza de otra forma.
- **Verificación:** el 2026-09-18 cargué el cheat sheet completo en **SWI-Prolog 9.2.9** y ejecuté las consultas principales. Las diferencias con SWI y los errores del código original están anotados en cada entrada: son buen material para ejercicios de depuración.
- **Leyenda de Tema:** 0 Entorno · 1 Hechos · 2 Reglas · 3 Términos y unificación · 4 Búsqueda/backtracking · 5 Recursión · 6 Listas · 7 Aritmética · 8 Corte y negación · 9 findall/orden superior · 10 assert/retract · 11 Prolog y SQL · A DCG · X Avanzado.

---

### NTT-1 — Primer contacto: cargar, listar y salir

- **Fuente:** newthinktank.com (cheat sheet, sección INTRODUCTION); video 05:40
- **Tema:** 0
- **Dificultad:** 1
- **Solución:** sí (en la página)
- **SWISH:** sí (salvo `halt/0` y `consult/1` de archivos locales)
- **Enunciado:** Escribí un archivo `familia.pl` con un par de hechos, cargalo con `[familia].` o `consult('familia.pl').`, mostralo con `listing.` y `listing(male).`, y escribí en consola `Hello World` y `Let's Program` en dos líneas usando `write/1` y `nl/0`.
- **Notas:** Sirve para mostrar el escape `\'` dentro de un átomo entre comillas simples. SWI responde `true`/`false`, no `yes`/`no` como en el video.

### NTT-2 — Romeo y Julieta: primer hecho y primera regla

- **Fuente:** cheat sheet, INTRODUCTION; video 05:40–09:55
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** sí
- **SWISH:** sí
- **Enunciado:** Dado `loves(romeo, juliet).` y la regla `loves(juliet, romeo) :- loves(romeo, juliet).`, respondé `?- loves(juliet, romeo).` y `?- loves(romeo, X).` ¿Qué diferencia hay entre un hecho y una regla? ¿Qué es una cláusula?
- **Notas:** Sirve para presentar la terminología: predicado, átomo, argumento, cláusula y variable (en mayúscula).

### NTT-3 — Hechos unarios y combinaciones

- **Fuente:** cheat sheet, FACTS; video 09:55
- **Tema:** 1, 4
- **Dificultad:** 1
- **Solución:** sí
- **SWISH:** sí
- **Enunciado:** Con los hechos `male/1` (albert, bob, bill, carl, charlie, dan, edward) y `female/1` (alice, betsy, diana), consultá `female(alice)`, `male(X)` y `male(X), female(Y)`. ¿Cuántas respuestas da la última consulta y por qué?
- **Notas:** Salen 7 × 3 = 21 pares. Es una buena introducción al backtracking como producto cartesiano. Conviene pedir a los alumnos que anticipen el orden de las respuestas.

### NTT-4 — Conjunción, disyunción y predicados sin definir

- **Fuente:** cheat sheet, RULES; video 12:00
- **Tema:** 2
- **Dificultad:** 2
- **Solución:** sí (con la corrección de la nota)
- **SWISH:** sí
- **Enunciado:** Con `happy/1`, `with_albert/1`, `runs/1`, `dances/1` y `swims/1` como en el video, consultá `dances(alice)`, `swims(bob)` y `swims(bill)`. Explicá qué pasa y corregí el programa para que `swims(bob)` falle limpiamente.
- **Notas:** **Verificado en SWI:** `near_water/1` no está definido, así que `swims(bob)` lanza `existence_error` en lugar de responder `no` como en el video. `swims(bill)` da primero `true` y, al pedir otra respuesta con `;`, lanza el mismo error. La corrección es declarar `:- dynamic near_water/1.` o agregar algún hecho `near_water(...)`. Sirve para discutir la hipótesis de mundo cerrado frente a un predicado inexistente.

### NTT-5 — Familia: padres, abuelos y nietos

- **Fuente:** cheat sheet, VARIABLES; video 15:30
- **Tema:** 2, 4
- **Dificultad:** 1–2
- **Solución:** sí
- **SWISH:** sí
- **Enunciado:** Con los hechos `parent/2` del video, respondé con consultas compuestas: ¿quiénes son los padres de bob?, ¿quiénes son los nietos de albert?, ¿carl y charlie comparten un padre? Definí `grand_parent(X, Y)` (Y es abuelo/a de X) y probalo con `grand_parent(carl, A)`.
- **Notas:** **Verificado:** `grand_parent(carl, A)` da `albert` y `alice`. En el original, `get_grandparent` imprime "bob is the grandparent", pero bob es el *padre* de carl y charlie. Un buen ejercicio es pedir que encuentren y corrijan ese error lógico.

### NTT-6 — Variable anónima y avisos de singleton

- **Fuente:** cheat sheet, VARIABLES y COMPLEX TERMS; video 15:30–28:38
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** sí
- **SWISH:** sí
- **Enunciado:** Usá `_` para preguntar si existe algún hombre (`male(_)`) y cuál es el saldo de sally (`customer(sally, _, Bal)`). Explicá el aviso "Singleton variables" de SWI y cómo evitarlo.
- **Notas:** SWI avisa de singletons en `vertical/1` y `horizontal/1` (ver NTT-8). La práctica recomendada es usar `_Y` o `_` para las variables que aparecen una sola vez.

### NTT-7 — "¿Dónde está el if?": casos por cláusulas

- **Fuente:** cheat sheet, WHERE IS IF?; video 23:54
- **Tema:** 8
- **Dificultad:** 2
- **Solución:** parcial (el original tiene un error)
- **SWISH:** sí
- **Enunciado:** `what_grade/1` imprime el grado escolar según la edad. Probá `what_grade(5)` y pedí más respuestas. Explicá la salida y corregilo de dos maneras: (a) con una guarda aritmética en la tercera cláusula (`Other > 6`) y (b) con un corte.
- **Notas:** **Verificado en SWI:** `what_grade(5)` imprime "Go to kindergarten" y, al volver atrás, también "Go to grade 0". Es un ejemplo clásico para introducir el corte y comparar el corte verde con la guarda explícita, que es más declarativa.

### NTT-8 — Términos compuestos: mascotas y segmentos

- **Fuente:** cheat sheet, COMPLEX TERMS / STRUCTURES; video 25:56
- **Tema:** 3
- **Dificultad:** 1–2
- **Solución:** sí
- **SWISH:** sí
- **Enunciado:** Con `owns(albert, pet(cat, olive))` preguntá el nombre del gato. Definí `vertical/1` y `horizontal/1` sobre `line(point(X,Y), point(X2,Y2))` usando unificación (sin aritmética). Consultá `vertical(line(point(5,10), point(X,20)))` y `vertical(line(point(5,10), P))`.
- **Notas:** **Verificado:** la última consulta devuelve `P = point(5, _)`, una respuesta con una variable libre. Es un excelente ejemplo de que la unificación "calcula". El código original genera avisos de singleton; corregirlo con `_`.

### NTT-9 — Salida con formato

- **Fuente:** cheat sheet, COMPLEX TERMS (`get_cust_bal`) y VARIABLES (`get_grandparent`); video 28:38
- **Tema:** 0 (E/S)
- **Dificultad:** 1
- **Solución:** sí
- **SWISH:** sí
- **Enunciado:** Con `customer(Nombre, Apellido, Saldo)`, escribí `get_cust_bal/2`, que imprima "sally smith owes us $120.55" usando `format/2` con `~w`, `~2f` y `~n`.
- **Notas:** **Verificado en SWI:** funciona. `~s` con `"is the"` también anda en SWI 7+, porque las comillas dobles son un *string* y `~s` los acepta.

### NTT-10 — Comparación, igualdad y unificación

- **Fuente:** cheat sheet, COMPARISON; video 31:13
- **Tema:** 3, 7, 8
- **Dificultad:** 2
- **Solución:** sí (en comentarios)
- **SWISH:** sí
- **Enunciado:** Predecí y luego comprobá: `alice = alice`, `'alice' = alice`, `\+ (alice = albert)`, `W = alice`, `Rand1 = Rand2`, `rich(money, X) = rich(Y, no_debt)`, `3 >= 15`. Para cada una explicá si es unificación, comparación aritmética o negación por falla.
- **Notas:** El video dice que `W = alice` "asigna". Conviene corregir esa idea: es unificación, no asignación, y conviene decirlo explícitamente a alumnos que vienen de C. Se puede agregar `==` y `=:=` para contrastar.

### NTT-11 — Seguir la ejecución con trace

- **Fuente:** cheat sheet, TRACE; video 33:36
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** sí (traza en la página)
- **SWISH:** sí (SWISH tiene un depurador gráfico: `trace, mammal(penguin).`)
- **Enunciado:** Con `warm_blooded/1`, `produce_milk/1`, `have_hair/1` y `mammal/1`, trazá `mammal(human)` y `mammal(penguin)`. Identificá los puertos Call, Exit y Fail y el punto exacto en que falla el pingüino.
- **Notas:** La traza de la página tiene el formato de GNU Prolog; la de SWI se ve distinta (`Call: (10) mammal(human) ?`). Sirve para presentar el modelo de cajas de Byrd.

### NTT-12 — Recursión: el ancestro

- **Fuente:** cheat sheet, RECURSION; video 36:16
- **Tema:** 5
- **Dificultad:** 2
- **Solución:** sí
- **SWISH:** sí
- **Enunciado:** Definí `related(X, Y)` (X es ancestro de Y) con un caso base y un caso recursivo sobre `parent/2`. Consultá `related(albert, carl)` y `related(albert, Y)`. Extensión: invertí el orden de los objetivos del caso recursivo (`related(Z, Y), parent(X, Z)`) o de las cláusulas y explicá qué cambia.
- **Notas:** **Verificado:** `related(albert, Y)` da bob, betsy, bill, carl y charlie. La extensión introduce la recursión por la izquierda y la no terminación.

### NTT-13 — Aritmética con is/2

- **Fuente:** cheat sheet, MATH; video 39:10
- **Tema:** 7
- **Dificultad:** 1
- **Solución:** sí
- **SWISH:** sí
- **Enunciado:** Evaluá `X is 3 + (2 * 10)`, `X is mod(7, 2)`, `5+4 =:= 4+5` y `X is 2 ** 3`. Escribí `double_digit(X, Y)` (Y es el doble de X) y `is_even(X)` usando `//`. ¿Funciona `double_digit(X, 8)`? ¿Por qué?
- **Notas:** La pregunta final lleva a que `is/2` no es reversible (error de instanciación). Se puede mencionar `library(clpfd)` como alternativa declarativa. `between/3`, `succ/2` y `random/3` existen en SWI.

### NTT-14 — Entrada y salida por consola y por archivos

- **Fuente:** cheat sheet, INPUT / OUTPUT; video 44:08–49:29
- **Tema:** 0 (E/S), 8
- **Dificultad:** 2
- **Solución:** sí
- **SWISH:** no (SWISH no permite leer ni escribir archivos; `read/1` funciona con un diálogo)
- **Enunciado:** Escribí `say_hi/0`, que pida un nombre con `read/1` y salude. Escribí `write_to_file/2` y `read_file/1`, que copie un archivo carácter a carácter a la consola usando `get_char/2` hasta `end_of_file`.
- **Notas:** `fav_char` usa `get/1` y `put/1`, predicados heredados de DEC-10 que conviene reemplazar por `get_char/1` y `put_char/1`. `process_stream(end_of_file, _) :- !.` es un corte verde razonable para mostrar. Es tema secundario para el curso.

### NTT-15 — Bucles: recursión y bucles por falla

- **Fuente:** cheat sheet, HOW TO LOOP; video 49:29
- **Tema:** 5, 4
- **Dificultad:** 2
- **Solución:** sí
- **SWISH:** sí
- **Enunciado:** (a) Escribí `count_to_10(X)`, que imprima de X a 10 recursivamente. ¿Qué pasa con `count_to_10(11)`? Corregilo. (b) Analizá `count_down(Low, High)`, que usa `between/3` y termina con `Y = 10`: explicá por qué funciona como un bucle.
- **Notas:** **Verificado:** `count_down(0, 10)` imprime de 10 a 0. `count_to_10(11)` no termina en el original. La parte (b) es un buen ejemplo de bucle por falla (*failure-driven loop*) para contrastarlo con la recursión.

### NTT-16 — Depurar el juego de adivinar

- **Fuente:** cheat sheet, HOW TO LOOP (`guess_num`, `loop/1`); video 49:29
- **Tema:** 5
- **Dificultad:** 2
- **Solución:** no (hay que corregir el original)
- **SWISH:** parcial (`read/1` en SWISH abre un diálogo)
- **Enunciado:** El programa `guess_num` debería repetir hasta que el usuario escriba 15. Encontrá los dos errores: (1) la guarda `x \= 15` usa el átomo `x` en minúscula, no la variable; (2) el programa imprime "15 is not the number" antes de "You guessed it!". Corregilo.
- **Notas:** SWI avisa de la variable `X` singleton en esa cláusula (verificado), lo que da una pista. Es un buen ejercicio de lectura de avisos del compilador.

### NTT-17 — Modificar la base: assert y retract

- **Fuente:** cheat sheet, CHANGING THE DATABASE; video 53:31
- **Tema:** 10
- **Dificultad:** 2
- **Solución:** sí
- **SWISH:** sí (el estado no persiste entre consultas)
- **Enunciado:** Declarando `:- dynamic friend/2.` y demás, usá `assertz/1`, `asserta/1`, `retract/1` y `retractall/1` para agregar y quitar hechos del mundo de Romeo y Julieta, y verificá el efecto con consultas.
- **Notas:** **Verificado en SWI:** como `stabs/3` aparece en dos lugares del archivo, SWI avisa de cláusulas no contiguas y `hates(romeo, X)` devuelve `tybalt` **dos veces**. Sirve para mostrar por qué hay que agrupar las cláusulas.

### NTT-18 — Listas: cabeza, cola y recorrido

- **Fuente:** cheat sheet, LISTS; video 56:51
- **Tema:** 6
- **Dificultad:** 1–2
- **Solución:** sí
- **SWISH:** sí
- **Enunciado:** Resolvé con unificación: `[H|T] = [a,b,c]`, `[_, X2, _, _|T] = [a,b,c,d]`, `[_, _, [X|Y], _, Z|T] = [a, b, [c,d,e], f, g, h]`. Usá `length/2`, `member/2`, `reverse/2` y `append/3`. Escribí `write_list/1`, que imprima cada elemento en una línea.
- **Notas:** Se puede ampliar pidiendo `append(X, Y, [1,2,3])` para mostrar la reversibilidad.

### NTT-19 — Cadenas como listas de códigos

- **Fuente:** cheat sheet, STRINGS; video 1:00:47
- **Tema:** 6, X
- **Dificultad:** 2
- **Solución:** parcial (el original tiene un error)
- **SWISH:** sí
- **Enunciado:** Escribí `join_str(A, B, C)`, que concatene dos átomos pasando por listas de códigos con `name/2` y `append/3`. Luego resolvelo con `atom_concat/3` y compará.
- **Notas:** **Verificado:** `join_str('Another ', 'Random String', X)` da `'Another Random String'`. La última línea del cheat sheet (`atom_length('Derek',X).`) está escrita como cláusula y no como consulta. Al cargar el archivo, SWI da `No permission to modify static procedure atom_length/2`. Hay que usarla en el *toplevel*. En SWI 7+, `"..."` es un *string*, no una lista de códigos; vale la pena mencionar `string_concat/3` y `atom_codes/2`.
