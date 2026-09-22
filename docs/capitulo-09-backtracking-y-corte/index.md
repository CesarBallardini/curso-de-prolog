# Capítulo 9 — Backtracking y corte

En los capítulos anteriores, el backtracking fue un mecanismo que Prolog
aplicaba de manera automática, sin intervención de quien escribe el programa.
Este capítulo presenta la única construcción que permite **intervenir** en él:
el corte, que se escribe `!`.

El corte indica a Prolog que descarte determinadas alternativas de búsqueda.
Usado correctamente, reduce el trabajo del programa y expresa su intención con
mayor claridad. Usado incorrectamente, hace que el programa produzca respuestas
falsas, y origina algunos de los errores más difíciles de localizar en Prolog.
El capítulo trata ambos aspectos.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- interpretar el corte como una poda del árbol de derivación;
- determinar con precisión qué ramas se descartan cuando la ejecución pasa por
  un `!`;
- usar el corte para definir casos que no se superponen;
- distinguir un corte que solo reduce el trabajo de uno que modifica lo que el
  programa afirma;
- escribir un predicado de generar y probar que se detenga en la primera
  respuesta.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **0:30 h**.
    Resolver los 7 ejercicios marcados con ★: **2:00 h**.
    Resolver los 15 ejercicios del final: **5:00 h**.

## 9.1 Un programa que produce respuestas de más

Las tres reglas siguientes clasifican a una persona según su edad. Están
escritas de modo que las condiciones **se superponen**: un bebé también cumple
la condición de chico, y toda persona cumple la de adulto.

<!-- ejemplo: capitulo-09/corte.pl predicado: categoria_sin_corte/2 consulta: categoria_sin_corte(sofia, C). -->
```prolog
% categoria_sin_corte(P, C): las tres condiciones se superponen deliberadamente.
categoria_sin_corte(P, bebe) :-
    edad(P, A),
    A < 4.
categoria_sin_corte(P, chico) :-
    edad(P, A),
    A < 13.
categoria_sin_corte(P, adulto) :-
    edad(P, _).
```

Sofía tiene tres años, por lo tanto:

```prolog
?- categoria_sin_corte(sofia, C).
C = bebe ;
C = chico ;
C = adulto.
```

Se obtienen tres respuestas, y las tres se deducen del programa. El programa no
es incorrecto: expresa algo distinto de lo que se pretendía. La intención era
"evaluar las condiciones en orden y conservar la primera que se cumple", pero
esa condición no está escrita en el programa.

El árbol de derivación del capítulo 5 lo muestra de manera directa: tres ramas
terminan en una hoja de éxito, y por eso hay tres respuestas.

## 9.2 El corte poda el árbol

El corte es un objetivo que se escribe `!` y que **siempre se cumple**. Su
función no es producir una respuesta, sino el efecto que tiene su ejecución:
indica a Prolog que descarte determinadas ramas del árbol.

<!-- ejemplo: capitulo-09/corte.pl predicado: categoria/2 consulta: categoria(sofia, C). -->
```prolog
% categoria(P, C): la misma clasificación, con corte. El corte descarta las
% cláusulas siguientes.
categoria(P, bebe) :-
    edad(P, A),
    A < 4,
    !.
categoria(P, chico) :-
    edad(P, A),
    A < 13,
    !.
categoria(P, adulto) :-
    edad(P, _).
```

```prolog
?- categoria(sofia, C).
C = bebe.
```

Se obtiene una sola respuesta, sin alternativas pendientes: la respuesta termina
en punto. Las otras dos ramas fueron descartadas.

En términos del modelo de cajas de la sección 5.3, el corte **inhabilita la
puerta Redo**: los objetivos que quedaron a su izquierda ya no se pueden
reingresar para pedirles otra solución, y la caja del predicado tampoco puede
ofrecer una cláusula distinta. Por eso el efecto se nota recién cuando algo
falla más adelante y la ejecución intenta retroceder.

## 9.3 Qué poda exactamente

Esta sección requiere especial atención, porque el corte no poda simplemente "lo
que sigue". Cuando la ejecución pasa por un `!` dentro de una cláusula, se
descartan dos conjuntos de alternativas:

1. **las cláusulas siguientes** del mismo predicado, **para esta invocación**.
   Una vez que la ejecución pasó el corte de esta cláusula, la elección es
   definitiva: las cláusulas posteriores no se evalúan.
2. **las alternativas de los objetivos ubicados a la izquierda del corte**,
   dentro de la misma cláusula. Las soluciones ya elegidas para esos objetivos
   quedan fijas.

El corte **no** poda:

- los objetivos ubicados a su **derecha**, que pueden producir varias respuestas
  y participar del backtracking con normalidad;
- las alternativas **externas** al predicado, es decir, las del predicado que lo
  invocó.

En `categoria/2` ese efecto es suficiente. Cuando la consulta sobre sofía ingresa
por la primera cláusula y alcanza el `!`, se descartan las otras dos cláusulas y
también la posibilidad de reingresar a `edad(P, A)` para buscar otra edad. Queda
una sola rama, y por eso hay una sola respuesta.

La precisión "para esta invocación" no importa en `categoria/2`, que no es
recursivo, pero es decisiva en cuanto el predicado se llama a sí mismo. El corte
no desactiva las cláusulas del predicado de una vez y para siempre: descarta las
alternativas **de la llamada que entró en esta cláusula**. Una llamada recursiva
posterior vuelve a considerar todas las cláusulas desde la primera, y la llamada
externa que produjo esta tampoco se ve afectada. Cada invocación tiene sus
propias alternativas, y el corte solo alcanza a las suyas.

!!! question "Actividad"
    Eliminar el `!` de la primera cláusula de `categoria/2` y conservar los otros
    dos. ¿Cuántas respuestas produce `categoria(sofia, C).`? Determinarlo con
    las dos reglas anteriores antes de ejecutar la consulta.

## 9.4 El uso más frecuente: casos que no se superponen

El caso de `categoria/2` es, con amplia diferencia, el uso más frecuente del
corte: una secuencia de casos que se evalúan en orden, de los cuales se conserva
el primero que corresponde.

Se reconoce por su forma. Cada cláusula termina con `!` a continuación de su
condición, y la última no tiene condición, porque cubre todos los casos
restantes.

No es la única forma de escribirlo. Las mismas tres categorías se pueden definir
con las condiciones completas —`A >= 4, A < 13` para chico, como en el capítulo
1—, y en ese caso no se requiere ningún corte. Esa versión es más extensa y
repite información; la versión con corte es más breve y depende del orden de las
cláusulas.

La diferencia es relevante: la versión con condiciones completas tiene el mismo
significado cualquiera sea el orden de lectura de sus cláusulas; la versión con
corte solo tiene el significado pretendido si se la lee de arriba hacia abajo.

!!! abstract "Plantilla 14 — Casos que no se superponen"
    **Cuándo**: una secuencia de casos que se evalúan en orden, de los cuales se
    conserva el primero que corresponde.

    ```prolog
    p(X, primer_caso) :-
        condicion(X),
        !.
    p(X, otro_caso) :-
        otra_condicion(X),
        !.
    p(_, caso_restante).
    ```

    Los casos deben ser **disjuntos y exhaustivos** leídos de arriba hacia
    abajo. La última cláusula es la que hay que mirar con cuidado: como no tiene
    condición, afirma su caso para todo lo que llegue hasta ella, y si eso no es
    cierto por sí solo, el predicado responde mal en cuanto se lo consulta con
    el segundo argumento ya instanciado. La sección 9.5 muestra exactamente ese
    problema.

    **En este capítulo se usa en**: `categoria/2` (9.2).

## 9.5 Corte verde y corte rojo

Esta sección describe el riesgo principal del corte.

Un corte que no modifica el **conjunto** de respuestas del programa se denomina
**corte verde**. Poda ramas que no aportan ninguna respuesta nueva: o bien no
producirían ninguna, o bien producirían una que ya se obtuvo. Eliminarlo deja
las mismas respuestas; lo que cambia es la eficiencia y, en algunos casos, que
una respuesta se repita.

Un corte que hace que el programa produzca respuestas distintas de las que
produciría sin él se denomina **corte rojo**. El de `categoria/2` es rojo, y se
lo comprueba con una consulta de otra forma:

```prolog
?- categoria(sofia, adulto).
true.
```

Sofía tiene tres años, y el programa la clasifica como adulta.

La causa es que el corte no llega a ejecutarse. Prolog evalúa las cláusulas en
orden y, antes de ejecutar el cuerpo, intenta unificar la cabeza:
`categoria(sofia, adulto)` no unifica con `categoria(P, bebe)`, de modo que esa
cláusula se descarta de inmediato, sin alcanzar el `!`. Lo mismo ocurre con la
cláusula de chico. La tercera, `categoria(P, adulto)`, unifica, y solo exige que
sofía tenga una edad registrada.

Por lo tanto, el corte tiene efecto cuando el segundo argumento está libre, y no
lo tiene cuando está instanciado. El programa responde de manera correcta una
consulta e incorrecta la otra.

Conviene además mirar el programa como un conjunto de afirmaciones, sin tener en
cuenta el orden. La tercera cláusula dice que toda persona con una edad
registrada es adulta, y eso es falso: es una afirmación incorrecta, y está
escrita en la cláusula que **no** lleva corte. Las dos primeras cláusulas no la
contradicen; se limitan a llegar antes. Mientras el corte se ejecuta, la
afirmación falsa queda tapada; cuando no se ejecuta, queda a la vista.

**Regla práctica**: todo predicado que contenga un corte se debe verificar con
los argumentos instanciados, y no solo con variables. Si se requiere que el
predicado funcione en ambos sentidos, corresponde escribir las condiciones
completas en lugar de depender del orden de las cláusulas.

!!! warning "El corte y la lectura lógica"
    Todos los programas hasta el capítulo 8 se podían leer como afirmaciones
    lógicas, con independencia de cómo Prolog los ejecuta. Con el corte esa
    lectura sigue existiendo: `!` se lee como un objetivo que siempre se cumple,
    de modo que una cláusula con corte afirma exactamente lo mismo que afirmaría
    sin él. Lo que el corte rompe no es la lectura sino el **acuerdo** entre la
    lectura y las respuestas: con un corte rojo, el programa deja de responder
    de acuerdo con lo que sus propias cláusulas afirman.

    De ahí la manera recomendada de trabajar: escribir primero un programa cuyas
    cláusulas sean todas verdaderas, y recién después agregarle cortes para
    evitar trabajo. Con ese orden, la anomalía de `categoria/2` no se produce,
    porque la tercera cláusula nunca se habría escrito de esa forma.

## 9.6 Generar y probar

Existe una técnica de resolución de problemas que se expresa de manera natural
en Prolog, y que se anticipó en el capítulo 8: cuando la respuesta no se puede
calcular de manera directa, **se generan candidatos y se verifica cada uno**.

Se escribe en dos partes: un objetivo que produce las posibilidades, y otro que
determina si cada posibilidad cumple la condición.

<!-- ejemplo: capitulo-09/generar.pl predicado: multiplo/3 consulta: multiplo(7, 20, N). -->
```prolog
% multiplo(De, Desde, N): N es un múltiplo de De, mayor o igual que Desde.
% between/3 genera los candidatos y la condición con mod los verifica.
multiplo(De, Desde, N) :-
    between(Desde, 200, N),
    0 =:= N mod De.
```

`between/3` genera los números de a uno por vez; la condición con `mod` los
verifica. Cuando un candidato no cumple la condición, el backtracking reingresa
a `between/3` y obtiene el siguiente. El programa no requiere ninguna
instrucción adicional para ello: es el modelo de ejecución de Prolog.

```prolog
?- multiplo(7, 20, N).
N = 21 ;
N = 28 ;
N = 35 ;
...
```

Cuando solo se requiere **la primera** respuesta, se agrega un corte:

<!-- ejemplo: capitulo-09/generar.pl predicado: primer_multiplo/3 consulta: primer_multiplo(7, 20, N). -->
```prolog
% primer_multiplo(De, Desde, N): N es el primero de esos múltiplos, y solo él.
primer_multiplo(De, Desde, N) :-
    multiplo(De, Desde, N),
    !.
```

```prolog
?- primer_multiplo(7, 20, N).
N = 21.
```

Este uso del corte es adecuado **mientras el tercer argumento llegue sin
valor**. Con `N` libre, `multiplo/3` produce los candidatos en orden, el corte
descarta los siguientes, y la primera respuesta sigue siendo la primera.

Con `N` ya instanciado, en cambio, reaparece exactamente el problema de la
sección 9.5:

```prolog
?- primer_multiplo(7, 20, 28).
true.
```

El programa afirma que 28 es el **primer** múltiplo de 7 a partir de 20, y no lo
es. La causa es la misma que en `categoria/2`: el corte no interviene para
impedirlo, porque `multiplo(7, 20, 28)` se cumple de manera directa —28 está en
el rango y es múltiplo de 7— y el `!` se ejecuta después, cuando ya no hay nada
que podar.

Es decir que este corte es **rojo**, aunque a primera vista parezca inofensivo.
Conviene anotarlo en el comentario del predicado: `primer_multiplo/3` responde
correctamente cuando su tercer argumento llega libre, y no se lo debe usar para
verificar un valor dado.

!!! abstract "Plantilla 15 — Generar y probar"
    **Cuándo**: la respuesta no se puede calcular de manera directa, pero sí se
    puede verificar si un candidato es una respuesta.

    ```prolog
    solucion(X) :-
        candidato(X),
        cumple(X).
    ```

    Cuando se requiere una sola respuesta, se agrega un corte al final:

    ```prolog
    una_solucion(X) :-
        solucion(X),
        !.
    ```

    Ese corte es **rojo**, aunque su uso sea habitual: si `X` llega con valor,
    el generador lo verifica de manera directa y el corte se ejecuta cuando ya
    no queda nada que podar, de modo que el predicado acepta un candidato que
    no es el primero. Corresponde documentar que el argumento de salida debe
    llegar libre.

    **En este capítulo se usa en**: `multiplo/3` y `primer_multiplo/3` (9.6),
    `dos_que_suman/3` (ejercicios). Las demás plantillas están en
    [esta página](../plantillas.md).

La técnica se aplica a problemas de mucha mayor escala que la búsqueda de
múltiplos: ubicar reinas en un tablero, resolver un sudoku, asignar horarios.
Cambian el generador y la condición; la estructura es siempre la misma. El
capítulo 33 la retoma con problemas de mayor complejidad, y el capítulo 32
presenta una técnica que la hace mucho más eficiente.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Con `corte.pl`, ¿qué responde `categoria(luis, C).`? ¿Y
   `categoria_sin_corte(luis, C).`?
2. **(1)** ¿Qué efecto tiene el `!` de `un_mayor_de_edad/1`? Eliminarlo y
   comparar los resultados.
3. **(2)** Escribir `categoria_sin_ningun_corte/2`: las mismas tres categorías,
   con una sola respuesta por persona y sin usar `!`.
4. ★ **(2)** ¿Cuál de las dos versiones del ejercicio anterior responde de manera
   correcta `categoria(sofia, adulto)`? Verificarlo.
5. ★ **(2)** Escribir `primer_par(L, X)`: X es el primer número par de la lista L.
6. **(2)** Escribir `hay_algun_menor(L)`: se cumple si algún número de `L` es
   menor que 18. ¿Requiere corte?
7. **(2)** Con `generar.pl`, ¿por qué `dos_que_suman(49, A, B)` produce dos
   respuestas en lugar de una? ¿Cómo se puede lograr que produzca una sola?
8. **(3)** Escribir `primer_cuadrado_mayor(N, C)`: C es el primer número cuyo
   cuadrado es mayor que `N`, con la búsqueda a partir de 1.
9. ★ **(3)** El siguiente predicado tiene un corte rojo. Identificarlo, indicar qué
   consulta responde de manera incorrecta, y corregirlo:

    ```prolog
    descuento(Edad, 50) :-
        Edad < 12,
        !.
    descuento(Edad, 30) :-
        Edad >= 65,
        !.
    descuento(_, 0).
    ```

10. **(3)** Escribir `sin_repetidos(L, R)`: `R` es `L` sin elementos repetidos,
    conservando la primera aparición de cada uno.
11. ★ **(1)** Sobre el programa siguiente, predecir cuántas respuestas produce
    cada consulta, antes de ejecutarlas:

    ```prolog
    color(rojo).
    color(verde).
    color(azul).

    primero(C) :-
        color(C),
        !.
    ```

    `color(C).` · `primero(C).` · `primero(verde).` · `primero(rojo).`

    La tercera es la que conviene pensar con cuidado.
12. ★ **(2)** Seguir a mano `?- categoria(luis, C).` sobre `corte.pl`,
    completando una tabla con una fila por paso, e indicando en cuál de ellos se
    ejecuta el `!` y qué alternativas descarta:

    | Objetivo que se intenta | Qué hace Prolog | Alternativas que quedan |
    |---|---|---|
    | | | |
13. **(2)** El predicado siguiente usa un corte dentro de una recursión.
    Determinar, con las reglas de la sección 9.3, si el corte afecta a las
    llamadas recursivas, y verificarlo ejecutando `primer_par([1, 3, 4, 6], X).`

    ```prolog
    primer_par([X|_], X) :-
        0 =:= X mod 2,
        !.
    primer_par([_|Resto], X) :-
        primer_par(Resto, X).
    ```
14. ★ **(2)** Escribir `clasificar(N, C)` con la plantilla 14, que se cumpla con
    `C = negativo`, `C = cero` o `C = positivo` según corresponda. Después
    ejecutar `clasificar(5, negativo).` y explicar el resultado a la luz de la
    sección 9.5.
15. **(3)** Escribir las pruebas de `primer_multiplo/3` de la sección 9.6 que
    distingan un corte verde de uno rojo: una que verifique la respuesta, una
    que verifique que **no** hay una segunda respuesta, y una que muestre qué
    ocurre al consultar con el tercer argumento ya instanciado.

## Resumen

| | |
|---|---|
| `!` | se cumple siempre, y poda ramas del árbol de derivación |
| qué poda | las cláusulas siguientes del predicado, y las alternativas de los objetivos a su izquierda |
| qué no poda | los objetivos a su derecha, ni las alternativas externas al predicado |
| **corte verde** | no modifica el conjunto de respuestas; eliminarlo solo cuesta trabajo, y puede hacer que alguna se repita |
| **corte rojo** | modifica las respuestas del programa; requiere verificación cuidadosa |
| **generar y probar** | un objetivo produce candidatos y otro los verifica |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| `\+`, que se define internamente con un corte | capítulo 10 |
| `->` y `;`, que expresan lo mismo con otra notación | capítulo 13 |
| Cuándo el corte mejora el rendimiento y cuándo lo perjudica | capítulo 14 |
| Generar y probar con restricciones, que descarta antes de generar | capítulo 32 |
| Búsquedas de mayor escala: reinas, laberintos, juegos | capítulo 33 |
