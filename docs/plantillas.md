# Plantillas

La mayor parte de los programas Prolog se construye con un conjunto reducido de
formas que se repiten. Una vez identificadas, escribir un predicado consiste en
seleccionar la forma adecuada y completarla con las relaciones del problema.

Esta página las reúne. Cada plantilla se presenta por primera vez en el capítulo
donde se la necesita, con un ejemplo concreto; aquí figuran sin el ejemplo, para
consultarlas y compararlas. Son quince, todas de la parte I: las partes
siguientes no agregan plantillas, sino los [patrones](patrones.md).

Cada plantilla es un **esquema**: un programa en el que las partes que cambian
de un uso a otro —el nombre del predicado, la condición, el caso base— se
reemplazan por nombres genéricos como `p`, `procesar` o `CasoBase`. El ejemplo
del capítulo que la presenta es un caso particular del esquema, y un predicado
nuevo se obtiene al dar a cada nombre genérico el valor que el problema
requiere. La distinción entre el programa concreto que ilustra una técnica y el
esquema que lo generaliza proviene de P. Brna y otros, «Prolog programming
techniques» (1991), el artículo que la introducción de los
[patrones](patrones.md) cita como antecedente.

Un predicado rara vez sigue una sola plantilla: por lo general combina varias.
`sin_los_vistos/3`, del [capítulo 15](capitulo-15-control/index.md#154-once1-e-ignore1), recorre una lista (plantilla 9),
construye el resultado a medida que la recorre (plantilla 12), lleva en un
acumulador los elementos ya vistos (plantilla 13) y, para cada elemento, elige
entre dos casos que no se superponen (plantilla 14, escrita con el condicional).
Reconocer las plantillas que componen un predicado facilita tanto escribirlo
como leerlo.

!!! tip "Modo de uso"
    Ante un ejercicio, conviene determinar primero qué datos se conocen y qué
    resultado se necesita. La respuesta corresponde, en la mayoría de los casos,
    a una de estas plantillas.

## 1 — Consultar por una respuesta, o por todas

**Cuándo**: se conoce una parte de la relación y se necesita la otra.

```prolog
?- relacion(dato_conocido, Incognita).
```

La primera respuesta se obtiene de manera directa; las siguientes se solicitan
con `;`. Si solo interesa saber si existe alguna respuesta, y no cuál es, se usa
`_` en lugar de la variable.

Capítulo 2, [sección 2.6](capitulo-02-hechos-consultas-y-variables/index.md#26-variables).

## 2 — Derivar una relación de otra

**Cuándo**: se dispone de una relación y se necesita otra que se obtiene de
ella, con menos argumentos o con los argumentos en otro orden.

```prolog
nueva(X) :-
    vieja(X, _).
```

Capítulo 3, [sección 3.3](capitulo-03-reglas-y-conjunciones/index.md#33-reglas).

## 3 — Encadenar dos relaciones

**Cuándo**: se conoce A, se necesita C, y existe una relación entre A y B y otra
entre B y C.

```prolog
nueva(A, C) :-
    primera(A, B),
    segunda(B, C).
```

El elemento central es `B`: aparece dos veces, y por eso debe tener el mismo
valor en los dos objetivos.

Capítulo 3, [sección 3.3](capitulo-03-reglas-y-conjunciones/index.md#33-reglas).

## 4 — Definir por casos

**Cuándo**: la relación se cumple por una condición **o** por otra.

```prolog
p(X) :-
    primer_caso(X).
p(X) :-
    otro_caso(X).
```

Cada cláusula es una alternativa completa. Si se cumple más de una, se obtiene
más de una respuesta.

Capítulo 3, [sección 3.3](capitulo-03-reglas-y-conjunciones/index.md#33-reglas).

## 5 — Filtrar: generar y después comprobar

**Cuándo**: se necesitan los elementos que cumplen una condición. Primero se
genera un candidato; después se lo verifica.

```prolog
nueva(X) :-
    candidato(X),
    condicion(X).
```

El orden es significativo: la condición se verifica sobre una variable que ya
tiene valor.

Capítulo 3, secciones [3.1](capitulo-03-reglas-y-conjunciones/index.md#31-conjunciones) y [3.3](capitulo-03-reglas-y-conjunciones/index.md#33-reglas).

## 6 — Exigir que dos valores sean distintos

**Cuándo**: una regla usa dos veces la misma relación, y ambos usos pueden
resolverse con el mismo valor.

```prolog
nueva(A, B) :-
    relacion(P, A),
    relacion(P, B),
    A \== B.
```

Se ubica al final, cuando `A` y `B` ya tienen valor.

Capítulo 3, [sección 3.5](capitulo-03-reglas-y-conjunciones/index.md#35-una-regla-que-produce-respuestas-de-mas).

## 7 — Extraer un componente de un término

**Cuándo**: se dispone de un término con estructura y se necesita uno de sus
componentes.

```prolog
parte(estructura(_, Componente, _), Componente).
```

Es un hecho, sin cuerpo. En la cabeza se escribe el patrón: variables en las
posiciones de interés, `_` en todas las demás. El trabajo lo realiza la
unificación.

Capítulo 4, [sección 4.10](capitulo-04-terminos-y-unificacion/index.md#410-extraer-los-componentes-de-un-termino).

## 8 — Caso base y caso recursivo

**Cuándo**: se debe repetir una operación una cantidad de veces que no se conoce
de antemano.

```prolog
p(CasoMinimo) :-
    solucion_directa.
p(CasoGeneral) :-
    un_paso(CasoGeneral, CasoMenor),
    p(CasoMenor).
```

El caso base se escribe primero: con el caso base escrito último, el predicado
puede responder bien la primera vez y no terminar al solicitar las respuestas
siguientes, o al usarlo para generar. En el caso recursivo, el objetivo que
reduce el problema se escribe **antes** de la llamada recursiva; de lo
contrario, el programa no termina.

Capítulo 6, [sección 6.2](capitulo-06-recursion/index.md#62-caso-base-y-caso-recursivo).

## 9 — Recorrer una lista

**Cuándo**: se deben examinar los elementos de una lista, de a uno por vez.

```prolog
%!  p(+L) is det.
%
%   Procesa cada elemento de L.
p([]) :-
    caso_de_la_lista_vacia.
p([Primero|Resto]) :-
    procesar(Primero),
    p(Resto).
```

El caso base es la lista vacía; el caso recursivo extrae el primer elemento y
continúa con el resto. En algunos predicados el caso base se escribe como hecho;
en otros no es necesario escribirlo: si ninguna cláusula unifica con `[]`, el
recorrido termina por falta de cláusulas aplicables.

Capítulo 7, [sección 7.3](capitulo-07-listas/index.md#73-recorrer-una-lista).

## 10 — Buscar un elemento que cumple una condición

**Cuándo**: alcanza con que **alguno** de los elementos cumpla la condición, y
no hace falta examinarlos todos.

```prolog
%!  p(+L) is nondet.
%
%   Algún elemento de L cumple la condición; una respuesta por cada uno.
p([Primero|_]) :-
    cumple(Primero).
p([_|Resto]) :-
    p(Resto).
```

Es distinta de la plantilla 9: en esta el caso base **no** es la lista vacía. La
primera cláusula tiene éxito sin recursión, en cuanto encuentra un elemento que
cumple; la segunda descarta el primer elemento y sigue buscando. Sobre la lista
vacía no hay cláusula aplicable, y por eso la búsqueda fracasa cuando se agota
la lista, que es lo correcto: ninguno cumplió.

Produce una respuesta por cada elemento que cumple la condición.

Capítulo 7, [sección 7.3](capitulo-07-listas/index.md#73-recorrer-una-lista).

## 11 — Todos los elementos cumplen

**Cuándo**: la condición se debe verificar sobre **todos** los elementos.

```prolog
%!  p(+L) is semidet.
%
%   Todos los elementos de L cumplen la condición.
p([]).
p([Primero|Resto]) :-
    cumple(Primero),
    p(Resto).
```

Es la imagen inversa de la plantilla 10, y conviene compararlas: en esta el caso
base es la lista vacía y tiene éxito —sobre una lista sin elementos, "todos
cumplen" es cierto—, y el fracaso se produce en cuanto un elemento no cumple.

Se distingue de la plantilla 9 en que no procesa cada elemento: lo somete a una
prueba, y no produce ningún resultado más allá de cumplirse o no.

Capítulo 7, [sección 7.3](capitulo-07-listas/index.md#73-recorrer-una-lista).

## 12 — Construir una lista durante el recorrido de otra

**Cuándo**: el resultado es una lista que se obtiene al recorrer otra.

```prolog
%!  p(+L, -R) is det.
%
%   R es la lista que resulta de relacionar cada elemento de L con el suyo.
p([], CasoBase).
p([X|Resto], [Y|RestoNuevo]) :-
    relacionar(X, Y),
    p(Resto, RestoNuevo).
```

La lista resultante se escribe en la **cabeza**; no se construye en el cuerpo.
Es la técnica llamada *construcción en la cabeza*. Cada llamada aporta el primer elemento del resultado, y la recursión completa el
resto. Las dos partes que cambian de un predicado a otro son el caso base —qué
resultado corresponde a la lista vacía— y la relación entre cada elemento y el
que ocupa su lugar en el resultado. En `pegar/3`, el caso más simple, cada
elemento pasa sin modificarse y el caso base entrega la segunda lista.

Capítulo 7, [sección 7.5](capitulo-07-listas/index.md#75-construir-una-lista-durante-el-recorrido-de-otra).

## 13 — Acumulador

**Cuándo**: la recursión debe construir un resultado a medida que avanza, en
lugar de hacerlo al retorno de la llamada recursiva.

```prolog
%!  p(+Entrada, -Resultado) is det.
%
%   Resultado se construye a partir de Entrada, elemento por elemento.
p(Entrada, Resultado) :-
    paso_a_paso(Entrada, ValorInicial, Resultado).

%!  paso_a_paso(+L, +Hasta, -Resultado) is det.
%
%   Resultado es Hasta combinado con los elementos de L.
paso_a_paso([], Acumulado, Acumulado).
paso_a_paso([X|Resto], Hasta, Resultado) :-
    combinar(Hasta, X, Ahora),
    paso_a_paso(Resto, Ahora, Resultado).
```

El predicado que invoca el usuario tiene un argumento menos: su función es
proveer el valor inicial. El caso base no realiza ningún cálculo; solo entrega
el valor acumulado. El acumulador no es necesariamente un número: puede ser una
lista que se construye de manera incremental.

Capítulo 8, secciones [8.5](capitulo-08-aritmetica/index.md#85-acumuladores) y [8.6](capitulo-08-aritmetica/index.md#86-un-acumulador-que-no-es-un-numero).

## 14 — Casos que no se superponen

**Cuándo**: una secuencia de casos que se evalúan en orden, de los cuales se
conserva el primero que corresponde.

```prolog
%!  p(+X, -Caso) is det.
%
%   Caso es el primero de los casos que corresponde a X. Caso debe llegar
%   libre.
p(X, primer_caso) :-
    condicion(X),
    !.
p(X, otro_caso) :-
    otra_condicion(X),
    !.
p(_, caso_restante).
```

Cada cláusula termina con `!` a continuación de su condición, y la última no
lleva condición porque cubre todo lo que quedó. Es el uso más frecuente del
corte.

Los casos deben ser **disjuntos y exhaustivos** cuando se los lee de arriba
hacia abajo: si la última cláusula afirma algo que no es cierto por sí solo, el
predicado responde de manera incorrecta en cuanto se lo consulta con el segundo argumento ya
instanciado, porque entonces el corte no llega a ejecutarse.

Capítulo 9, [sección 9.4](capitulo-09-backtracking-y-corte/index.md#94-el-uso-mas-frecuente-casos-que-no-se-superponen).

## 15 — Generar y probar

**Cuándo**: la respuesta no se puede calcular de manera directa, pero sí se
puede verificar si un candidato es una respuesta.

```prolog
%!  solucion(?X) is nondet.
%
%   X es una solución: una respuesta por cada candidato que cumple.
solucion(X) :-
    candidato(X),
    cumple(X).
```

Es la plantilla 5 llevada al caso en que los candidatos se generan de a uno por
vez y son muchos.

Cuando se requiere una sola respuesta, se agrega un corte al final:

```prolog
%!  una_solucion(-X) is semidet.
%
%   X es la primera solución. X debe llegar libre.
una_solucion(X) :-
    solucion(X),
    !.
```

Ese corte establece que la primera respuesta es suficiente. Conviene tener
presente que es un corte **rojo**: si el argumento de salida llega con valor, el
generador lo verifica de manera directa y el corte se ejecuta cuando ya no hay
nada que podar, de modo que el predicado acepta un valor que no es el primero.
Por eso la descripción del encabezado aclara que `X` debe llegar libre: el `-X`
solo no lo dice.

Capítulo 9, [sección 9.6](capitulo-09-backtracking-y-corte/index.md#96-generar-y-probar).
