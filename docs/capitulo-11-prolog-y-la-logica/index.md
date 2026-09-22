# Capítulo 11 — Prolog y la lógica

Este capítulo cierra la parte I, y vincula todo su contenido con la asignatura
de lógica.

En los capítulos anteriores se describió a Prolog como un mecanismo de búsqueda
de respuestas: prueba objetivos, recorre cláusulas, retrocede. Esa descripción
es correcta, y corresponde a lo que ocurre durante la ejecución del programa.
Existe una segunda lectura, presente desde el capítulo 1 aunque no se la haya
nombrado: **un programa Prolog es un conjunto de afirmaciones lógicas**, y una
consulta es una pregunta sobre lo que se deduce de ellas.

Las dos lecturas coexisten, y en la mayoría de los casos coinciden. Este
capítulo describe la correspondencia entre ambas, y también los casos en los que
difieren.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- leer una regla como una fórmula lógica, y escribir una fórmula como regla;
- determinar qué cuantificador corresponde a cada variable de una cláusula;
- explicar qué es una cláusula de Horn y por qué Prolog se restringe a ellas;
- describir, en términos generales, el método con el que Prolog prueba una
  consulta;
- identificar las construcciones de Prolog que **no** admiten una lectura
  lógica.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **0:35 h**.
    Resolver los 6 ejercicios marcados con ★: **1:40 h**.
    Resolver los 13 ejercicios del final: **4:10 h**.

## 11.1 Las dos lecturas

La siguiente es una regla del ejemplo de este capítulo:

<!-- ejemplo: capitulo-11/logica.pl predicado: madre/2 consulta: madre(Quien, ana). -->
```prolog
% madre(M, H): para toda M y todo H, si M es mujer y M es progenitora de H,
% entonces M es madre de H.
madre(M, H) :-
    mujer(M),
    progenitor(M, H).
```

La **lectura procedimental** es la que se usó hasta aquí: para probar que M es
madre de H, se prueba que M es mujer, y después se prueba que M es progenitora
de H.

La **lectura declarativa** no hace referencia a ningún procedimiento de prueba:

> Para toda M y todo H: si M es mujer y M es progenitora de H, entonces M es
> madre de H.

En notación simbólica, como en la asignatura de lógica:

$$\forall M \, \forall H \; \bigl( \mathit{mujer}(M) \land \mathit{progenitor}(M, H)
  \rightarrow \mathit{madre}(M, H) \bigr)$$

La fórmula no establece el orden en que se deben probar las condiciones, ni hace
referencia al backtracking. Establece qué es verdadero. Sin embargo, es
exactamente la misma regla.

## 11.2 Los conectivos

La traducción entre ambas notaciones es sistemática. Cuatro correspondencias
cubren la mayor parte de los casos:

| En lógica | En Prolog |
|---|---|
| $\land$ (conjunción) | la coma entre objetivos |
| $\lor$ (disyunción) | varias cláusulas del mismo predicado |
| $\rightarrow$ (implicación) | `:-`, **con los operandos en orden inverso** |
| $\lnot$ (negación) | `\+`, con restricciones (sección 11.6) |

Dos observaciones sobre la tabla.

**`:-` invierte el orden de la implicación.** En lógica se escribe primero el
antecedente y después el consecuente: $\text{condición} \rightarrow \text{conclusión}$. En Prolog se
escribe primero la conclusión: `conclusion :- condicion`. Por eso `:-` se suele
representar como una flecha hacia la izquierda. Es la misma implicación, con los
operandos en orden inverso.

**La disyunción no tiene un símbolo propio.** En la parte I no se usa ningún
operador para la disyunción: se escriben dos cláusulas, y ese conjunto de
cláusulas *es* la disyunción.

<!-- ejemplo: capitulo-11/logica.pl predicado: ascendiente/2 consulta: ascendiente(Quien, luis). -->
```prolog
% ascendiente(A, D): A es progenitor de D, o es progenitor de alguien que a su
% vez es ascendiente de D. La disyunción se expresa con las dos cláusulas.
ascendiente(A, D) :-
    progenitor(A, D).
ascendiente(A, D) :-
    progenitor(A, Medio),
    ascendiente(Medio, D).
```

Su lectura lógica es:

> Para todo A y todo D: A es ascendiente de D si A es progenitor de D, **o** si
> existe alguien de quien A es progenitor y que a su vez es ascendiente de D.

## 11.3 Las variables y los cuantificadores

En una cláusula no se escribe ningún cuantificador; sin embargo, cada variable
tiene uno asociado. La regla es breve:

**Una variable que aparece en la cabeza está cuantificada universalmente**, y el
alcance del $\forall$ es la cláusula completa. Es el caso de `M` y `H` en `madre/2`: la
regla vale para todos sus valores.

**Una variable que aparece solo en el cuerpo está cuantificada
existencialmente**, y el alcance del $\exists$ es el antecedente:

<!-- ejemplo: capitulo-11/logica.pl predicado: tiene_hijos/1 consulta: tiene_hijos(Quien). -->
```prolog
% tiene_hijos(P): para todo P, si existe algún H del que P es progenitor,
% entonces P tiene hijos. H no aparece en la cabeza: es la variable
% cuantificada existencialmente.
tiene_hijos(P) :-
    progenitor(P, _).
```

$$\forall P \; \bigl( \exists H \; \mathit{progenitor}(P, H)
  \rightarrow \mathit{tiene\_hijos}(P) \bigr)$$

"Para todo P: si existe algún H del que P es progenitor, entonces P tiene
hijos." La variable anónima `_` corresponde a la variable cuantificada
existencialmente, y por eso no es necesario darle nombre.

La regla tiene una excepción, y es la del capítulo 10: **una variable que
aparece solo dentro de un `\+` está cuantificada universalmente**, no
existencialmente. Negar "existe algún H" equivale a afirmar "para todo H, no":

$$\lnot \, \exists H \; \mathit{tiene}(P, H)
  \quad \equiv \quad
  \forall H \; \lnot \, \mathit{tiene}(P, H)$$

Es la razón de fondo del problema de ubicación de `\+` de la sección 10.4: al
escribir `\+ tiene(P, _)` no se pregunta si *algún* valor falla, sino si fallan
*todos*.

!!! question "Actividad"
    En `logica.pl`, `tiene_hijos/1` tiene una variable que aparece solo en el
    cuerpo. Ejecutar `tiene_hijos(P).` y solicitar todas las respuestas.
    Contar cuántas se obtienen para cada persona y explicar por qué hay
    repeticiones. Son la marca del $\exists$: Prolog no informa "existe un hijo", sino
    que informa una respuesta por cada hijo que encuentra.

El programa muestra un comportamiento que la fórmula no refleja:

```prolog
?- tiene_hijos(P).
P = juan ;
P = marta ;
P = juan ;
P = marta ;
P = pedro ;
P = pedro.
```

Se obtienen seis respuestas para tres personas. La fórmula establece que juan
tiene hijos, una sola vez; el programa lo establece una vez **por cada
demostración**, y juan tiene dos hijos registrados. Es la primera diferencia
entre las dos lecturas: la lógica establece qué es verdadero; Prolog produce una
respuesta por cada demostración.

## 11.4 Cláusulas de Horn

En lógica se pueden escribir fórmulas de cualquier forma: con varias
disyunciones en el consecuente, con negaciones en cualquier posición, con
cuantificadores anidados. Prolog no admite todas esas formas. Admite una forma
particular, y conocerla explica varias de sus características.

Una **cláusula de Horn** es una implicación con **una única conclusión**:

$$\text{condición}_1 \land \text{condición}_2 \land \dots \land \text{condición}_n
  \rightarrow \text{conclusión}$$

El consecuente contiene un solo átomo lógico, nunca dos.

Esa es exactamente la forma de una regla de Prolog, y los casos límite también
corresponden a construcciones del lenguaje:

- si no hay ninguna condición, queda solo la conclusión: es un **hecho**;
- si no hay conclusión, queda solo un conjunto de condiciones a satisfacer: es
  una **consulta**.

Hechos, reglas y consultas —las tres construcciones que se usan desde el capítulo
2— son los tres casos de una misma forma.

Esto permite releer el árbol de derivación del capítulo 5. Cada uno de sus nodos
es una **consulta**, es decir el tercer caso: una cláusula sin conclusión. Cada
uno de sus arcos está etiquetado con una cláusula de los otros dos casos, un
hecho o una regla. El árbol completo está construido con las tres
construcciones del lenguaje, y con ninguna otra.

### Por qué se usa esa forma

Porque con una única conclusión la demostración es **directa**: para establecer
la conclusión se deben satisfacer las condiciones, y no se requiere nada más.
Prolog no necesita razonar por casos ni formular hipótesis auxiliares.

Si se admitieran dos conclusiones —"llueve $\lor$ está nublado"—, el programa debería
operar con información indefinida: se sabe que una de las dos afirmaciones es
verdadera, pero no cuál. Ese razonamiento tiene un costo computacional mucho
mayor, y el lenguaje resultante ya no sería Prolog.

El costo de la restricción es que algunas afirmaciones no se pueden expresar.
"Toda persona es mayor o menor de edad" no se puede escribir como una cláusula
de Horn. Se puede escribir el predicado que lo determina —como se hizo en el
capítulo 9—, pero no es equivalente: es un programa que decide, y no una
afirmación que se pueda usar en cualquier sentido.

!!! question "Actividad"
    Intentar escribir "todo número es par o impar" como una sola cláusula, con
    la conclusión `par(N) ; impar(N)` a la izquierda de `:-`, y cargar el
    archivo. SWI-Prolog responde:

    ```
    ERROR: No permission to modify static procedure `(;)/2'
    ```

    La causa está a la vista una vez que se la busca: Prolog lee esa cabeza
    como el término `;(par(N), impar(N))`, es decir como una llamada a `;/2`,
    que ya existe. Escribir en dos líneas por qué una cláusula de Horn admite
    la disyunción en el cuerpo y no en la cabeza.

## 11.5 Cómo prueba Prolog

El método de demostración de Prolog tiene una característica poco intuitiva:
para probar que una afirmación es verdadera, comienza por suponer que es
**falsa**.

Ante la consulta `?- madre(marta, ana).`, Prolog agrega a las cláusulas del
programa la negación de la consulta —"marta no es madre de ana"— e intenta
derivar una contradicción. Si la encuentra, la suposición no puede ser
verdadera, y por lo tanto la consulta original sí lo es. El método se denomina
**demostración por refutación**.

La única regla de inferencia que usa es la del capítulo 5: tomar un objetivo,
encontrar una cláusula cuya cabeza unifique con él, y reemplazarlo por el cuerpo
de esa cláusula. Esa regla se denomina **resolución**, y la unificación del
capítulo 4 es la que determina cuándo se la puede aplicar.

En síntesis: **Prolog es resolución sobre cláusulas de Horn, con un recorrido
del árbol de izquierda a derecha y de arriba hacia abajo.** Esa definición resume
toda la parte I, y cada uno de sus términos se desarrolló en un capítulo
anterior.

Cuando el árbol alcanza un objetivo vacío —no queda nada por probar—, la
contradicción está derivada y se produce la respuesta. Las hojas de éxito del
capítulo 5 corresponden exactamente a esa situación.

## 11.6 Lo que excede la lógica

Las dos lecturas coinciden en la mayoría de los casos. Esta sección enumera las
excepciones, que se deben tener presentes cuando un programa produce un
resultado inesperado.

**El orden.** Las fórmulas no tienen orden: $a \land b$ y $b \land a$ son equivalentes.
En Prolog tienen el mismo significado pero distinto comportamiento, y en algunos
casos la diferencia determina si el programa termina o no (capítulo 5).

**El recorrido no alcanza todo lo que el método demuestra.** La resolución de la
sección 11.5 encuentra toda consecuencia del programa. Pero Prolog no explora el
árbol de cualquier manera: lo recorre de izquierda a derecha y de arriba hacia
abajo, y si en el camino hay una rama infinita, nunca llega a las ramas ubicadas
a su derecha. La respuesta se sigue del programa, está en el árbol, y no se
obtiene (sección 5.6). Es la razón de fondo por la cual existe el corte.

**El corte.** `!` sí tiene traducción a la lógica, y es la más simple posible:
se lee como un objetivo que siempre se cumple, de modo que una cláusula con
corte afirma lo mismo que afirmaría sin él. Lo que el corte altera no es la
lectura sino el acuerdo entre la lectura y las respuestas: con un corte rojo, el
programa deja de responder de acuerdo con lo que sus propias cláusulas afirman
(capítulo 9). De ahí la recomendación de escribir primero cláusulas verdaderas y
agregar los cortes después.

**`\+` no es $\lnot$.** La negación lógica establece que una afirmación es falsa; `\+`
establece que no se la pudo probar (capítulo 10). Coinciden solo cuando el
programa contiene toda la información relevante.

**Las respuestas repetidas.** La lógica establece que una afirmación es
verdadera; Prolog produce una respuesta por cada demostración, como se observó
con `tiene_hijos/1`.

**`is/2`.** "X es el resultado de 2+3" se asemeja a una igualdad, pero opera en
un único sentido (capítulo 8). Corresponde a la relación aritmética únicamente
cuando su lado derecho no contiene variables sin valor; fuera de ese caso, el
programa abandona la lógica por completo.

**Los errores.** Todo el curso sostiene que una consulta responde `true.` o
`false.`, y hay un tercer desenlace: `is/2` y las comparaciones aritméticas no
responden ninguna de las dos cuando sus argumentos no tienen valor, sino que
emiten un error. Un error no tiene ninguna contraparte en la lógica: no es una
afirmación verdadera ni falsa, es la ejecución que se interrumpe.

**La unificación no es exactamente la de la lógica.** Lógicamente no existe
ningún valor que haga idénticos a `X` y a `padre(X)`: el segundo término siempre
tiene un nivel más de anidamiento. Prolog, sin embargo, acepta la unificación:

```prolog
?- X = padre(X).
X = padre(X).
```

Construye un término que se contiene a sí mismo. La comprobación que evitaría
este caso existe, y tiene un costo que las implementaciones prefieren no pagar
en cada unificación. Es la diferencia más silenciosa de esta lista, porque no
produce un error ni una respuesta extraña: produce un término que no
corresponde a ninguna afirmación del programa.

Ninguna de estas diferencias es un defecto: son consecuencia de que el lenguaje,
además de expresar afirmaciones, **se ejecuta**. Conviene conocerlas, porque
cuando un programa produce un resultado inesperado, la causa es con frecuencia
una de ellas.

## Cierre de la parte I

Con este capítulo termina la primera parte del curso. Los contenidos cubiertos
son:

- la escritura de hechos, reglas y consultas, y sus dos lecturas;
- el modelo de búsqueda de Prolog, y su representación como árbol de derivación;
- unificación, recursión, listas y aritmética;
- el corte y la negación, con sus restricciones;
- doce plantillas que cubren la mayor parte de los programas de este nivel.

Los contenidos que la parte II presenta desde su comienzo son: reunir todas las
respuestas de una consulta en una lista, escribir predicados que reciben otros
predicados como argumento, y modificar el programa durante la ejecución. Con
esos tres mecanismos, gran parte de lo que en la parte I se debía escribir de
manera explícita se reduce a una línea.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Escribir en notación lógica, con $\forall$ y $\land$, la regla `padre/2` del
   ejemplo.
2. **(1)** Traducir a Prolog: "para todo X, si X es un gato entonces X es un
   animal".
3. ★ **(2)** ¿Qué cuantificador corresponde a cada variable de la siguiente regla?

    ```prolog
    tiene_nieto(A) :-
        progenitor(A, P),
        progenitor(P, _).
    ```

4. **(2)** Escribir como cláusulas de Horn: "una persona puede entrar si es
   socia, o si la invita un socio".
5. ★ **(2)** ¿Por qué "todo número es par o impar" no se puede escribir como una
   única cláusula de Horn? ¿Cómo se lo puede expresar en Prolog de todos modos?
6. **(2)** `ascendiente/2` del ejemplo produce tres respuestas para `luis`.
   Escribir la fórmula lógica que corresponde a las dos cláusulas en conjunto.
7. **(3)** El siguiente programa y la siguiente fórmula no tienen el mismo
   significado. Identificar la diferencia:

    ```prolog
    sin_mascota(P) :-
        persona(P),
        \+ tiene(P, _).
    ```

    $$\forall P \; \bigl( \mathit{persona}(P) \land \lnot \, \exists M \; \mathit{tiene}(P, M)
  \rightarrow \mathit{sin\_mascota}(P) \bigr)$$

8. **(3)** Elegir un predicado de cualquier capítulo anterior, escribir su
   lectura declarativa, e indicar si el programa cumple exactamente lo que la
   fórmula afirma.
9. ★ **(1)** Escribir la lectura declarativa de cada una de estas cláusulas,
   indicando el cuantificador de cada variable:

    ```prolog
    % a
    abuelo(A, N) :- padre(A, P), padre(P, N).
    % b
    tiene_mascota(P) :- tiene(P, _).
    % c
    varon(juan).
    ```
10. **(2)** Traducir a cláusulas de Prolog, o explicar por qué no se puede:

    a. "Todo el que tiene un gato tiene una mascota."
    b. "Nadie es padre de sí mismo."
    c. "Toda persona es varón o mujer."
11. ★ **(2)** De las cinco diferencias que enumera la sección 11.6, indicar cuál
    explica cada uno de estos comportamientos:

    a. `?- categoria(sofia, adulto).` responde `true.`
    b. `?- tiene_hijos(P).` informa dos veces a `juan`.
    c. `?- X is 3 + Y.` no responde `true.` ni `false.`
    d. Un programa correcto no produce una respuesta que sus cláusulas afirman.
12. **(2)** La sección 11.4 afirma que un hecho es una cláusula de Horn sin
    condiciones y una consulta es una cláusula de Horn sin conclusión. Escribir
    la fórmula que corresponde a la consulta `?- padre(juan, Quien).` y explicar
    en qué sentido Prolog la **refuta** en lugar de demostrarla.
13. ★ **(3)** El programa siguiente tiene una lectura declarativa impecable y un
    comportamiento inútil. Escribir su lectura, explicar por qué es verdadera, y
    decir qué elemento de la sección 11.6 lo explica:

    ```prolog
    ascendiente(A, D) :-
        ascendiente(A, X),
        progenitor(X, D).
    ascendiente(A, D) :-
        progenitor(A, D).
    ```

## Resumen

| | |
|---|---|
| **lectura procedimental** | qué hace Prolog para responder una consulta |
| **lectura declarativa** | qué afirma el programa |
| `,` | $\land$ |
| varias cláusulas | $\lor$ |
| `:-` | $\rightarrow$, con los operandos en orden inverso |
| variable en la cabeza | $\forall$, con alcance sobre toda la cláusula |
| variable solo en el cuerpo | $\exists$, con alcance sobre el antecedente |
| **cláusula de Horn** | una implicación con una única conclusión |
| hecho, regla, consulta | los tres casos de la misma forma |
| **resolución** | reemplazar un objetivo por el cuerpo de una cláusula cuya cabeza unifica con él |
| **refutación** | probar una afirmación suponiendo su negación y derivando una contradicción |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Reunir todas las respuestas de una consulta | capítulo 15 |
| Predicados que reciben predicados como argumento | capítulo 16 |
| Programas que se modifican durante la ejecución | capítulo 17 |
| Gramáticas, que son cláusulas con otra notación | capítulo 19 |
| Metaintérpretes: un intérprete de Prolog escrito en Prolog | capítulo 25 |
| Restricciones, donde la lectura declarativa vuelve a ser exacta | capítulo 32 |
