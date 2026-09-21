# Fuentes en español: otras instituciones

Parte del banco [fuentes-en-espanol.md](fuentes-en-espanol.md). Licencias en la tabla de
fuentes de ese archivo y, además, en el encabezado de cada sección.

## Argentina

### Universidad Nacional del Sur (UNS), Bahía Blanca

Documento: "Conceptos de Inteligencia Artificial – Introducción al Lenguaje Prolog –
Ejercicios", Depto. de Ciencias e Ingeniería de la Computación, UNS.
URL: http://cs.uns.edu.ar/~grs/Conceptos/EjerciciosProlog.pdf
Licencia: no declarada. Sin soluciones.

### ES-UNS-1 — Días de cada mes (con años bisiestos)
- **Fuente:** UNS, "Introducción al Lenguaje Prolog – Ejercicios", ejercicio 1. http://cs.uns.edu.ar/~grs/Conceptos/EjerciciosProlog.pdf
- **Tema:** 1, 2, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Crear un programa que asocie a cada mes su cantidad de días, contemplando los años bisiestos.
- **Notas:** Obliga a decidir si febrero depende del año (predicado de aridad 3) o no.

### ES-UNS-2 — Consultas sobre una base de progenitores
- **Fuente:** ídem, ejercicio 2.
- **Tema:** 1, 4
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dada una base de hechos `progenitor/2` con doce hechos, indicar las respuestas de nueve consultas, desde `progenitor(omar, maria)` hasta `progenitor(X, hector), progenitor(abel, X)` y `progenitor(X, Y)`.
  ```prolog
  progenitor(abel, cesar).   progenitor(dario, hector).
  progenitor(flavia, dario). progenitor(omar, maria).
  ```
- **Notas:** Ejercicio de lectura: predecir antes de ejecutar, incluido el orden de las respuestas.

### ES-UNS-3 — Relaciones de parentesco a partir de progenitor
- **Fuente:** ídem, ejercicio 3.
- **Tema:** 2, 5, 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Sobre la base anterior, definir `padresDe/3`, `tuvoHijos/1`, `esMadre/1` (sin respuestas incorrectas; agregar hechos auxiliares si hace falta y justificarlo), `hermanos/2` (explicitar la noción de hermano), `tio/2`, `abuelo/2`, `tioAbuelo/2` (¿qué particularidad tiene con esta base?) y `ancestro/2`.
- **Notas:** `esMadre/1` no se puede definir sin información de sexo: el enunciado busca que el estudiante lo descubra. Con los datos dados, `tioAbuelo/2` no tiene ninguna solución (verificado con una definición directa).

### ES-UNS-4 — Parentesco político: suegros, yernos, cuñados, concuñados
- **Fuente:** ídem, ejercicio 4.
- **Tema:** 2, 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Agregar `parejaCasada/2` con cuatro parejas y definir `suegra/2`, `suegro/2`, `padresPoliticosDe/3`, `nuera/2`, `yerno/2`, `cunado/2`, `cunada/2`, `hermanosPoliticos/2` y `concunados/2`.
- **Notas:** `parejaCasada/2` no es simétrica en los hechos: hay que definir un predicado auxiliar `casados/2` que lo sea.

### ES-UNS-5 — ¿Qué consultas con is/2 son válidas?
- **Fuente:** ídem, ejercicio 5.
- **Tema:** 7
- **Dificultad:** 1
- **Solución:** verificada en SWI 9.2.9: `X is 2` → `X = 2`; `2 is X` → error de instanciación; `2 is 2` → true; `X is 2 + 2` → `X = 4`; `2 + 2 is X` → error de instanciación; `2 + 2 is 2 + 2` → false; `X is Y` → error de instanciación.
- **SWISH:** sí
- **Enunciado:** Determinar cuáles de siete consultas con `is/2` son válidas, desde `X is 2` hasta `2 + 2 is 2 + 2` y `X is Y`.
- **Notas:** El caso `2 + 2 is 2 + 2` es el más instructivo: el lado izquierdo no se evalúa, así que compara el término `2+2` con el número 4.

### ES-UNS-6 — Funciones como relaciones: suma, producto, factorial, Fibonacci, Ackermann
- **Fuente:** ídem, ejercicio 6.
- **Tema:** 5, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Toda función n-aria se puede escribir como una relación (n+1)-aria. Definir así la suma, el producto, el factorial, Fibonacci y la función de Ackermann, con `is/2`.
- **Notas:** Ackermann crece muy rápido: con argumentos pequeños (A(3,3)) ya hace muchas llamadas.

### ES-UNS-7 — Números de Peano: generar, sumar, multiplicar, potencia
- **Fuente:** ídem, ejercicios 7 a 10.
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con naturales en notación `s(s(0))`, definir un generador de todos los naturales en orden, la suma por incrementos sucesivos, la multiplicación por sumas sucesivas y la potencia por multiplicaciones sucesivas.
- **Notas:** A diferencia de `is/2`, la suma de Peano es inversible: `suma(X, Y, s(s(0)))` genera todas las descomposiciones.

### ES-UNS-8 — Predicados recursivos sobre listas
- **Fuente:** ídem, ejercicio 11.
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir: crear una lista con dos elementos, insertar al comienzo y al final, concatenar, buscar, invertir, borrar una o todas las apariciones, cambiar una o todas las apariciones, generar un palíndromo de longitud 2n y rotar a derecha e izquierda.
- **Notas:** La misma lista de ejercicios aparece en la práctica de la Universidad de Huelva (ES-UHU-4).

### ES-UNS-9 — Conjuntos como listas sin repetidos
- **Fuente:** ídem, ejercicio 12.
- **Tema:** 6, 8
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con conjuntos representados como listas sin repeticiones, definir pertenencia, agregar un elemento, unión, intersección, diferencia y conversión de lista con repetidos a conjunto.

### Universidad de Buenos Aires (UBA), Paradigmas de Lenguajes de Programación

Documento: "Práctica No 7 – Programación lógica", Paradigmas de Lenguajes de
Programación, Departamento de Computación, FCEyN, UBA, Verano 2018 (22 ejercicios). No
se encontró la copia oficial en línea; se usa la que un estudiante subió a su
repositorio de apuntes.
URL: https://github.com/pmontepagano/plp/blob/master/practicas_enunciados/p7_logica.pdf
Soluciones de estudiantes (no oficiales): `practicas_solucion/practica_7.pdf` y
`soluciones_haskell_js_prolog/practica7.pl` en el mismo repositorio.
Licencia: el repositorio no declara licencia y el enunciado es de la cátedra. Solo citar
y enlazar.
Regla de la práctica: el único metapredicado permitido es `not`; no se pueden usar el
corte ni predicados de orden superior como `setof`.

### ES-UBA-1 — Abuelo, descendiente y un ancestro que no termina
- **Fuente:** UBA, PLP, "Práctica 7 – Programación lógica" (Verano 2018), ejercicio 1. https://github.com/pmontepagano/plp/blob/master/practicas_enunciados/p7_logica.pdf
- **Tema:** 2, 4, 5
- **Dificultad:** 2
- **Solución:** no oficial (repositorio del estudiante)
- **SWISH:** sí
- **Enunciado:** Con hechos `padre/2`, consultar `abuelo(X, manuel)`, definir `hijo`, `hermano` y `descendiente`, dibujar el árbol de búsqueda de `descendiente(Alguien, juan)`, buscar nietos y hermanos, y explicar qué pasa con `ancestro(juan, X)` al pedir más de una respuesta si se define `ancestro(X,X).` y `ancestro(X,Y) :- ancestro(Z,Y), padre(X,Z).` Proponer un arreglo.
- **Notas:** Recursión a la izquierda: después de las primeras respuestas no termina.

### ES-UBA-2 — Árbol de búsqueda de vecino/3
- **Fuente:** ídem, ejercicio 2.
- **Tema:** 4, 6
- **Dificultad:** 1
- **Solución:** no oficial
- **SWISH:** sí
- **Enunciado:** Dibujar el árbol de búsqueda de `vecino(5, Y, [5,6,5,3])` para el programa de abajo y decir si invertir el orden de las reglas cambia los resultados o su orden.
  ```prolog
  vecino(X, Y, [X|[Y|Ls]]).
  vecino(X, Y, [W|Ls]) :- vecino(X, Y, Ls).
  ```

### ES-UBA-3 — menorOIgual y los ciclos infinitos
- **Fuente:** ídem, ejercicio 3.
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** no oficial; verificado que `menorOIgual(0,X)` se queda sin pila en SWI 9.2.9
- **SWISH:** sí
- **Enunciado:** Explicar qué pasa con la consulta `menorOIgual(0,X)`, describir cuándo puede haber un ciclo infinito en Prolog y corregir la definición.
  ```prolog
  natural(0).
  natural(suc(X)) :- natural(X).
  menorOIgual(X, suc(Y)) :- menorOIgual(X, Y).
  menorOIgual(X,X) :- natural(X).
  ```
- **Notas:** Basta con invertir el orden de las dos cláusulas de `menorOIgual` para que genere respuestas (verificado: `0`, `suc(0)`, `suc(suc(0))`, …).

### ES-UBA-4 — Predicados sobre listas con modos de instanciación
- **Fuente:** ídem, ejercicios 4 a 7 y 9 a 10.
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** no oficial
- **SWISH:** sí
- **Enunciado:** Definir `concatenar/3` en todos los modos, `last`, `reverse` (con árbol de búsqueda), máximo y mínimo, prefijo, sufijo, sublista, pertenece, `aplanar/2`, `palíndromo/2`, `doble/2`, `iésimo/3`, `intersección/3`, `split/4` (¿cuán reversible es?), `borrar/3`, `sacarDuplicados/2`, `reparto/3`, `repartoSinVacías/2` e `intercalar/3`.
- **Notas:** Cada predicado viene con sus modos (`+`, `-`, `?`): la práctica exige pensar la reversibilidad de cada uno.

### ES-UBA-5 — desde/2: generador infinito
- **Fuente:** ídem, ejercicio 8.
- **Tema:** 4, 5, 7
- **Dificultad:** 2
- **Solución:** no oficial; verificada una versión propia (con `var/1`) que genera 3, 4, 5, … desde 3 y acepta `desde2(3,10)`
- **SWISH:** sí
- **Enunciado:** Con `desde(X,X). desde(X,Y) :- N is X+1, desde(N,Y).`, explicar cómo deben instanciarse los argumentos para que no se cuelgue ni dé error, y modificarlo para el modo `desde(+X,?Y)`.
- **Notas:** Es el generador infinito que se usa después en todos los ejercicios de "generate & test".

### ES-UBA-6 — Árboles binarios: altura, inorder, ABB
- **Fuente:** ídem, ejercicios 11 y 12.
- **Tema:** 3, 5, 6
- **Dificultad:** 2
- **Solución:** no oficial
- **SWISH:** sí
- **Enunciado:** Con árboles `nil` y `bin(Izq, V, Der)`, definir `vacío`, `raiz`, `altura`, `cantidadDeNodos`, `inorder/2`, su inversa `arbolConInorder/2`, `aBB/1` e `aBBInsertar/3`.

### ES-UBA-7 — Generate & test: coprimos, cuadrados semilatinos, triángulos
- **Fuente:** ídem, ejercicios 13 a 15.
- **Tema:** 4, 5, 6, 7
- **Dificultad:** 3
- **Solución:** no oficial; verificada una versión propia de `coprimos/2` (primeros pares: 1-1, 1-2, 2-1, 1-3, 3-1, 1-4)
- **SWISH:** sí
- **Enunciado:** Generar todos los pares de naturales coprimos sin repetir; generar los cuadrados semilatinos N×N (todas las filas suman lo mismo) en orden creciente de suma; y con `tri(A,B,C)`, definir `esTriángulo/1`, `perímetro/2` para cualquier instanciación (sin colgarse ni repetir) y `triángulo/1`, que genera todos los triángulos válidos.
  ```prolog
  coprimos(X,Y) :- desde(2,S), between(1,S,X), Y is S-X, Y > 0, 1 =:= gcd(X,Y).
  ```
- **Notas:** Enseñan a recorrer un espacio infinito "por diagonales" (fijando primero la suma) para que cada respuesta aparezca tras un número finito de pasos.

### ES-UBA-8 — Negación por falla: diferencia simétrica, unicidad, corte más parejo
- **Fuente:** ídem, ejercicios 16 a 19.
- **Tema:** 8, 4
- **Dificultad:** 2
- **Solución:** no oficial
- **SWISH:** sí
- **Enunciado:** Definir la diferencia simétrica de dos listas; explicar qué significa `P(Y), not(Q(Y))` y qué pasa si se invierte el orden; usar `not` para decidir si existe un único Y tal que P(Y); definir `corteMásParejo/3` (partir una lista en dos con sumas lo más parecidas posible); y el máximo X que satisface un predicado P.
- **Notas:** "El más parejo" y "el máximo" se expresan con `not`: existe uno y no existe otro mejor.

### ES-UBA-9 — Grafos: camino simple, hamiltoniano, conexo, estrella
- **Fuente:** ídem, ejercicio 20 (integrador opcional).
- **Tema:** 4, 5, 6, 8
- **Dificultad:** 3
- **Solución:** no oficial
- **SWISH:** sí
- **Enunciado:** Con `esNodo(+G,?X)` y `esArista(+G,?X,?Y)` (grafo no orientado de representación desconocida), definir `caminoSimple/4` sin repetidos ni cuelgues, `caminoHamiltoniano/2`, `esConexo/1` y `esEstrella/1`, sin `setof`.
- **Notas:** La ayuda sugiere pensar primero el predicado opuesto (por ejemplo, "no conexo") y negarlo.

### ES-UBA-10 — Generar árboles y el recetario
- **Fuente:** ídem, ejercicios 21 y 22 (integradores opcionales).
- **Tema:** 4, 5, 6, 8
- **Dificultad:** 3
- **Solución:** no oficial
- **SWISH:** sí
- **Enunciado:** Generar todas las estructuras de árbol binario sin repetir (`arbol/1`), árboles con nodos de un alfabeto y sin símbolos repetidos. Con `disponible/1` y `receta(Plato, Minutos, Ingredientes)`, definir `sonSimilares/2`, `quéMeFalta/3`, `puedoPreparar/1` y `másRápido/1`.
- **Notas:** El recetario usa átomos con tilde (`azúcar`, `ananá`): en SWI local conviene `:- encoding(utf8).`

## España

### Universidad de Huelva (UHU)

Documento: José Carpio Cañada, Gonzalo Antonio Aranda Corral y José Marco de la Rosa,
*Programación Declarativa*, Materiales para la docencia [95], Universidad de Huelva,
Servicio de Publicaciones, 2010, ISBN 978-84-15147-05-3. Parte "Prácticas con Prolog".
URL: https://www.uhu.es/jose.carpio/N_95.pdf
Licencia: © Universidad de Huelva y los autores (sin licencia abierta). Citar y enlazar.
Usa SWI-Prolog (de 2010: `Yes`/`No`, `guitracer`, `edit(file(...))`).

### ES-UHU-1 — Unificación: ¿unifican estos pares?
- **Fuente:** UHU, *Programación Declarativa* (2010), práctica "Introducción al entorno SWI-Prolog", ejercicio 1. https://www.uhu.es/jose.carpio/N_95.pdf
- **Tema:** 3, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Comprobar si unifican dieciséis pares de términos, entre ellos `X = 2 + 3`, `X=1, X=2, X=Y`, `X = 2+X`, `X=3+4, Y=7, X=Y`, `2 + 3 = 2 + Y`, `2*X = Y*(3+Y)`, `1+1 = +(1,1)` y `(1+1)+1 = 1+(1+1)`.
- **Notas:** `X = 2+X` tiene éxito en SWI-Prolog y crea un término cíclico, porque no hace prueba de ocurrencia. Con `unify_with_occurs_check/2` falla. El mismo documento también trae ejercicios de "aritmética y unificación" (`X is 2+3, X = 2+3`, `6 is X + 1, X = 5`, …).

### ES-UHU-2 — Predicados sencillos: natural, factorial, Fibonacci, menú
- **Fuente:** ídem, práctica "Predicados sencillos en Prolog", ejercicios 1 a 4.
- **Tema:** 2, 5, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `natural/1`, `factorial/2`, `fib/2` y, con platos clasificados en primero, segundo y postre con precio, un predicado que encuentre menús completos que cuesten menos de N.

### ES-UHU-3 — Aritmética de Peano y Fibonacci reversible
- **Fuente:** ídem, práctica "Predicados sencillos en Prolog", ejercicios 5 a 7.
- **Tema:** 3, 5
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con naturales `0`, `s(0)`, `s(s(0))`…, definir `suma/3`, `resta/3` y `producto/3`, y reescribir `fib(N,F)` con aritmética de Peano para que sea reversible: `fib(N, s(s(0)))` debe dar `N = s(s(s(0)))`.
- **Notas:** Muestra cómo lograr inversibilidad sin `is/2`; hay que cuidar el orden de los objetivos para que la búsqueda no diverja.

### ES-UHU-4 — Unificación de listas y predicados sobre listas
- **Fuente:** ídem, práctica "Predicados sobre listas en Prolog", ejercicios 1 y 2.
- **Tema:** 3, 5, 6
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Predecir el resultado de siete unificaciones de listas (`[X,Y|Z] = [a,b,c]`, `[X,Y,a] = [Z,b,Z]`, `[X,Y|Z] = [a,W]`, …). Luego definir insertar al comienzo, al final y en la posición N, concatenar (y con eso prefijo, sufijo y sublista), invertir, borrar, cambiar, palíndromo de longitud 2n y rotaciones.

### ES-UHU-5 — dividir, mezclar ordenado y ordenar
- **Fuente:** ídem, práctica "Predicados sobre listas en Prolog", ejercicios 3 a 5.
- **Tema:** 6, 7, 4
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `dividir(+N,+L,-May,-Men)`, `mezclar_ord(+L1,+L2,-R)` para dos listas ordenadas y `ordena(L,R)` de dos formas: probando permutaciones hasta encontrar la ordenada, y separando, ordenando y mezclando.
- **Notas:** El enunciado no dice qué hacer con los elementos iguales a N, y el ejemplo muestra `Menores = [1, 2, 3, 0]`, que no respeta el orden de la lista original `[3,1,2,5,0]`: conviene aclarar ambas cosas antes de resolver.

### ES-UHU-6 — Producto, producto escalar, divisores y permutaciones
- **Fuente:** ídem, práctica "Predicados sobre listas en Prolog", ejercicios 6 a 9.
- **Tema:** 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `prod(+L,?P)`, `pEscalar(+L1,+L2,-P)` (falla si las longitudes difieren), `divisores(+N,?L)` (lista creciente; `divisores(6,[2,3,6,1])` debe fallar) y `permuta(+L,-P)` (con repetidos se admiten permutaciones repetidas).

### ES-UHU-7 — Conjuntos y multiconjuntos
- **Fuente:** ídem, práctica "Predicados sobre listas en Prolog", ejercicios 10 y 11.
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Operaciones de conjuntos con listas sin repetidos (como ES-UNS-9) y, para multiconjuntos representados como listas de pares (elemento, multiplicidad), pertenencia y multiplicidad de un elemento.

### ES-UHU-8 — Árboles binarios, genéricos y de búsqueda
- **Fuente:** ídem, práctica "Árboles en Prolog".
- **Tema:** 3, 5, 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Para árboles binarios: contar nodos, internos y hojas, sumar nodos, pertenencia, iguales, simétricos, isomorfos, profundidad, balanceado y recorridos (inorden, preorden, postorden, anchura). Repetirlo para árboles genéricos `a(Et, ListaHijos)`. Para árboles binarios de búsqueda: crear vacío, insertar, altura, equilibrado, recorridos y construir el árbol desde una lista.
  ```prolog
  % ?- construir([3,2,5,7,1],T).
  % T = t(3,t(2,t(1,nil,nil),nil),t(5,nil,t(7,nil,nil)))
  ```

### ES-UHU-9 — Grafos: el sobre sin levantar el lápiz y caminos entre ciudades
- **Fuente:** ídem, práctica "Grafos en Prolog", ejercicios 1 a 3.
- **Tema:** 4, 5, 6, 7, 9
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dibujar "el sobre" recorriendo cada arco una sola vez. Con un grafo de carreteras españolas, encontrar todos los caminos entre Madrid y Oviedo con sus carreteras y distancias, y ver qué pasa al agregar arcos que forman ciclos. Para grafos G = (V, A), definir `camino/4`, `distancia/4` (con y sin ciclos), `ciclos/2`, `conexo/1`, `grado/3`, `listagrados/2` y `pintargrafo/3`.
- **Notas:** El grafo de ciudades está en una figura del PDF. El "¿qué ocurriría si hubiera ciclos?" lleva a la lista de visitados.

### Universidad de Valladolid (UVa)

Documento: "Práctica I. Prolog I: Elementos básicos de Prolog", Ingeniería del
Conocimiento, Grado en Informática, Universidad de Valladolid (transparencias).
URL: https://www.infor.uva.es/~calonso/Ingenieria%20Conocimiento-Grado%20Informatica/Practicas/Practica%20I%20Prolog.pdf
Licencia: no declarada. Sin soluciones.

### ES-UVA-1 — Tu propia familia
- **Fuente:** UVa, "Práctica I. Prolog I", ejercicio 1. https://www.infor.uva.es/~calonso/Ingenieria%20Conocimiento-Grado%20Informatica/Practicas/Practica%20I%20Prolog.pdf
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Describir la propia familia con hechos `hombre/1`, `mujer/1` y `es_hijo_de/2`, y reglas para abuelo/a, padre/madre y hermano/a, sin usar operadores en las reglas. Consultar `hermano(X,Y)` y analizar el resultado.
- **Notas:** "Sin operadores" impide usar `\=`, así que con la definición obvia cada persona sale hermana de sí misma: es muy probablemente lo que la consulta pide analizar.

### ES-UVA-2 — Signo del zodiaco
- **Fuente:** ídem, ejercicio 2.
- **Tema:** 2, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con hechos `horoscopo(Signo, DiaIni, MesIni, DiaFin, MesFin)`, escribir dos reglas que calculen `signo(Dia, Mes, Signo)`.
- **Notas:** Son dos reglas porque el día puede caer en el mes de inicio o en el de fin del signo.

### ES-UVA-3 — es_lista, longitud e inventario de la bicicleta
- **Fuente:** ídem, ejercicios 3 y 4.
- **Tema:** 5, 6
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `es_lista/1` y `longitud/2` sin predefinidos. Con `pieza_basica/1` y `ensamblaje(Parte, ListaDePartes)` para una bicicleta, definir `piezas_de/2`, que da la lista de piezas básicas necesarias para una parte o para toda la bicicleta.
  ```prolog
  pieza_basica(cadena).
  ensamblaje(bicicleta, [rueda_delantera, cuadro, rueda_trasera]).
  ```
- **Notas:** Recursión sobre un árbol representado con listas (recursión doble: sobre la parte y sobre la lista).

### ES-UVA-4 — Corte: doble escalón, borrar, añadir sin duplicar
- **Fuente:** ídem, ejercicios 5 a 8.
- **Tema:** 6, 8
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Implementar con corte la función escalón (0 si X < 3, 2 si 3 ≤ X < 6, 4 si X > 6), `borrar_primera/3`, `borrar_todas/3` y `añadir_sin_duplicar/3`.
- **Notas:** El enunciado deja sin definir el caso X = 6: buena ocasión para discutirlo. Es la misma función que ES-US-23.

### Universidad de Oviedo (José E. Labra)

Documento: Jose E. Labra G., *Programación Práctica en Prolog*, Área de Lenguajes y
Sistemas Informáticos, Universidad de Oviedo, octubre de 1998, sección 9 "Ejercicios
Propuestos". Copia alojada por la Universidad de Pamplona (Colombia).
URL: https://www.unipamplona.edu.co/unipamplona/portalIG/home_23/recursos/general/06052011/practica1_prolog.pdf
Licencia: no declarada. Sin soluciones para los ejercicios propuestos (el cuerpo del
apunte sí trae ejemplos resueltos).

### ES-UNIOVI-1 — Listas numéricas: cambia, sucesión, diferentes
- **Fuente:** Labra, *Programación Práctica en Prolog* (1998), sección 9, ejercicios 1 a 3. https://www.unipamplona.edu.co/unipamplona/portalIG/home_23/recursos/general/06052011/practica1_prolog.pdf
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `cambia(Xs,Ys)` (a cada elemento le suma la suma de toda la lista: `[1,3,2]` da `[7,9,8]`), `sucesion(N,Xs)` con x1 = 0, x2 = 1 y x(i+2) = 2·x(i) + x(i+1), y `diferentes(Xs,N)`, la cantidad de elementos distintos.

### ES-UNIOVI-2 — ¿Qué responde este programa con corte?
- **Fuente:** ídem, ejercicio 4.
- **Tema:** 4, 8
- **Dificultad:** 2
- **Solución:** verificada: `a(1,X)` da `2` y `3`; `a(2,X)` da `3`; `a(3,X)` da `4` y `5`.
- **SWISH:** sí
- **Enunciado:** Dado el programa de abajo, indicar todas las respuestas (por backtracking) de `a(1,X)`, `a(2,X)` y `a(3,X)`.
  ```prolog
  a(X,Y):-b(X,Y).        a(X,Y):-c(X,Y).
  b(X,Y):-d(X),!,e(X,Y). b(X,Y):-f(X,Y).
  c(1,2). c(1,3). d(1). d(2). e(2,3). f(3,4). f(3,5).
  ```
- **Notas:** En `a(1,X)`, el corte hace fallar a `b/2` entero (no se prueba `f/2`), pero `a/2` sigue con su segunda cláusula: el corte es local al predicado donde aparece.

### ES-UNIOVI-3 — Número desde dígitos, montes, cambio de monedas, binario
- **Fuente:** ídem, ejercicios 5 a 8 y 12.
- **Tema:** 5, 6, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir `rep(Xs,V)` (`[1,4,6]` da 146), `monte(Xs)` (creciente hasta un elemento y decreciente después), `cambio(X,Xs)` (monedas de 1, 5, 25 y 100 para una cantidad) y `decBin(D,B)`, que además debe funcionar al revés: `decBin(V,[1,0,1,1])` da `V = 13`.

### ES-UNIOVI-4 — Combinaciones, variaciones con repetición y triángulos
- **Fuente:** ídem, ejercicios 9 a 11, 13 y 16.
- **Tema:** 4, 6, 7, 9
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Generar por backtracking las combinaciones de un elemento de cada sublista (`[[1,2,3],[4,5],[6]]` da `[1,4,6]`, `[1,5,6]`, …) y sumar sus representaciones decimales (`sumCombs` da 1506); calcular las variaciones con repetición `varsRep(N,Xs,Vs)`; e imprimir un triángulo de asteriscos y el triángulo de Tartaglia.
- **Notas:** Los ejercicios de impresión usan `write/1` y `nl/0`, que el curso no cubre en detalle.

### ES-UNIOVI-5 — Proyectos: derivadas simbólicas, polinomios, calculadora interactiva
- **Fuente:** ídem, ejercicios 14, 15 y 17 a 23.
- **Tema:** X, 3, 10
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** parcial (la calculadora interactiva necesita leer de la entrada estándar)
- **Enunciado:** Proyectos largos: contar palabras de un texto, buscar con expresiones regulares simples, derivar y simplificar expresiones simbólicas, operar con polinomios, finales de ajedrez, reconocimiento de letras, coloreado de mapas y un intérprete interactivo con variables (`x = 3*2 + 4*(6+2).`, `x + 1.`).
- **Notas:** Las derivadas simbólicas son un gran ejercicio de unificación sobre términos aritméticos. Los que tratan texto asumen que `"..."` es una lista de códigos, lo que en SWI-Prolog 7 y posteriores ya no es así.

### Universitat Jaume I (UJI), Castellón

Documento: Francisco Toledo Lobo, Julio Pacheco Aparicio y M. Teresa Escrig Monferrer,
*El Lenguaje de Programación PROLOG*, Universitat Jaume I, septiembre de 2000. El Apéndice A
trae soluciones de ejercicios de los capítulos 1 a 8.
URL (copia de terceros, no de los autores): http://mural.uv.es/mijuanlo/PracticasPROLOG.pdf
Licencia: © de los autores; no se encontró una copia oficial ni una licencia. Solo citar
y enlazar.
Dialecto: ECLiPSe (el libro lo elige explícitamente). Las soluciones escriben
`not objetivo` como operador prefijo, lo que en SWI-Prolog da error de sintaxis
(verificado): hay que escribir `not(objetivo)` o `\+ objetivo`. El capítulo 5 usa además
`lib(db)` y `retr_tup/1`, que son de ECLiPSe.

### ES-UJI-1 — Familia: preguntas, reglas y árboles de deducción
- **Fuente:** Toledo, Pacheco y Escrig, *El Lenguaje de Programación PROLOG* (UJI, 2000), cap. 1, ejercicios 1.1 a 1.4 y 1.9. http://mural.uv.es/mijuanlo/PracticasPROLOG.pdf
- **Tema:** 1, 2, 4, 5
- **Dificultad:** 1
- **Solución:** en el libro (Apéndice A)
- **SWISH:** sí
- **Enunciado:** Con la base familiar del ejemplo 1.1 (`progenitor/2`), dar la respuesta y la lectura en castellano de varias consultas, formular preguntas (¿quién es el abuelo de Isabel?), definir `es_madre/1`, `es_padre/1`, `es_hijo/1` y los sucesores de una persona, y construir el árbol de deducción de `tia(isabel,ana)` y `tia(clara,ana)`.
- **Notas:** El 1.3 aclara por qué un hecho con variable (`hombre(X).`) sería verdadero para cualquier objeto.

### ES-UJI-2 — Unificación geométrica: triángulos, segmentos, rectángulos
- **Fuente:** ídem, ejercicios 1.5 a 1.7.
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** en el libro
- **SWISH:** sí
- **Enunciado:** Decidir si unifica `triangulo(punto(-1,0),P2,P3) = triangulo(P1,punto(1,0),punto(0,Y))` y qué familia de triángulos describe; representar cualquier segmento vertical con X = 5; definir `regular(R)` para rectángulos con lados horizontales y verticales.

### ES-UJI-3 — Contar de a tres con s/1
- **Fuente:** ídem, ejercicio 1.8.
- **Tema:** 3, 4, 5
- **Dificultad:** 2
- **Solución:** en el libro
- **SWISH:** sí
- **Enunciado:** Predecir las respuestas de `f(s(1),A)`, `f(s(s(1)),dos)`, `f(s(s(s(s(s(s(1)))))),C)` y `f(D,tres)` para el programa:
  ```prolog
  f(1,uno). f(s(1),dos). f(s(s(1)),tres).
  f(s(s(s(X))),N) :- f(X,N).
  ```
- **Notas:** `f(D,tres)` genera infinitas respuestas (verificado: `s(s(1))`, `s(s(s(s(s(1)))))`, `s(s(s(s(s(s(s(s(1))))))))`, …).

### ES-UJI-4 — Cuatro órdenes de predecesor
- **Fuente:** ídem, ejercicio 1.10.
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** en el libro
- **SWISH:** sí
- **Enunciado:** Construir el árbol de resolución de `predecesor(clara,patricia)` para cuatro definiciones que solo difieren en el orden de las cláusulas y de los objetivos (caso base primero o último, llamada recursiva a la izquierda o a la derecha).
- **Notas:** Es el ejemplo clásico de Bratko: la versión con recursión a la izquierda (`predecesor(Z,Y), progenitor(X,Z)`) no termina en algunos casos.

### ES-UJI-5 — Listas con concatenar y más
- **Fuente:** ídem, cap. 2, ejercicios 2.1 a 2.14.
- **Tema:** 5, 6, 7
- **Dificultad:** 1
- **Solución:** en el libro
- **SWISH:** sí
- **Enunciado:** Usar `concatenar` para descomponer listas, borrar lo que sigue a `z,z,z` y borrar los tres últimos; borrar y añadir elementos; consecutivos; palíndromo; subconjunto; `par/1` e `impar/1`; `shift/2`; traducir números a nombres; permutaciones; contar positivos y negativos; separar posiciones pares e impares; mínimo y máximo; contar apariciones.

### ES-UJI-6 — Corte: p(1). p(2):-!. p(3).
- **Fuente:** ídem, cap. 3, ejercicio 3.6.
- **Tema:** 4, 8
- **Dificultad:** 2
- **Solución:** en el libro; verificada: `p(X)` da 1 y 2; `p(X), p(Y)` da 1-1, 1-2, 2-1, 2-2; `p(X), !, p(Y)` da 1-1 y 1-2.
- **SWISH:** sí
- **Enunciado:** Escribir las respuestas de `p(X)`, `p(X), p(Y)` y `p(X), !, p(Y)` para el programa `p(1). p(2) :- !. p(3).`
- **Notas:** Ejercicio mínimo y muy claro sobre el alcance del corte.

### ES-UJI-7 — Corte y negación: conjuntos, clasificar números, frases, expresiones lógicas
- **Fuente:** ídem, cap. 3, ejercicios 3.1 a 3.5 y 3.7 a 3.12.
- **Tema:** 6, 8
- **Dificultad:** 2
- **Solución:** en el libro
- **SWISH:** sí
- **Enunciado:** Intersección, unión y diferencia de conjuntos; aplanar listas; transformar frases con una tabla `cambiar/2` ("tu eres un ordenador" → "yo no soy un ordenador"); un `miembro` que encuentre solo la primera ocurrencia; hacer más eficiente `clase/2` (positivo, cero, negativo); dividir en positivos y negativos con corte; evaluar listas como `[not,not,not,0,and,1,and,1,and,not,0]`; sublistas "desde", unión ordenada y sublista entre dos nombres.
- **Notas:** El ejercicio 3.3 es una versión mínima de ELIZA. Su cláusula "recogetodo" `cambiar(X,X)` hace que, sin corte, al pedir más respuestas aparezcan frases con palabras sin cambiar.

### ES-UJI-8 — Búsqueda con predicados predefinidos y gensym
- **Fuente:** ídem, cap. 4, ejercicios 4.2 a 4.5.
- **Tema:** 4, 6, 10
- **Dificultad:** 3
- **Solución:** en el libro
- **SWISH:** sí
- **Enunciado:** Búsqueda primero en anchura, camino por las calles de una cuadrícula, buscar el teléfono en un palacio sin pasar dos veces por la misma habitación, y un `gensim/2` que genere átomos nuevos (`estudiante1`, `estudiante2`, …).
- **Notas:** `gensim` requiere un contador en la base dinámica (`assert`/`retract`). SWI ya trae `gensym/2`.

### ES-UJI-9 — Suministradores y partes: álgebra relacional en Prolog
- **Fuente:** ídem, cap. 5 "Programación lógica y Bases de Datos", ejercicio 5.1 (y 5.3).
- **Tema:** 11, 9, 8
- **Dificultad:** 2
- **Solución:** en el libro (usa `findall` y `not` prefijo); verificada con consultas propias equivalentes: (a) partes rojas: `juan`; (b) no suministran p2: `luis`; (c) suministran todo lo de s2: `juan`; (e) partes suministradas por todos: ninguna (s5, luis, no suministra nada); (g) totales: juan 2000, maria 900, pedro 700, raquel 200, luis 0.
- **SWISH:** sí (el 5.3 no: pide `lib(db)` de ECLiPSe)
- **Enunciado:** Con las tablas `sumin(Scodigo,Snombre,Estado,Ciudad)`, `partes(Pcodigo,Pnombre,Color,Peso,Ciudad)` y `s_p(Scodigo,Pcodigo,Cantidad)`, resolver nueve consultas: suministradores de alguna parte roja, que no suministran p2, que suministran todo lo que suministra s2, que solo suministran partes de Castellón, partes suministradas por todos, suministradores "al por mayor", totales por suministrador, media de totales y quiénes superan la media.
  ```prolog
  sumin(s1,juan,20,madrid).  partes(p1,mesa,verde,20,castellon).
  s_p(s1,p1,300).
  ```
- **Notas:** El mejor ejercicio encontrado para el tema 11: el capítulo explica antes selección, proyección, unión, diferencia, producto, reunión y división del álgebra relacional, y su traducción a Prolog. La división ("todos") se escribe con `forall/2`, y las consultas con negación ("no suministran p2") con `\+`.

### ES-UJI-10 — Base de datos de familias con estructuras anidadas
- **Fuente:** ídem, cap. 5, ejercicio 5.2.
- **Tema:** 3, 9, 11
- **Dificultad:** 2
- **Solución:** en el libro
- **SWISH:** sí
- **Enunciado:** Con una única relación `familia(Padre, Madre, ListaDeHijos)` cuyos miembros son `persona(Nombre, Ap1, Ap2, fecha(D,M,A), trabaja(Compania,Salario) | desempleado)`, escribir consultas sobre la base.
- **Notas:** Muy parecido a ES-US-18: contrasta una tabla plana con un término anidado.

### ES-UJI-11 — Gramáticas y análisis de oraciones
- **Fuente:** ídem, cap. 6, ejercicios 6.1 a 6.7.
- **Tema:** A
- **Dificultad:** 2
- **Solución:** en el libro
- **SWISH:** sí
- **Enunciado:** Probar la gramática del ejemplo con otras frases, resolver la concordancia de número, devolver el árbol sintáctico (`oracion(S,[el,hombre,come,la,manzana],[])`), analizar "Juan ama a María" y "todo hombre que vive ama a una mujer", un diálogo "X es un(a) Y" / "¿Es X un(a) Y?", voz pasiva y oraciones de agenda de oficina.

### ES-UJI-12 — Compilador reducido de Pascal
- **Fuente:** ídem, cap. 6, ejercicios 6.8 y 6.9.
- **Tema:** A, X
- **Dificultad:** 3
- **Solución:** en el libro
- **SWISH:** sí
- **Enunciado:** Modificar el generador de código del capítulo para que produzca una lista aplanada de instrucciones usando listas diferenciadas, y agregar `if…then…else`.

### ES-UJI-13 — Sistemas expertos: animales, préstamos, sanciones
- **Fuente:** ídem, cap. 7, ejercicios 7.1 a 7.7.
- **Tema:** X, 10
- **Dificultad:** 3
- **Solución:** en el libro
- **SWISH:** parcial (los que preguntan al usuario necesitan entrada interactiva)
- **Enunciado:** Encadenamiento hacia adelante y hacia atrás, generación de explicaciones e incertidumbre para el ejemplo de averías de agua; un sistema experto que identifica siete animales; y el diseño de dos sistemas de decisión (conceder un préstamo, sancionar a un médico).

### ES-UJI-14 — Problemas de restricciones: reinas, parejas de baile, muebles, regalos, crucigrama
- **Fuente:** ídem, cap. 8, ejercicios 8.1 a 8.12.
- **Tema:** X
- **Dificultad:** 3
- **Solución:** en el libro (CLP(FD) de ECLiPSe)
- **SWISH:** sí, adaptando a `library(clpfd)`
- **Enunciado:** Doce problemas de satisfacción de restricciones: 8 reinas, parejas de baile, distribución de muebles, reparto de regalos entre personas incompatibles, pintar paredes, reparto de piezas, colorear matrices, asignar despachos, planificar tareas, figuras en una caja y un crucigrama.
- **Notas:** También se pueden resolver con generar y testear puro (sin CLP), con matrices pequeñas.

### Universidad de Córdoba (UCO)

Documento: "Tema 8. Introducción al lenguaje Prolog", Programación Declarativa,
Ingeniería Informática, Escuela Politécnica Superior, Universidad de Córdoba, curso
2019-2020 (transparencias).
URL: http://www.uco.es/users/ma1fegan/2019-2020/pd/temas/Tema-8/PD-Tema-8.-Introduccion-al-lenguaje-Prolog.pdf
Licencia: no declarada.

### ES-UCO-1 — Familia y donantes de sangre
- **Fuente:** UCO, Programación Declarativa, "Tema 8. Introducción al lenguaje Prolog", sección 6 (reglas). http://www.uco.es/users/ma1fegan/2019-2020/pd/temas/Tema-8/PD-Tema-8.-Introduccion-al-lenguaje-Prolog.pdf
- **Tema:** 2, 5
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Definir sobre la base familiar del tema las relaciones abuelo/a, nieto/a y primos/as, y resolver el "ejercicio de los donantes de sangre".
- **Notas:** La transparencia solo nombra los ejercicios; el enunciado de los donantes no está en el PDF (se presenta en clase). Útil solo como lista de ideas.

### Universidad de Almería (UAL)

Documento: "Transparencias de Programación Lógica y Funcional" (2005), grupo indalog,
Universidad de Almería.
URL: http://indalog.ual.es/WWW/prolog2005.pdf
Licencia: no declarada.

### ES-UAL-1 — Familia: nieto, tía, primo hermano, abuela paterna, bisabuelo
- **Fuente:** UAL, "Transparencias de Programación Lógica y Funcional" (2005), "Programación Lógica. Ejercicios". http://indalog.ual.es/WWW/prolog2005.pdf
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con `ascendente/2` y `mujer/1` de las transparencias, definir `nieto`, `tía`, `primo hermano`, `abuela paterna` y `bisabuelo`.

### ES-UAL-2 — Horario de cursos: ocupado, conflictos de programación
- **Fuente:** ídem, "Prolog. Términos Prolog. Ejercicios".
- **Tema:** 3, 7
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Con hechos `curso(Curso, horario(Dia,Inicio,Fin), Profesor, Lugar)`, definir `lugar(Curso,Edificio)`, `ocupado(Profesor,Hora)`, `no_pueden_reunirse(Prof1,Prof2)` y `conflicto_programación(Hora,Lugar,Curso1,Curso2)`.
- **Notas:** Las transparencias escriben `Inicio<=Hora`, que no es un operador de Prolog: es `=<`. Buena trampa para señalar.

## Latinoamérica

### Universidad Autónoma Metropolitana (UAM Azcapotzalco, México) — tutorial de Ángel Fernández Pineda

Documento: "Tutorial básico de programación en Prolog", Ángel Fernández Pineda, alojado
en el sitio de un curso de la UAM Azcapotzalco.
URL: https://academicos.azc.uam.mx/cbr/Cursos/UEA_12p_Log/TutorialdePrologEspa.pdf
Licencia: el propio documento dice que el autor solo cede el derecho de distribución
íntegra y sin fines de lucro, y **prohíbe expresamente incluir la obra, total o
parcialmente, en otra obra**. Por eso aquí solo se describen los ejercicios, sin
reproducir texto ni código.

### ES-UAM-1 — ¿Variable, término o mal construido?
- **Fuente:** Fernández Pineda, "Tutorial básico de programación en Prolog", sección "Resumen y ejercicios", "Ejercicios sobre términos y variables". https://academicos.azc.uam.mx/cbr/Cursos/UEA_12p_Log/TutorialdePrologEspa.pdf
- **Tema:** 1, 3
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Clasificar diez expresiones como variables, términos o expresiones mal construidas.
- **Notas:** Varias exploran casos límite de la sintaxis (functor con mayúscula, variable que empieza con `_`, átomos entre comillas).

### ES-UAM-2 — ¿Unifican estos pares de términos?
- **Fuente:** ídem, "Ejercicios sobre unificación".
- **Tema:** 3
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Decidir si unifican seis pares de términos, algunos con estructuras anidadas de varios niveles, y dar las ligaduras. Luego ejecutar en el intérprete secuencias de `=/2` y observar cómo se propagan las ligaduras entre variables.
- **Notas:** Dos pares casi iguales se distinguen solo por la aridad de un subtérmino: uno falla por eso y el otro unifica.

### ES-UAM-3 — Traza de una conjunción y modos de uso
- **Fuente:** ídem, "Ejercicios sobre predicados".
- **Tema:** 4, 7, 2
- **Dificultad:** 2
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Dadas las soluciones de tres predicados, indicar los pasos de ejecución de una conjunción de los tres; definir un predicado que sume dos e indicar sus modos de uso permitidos; y agregar `tio/2` al árbol genealógico de ejemplo.

### Universidad Nacional de Colombia (UNAL) — sitio "Paradigmas de Programación" (ferestrepoca)

Sitio: https://ferestrepoca.github.io/paradigmas-de-programacion/proglogica/ (tutoriales
de estudiantes, 2017 a 2026) y un cuaderno SWISH público "Paradigma Programacion Logica".
Repositorio: https://github.com/ferestrepoca/paradigmas-de-programacion (sin licencia
declarada). El material es de ejemplos, no de ejercicios: se incluye porque el cuaderno
SWISH en español sirve para practicar en clase.

### ES-UNAL-1 — Cuaderno SWISH: grafo, Fibonacci, oraciones, familia
- **Fuente:** UNAL, "Paradigmas de Programación – Programación lógica", cuaderno SWISH "Paradigma Programacion Logica". https://swish.swi-prolog.org/p/Paradigma%20Programacion%20Logica.swinb (enlazado desde https://ferestrepoca.github.io/paradigmas-de-programacion/proglogica/logica_teoria/lenguaje.html)
- **Tema:** 0, 1, 5, 6, A
- **Dificultad:** 1
- **Solución:** sí (es un cuaderno de ejemplos resueltos)
- **SWISH:** sí (es un cuaderno SWISH)
- **Enunciado:** Seis ejemplos para ejecutar y modificar: `mortal/humano`, caminos en un grafo dirigido (`path/2` y `pathall/3` con la lista de nodos), Fibonacci, un ahorcado con `read/1`, un analizador de oraciones con `append/3` y una base familiar bíblica.
- **Notas:** Sirve para un ejercicio de depuración: el `fib/2` del cuaderno no tiene guarda (`X > 1`), así que al pedir otra respuesta con `;` después de `fib(6,X)` baja a números negativos y no termina. El analizador de oraciones es un buen punto de partida para pasar a DCG.

### ES-UNAL-2 — Preguntas sobre un programa de científicos
- **Fuente:** UNAL, tutorial "Prolog" (estudiantes). https://ferestrepoca.github.io/paradigmas-de-programacion/proglogica/tutoriales/prolog-gh-pages/Prolog.pdf
- **Tema:** 1, 2, 8
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Sobre una base de científicos, el tutorial pregunta por qué una consulta sobre Feynman (que es físico) no da verdadero, y qué pasa si se elimina la comparación en la regla `odia`.
- **Notas:** Son preguntas sueltas dentro de un tutorial, no una guía.

### Universidad de Pamplona (Colombia)

Documento: "Práctica No. 6. Ejercicios en Prolog", Universidad de Pamplona.
URL: https://www.unipamplona.edu.co/unipamplona/portalIG/home_23/recursos/general/28062012/practicaprologup_familiarespl.pdf
Licencia: no declarada.

### ES-UPAMPLONA-1 — Una bonita familia (familiares.pl)
- **Fuente:** Universidad de Pamplona, "Práctica No. 6. Ejercicios en Prolog", actividades. https://www.unipamplona.edu.co/unipamplona/portalIG/home_23/recursos/general/28062012/practicaprologup_familiarespl.pdf
- **Tema:** 0, 1, 2
- **Dificultad:** 1
- **Solución:** no
- **SWISH:** sí
- **Enunciado:** Capturar `familiares.pl` (hechos `varon/1`, `mujer/1`, `padres(Hijo, Padre, Madre)`, `esposos/2` y reglas `hermana`, `hermano`, `hijo`, `hija`), traducir a consultas cinco preguntas (¿Eduardo y Alicia son hermanos? ¿De quién es hija Beatriz?…), definir nieto/a y abuelo/a, volver a consultar, y definir al menos dos de sobrino, sobrina, cuñado o cuñada.
- **Notas:** `padres/3` (hijo, padre y madre en un solo hecho) es una representación distinta de `progenitor/2`: sirve para comparar ambas. Las reglas `hermana`/`hermano` del archivo no excluyen a la propia persona: cada una sale hermana de sí misma.
