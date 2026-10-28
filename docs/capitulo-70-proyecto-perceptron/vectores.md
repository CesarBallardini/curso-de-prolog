# Vectores y el esquema del acumulador

Esta página continúa el [capítulo 70](index.md) después de la
[sección 70.5](index.md#705-version-4-un-rasgo-nuevo), con la sección
[70.6](#706-version-5-vectores-y-el-esquema-del-acumulador): las partes
del apartado 1.6 de Csenki que las versiones 1 a 4 no cubren. El ejemplo
está en `vectores.pl`, en `ejemplos/capitulo-70/`, con sus pruebas; carga
`perceptron.pl` y se ejecuta localmente.

## 70.6 Versión 5: vectores y el esquema del acumulador

Csenki escribe la regla del perceptrón con dos
operaciones sobre vectores, el producto por un número y la suma, y deja
como ejercicio definirlas por recursión simple y con acumulador y
comparar las dos formas. Su entrenamiento sigue además un esquema general
de los predicados con acumulador, que el apartado 1.5 de su libro
presenta antes del caso del perceptrón. La quinta versión lo hace y mide
las inferencias: la recursión simple es la más barata, y en Prolog no
necesita acumulador porque construye la lista resultado hacia adelante.
Muestra también que el orden de los argumentos que usa Csenki, con el
número primero, deja una alternativa pendiente que la indexación evita
con la lista primero. Por último, escribe el entrenamiento de a un
ejemplo con el esquema general del acumulador y lo compara con
`iterar/5` del
[capítulo 47](../capitulo-47-proyecto-metodos-numericos/index.md).

### Dos operaciones sobre vectores

La corrección de la regla del perceptrón es una suma de vectores: a los
pesos se les suma el vector `[1|Xs]` multiplicado por el número
K = Tasa·(D − Y). `corregir/4` de la
[sección 70.2](index.md#702-version-1-la-regla-del-perceptron) hace las
dos cosas a la vez con `maplist/4`. Por separado, y por recursión simple,
son dos predicados que recorren las listas elemento por elemento:

<!-- ejemplo: capitulo-70/vectores.pl predicado: escalar_rec/3 sumar_rec/3 -->
```prolog
%!  escalar_rec(+Xs:list(number), +K:number, -Ys:list(number)) is det.
%
%   Ys es el vector Xs multiplicado por el número K, por recursión simple.
escalar_rec([], _, []).
escalar_rec([X|Xs], K, [Y|Ys]) :-
    Y is K * X,
    escalar_rec(Xs, K, Ys).

%!  sumar_rec(+Xs:list(number), +Ys:list(number), -Zs:list(number)) is det.
%
%   Zs es la suma de los vectores Xs e Ys, de igual longitud, por
%   recursión simple.
sumar_rec([], [], []).
sumar_rec([X|Xs], [Y|Ys], [Z|Zs]) :-
    Z is X + Y,
    sumar_rec(Xs, Ys, Zs).
```

Con un acumulador, cada resultado se agrega al frente de una lista
auxiliar, que al final queda en orden inverso y hay que invertir:

<!-- ejemplo: capitulo-70/vectores.pl predicado: escalar_acc/3 escalar_acc/4 sumar_acc/3 sumar_acc/4 -->
```prolog
%!  escalar_acc(+Xs:list(number), +K:number, -Ys:list(number)) is det.
%
%   Como escalar_rec/3, con un acumulador que guarda los productos ya
%   calculados en orden inverso.
escalar_acc(Xs, K, Ys) :-
    escalar_acc(Xs, K, [], Ys).

%!  escalar_acc(+Xs:list, +K:number, +Inv:list, -Ys:list) is det.
%
%   Ys son los productos de Inv, invertidos, seguidos de los de Xs.
escalar_acc([], _, Inv, Ys) :-
    reverse(Inv, Ys).
escalar_acc([X|Xs], K, Inv, Ys) :-
    Y is K * X,
    escalar_acc(Xs, K, [Y|Inv], Ys).

%!  sumar_acc(+Xs:list(number), +Ys:list(number), -Zs:list(number)) is det.
%
%   Como sumar_rec/3, con un acumulador en orden inverso.
sumar_acc(Xs, Ys, Zs) :-
    sumar_acc(Xs, Ys, [], Zs).

%!  sumar_acc(+Xs:list, +Ys:list, +Inv:list, -Zs:list) is det.
%
%   Zs son las sumas de Inv, invertidas, seguidas de las de Xs e Ys.
sumar_acc([], [], Inv, Zs) :-
    reverse(Inv, Zs).
sumar_acc([X|Xs], [Y|Ys], Inv, Zs) :-
    Z is X + Y,
    sumar_acc(Xs, Ys, [Z|Inv], Zs).
```

```prolog
?- escalar_rec([1, 2, 3], 2, Ys).
Ys = [2, 4, 6].

?- escalar_acc([1, 2, 3], 2, Ys).
Ys = [2, 4, 6].
```

Con las dos operaciones, la regla del perceptrón se escribe como la
escribe Csenki: el producto de `[1|Xs]` por K, sumado a los pesos. A
diferencia de `corregir/4`, no pregunta si el ejemplo está bien
clasificado: en ese caso K vale cero y los pesos no cambian de valor,
aunque los enteros pueden pasar a ser números de punto flotante.

<!-- ejemplo: capitulo-70/vectores.pl predicado: corregir_vectores/4 -->
```prolog
%!  corregir_vectores(+Tasa:number, +Ejemplo, +Pesos0:list, -Pesos:list)
%!      is det.
%
%   Como corregir/4, escrito como Pesos = Pesos0 + K·[1|Xs], con
%   K = Tasa·(D - Y). Si el ejemplo está bien clasificado, K es cero y
%   los pesos no cambian de valor.
corregir_vectores(Tasa, ej(Xs, D), Pesos0, Pesos) :-
    salida(Pesos0, Xs, Y),
    K is Tasa * (D - Y),
    escalar_rec([1|Xs], K, Deltas),
    sumar_rec(Pesos0, Deltas, Pesos).
```

```prolog
?- corregir_vectores(1, ej([0, 0], -1), [0, 0, 0], P).
P = [-2, 0, 0].

?- corregir_vectores(0.25, ej([1, 1], 1), [0, 0, 0], P).
P = [0.0, 0.0, 0.0].
```

Una de las pruebas de `vectores.plt` verifica que `corregir_vectores/4`
y `corregir/4` dan los mismos valores con cada ejemplo de los cuatro
conjuntos y tres pesos iniciales distintos.

### El orden de los argumentos

Csenki pone el número primero: `mult(Const, Point, DeltaWs)`. Con ese
orden, la recursión simple deja una alternativa pendiente:

<!-- ejemplo: capitulo-70/vectores.pl predicado: escalar_k/3 -->
```prolog
%!  escalar_k(+K:number, +Xs:list(number), -Ys:list(number)) is det.
%
%   Como escalar_rec/3, con el número primero, en el orden de los
%   argumentos de Csenki. La indexación por el primer argumento no
%   distingue sus dos cláusulas, y la última respuesta deja una
%   alternativa pendiente.
escalar_k(_, [], []).
escalar_k(K, [X|Xs], [Y|Ys]) :-
    Y is K * X,
    escalar_k(K, Xs, Ys).
```

```prolog
?- escalar_k(2, [1, 2, 3], Ys).
Ys = [2, 4, 6] ;
false.
```

La indexación de SWI-Prolog examina en primer lugar el primer argumento,
como explica la
[sección 17.3](../capitulo-17-rendimiento/index.md#173-indexacion). Aquí
ese argumento es el número, que es una variable en las dos cláusulas,
y no permite descartar la primera cuando la lista no es vacía. Con la
lista primero, como en `escalar_rec/3`, la indexación distingue `[]` de
`[X|Xs]`, y la consulta termina sin alternativas. Csenki escribe para
otra versión de SWI-Prolog y no se ocupa de las alternativas, porque
llama a `perceptron/5` desde un predicado que corta después de cada
paso.

### El costo de cada forma

`costos_vectores/2` mide las inferencias de multiplicar un vector de N
elementos por un número y sumarle el resultado, con cada forma:

<!-- ejemplo: capitulo-70/vectores.pl predicado: costos_vectores/2 por/3 mas/3 -->
```prolog
%!  costos_vectores(+N:integer, -Costos:list(pair)) is det.
%
%   Costos son las inferencias que usa escalar un vector de N elementos y
%   sumarlo consigo mismo, por recursión simple, con acumulador y con
%   maplist/3 y maplist/4: pares rec-I, acc-I y maplist-I.
costos_vectores(N, [rec-I1, acc-I2, maplist-I3]) :-
    numlist(1, N, Xs),
    inferencias(( escalar_rec(Xs, 2, Ys1),
                  sumar_rec(Xs, Ys1, _) ), I1),
    inferencias(( escalar_acc(Xs, 2, Ys2),
                  sumar_acc(Xs, Ys2, _) ), I2),
    inferencias(( maplist(por(2), Xs, Ys3),
                  maplist(mas, Xs, Ys3, _) ), I3).

%!  por(+K:number, +X:number, -Y:number) is det.
%
%   Y es K·X.
por(K, X, Y) :-
    Y is K * X.

%!  mas(+X:number, +Y:number, -Z:number) is det.
%
%   Z es X + Y.
mas(X, Y, Z) :-
    Z is X + Y.
```

```prolog
?- costos_vectores(1000, Costos).
Costos = [rec-4004, acc-6010, maplist-6006].
```

La recursión simple es la más barata: dos inferencias por elemento en
cada operación, una para la llamada y otra para `is/2`. El acumulador
agrega la inversión del resultado, una inferencia más por elemento, y
`maplist/3` y `maplist/4` agregan la llamada a `por/3` o a `mas/3` por
cada elemento.

La recursión simple no paga por eso en memoria. La cabeza de la segunda
cláusula de `escalar_rec/3` construye la celda `[Y|Ys]` del resultado
con `Ys` libre, y la llamada recursiva, que es la última meta del cuerpo,
la completa. Es una recursión de cola, que corre en espacio constante
gracias a la optimización de la última llamada de la
[sección 17.2](../capitulo-17-rendimiento/index.md#172-la-pila-y-la-recursion).
En Prolog, una operación que produce una lista no necesita acumulador:
el resultado se construye hacia adelante, con su resto libre. El
acumulador conviene cuando el resultado es un número que la recursión
simple tendría que calcular al retorno de la llamada recursiva, como la
suma de los elementos de un vector; el [ejercicio 13](#ejercicios)
mide esa diferencia.

### El esquema general del acumulador

En el apartado 1.5 de su libro, Csenki observa que los predicados con
acumulador tienen dos cláusulas: una que se detiene, cuando la entrada y
el acumulador cumplen una condición de parada, y otra que transforma
los dos y sigue. Luego generaliza: la entrada y el acumulador se agrupan
en un único **argumento**, que se transforma hasta cumplir la condición
de parada, y del que se **extrae** el resultado. Su entrenamiento del
perceptrón sigue ese esquema con dos términos, `in/5` para el argumento
y `out/2` para el resultado. Con los nombres del curso:

<!-- ejemplo: capitulo-70/vectores.pl predicado: esquema/2 parada/1 extraer/2 transformar/2 entrenar_esquema/5 -->
```prolog
%!  esquema(+Argumento, -Resultado) is det.
%
%   Transforma Argumento hasta que cumple la condición de parada, y
%   extrae de él el Resultado. Argumento es en(Tasa, Ejemplos, Pesos,
%   Pasos) y Resultado es sal(Pesos, Pasos). No termina si los ejemplos
%   no son linealmente separables.
esquema(Arg, Res) :-
    (   parada(Arg)
    ->  extraer(Arg, Res)
    ;   transformar(Arg, Arg1),
        esquema(Arg1, Res)
    ).

%!  parada(+Argumento) is semidet.
%
%   Los pesos de Argumento clasifican bien todos sus ejemplos.
parada(en(_, Ejemplos, Pesos, _)) :-
    maplist(bien_clasificado(Pesos), Ejemplos).

%!  extraer(+Argumento, -Resultado) is det.
%
%   Resultado son los pesos y los pasos de Argumento.
extraer(en(_, _, Pesos, Pasos), sal(Pesos, Pasos)).

%!  transformar(+Argumento0, -Argumento) is det.
%
%   Argumento sigue a Argumento0: los pesos corregidos con el primer
%   ejemplo, ese ejemplo al final de la lista y un paso más.
transformar(en(Tasa, [E|Es], Pesos0, Pasos0), en(Tasa, Es1, Pesos, Pasos)) :-
    corregir_vectores(Tasa, E, Pesos0, Pesos),
    append(Es, [E], Es1),
    Pasos is Pasos0 + 1.

%!  entrenar_esquema(+Nombre:atom, +Tasa:number, +Pesos0:list,
%!                   -Pesos:list, -Pasos:integer) is det.
%
%   Como pasos/5, con esquema/2: el argumento empieza con los ejemplos del
%   conjunto Nombre, los Pesos0 y cero pasos.
entrenar_esquema(Nombre, Tasa, Pesos0, Pesos, Pasos) :-
    datos(Nombre, Ejemplos),
    esquema(en(Tasa, Ejemplos, Pesos0, 0), sal(Pesos, Pasos)).
```

```prolog
?- entrenar_esquema(puntos, 0.25, [0.13, -0.51, -0.35], Pesos, Pasos).
Pesos = [-39.870000000000005, 3.0180000000000176, 4.193500000000006],
Pasos = 801.
```

Son los mismos pesos y los mismos 801 pasos que `pasos/5` de la
[sección 70.2](index.md#702-version-1-la-regla-del-perceptron).
`entrenar_uno/6` es el mismo esquema con el argumento repartido en cuatro
argumentos del predicado; `esquema/2` lo agrupa en un término, y a cambio
de construir un término por paso nombra cada parte del ciclo: qué se
transforma, cuándo se detiene y qué se extrae.

`iterar/5` del
[capítulo 47](../capitulo-47-proyecto-metodos-numericos/index.md), que
usan las versiones 2 y 3, da un paso más. El estado es el argumento del
esquema, y el paso que lo transforma es un parámetro, de modo que un
mismo ciclo sirve para la bisección, para las épocas del perceptrón y
para la detección de ciclos; la condición de parada es fija, un cambio
menor o igual que una tolerancia, y el ciclo agrega un límite de pasos.
El [ejercicio 14](#ejercicios) escribe el esquema de Csenki con
las tres partes como parámetros.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; los entrenamientos que pueden no terminar lo dicen: `entrenar_uno/5` es `det` solo para conjuntos separables, y `entrenar/5` y `entrenar_o_ciclo/4` son `semidet` porque tienen un límite de épocas |
    | C3 | `salida/3` compara la suma antes de unificar la clase, así que `salida(P, Xs, 1)` responde como `salida(P, Xs, C), C = 1`; `aprender/4` y `corregir/4` deciden con la comparación antes de ligar sus salidas |
    | C4 | ningún entrenamiento deja alternativas pendientes; `once/1` elige la posición del peso repetido, que es única |
    | C6 | todo el programa es puro: los pesos y la historia viajan en los argumentos, el ciclo es el del [capítulo 47](../capitulo-47-proyecto-metodos-numericos/index.md) y la tasa es un parámetro |
    | C7 | 80 pruebas en los cinco archivos del programa y 51 en las soluciones; cada afirmación del texto que depende de una ejecución —los 801 pasos, las 102 épocas, los pesos repetidos de la o exclusiva, las catorce y dieciséis funciones— tiene su prueba |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio.

13. ★ **(2)** Escribir `suma_rec/2` y `suma_acc/2`, la suma de los
    elementos de un vector por recursión simple y con acumulador, medir
    sus inferencias con mil elementos, y sumar los números de 1 a 200 000
    con cada una con las pilas limitadas a 12 000 000 de bytes con el
    indicador `stack_limit`. Explicar por qué aquí el acumulador conviene
    y en `escalar_rec/3` de la
    [sección 70.6](#el-costo-de-cada-forma) no.
14. **(2)** Escribir `esquema_general/5`, el esquema del acumulador de la
    [sección 70.6](#el-esquema-general-del-acumulador) con la
    condición de parada, la extracción y la transformación como
    parámetros, y usarlo para entrenar el perceptrón con las partes de
    `vectores.pl` y para calcular el menor elemento de una lista no
    vacía.

## Resumen

| | |
|---|---|
| **perceptrón** | clasifica por el signo de una suma pesada de las entradas más un sesgo |
| **sesgo** | el peso de una entrada fija igual a 1; desplaza la frontera |
| **frontera** | los puntos con suma nula: una recta en el plano, un hiperplano en general |
| **linealmente separable** | un conjunto cuyas clases deja un hiperplano cada una de un lado |
| **regla del perceptrón** | con un ejemplo mal clasificado, cada peso suma Tasa·(D − Y)·Xi |
| **tasa de aprendizaje** | el factor fijo de la corrección |
| **época** | un recorrido completo de los ejemplos; una época sin errores termina el entrenamiento |
| **curva de aprendizaje** | los errores de cada época; no tiene por qué decrecer |
| **ciclo** | los pesos del final de una época repiten los de otra; con pesos enteros, prueba que el conjunto no es separable |
| **rasgo** | una entrada calculada a partir de las originales, que puede volver separable un conjunto |
| `datos/2`, `corregir/4`, `bien_clasificado/2` | los ejemplos, la respuesta y la regla |
| `entrenar_uno/5`, `pasos/5`, `inferencias/2` | la versión 1 y su medición |
| `epoca/5`, `entrenar/5`, `curva/5`, `costos/5` | la versión 2, sobre `iterar/5` del [capítulo 47](../capitulo-47-proyecto-metodos-numericos/index.md) |
| `entrenar_o_ciclo/4`, `probar/2`, `tabla/1`, `no_separables/1` | la versión 3 |
| **[Patrón 68](../patrones.md#68-historia-en-el-estado-del-ciclo)** | historia en el estado del ciclo |
| `rasgos/3`, `ampliar/3`, `aprender/3`, `separables_con/2` | la versión 4 |
| **esquema del acumulador** | un argumento que se transforma hasta cumplir una condición de parada, y del que se extrae el resultado |
| `escalar_rec/3`, `sumar_rec/3`, `escalar_acc/3`, `sumar_acc/3`, `corregir_vectores/4`, `costos_vectores/2`, `entrenar_esquema/5` | la versión 5 |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Umbrales ajustados a partir de datos para separar lo normal de lo anómalo | [capítulo 85](../capitulo-85-proyecto-analisis-registros/index.md) |

## Referencias

- Attila Csenki, *Prolog Techniques*, Ventus Publishing (Bookboon), 2009 —
  apartado 1.6, «Case Study: The Perceptron Training Algorithm», y
  apartado 2.5.2, «The Perceptron Training Algorithm Revisited».
  [Página de la editorial, copia de archivo](https://web.archive.org/web/20220123025207/https://bookboon.com/en/prolog-techniques-applications-of-prolog-ebook?mediaType=ebook).
  Esta página toma del primero el ejercicio de escribir el producto de un
  vector por un número y la suma de vectores por recursión simple y con
  acumulador, y el esquema general de los predicados con acumulador de su
  apartado 1.5.

El código del capítulo es propio, escrito para el curso: de la fuente se
toman la regla, los datos y la idea de la rotación, no el código; las
épocas como plegado, el uso del ciclo del
[capítulo 47](../capitulo-47-proyecto-metodos-numericos/index.md), la
curva de aprendizaje, la detección de ciclos, la medición de las
dieciséis funciones, el rasgo producto y la medición de las dos formas
de las operaciones con vectores son del curso.
