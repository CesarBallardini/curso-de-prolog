# Vectores y el esquema del acumulador

Esta página contiene la sección
[69.6](index.md#696-version-5-vectores-y-el-esquema-del-acumulador) del
[capítulo 69](index.md): las partes del apartado 1.6 de Csenki que las
versiones 1 a 4 no cubren. Csenki escribe la regla del perceptrón con dos
operaciones sobre vectores, el producto por un número y la suma, y deja
como ejercicio definirlas por recursión simple y con acumulador y
comparar las dos formas. Su entrenamiento sigue además un esquema general
de los predicados con acumulador, que el apartado 1.5 de su libro
presenta antes del caso del perceptrón. El ejemplo está en `vectores.pl`,
en `ejemplos/capitulo-69/`, con sus pruebas; carga `perceptron.pl` y se
ejecuta localmente.

## Dos operaciones sobre vectores

La corrección de la regla del perceptrón es una suma de vectores: a los
pesos se les suma el vector `[1|Xs]` multiplicado por el número
K = Tasa·(D − Y). `corregir/4` de la
[sección 69.2](index.md#692-version-1-la-regla-del-perceptron) hace las
dos cosas a la vez con `maplist/4`. Por separado, y por recursión simple,
son dos predicados que recorren las listas elemento por elemento:

<!-- ejemplo: capitulo-69/vectores.pl predicado: escalar_rec/3 sumar_rec/3 -->
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

<!-- ejemplo: capitulo-69/vectores.pl predicado: escalar_acc/3 escalar_acc/4 sumar_acc/3 sumar_acc/4 -->
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

<!-- ejemplo: capitulo-69/vectores.pl predicado: corregir_vectores/4 -->
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

## El orden de los argumentos

Csenki pone el número primero: `mult(Const, Point, DeltaWs)`. Con ese
orden, la recursión simple deja una alternativa pendiente:

<!-- ejemplo: capitulo-69/vectores.pl predicado: escalar_k/3 -->
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
[sección 16.3](../capitulo-16-rendimiento/index.md#163-indexacion). Aquí
ese argumento es el número, que es una variable en las dos cláusulas,
y no permite descartar la primera cuando la lista no es vacía. Con la
lista primero, como en `escalar_rec/3`, la indexación distingue `[]` de
`[X|Xs]`, y la consulta termina sin alternativas. Csenki escribe para
otra versión de SWI-Prolog y no se ocupa de las alternativas, porque
llama a `perceptron/5` desde un predicado que corta después de cada
paso.

## El costo de cada forma

`costos_vectores/2` mide las inferencias de multiplicar un vector de N
elementos por un número y sumarle el resultado, con cada forma:

<!-- ejemplo: capitulo-69/vectores.pl predicado: costos_vectores/2 por/3 mas/3 -->
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
[sección 16.2](../capitulo-16-rendimiento/index.md#162-la-pila-y-la-recursion).
En Prolog, una operación que produce una lista no necesita acumulador:
el resultado se construye hacia adelante, con su resto libre. El
acumulador conviene cuando el resultado es un número que la recursión
simple tendría que calcular al retorno de la llamada recursiva, como la
suma de los elementos de un vector; el [ejercicio 13](index.md#ejercicios)
mide esa diferencia.

## El esquema general del acumulador

En el apartado 1.5 de su libro, Csenki observa que los predicados con
acumulador tienen dos cláusulas: una que se detiene, cuando la entrada y
el acumulador cumplen una condición de parada, y otra que transforma
los dos y sigue. Luego generaliza: la entrada y el acumulador se agrupan
en un único **argumento**, que se transforma hasta cumplir la condición
de parada, y del que se **extrae** el resultado. Su entrenamiento del
perceptrón sigue ese esquema con dos términos, `in/5` para el argumento
y `out/2` para el resultado. Con los nombres del curso:

<!-- ejemplo: capitulo-69/vectores.pl predicado: esquema/2 parada/1 extraer/2 transformar/2 entrenar_esquema/5 -->
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
[sección 69.2](index.md#692-version-1-la-regla-del-perceptron).
`entrenar_uno/6` es el mismo esquema con el argumento repartido en cuatro
argumentos del predicado; `esquema/2` lo agrupa en un término, y a cambio
de construir un término por paso nombra cada parte del ciclo: qué se
transforma, cuándo se detiene y qué se extrae.

`iterar/5` del
[capítulo 46](../capitulo-46-proyecto-metodos-numericos/index.md), que
usan las versiones 2 y 3, da un paso más. El estado es el argumento del
esquema, y el paso que lo transforma es un parámetro, de modo que un
mismo ciclo sirve para la bisección, para las épocas del perceptrón y
para la detección de ciclos; la condición de parada es fija, un cambio
menor o igual que una tolerancia, y el ciclo agrega un límite de pasos.
El [ejercicio 14](index.md#ejercicios) escribe el esquema de Csenki con
las tres partes como parámetros.
