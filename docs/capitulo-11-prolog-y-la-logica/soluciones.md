# Soluciones del capítulo 11 — Prolog y la lógica

El código de esta página está en `ejemplos/capitulo-11/soluciones.pl` y pasa sus
pruebas.

## 1

$$\forall P \, \forall H \; \bigl( \mathit{varon}(P) \land \mathit{progenitor}(P, H)
  \rightarrow \mathit{padre}(P, H) \bigr)$$

Las dos variables aparecen en la cabeza, por lo que ambas están cuantificadas
universalmente, y el alcance del $\forall$ es la cláusula completa.

## 2

<!-- ejemplo: capitulo-11/soluciones.pl predicado: animal/1 consulta: animal(Quien). -->
```prolog
%!  animal(?X) is nondet.
%
%   Para todo X, si X es gato entonces X es animal.
animal(X) :-
    gato(X).
animal(X) :-
    perro(X).
```

La primera cláusula es suficiente para el enunciado; la segunda se agregó para
que el predicado tenga más de un caso. Cada cláusula es una implicación distinta
con la misma conclusión, y en conjunto expresan la disyunción.

## 3

- `A` aparece en la cabeza: es **universal**.
- `P` aparece solo en el cuerpo: es **existencial**.
- `_` también es existencial, y por eso no es necesario darle nombre.

La lectura completa es:

$$\forall A \; \Bigl( \exists P \; \bigl( \mathit{progenitor}(A, P) \land
  \exists N \; \mathit{progenitor}(P, N) \bigr) \rightarrow \mathit{tiene\_nieto}(A) \Bigr)$$

En castellano: A tiene nieto si existe alguien de quien A es progenitor, y que a
su vez es progenitor de alguien.

## 4

<!-- ejemplo: capitulo-11/soluciones.pl predicado: puede_entrar/1 consulta: puede_entrar(Quien). -->
```prolog
%!  puede_entrar(?P) is nondet.
%
%   P es socio, o lo invita un socio. Las dos cláusulas expresan la
%   disyunción.
puede_entrar(P) :-
    socio(P).
puede_entrar(P) :-
    invita(S, P),
    socio(S).
```

$$\forall P \; \bigl( \mathit{socio}(P) \rightarrow \mathit{puede\_entrar}(P) \bigr)$$

$$\forall P \; \Bigl( \exists S \; \bigl( \mathit{invita}(S, P) \land \mathit{socio}(S) \bigr)
  \rightarrow \mathit{puede\_entrar}(P) \Bigr)$$

Son dos cláusulas y dos fórmulas. La disyunción del enunciado no aparece en
ninguna de las dos: está expresada por la existencia de dos cláusulas.

## 5

Porque en "todo número es par o impar" la disyunción está en la **conclusión**:

$$\forall N \; \bigl( \mathit{numero}(N) \rightarrow \mathit{par}(N) \lor \mathit{impar}(N) \bigr)$$

El consecuente tiene dos átomos lógicos, y una cláusula de Horn admite uno solo.
La afirmación establece que se cumple alguna de las dos alternativas sin indicar
cuál, y ese tipo de información indefinida es precisamente lo que Prolog no puede
representar.

En Prolog se escribe algo distinto: un predicado que **decide** cuál de las dos
alternativas corresponde.

<!-- ejemplo: capitulo-11/soluciones.pl predicado: paridad/2 consulta: paridad(7, Que). -->
```prolog
%!  paridad(+N, -P) is det.
%
%   P indica si N es par o impar. No es una afirmación con una disyunción en
%   la conclusión: son dos reglas, cada una con su condición.
paridad(N, par) :-
    0 =:= N mod 2.
paridad(N, impar) :-
    1 =:= N mod 2.
```

No es la misma afirmación. `paridad/2` determina la paridad de un número dado,
pero no afirma que todo número sea par o impar; esa propiedad se deduce de que
las dos condiciones cubren todos los casos, y es un conocimiento de quien escribe
el programa, no del programa.

## 6

$$\forall A \, \forall D \; \bigl( \mathit{progenitor}(A, D) \rightarrow \mathit{ascendiente}(A, D) \bigr)$$

$$\forall A \, \forall D \; \Bigl( \exists M \; \bigl( \mathit{progenitor}(A, M) \land
  \mathit{ascendiente}(M, D) \bigr) \rightarrow \mathit{ascendiente}(A, D) \Bigr)$$

La variable `Medio` del programa aparece solo en el cuerpo, por lo que es
existencial. La segunda fórmula usa `ascendiente` en su propia definición: en
lógica es una definición recursiva, y es tan válida como en Prolog.

## 7

La diferencia está en `\+`.

La fórmula establece $\lnot \, \exists M \; \mathit{tiene}(P, M)$: no existe ninguna mascota de P. Es una
afirmación sobre el dominio.

El programa establece `\+ tiene(P, _)`: **no se puede probar**, con las cláusulas
disponibles, que P tenga una mascota. Es una afirmación sobre el programa.

Ambas coinciden solo si el programa contiene toda la información sobre quién
tiene qué mascota. Con la base del ejemplo, `sin_mascota(luis)` responde `true`,
aunque luis podría tener mascotas que no están registradas en el programa.

<!-- ejemplo: capitulo-11/soluciones.pl predicado: sin_mascota/1 consulta: sin_mascota(Quien). -->
```prolog
%!  sin_mascota(?P) is nondet.
%
%   P es una persona para la que no se puede probar que tenga mascota.
sin_mascota(P) :-
    persona(P),
    \+ tiene(P, _).
```

Es el supuesto de mundo cerrado del [capítulo 10](../capitulo-10-negacion-como-falla/index.md), analizado desde la lógica: `\+`
no es $\lnot$, y por eso la fórmula del enunciado describe al programa solo bajo ese
supuesto.

## 8

El ejercicio admite cualquier predicado; la elección condiciona el resultado. Dos
casos representativos:

`abuelo/2` del [capítulo 3](../capitulo-03-reglas-y-conjunciones/index.md) es el caso simple: su lectura declarativa es exacta.
El programa no tiene corte ni negación, y responde exactamente lo que la fórmula
afirma, con la única salvedad de las respuestas repetidas cuando existe más de
una demostración.

`categoria/2` del [capítulo 9](../capitulo-09-backtracking-y-corte/index.md) es el caso de mayor interés: su lectura declarativa
**no es válida**. La fórmula de la tercera cláusula establece que toda persona
con edad registrada es adulta, y eso es lo que el programa responde a la consulta
`categoria(sofia, adulto)`. El corte no aparece en ninguna fórmula, y por eso la
lectura declarativa y la procedimental dejan de coincidir.

## 9

**a.** `A`, `N` y `P`: las dos primeras aparecen en la cabeza y están
cuantificadas universalmente; `P` aparece solo en el cuerpo y está cuantificada
existencialmente.

$$\forall A \, \forall N \; \Bigl( \exists P \; \bigl( \mathit{padre}(A, P) \land
  \mathit{padre}(P, N) \bigr) \rightarrow \mathit{abuelo}(A, N) \Bigr)$$

"Para todo A y todo N: si existe algún P tal que A es padre de P y P es padre de
N, entonces A es abuelo de N."

**b.** `P` aparece en la cabeza; la variable anónima aparece solo en el cuerpo:

$$\forall P \; \bigl( \exists M \; \mathit{tiene}(P, M) \rightarrow \mathit{tiene\_mascota}(P) \bigr)$$

**c.** No tiene variables, de modo que no lleva ningún cuantificador. Es una
afirmación sobre un objeto determinado:

> varon(juan)

Es el caso límite de la [sección 11.4](index.md#114-clausulas-de-horn): una cláusula de Horn sin condiciones.

## 10

**a.** Se traduce de manera directa. La implicación se escribe como regla, con
la conclusión a la izquierda:

<!-- ejemplo: capitulo-11/soluciones.pl predicado: tiene_mascota/1 tiene_gato/1 consulta: tiene_mascota(Quien). -->
```prolog
%!  tiene_mascota(?P) is nondet.
%
%   Todo el que tiene un gato tiene una mascota. La implicación se escribe como
%   una regla: la conclusión a la izquierda, la condición a la derecha.
tiene_mascota(P) :-
    tiene_gato(P).

tiene_gato(ana).
tiene_gato(eva).
```

**b.** "Nadie es padre de sí mismo" es una **negación**, y no es una cláusula de
Horn: afirma que algo no ocurre. Lo que se puede escribir es el predicado que lo
verifica, con `\+`:

<!-- ejemplo: capitulo-11/soluciones.pl predicado: padre/2 no_es_padre_de_si_mismo/1 consulta: no_es_padre_de_si_mismo(Quien). -->
```prolog
% padre(P, H): P es el padre de H.
padre(luis, eva).

%!  no_es_padre_de_si_mismo(?P) is nondet.
%
%   Nadie es padre de sí mismo. La negación del enunciado se escribe con \+, y
%   no como una cláusula de Horn.
no_es_padre_de_si_mismo(P) :-
    persona(P),
    \+ padre(P, P).
```

Conviene notar la diferencia: el enunciado original es una afirmación sobre el
mundo; lo que se escribe es un predicado que la comprueba caso por caso, bajo la
hipótesis del mundo cerrado del [capítulo 10](../capitulo-10-negacion-como-falla/index.md).

**c.** "Toda persona es varón o mujer" **no** se puede escribir, y es el ejemplo
de la [sección 11.4](index.md#114-clausulas-de-horn): tiene dos conclusiones. Se puede escribir un predicado que
decida el sexo de cada persona, pero eso no es lo mismo: la afirmación original
dice que toda persona es una de las dos cosas sin decir cuál, y una cláusula de
Horn no puede expresar esa indefinición.

## 11

| | Diferencia de 11.6 |
|---|---|
| a. `categoria(sofia, adulto)` responde `true.` | **El corte.** La lectura lógica de las cláusulas sigue existiendo; lo que se rompe es el acuerdo entre esa lectura y las respuestas, porque la tercera cláusula afirma algo falso y el corte no llega a ejecutarse ([capítulo 9](../capitulo-09-backtracking-y-corte/index.md)). |
| b. `tiene_hijos(P)` informa dos veces a `juan` | **Las respuestas repetidas.** La lógica afirma que algo es cierto; Prolog informa una respuesta por cada demostración, y juan tiene dos hijos. |
| c. `X is 3 + Y.` no responde `true.` ni `false.` | **Los errores.** Es el tercer desenlace, y no tiene contraparte lógica: no es una afirmación verdadera ni falsa. |
| d. No se obtiene una respuesta que el programa afirma | **La incompletitud del recorrido.** El método de demostración la alcanza; el orden en que Prolog explora, no. |

## 12

La consulta `?- padre(juan, Quien).` es una cláusula de Horn sin conclusión, es
decir un conjunto de condiciones sin nada que concluir:

$$\exists \mathit{Quien} \; \mathit{padre}(\mathit{juan}, \mathit{Quien})$$

Prolog no intenta demostrar esa fórmula de manera directa. Hace lo contrario:
supone que es **falsa** —que no existe ningún `Quien` que la cumpla— y agrega
esa suposición al programa. Si de esa suma se deduce una contradicción, la
suposición era errónea, y por lo tanto la fórmula original es cierta.

Eso es refutar. La ventaja práctica es la que describe la [sección 11.5](index.md#115-como-prueba-prolog): el
método necesita una sola regla de inferencia, la resolución, y termina cuando
llega a la cláusula vacía, que es la contradicción. Los valores de `Quien` que
aparecen en el camino son la respuesta.

## 13

La lectura declarativa es correcta, y de hecho es la más natural de las dos
posibles:

$$\forall A \, \forall D \; \Bigl( \exists X \; \bigl( \mathit{ascendiente}(A, X) \land
  \mathit{progenitor}(X, D) \bigr) \rightarrow \mathit{ascendiente}(A, D) \Bigr)$$

$$\forall A \, \forall D \; \bigl( \mathit{progenitor}(A, D) \rightarrow \mathit{ascendiente}(A, D) \bigr)$$

"A es ascendiente de D si es ascendiente de alguien que es progenitor de D; y
también si es progenitor de D." Las dos afirmaciones son verdaderas, y juntas
describen exactamente la relación de ascendencia.

El elemento de la [sección 11.6](index.md#116-lo-que-excede-la-logica) que lo explica es **la incompletitud del
recorrido**. La primera cláusula lleva a `ascendiente(A, X)`, que es el mismo
objetivo con otro nombre de variable, de modo que la rama de la izquierda es
infinita. La segunda cláusula —la que responde— está a su derecha, y el
recorrido nunca llega. Las respuestas se siguen del programa y están en el
árbol; lo que falla es el orden en que se lo explora.

Es el mismo programa de la [sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas), leído ahora desde la lógica: ninguna de
sus dos cláusulas es falsa, y aun así no sirve.
