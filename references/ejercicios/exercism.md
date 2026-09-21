# Exercism: *track* de Prolog

- **Fuente:** Exercism, *Prolog track*, ejercicios de práctica (*practice exercises*).
- **URL:** https://exercism.org/tracks/prolog/exercises. Cada ejercicio está en `https://exercism.org/tracks/prolog/exercises/<slug>`. Repositorio: https://github.com/exercism/prolog, con los enunciados en `exercises/practice/<slug>/.docs/instructions.md`.
- **Licencia:** MIT (© 2021 Exercism, archivo `LICENSE` del repositorio). Casi todos los enunciados vienen de `exercism/problem-specifications`, también MIT. Aun así, aquí están parafraseados en castellano.
- **Verificación:** la lista y las dificultades salen de `config.json` del repositorio (rama `main`, septiembre de 2026). El sitio web devuelve 403 a los clientes automáticos, así que las URLs de `exercism.org` siguen el formato estándar y las del repositorio se comprobaron. El *track* no tiene ejercicios de concepto (*concept exercises*), solo de práctica.
- **Dificultad:** Exercism usa una escala de 1 a 10, que el sitio muestra como *easy* (1–3), *medium* (4–7) y *hard* (8–10). Acá se convierte a la escala del curso así: 1–3 → **1**, 4–6 → **2**, 7–10 → **3**. Cada entrada indica también el valor original (`d=`).
- **Soluciones:** cada ejercicio trae una solución de referencia en `exercises/practice/<slug>/.meta/<slug_con_guiones_bajos>.example.pl`, por ejemplo https://github.com/exercism/prolog/blob/main/exercises/practice/leap/.meta/leap.example.pl. **Verificado:** las 110 soluciones de referencia pasan sus tests (`<slug>_tests.plt`, con plunit) en SWI-Prolog 9.2.9 (`swipl -g run_tests -t halt X.example.pl X_tests.plt -- --all`). Las soluciones de la comunidad están en el sitio y requieren cuenta.
- **SWISH:** el flujo de Exercism es local: CLI de Exercism, `swipl` y tests plunit. La solución en sí se puede escribir y probar en SWISH, pero los archivos `.plt` no se corren ahí. Por eso "sí" quiere decir que la lógica funciona en SWISH, y se aclaran las excepciones: hilos, `setarg/3` y números aleatorios.
- **Advertencias del *track*:** muchos ejercicios usan *strings* de SWI-Prolog (`"..."`) y piden pasar a lista con `string_chars/2` o `string_codes/2`. Además, 48 de las 110 soluciones de referencia usan `library(clpfd)`. Ninguna de las dos cosas es obligatoria para resolverlos.
- **Total:** 110 ejercicios (109 activos y 1 obsoleto, `minesweeper`, reemplazado por `flower-field`).

**Cantidad por tema** (un ejercicio puede tener más de un tema):

| Tema | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | A | X |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ejercicios | 0 | 9 | 3 | 7 | 14 | 25 | 60 | 48 | 5 | 17 | 2 | 0 | 6 | 8 |

---

## Fáciles (Exercism *easy*, d=1–3)

### EXM-hello-world — Hola, mundo
- **Fuente:** Exercism Prolog, `hello-world`, d=1 (*easy*). https://exercism.org/tracks/prolog/exercises/hello-world
- **Tema:** 1
- **Dificultad:** 1
- **Solución:** sí (referencia en `.meta/`)
- **SWISH:** sí
- **Enunciado:** Modificar el único hecho del archivo para que `hello_world('Hello, World!')` sea verdadero.
  ```prolog
  hello_world('Goodbye, Mars!').
  ```
- **Notas:** Es el primer contacto con el flujo de Exercism: descargar, correr los tests y enviar.

### EXM-resistor-color — Código de colores de resistencias
- **Fuente:** Exercism Prolog, `resistor-color`, d=1 (*easy*). https://exercism.org/tracks/prolog/exercises/resistor-color
- **Tema:** 1, 6
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Definir `color_code(Color, Code)`, que asocie cada color de banda ("black" = 0, …, "white" = 9) con su valor, y `colors(Colors)`, con la lista de colores en orden.
- **Notas:** Una tabla de hechos que se consulta en ambas direcciones.

### EXM-reverse-string — Invertir una cadena
- **Fuente:** Exercism Prolog, `reverse-string`, d=1 (*easy*). https://exercism.org/tracks/prolog/exercises/reverse-string
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Escribir `string_reverse(S, Reversed)`, que invierta un *string*, por ejemplo "stressed" → "desserts".
- **Notas:** Obliga a pasar entre *string* y lista (`string_chars/2`).

### EXM-wedding-woes — Ubicar invitados en una mesa
- **Fuente:** Exercism Prolog, `wedding-woes`, d=1 (*easy*). https://exercism.org/tracks/prolog/exercises/wedding-woes
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Declarar hechos `chatty/1` y `likes/2`. Definir la regla `pairing/2`: dos personas combinan si se gustan mutuamente o si alguna es conversadora. Definir `seating/5`: una mesa redonda de cinco personas es buena si todos los pares vecinos combinan.
- **Notas:** Es el ejercicio del *track* más alineado con los temas 1 y 2: hechos, reglas con varias cláusulas (disyunción) y conjunciones.

### EXM-difference-of-squares — Diferencia de cuadrados
- **Fuente:** Exercism Prolog, `difference-of-squares`, d=2 (*easy*). https://exercism.org/tracks/prolog/exercises/difference-of-squares
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Para los primeros N naturales, calcular el cuadrado de la suma, la suma de los cuadrados y la diferencia entre ambos (`square_of_sum/2`, `sum_of_squares/2`, `difference/2`).

### EXM-gigasecond — Mil millones de segundos después
- **Fuente:** Exercism Prolog, `gigasecond`, d=2 (*easy*). https://exercism.org/tracks/prolog/exercises/gigasecond
- **Tema:** 7, X
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Dada una fecha y hora con la estructura `date/9` de SWI-Prolog, calcular el momento que cae 10^9 segundos después.
- **Notas:** Requiere conocer los predicados de fecha de SWI (`date_time_stamp/2`, `stamp_date_time/3`), que no son del programa del curso.

### EXM-leap — Año bisiesto
- **Fuente:** Exercism Prolog, `leap`, d=2 (*easy*). https://exercism.org/tracks/prolog/exercises/leap
- **Tema:** 2, 7
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Definir `leap(Year)`, verdadero si el año es bisiesto: divisible por 4, salvo los divisibles por 100 que no lo son por 400.
- **Notas:** Se puede resolver con varias cláusulas o con `;` y `mod`. Es buen ejemplo para comparar ambos estilos.

### EXM-resistor-color-duo — Valor de dos bandas
- **Fuente:** Exercism Prolog, `resistor-color-duo`, d=2 (*easy*). https://exercism.org/tracks/prolog/exercises/resistor-color-duo
- **Tema:** 1, 6, 7
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Dada una lista de colores, `value(Colors, Value)` devuelve el número de dos dígitos que forman las dos primeras bandas.

### EXM-rna-transcription — Transcripción de ADN a ARN
- **Fuente:** Exercism Prolog, `rna-transcription`, d=2 (*easy*). https://exercism.org/tracks/prolog/exercises/rna-transcription
- **Tema:** 1, 6
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Con `rna_transcription(Dna, Rna)`, reemplazar cada nucleótido por su complemento: G→C, C→G, T→A, A→U.
- **Notas:** Cuatro hechos más un recorrido de la lista, o `maplist/3`.

### EXM-scrabble-score — Puntaje de Scrabble
- **Fuente:** Exercism Prolog, `scrabble-score`, d=2 (*easy*). https://exercism.org/tracks/prolog/exercises/scrabble-score
- **Tema:** 1, 6, 7
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `score(Word, Score)` suma los valores de las letras de una palabra, según la tabla de puntajes del Scrabble y sin distinguir mayúsculas.

### EXM-darts — Dardos
- **Fuente:** Exercism Prolog, `darts`, d=3 (*easy*). https://exercism.org/tracks/prolog/exercises/darts
- **Tema:** 7
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `score(X, Y, Score)` da el puntaje de un dardo según la distancia al centro: 10 si está dentro del radio 1, 5 dentro del radio 5, 1 dentro del radio 10 y 0 fuera.

### EXM-grains — Granos en el tablero de ajedrez
- **Fuente:** Exercism Prolog, `grains`, d=3 (*easy*). https://exercism.org/tracks/prolog/exercises/grains
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Cada casilla tiene el doble de granos que la anterior. `square(N, Value)` da los granos de la casilla N, y `total(Value)` el total de las 64 casillas.
- **Notas:** Los enteros de SWI no desbordan, así que 2^64 − 1 se calcula sin problemas.

### EXM-hamming — Distancia de Hamming
- **Fuente:** Exercism Prolog, `hamming`, d=3 (*easy*). https://exercism.org/tracks/prolog/exercises/hamming
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `hamming_distance(Str1, Str2, Dist)` cuenta las posiciones en que difieren dos cadenas de ADN de igual largo, y falla si los largos son distintos.

### EXM-high-scores — Tabla de puntajes
- **Fuente:** Exercism Prolog, `high-scores`, d=3 (*easy*). https://exercism.org/tracks/prolog/exercises/high-scores
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Sobre una lista de puntajes, obtener el último (`latest/2`), el máximo (`personal_best/2`) y los tres mejores (`personal_top_three/2`).

### EXM-pangram — Pangrama
- **Fuente:** Exercism Prolog, `pangram`, d=3 (*easy*). https://exercism.org/tracks/prolog/exercises/pangram
- **Tema:** 6, 9
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `pangram(Sentence)` es verdadero si la frase contiene las 26 letras del alfabeto inglés, sin distinguir mayúsculas.
- **Notas:** Se resuelve de forma natural con `forall/2` o comparando conjuntos (`subtract/3`).

### EXM-space-age — Edad en otros planetas
- **Fuente:** Exercism Prolog, `space-age`, d=3 (*easy*). https://exercism.org/tracks/prolog/exercises/space-age
- **Tema:** 1, 7
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Dada una edad en segundos, `space_age(Planet, AgeSec, Years)` calcula la edad en años de ese planeta, usando una tabla de períodos orbitales.
- **Notas:** Tabla de hechos más aritmética de punto flotante.

### EXM-square-root — Raíz cuadrada entera
- **Fuente:** Exercism Prolog, `square-root`, d=3 (*easy*). https://exercism.org/tracks/prolog/exercises/square-root
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Calcular la raíz cuadrada de un cuadrado perfecto sin usar `sqrt`, por búsqueda lineal o binaria.

### EXM-triangle — Clasificar triángulos
- **Fuente:** Exercism Prolog, `triangle`, d=3 (*easy*). https://exercism.org/tracks/prolog/exercises/triangle
- **Tema:** 2, 7
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `triangle(A, B, C, Type)` decide si tres lados forman un triángulo válido (desigualdad triangular, lados positivos) y si es "equilateral", "isosceles" o "scalene".
- **Notas:** Un equilátero también es isósceles: `triangle(2,2,2,"isosceles")` debe ser verdadero. Es una lección sobre relaciones que no son funciones.

### EXM-two-fer — "Uno para vos, uno para mí"
- **Fuente:** Exercism Prolog, `two-fer`, d=3 (*easy*). https://exercism.org/tracks/prolog/exercises/two-fer
- **Tema:** 1
- **Dificultad:** 1
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Armar la frase "One for X, one for me.", con `two_fer/2` si se da el nombre y `two_fer/1` (con "you") si no.
- **Notas:** Muestra que `two_fer/1` y `two_fer/2` son predicados distintos: la aridad forma parte del nombre.

---

## Intermedios, parte 1 (Exercism *medium*, d=4)

### EXM-allergies — Alergias codificadas en bits
- **Fuente:** Exercism Prolog, `allergies`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/allergies
- **Tema:** 7, 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Cada alérgeno tiene un valor potencia de 2 (huevos 1, maní 2, …, gatos 128). Dado un puntaje, `allergic_to/2` dice si incluye un alérgeno y `allergies/2` devuelve la lista completa.
- **Notas:** `allergies/2` sale directo con `findall/3` sobre `allergic_to/2`.

### EXM-anagram — Anagramas
- **Fuente:** Exercism Prolog, `anagram`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/anagram
- **Tema:** 6, 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** De una lista de candidatas, `anagram(Word, Candidates, Anagrams)` se queda con las que son anagramas de la palabra, sin distinguir mayúsculas y sin contar la palabra misma.
- **Notas:** Se puede usar `msort/2` sobre las listas de caracteres y filtrar con `include/3`.

### EXM-armstrong-numbers — Números de Armstrong
- **Fuente:** Exercism Prolog, `armstrong-numbers`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/armstrong-numbers
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `armstrong_number(N)` es verdadero si N es igual a la suma de sus dígitos elevados a la cantidad de dígitos (por ejemplo, 153 = 1³ + 5³ + 3³).

### EXM-bank-account — Cuenta bancaria mutable
- **Fuente:** Exercism Prolog, `bank-account`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/bank-account
- **Tema:** 10, X
- **Dificultad:** 2
- **Solución:** sí (referencia, con `setarg/3`)
- **SWISH:** sí (`setarg/3` está permitido)
- **Enunciado:** Implementar una cuenta que se abre y se cierra, con depósitos y extracciones, fallando ante operaciones inválidas (cuenta cerrada, montos no positivos, saldo insuficiente).
- **Notas:** El apéndice del enunciado sugiere `setarg/3`, que es mutación destructiva y no es Prolog puro. Para el curso conviene rehacerlo con `assertz/retract` (tema 10) o pasando el estado nuevo como argumento.

### EXM-binary — Binario a decimal
- **Fuente:** Exercism Prolog, `binary`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/binary
- **Tema:** 5, 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `binary(Str, Dec)` convierte una cadena de ceros y unos a su valor decimal sin usar conversiones predefinidas, y falla ante entradas inválidas.
- **Notas:** Es un caso típico para un acumulador (esquema de Horner).

### EXM-binary-search — Búsqueda binaria
- **Fuente:** Exercism Prolog, `binary-search`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/binary-search
- **Tema:** 5, 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `find(List, Value, Index)` busca un valor en una lista ordenada partiendo el rango a la mitad y devuelve su índice, o falla si no está.
- **Notas:** Sobre listas enlazadas, el acceso por índice (`nth0/3`) es lineal. Sirve para discutir por qué la búsqueda binaria no rinde igual que sobre un arreglo.

### EXM-collatz-conjecture — Pasos de Collatz
- **Fuente:** Exercism Prolog, `collatz-conjecture`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/collatz-conjecture
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `collatz_steps(N, Steps)` cuenta cuántos pasos de Collatz hacen falta para llegar de N a 1, y falla si N no es positivo.
- **Notas:** Se complementa con POP-01.

### EXM-custom-set — Conjuntos propios
- **Fuente:** Exercism Prolog, `custom-set`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/custom-set
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Implementar un tipo conjunto con creación, pertenencia, subconjunto, disjunción, igualdad, agregado, diferencia, intersección y unión.
- **Notas:** Se puede elegir la representación (lista sin repetidos u ordenada); conviene discutir el costo de cada opción.

### EXM-eliuds-eggs — Contar bits en 1
- **Fuente:** Exercism Prolog, `eliuds-eggs`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/eliuds-eggs
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `egg_count(N, Count)` cuenta los bits en 1 de un número sin usar `popcount`.

### EXM-etl — Reestructurar datos (ETL)
- **Fuente:** Exercism Prolog, `etl`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/etl
- **Tema:** 6, 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Convertir una lista `Puntaje-[Letras]` (de uno a muchos) en una lista de pares `letra-Puntaje` con las letras en minúscula.
- **Notas:** Una transformación de datos de un solo paso. Se resuelve cómodo con `findall/3` y dos `member/2`.

### EXM-flatten-array — Aplanar listas anidadas
- **Fuente:** Exercism Prolog, `flatten-array`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/flatten-array
- **Tema:** 5, 6, 8
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `flatten_list(Xs, Flat)` aplana una lista anidada a cualquier profundidad, descartando los elementos `nil`.
- **Notas:** Hay que distinguir "es lista" de "no es lista": es el caso de representación *defaulty* que discute POP-09.

### EXM-global-positioning-system — Parsear coordenadas GPS
- **Fuente:** Exercism Prolog, `global-positioning-system`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/global-positioning-system
- **Tema:** A
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí (`library(dcg/basics)` está disponible)
- **Enunciado:** Con no terminales DCG (`comma`, `space`, hemisferios y grados en rango), reconocer y analizar coordenadas del tipo "12.5 N, 45.2 W".
- **Notas:** Es el ejercicio de DCG más accesible del *track*, porque va construyendo la gramática paso a paso.

### EXM-grade-school — Nómina de una escuela
- **Fuente:** Exercism Prolog, `grade-school`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/grade-school
- **Tema:** 6, 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Mantener una nómina inmutable de alumnos por grado: agregar alumnos (rechazando duplicados), listar un grado ordenado y listar la escuela completa ordenada por grado y nombre.
- **Notas:** Es una tabla relacional pequeña. Se puede proponer también la versión con hechos `student(Nombre, Grado)` y consultas (temas 10 y 11).

### EXM-isogram — Isograma
- **Fuente:** Exercism Prolog, `isogram`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/isogram
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `isogram(Phrase)` es verdadero si ninguna letra se repite, sin distinguir mayúsculas e ignorando espacios y guiones.

### EXM-matrix — Filas y columnas de una matriz
- **Fuente:** Exercism Prolog, `matrix`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/matrix
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** A partir de un *string* con filas separadas por saltos de línea, `row/3` y `column/3` devuelven una fila o una columna (numeradas desde 1).

### EXM-minesweeper — Buscaminas (obsoleto)
- **Fuente:** Exercism Prolog, `minesweeper`, d=4, **obsoleto** (reemplazado por `flower-field`). https://github.com/exercism/prolog/tree/main/exercises/practice/minesweeper
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Anotar un tablero de buscaminas con la cantidad de minas vecinas de cada celda vacía. Ver EXM-flower-field.

### EXM-nucleotide-count — Contar nucleótidos
- **Fuente:** Exercism Prolog, `nucleotide-count`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/nucleotide-count
- **Tema:** 6, 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `nucleotide_count(Dna, Counts)` cuenta cuántas A, C, G y T tiene una cadena de ADN y falla si aparece otro carácter.
- **Notas:** El archivo inicial viene vacío, así que el alumno elige el diseño a partir de los tests.

### EXM-perfect-numbers — Números perfectos, abundantes y deficientes
- **Fuente:** Exercism Prolog, `perfect-numbers`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/perfect-numbers
- **Tema:** 7, 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `classify(N, Class)` compara N con la suma de sus divisores propios y lo clasifica como "perfect", "abundant" o "deficient".

### EXM-proverb — Refrán encadenado
- **Fuente:** Exercism Prolog, `proverb`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/proverb
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** A partir de una lista de palabras, generar las líneas "For want of a X the Y was lost." para cada par consecutivo, más el cierre "And all for the want of a Primero."
- **Notas:** El patrón `[A, B | Resto]` resuelve el recorrido de a pares.

### EXM-raindrops — Gotas de lluvia
- **Fuente:** Exercism Prolog, `raindrops`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/raindrops
- **Tema:** 7, 8
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `convert(N, Sounds)` arma "Pling", "Plang" o "Plong" según N sea divisible por 3, 5 o 7 (concatenando los que correspondan), o devuelve el número como *string* si no es divisible por ninguno.
- **Notas:** El caso "ninguno" necesita negación o si-entonces-si-no.

### EXM-roman-numerals — De número a romano
- **Fuente:** Exercism Prolog, `roman-numerals`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/roman-numerals
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `convert(N, Numeral)` convierte un número de 1 a 3999 a números romanos.
- **Notas:** Es la dirección inversa de END-3.16. Una tabla de hechos con los pares valor-símbolo, incluidos los sustractivos (900-CM, 4-IV), simplifica mucho la solución.

### EXM-rotational-cipher — Cifrado César
- **Fuente:** Exercism Prolog, `rotational-cipher`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/rotational-cipher
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `rotate(Text, Key, Cipher)` desplaza cada letra `Key` posiciones en el alfabeto, respetando mayúsculas y minúsculas y dejando igual lo que no es letra.

### EXM-series — Subcadenas consecutivas
- **Fuente:** Exercism Prolog, `series`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/series
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `slices(Input, Size, Slices)` lista todas las subcadenas contiguas de largo `Size` de una cadena de dígitos, en orden.
- **Notas:** `append/3` usado para descomponer (`append(_, S, Pre), append(Pre, _, L)`) resuelve la parte difícil.

### EXM-strain — `keep` y `discard`
- **Fuente:** Exercism Prolog, `strain`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/strain
- **Tema:** 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Implementar `keep(Goal, List, Kept)` y `discard(Goal, List, Discarded)`, que filtran según un predicado pasado como argumento, sin usar `include/3` ni `exclude/3`.
- **Notas:** Es la introducción natural a `call/N` y a los predicados de orden superior.

### EXM-sublist — Relación de sublista
- **Fuente:** Exercism Prolog, `sublist`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/sublist
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `sublist(A, B, Rel)` clasifica dos listas como `equal`, `sublist`, `superlist` o `unequal`, donde "sublista" quiere decir segmento contiguo.
- **Notas:** El orden de las cláusulas importa: dos listas iguales también son sublistas una de otra, así que hay que cortar o excluir casos.

### EXM-sum-of-multiples — Suma de múltiplos
- **Fuente:** Exercism Prolog, `sum-of-multiples`, d=4 (*medium*). https://exercism.org/tracks/prolog/exercises/sum-of-multiples
- **Tema:** 7, 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `sum_of_multiples(Factors, Limit, Sum)` suma los números menores que `Limit` que son múltiplos de al menos un factor, contando cada número una sola vez.
- **Notas:** Con `setof/3` o `sort/2` se eliminan los repetidos. Cuidado con el factor 0.

---

## Intermedios, parte 2 (Exercism *medium*, d=5)

### EXM-acronym — Acrónimos
- **Fuente:** Exercism Prolog, `acronym`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/acronym
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `abbreviate(Phrase, Acronym)` forma el acrónimo en mayúsculas con la primera letra de cada palabra, tratando los guiones como separadores e ignorando el resto de la puntuación.

### EXM-binary-search-tree — Árbol binario de búsqueda
- **Fuente:** Exercism Prolog, `binary-search-tree`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/binary-search-tree
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Con árboles `tree_node(Valor, Izq, Der)` o `nil`, `from_data/2` inserta una lista de números (los iguales van a la izquierda) y `to_data/2` devuelve los valores ordenados.
- **Notas:** Es un buen ejercicio de términos compuestos como estructura de datos recursiva.

### EXM-bob — Las respuestas de Bob
- **Fuente:** Exercism Prolog, `bob`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/bob
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `hey(Sentence, Response)` elige una de cinco respuestas según la frase sea una pregunta, un grito (todo en mayúsculas), un grito en forma de pregunta, silencio o cualquier otra cosa.
- **Notas:** Los casos se solapan (grito y pregunta a la vez), así que el orden de las cláusulas y la exclusión mutua son lo central del ejercicio.

### EXM-bottle-song — "Ten Green Bottles"
- **Fuente:** Exercism Prolog, `bottle-song`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/bottle-song
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Generar las estrofas de la canción desde un número inicial, con los números en palabras y el singular o plural correctos.

### EXM-clock — Reloj sin fecha
- **Fuente:** Exercism Prolog, `clock`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/clock
- **Tema:** 3, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Crear relojes normalizados (horas y minutos, incluso con valores negativos o que se pasan de rango), sumar y restar minutos y mostrarlos como "HH:MM".
- **Notas:** Normalizar con `mod` hace que dos relojes equivalentes unifiquen, es decir, sean el mismo término.

### EXM-complex-numbers — Números complejos
- **Fuente:** Exercism Prolog, `complex-numbers`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/complex-numbers
- **Tema:** 3, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Con complejos representados como pares `(Re, Im)`, implementar parte real e imaginaria, conjugado, módulo, suma, resta, producto y cociente.

### EXM-dnd-character — Personaje de D&D
- **Fuente:** Exercism Prolog, `dnd-character`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/dnd-character
- **Tema:** 7, X
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Calcular el modificador de una habilidad, generar un puntaje tirando 4 dados y sumando los 3 mayores, y crear un personaje con seis habilidades y sus puntos de vida.
- **Notas:** Usa números aleatorios (`random_between/3`), que no son declarativos.

### EXM-house — "La casa que construyó Jack"
- **Fuente:** Exercism Prolog, `house`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/house
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Recitar las estrofas acumulativas de la canción infantil, de una en una o en un rango.
- **Notas:** La estructura acumulativa lleva naturalmente a una solución recursiva sobre una lista de frases.

### EXM-isbn-verifier — Validar un ISBN-10
- **Fuente:** Exercism Prolog, `isbn-verifier`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/isbn-verifier
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `isbn(S)` es verdadero si la cadena, con o sin guiones, es un ISBN-10 válido: 9 dígitos más un dígito o `X` de control, y suma ponderada congruente con 0 módulo 11.

### EXM-kindergarten-garden — El jardín de infantes
- **Fuente:** Exercism Prolog, `kindergarten-garden`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/kindergarten-garden
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** A partir de un diagrama de dos filas de letras (G, C, R, V), `garden(Diagram, Child, Plants)` devuelve las cuatro plantas que le tocan a cada uno de los 12 chicos, asignados en orden alfabético.

### EXM-largest-series-product — Mayor producto de una serie
- **Fuente:** Exercism Prolog, `largest-series-product`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/largest-series-product
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Dada una cadena de dígitos y un largo, `largest_product/3` devuelve el mayor producto entre todas las subsecuencias contiguas de ese largo, y falla ante entradas inválidas.

### EXM-list-ops — Operaciones básicas sobre listas
- **Fuente:** Exercism Prolog, `list-ops`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/list-ops
- **Tema:** 5, 6, 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Reimplementar sin predicados de biblioteca: largo, concatenación, concatenación de una lista de listas, inversión, `map`, `filter` y `foldl`.
  ```prolog
  custom_length(List, Length).
  custom_map(Goal, List, Mapped).
  custom_foldl(Goal, State, List, Folded).
  ```
- **Notas:** Es un resumen muy completo de los temas 5, 6 y 9. Muy recomendable.

### EXM-luhn — Algoritmo de Luhn
- **Fuente:** Exercism Prolog, `luhn`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/luhn
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `valid(S)` decide si una cadena de dígitos (con espacios permitidos) pasa el control de Luhn: duplicar uno de cada dos dígitos desde la derecha y comprobar la suma módulo 10.

### EXM-phone-number — Normalizar teléfonos
- **Fuente:** Exercism Prolog, `phone-number`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/phone-number
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `cleanup(Input, Cleaned)` extrae los 10 dígitos de un teléfono norteamericano (NANP), quitando puntuación y el prefijo 1, y falla o lanza un error ante números inválidos.
- **Notas:** Los tests esperan excepciones con mensajes concretos: es un buen primer contacto con `throw/1`.

### EXM-prime-factors — Factores primos
- **Fuente:** Exercism Prolog, `prime-factors`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/prime-factors
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `factors(N, Factors)` devuelve la lista de factores primos de N con repetición, en orden creciente.
- **Notas:** Es la versión sin exponentes de END-5.6.

### EXM-protein-translation — Traducir ARN a proteínas
- **Fuente:** Exercism Prolog, `protein-translation`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/protein-translation
- **Tema:** 1, 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Partir una cadena de ARN en codones de tres letras y traducirlos a aminoácidos con una tabla, cortando en el primer codón STOP.
- **Notas:** Una tabla de hechos `codon/2` más un recorrido de tres en tres.

### EXM-queen-attack — Ataque de reinas
- **Fuente:** Exercism Prolog, `queen-attack`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/queen-attack
- **Tema:** 3, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `create/1` valida una posición `(Fila, Col)` del tablero de 8×8, y `attack/2` decide si dos reinas se atacan: misma fila, misma columna o misma diagonal.

### EXM-rational-numbers — Números racionales
- **Fuente:** Exercism Prolog, `rational-numbers`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/rational-numbers
- **Tema:** 3, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Representar racionales como `rational(N, D)` reducidos a su mínima expresión e implementar suma, resta, producto, cociente, valor absoluto y potencias.

### EXM-robot-name — Nombres aleatorios de robots
- **Fuente:** Exercism Prolog, `robot-name`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/robot-name
- **Tema:** 10, X
- **Dificultad:** 2
- **Solución:** sí (referencia, con `setarg/3` y `random_member/2`)
- **SWISH:** sí
- **Enunciado:** Crear robots con un nombre aleatorio de la forma "AB123" y permitir reiniciarlos para que reciban uno nuevo.
- **Notas:** Requiere estado mutable. Para el curso es más formativo resolverlo con `assertz/retract`, llevando además la cuenta de los nombres ya usados para no repetirlos.

### EXM-robot-simulator — Simulador de robot
- **Fuente:** Exercism Prolog, `robot-simulator`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/robot-simulator
- **Tema:** 3, 5, 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Un robot en una grilla infinita recibe una cadena de instrucciones (R, L, A: girar a la derecha, a la izquierda, avanzar). `move/3` devuelve su posición y orientación finales.
- **Notas:** Es casi el mismo problema que END-3.10.

### EXM-secret-handshake — Saludo secreto
- **Fuente:** Exercism Prolog, `secret-handshake`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/secret-handshake
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Convertir un número de 1 a 31 en una lista de acciones según sus bits (wink, double blink, close your eyes, jump); el quinto bit invierte el orden.

### EXM-sieve — Criba de Eratóstenes
- **Fuente:** Exercism Prolog, `sieve`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/sieve
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `primes(Limit, Primes)` genera los primos hasta un límite con la criba de Eratóstenes, sin usar divisiones de prueba.
- **Notas:** Sobre listas, la criba se expresa como un filtrado recursivo de múltiplos.

### EXM-simple-cipher — Cifrado de Vigenère
- **Fuente:** Exercism Prolog, `simple-cipher`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/simple-cipher
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `encode/3` y `decode/3` cifran y descifran con una clave de letras minúsculas: cada letra se desplaza según la letra correspondiente de la clave, que se repite si hace falta.

### EXM-state-of-tic-tac-toe — Estado de un tatetí
- **Fuente:** Exercism Prolog, `state-of-tic-tac-toe`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/state-of-tic-tac-toe
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Dado un tablero de 3×3 como lista de tres cadenas, `state/2` decide si el juego está en curso (`ongoing`), terminó en empate (`draw`) o alguien ganó (`win`), y falla si el tablero es imposible (turnos incorrectos, dos ganadores).
- **Notas:** Las ocho líneas ganadoras se escriben cómodamente como hechos de patrones de posiciones.

### EXM-twelve-days — "Los doce días de Navidad"
- **Fuente:** Exercism Prolog, `twelve-days`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/twelve-days
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Recitar las estrofas acumulativas del villancico, de una en una o en un rango.

### EXM-yacht — Yacht (juego de dados)
- **Fuente:** Exercism Prolog, `yacht`, d=5 (*medium*). https://exercism.org/tracks/prolog/exercises/yacht
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `score(Dice, Category, Score)` calcula el puntaje de cinco dados en una categoría: unos a seises, full house, póker, escaleras, *choice* o *yacht*.
- **Notas:** Con `msort/2` y patrones de lista, varias categorías se resuelven solo por unificación.

---

## Intermedios, parte 3 (Exercism *medium*, d=6)

### EXM-all-your-base — Cambio de base
- **Fuente:** Exercism Prolog, `all-your-base`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/all-your-base
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `rebase(InBase, InDigits, OutBase, OutDigits)` convierte una lista de dígitos de una base a otra, validando las bases y los dígitos.

### EXM-atbash-cipher — Cifrado Atbash
- **Fuente:** Exercism Prolog, `atbash-cipher`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/atbash-cipher
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Cifrar y descifrar reemplazando cada letra por su simétrica en el alfabeto (a↔z, b↔y…), conservando los dígitos y agrupando la salida en bloques de 5.

### EXM-game-of-life — Juego de la vida de Conway
- **Fuente:** Exercism Prolog, `game-of-life`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/game-of-life
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Dada una matriz de 0 y 1, `tick(Current, Next)` calcula la generación siguiente según las reglas de Conway: una celda viva con 2 o 3 vecinas sigue viva, y una muerta con exactamente 3 vecinas nace.

### EXM-dominoes — Cadena de dominós
- **Fuente:** Exercism Prolog, `dominoes`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/dominoes
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `can_chain(Pieces)` decide si las fichas se pueden ordenar, girándolas si hace falta, en una cadena cerrada donde las mitades vecinas coinciden y los extremos también.
- **Notas:** Se resuelve con `select/3` y backtracking: es un ejemplo claro de búsqueda del tema 4.

### EXM-floored — ¿Quién vive en qué piso?
- **Fuente:** Exercism Prolog, `floored`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/floored
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** sí (referencia, con CLP(FD))
- **SWISH:** sí
- **Enunciado:** Cinco inquilinos viven en cinco pisos distintos y hay pistas como "Cora no vive arriba ni abajo" o "Dale vive más arriba que Björn". `floor(Name, Floor)` debe dar el piso de cada uno.
- **Notas:** Es un puzzle chico, ideal para "generar y comprobar" con `permutation/2` sin CLP.

### EXM-food-chain — "I Know an Old Lady Who Swallowed a Fly"
- **Fuente:** Exercism Prolog, `food-chain`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/food-chain
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Generar la canción acumulativa de forma algorítmica, entre dos estrofas dadas.

### EXM-killer-sudoku-helper — Combinaciones de una jaula de Killer Sudoku
- **Fuente:** Exercism Prolog, `killer-sudoku-helper`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/killer-sudoku-helper
- **Tema:** 4, 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `combinations(Size, Sum, Exclude, Combos)` lista, ordenadas, todas las combinaciones de `Size` dígitos distintos del 1 al 9 que suman `Sum` y no usan los dígitos excluidos.
- **Notas:** Se genera con backtracking y se recolecta con `findall/3`.

### EXM-magic-square — Cuadrado mágico
- **Fuente:** Exercism Prolog, `magic-square`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/magic-square
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `magic_square(Rows)` decide si en una matriz cuadrada todas las filas, columnas y las dos diagonales suman lo mismo.
- **Notas:** La solución de referencia con CLP(FD) además completa cuadrados parciales.

### EXM-matching-brackets — Paréntesis balanceados
- **Fuente:** Exercism Prolog, `matching-brackets`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/matching-brackets
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `paired(S)` es verdadero si los `()`, `[]` y `{}` de la cadena están bien anidados; el resto de los caracteres se ignora.
- **Notas:** Se resuelve con una pila representada como lista. También admite una solución elegante con DCG.

### EXM-meetup — Fecha de una reunión
- **Fuente:** Exercism Prolog, `meetup`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/meetup
- **Tema:** 7, X
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Encontrar la fecha de, por ejemplo, "el primer lunes de marzo de 2013" o "el *teenth* miércoles", es decir, el que cae entre el 13 y el 19.
- **Notas:** Depende de los predicados de fechas de SWI (`day_of_the_week/2`).

### EXM-nth-prime — n-ésimo primo
- **Fuente:** Exercism Prolog, `nth-prime`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/nth-prime
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `nth_prime(N, P)` devuelve el n-ésimo primo sin usar bibliotecas de primos.

### EXM-ocr-numbers — OCR de dígitos
- **Fuente:** Exercism Prolog, `ocr-numbers`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/ocr-numbers
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Reconocer dígitos dibujados con `_`, `|` y espacios en celdas de 3×4 y devolver la cadena de dígitos, con `?` para los desconocidos y comas entre las líneas.

### EXM-palindrome-products — Productos palíndromos
- **Fuente:** Exercism Prolog, `palindrome-products`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/palindrome-products
- **Tema:** 4, 7, 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** En un rango de factores, encontrar el menor y el mayor producto que sea palíndromo, junto con todos los pares de factores que lo generan.

### EXM-parallel-letter-frequency — Frecuencia de letras en paralelo
- **Fuente:** Exercism Prolog, `parallel-letter-frequency`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/parallel-letter-frequency
- **Tema:** X
- **Dificultad:** 2
- **Solución:** sí (referencia, con `concurrent_maplist/3`)
- **SWISH:** no (SWISH no permite crear hilos; hay que usar `swipl` local)
- **Enunciado:** Contar la frecuencia de cada letra en una lista de textos, repartiendo el trabajo en paralelo.

### EXM-pascals-triangle — Triángulo de Pascal
- **Fuente:** Exercism Prolog, `pascals-triangle`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/pascals-triangle
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `pascal(N, Rows)` genera las primeras N filas del triángulo de Pascal.
- **Notas:** Cada fila se obtiene de la anterior sumando pares vecinos: recursión con la fila previa como estado.

### EXM-pythagorean-triplet — Ternas pitagóricas
- **Fuente:** Exercism Prolog, `pythagorean-triplet`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/pythagorean-triplet
- **Tema:** 4, 7, 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `triplets(N, Ts)` encuentra todas las ternas a < b < c con a² + b² = c² y a + b + c = N.
- **Notas:** Es "generar y comprobar" con `between/3`. Para N grande hay que acotar bien los rangos.

### EXM-resistor-color-trio — Valor de tres bandas
- **Fuente:** Exercism Prolog, `resistor-color-trio`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/resistor-color-trio
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Con tres bandas (dos dígitos y un multiplicador), `label/2` devuelve la resistencia como texto con unidad: ohms, kiloohms, megaohms o gigaohms.

### EXM-saddle-points — Puntos de silla
- **Fuente:** Exercism Prolog, `saddle-points`, d=6 (*medium*). https://exercism.org/tracks/prolog/exercises/saddle-points
- **Tema:** 6, 9
- **Dificultad:** 2
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** En una matriz de alturas, encontrar las posiciones que son máximas en su fila y mínimas en su columna.
- **Notas:** Con `nth1/3`, `findall/3` y `forall/2` sale una solución casi declarativa.

---

## Intermedios, parte 4 (Exercism *medium*, d=7)

### EXM-affine-cipher — Cifrado afín
- **Fuente:** Exercism Prolog, `affine-cipher`, d=7 (*medium*). https://exercism.org/tracks/prolog/exercises/affine-cipher
- **Tema:** 6, 7
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Cifrar con E(x) = (a·x + b) mod 26 y descifrar usando el inverso multiplicativo de a, fallando si a y 26 no son coprimos.

### EXM-binary-puzzle — Puzzle binario
- **Fuente:** Exercism Prolog, `binary-puzzle`, d=7 (*medium*). https://exercism.org/tracks/prolog/exercises/binary-puzzle
- **Tema:** X
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí (con `library(clpfd)`)
- **Enunciado:** Completar una grilla de 0 y 1 respetando que no haya tres iguales seguidos, que cada fila y columna tenga tantos ceros como unos y que no haya filas ni columnas repetidas.
- **Notas:** El enunciado exige usar CLP(FD), que está fuera del alcance del curso.

### EXM-cheryls-birthday — El cumpleaños de Cheryl
- **Fuente:** Exercism Prolog, `cheryls-birthday`, d=7 (*medium*). https://exercism.org/tracks/prolog/exercises/cheryls-birthday
- **Tema:** 4, 9
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Hay 10 fechas posibles y tres afirmaciones de Albert y Bernard sobre lo que saben y lo que no. Deducir el cumpleaños de Cheryl.
- **Notas:** Es un puzzle de conocimiento: "saber" se modela contando soluciones con `findall/3` o `aggregate_all/3`, y "no saber" con negación.

### EXM-crypto-square — Cifrado del cuadrado
- **Fuente:** Exercism Prolog, `crypto-square`, d=7 (*medium*). https://exercism.org/tracks/prolog/exercises/crypto-square
- **Tema:** 6
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Normalizar el texto, acomodarlo en un rectángulo casi cuadrado y leerlo por columnas, rellenando con espacios.

### EXM-diamond — Diamante de letras
- **Fuente:** Exercism Prolog, `diamond`, d=7 (*medium*). https://exercism.org/tracks/prolog/exercises/diamond
- **Tema:** 6
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Dada una letra, `diamond(Letter, Rows)` construye el diamante que va de 'A' hasta esa letra y vuelve, con la simetría y los espacios exactos.

### EXM-flower-field — Campo de flores
- **Fuente:** Exercism Prolog, `flower-field`, d=7 (*medium*). https://exercism.org/tracks/prolog/exercises/flower-field
- **Tema:** 6
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** En un tablero de flores (`*`) y espacios, reemplazar cada espacio por la cantidad de flores vecinas, contando las diagonales, y dejarlo en blanco si no tiene ninguna.

### EXM-garden-party — Fiesta en el jardín
- **Fuente:** Exercism Prolog, `garden-party`, d=7 (*medium*). https://exercism.org/tracks/prolog/exercises/garden-party
- **Tema:** 4
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Con seis pistas sobre qué plato cocinó y qué bebida llevó cada uno de cuatro chefs, deducir las asignaciones y exponerlas con `dish/2` y `beverage/2`.
- **Notas:** Es un puzzle lógico pequeño, adecuado para "generar y comprobar" con permutaciones.

### EXM-knapsack — Problema de la mochila
- **Fuente:** Exercism Prolog, `knapsack`, d=7 (*medium*). https://exercism.org/tracks/prolog/exercises/knapsack
- **Tema:** 4, 7, 9
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Elegir un subconjunto de objetos con peso y valor que no supere la capacidad y maximice el valor total.
- **Notas:** Se puede resolver por fuerza bruta con subconjuntos y el máximo, o con programación dinámica (*tabling*).

### EXM-satellite — Reconstruir un árbol a partir de sus recorridos
- **Fuente:** Exercism Prolog, `satellite`, d=7 (*medium*). https://exercism.org/tracks/prolog/exercises/satellite
- **Tema:** 3, 6, A
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Relacionar un árbol binario sin elementos repetidos con sus recorridos en preorden y en orden simétrico, de modo que se pueda reconstruir a partir de ellos.
- **Notas:** El apéndice del enunciado pide resolverlo con DCG (se relaciona con POP-13).

### EXM-word-count — Contar palabras
- **Fuente:** Exercism Prolog, `word-count`, d=7 (*medium*). https://exercism.org/tracks/prolog/exercises/word-count
- **Tema:** 6, 9
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Contar cuántas veces aparece cada palabra en una frase, sin distinguir mayúsculas, conservando las contracciones con apóstrofo y separando por cualquier signo de puntuación.

### EXM-wordy — Problemas aritméticos en palabras
- **Fuente:** Exercism Prolog, `wordy`, d=7 (*medium*). https://exercism.org/tracks/prolog/exercises/wordy
- **Tema:** A, 7
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Analizar y evaluar preguntas como "What is 5 plus 13 multiplied by 2?", de izquierda a derecha y sin precedencia, fallando ante preguntas mal formadas u operaciones desconocidas.
- **Notas:** Es un caso de uso natural de las DCG.

---

## Difíciles (Exercism *hard*, d=8–9)

### EXM-book-store — Descuentos en una librería
- **Fuente:** Exercism Prolog, `book-store`, d=8 (*hard*). https://exercism.org/tracks/prolog/exercises/book-store
- **Tema:** 4, 7
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Cada libro de una serie de 5 cuesta $8, y los grupos de títulos distintos tienen descuento (5 %, 10 %, 20 %, 25 %). `total(Basket, Price)` calcula el precio mínimo agrupando la canasta de la mejor manera.
- **Notas:** Agrupar siempre en el grupo más grande no da el óptimo: hay que explorar agrupaciones con backtracking y quedarse con el mínimo.

### EXM-change — Cambio con la menor cantidad de monedas
- **Fuente:** Exercism Prolog, `change`, d=8 (*hard*). https://exercism.org/tracks/prolog/exercises/change
- **Tema:** 4, 7
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `fewest_coins(Coins, Target, Change)` devuelve la combinación con menos monedas que suma exactamente `Target`, y falla si no hay ninguna.
- **Notas:** El algoritmo goloso no alcanza. Se resuelve con profundización iterativa sobre la cantidad de monedas (`length/2`) o con programación dinámica.

### EXM-pig-latin — Pig Latin
- **Fuente:** Exercism Prolog, `pig-latin`, d=8 (*hard*). https://exercism.org/tracks/prolog/exercises/pig-latin
- **Tema:** 6, A
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Traducir frases a Pig Latin según cuatro reglas sobre las vocales y consonantes iniciales, con casos especiales para "xr", "yt", "qu" e "y".
- **Notas:** Con `append/3` para partir la palabra, o con una DCG, las reglas quedan casi textuales.

### EXM-run-length-encoding — Codificación por longitud de corrida
- **Fuente:** Exercism Prolog, `run-length-encoding`, d=8 (*hard*). https://exercism.org/tracks/prolog/exercises/run-length-encoding
- **Tema:** 6, A
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `encode/2` comprime las corridas de caracteres iguales ("WWWB" → "3WB") y `decode/2` las expande.
- **Notas:** Una sola relación bien escrita puede servir para ambas direcciones. Es un buen desafío de reversibilidad.

### EXM-say — Números en palabras (inglés)
- **Fuente:** Exercism Prolog, `say`, d=8 (*hard*). https://exercism.org/tracks/prolog/exercises/say
- **Tema:** 5, 7
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `say(N, English)` escribe en palabras en inglés un número de 0 a 999.999.999.999 ("one hundred twenty-three").
- **Notas:** Se descompone recursivamente en grupos de tres cifras.

### EXM-sgf-parsing — Parsear el formato SGF
- **Fuente:** Exercism Prolog, `sgf-parsing`, d=8 (*hard*). https://exercism.org/tracks/prolog/exercises/sgf-parsing
- **Tema:** A
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `parse(Input, Tree)` analiza una cadena en *Smart Game Format* (partidas de go) y construye el árbol de nodos con sus propiedades, fallando ante entradas mal formadas.
- **Notas:** Es un parser completo con DCG y manejo de escapes.

### EXM-spiral-matrix — Matriz espiral
- **Fuente:** Exercism Prolog, `spiral-matrix`, d=8 (*hard*). https://exercism.org/tracks/prolog/exercises/spiral-matrix
- **Tema:** 6
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** `spiral(N, Matrix)` construye la matriz N×N con los números 1 a N² dispuestos en espiral en el sentido de las agujas del reloj, desde la esquina superior izquierda.

### EXM-two-bucket — Dos baldes
- **Fuente:** Exercism Prolog, `two-bucket`, d=8 (*hard*). https://exercism.org/tracks/prolog/exercises/two-bucket
- **Tema:** 4
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Con dos baldes de capacidades dadas y uno que se llena primero, `measure/5` encuentra la menor cantidad de acciones (llenar, vaciar, trasvasar) para medir exactamente la cantidad objetivo.
- **Notas:** Es búsqueda en un espacio de estados. Se relaciona con POP-21 y con UNI-CAM-13.3.

### EXM-zebra-puzzle — El acertijo de la cebra
- **Fuente:** Exercism Prolog, `zebra-puzzle`, d=8 (*hard*). https://exercism.org/tracks/prolog/exercises/zebra-puzzle
- **Tema:** 4
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí
- **Enunciado:** Con las 15 pistas clásicas, `water_drinker/1` debe dar quién bebe agua y `zebra_owner/1` quién tiene la cebra.
- **Notas:** Ver también POP-20 (versión con CLP(FD)) y UNI-CAM-2.1.

### EXM-alphametics — Alfamética general
- **Fuente:** Exercism Prolog, `alphametics`, d=9 (*hard*). https://exercism.org/tracks/prolog/exercises/alphametics
- **Tema:** 4, X
- **Dificultad:** 3
- **Solución:** sí (referencia)
- **SWISH:** sí (con `library(clpfd)`)
- **Enunciado:** `solve(Equation, Solution)` resuelve cualquier criptoaritmética dada como *string* ("SEND + MORE == MONEY"): asigna dígitos distintos a las letras, sin ceros al comienzo de las palabras.
- **Notas:** Combina parseo de la ecuación con búsqueda o restricciones. Es el ejercicio más difícil del *track*.
