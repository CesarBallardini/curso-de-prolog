# Soluciones del capítulo 69 — Proyecto: un perceptrón

El código de esta página está en `ejemplos/capitulo-69/soluciones.pl`, que
carga `rasgos.pl` y con él las cuatro versiones del capítulo
—`perceptron.pl`, `epocas.pl`, `ciclos.pl` y `rasgos.pl`— y el ciclo de
iteración del [capítulo 46](../capitulo-46-proyecto-metodos-numericos/index.md);
sus pruebas están en `soluciones.plt`. Los ejercicios 1, 2 y 9 se
resuelven con los archivos del capítulo. Varias consultas usan un
predicado auxiliar de `soluciones.pl` que toma los ejemplos por su nombre,
como `pasos/5` y `curva/5` en el capítulo.

## 1

Desde `[0, 0, 0]`, la primera época corrige con `[0, 0]`, cuya suma 0 da
la clase 1 en lugar de −1, y el sesgo pasa a −2; `[0, 1]` da −2, clase −1
en lugar de 1, y los pesos pasan a `[0, 0, 2]`; `[1, 0]` da 0 y `[1, 1]`
da 2, los dos bien. La segunda época repite la corrección de `[0, 0]`
(sesgo −2) y corrige `[1, 0]`, cuya suma es entonces −2: `[0, 2, 2]`. La
tercera solo corrige `[0, 0]`, y la cuarta no tiene errores.

<!-- contexto: capitulo-69/epocas.pl -->

```prolog
?- epoca(1, [ej([0, 0], -1), ej([0, 1], 1), ej([1, 0], 1), ej([1, 1], 1)], [0, 0, 0], P, E).
P = [0, 0, 2],
E = 2.

?- epoca(1, [ej([0, 0], -1), ej([0, 1], 1), ej([1, 0], 1), ej([1, 1], 1)], [0, 0, 2], P, E).
P = [0, 2, 2],
E = 2.

?- epoca(1, [ej([0, 0], -1), ej([0, 1], 1), ej([1, 0], 1), ej([1, 1], 1)], [0, 2, 2], P, E).
P = [-2, 2, 2],
E = 1.
```

La curva es `[2, 2, 1, 0]` y los pesos finales `[-2, 2, 2]`, como en la
[sección 69.3](index.md#693-version-2-epocas-y-curva-de-aprendizaje). La
cuarta época, desde `[-2, 2, 2]`, da sumas −2, 0, 0 y 2: los cuatro
ejemplos quedan bien, porque una suma nula da la clase 1.

## 2

```prolog
?- entrenar(1, [ej([1, 1], 1), ej([1, 0], -1), ej([0, 1], -1), ej([0, 0], -1)], [0, 0, 0], P, C).
P = [-6, 2, 4],
C = [1, 3, 2, 2, 3, 2, 2, 0].
```

Con el orden inverso, los pesos son `[-6, 2, 4]` en lugar de `[-6, 4, 2]`,
y el entrenamiento dura ocho épocas en lugar de seis. Los dos resultados
son correctos porque la regla solo busca pesos que clasifiquen bien los
ejemplos, y hay infinitos: cualquier recta que deje `[1, 1]` de un lado y
los otros tres puntos del otro sirve. La regla corrige con los ejemplos en
el orden en que los recibe, y el orden decide cuál de esas rectas
encuentra. Las dos fronteras coinciden en los cuatro ejemplos y difieren
fuera de ellos: el punto `[1.5, 0]` da una suma de 0, clase 1, con los
primeros pesos, y de −3, clase −1, con los segundos.

## 3

`errores/3` cuenta los ejemplos que `bien_clasificado/2` rechaza. `exclude/3`
de la [sección 18.4](../capitulo-18-orden-superior/index.md#184-include3-exclude3-partition4-convlist3)
los separa y `length/2` los cuenta. El predicado siempre tiene una sola
respuesta, y todos sus argumentos salvo el último deben llegar
instanciados: `salida/3` evalúa una expresión aritmética con los pesos y
las entradas.

<!-- ejemplo: capitulo-69/soluciones.pl predicado: errores/3 -->
```prolog
%!  errores(+Pesos:list, +Ejemplos:list, -N:integer) is det.
%
%   N es la cantidad de Ejemplos que Pesos clasifican mal.
errores(Pesos, Ejemplos, N) :-
    exclude(bien_clasificado(Pesos), Ejemplos, Mal),
    length(Mal, N).
```

`errores_en/3` toma los ejemplos por su nombre:

```prolog
?- errores_en(puntos, [0.13, -0.51, -0.35], N).
N = 4.
```

Los pesos iniciales de Csenki clasifican bien la mitad de los ocho puntos.

## 4

`numlist/3` da la lista de 1 a N y `foldl/4` la recorre; el número de la
época no se usa, solo marca cuántas veces se aplica el paso. El
acumulador es el par `Pesos-Curva`, con la curva como una lista que se
completa de adelante hacia atrás: cada época liga el primer elemento de la
lista pendiente y pasa el resto, y al final el resto es `[]`. Es la
técnica de las listas que se completan por unificación del
[capítulo 34](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md),
y evita invertir la curva al final.

<!-- ejemplo: capitulo-69/soluciones.pl predicado: entrenar_n/6 epoca_contada/5 -->
```prolog
%!  entrenar_n(+Tasa:number, +N:integer, +Ejemplos:list, +Pesos0:list,
%!             -Pesos:list, -Curva:list(integer)) is det.
%
%   Pesos son los que quedan después de N épocas desde Pesos0, y Curva
%   los errores de cada época, aunque alguna no tenga errores.
entrenar_n(Tasa, N, Ejemplos, Pesos0, Pesos, Curva) :-
    numlist(1, N, Epocas),
    foldl(epoca_contada(Tasa, Ejemplos), Epocas, Pesos0-Curva, Pesos-[]).

%!  epoca_contada(+Tasa, +Ejemplos, +Numero:integer, +Estado0, -Estado)
%!      is det.
%
%   Estado0 es Pesos0-[Errores|Curva] y Estado es Pesos-Curva: la época
%   deja sus errores en la lista, que se completa de adelante hacia atrás.
epoca_contada(Tasa, Ejemplos, _, Pesos0-[Errores|Curva], Pesos-Curva) :-
    epoca(Tasa, Ejemplos, Pesos0, Pesos, Errores).
```

```prolog
?- entrenar_n(1, 6, [ej([0, 0], -1), ej([0, 1], 1), ej([1, 0], 1), ej([1, 1], -1)], [0, 0, 0], P, C).
P = [0, -2, 0],
C = [3, 3, 4, 4, 4, 4].

?- entrenar_n(1, 5, [ej([0, 0], -1), ej([0, 1], 1), ej([1, 0], 1), ej([1, 1], 1)], [0, 0, 0], P, C).
P = [-2, 2, 2],
C = [2, 2, 1, 0, 0].
```

La o exclusiva queda en `[0, -2, 0]` desde la segunda época, con cuatro
errores por época: el ciclo de la
[sección 69.4](index.md#694-version-3-separables-o-en-ciclo). La
disyunción llega a cero en la cuarta época, y la quinta, sin errores, no
cambia los pesos. Un número fijo de épocas siempre termina, pero no dice si
alcanzó: la curva hay que leerla.

## 5

Con la clase del último punto cambiada, ni la versión 2 ni la 3 dan un
resultado:

```prolog
?- puntos_con_ruido(Es), entrenar_o_ciclo(0.25, Es, [0.13, -0.51, -0.35], R).
false.
```

Los pesos son de punto flotante y no se repiten en 1000 épocas. El
algoritmo del bolsillo no intenta decidir si el conjunto es separable:
guarda los mejores pesos vistos. El estado del plegado es un término
`b(Pesos, Mejores, Errores)`, y cada época compara los errores de sus pesos
finales, medidos con `errores/3` sobre todos los ejemplos, con los de los
mejores. La comparación estricta conserva los primeros pesos que alcanzan
el mínimo.

<!-- ejemplo: capitulo-69/soluciones.pl predicado: puntos_con_ruido/1 entrenar_bolsillo/6 epoca_bolsillo/5 -->
```prolog
%!  puntos_con_ruido(-Ejemplos:list) is det.
%
%   Ejemplos son los puntos de datos/2 con la clase del último cambiada.
puntos_con_ruido(Ejemplos) :-
    datos(puntos, Ps),
    reverse(Ps, [ej(Xs, _)|Anteriores]),
    reverse([ej(Xs, -1)|Anteriores], Ejemplos).

%!  entrenar_bolsillo(+Tasa:number, +N:integer, +Ejemplos:list,
%!                    +Pesos0:list, -Mejores:list, -Errores:integer)
%!      is det.
%
%   Mejores son, entre Pesos0 y los pesos del final de cada una de N
%   épocas, los primeros que menos Ejemplos clasifican mal, y Errores es
%   esa cantidad.
entrenar_bolsillo(Tasa, N, Ejemplos, Pesos0, Mejores, Errores) :-
    errores(Pesos0, Ejemplos, E0),
    numlist(1, N, Epocas),
    foldl(epoca_bolsillo(Tasa, Ejemplos), Epocas,
          b(Pesos0, Pesos0, E0), b(_, Mejores, Errores)).

%!  epoca_bolsillo(+Tasa, +Ejemplos, +Numero:integer, +Estado0, -Estado)
%!      is det.
%
%   Estado0 es b(Pesos0, Mejores0, E0): los pesos actuales, los mejores
%   hasta ahora y sus errores. Estado es el mismo término después de una
%   época.
epoca_bolsillo(Tasa, Ejemplos, _, b(Pesos0, Mejores0, E0),
               b(Pesos, Mejores, E)) :-
    epoca(Tasa, Ejemplos, Pesos0, Pesos, _),
    errores(Pesos, Ejemplos, E1),
    (   E1 < E0
    ->  Mejores = Pesos,
        E = E1
    ;   Mejores = Mejores0,
        E = E0
    ).
```

```prolog
?- bolsillo_con_ruido(200, P, E).
P = [-12.870000000000001, 2.1150000000000064, -3.6730000000000067],
E = 1.
```

Un error es el mínimo posible. El conjunto modificado no es separable:
las ocho desigualdades D·(W0 + W1·x + W2·y) ≥ 1, una por punto, no tienen
solución, lo que un resolvedor de desigualdades lineales comprueba. Todos
los pesos cometen entonces al menos un error, y los del bolsillo cometen
uno. El bolsillo no puede saber por sí mismo que no existen pesos mejores:
esa garantía viene de fuera del entrenamiento.

## 6

La o exclusiva de x₁ y x₂ es verdadera cuando es verdadera la disyunción y
falsa la conjunción: la conjunción de «x₁ o x₂» y de «no (x₁ y x₂)».
Cada una de las tres funciones es separable. `nand/1` da los ejemplos de
la negación de la conjunción, que no están en `datos/2`, y
`entrenar_capas/1` entrena los tres perceptrones por separado con
`entrenar/5`. La segunda capa recibe las salidas de la primera; como la
conjunción se entrenó con entradas 0 y 1, `binaria/2` convierte −1 en 0.

<!-- ejemplo: capitulo-69/soluciones.pl predicado: nand/1 entrenar_capas/1 salida_capas/3 binaria/2 -->
```prolog
% nand(Ejemplos): la negación de la conjunción.
nand([ej([0, 0], 1), ej([0, 1], 1), ej([1, 0], 1), ej([1, 1], -1)]).

%!  entrenar_capas(-Modelo) is det.
%
%   Modelo es capas(Po, Pn, Py): los pesos de la disyunción y de la
%   negación de la conjunción, que forman la primera capa, y los de la
%   conjunción, que combina sus salidas. Los tres se entrenan por
%   separado, desde pesos nulos y con tasa 1.
entrenar_capas(capas(Po, Pn, Py)) :-
    datos(o, O),
    entrenar(1, O, [0, 0, 0], Po, _),
    nand(N),
    entrenar(1, N, [0, 0, 0], Pn, _),
    datos(y, Y),
    entrenar(1, Y, [0, 0, 0], Py, _).

%!  salida_capas(+Modelo, +Entradas:list, -Clase) is det.
%
%   Clase es la salida de la segunda capa de Modelo para las Entradas.
%   Las salidas de la primera capa, 1 o -1, se pasan a 1 o 0 porque la
%   segunda capa se entrenó con entradas 1 y 0.
salida_capas(capas(Po, Pn, Py), Xs, Clase) :-
    salida(Po, Xs, A),
    salida(Pn, Xs, B),
    maplist(binaria, [A, B], Intermedias),
    salida(Py, Intermedias, Clase).

%!  binaria(+Clase, -Bit) is det.
%
%   Bit es 1 si Clase es 1, y 0 si es -1.
binaria(Clase, Bit) :-
    Bit is (Clase + 1) // 2.
```

```prolog
?- entrenar_capas(M), salida_capas(M, [0, 0], A), salida_capas(M, [0, 1], B), salida_capas(M, [1, 0], C), salida_capas(M, [1, 1], D).
M = capas([-2, 2, 2], [4, -4, -2], [-6, 4, 2]),
A = D, D = -1,
B = C, C = 1.
```

Los cuatro ejemplos quedan bien clasificados. La red no se entrenó como
red: cada perceptrón aprendió una función que se eligió de antemano. Para
entrenar juntas las dos capas, sin decir qué debe calcular cada neurona
de la primera, la regla del perceptrón no alcanza, porque no hay una
clase deseada para las salidas intermedias; hace falta otra regla, que
reparta el error de la salida entre las neuronas que lo produjeron.

## 7

Los nueve puntos forman tres grupos, cerca de `[0, 0]`, de `[6, 0]` y de
`[0, 6]`. `entrenar_clases/2` junta las clases con `sort/2` y entrena un
perceptrón por clase; `uno_contra_resto/3` da a los ejemplos de la clase
la clase 1 y a los demás −1. `clase_de/3` calcula la suma de cada
perceptrón con `suma/3`, que es la de `salida/3` sin el signo, y responde
con la clase de la mayor.

<!-- ejemplo: capitulo-69/soluciones.pl predicado: tres_clases/1 entrenar_clases/2 entrenar_clase/3 uno_contra_resto/3 suma/3 clase_de/3 suma_de/3 -->
```prolog
% tres_clases(Ejemplos): puntos del plano con clases a, b y c.
tres_clases([ ej([0, 0], a), ej([1, 0], a), ej([0, 1], a),
              ej([6, 0], b), ej([7, 1], b), ej([6, 1], b),
              ej([0, 6], c), ej([1, 7], c), ej([1, 6], c)
            ]).

%!  entrenar_clases(+Ejemplos:list, -Modelo:list(pair)) is semidet.
%
%   Modelo es una lista Clase-Pesos con un perceptrón por clase, que
%   separa esa clase de todas las demás. Falla si alguna clase no se
%   separa de las otras.
entrenar_clases(Ejemplos, Modelo) :-
    findall(C, member(ej(_, C), Ejemplos), Cs0),
    sort(Cs0, Clases),
    maplist(entrenar_clase(Ejemplos), Clases, Modelo).

%!  entrenar_clase(+Ejemplos:list, +Clase, -Par:pair) is semidet.
%
%   Par es Clase-Pesos, con Pesos entrenados para dar 1 a los Ejemplos de
%   la Clase y -1 a los demás.
entrenar_clase(Ejemplos, Clase, Clase-Pesos) :-
    maplist(uno_contra_resto(Clase), Ejemplos, Binarios),
    entrenar(1, Binarios, [0, 0, 0], Pesos, _).

%!  uno_contra_resto(+Clase, +Ejemplo, -Binario) is det.
%
%   Binario es el Ejemplo con clase 1 si era de la Clase, y -1 si no.
uno_contra_resto(Clase, ej(Xs, C), ej(Xs, D)) :-
    (   C == Clase
    ->  D = 1
    ;   D = -1
    ).

%!  suma(+Pesos:list, +Entradas:list, -S:number) is det.
%
%   S es W0 + W1·X1 + ... + Wn·Xn.
suma([W0|Ws], Xs, S) :-
    foldl(sumar_producto, Ws, Xs, W0, S).

%!  clase_de(+Modelo:list(pair), +Entradas:list, -Clase) is det.
%
%   Clase es la del perceptrón de Modelo con la mayor suma para las
%   Entradas; con sumas iguales, la primera.
clase_de(Modelo, Xs, Clase) :-
    maplist(suma_de(Xs), Modelo, Pares),
    pairs_keys_values(Pares, Sumas, _),
    max_list(Sumas, Maxima),
    once(member(Maxima-Clase, Pares)).

%!  suma_de(+Entradas, +Par:pair, -Suma:pair) is det.
%
%   Par es Clase-Pesos y Suma es S-Clase, con S la suma de Pesos para las
%   Entradas.
suma_de(Xs, Clase-Pesos, S-Clase) :-
    suma(Pesos, Xs, S).
```

```prolog
?- modelo_tres_clases(M), clase_de(M, [3, 3], C).
M = [a-[8, -6, -8], b-[-8, 6, -12], c-[-8, -14, 6]],
C = b.
```

Las sumas para `[3, 3]` son 8 − 18 − 24 = −34 para `a`, −8 + 18 − 36 =
−26 para `b` y −8 − 42 + 18 = −32 para `c`. Los tres perceptrones
rechazan el punto, que no está cerca de ningún grupo, y la respuesta es la
del rechazo menos negativo. La elección entre `b` y `c`, simétricos
respecto del punto, depende de pesos que el entrenamiento fijó por el
orden de los ejemplos: un punto lejos de todos los ejemplos recibe una
clase, pero esa clase no dice nada seguro.

## 8

La frontera es W0 + W1·x + W2·y = 0; si W2 no es cero, se despeja y.

<!-- ejemplo: capitulo-69/soluciones.pl predicado: recta/3 -->
```prolog
%!  recta(+Pesos:list, -Pendiente:float, -Ordenada:float) is semidet.
%
%   La frontera de Pesos [W0, W1, W2] es la recta y = Pendiente · x +
%   Ordenada. Falla si W2 es 0: la frontera es entonces vertical.
recta([W0, W1, W2], Pendiente, Ordenada) :-
    W2 =\= 0,
    Pendiente is -W1 / W2,
    Ordenada is -W0 / W2.
```

```prolog
?- curva(puntos, 0.25, [0.13, -0.51, -0.35], P, _), recta(P, Pendiente, Ordenada).
P = [-39.870000000000005, 3.0180000000000176, 4.193500000000006],
Pendiente = -0.7196852271372395,
Ordenada = 9.507571241206618.

?- salida([-39.87, 3.018, 4.1935], [10, 5], C1), salida([-39.87, 3.018, 4.1935], [4, 2], C2).
C1 = 1,
C2 = -1.
```

La recta y ≈ −0.72·x + 9.51 baja de izquierda a derecha, y la clase 1
está por encima de ella, porque W2 es positivo. `[10, 5]` está por encima
—la recta pasa por y ≈ 2.31 en x = 10— y `[4, 2]` por debajo —la recta
pasa por y ≈ 6.63 en x = 4—. Los pesos se ajustaron con ocho puntos, y
ahora clasifican puntos que no estaban entre ellos: es lo que en el
[capítulo 66](../capitulo-66-proyecto-evidencia-arboles-decision/index.md)
hacían las fuerzas escritas a mano, con números que aquí salieron de los
datos.

## 9

Sean P₀ = 0 y Q₀ = 0 los pesos iniciales para las tasas 1 y c. Si antes de
un ejemplo Q = c·P, las sumas cumplen S_Q = c·S_P, y como c > 0 tienen el
mismo signo: las dos salidas son iguales. Si el ejemplo está bien
clasificado, ninguno cambia; si no, la corrección con la tasa c es c veces
la de la tasa 1, y Q + c·Δ = c·(P + Δ). Por inducción sobre los ejemplos
usados, Q = c·P en todo momento, los errores son los mismos en cada época
y la curva es la misma. Desde los pesos de Csenki, Q₀ = P₀ ≠ c·P₀, y la
igualdad falla desde el primer paso: la tasa pesa distinto sobre la parte
inicial y sobre las correcciones.

<!-- contexto: capitulo-69/epocas.pl -->

```prolog
?- curva(puntos, 0.25, [0, 0, 0], P1, C1), curva(puntos, 1, [0, 0, 0], P2, C2), C1 == C2.
P1 = [-27.5, 2.6445000000000087, 1.4665000000000004],
C1 = C2, C2 = [5, 5, 5, 4, 3, 5, 4, 5, 5|...],
P2 = [-110, 10.578000000000035, 5.866000000000001].
```

Las curvas son iguales y los pesos de la tasa 1 son cuatro veces los de la
tasa 0.25. Con los pesos de Csenki, las tasas 0.25, 1 y 0.1 necesitan 102,
53 y 74 épocas: no hay un orden entre la tasa y la cantidad de épocas.

## 10

La cola es una lista diferencia `Frente-Fin`: sacar el primero es tomar la
cabeza de `Frente`, y ponerlo al final es ligar `Fin` a `[E|Fin1]`, sin
recorrer la lista. La verificación necesita la lista completa y cerrada de
los ejemplos, que se pasa aparte, porque el orden no importa para
verificar.

<!-- ejemplo: capitulo-69/soluciones.pl predicado: entrenar_cola/5 entrenar_cola/7 -->
```prolog
%!  entrenar_cola(+Tasa:number, +Ejemplos:list, +Pesos0:list,
%!                -Pesos:list, -Pasos:integer) is det.
%
%   Como entrenar_uno/5, con los ejemplos en una cola hecha con una lista
%   diferencia: pasar el primero al final no copia la lista.
entrenar_cola(Tasa, Ejemplos, Pesos0, Pesos, Pasos) :-
    append(Ejemplos, Fin, Cola),
    entrenar_cola(Tasa, Ejemplos, Cola-Fin, Pesos0, 0, Pesos, Pasos).

%!  entrenar_cola(+Tasa, +Ejemplos, +Cola, +Pesos0, +Pasos0:integer,
%!                -Pesos, -Pasos:integer) is det.
%
%   Cola es Frente-Fin, una lista diferencia con los ejemplos en el orden
%   en que se usan; Ejemplos es la lista fija que se verifica.
entrenar_cola(Tasa, Ejemplos, [E|Frente]-[E|Fin], Pesos0, Pasos0,
              Pesos, Pasos) :-
    (   maplist(bien_clasificado(Pesos0), Ejemplos)
    ->  Pesos = Pesos0,
        Pasos = Pasos0
    ;   corregir(Tasa, E, Pesos0, Pesos1),
        Pasos1 is Pasos0 + 1,
        entrenar_cola(Tasa, Ejemplos, Frente-Fin, Pesos1, Pasos1, Pesos,
                      Pasos)
    ).
```

```prolog
?- costo_cola(Cola, Uno).
Cola = 43647,
Uno = 46400.
```

La cola ahorra 2 753 inferencias, menos del 6 %. En la versión 1, la
rotación cuesta unas 10 inferencias por paso con ocho ejemplos; la
verificación, hasta 112, porque clasifica los ocho antes de corregir uno.
La cola elimina la parte menor del costo; las épocas de la versión 2
eliminan la mayor, porque verifican sin un recorrido aparte, y bajan a
21 758.

## 11

La distancia de un punto a la frontera es la suma dividida por la norma
de los pesos sin el sesgo; multiplicada por la clase, es positiva si el
punto está del lado de su clase. El margen es la menor de esas
distancias.

<!-- ejemplo: capitulo-69/soluciones.pl predicado: margen/3 distancia/4 -->
```prolog
%!  margen(+Pesos:list, +Ejemplos:list, -Margen:float) is det.
%
%   Margen es la menor distancia con signo de los Ejemplos a la frontera
%   de Pesos: positiva si todos están del lado de su clase. Pesos debe
%   tener algún peso distinto de cero además del sesgo.
margen([W0|Ws], Ejemplos, Margen) :-
    foldl(sumar_producto, Ws, Ws, 0, Cuadrados),
    Norma is sqrt(Cuadrados),
    maplist(distancia([W0|Ws], Norma), Ejemplos, Distancias),
    min_list(Distancias, Margen).

%!  distancia(+Pesos:list, +Norma:float, +Ejemplo, -D:float) is det.
%
%   D es la distancia con signo del Ejemplo ej(Xs, C) a la frontera: la
%   suma de Pesos para Xs, por C, dividida por la Norma.
distancia(Pesos, Norma, ej(Xs, C), D) :-
    suma(Pesos, Xs, S),
    D is C * S / Norma.
```

```prolog
?- margen([-6, 4, 2], [ej([0, 0], -1), ej([0, 1], -1), ej([1, 0], -1), ej([1, 1], 1)], M).
M = 0.0.

?- margen_en(puntos, 0.25, [0.13, -0.51, -0.35], M).
M = 0.08583515487964459.

?- margen_en(puntos, 1, [0, 0, 0], M).
M = 0.03476762463048091.
```

Un margen nulo indica un ejemplo sobre la frontera: con `[-6, 4, 2]`, la
suma de `[1, 1]` es exactamente 0, y el ejemplo está bien clasificado solo
porque una suma nula da la clase 1. La regla se detiene en cuanto todo
está bien, sin buscar una frontera alejada de los ejemplos. En los ocho
puntos, las dos fronteras separan, pero la segunda pasa a 0.035 de un
punto: un error de medición de ese tamaño lo pasa de clase. Entre dos
soluciones que separan, la de mayor margen es la más segura para puntos
nuevos.

## 12

<!-- ejemplo: capitulo-69/soluciones.pl predicado: anillo/1 cuadrados/2 cuadrado/2 probar_anillo/2 -->
```prolog
% anillo(Ejemplos): la clase 1 dentro del círculo de radio 2, -1 fuera.
anillo([ ej([0, 0], 1), ej([1, 0], 1), ej([0, -1], 1), ej([-1, 1], 1),
         ej([3, 0], -1), ej([0, 3], -1), ej([-3, 1], -1),
         ej([2, -2], -1), ej([-2, -2], -1)
       ]).

%!  cuadrados(+Ejemplo0, -Ejemplo) is det.
%
%   Ejemplo tiene como entradas los cuadrados de las de Ejemplo0.
cuadrados(ej(Xs, D), ej(Cs, D)) :-
    maplist(cuadrado, Xs, Cs).

%!  cuadrado(+X:number, -C:number) is det.
%
%   C es X·X.
cuadrado(X, C) :-
    C is X * X.

%!  probar_anillo(+Rasgos:atom, -Resultado) is semidet.
%
%   Resultado es el de entrenar_o_ciclo/4 para anillo/1, con las entradas
%   originales (Rasgos = entradas) o sus cuadrados (Rasgos = cuadrados),
%   desde pesos nulos y con tasa 1.
probar_anillo(entradas, Resultado) :-
    anillo(Ejemplos),
    entrenar_o_ciclo(1, Ejemplos, [0, 0, 0], Resultado).
probar_anillo(cuadrados, Resultado) :-
    anillo(Ejemplos0),
    maplist(cuadrados, Ejemplos0, Ejemplos),
    entrenar_o_ciclo(1, Ejemplos, [0, 0, 0], Resultado).
```

```prolog
?- probar_anillo(entradas, R).
R = ciclo(2, [3, 6, 6]).

?- probar_anillo(cuadrados, R).
R = separa([14, -6, -8], [1, 4, 3, 3, 0]).
```

Con las coordenadas originales, los pesos se repiten cada dos épocas: los
puntos no son separables, porque los de fuera rodean a los de dentro.
Con los cuadrados, un punto está dentro del círculo de radio r si
x² + y² < r², una desigualdad lineal en x² e y²: la frontera circular del
plano original es una recta en las nuevas coordenadas. Los pesos
`[14, -6, -8]` dan 14 − 6·x² − 8·y² ≥ 0, una elipse que contiene los
cuatro puntos interiores y deja fuera los cinco exteriores. Para la o
exclusiva el rasgo no sirve: con entradas 0 y 1, el cuadrado de cada
entrada es la misma entrada, y los ejemplos no cambian.

## Ejercicio 13

<!-- ejemplo: capitulo-69/soluciones_vectores.pl predicado: suma_rec/2 suma_acc/2 suma_acc/3 costos_suma/2 con_pila/4 -->
```prolog
%!  suma_rec(+Xs:list(number), -S:number) is det.
%
%   S es la suma de los elementos de Xs, por recursión simple.
suma_rec([], 0).
suma_rec([X|Xs], S) :-
    suma_rec(Xs, S0),
    S is S0 + X.

%!  suma_acc(+Xs:list(number), -S:number) is det.
%
%   Como suma_rec/2, con un acumulador.
suma_acc(Xs, S) :-
    suma_acc(Xs, 0, S).

%!  suma_acc(+Xs:list(number), +S0:number, -S:number) is det.
%
%   S es S0 más la suma de los elementos de Xs.
suma_acc([], S, S).
suma_acc([X|Xs], S0, S) :-
    S1 is S0 + X,
    suma_acc(Xs, S1, S).

%!  costos_suma(+N:integer, -Costos:list(pair)) is det.
%
%   Costos son las inferencias que usa sumar los números de 1 a N con
%   cada forma: rec-I y acc-I.
costos_suma(N, [rec-I1, acc-I2]) :-
    numlist(1, N, Xs),
    inferencias(suma_rec(Xs, _), I1),
    inferencias(suma_acc(Xs, _), I2).

%!  con_pila(+Limite:integer, +Suma:atom, +N:integer, -Resultado) is det.
%
%   Resultado es suma(S) si el predicado Suma, suma_rec o suma_acc, suma
%   los números de 1 a N con un límite de Limite bytes para las pilas, y
%   sin_pila si las pilas se agotan. El límite anterior se restituye.
con_pila(Limite, Suma, N, Resultado) :-
    numlist(1, N, Xs),
    current_prolog_flag(stack_limit, Anterior),
    setup_call_cleanup(
        set_prolog_flag(stack_limit, Limite),
        catch(( call(Suma, Xs, S),
                Resultado = suma(S) ),
              error(resource_error(_), _),
              Resultado = sin_pila),
        set_prolog_flag(stack_limit, Anterior)).
```

```prolog
?- costos_suma(1000, Costos).
Costos = [rec-2003, acc-2004].

?- con_pila(12000000, suma_rec, 200000, R).
R = sin_pila.

?- con_pila(12000000, suma_acc, 200000, R).
R = suma(20000100000).
```

Las dos formas usan las mismas inferencias: una llamada y una suma por
elemento. La diferencia está en la memoria. En `suma_rec/2` la suma
`S is S0 + X` va después de la llamada recursiva, que no es la última
meta del cuerpo: cada llamada conserva su marco hasta que la siguiente
retorna, y con 200 000 elementos los marcos agotan las pilas. En
`suma_acc/3` la llamada recursiva es la última meta, la optimización de
la última llamada reutiliza el marco, y la suma corre en espacio
constante. `escalar_rec/3` no tiene ese problema porque su resultado es
una lista: la celda `[Y|Ys]` se construye en la cabeza, con su resto
libre, antes de la llamada recursiva, que es la última meta. El
acumulador conviene cuando el resultado es un valor que se calcula al
retorno de la llamada recursiva; cuando es una lista, la recursión simple
ya es de cola y el acumulador solo agrega la inversión.

`con_pila/4` cambia el indicador `stack_limit` y lo restituye con
`setup_call_cleanup/3`, aunque la suma termine con un error de recursos.

## Ejercicio 14

<!-- ejemplo: capitulo-69/soluciones_vectores.pl predicado: esquema_general/5 entrenar_general/5 minimo/2 resto_vacio/1 menor/2 avanzar/2 -->
```prolog
%!  esquema_general(:Parada, :Extraer, :Transformar, +Argumento,
%!                  -Resultado) is det.
%
%   Transforma Argumento con call(Transformar, A0, A) hasta que se cumple
%   call(Parada, A), y da Resultado con call(Extraer, A, Resultado).
esquema_general(Parada, Extraer, Transformar, Arg, Res) :-
    (   call(Parada, Arg)
    ->  call(Extraer, Arg, Res)
    ;   call(Transformar, Arg, Arg1),
        esquema_general(Parada, Extraer, Transformar, Arg1, Res)
    ).

%!  entrenar_general(+Nombre:atom, +Tasa:number, +Pesos0:list,
%!                   -Pesos:list, -Pasos:integer) is det.
%
%   Como entrenar_esquema/5, con esquema_general/5 y las tres partes de
%   vectores.pl.
entrenar_general(Nombre, Tasa, Pesos0, Pesos, Pasos) :-
    datos(Nombre, Ejemplos),
    esquema_general(parada, extraer, transformar,
                    en(Tasa, Ejemplos, Pesos0, 0), sal(Pesos, Pasos)).

%!  minimo(+Xs:list(number), -M:number) is semidet.
%
%   M es el menor elemento de Xs, que no es vacía, con esquema_general/5:
%   el argumento es el par Resto-Menor. Falla si Xs es vacía.
minimo([X|Xs], M) :-
    esquema_general(resto_vacio, menor, avanzar, Xs-X, M).

%!  resto_vacio(+Argumento) is semidet.
%
%   No quedan elementos por examinar.
resto_vacio([]-_).

%!  menor(+Argumento, -M:number) is det.
%
%   M es el menor de Argumento.
menor(_-M, M).

%!  avanzar(+Argumento0, -Argumento) is det.
%
%   Argumento examina el primer elemento restante de Argumento0.
avanzar([X|Xs]-M0, Xs-M) :-
    M is min(M0, X).
```

```prolog
?- entrenar_general(puntos, 0.25, [0.13, -0.51, -0.35], Pesos, Pasos).
Pesos = [-39.870000000000005, 3.0180000000000176, 4.193500000000006],
Pasos = 801.

?- minimo([7, -3, 2, 5], M).
M = -3.
```

`esquema_general/5` es `esquema/2` con las tres partes como metas. El
entrenamiento usa las de `vectores.pl` sin cambios. El mínimo es el
ejemplo con el que Csenki presenta los acumuladores: el argumento es el
par formado por los elementos que faltan examinar y el menor de los ya
examinados, que empieza con el primero de la lista; la parada es que no
quede ninguno, y la transformación examina el siguiente. Con una lista
vacía no hay primer elemento con el que empezar, y `minimo/2` falla.
