# Learn Prolog Now! (Blackburn, Bos, Striegnitz)

- **Fuente:** Patrick Blackburn, Johan Bos, Kristina Striegnitz, *Learn Prolog Now!*, versión en línea (el libro impreso es de College Publications, Texts in Computing vol. 7, 2006). Cada capítulo cierra con una sección "Exercises" y otra "Practical Session".
- **URL:** https://www.let.rug.nl/bos/lpn/ (sitio original) y https://lpn.swi-prolog.org/ (versión con botones para abrir los ejemplos en SWISH). Índice: https://lpn.swi-prolog.org/lpnpage.php?pageid=online
- **Licencia:** "© 2006-2012 Patrick Blackburn, Johan Bos, Kristina Striegnitz". Lectura gratuita en línea, **sin licencia abierta** en ninguna de las dos copias. Por eso los enunciados están parafraseados y resumidos en castellano; el texto completo está en las URL de cada entrada. Hay que atribuir y enlazar; no copiar el texto original.
- **Soluciones oficiales:** **no hay** en el sitio. Las soluciones cortas de abajo son propias y se verificaron con SWI-Prolog 9.2.9.
- **Mirror roto:** en lpn.swi-prolog.org las secciones 8.4 (`lpn-htmlse35`) y 9.5 (`lpn-htmlse41`) devuelven un error de PHP ("Failed to open stream"). Para esas dos se enlaza la copia de let.rug.nl, que funciona.
- **Nota general sobre SWI-Prolog 7+:** el libro es anterior a SWI-Prolog 7. Las respuestas `yes`/`no` hoy se ven como `true`/`false`, y las listas ya no se construyen con `'.'/2` sino con `'[|]'/2` (esto afecta al ejercicio 9.2).
- **Total:** 87 entradas (50 ejercicios de las secciones "Exercises" y 37 consignas de las "Practical Session"). Por dificultad: 1: 51, 2: 31, 3: 5.

**Cantidad por tema** (una entrada puede tener más de un tema):

| Tema | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | A | X |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Entradas | 7 | 4 | 4 | 22 | 12 | 16 | 30 | 8 | 8 | 2 | 3 | 0 | 13 | 3 |

---

## Capítulo 1: Facts, Rules, and Queries

### LPN-1.1 — ¿Átomo, variable o ninguno?
- **Fuente:** Blackburn, Bos, Striegnitz, §1.3 Exercises, Ejercicio 1.1. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse3
- **Tema:** 1, 3
- **Dificultad:** 1
- **Solución:** propia, verificada: átomos: `vINCENT`, `variable23`, `big_kahuna_burger`, `'big kahuna burger'`, `'Jules'`, `'_Jules'`. Variables: `Footmassage`, `Variable2000`, `_Jules`. Ninguna de las dos: `big kahuna burger` sin comillas (son tres átomos seguidos, no un término).
- **SWISH:** sí
- **Enunciado:** Clasificar diez cadenas (por ejemplo `vINCENT`, `Footmassage`, `'big kahuna burger'`, `_Jules`) en átomos, variables o ninguna de las dos.
- **Notas:** Se comprueba con `atom/1` y `var/1`, por ejemplo `?- atom('_Jules').`. La regla que se fija es que la primera letra decide: minúscula significa átomo, mayúscula o `_` significa variable, y las comillas simples siempre dan un átomo.

### LPN-1.2 — Clasificar términos y dar functor/aridad
- **Fuente:** §1.3, Ejercicio 1.2. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse3
- **Tema:** 1, 3
- **Dificultad:** 1
- **Solución:** propia: `loves(Vincent,mia)` es un compuesto `loves/2`; `'loves(Vincent,mia)'` es un átomo; `Butch(boxer)` no es un término (el functor no puede ser una variable); `boxer(Butch)` es `boxer/1`; `and(big(burger),kahuna(burger))` y `and(big(X),kahuna(X))` son `and/2`; `_and(big(X),kahuna(X))` no es un término; `(Butch kills Vincent)` y `kills(Butch Vincent)` tampoco (no hay operadores definidos); `kills(Butch,Vincent` no lo es porque le falta el paréntesis.
- **SWISH:** sí
- **Enunciado:** Para diez expresiones, decir si son átomo, variable, término compuesto o nada; para los compuestos, dar functor y aridad.
- **Notas:** `functor/3` confirma las respuestas: `?- functor(and(big(X),kahuna(X)), F, A).`

### LPN-1.3 — Contar hechos, reglas, cláusulas y predicados
- **Fuente:** §1.3, Ejercicio 1.3. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse3
- **Tema:** 2
- **Dificultad:** 1
- **Solución:** propia: 3 hechos, 4 reglas, 7 cláusulas, 5 predicados (`woman/1`, `man/1`, `person/1`, `loves/2`, `father/2`). Cabezas: `person(X)`, `loves(X,Y)`, `father(Y,Z)` (dos veces). Metas: `man(X)`, `woman(X)`, `father(X,Y)`, `man(Y)`, `son(Z,Y)`, `daughter(Z,Y)`.
- **SWISH:** sí
- **Enunciado:** Dada una base de 7 cláusulas, contar hechos, reglas, cláusulas y predicados, e identificar las cabezas y las metas de cada regla.
  ```prolog
  woman(vincent).  woman(mia).  man(jules).
  person(X) :- man(X); woman(X).
  loves(X,Y) :- father(X,Y).
  father(Y,Z) :- man(Y), son(Z,Y).
  father(Y,Z) :- man(Y), daughter(Z,Y).
  ```
- **Notas:** Un predicado se identifica por nombre **y** aridad. `son/2` y `daughter/2` se usan pero no están definidos: si se consulta `father(X,Y)` en SWI-Prolog, da un error de procedimiento desconocido.

### LPN-1.4 — Traducir oraciones a Prolog
- **Fuente:** §1.3, Ejercicio 1.4. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse3
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** propia: `killer(butch).`, `married(mia,marsellus).`, `dead(zed).`, `kills(marsellus,X) :- gives_footmassage(X,mia).`, `loves(mia,X) :- good_dancer(X).`, `eats(jules,X) :- nutritious(X) ; tasty(X).`
- **SWISH:** sí
- **Enunciado:** Escribir en Prolog seis oraciones: tres son hechos ("Butch es un asesino", "Zed está muerto") y tres son reglas con variables ("Mia ama a todo el que baila bien", "Jules come todo lo que es nutritivo o sabroso").
- **Notas:** El "todo el que" se traduce con una variable en la cabeza de la regla, y el "o" con `;` o con dos cláusulas.

### LPN-1.5 — Predecir respuestas en la base de Harry Potter
- **Fuente:** §1.3, Ejercicio 1.5. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse3
- **Tema:** 2, 4
- **Dificultad:** 1
- **Solución:** verificada: `wizard(ron)` da true; `wizard(hermione)` da false; `wizard(harry)` da true; `wizard(Y)` da `Y = ron ; Y = harry`. Las consultas con `witch/1` dan un **error** de procedimiento desconocido en SWI-Prolog, no `no`.
- **SWISH:** sí
- **Enunciado:** Con la base de abajo, predecir la respuesta de Prolog a siete consultas sobre `wizard/1` y `witch/1`.
  ```prolog
  wizard(ron).
  hasWand(harry).
  quidditchPlayer(harry).
  wizard(X) :- hasBroom(X), hasWand(X).
  hasBroom(X) :- quidditchPlayer(X).
  ```
- **Notas:** Sirve para ver la diferencia entre "falso" y "predicado inexistente" (`existence_error`). Al cargar la base, SWI-Prolog avisa que las cláusulas de `wizard/1` no están juntas ("not together in the source-file"). Es un aviso y no un error, y se evita agrupando las cláusulas o declarando `:- discontiguous wizard/1.`

### LPN-PS1.1 — Cargar una base y usar `listing`
- **Fuente:** §1.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse4
- **Tema:** 0
- **Dificultad:** 1
- **Solución:** no corresponde (práctica de entorno).
- **SWISH:** parcial (en SWISH el programa se escribe en el panel izquierdo y no se hace `consult`; `listing/1` sí funciona).
- **Enunciado:** Guardar la base KB2 en `kb2.pl`, arrancar Prolog, cargarla con `?- [kb2].` y ver su contenido con `listing.` y `listing(playsAirGuitar).`. Si el archivo no está en el directorio actual, cargarlo con su ruta completa entre comillas simples. Salir con `halt.`
- **Notas:** En Windows conviene usar `/` en las rutas (`'c:/Users/.../kb2.pl'`). En SWI-Prolog, `listing.` sin argumentos también muestra predicados de librerías, así que es mejor usar `listing/1`.

### LPN-PS1.2 — Jugar con las bases del capítulo y crear una propia
- **Fuente:** §1.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse4
- **Tema:** 1, 2
- **Dificultad:** 1
- **Solución:** no corresponde.
- **SWISH:** sí
- **Enunciado:** Cargar las bases KB1 a KB5 del capítulo y reproducir las consultas del texto. Entender por qué KB5 genera relaciones de celos "raras" (alguien celoso de sí mismo), comprobar las respuestas del ejercicio 1.5 y armar una base propia sobre un tema cualquiera.
- **Notas:** El caso de los celos reaparece en LPN-10.5, que lo corrige con `\==`.

## Capítulo 2: Unification and Proof Search

### LPN-2.1 — ¿Unifican estos pares?
- **Fuente:** §2.3 Exercises, Ejercicio 2.1. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse7
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** autoverificable con `=/2` en el intérprete (ver LPN-PS2.1). Los dos casos engañosos son `food(X) = X`, que en SWI-Prolog tiene éxito y crea un término cíclico porque no hay *occurs check*, y `meal(food(bread),X) = meal(X,drink(beer))`, que falla.
- **SWISH:** sí
- **Enunciado:** Decir cuáles de 14 pares de términos unifican (por ejemplo `'Bread' = bread`, `food(bread,X,beer) = food(Y,sausage,X)`) y con qué ligaduras.

### LPN-2.2 — Consultas sobre `magic/1` y árbol de búsqueda
- **Fuente:** §2.3, Ejercicio 2.2. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse7
- **Tema:** 4
- **Dificultad:** 2
- **Solución:** verificada: en SWI-Prolog, `magic(house_elf)` y `magic(wizard)` dan **error** (no false), porque la segunda cláusula llama a `wizard/1`, que no existe; `wizard(harry)` también da error. `magic(Hermione)` da `dobby` y después se corta con el mismo error al probar la segunda cláusula. Si se agrega `:- dynamic wizard/1.`, las respuestas son las del libro: `dobby`, `hermione`, `'McGonagall'`, `rita_skeeter`.
- **SWISH:** sí
- **Enunciado:** Con la base de abajo, decir qué consultas tienen éxito y con qué valores, y dibujar el árbol de búsqueda de `magic(Hermione)`.
  ```prolog
  house_elf(dobby).
  witch(hermione).  witch('McGonagall').  witch(rita_skeeter).
  magic(X) :- house_elf(X).
  magic(X) :- wizard(X).
  magic(X) :- witch(X).
  ```
- **Notas:** `Hermione` con mayúscula es una **variable**. Conviene discutir el error por predicado inexistente, que el libro no contempla.

### LPN-2.3 — Oraciones generadas por una mini gramática
- **Fuente:** §2.3, Ejercicio 2.3. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse7
- **Tema:** 4
- **Dificultad:** 1
- **Solución:** la consulta es `?- sentence(W1,W2,W3,W4,W5).`; genera 2⁵ = 32 oraciones, en el orden del backtracking (el último argumento varía más rápido).
- **SWISH:** sí
- **Enunciado:** Con un léxico de seis palabras y una regla `sentence/5` (determinante, sustantivo, verbo, determinante, sustantivo), escribir la consulta que genera todas las oraciones y listarlas en el orden en que salen.
  ```prolog
  word(determiner,a).       word(determiner,every).
  word(noun,criminal).      word(noun,'big kahuna burger').
  word(verb,eats).          word(verb,likes).
  sentence(W1,W2,W3,W4,W5) :-
      word(determiner,W1), word(noun,W2), word(verb,W3),
      word(determiner,W4), word(noun,W5).
  ```
- **Notas:** Es un buen ejercicio para ver el orden del backtracking y para usar `findall/3` más adelante.

### LPN-2.4 — Crucigrama con seis palabras italianas
- **Fuente:** §2.3, Ejercicio 2.4. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse7
- **Tema:** 3, 4
- **Dificultad:** 2
- **Solución:** propia, verificada:
  ```prolog
  crossword(V1,V2,V3,H1,H2,H3) :-
      word(V1,_,A,_,B,_,C,_), word(V2,_,D,_,E,_,F,_), word(V3,_,G,_,H,_,I,_),
      word(H1,_,A,_,D,_,G,_), word(H2,_,B,_,E,_,H,_), word(H3,_,C,_,F,_,I,_).
  ```
  Así sale, entre otras, `V = astante, cobalto, pistola` y `H = astoria, baratto, statale`. Sin exigir que las seis palabras sean distintas aparecen 6 soluciones (con palabras repetidas). Si se agrega `sort([V1,V2,V3,H1,H2,H3],S), length(S,6)` quedan 2: la anterior y su traspuesta.
- **SWISH:** sí
- **Enunciado:** Se dan seis palabras de 7 letras como hechos `word(Palabra, L1,...,L7)`. Hay que ubicarlas en una grilla de 3 verticales por 3 horizontales, que se cruzan en las letras 2, 4 y 6 de cada palabra, escribiendo `crossword/6` (primero las verticales de izquierda a derecha, después las horizontales de arriba abajo).
  ```prolog
  word(astante, a,s,t,a,n,t,e).   word(astoria, a,s,t,o,r,i,a).
  word(baratto, b,a,r,a,t,t,o).   word(cobalto, c,o,b,a,l,t,o).
  word(pistola, p,i,s,t,o,l,a).   word(statale, s,t,a,t,a,l,e).
  ```
- **Notas:** La grilla es una imagen (`crosswd2.eps.png`) y solo se ve en la página. El libro no aclara si una palabra puede repetirse. Es un buen ejemplo de variable compartida como restricción: resuelve el problema solo con unificación, sin escribir ningún algoritmo.

### LPN-PS2.1 — Verificar unificaciones y el *occurs check*
- **Fuente:** §2.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse8
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** autoverificable. En SWI-Prolog, `?- g(X,Y) = Y.` tiene éxito con un término cíclico (`Y = g(X, Y)`), y `?- X = f(X), Y = f(Y), X = Y.` también tiene éxito. `unify_with_occurs_check/2` falla en ambos casos.
- **SWISH:** sí
- **Enunciado:** Comprobar en el intérprete las respuestas del ejercicio 2.1 usando `=/2`. Después ver qué pasa con unificaciones que requieren *occurs check*, como `g(X,Y) = Y`.
- **Notas:** Vale la pena mostrar `unify_with_occurs_check/2` y el flag `occurs_check`.

### LPN-PS2.2 — Predecir `\=/2` antes de ejecutarlo
- **Fuente:** §2.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse8
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** verificada: `a \= a` falla, `'a' \= a` falla, `A \= a` falla, `f(a) \= a` tiene éxito, `f(a) \= A` falla, `f(A) \= f(a)` falla, `g(a,B,c) \= g(A,b,C)` falla, `g(a,b,c) \= g(A,C)` tiene éxito, `f(X) \= X` falla (sin *occurs check* unifican).
- **SWISH:** sí
- **Enunciado:** Para nueve pares de términos (`a \= a`, `A \= a`, `g(a,B,c) \= g(A,b,C)`, `f(X) \= X`, ...), anotar primero qué va a responder Prolog y recién después ejecutar.
- **Notas:** `\=` quiere decir "no unifica", no "distinto". Por eso `A \= a` falla: una variable libre siempre unifica.

### LPN-PS2.3 — Seguir la búsqueda con `trace`
- **Fuente:** §2.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse8
- **Tema:** 0, 4
- **Dificultad:** 1
- **Solución:** no corresponde; la salida esperada (Call/Exit/Fail/Redo) está en la página.
- **SWISH:** sí (SWISH tiene un depurador gráfico; se activa con `trace, k(X).`)
- **Enunciado:** Cargar la base de abajo, activar `trace` y consultar `k(X)`. Relacionar cada línea Call/Exit/Fail/Redo con el árbol de búsqueda y desactivarlo con `notrace`.
  ```prolog
  f(a). f(b). g(a). g(b). h(b).
  k(X) :- f(X), g(X), h(X).
  ```
- **Notas:** El modelo de cuatro puertos de Byrd (Call, Exit, Redo, Fail) es la herramienta central para entender el backtracking.

## Capítulo 3: Recursion

### LPN-3.1 — ¿Es problemática esta versión de `descend/2`?
- **Fuente:** §3.3 Exercises, Ejercicio 3.1. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse11
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** propia, verificada: sí es problemática. La regla es recursiva por la izquierda (`descend(X,Y) :- descend(X,Z), descend(Z,Y).`), así que puede dar algunas respuestas correctas, pero cuando no hay solución o al pedir más respuestas entra en recursión infinita. `descend(emily,anne)` agota la pila en SWI-Prolog, y también `findall(Y, descend(anne,Y), L)`.
- **SWISH:** sí (SWISH corta la consulta por límite de recursos)
- **Enunciado:** Comparar la definición habitual de `descend/2` con una variante cuya regla recursiva es `descend(X,Z), descend(Z,Y)`, y decir si la variante trae problemas.
- **Notas:** Declarativamente las dos versiones son equivalentes; lo que cambia es el comportamiento procedural. El mensaje "Stack limit exceeded ... Probable infinite recursion" de SWI-Prolog es parte de lo que hay que aprender a leer.

### LPN-3.2 — Muñecas rusas: `directlyIn/2` e `in/2`
- **Fuente:** §3.3, Ejercicio 3.2. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse11
- **Tema:** 5
- **Dificultad:** 1
- **Solución:** propia, verificada (siguiendo el dibujo):
  ```prolog
  directlyIn(irina,natasha).  directlyIn(natasha,olga).  directlyIn(olga,katarina).
  in(X,Y) :- directlyIn(X,Y).
  in(X,Y) :- directlyIn(X,Z), in(Z,Y).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir una base con `directlyIn/2`, que dice qué muñeca está directamente dentro de cuál, y definir recursivamente `in/2` (contenida directa o indirectamente).
- **Notas:** **Error en la fuente:** en el dibujo (`dolls.eps.png`) Katarina es la muñeca más grande e Irina la más chica, pero el texto dice que `in(katarina,natasha)` debería ser verdadero y `in(olga,katarina)` falso, lo que corresponde al orden inverso. Hay que elegir una convención y aclararla. Con la del dibujo, lo verdadero es `in(natasha,katarina)`.

### LPN-3.3 — Viajes en tren: `travelFromTo/2`
- **Fuente:** §3.3, Ejercicio 3.3. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse11
- **Tema:** 5
- **Dificultad:** 1
- **Solución:** propia, verificada: `travelFromTo(X,Y) :- directTrain(X,Y).` y `travelFromTo(X,Y) :- directTrain(X,Z), travelFromTo(Z,Y).`; `travelFromTo(nancy,saarbruecken)` da true.
- **SWISH:** sí
- **Enunciado:** A partir de siete hechos `directTrain/2` (nancy→metz→fahlquemont→stAvold→freyming→forbach→saarbruecken→dudweiler), definir `travelFromTo/2`, que dice si se puede viajar entre dos ciudades encadenando trenes directos.
  ```prolog
  directTrain(saarbruecken,dudweiler).  directTrain(forbach,saarbruecken).
  directTrain(freyming,forbach).        directTrain(stAvold,freyming).
  directTrain(fahlquemont,stAvold).     directTrain(metz,fahlquemont).
  directTrain(nancy,metz).
  ```
- **Notas:** Es el esquema de clausura transitiva, igual que `descend/2`. LPN-10.4 lo retoma con trenes en ambos sentidos.

### LPN-3.4 — `greater_than/2` sobre numerales de Peano
- **Fuente:** §3.3, Ejercicio 3.4. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse11
- **Tema:** 3, 5
- **Dificultad:** 1
- **Solución:** propia, verificada: `greater_than(succ(_),0).` y `greater_than(succ(X),succ(Y)) :- greater_than(X,Y).`
- **SWISH:** sí
- **Enunciado:** Con los numerales `0`, `succ(0)`, `succ(succ(0))`, ..., definir `greater_than/2`, que se cumple si el primero es mayor que el segundo.
- **Notas:** Sirve para ver recursión sobre términos, no sobre números: `succ(0)` no se evalúa. SWI-Prolog tiene además un predicado predefinido `succ/2`, que no tiene nada que ver con este functor.

### LPN-3.5 — Espejar un árbol binario: `swap/2`
- **Fuente:** §3.3, Ejercicio 3.5. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse11
- **Tema:** 3, 5
- **Dificultad:** 1
- **Solución:** propia, verificada: `swap(leaf(X),leaf(X)).` y `swap(tree(A,B),tree(B1,A1)) :- swap(A,A1), swap(B,B1).`
- **SWISH:** sí
- **Enunciado:** Los árboles binarios se representan con hojas `leaf(Etiqueta)` y nodos `tree(Izq,Der)`. Definir `swap/2`, que devuelve la imagen especular del árbol.
  ```prolog
  ?- swap(tree(tree(leaf(1),leaf(2)),leaf(4)), T).
  T = tree(leaf(4), tree(leaf(2), leaf(1))).
  ```

### LPN-PS3.1 — Trazar las cuatro variantes de `descend`
- **Fuente:** §3.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse12
- **Tema:** 0, 4, 5
- **Dificultad:** 2
- **Solución:** no corresponde (práctica de observación).
- **SWISH:** sí
- **Enunciado:** Con `descend1.pl` a `descend4.pl`, que combinan dos órdenes de reglas con dos órdenes de metas, usar `trace` para contar pasos en `descend(anne,emily)`, contar las respuestas de `descend(X,Y)` y ver cuáles versiones no terminan (las recursivas por la izquierda).
- **Notas:** Los cuatro archivos se descargan desde la página del capítulo 3. La idea que se fija es que el orden de las metas decide si el programa termina, y el orden de las reglas decide en qué orden salen las respuestas.

### LPN-PS3.2 — `numeral/1` con las cláusulas invertidas
- **Fuente:** §3.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse12
- **Tema:** 4, 5
- **Dificultad:** 2
- **Solución:** verificada: con la cláusula recursiva primero, `numeral(succ(succ(succ(0))))` sigue teniendo éxito, pero `numeral(X)` no produce ninguna respuesta y recurre sin fin, hasta agotar la pila.
- **SWISH:** sí
- **Enunciado:** Comparar `numeral(0). numeral(succ(X)) :- numeral(X).` con la versión que tiene las dos cláusulas en orden inverso, primero para verificar numerales concretos y después para generar con `numeral(X)`.

### LPN-PS3.3 — Laberinto de una sola mano: `path/2`
- **Fuente:** §3.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse12
- **Tema:** 5
- **Dificultad:** 1
- **Solución:** propia, verificada: `path(X,Y) :- connected(X,Y).` y `path(X,Y) :- connected(X,Z), path(Z,Y).` Resultados: de 5 se llega a 10 (true); desde 1 solo se llega a 2; desde 13 se llega a 9, 10, 14, 17 y 18.
- **SWISH:** sí
- **Enunciado:** Con 19 hechos `connected/2`, que son pasos de un solo sentido en un laberinto, definir `path/2` y responder: ¿se va de 5 a 10?, ¿a dónde se llega desde 1?, ¿y desde 13?
- **Notas:** El grafo no tiene ciclos, así que la versión ingenua termina. Si hubiera ciclos habría que llevar una lista de visitados, como en LPN-10.4.

### LPN-PS3.4 — ¿Se puede viajar? `travel/2`
- **Fuente:** §3.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse12
- **Tema:** 5
- **Dificultad:** 1
- **Solución:** propia, verificada: `step(X,Y) :- byCar(X,Y) ; byTrain(X,Y) ; byPlane(X,Y).`, `travel(X,Y) :- step(X,Y).` y `travel(X,Y) :- step(X,Z), travel(Z,Y).`; `travel(valmont,raglan)` da true.
- **SWISH:** sí
- **Enunciado:** Con hechos `byCar/2`, `byTrain/2` y `byPlane/2` (valmont, metz, paris, losAngeles, auckland, raglan, ...), definir `travel/2`, que dice si se puede ir de un lugar a otro combinando tramos.

### LPN-PS3.5 — Devolver la ruta: `travel/3`
- **Fuente:** §3.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse12
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** propia, verificada: `travel(X,Y,go(X,Y)) :- step(X,Y).` y `travel(X,Y,go(X,Z,R)) :- step(X,Z), travel(Z,Y,R).` Con el orden de hechos del libro, la **primera** respuesta a `travel(valmont,losAngeles,X)` pasa por saarbruecken. La ruta por metz que muestra el libro sale por backtracking.
- **SWISH:** sí
- **Enunciado:** Extender `travel` para que devuelva la ruta como término anidado, por ejemplo `go(valmont,metz,go(metz,paris,go(paris,losAngeles)))`.
- **Notas:** Es el primer caso de construir una estructura de datos como resultado de la recursión.

### LPN-PS3.6 — Ruta con medio de transporte
- **Fuente:** §3.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse12
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** propia, verificada: con `mstep(X,Y,car) :- byCar(X,Y).` (y lo mismo para `train` y `plane`), `travel(X,Y,go(X,Y,M)) :- mstep(X,Y,M).` y `travel(X,Y,go(X,Z,M,R)) :- mstep(X,Z,M), travel(Z,Y,R).`
- **SWISH:** sí
- **Enunciado:** Modificar `travel/3` para que la ruta indique en cada tramo si se viaja en auto, en tren o en avión.

## Capítulo 4: Lists

### LPN-4.1 — Unificación de listas
- **Fuente:** §4.4 Exercises, Ejercicio 4.1. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse16
- **Tema:** 3, 6
- **Dificultad:** 1
- **Solución:** verificada: tienen éxito `[a|[b,c,d]]`, `[a,b|[c,d]]`, `[a,b,c|[d]]`, `[a,b,c,d|[]]` y `[] = _`. Fallan `[a,[b,c,d]]`, `[a,b,[c,d]]`, `[a,b,c,[d]]`, `[a,b,c,d,[]]`, `[] = [_]` y `[] = [_|[]]` (porque `[_|[]]` es `[_]`, una lista de un elemento).
- **SWISH:** sí
- **Enunciado:** Predecir la respuesta a 11 consultas del tipo `[a,b,c,d] = [a,b|[c,d]]` o `[] = [_]`.
- **Notas:** La confusión típica es entre `[a,[b,c,d]]` (dos elementos) y `[a|[b,c,d]]` (cuatro).

### LPN-4.2 — ¿Listas bien formadas?
- **Fuente:** §4.4, Ejercicio 4.2. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse16
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia: son listas `[1|[2,3,4]]` (4 elementos), `[1,2,3|[]]` (3), `[1|[2|[3|[4]]]]` (4), `[1,2,3,4|[]]` (4), `[[]|[]]` (1) y `[[1,2],[3,4]|[5,6,7]]` (5). `[1|2,3,4]` es un error de sintaxis y `[[1,2]|4]` es un término válido pero **no** es una lista propia (su cola es `4`).
- **SWISH:** sí
- **Enunciado:** Decir cuáles de ocho expresiones son listas sintácticamente correctas y cuántos elementos tiene cada una.
- **Notas:** `is_list/1` y `length/2` sirven para comprobarlo.

### LPN-4.3 — `second/2`
- **Fuente:** §4.4, Ejercicio 4.3. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse16
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `second(X,[_,X|_]).`
- **SWISH:** sí
- **Enunciado:** Escribir `second(X,Lista)`, que se cumple si `X` es el segundo elemento de `Lista`.
- **Notas:** Se resuelve con un solo hecho, sin reglas: toda la condición la expresa la unificación.

### LPN-4.4 — `swap12/2`
- **Fuente:** §4.4, Ejercicio 4.4. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse16
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `swap12([A,B|T],[B,A|T]).`
- **SWISH:** sí
- **Enunciado:** Escribir `swap12(L1,L2)`, que se cumple si `L2` es `L1` con los dos primeros elementos intercambiados.

### LPN-4.5 — Traducir listas alemán ↔ inglés: `listtran/2`
- **Fuente:** §4.4, Ejercicio 4.5. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse16
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `listtran([],[]).` y `listtran([G|Gs],[E|Es]) :- tran(G,E), listtran(Gs,Es).`; `listtran(X,[one,seven,six,two])` da `[eins,sieben,sechs,zwei]`.
- **SWISH:** sí
- **Enunciado:** Con hechos `tran(eins,one)`, ..., `tran(neun,nine)`, escribir `listtran/2`, que traduce una lista de números en alemán a inglés y que también funcione en la dirección inversa.
- **Notas:** Es un buen ejemplo de predicado reversible: el mismo código sirve para traducir en los dos sentidos.

### LPN-4.6 — Duplicar cada elemento: `twice/2`
- **Fuente:** §4.4, Ejercicio 4.6. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse16
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `twice([],[]).` y `twice([X|Xs],[X,X|Ys]) :- twice(Xs,Ys).`
- **SWISH:** sí
- **Enunciado:** Escribir `twice(In,Out)`, donde `Out` repite dos veces cada elemento de `In`: `twice([a,4,buggle],X)` da `X = [a,a,4,4,buggle,buggle]`.
- **Notas:** En la página, el resultado de ejemplo tiene un paréntesis de más (`X = [a,a,4,4,buggle,buggle]).`).

### LPN-4.7 — Árboles de búsqueda de `member/2`
- **Fuente:** §4.4, Ejercicio 4.7. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse16
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** no (se verifica con `trace`).
- **SWISH:** sí
- **Enunciado:** Dibujar los árboles de búsqueda de `member(a,[c,b,a,y])`, `member(x,[a,b,c])` y `member(X,[a,b,c])`.

### LPN-PS4.1 — Trazas de `a2b/2` y `member/2`
- **Fuente:** §4.5 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse17
- **Tema:** 0, 6
- **Dificultad:** 1
- **Solución:** no corresponde.
- **SWISH:** sí
- **Enunciado:** Trazar `a2b/2` (que relaciona una lista de `a` con una lista de `b` del mismo largo) en casos que tienen éxito, casos que fallan (largos distintos, otros símbolos) y casos con variables, incluido `a2b(X,Y)`. Después hacer lo mismo con `member/2`.
- **Notas:** `a2b/2` está definido en §4.3. Hay que prestar atención a por qué se detiene la recursión en cada caso.

### LPN-PS4.2 — Intercalar dos listas: `combine1/3`
- **Fuente:** §4.5 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse17
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `combine1([],[],[]).` y `combine1([X|Xs],[Y|Ys],[X,Y|Zs]) :- combine1(Xs,Ys,Zs).`
- **SWISH:** sí
- **Enunciado:** Escribir `combine1/3`, que intercala dos listas del mismo largo: `combine1([a,b,c],[1,2,3],X)` da `X = [a,1,b,2,c,3]`.

### LPN-PS4.3 — Emparejar en sublistas: `combine2/3`
- **Fuente:** §4.5 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse17
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia, verificada: igual que `combine1`, pero con `[[X,Y]|Zs]` en la cabeza.
- **SWISH:** sí
- **Enunciado:** Escribir `combine2/3`, que da `[[a,1],[b,2],[c,3]]` a partir de `[a,b,c]` y `[1,2,3]`.

### LPN-PS4.4 — Emparejar en términos: `combine3/3`
- **Fuente:** §4.5 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse17
- **Tema:** 3, 6
- **Dificultad:** 1
- **Solución:** propia, verificada: igual que `combine1`, pero con `[j(X,Y)|Zs]` en la cabeza.
- **SWISH:** sí
- **Enunciado:** Escribir `combine3/3`, que da `[j(a,1),j(b,2),j(c,3)]` a partir de `[a,b,c]` y `[1,2,3]`.
- **Notas:** Las tres versiones solo difieren en qué se hace con las cabezas de las listas.

## Capítulo 5: Arithmetic

### LPN-5.1 — `=` contra `is`
- **Fuente:** §5.5 Exercises, Ejercicio 5.1. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse22
- **Tema:** 3, 7
- **Dificultad:** 1
- **Solución:** verificada en SWI-Prolog 9.2.9: `X = 3*4` da `X = 3*4` (no evalúa); `X is 3*4` da `X = 12`; `4 is X` y `3 is X+2` dan **error de instanciación**; `3 is 1+2`, `3 is +(1,2)` y `is(X,+(1,2))` tienen éxito; `1+2 is 1+2` falla (el lado izquierdo no se evalúa); `3+2 = +(3,2)`, `*(7,5) = 7*5` y las tres variantes de `7*(3+2)` unifican; `7*3+2 = *(7,+(3,2))` falla por precedencia.
- **SWISH:** sí
- **Enunciado:** Predecir la respuesta a 16 consultas que mezclan `=`, `is` y la notación prefija de operadores (`+(1,2)`, `*(7,5)`).
- **Notas:** Es la confusión más frecuente al empezar: `=` no calcula, solo unifica términos. Y `is` no es reversible, porque su lado derecho tiene que estar instanciado.

### LPN-5.2 — `increment/2` y `sum/3`
- **Fuente:** §5.5, Ejercicio 5.2. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse22
- **Tema:** 7
- **Dificultad:** 1
- **Solución:** propia, verificada: `increment(X,Y) :- Y =:= X+1.` y `sum(X,Y,Z) :- Z =:= X+Y.` Si además se quiere que calcule el resultado, se usa `Y is X+1`.
- **SWISH:** sí
- **Enunciado:** Definir `increment/2` (se cumple si el segundo argumento es el primero más uno) y `sum/3` (se cumple si el tercero es la suma de los dos primeros).
- **Notas:** Hay que elegir entre `=:=`, que solo verifica, e `is`, que también calcula. Ninguno de los dos sirve para despejar `X` en `sum(X,5,9)`; para eso está `succ/2` o `library(clpfd)`, que queda fuera del alcance del curso.

### LPN-5.3 — Sumar 1 a cada elemento: `addone/2`
- **Fuente:** §5.5, Ejercicio 5.3. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse22
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** propia, verificada: `addone([],[]).` y `addone([X|Xs],[Y|Ys]) :- Y is X+1, addone(Xs,Ys).`
- **SWISH:** sí
- **Enunciado:** Escribir `addone/2`, que suma 1 a cada entero de una lista: `addone([1,2,7,2],X)` da `X = [2,3,8,3]`.
- **Notas:** Más adelante se puede resolver con `maplist/3` (tema 9).

### LPN-PS5.1 — Mínimo con acumulador: `accMin/3`
- **Fuente:** §5.6 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse23
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** propia, verificada: `accMin([H|T],A,M) :- H < A, accMin(T,H,M).`, `accMin([H|T],A,M) :- H >= A, accMin(T,A,M).` y `accMin([],A,A).`
- **SWISH:** sí
- **Enunciado:** Adaptar el `accMax/3` del texto (§5.4) para obtener `accMin/3`, que devuelve el mínimo de una lista de enteros.
- **Notas:** Hay que pensar con qué valor inicializar el acumulador: conviene usar el primer elemento de la lista, no un número "grande" arbitrario.

### LPN-PS5.2 — Producto por escalar: `scalarMult/3`
- **Fuente:** §5.6 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse23
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** propia, verificada: `scalarMult(_,[],[]).` y `scalarMult(K,[X|Xs],[Y|Ys]) :- Y is K*X, scalarMult(K,Xs,Ys).`
- **SWISH:** sí
- **Enunciado:** Escribir `scalarMult/3`, que multiplica cada componente de un vector (lista) por un entero: `scalarMult(3,[2,7,4],R)` da `R = [6,21,12]`.

### LPN-PS5.3 — Producto escalar: `dot/3`
- **Fuente:** §5.6 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse23
- **Tema:** 6, 7
- **Dificultad:** 1
- **Solución:** propia, verificada: `dot([],[],0).` y `dot([X|Xs],[Y|Ys],R) :- dot(Xs,Ys,R0), R is R0 + X*Y.` Con `dot([2,5,6],[3,4,1],R)` da `R = 32`.
- **SWISH:** sí
- **Enunciado:** Escribir `dot/3`, que calcula el producto escalar de dos vectores del mismo largo.
- **Notas:** Se puede hacer una segunda versión con acumulador, para compararla con la recursión "hacia afuera".

## Capítulo 6: More Lists

### LPN-6.1 — Listas duplicadas: `doubled/1`
- **Fuente:** §6.3 Exercises, Ejercicio 6.1. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse26
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `doubled(L) :- append(X,X,L).`
- **SWISH:** sí
- **Enunciado:** Una lista es "doble" si está formada por dos bloques consecutivos idénticos (`[a,b,c,a,b,c]`). Escribir `doubled/1`.
- **Notas:** `append/3` se usa aquí "al revés", para partir la lista en lugar de concatenar.

### LPN-6.2 — Palíndromos
- **Fuente:** §6.3, Ejercicio 6.2. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse26
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `palindrome(L) :- reverse(L,L).`
- **SWISH:** sí
- **Enunciado:** Escribir `palindrome/1`, que reconoce listas que se leen igual en los dos sentidos (`[r,o,t,a,t,o,r]`).
- **Notas:** Se puede exigir también una versión que use el `rev/2` con acumulador del texto en lugar de `reverse/2`. Coincide con P99-06.

### LPN-6.3 — Sacar el primero y el último: `toptail/2`
- **Fuente:** §6.3, Ejercicio 6.3. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse26
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `toptail([_|T],Out) :- append(Out,[_],T).` Falla con listas de menos de dos elementos.
- **SWISH:** sí
- **Enunciado:** Escribir `toptail(In,Out)`: falla si `In` tiene menos de dos elementos y, si no, `Out` es `In` sin su primer y último elemento.

### LPN-6.4 — Último elemento, de dos maneras
- **Fuente:** §6.3, Ejercicio 6.4. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse26
- **Tema:** 5, 6
- **Dificultad:** 1
- **Solución:** propia, verificada: con `rev/2`: `last(L,X) :- rev(L,[X|_]).`; recursiva: `last([X],X).` y `last([_|T],X) :- last(T,X).`
- **SWISH:** sí
- **Enunciado:** Escribir `last(Lista,X)` (último elemento de una lista no vacía) primero usando `rev/2` y después con recursión directa.
- **Notas:** `last/2` ya existe en `library(lists)`. En SWI-Prolog, definirlo en el propio archivo reemplaza al de la biblioteca sin error, pero conviene usar otro nombre (`ultimo/2`) para no confundir. Coincide con P99-01.

### LPN-6.5 — Intercambiar primero y último: `swapfl/2`
- **Fuente:** §6.3, Ejercicio 6.5. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse26
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** propia, verificada (con `append/3`): `swapfl([F|T1],[L|T2]) :- append(M,[L],T1), append(M,[F],T2).`
- **SWISH:** sí
- **Enunciado:** Escribir `swapfl(L1,L2)`, que se cumple si `L2` es `L1` con el primer y el último elemento intercambiados. Hacerlo con `append/3` y también con recursión directa.

### LPN-6.6 — Acertijo de las tres casas (zebra)
- **Fuente:** §6.3, Ejercicio 6.6. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse26
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** propia, verificada: con la calle `[_,_,_]` y casas `h(Color,Nacionalidad,Mascota)`, cada pista se escribe con `member/2` o con "A está inmediatamente antes que B", `append(_,[A,B|_],Calle)`. El resultado es `zebra(japanese)`. La respuesta sale dos veces por backtracking, porque hay dos disposiciones de calle compatibles.
- **SWISH:** sí
- **Enunciado:** Hay tres casas vecinas, cada una de un color distinto (rojo, azul, verde), con dueños de nacionalidades distintas y mascotas distintas. Con cuatro pistas (el inglés vive en la casa roja; el jaguar es de los españoles; el japonés vive a la derecha del que cría caracoles; el de los caracoles vive a la izquierda de la casa azul), escribir `zebra/1`, que da la nacionalidad del dueño de la cebra.
- **Notas:** El enunciado no dice si "a la derecha" significa "inmediatamente a la derecha"; con esa interpretación la respuesta es única. Es la versión reducida del acertijo de Einstein, que está completo en SWISH (ver SWISH-60 en `swish-tutoriales.md`).

### LPN-PS6.1 — Trazas de `append`, `prefix`, `suffix`, `sublist` y `rev`
- **Fuente:** §6.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse27
- **Tema:** 0, 6
- **Dificultad:** 2
- **Solución:** no corresponde.
- **SWISH:** sí
- **Enunciado:** Trazar `append/3` para concatenar y para partir (`append(L,R,[foo,wee,blup])`), explicar por qué `prefix/2` da primero las listas cortas y `suffix/2` las largas, por qué `sublist/2` repite sublistas, y comparar `naiverev/2` con `rev/2`.
- **Notas:** Para medir la diferencia entre `naiverev` y `rev` se puede usar `time/1` (ver también el ejemplo `lists.pl` de SWISH).

### LPN-PS6.2 — `member/2` en una línea con `append/3`
- **Fuente:** §6.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse27
- **Tema:** 6
- **Dificultad:** 1
- **Solución:** propia, verificada: `member2(X,L) :- append(_,[X|_],L).`
- **SWISH:** sí
- **Enunciado:** Definir `member` en una línea usando `append/3`, y comparar su eficiencia con la definición recursiva estándar.
- **Notas:** Las dos versiones recorren la lista de la misma manera, pero la de `append` construye prefijos que después descarta.

### LPN-PS6.3 — Eliminar repetidos: `set/2`
- **Fuente:** §6.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse27
- **Tema:** 6
- **Dificultad:** 2
- **Solución:** propia, verificada (con acumulador y `member/2`):
  ```prolog
  set(L,S) :- set_(L,[],S).
  set_([],Acc,S) :- reverse(Acc,S).
  set_([H|T],Acc,S) :- member(H,Acc), !, set_(T,Acc,S).
  set_([H|T],Acc,S) :- set_(T,[H|Acc],S).
  ```
  `set([2,2,foo,1,foo,[],[]],X)` da `X = [2,foo,1,[]]`.
- **SWISH:** sí
- **Enunciado:** Escribir `set(In,Out)`, que deja una sola aparición de cada elemento y conserva el orden de la primera aparición.
- **Notas:** La solución de arriba usa corte (tema 8). Sin corte, la tercera cláusula necesita la condición `\+ member(H,Acc)`. La biblioteca ofrece `list_to_set/2`.

### LPN-PS6.4 — Aplanar una lista sin `append/3`
- **Fuente:** §6.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse27
- **Tema:** 5, 6
- **Dificultad:** 3
- **Solución:** propia, verificada (con acumulador):
  ```prolog
  myflatten(L,F) :- fl(L,[],F).
  fl([],Acc,Acc) :- !.
  fl([H|T],Acc,F) :- !, fl(T,Acc,F1), fl(H,F1,F).
  fl(X,Acc,[X|Acc]).
  ```
  `myflatten([a,b,[[[[[[[c,d]]]]]]],[[1,2]],foo,[]],X)` da `X = [a,b,c,d,1,2,foo]`.
- **SWISH:** sí
- **Enunciado:** Escribir `flatten(Lista,Plana)`, que elimina todos los corchetes anidados (`[a,b,[c,d],[[1,2]],foo]` queda `[a,b,c,d,1,2,foo]`), sin usar `append/3`.
- **Notas:** El libro lo llama el *pons asinorum* de Prolog. `flatten/2` ya existe en la biblioteca, así que conviene otro nombre. Relacionado con P99-07. Esta solución usa corte; se puede discutir cuál sería la versión sin corte.

## Capítulo 7: Definite Clause Grammars

### LPN-7.1 — Traducir una DCG a cláusulas comunes
- **Fuente:** §7.3 Exercises, Ejercicio 7.1. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse30
- **Tema:** A
- **Dificultad:** 2
- **Solución:** verificada con `listing/1`: cada regla `a --> b, c.` se traduce como `a(S0,S) :- b(S0,S1), c(S1,S).`, y cada terminal `foo --> [choo].` como `foo([choo|S],S).` Las tres primeras respuestas a `s(X,[])` son `[choo,i,am,a,train,toot]`, la misma con `toot,toot` y la misma con `toot,toot,toot`.
- **SWISH:** sí
- **Enunciado:** Dada una DCG de 12 reglas (`s --> foo,bar,wiggle.`, `foo --> [choo].`, `foo --> foo,foo.`, ..., `wiggle --> wiggle,wiggle.`), escribir las cláusulas Prolog equivalentes y dar las tres primeras respuestas a `s(X,[])`.
- **Notas:** Las reglas `foo --> foo,foo` y `wiggle --> wiggle,wiggle` son recursivas por la izquierda. Por eso Prolog nunca llega a generar dos `choo`: siempre varía el último no terminal.

### LPN-7.2 — DCG para aⁿbⁿ sin la cadena vacía
- **Fuente:** §7.3, Ejercicio 7.2. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse30
- **Tema:** A
- **Dificultad:** 1
- **Solución:** propia, verificada: `s --> [a],[b].` y `s --> [a],s,[b].`
- **SWISH:** sí
- **Enunciado:** Escribir una DCG para el lenguaje aⁿbⁿ con n ≥ 1.
- **Notas:** Se prueba con `phrase/2`, por ejemplo `?- length(L,4), phrase(s,L).`

### LPN-7.3 — DCG para aⁿb²ⁿ
- **Fuente:** §7.3, Ejercicio 7.3. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse30
- **Tema:** A
- **Dificultad:** 1
- **Solución:** propia, verificada: `s --> [].` y `s --> [a],s,[b,b].`
- **SWISH:** sí
- **Enunciado:** Escribir una DCG para el lenguaje formado por n letras `a` seguidas de 2n letras `b` (incluida la cadena vacía).

### LPN-PS7.1 — Reconocedores con `append` contra listas de diferencia
- **Fuente:** §7.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse31
- **Tema:** 0, A
- **Dificultad:** 2
- **Solución:** no corresponde. En SWI-Prolog, `det --> [the].` se lista como `det([the|A], A).`, sin el predicado `'C'/3`.
- **SWISH:** sí
- **Enunciado:** Trazar el reconocedor basado en `append/3` y el basado en listas de diferencia del capítulo, comparar el tamaño de las trazas, y usar `listing` para ver cómo traduce el sistema las reglas DCG, por ejemplo si usa `'C'/3`.

### LPN-PS7.2 — DCG para un número par de `a`
- **Fuente:** §7.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse31
- **Tema:** A
- **Dificultad:** 1
- **Solución:** propia, verificada: `even --> [].` y `even --> [a,a],even.`
- **SWISH:** sí
- **Enunciado:** Escribir una DCG para el lenguaje de las cadenas con una cantidad par de `a` (incluida la vacía).

### LPN-PS7.3 — DCG para aⁿb²ᵐc²ᵐdⁿ
- **Fuente:** §7.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse31
- **Tema:** A
- **Dificultad:** 2
- **Solución:** propia, verificada: `s --> [a],s,[d].`, `s --> m.`, `m --> [].` y `m --> [b,b],m,[c,c].`
- **SWISH:** sí
- **Enunciado:** Escribir una DCG para las cadenas formadas por bloques de `a`, `b`, `c` y `d`, donde los bloques de `a` y `d` tienen el mismo largo, y los de `b` y `c` tienen el mismo largo, que además es par.
- **Notas:** Si se agrega también `s --> [].`, la gramática queda ambigua y genera la cadena vacía dos veces.

### LPN-PS7.4 — DCG para lógica proposicional
- **Fuente:** §7.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse31
- **Tema:** A
- **Dificultad:** 2
- **Solución:** propia, verificada: `prop --> [p].` (y lo mismo para `q` y `r`), `prop --> [not],prop.` y `prop --> ['('],prop,[and],prop,[')'].` (y lo mismo para `or` e `implies`). Reconoce `[not,'(',p,implies,q,')']`.
- **SWISH:** sí
- **Enunciado:** Escribir una DCG que reconozca fórmulas de lógica proposicional sobre `p`, `q` y `r` con negación, conjunción, disyunción e implicación, tokenizadas como lista de átomos (por ejemplo `[not,'(',p,implies,q,')']`).
- **Notas:** Conecta con la parte de lógica proposicional de la materia. LPN-PS9.3 retoma el ejercicio con operadores.

## Capítulo 8: More Definite Clause Grammars

### LPN-8.1 — Concordancia de número con un argumento extra
- **Fuente:** §8.4 Exercises, Ejercicio 8.1. https://www.let.rug.nl/bos/lpn/lpnpage.php?pagetype=html&pageid=lpn-htmlse35 (el mirror de lpn.swi-prolog.org está roto)
- **Tema:** A
- **Dificultad:** 2
- **Solución:** propia, verificada: `s --> np(N), vp(N).`, `np(N) --> det, n(N).`, `vp(N) --> v(N), np(_).`, `vp(N) --> v(N).`, `n(sg) --> [man].`, `n(pl) --> [men].`, `v(sg) --> [eats].`, `v(pl) --> [eat].` (y lo mismo para *know*). Acepta "the men eat" y "the man eats"; rechaza "the men eats" y "the man eat".
- **SWISH:** sí
- **Enunciado:** Tomar la DCG básica del capítulo (`s --> np,vp.`, ...) y agregarle el sustantivo plural *men* y el verbo *know*. Con un argumento extra, lograr que se respete la concordancia de número entre sujeto y verbo.

### LPN-8.2 — Traducir una regla DCG con tres argumentos extra
- **Fuente:** §8.4, Ejercicio 8.2. https://www.let.rug.nl/bos/lpn/lpnpage.php?pagetype=html&pageid=lpn-htmlse35
- **Tema:** A
- **Dificultad:** 1
- **Solución:** verificada con `listing(kanga//3)`: `kanga(V,R,Q,A,B) :- roo(V,R,A,C), jumps(Q,Q,C,D), marsupial(V,R,Q), B = D.` (a mano: `kanga(V,R,Q,S0,S) :- roo(V,R,S0,S1), jumps(Q,Q,S1,S), marsupial(V,R,Q).`)
- **SWISH:** sí
- **Enunciado:** Traducir a cláusulas comunes la regla `kanga(V,R,Q) --> roo(V,R), jumps(Q,Q), {marsupial(V,R,Q)}.`
- **Notas:** Las llaves `{}` meten una meta Prolog común, que no consume entrada.

### LPN-PS8.1 — Trazas de DCG con argumentos y metas extra
- **Fuente:** §8.5 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse36
- **Tema:** A
- **Dificultad:** 2
- **Solución:** no corresponde.
- **SWISH:** sí
- **Enunciado:** Trazar las DCG del capítulo: la de sujeto/objeto, la que construye árboles de análisis, la de léxico separado y la de aⁿbⁿcⁿ con contador `succ(...)`, tanto con entradas válidas como inválidas.

### LPN-PS8.2 — Mini proyecto: una DCG del inglés completa
- **Fuente:** §8.5 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse36
- **Tema:** A
- **Dificultad:** 3
- **Solución:** no (se puede comparar con el ejemplo `grammar.pl` de SWISH).
- **SWISH:** sí
- **Enunciado:** Juntar en una sola DCG la distinción sujeto/objeto y la de singular/plural, que además construya el árbol de análisis y use un léxico separado. Después extenderla con adjetivos, frases preposicionales ("the small frightened woman on the table") y pronombres de primera, segunda y tercera persona en forma sujeto y objeto.
- **Notas:** Es un proyecto largo, fuera del núcleo del curso. LPN-PS12.1 lo reutiliza.

## Capítulo 9: A Closer Look at Terms

### LPN-9.1 — Comparación de términos contra comparación aritmética
- **Fuente:** §9.5 Exercises, Ejercicio 9.1. https://www.let.rug.nl/bos/lpn/lpnpage.php?pagetype=html&pageid=lpn-htmlse41 (el mirror de lpn.swi-prolog.org está roto)
- **Tema:** 3, 7
- **Dificultad:** 1
- **Solución:** verificada: tienen éxito `12 is 2*6`, `14 =\= 2*6`, `14 \== 2*7`, `14 =:= 2*7`, `[1,2,3|[d,e]] == [1,2,3,d,e]`, `2+3 =:= 3+2`, `7-2 =\= 9-2`, `p == 'p'` y `vincent=VAR, VAR==vincent`. Fallan `14 = 2*7`, `14 == 2*7`, `2+3 == 3+2` y `vincent == VAR`. `p =\= 'p'` da **error de tipo** (`p` no es evaluable).
- **SWISH:** sí
- **Enunciado:** Decir cuáles de 14 consultas que mezclan `=`, `==`, `\==`, `=:=`, `=\=` e `is` tienen éxito y cuáles fallan.
- **Notas:** Hay que distinguir cuatro relaciones: unificable (`=`), idéntico (`==`), aritméticamente igual (`=:=`) y evaluar (`is`).

### LPN-9.2 — Listas en notación con punto
- **Fuente:** §9.5, Ejercicio 9.2. https://www.let.rug.nl/bos/lpn/lpnpage.php?pagetype=html&pageid=lpn-htmlse41
- **Tema:** 3, 6
- **Dificultad:** 2
- **Solución:** en Prolog tradicional (o en SWI-Prolog arrancado con `swipl --traditional`) las tres primeras consultas unifican: `X = [[a],[b],[c]]` en la tercera. La cuarta falla, porque `.(.(c,[]),[])` es `[[c]]`, no `[c]`. En SWI-Prolog 9 sin esa opción, `.(a,...)` **no** es una lista (el punto se usa para los *dicts*): hay que reescribir con `'[|]'(a,'[|]'(b,[]))`.
- **SWISH:** sí, pero hay que reescribir con `'[|]'`
- **Enunciado:** Predecir la respuesta de cuatro unificaciones entre listas escritas con el functor `.`/2 (por ejemplo `.(a,.(b,.(c,[]))) = [a,b,c]`) y listas en notación de corchetes.
- **Notas:** **Desactualizado para SWI-Prolog 7+.** Conviene presentarlo con `'[|]'` o con `write_canonical([a,b])`, que muestra `'[|]'(a,'[|]'(b,[]))`.

### LPN-9.3 — Clasificar un término: `termtype/2`
- **Fuente:** §9.5, Ejercicio 9.3. https://www.let.rug.nl/bos/lpn/lpnpage.php?pagetype=html&pageid=lpn-htmlse41
- **Tema:** 3
- **Dificultad:** 2
- **Solución:** propia, verificada:
  ```prolog
  termtype(T,variable) :- var(T), !.
  termtype(T,atom) :- atom(T).
  termtype(T,number) :- number(T).
  termtype(T,constant) :- atomic(T).
  termtype(T,simple_term) :- atomic(T).
  termtype(T,complex_term) :- compound(T).
  termtype(_,term).
  ```
  `termtype(mia,X)` da `atom ; constant ; simple_term ; term`.
- **SWISH:** sí
- **Enunciado:** Escribir `termtype(Term,Tipo)`, que por backtracking da todos los tipos de un término, del más específico al más general (variable, átomo, número, constante, término simple, término complejo, término).
- **Notas:** En el libro, "término simple" incluye también a las variables. La solución de arriba corta en el caso variable para que `termtype(Vincent,variable)` no ligue la variable.

### LPN-9.4 — ¿Es un término cerrado? `groundterm/1`
- **Fuente:** §9.5, Ejercicio 9.4. https://www.let.rug.nl/bos/lpn/lpnpage.php?pagetype=html&pageid=lpn-htmlse41
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** propia, verificada: `groundterm(T) :- nonvar(T), T =.. [_|Args], all_ground(Args).`, `all_ground([]).` y `all_ground([A|As]) :- groundterm(A), all_ground(As).`
- **SWISH:** sí
- **Enunciado:** Escribir `groundterm/1`, que tiene éxito si el término no contiene variables (sin usar el predicado predefinido `ground/1`).
- **Notas:** Sirve para practicar `=../2` (*univ*). Después se compara con `ground/1`.

### LPN-9.5 — Operadores definidos por el usuario
- **Fuente:** §9.5, Ejercicio 9.5. https://www.let.rug.nl/bos/lpn/lpnpage.php?pagetype=html&pageid=lpn-htmlse41
- **Tema:** 3
- **Dificultad:** 2
- **Solución:** verificada con `write_canonical/1`: `X is_a witch` es `is_a(X,witch)`; `harry and ron and hermione are friends` es `are(and(harry,and(ron,hermione)),friends)`; `harry is_a wizard and likes quidditch` es un **error de sintaxis** (`operator_clash`), porque `likes` (300) no puede ser argumento de `and` (200); `dumbledore is_a famous wizard` es `is_a(dumbledore,famous(wizard))`.
- **SWISH:** sí
- **Enunciado:** Con las declaraciones de abajo, decir cuáles de cuatro expresiones son términos bien formados, cuál es su operador principal y cómo se agrupan.
  ```prolog
  :- op(300, xfx, [are, is_a]).
  :- op(300, fx, likes).
  :- op(200, xfy, and).
  :- op(100, fy, famous).
  ```

### LPN-PS9.1 — Explorar `display/1` y `write/1`
- **Fuente:** §9.6 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse42
- **Tema:** 3
- **Dificultad:** 1
- **Solución:** no corresponde. En SWI-Prolog 9, `display(2+3+4)` imprime `+(+(2,3),4)` y `display([a,b,c])` imprime `'[|]'(a,'[|]'(b,'[|]'(c,[])))`.
- **SWISH:** sí
- **Enunciado:** Probar `display/1` con `[a,b,c]`, `3 is 4 + 5 / 3`, `(a:-b,c,d)`, etc., para ver la estructura interna de los términos con operadores, y compararlo con `write/1`, `tab/1` y `nl/0`.
- **Notas:** `display(a:-b,c,d)` sin paréntesis extra se lee como una llamada a `display/3`, que no existe. `write_canonical/1` es la alternativa estándar.

### LPN-PS9.2 — Imprimir árboles de análisis con sangría: `pptree/1`
- **Fuente:** §9.6 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse42
- **Tema:** 3, 5
- **Dificultad:** 2
- **Solución:** propia, verificada:
  ```prolog
  pptree(T) :- pp(T,0), nl.
  pp(T,I) :- compound(T), !, T =.. [F|Args], tab(I), write(F), write('('),
             I2 is I+2, pp_args(Args,I2), write(')').
  pp(T,I) :- tab(I), write(T).
  pp_args([A],I) :- !, nl, pp(A,I).
  pp_args([A|As],I) :- nl, pp(A,I), pp_args(As,I).
  ```
- **SWISH:** sí
- **Enunciado:** Escribir `pptree/1`, que imprime un árbol como `s(np(det(a),n(man)),vp(...))` con un nodo por línea y sangría según la profundidad.
- **Notas:** La salida de arriba difiere un poco del ejemplo del libro, que deja las hojas en la misma línea (`det(a)`).

### LPN-PS9.3 — Operadores para lógica proposicional
- **Fuente:** §9.6 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse42
- **Tema:** 3, A
- **Dificultad:** 2
- **Solución:** propia, verificada: `:- op(200, fy, not).`, `:- op(300, xfy, and).`, `:- op(400, xfy, or).` y `:- op(500, xfy, implies).` Con eso, `write_canonical(not p implies q)` da `implies(not(p),q)`.
- **SWISH:** sí
- **Enunciado:** Definir operadores `not`, `and`, `or` e `implies` para que Prolog lea fórmulas como `not(p implies q)` o `not p implies q` y las agrupe correctamente.
- **Notas:** Conecta con la lógica proposicional de la materia y con P99-47.

## Capítulo 10: Cuts and Negation

### LPN-10.1 — Respuestas con corte
- **Fuente:** §10.4 Exercises, Ejercicio 10.1. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse46
- **Tema:** 4, 8
- **Dificultad:** 2
- **Solución:** verificada: `p(X)` da `X = 1 ; X = 2`. `p(X),p(Y)` da los pares `1-1, 1-2, 2-1, 2-2`. `p(X),!,p(Y)` da `1-1, 1-2`.
- **SWISH:** sí
- **Enunciado:** Con la base de abajo, escribir todas las respuestas de `p(X)`, de `p(X),p(Y)` y de `p(X),!,p(Y)`.
  ```prolog
  p(1).
  p(2) :- !.
  p(3).
  ```
- **Notas:** El corte dentro de `p(2)` elimina la alternativa `p(3)`; el corte de la consulta congela la elección de `X`.

### LPN-10.2 — Clasificar números y agregar cortes verdes
- **Fuente:** §10.4, Ejercicio 10.2. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse46
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** propia, verificada: `class(N,positive) :- N > 0, !.`, `class(0,zero) :- !.` y `class(N,negative) :- N < 0.`
- **SWISH:** sí
- **Enunciado:** Explicar qué hace un programa `class/2` que clasifica un número como `positive`, `zero` o `negative`, y mejorarlo con cortes verdes.
  ```prolog
  class(Number,positive) :- Number > 0.
  class(0,zero).
  class(Number,negative) :- Number < 0.
  ```
- **Notas:** Un corte "verde" no cambia el significado del programa, solo evita trabajo inútil. La prueba es que quitarlo no cambia las respuestas.

### LPN-10.3 — Separar positivos y negativos: `split/3`
- **Fuente:** §10.4, Ejercicio 10.3. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse46
- **Tema:** 6, 8
- **Dificultad:** 1
- **Solución:** propia, verificada: sin corte: `split([],[],[]).`, `split([X|Xs],[X|P],N) :- X >= 0, split(Xs,P,N).` y `split([X|Xs],P,[X|N]) :- X < 0, split(Xs,P,N).` Con corte: se pone `!` después de `X >= 0` y se quita la prueba `X < 0` de la tercera cláusula.
- **SWISH:** sí
- **Enunciado:** Escribir `split/3`, que separa una lista de enteros en no negativos y negativos, primero sin corte y después mejorado con corte sin cambiar su significado.
  ```prolog
  ?- split([3,4,-5,-1,0,4,-9],P,N).
  P = [3,4,0,4], N = [-5,-1,-9].
  ```
- **Notas:** La segunda versión usa un corte "rojo": si se lo saca, el programa da respuestas incorrectas al pedir más soluciones. Relacionado con `partition/4` (tema 9).

### LPN-10.4 — Ruta de trenes en ambos sentidos: `route/3`
- **Fuente:** §10.4, Ejercicio 10.4. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse46
- **Tema:** 5, 6, 8
- **Dificultad:** 2
- **Solución:** propia, verificada:
  ```prolog
  conn(X,Y) :- directTrain(X,Y) ; directTrain(Y,X).
  route(A,B,R) :- route_(A,B,[A],Rev), reverse(Rev,R).
  route_(B,B,Acc,Acc).
  route_(A,B,Acc,R) :- conn(A,C), \+ member(C,Acc), route_(C,B,[C|Acc],R).
  ```
  `route(forbach,metz,R)` da `R = [forbach,freyming,stAvold,fahlquemont,metz]`.
- **SWISH:** sí
- **Enunciado:** Retomar los trenes de LPN-3.3 suponiendo que todo tren directo también va en sentido contrario, y escribir `route/3`, que da la lista de ciudades visitadas entre dos ciudades.
- **Notas:** Con conexiones simétricas aparecen ciclos, así que hace falta una lista de visitados y `\+ member`, que es negación por falla. Si se agregan hechos `directTrain(Y,X)` en lugar de la regla `conn/2`, la versión ingenua no termina.

### LPN-10.5 — Nadie es celoso de sí mismo
- **Fuente:** §10.4, Ejercicio 10.5. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse46
- **Tema:** 8
- **Dificultad:** 1
- **Solución:** propia, verificada: `jealous(X,Y) :- loves(X,Z), loves(Y,Z), X \== Y.` (también sirve `\+ X = Y` al final).
- **SWISH:** sí
- **Enunciado:** Corregir `jealous(X,Y) :- loves(X,Z), loves(Y,Z).` para que nadie resulte celoso de sí mismo.
- **Notas:** La prueba tiene que ir **al final**, cuando `X` e `Y` ya están ligadas. Si `\+ X = Y` va al principio, falla siempre.

### LPN-PS10.1 — Trazar `max/3` y las preferencias de Vincent
- **Fuente:** §10.5 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse47
- **Tema:** 0, 8
- **Dificultad:** 2
- **Solución:** no corresponde.
- **SWISH:** sí
- **Enunciado:** Trazar las tres versiones de `max/3` del texto (sin corte, con corte verde y con corte rojo), con los tres argumentos instanciados y con el tercero libre. Después probar las variantes de "a Vincent le gustan las hamburguesas salvo las Big Kahuna": con corte-falla, con `\+` bien ubicado y con `\+` mal ubicado.
- **Notas:** La versión con corte rojo que unifica en la cabeza (`max(X,Y,Y) :- X =< Y, !.` y `max(X,_,X).`) tiene éxito con `max(2,3,2)`, que es falso (verificado). Es el ejemplo clásico de por qué los cortes rojos son peligrosos cuando el tercer argumento viene instanciado.

### LPN-PS10.2 — "No unificable" de tres maneras: `nu/2`
- **Fuente:** §10.5 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse47
- **Tema:** 3, 8
- **Dificultad:** 2
- **Solución:** propia, verificada: (1) `nu(X,Y) :- \+ X = Y.` (2) `nu(X,Y) :- X = Y, !, fail.` y `nu(_,_).` (3) `nu(X,X) :- !, fail.` y `nu(_,_).`
- **SWISH:** sí
- **Enunciado:** Definir `nu/2`, que tiene éxito si dos términos no unifican, de tres maneras: con `=` y `\+`; con `=` pero sin `\+`; y con corte-falla, sin `=` ni `\+`.
- **Notas:** Es exactamente `\=/2`. Muestra que la negación por falla se puede construir con corte y falla.

### LPN-PS10.3 — Filtrar sin ligar variables: `unifiable/3`
- **Fuente:** §10.5 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse47
- **Tema:** 6, 8
- **Dificultad:** 3
- **Solución:** propia, verificada:
  ```prolog
  unifiable([],_,[]).
  unifiable([H|T],X,[H|R]) :- \+ \+ H = X, !, unifiable(T,X,R).
  unifiable([_|T],X,R) :- unifiable(T,X,R).
  ```
  `unifiable([X,b,t(Y)],t(a),L)` da `L = [X,t(Y)]` con `X` e `Y` libres.
- **SWISH:** sí
- **Enunciado:** Escribir `unifiable(L1,T,L2)`, donde `L2` contiene los elementos de `L1` que unifican con `T`, sin que la prueba deje ligadas sus variables.
- **Notas:** La doble negación `\+ \+` prueba la unificación y deshace las ligaduras. En la página, la consulta de ejemplo termina en `]` en lugar de `)`.

## Capítulo 11: Database Manipulation and Collecting Solutions

### LPN-11.1 — `assert`, `retract` y `retractall`
- **Fuente:** §11.3 Exercises, Ejercicio 11.1. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse50
- **Tema:** 10
- **Dificultad:** 1
- **Solución:** verificada con `listing/1`: después del primer comando la base queda `q(foo,blug). q(a,b). q(1,2).`; después del segundo, `q(foo,blug). q(a,b). p(X) :- h(X).`; después del tercero, solo `p(X) :- h(X).`
- **SWISH:** sí (dentro de una misma consulta)
- **Enunciado:** Partiendo de una base vacía, decir qué contiene la base después de tres comandos sucesivos con `assert/1`, `assertz/1`, `asserta/1`, `retract/1` y `retractall/1`.
  ```prolog
  ?- assert(q(a,b)), assertz(q(1,2)), asserta(q(foo,blug)).
  ?- retract(q(1,2)), assertz( (p(X) :- h(X)) ).
  ?- retractall(q(_,_)).
  ```
- **Notas:** En SWISH cada consulta corre en un entorno nuevo y los cambios no pasan de una consulta a la siguiente. Para ver la secuencia hay que encadenar los tres comandos en una sola consulta o usar `swipl`.

### LPN-11.2 — `findall`, `bagof` y `setof`
- **Fuente:** §11.3, Ejercicio 11.2. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse50
- **Tema:** 9
- **Dificultad:** 2
- **Solución:** verificada: `findall(X,q(blob,X),L)` da `[blug,blag,blig]`; `findall(X,q(X,blug),L)` da `[blob,dang]`; `findall(X,q(X,Y),L)` da `[blob,blob,blob,blaf,dang,dang,flab]`; `bagof(X,q(X,Y),L)` da una respuesta por cada `Y` (por ejemplo `Y = blag, L = [blob,blaf]`); `setof(X,Y^q(X,Y),L)` da `[blaf,blob,dang,flab]`.
- **SWISH:** sí
- **Enunciado:** Con siete hechos `q/2`, dar la respuesta de cinco consultas con `findall/3`, `bagof/3` y `setof/3` (con y sin `^`).
- **Notas:** La diferencia clave es que `bagof` agrupa por las variables libres y `findall` no. `^` cuantifica existencialmente.

### LPN-11.3 — Suma 1..n con memorización: `sigma/2`
- **Fuente:** §11.3, Ejercicio 11.3. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse50
- **Tema:** 7, 10
- **Dificultad:** 2
- **Solución:** propia, verificada:
  ```prolog
  :- dynamic sigmares/2.
  sigma(1,1) :- !.
  sigma(N,S) :- sigmares(N,S), !.
  sigma(N,S) :- N > 1, N1 is N-1, sigma(N1,S1), S is S1+N,
                assertz(sigmares(N,S)).
  ```
  Después de `sigma(2,X)` y `sigma(3,X)`, `listing(sigmares/2)` muestra `sigmares(2,3).` y `sigmares(3,6).`
- **SWISH:** parcial (la memorización no sobrevive entre consultas)
- **Enunciado:** Escribir `sigma/2`, que suma los enteros de 1 a n, guardando cada resultado en la base (una sola entrada por valor) y reutilizando los ya calculados.
- **Notas:** Es memoización a mano. SWI-Prolog ofrece `:- table sigma/2.`, que hace lo mismo automáticamente (ver el tutorial de *tabling* en SWISH).

### LPN-PS11.1 — Subconjuntos por backtracking: `subset/2`
- **Fuente:** §11.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse51
- **Tema:** 4, 6
- **Dificultad:** 2
- **Solución:** propia, verificada: `subset2([],[]).`, `subset2([X|S],[X|L]) :- subset2(S,L).` y `subset2(S,[_|L]) :- subset2(S,L).`
- **SWISH:** sí
- **Enunciado:** Escribir `subset/2`, que se cumple si todo elemento del primer conjunto (lista sin repetidos) está en el segundo, y que con el primer argumento libre genere por backtracking los ocho subconjuntos de `[a,b,c]`.
- **Notas:** `subset/2` ya existe en `library(lists)`, pero no genera; conviene otro nombre. La versión de arriba genera subconjuntos que respetan el orden de la lista. Para verificar `subset([c,b],[a,b,c])`, que no respeta ese orden, hace falta otra cláusula de prueba (por ejemplo con `member/2`).

### LPN-PS11.2 — Conjunto potencia: `powerset/2`
- **Fuente:** §11.4 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse51
- **Tema:** 9
- **Dificultad:** 1
- **Solución:** propia, verificada: `powerset(Set,P) :- findall(S, subset2(S,Set), P).` Con `[a,b,c]` da los 8 subconjuntos.
- **SWISH:** sí
- **Enunciado:** Usando el `subset/2` anterior y `findall/3`, escribir `powerset/2`.

## Capítulo 12: Working With Files

### LPN-12.1 — Escribir un archivo con formato
- **Fuente:** §12.4 Exercises, Ejercicio 12.1. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse55
- **Tema:** X
- **Dificultad:** 1
- **Solución:** propia, verificada: `open('hogwart.houses',write,S), tab(S,7), write(S,gryffindor), nl(S), write(S,hufflepuff), tab(S,5), write(S,ravenclaw), nl(S), tab(S,7), write(S,slytherin), nl(S), close(S).`
- **SWISH:** no (SWISH no permite escribir archivos en disco)
- **Enunciado:** Crear el archivo `hogwart.houses` con los cuatro nombres de las casas dispuestos en forma de rombo, usando `open/3`, `close/1`, `tab/2`, `nl/1` y `write/2`.

### LPN-12.2 — Contar frecuencias de palabras de un archivo
- **Fuente:** §12.4, Ejercicio 12.2. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse55
- **Tema:** 10, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no (lee archivos locales)
- **Enunciado:** Leer un archivo de texto palabra por palabra (con el `readWord/2` definido en §12.3) y guardar cada palabra con su frecuencia en un predicado dinámico `word/2`.
- **Notas:** `readWord/2` no es predefinido: está en el texto del capítulo. En SWI-Prolog moderno es más simple `read_file_to_string/3` más `split_string/4`.

### LPN-PS12.1 — Banco de pruebas para una DCG (pasos 1 a 7)
- **Fuente:** §12.5 Practical Session. https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse56
- **Tema:** A, X
- **Dificultad:** 3
- **Solución:** no
- **SWISH:** no (módulos y archivos)
- **Enunciado:** Convertir la DCG de LPN-PS8.2 y el `pptree` de LPN-PS9.2 en módulos. Escribir `test/2`, que analiza oraciones leídas de un archivo y escribe los árboles resultantes en otro archivo. Después aceptar oraciones como texto plano terminado en punto y comparar el resultado obtenido con el esperado, anotado en el archivo de entrada.
- **Notas:** Es un proyecto integrador que queda fuera del alcance del curso. Sirve como referencia de módulos (`module/2`, `use_module/1`).
