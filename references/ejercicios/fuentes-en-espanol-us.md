# Fuentes en español: Universidad de Sevilla (José A. Alonso)

Parte del banco [fuentes-en-espanol.md](fuentes-en-espanol.md).

Documento: José A. Alonso Jiménez, *Ejercicios de programación declarativa con Prolog*,
Grupo de Lógica Computacional, Dpto. de Ciencias de la Computación e Inteligencia
Artificial, Universidad de Sevilla, versión del 7 de noviembre de 2006, 110 ejercicios.
URL: https://www.cs.us.es/~jalonso/publicaciones/2006-ej_prog_declarativa.pdf
Licencia: Creative Commons Reconocimiento–NoComercial–CompartirIgual 2.5 España
(CC BY-NC-SA 2.5 ES).

Todos los ejercicios traen solución en el mismo documento, inmediatamente después del
enunciado. Por eso el campo **Solución** dice "en el documento" y, cuando se ejecutó
una solución propia equivalente, "verificada".

Advertencias generales sobre el documento:

- Usa nombres de predicado con tildes (`último/2`, `palíndromo/1`, `permutación/2`).
  SWI-Prolog 9.2.9 en Windows lee los archivos fuente con la codificación del sistema
  (flag `encoding` = `text`), no en UTF-8. Un archivo UTF-8 con `último(X,[X]).` se lee
  como la variable `Ãºltimo` y da error de sintaxis. Hay que agregar `:- encoding(utf8).`
  al principio del archivo o quitar las tildes. En SWISH no pasa, porque el editor ya
  trabaja en UTF-8.
- Las respuestas de ejemplo muestran el formato de SWI-Prolog 5 (`Yes`/`No`). SWI
  9 responde `true`/`false`.
- Algunos ejercicios usan predicados de SWI antiguos: `sumlist/2` (hoy `sum_list/2`,
  aunque `sumlist` sigue disponible) y `not/1` (hoy se prefiere `\+`).
- La extracción de texto del PDF pierde la letra "c" en algunas fuentes tipográficas
  (`on ` por `conc`). Hay que leer el PDF, no el texto extraído.

## Capítulo 1. Operaciones con listas

### ES-US-1 — primero, resto y cons
- **Fuente:** Alonso, *Ejercicios de programación declarativa con Prolog*, cap. 1, ejercicios 1.1 a 1.3. https://www.cs.us.es/~jalonso/publicaciones/2006-ej_prog_declarativa.pdf
- **Tema:** 3, 6
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `primero(?L,?X)`, `resto(?L1,?L2)` y `cons(?X,?L1,?L2)` con una sola cláusula cada uno, y responder consultas en todos los modos, como `primero(X,a)` o `cons(X,L,[a,b,c])`.
- **Notas:** Muestra que un hecho con el patrón `[X|_]` basta para "acceder" a una lista, y que las respuestas pueden contener variables libres.

### ES-US-2 — pertenece (member)
- **Fuente:** ídem, ejercicio 1.4.
- **Tema:** 5, 6, 4
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `pertenece(?X,?L)` y usarlo para averiguar si un elemento está en una lista, cuáles son los elementos de `[a,b,a]` y cuáles son los elementos comunes de dos listas.

### ES-US-3 — concatenación (append)
- **Fuente:** ídem, ejercicio 1.5.
- **Tema:** 5, 6, 4
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `conc(?L1,?L2,?L3)` y usarlo en distintos modos: qué hay que agregarle a `[a,b]` para obtener `[a,b,c,d]`, qué pares de listas concatenadas dan `[a,b]`, si `b` pertenece a una lista, si una lista es sublista de otra.
- **Notas:** El ejercicio central para mostrar la inversibilidad de un predicado recursivo.

### ES-US-4 — Lista inversa y palíndromo
- **Fuente:** ídem, ejercicios 1.6 y 1.7.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** en el documento (inversa con `conc` y con acumulador)
- **SWISH:** sí
- **Enunciado:** Definir `inversa(+L1,-L2)` y `palíndromo(+L)`, que se verifica si la lista se lee igual al derecho y al revés.

### ES-US-5 — Último y penúltimo elemento
- **Fuente:** ídem, ejercicios 1.8 y 1.9.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** en el documento; `último/2` verificado (`último(a,L)` genera `[a]`, `[_,a]`, `[_,_,a]`, …)
- **SWISH:** sí
- **Enunciado:** Definir `último(?X,?L)` y `penúltimo(?X,?L)`, que también funcionen para generar listas.

### ES-US-6 — Seleccionar e insertar un elemento
- **Fuente:** ídem, ejercicios 1.10 y 1.11.
- **Tema:** 4, 5, 6
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `selecciona(?X,?L1,?L2)` (L2 es L1 sin una ocurrencia de X) e `inserta(?X,?L1,?L2)` (L2 resulta de insertar X en alguna posición de L1), observando todas las respuestas por backtracking.
- **Notas:** `inserta` se define a partir de `selecciona` invirtiendo los argumentos.

### ES-US-7 — Sublista
- **Fuente:** ídem, ejercicio 1.12.
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** en el documento; verificada una versión con `append/3` (`sublista([b,c],[a,b,c,d])` sí, `sublista([a,c],[a,b,c,d])` no)
- **SWISH:** sí
- **Enunciado:** Definir `sublista(?L1,?L2)`: L1 es un tramo contiguo de L2.

### ES-US-8 — Permutación
- **Fuente:** ídem, ejercicio 1.13.
- **Tema:** 4, 5, 6
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `permutación(+L1,?L2)` y obtener por backtracking las seis permutaciones de `[a,b,c]`.
- **Notas:** El modo es `+L1`: con el primer argumento libre la búsqueda puede no terminar después de dar las respuestas.

### ES-US-9 — Todos iguales y longitud par
- **Fuente:** ídem, ejercicios 1.14 y 1.15.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `todos_iguales(+L)` (verdadero para `[]`) y `longitud_par(+L)` sin usar aritmética (con recursión mutua `longitud_par`/`longitud_impar`).

### ES-US-10 — Rotación y subconjunto
- **Fuente:** ídem, ejercicios 1.16 y 1.17.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `rota(?L1,?L2)` (pasa el primer elemento al final; usable en ambos sentidos) y `subconjunto(+L1,?L2)`, que genera todos los subconjuntos manteniendo el orden.

## Capítulo 2. Aritmética

### ES-US-11 — Máximo, factorial, Fibonacci, MCD
- **Fuente:** ídem, cap. 2, ejercicios 2.1 a 2.4.
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** en el documento; factorial y MCD verificados (`factorial(3,6)`, `mcd(10,15,5)`)
- **SWISH:** sí
- **Enunciado:** Definir `máximo(+X,+Y,?Z)`, `factorial(+X,?Y)`, `fibonacci(+N,-X)` (sucesión 0, 1, 1, 2, … y `fibonacci(6,8)`) y `mcd(+X,+Y,?Z)` por el algoritmo de Euclides.
- **Notas:** El Fibonacci de Alonso empieza en 0; el de la guía UTN (ES-UTN-23), en 1. Los modos `+`/`-` documentan qué argumentos deben venir ligados.

### ES-US-12 — Longitud y lista acotada
- **Fuente:** ídem, ejercicios 2.5 y 2.6.
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `longitud(?L,?N)` (también `longitud(L,3)` genera `[X,Y,Z]`) y `lista_acotada(+L)`: todos sus elementos son menores que su longitud.

### ES-US-13 — Máximo, suma y orden de una lista
- **Fuente:** ídem, ejercicios 2.7 a 2.9.
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `max_lista(+L,?X)`, `suma_lista(+L,?X)` y `ordenada(+L)` (creciente, se admiten repetidos).

### ES-US-14 — Suma parcial (subconjuntos de suma dada)
- **Fuente:** ídem, ejercicio 2.10.
- **Tema:** 4, 5, 6, 7
- **Dificultad:** 2
- **Solución:** en el documento; verificada (`suma_parcial([1,2,5,3,2],5,L)` da `[1,2,2]`, `[2,3]`, `[5]`, `[3,2]`)
- **SWISH:** sí
- **Enunciado:** Definir `suma_parcial(+L1,+X,?L2)`: L2 es un subconjunto de L1 cuyos elementos suman X.

### ES-US-15 — Construir listas numéricas: lista de N, rango, entre
- **Fuente:** ídem, ejercicios 2.11 a 2.13.
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `lista(+N,-L)` (N copias de N), `lista_de_números(+N,+M,-L)` (de N a M inclusive) y `entre(+N1,+N2,?X)`, que genera los enteros entre N1 y N2 como `between/3`.

### ES-US-16 — K-ésimo elemento y multiplicar ocurrencias
- **Fuente:** ídem, ejercicios 2.14 y 2.15.
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `elemento_en(+K,?L,?X)` (numerando desde 1; `elemento_en(2,L,b)` da `L = [_,b|_]`) y `multiplicada(+L1,+N,-L2)`, que repite N veces cada elemento.

## Capítulo 3. Estructuras

### ES-US-17 — Segmentos verticales y horizontales
- **Fuente:** ídem, cap. 3, ejercicio 3.1.
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Con puntos `punto(X,Y)` y segmentos `segmento(P1,P2)`, definir `vertical(?S)` y `horizontal(?S)` solo por unificación, y responder preguntas como "¿hay algún Y tal que el segmento de (1,1) a (2,Y) sea vertical?".
- **Notas:** Ejemplo clásico (de Bratko) de que la unificación sola resuelve una pregunta geométrica.

### ES-US-18 — Base de datos familiar con estructuras
- **Fuente:** ídem, ejercicio 3.2.
- **Tema:** 3, 7, 9
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Representar familias con términos anidados (persona con nombre, apellidos, fecha de nacimiento y trabajo con sueldo diario), y consultar si hay familias con 0, 1, 2, 3 o 4 hijos, quiénes son los padres de familias con tres hijos, y definir `casado/1`, `casada/1` y otras relaciones sobre la base.
- **Notas:** Buen ejercicio para diseñar la representación con functores anidados.

### ES-US-19 — Autómata no determinista con movimientos nulos
- **Fuente:** ídem, ejercicio 3.3.
- **Tema:** 4, 5, 6
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Representar un autómata de cuatro estados con `final/1`, `trans/3` y `nulo/2`; definir `acepta(E,L)` (la cadena L lleva de E a un estado final) y usarlo para generar las cadenas aceptadas de una longitud dada.
- **Notas:** Comparable con ES-UTN-59, pero agrega transiciones vacías.

### ES-US-20 — El mono y el plátano
- **Fuente:** ídem, ejercicio 3.4.
- **Tema:** 3, 4, 5
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Un mono en la puerta quiere alcanzar un plátano colgado en el centro; puede pasear, empujar la silla de la ventana, subirse a ella y coger el plátano. Representar estados y movimientos y definir `solución(E,L)`: L es una lista de acciones que lleva del estado E a tener el plátano.
- **Notas:** Búsqueda en espacio de estados por backtracking. El orden de las cláusulas de `movimiento` determina si termina.

### ES-US-21 — Saltos del caballo de ajedrez
- **Fuente:** ídem, ejercicio 3.5.
- **Tema:** 4, 5, 6, 7
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Con casillas `[X,Y]` de 1 a 8, definir `salta(+C1,?C2)` (movimiento de caballo) y `camino(L)` (lista de casillas de un recorrido válido); usarlo para buscar caminos de longitud 4 desde `[2,1]` hasta la fila 8 pasando por `[5,4]`, y calcular el menor número de movimientos entre dos casillas.

### ES-US-22 — Máximo de un árbol binario
- **Fuente:** ídem, ejercicio 3.6.
- **Tema:** 3, 5, 7
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Con árboles `nil` y `t(I,R,D)` de números positivos, definir `máximo(+T,-X)`, el mayor nodo del árbol.

## Capítulo 4. Retroceso, corte y negación

### ES-US-23 — La función escalón con y sin corte
- **Fuente:** ídem, cap. 4, ejercicio 4.1.
- **Tema:** 4, 8
- **Dificultad:** 2
- **Solución:** en el documento; verificado que `f(1,Y), 2 < Y` falla con la versión con cortes
- **SWISH:** sí
- **Enunciado:** Definir `f(X,Y)` (0 si X < 3, 2 si 3 ≤ X < 6, 4 si X ≥ 6), dibujar el árbol de deducción de `?- f(1,Y), 2 < Y.`, repetir con cortes al final de las dos primeras cláusulas (`f_1`) y luego suprimiendo las comparaciones innecesarias (`f_2`), y comparar los árboles.
- **Notas:** El ejercicio de referencia sobre cortes verdes y rojos. `f_1` tiene cortes verdes; `f_2` tiene cortes rojos: `f_2(1,2)` tiene éxito aunque f(1) = 0, porque la primera cabeza no unifica y se salta la comparación.

### ES-US-24 — Árboles de deducción de memberchk
- **Fuente:** ídem, ejercicio 4.2.
- **Tema:** 4, 8
- **Dificultad:** 2
- **Solución:** en el documento (figuras de los árboles)
- **SWISH:** sí
- **Enunciado:** Con `memberchk(X,[X|_]) :- !.` y su cláusula recursiva, dibujar los árboles SLD de `memberchk(X,[a,b,c]), X=a`, `memberchk(X,[a,b,c]), X=b` y `X=b, memberchk(X,[a,b,c])`.
- **Notas:** Muestra que el corte hace que el orden de los objetivos importe: la segunda consulta falla y la tercera no.

### ES-US-25 — Diferencia de conjuntos y agregar sin repetir
- **Fuente:** ídem, ejercicios 4.3 y 4.4.
- **Tema:** 6, 8
- **Dificultad:** 1
- **Solución:** en el documento (versión con negación y versión con corte)
- **SWISH:** sí
- **Enunciado:** Definir `diferencia(+C1,+C2,-C3)` y `agregar(+X,+L,-L1)` (agrega X solo si no está), cada una en una versión con `not` y otra con corte.

### ES-US-26 — Separar positivos y sumar pares
- **Fuente:** ídem, ejercicios 4.5 y 4.6.
- **Tema:** 6, 7, 8
- **Dificultad:** 1
- **Solución:** en el documento (con y sin corte)
- **SWISH:** sí
- **Enunciado:** Definir `separa(+L1,-L2,-L3)` (positivos y no positivos) y `suma_pares(+L,-N)`, cada uno con y sin corte.

### ES-US-27 — Exponente de dos y lista a conjunto
- **Fuente:** ídem, ejercicios 4.7 y 4.8.
- **Tema:** 5, 6, 7, 8
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `exponente_de_dos(+N,-E)` (exponente de 2 en la factorización de N) y `lista_a_conjunto(+L,-C)`, que conserva la última aparición de cada elemento.
- **Notas:** El documento lo relaciona con `list_to_set/2`, pero en SWI 9 `list_to_set/2` conserva la primera aparición (`[b,a,d]` para `[b,a,b,d]`), no la última (`[a,b,d]`).

### ES-US-28 — Crecimientos de una sucesión
- **Fuente:** ídem, ejercicio 4.9.
- **Tema:** 6, 7, 8
- **Dificultad:** 1
- **Solución:** en el documento (con y sin corte)
- **SWISH:** sí
- **Enunciado:** Definir `crecimientos(+L1,-L2)`: entre cada par de números consecutivos se pone `+` si crece y `-` si no; por ejemplo `[1,3,2]` da `[1,+,3,-]`.

### ES-US-29 — Factorización en primos
- **Fuente:** ídem, ejercicio 4.10.
- **Tema:** 5, 7, 8
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `menor_divisor_propio(+N,?X)` (menor divisor ≥ 2) y `factorización(+N,-L)` (lista creciente de factores primos, por ejemplo `[2,2,3]` para 12).

### ES-US-30 — Menor múltiplo con suma de dígitos mayor que M
- **Fuente:** ídem, ejercicio 4.11.
- **Tema:** 5, 7, 8
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `calcula(+N,+M,?X)`: X es el menor múltiplo de N cuyos dígitos suman más que M (por ejemplo, `calcula(3,10,39)`).
- **Notas:** Patrón "generar hasta el primero que cumple y cortar".

### ES-US-31 — Números libres de cuadrados
- **Fuente:** ídem, ejercicios 4.12 y 4.13.
- **Tema:** 6, 7, 8
- **Dificultad:** 1
- **Solución:** en el documento (con negación y con corte)
- **SWISH:** sí
- **Enunciado:** Definir `libre_de_cuadrados(+N)` (no divisible por ningún cuadrado mayor que 1) y `suma_libres_de_cuadrados(+L,-S)`.

### ES-US-32 — Máximo de una lista con elementos no numéricos
- **Fuente:** ídem, ejercicio 4.14.
- **Tema:** 6, 7, 8
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `max_lista(+L,-N)`: el mayor número de L, ignorando los elementos que no son números (`a23`, `7+9`); falla si no hay ninguno.
- **Notas:** Usa `number/1`. `7+9` no es un número: es un término.

### ES-US-33 — Subsucesión común maximal
- **Fuente:** ídem, ejercicio 4.15.
- **Tema:** 5, 6, 7, X
- **Dificultad:** 3
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `longitud_scm(+L1,+L2,-N)`, la longitud de la subsucesión común más larga (los elementos no tienen por qué ser contiguos).
- **Notas:** La versión recursiva directa es exponencial; es un buen disparador para hablar de tabling (`:- table`).

### ES-US-34 — Repetidos y eliminar ocurrencias
- **Fuente:** ídem, ejercicios 4.16 a 4.18.
- **Tema:** 6, 8
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `repetido(-A,+L)` (A aparece más de una vez; da cada respuesta repetida), `elimina(+X,+L1,-L2)` (todas las ocurrencias) y `repetidos(+L1,-L2)` (lista sin duplicados de los elementos repetidos).

### ES-US-35 — Subconjunto maximal y suma por posiciones
- **Fuente:** ídem, ejercicios 4.19 y 4.20.
- **Tema:** 6, 7, 8
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `subconjunto_maximal(+L1,-L2)` (le falta exactamente un elemento de L1, sin repetidos) y `suma_posiciones(+N,+L,-S)` (suma de los elementos en posiciones múltiplo de N).

### ES-US-36 — Compresión, empaquetamiento y codificación por longitud
- **Fuente:** ídem, ejercicios 4.21 a 4.26.
- **Tema:** 5, 6, 8
- **Dificultad:** 2
- **Solución:** en el documento; `comprimida/2` verificada (`[a,b,b,a,a,a,c,c,b,b,b]` da `[a,b,a,c,b]`)
- **SWISH:** sí
- **Enunciado:** Serie encadenada: comprimir las repeticiones consecutivas, empaquetarlas en sublistas, codificar como `N-X`, codificación reducida (X solo cuando N = 1), decodificar, y codificar de forma directa sin crear sublistas.
- **Notas:** Son los problemas P08 a P13 de la conocida lista "99 problemas de Prolog", en español.

### ES-US-37 — Cota superior
- **Fuente:** ídem, ejercicio 4.27.
- **Tema:** 6, 7, 8, 9
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `cota_superior(+L,+N)`: todos los elementos de L son ≤ N. Dar una versión recursiva y otra no recursiva.
- **Notas:** La versión no recursiva usa doble negación o `forall/2`.

### ES-US-38 — Dientes de sierra
- **Fuente:** ídem, ejercicios 4.28 y 4.29.
- **Tema:** 5, 6, 7
- **Dificultad:** 3
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Un diente es una lista estrictamente creciente hasta una cima y luego estrictamente decreciente. Definir `diente(+L,-L1,-X,-L2)` y `dientes_de_sierra(+L1,?L2)`, que descompone una sierra en sus dientes (dientes consecutivos comparten un extremo).

## Capítulo 5. Programación lógica de segundo orden

En este capítulo, "segundo orden" significa `findall/3`, `setof/3`, `bagof/3`,
`maplist`, `apply/2`, `=..` y metapredicados en general.

### ES-US-39 — Factorial inverso
- **Fuente:** ídem, cap. 5, ejercicio 5.1.
- **Tema:** 5, 7, 8
- **Dificultad:** 2
- **Solución:** en el documento; verificada (`factorial_inverso(120,N)` da `N = 5`; con 80 falla)
- **SWISH:** sí
- **Enunciado:** Definir `factorial_inverso(+X,-N)`: X es el factorial de N; debe fallar si X no es un factorial.
- **Notas:** Obliga a generar N de forma creciente y cortar en cuanto el factorial supera X.

### ES-US-40 — Árbol de resolución y definición no recursiva
- **Fuente:** ídem, ejercicio 5.2.
- **Tema:** 4, 8, 9
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Dibujar el árbol de resolución de `?- p([5,1,6],B).` para el programa de abajo, explicar qué relación hay entre L1 y L2, y dar una definición no recursiva de `p/2`.
  ```prolog
  p([],[]).
  p([X|A],[X|B]) :- X > 4, !, p(A,B).
  p([X|A],B) :- p(A,B).
  ```
- **Notas:** Es un filtro (`include/3` con `X > 4`); la versión no recursiva usa `findall/3`.

### ES-US-41 — Nodos de una generación de árboles binarios
- **Fuente:** ídem, ejercicio 5.3.
- **Tema:** 3, 5, 6, 9
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Con árboles `nil` / `t(I,R,D)`, definir `generación(+N,+L1,-L2)`: L2 son los nodos del nivel N de la lista de árboles L1 (nivel 0 = raíces).

### ES-US-42 — Elementos únicos y más frecuentes
- **Fuente:** ídem, ejercicios 5.4 y 5.5.
- **Tema:** 6, 9
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `únicos(+L1,-L2)` (elementos que aparecen una sola vez) y `populares(L1,L2)` (elementos que más veces aparecen, por ejemplo `[david,rosa]`).

### ES-US-43 — Problema 3n+1 (Collatz)
- **Fuente:** ídem, ejercicio 5.6.
- **Tema:** 5, 6, 7, 9
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Con f(x) = 3x+1 si x es impar y x/2 si es par, definir `sucesión(+X,?L)` (hasta llegar a 1), `longitudes(+X,?L)` (pares `Y-N` para Y de 1 a X) y `longitud_máx(+X,?P)` (el Y con la sucesión más larga).
- **Notas:** Usar `//` para la división entera; con `/` aparecen flotantes.

### ES-US-44 — Números perfectos, abundantes y deficientes
- **Fuente:** ídem, ejercicios 5.7 a 5.12.
- **Tema:** 6, 7, 9
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `divisores_propios(+N,-L)`, `suma_divisores_propios(+N,-S)`, `tipo(+N,-T)` (a si N es mayor que la suma de sus divisores propios, b si es igual, c si es menor), `clasifica(+N,-L)`, `promedio(+N,-A,-B,-C)` (cantidad de cada tipo hasta N) y `menor(+N,-X)`.
- **Notas:** Serie graduada en la que cada predicado usa el anterior.

### ES-US-45 — Polígonos equiláteros con =..
- **Fuente:** ídem, ejercicio 5.13.
- **Tema:** 3, 6
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Un polígono es un término cuyo nombre es el tipo y cuyos argumentos son las longitudes de sus lados (`triángulo(4,4,4)`, `cuadrilátero(3,4,5,3)`). Definir `es_equilátero(+P)`.
- **Notas:** Primer uso de `=..` (univ) para tratar términos de aridad variable.

### ES-US-46 — Operación binaria aplicada a listas
- **Fuente:** ídem, ejercicio 5.14.
- **Tema:** 6, 7, 9
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `operación_lista(+O,+L1,+L2,-L3)`: aplica la operación O (`+`, `*`, …) elemento a elemento; por ejemplo, con `+`, `[1,2,3]` y `[4,5,6]` da `[5,7,9]`.
- **Notas:** Hay que construir la expresión con `=..` y evaluarla con `is`. En el texto del ejemplo el nombre aparece como `operación_lista` y en la definición como `operación_listas`.

### ES-US-47 — Números que aparecen en un término
- **Fuente:** ídem, ejercicio 5.15.
- **Tema:** 3, 5, 9
- **Dificultad:** 2
- **Solución:** en el documento; verificada una versión propia con `=..` y `setof/3`
- **SWISH:** sí
- **Enunciado:** Definir `números(+T,-L)`: el conjunto de números que aparecen en el término cerrado T; por ejemplo, `a+3+b*(sen(2)+3)` da `[2,3]`.
- **Notas:** Recorrido recursivo de un término cualquiera: base para entender que las expresiones aritméticas son árboles.

### ES-US-48 — Palabras: sin vocales, longitud y maximales
- **Fuente:** ídem, ejercicios 5.16 a 5.19.
- **Tema:** 6, 9
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `elimina_vocales(+P1,-P2)` (`sevillano` da `svlln`), `longitud(+P,-N)` de una palabra, `palabra_maximal(+L,-P)` y `palabras_maximales(+L1,-L2)`.
- **Notas:** Usa `name/2` para pasar de átomo a códigos. Hoy se prefieren `atom_chars/2` o `atom_codes/2`.

### ES-US-49 — Clausura transitiva de una relación
- **Fuente:** ídem, ejercicio 5.20.
- **Tema:** 5, 9
- **Dificultad:** 2
- **Solución:** en el documento; verificada una versión con `call/3` (con `p(a,b). p(b,c).` da `b` y `c` desde `a`)
- **SWISH:** sí
- **Enunciado:** Definir `clausura_transitiva(R,X,Y)`: (X,Y) está en la clausura transitiva de la relación binaria R, que se pasa como argumento.
  ```prolog
  clausura_transitiva(R,X,Y) :- call(R,X,Y).
  clausura_transitiva(R,X,Y) :- call(R,X,Z), clausura_transitiva(R,Z,Y).
  ```
- **Notas:** La solución del documento usa `apply/2`, que en SWI 9.2.9 todavía funciona pero es obsoleto; `call/N` es lo estándar. Con una relación que tiene ciclos (la `q/2` del ejemplo) se repiten respuestas y, al pedir más, no termina.

### ES-US-50 — Traducción de cifras y transformación por posición
- **Fuente:** ídem, ejercicios 5.21 y 5.22.
- **Tema:** 6, 7, 9
- **Dificultad:** 1
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Definir `traducción(+L1,-L2)` (`[1,3]` da `[uno,tres]`, con `maplist`) y `transforma(+L1,-L2)`, que le suma a cada número su posición en la lista y deja igual lo que no es número. Dar una versión recursiva y otra no recursiva.

### ES-US-51 — Aplanamiento de listas
- **Fuente:** ídem, ejercicio 5.23.
- **Tema:** 5, 6, 8
- **Dificultad:** 2
- **Solución:** en el documento; verificada (`[a,[b,[c]],[[d],e]]` da `[a,b,c,d,e]`)
- **SWISH:** sí
- **Enunciado:** Definir `aplana(+L1,?L2)`: reemplaza recursivamente cada sublista por sus elementos.
- **Notas:** SWI trae `flatten/2`; el ejercicio es definirlo a mano, con corte para distinguir listas de no listas.

## Capítulo 6. Estilo y eficiencia en programación lógica

### ES-US-52 — Número de Hardy–Ramanujan
- **Fuente:** ídem, cap. 6, ejercicios 6.1 a 6.4.
- **Tema:** 4, 7, 8, 9
- **Dificultad:** 2
- **Solución:** en el documento; verificada una versión propia (`hardy(N)` da `N = 1729`)
- **SWISH:** sí
- **Enunciado:** Definir `es_cubo(+N)`, `descompone(+N,-X,-Y)` (N = X + Y con X ≤ Y cubos), `ramanujan(+N)` (exactamente dos descomposiciones) y `hardy(-N)`, el menor número de Ramanujan: la matrícula del taxi de Hardy.
- **Notas:** El capítulo compara varias versiones por tiempo de ejecución (`time/1`): buen ejercicio de eficiencia al generar y testear.

### ES-US-53 — Subconjuntos de suma dada
- **Fuente:** ídem, ejercicio 6.5.
- **Tema:** 4, 6, 7, 10
- **Dificultad:** 2
- **Solución:** en el documento (cuatro versiones)
- **SWISH:** sí
- **Enunciado:** Definir `subconjunto_suma(+L1,+N,?L2)`: L2 es un subconjunto de L1 que suma N (con `[]` para N = 0). Comparar la eficiencia de generar todos los subconjuntos con la de podar durante la construcción.
- **Notas:** Las versiones 3 y 4 de la solución memorizan resultados con `asserta/1` en un predicado dinámico (y la 4 cambia el orden de los argumentos para aprovechar la indexación): es un ejemplo de base de datos dinámica usada como caché.

### ES-US-54 — Coloreado de mapas
- **Fuente:** ídem, ejercicio 6.6.
- **Tema:** 4, 6, 9
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Con `mapa(Nombre, [Region-Vecinas, ...])`, definir `coloración(+M,+LC,-S)`: asignar a cada región un color de LC de modo que las vecinas tengan colores distintos. Averiguar cuántos colores necesita el segundo mapa.
- **Notas:** El clásico de generar y testear. La solución compara con `time/1` la versión que prueba al final (16,7 millones de inferencias) con la que adelanta la prueba usando un acumulador (546 inferencias). El segundo mapa necesita 4 colores y admite 1032 coloreados.

## Capítulo 7. Aplicaciones de programación declarativa

### ES-US-55 — Grupos compatibles de asignaturas
- **Fuente:** ídem, cap. 7, ejercicios 7.1 a 7.7.
- **Tema:** 4, 6, 9
- **Dificultad:** 3
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Con las listas de clase de cada asignatura, definir las asignaturas de un curso, grupos y listas de grupos incompatibles (algún alumno en dos asignaturas del grupo), `extensión/3`, `partición(+L,-P)` de una lista, las particiones compatibles y la partición compatible con el menor número de grupos.
- **Notas:** Problema de planificación de exámenes: combina particiones generadas por backtracking con minimización.

### ES-US-56 — Simulación de una calculadora básica
- **Fuente:** ídem, ejercicios 7.8 a 7.13.
- **Tema:** 3, 6, 7, 8, 9
- **Dificultad:** 3
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** El estado de la calculadora es `[UCE,UTA,UOA,VIM]`. Definir `transición/3` para una tecla (dígito u operación), `transiciones/3` para una lista de teclas, `acciones/1`, las secuencias válidas (sin dos operaciones seguidas, sin dividir por cero, etc.), contarlas para longitud 3 y encontrar las secuencias de M teclas que dan un resultado N.
- **Notas:** Las operaciones se aplican construyendo el término con `=..`.

### ES-US-57 — Problema de las subastas
- **Fuente:** ídem, ejercicio 7.14.
- **Tema:** 6, 7, 8, 9
- **Dificultad:** 2
- **Solución:** en el documento
- **SWISH:** sí
- **Enunciado:** Con `oferta(O, Lote, Precio)`, definir `aceptada(-L)`: un conjunto de ofertas sin objetos en común cuya ganancia total sea máxima.
  ```prolog
  oferta(a,[1,2,3],30). oferta(b,[1,2,3],20). oferta(c,[4],20).
  oferta(d,[2,4],20). oferta(e,[1,2],20).
  % ?- aceptada(L).  L = [a,c]
  ```
- **Notas:** La solución expresa "máximo" con negación: es aceptable y no existe otra aceptable de mayor ganancia.

## Relaciones de ejercicios del curso "Programación lógica con Prolog" (2022)

Repositorio: José A. Alonso Jiménez, *Ejercicios de programación lógica con Prolog*,
https://github.com/jaalonso/Ejercicios-Prolog (licencia GPL-3.0). Son ocho archivos
`src/ejercicios-tema-N.pl` (temas 2 a 9 del curso https://jaalonso.github.io/materias/PLconProlog/),
cada uno con el enunciado en comentarios y una o varias soluciones. Cada archivo tiene
una copia pública en SWISH: `https://swish.swi-prolog.org/p/PLP_ejercicios-tema-N.pl`
(se comprobaron las de los temas 2, 5 y 9).

Es una actualización para SWI-Prolog moderno (respuestas `true`/`false`) de buena parte
del documento de 2006: pertenece, sublista, último, inversa, palíndromo, selecciona,
máximo, longitud, entre, la familia y el autómata, el caballo, corte y negación
(diferencia, agregar, separa, suma_pares, factorización, compresión y codificación,
dientes de sierra), segundo orden (Collatz, perfectos, palabras, clausura transitiva,
aplana), Hardy, subconjuntos, calculadora, asignaturas y subastas. Esos ejercicios ya
están arriba (ES-US-1 a ES-US-57) y no se repiten. Abajo solo van los nuevos.

Advertencia verificada: con la codificación por defecto de SWI-Prolog 9.2.9 en Windows,
siete de los ocho archivos dan errores de sintaxis al cargarse (de 7 a 42 por archivo),
por los nombres con tildes. Con `load_files(F, [encoding(utf8)])` cargan todos sin
errores, salvo el tema 7, que incluye `representacion_de_grafos.pl` con un error propio
en la línea 22. En SWISH cargan bien.

### ES-US-58 — Operadores definidos por el usuario: "el libro de ciencias de juan es rojo"
- **Fuente:** Alonso, *Ejercicios de programación lógica con Prolog*, `src/ejercicios-tema-2.pl`, ejercicios 12 y 13. https://github.com/jaalonso/Ejercicios-Prolog/blob/main/src/ejercicios-tema-2.pl
- **Tema:** 3
- **Dificultad:** 2
- **Solución:** en el archivo; verificada: con `op(400,yfx,de)`, `X es rojo` da `el_libro de ciencias de juan`; `X de Y es rojo` da `X = el_libro de ciencias, Y = juan`; `el_libro de X es rojo` falla. Con `op(500,yfx,a)`, `M a l a S` da `M = b a c, S = o` y `b a c a S` falla; con `xfy` pasa lo contrario (`S = l a o`).
- **SWISH:** sí
- **Enunciado:** Dadas las directivas `op/3` y el hecho que se muestra abajo, predecir qué responde Prolog a varias consultas y cómo cambian las respuestas si la asociatividad pasa de `yfx` a `xfy`.
  ```prolog
  :- op(800,xfx,es).
  :- op(400,yfx,de).
  el_libro de ciencias de juan es rojo.
  ```
- **Notas:** Muestra que los operadores son solo sintaxis para términos y que la asociatividad decide la forma del árbol.

### ES-US-59 — MCD por restas (algoritmo de Euclides)
- **Fuente:** ídem, `src/ejercicios-tema-2.pl`, ejercicio 8.
- **Tema:** 5, 7
- **Dificultad:** 1
- **Solución:** en el archivo
- **SWISH:** sí
- **Enunciado:** Definir `mcd(X,Y,D)` con las tres reglas: si X = Y, D = X; si X < Y, D = mcd(X, Y−X); si Y < X, D = mcd(X−Y, Y).

### ES-US-60 — La banda de tres músicos (acertijo lógico)
- **Fuente:** ídem, `src/ejercicios-tema-3.pl`, ejercicio 3.
- **Tema:** 3, 4, 6
- **Dificultad:** 2
- **Solución:** en el archivo (`solución_músicos/1`)
- **SWISH:** sí
- **Enunciado:** Tres músicos de distintos países tocan distintos instrumentos; el pianista toca primero, Juan toca el saxo y toca antes que el australiano, Marco es francés y toca antes que el violinista, hay un japonés y uno se llama Saúl. Determinar nombre, país e instrumento de cada uno.
- **Notas:** Plantilla de "acertijo de Einstein": una lista de tres estructuras `músico(N,P,I)` parcialmente instanciadas, que se va restringiendo con `member/2`.

### ES-US-61 — Eficiencia de conc para obtener prefijos
- **Fuente:** ídem, `src/ejercicios-tema-4.pl`, ejercicio 6.
- **Tema:** 4, 6, 8
- **Dificultad:** 2
- **Solución:** en el archivo
- **SWISH:** sí
- **Enunciado:** Encontrar todas las L tales que `conc(L,[c,d],[a,b,c,d])`. Si ese fuera el único uso de `conc`, ¿se podría modificar su definición (con un corte) para que sea más eficiente? ¿Serviría esa modificación para el uso general?

### ES-US-62 — Divisores, primos y el polinomio de Euler
- **Fuente:** ídem, `src/ejercicios-tema-5.pl`, ejercicios 1 a 3.
- **Tema:** 7, 8, 9
- **Dificultad:** 2
- **Solución:** en el archivo
- **SWISH:** sí
- **Enunciado:** Definir `divisores(+N,-L)` y tres versiones de `primo(+N)` (por cantidad de divisores, por ausencia de divisores hasta √N y por ausencia de divisores primos hasta √N). Definir `genera_primo(+X,+Y,-L)` para p(x) = x² − x + 41 y comprobar que p(A) es primo para A de 1 a 40, pero no para 41.

### ES-US-63 — Números amigos
- **Fuente:** ídem, `src/ejercicios-tema-5.pl`, ejercicios 4.1 y 4.2.
- **Tema:** 7, 9
- **Dificultad:** 2
- **Solución:** en el archivo
- **SWISH:** sí
- **Enunciado:** Dos números son amigos si cada uno es la suma de los divisores propios del otro (6 y 28 son amigos de sí mismos). Definir `divisores_propios/2` y la relación de números amigos en un intervalo.

### ES-US-64 — para_todos, existe y filtrar con call
- **Fuente:** ídem, `src/ejercicios-tema-5.pl`, ejercicios 6 a 8.
- **Tema:** 9, 6
- **Dificultad:** 1
- **Solución:** en el archivo
- **SWISH:** sí
- **Enunciado:** Definir `para_todos(+P,+L)`, `existe(+P,+L)` y `sublista(+P,+L1,?L2)` (los elementos de L1 que cumplen P), donde P es el nombre de una propiedad que se aplica con `call/2`. Por ejemplo, `para_todos(number,[1,2,3])` es verdadero.
- **Notas:** Equivalen a `maplist/2`, a `include/3` y a una versión de `memberchk` con propiedad: buen puente hacia `forall/2`.

### ES-US-65 — Rotaciones, capicúas e invertir palabras
- **Fuente:** ídem, `src/ejercicios-tema-5.pl`, ejercicios 9 a 11.
- **Tema:** 6, 7, 9
- **Dificultad:** 1
- **Solución:** en el archivo
- **SWISH:** sí
- **Enunciado:** Definir `rotaciones(L1,L2)` (lista de todas las rotaciones de L1), `capicúas(N,L)` (enteros positivos capicúa menores que N) e `invierte_palabra(P1,P2)` (`arroz` da `zorra`).
- **Notas:** El archivo muestra cómo ver listas largas completas con `set_prolog_flag(answer_write_options, [max_depth(100)])`.

### ES-US-66 — Lista más larga y acumuladores
- **Fuente:** ídem, `src/ejercicios-tema-6.pl`, ejercicios 1 y 3.
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** en el archivo
- **SWISH:** sí
- **Enunciado:** Definir `lista_mayor(+L1,-L2)` (una lista de longitud máxima de una lista de listas) y, usando un acumulador, `factorial/2` y `longitud/2`.

### ES-US-67 — Torres de Hanói
- **Fuente:** ídem, `src/ejercicios-tema-6.pl`, ejercicio 4.
- **Tema:** 5, 6, 10
- **Dificultad:** 2
- **Solución:** en el archivo
- **SWISH:** sí
- **Enunciado:** Definir `hanoi(+N,+A,+B,+C,-L)`: L es la lista de movimientos (`a-c`, `a-b`, …) para pasar N discos del poste A al B usando C como auxiliar, sin poner nunca un disco sobre otro menor. Dar una versión sin memoria y otra con memoria, y comparar.

### ES-US-68 — Bandera tricolor
- **Fuente:** ídem, `src/ejercicios-tema-6.pl`, ejercicio 5.
- **Tema:** 6, 8, 9
- **Dificultad:** 1
- **Solución:** en el archivo (tres versiones)
- **SWISH:** sí
- **Enunciado:** Dada una lista de objetos rojos, amarillos y morados, definir `bandera_tricolor(+L1,-L2)`, que devuelve primero los rojos, luego los amarillos y por último los morados.

### ES-US-69 — Sucesión de Langford
- **Fuente:** ídem, `src/ejercicios-tema-6.pl`, ejercicio 6.
- **Tema:** 4, 6, X
- **Dificultad:** 3
- **Solución:** en el archivo
- **SWISH:** sí (puede tardar)
- **Enunciado:** Definir `lanford(?L)`: L tiene longitud 27, cada dígito del 1 al 9 aparece tres veces y entre dos apariciones consecutivas del dígito k hay exactamente k dígitos.

### ES-US-70 — Grafos: conexo, ciclos, árbol y árbol de expansión
- **Fuente:** ídem, `src/ejercicios-tema-7.pl`, ejercicios 1 a 4.
- **Tema:** 5, 6, 8, 9
- **Dificultad:** 2
- **Solución:** en el archivo
- **SWISH:** sí
- **Enunciado:** Con grafos representados en el archivo auxiliar `representacion_de_grafos.pl`, definir `conectado(+G)`, `tiene_ciclos(+G)`, `es_árbol(+G)`, `recubre(+G1,+G2)` y `árbol_de_expansión(+G,?A)`.
- **Notas:** En la carga local, `representacion_de_grafos.pl` da un error de sintaxis en la línea 22 en SWI 9.2.9.

### ES-US-71 — Mundo de bloques y 8 reinas como búsqueda en espacio de estados
- **Fuente:** ídem, `src/ejercicios-tema-8.pl`, ejercicios 1 y 2, con `src/b_profundidad_sin_ciclos.pl`, `src/b_profundidad_con_ciclos.pl` y `src/b_anchura.pl`.
- **Tema:** 4, 5, 6, X
- **Dificultad:** 3
- **Solución:** en el archivo
- **SWISH:** sí
- **Enunciado:** Representar estados y sucesores para apilar tres bloques y para colocar ocho reinas, y resolver ambos problemas con búsqueda en profundidad sin ciclos, con detección de ciclos y en anchura, usando los buscadores genéricos del repositorio.

### ES-US-72 — Restricciones: CLP(R) y CLP(FD)
- **Fuente:** ídem, `src/ejercicios-tema-9.pl`, ejercicios 1 a 5 y 10 a 17.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** en el archivo
- **SWISH:** sí
- **Enunciado:** Producto escalar y sistemas lineales en CLP(R), matriz equilibrada, CUATRO × 5 = VEINTE, mochila del contrabandista, asignación óptima de tareas, factores y suma "inversibles" con `#=`, cuadrado mágico 3×3, N reinas, coloreado de mapas, el problema de pollos y vacas, y Fibonacci inversible.
- **Notas:** Fuera del alcance del curso base, pero `library(clpfd)` es la respuesta moderna a "por qué `X is Y+1` no es inversible". Los ejercicios 6 a 18 reescriben con CLP(FD) problemas de temas anteriores (factorial, máximo, MCD, caballo, cota superior) para que funcionen en todos los modos.
