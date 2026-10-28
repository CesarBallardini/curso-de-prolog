# La terminación

Esta página continúa la página
[Un demostrador por resolución](resolucion.md#616-version-4-un-demostrador-por-resolucion) del
[capítulo 61](index.md), con la [sección 61.7](#617-version-5-la-terminacion): la versión 5,
`terminacion.pl`, que ejecuta el ciclo con un límite y con un registro de las
memorias vistas. El archivo está en `ejemplos/capitulo-61/`, con sus pruebas,
y carga la versión 3, `conflictos.pl`.

## 61.7 Versión 5: la terminación

Un programa dirigido por patrones termina si cada ciclo reduce una medida
que no puede decrecer para siempre, como pide el
[Patrón 56](../capitulo-44-proyecto-resolver-ecuaciones/index.md#443-version-2-reglas-de-reescritura-y-coleccion),
«Medida que decrece». En el máximo común divisor, cada resta reduce la suma
de los números, que es un número natural. En el ordenamiento, cada
intercambio reduce la cantidad de inversiones, que es el tamaño del
conjunto de conflicto. En el demostrador, cada ciclo quita una cláusula o
agrega una de un conjunto finito que nunca se repite.

Cuando la medida no existe, el programa puede no terminar de dos maneras: la
memoria crece sin fin, o vuelve a un estado por el que ya pasó. `vigilar/6`
ejecuta el ciclo de la versión 3 con dos controles: un límite de ciclos, y un
registro de las memorias vistas en un árbol AVL de `library(assoc)`, de la
[sección 23.5](../capitulo-23-estructuras-de-datos-de-la-biblioteca/index.md#235-libraryassoc-y-libraryrbtrees).
Como la memoria es un término, reconocer que se repite es comparar
términos; `msort/2` la ordena antes, porque dos memorias con los mismos
hechos en otro orden son el mismo estado:

<!-- ejemplo: capitulo-61/terminacion.pl predicado: vigilar/6 -->
```prolog
%!  vigilar(+Programa, +Estrategia, +Limite:integer, +Memoria0:list,
%!          -Memoria:list, -Resultado) is semidet.
%
%   Como ejecutar/5, con dos resultados más: limite(N) si el programa hizo
%   Limite ciclos sin terminar, y repetida(K, N) si la memoria después de
%   N ciclos es la misma, como colección de hechos, que después de K.
%   Falla si falla una acción de la instancia elegida.
vigilar(Programa, Estrategia, Limite, Memoria0, Memoria, Resultado) :-
    programa(Programa, Modulos),
    empty_assoc(Vistas),
    vigilado(Modulos, Estrategia, Limite, 0, Vistas, Memoria0, Memoria,
             Resultado).
```

<!-- ejemplo: capitulo-61/terminacion.pl predicado: vigilado/8 -->
```prolog
%!  vigilado(+Modulos:list, +Estrategia, +Limite:integer, +N:integer,
%!           +Vistas, +Memoria0:list, -Memoria:list, -Resultado) is semidet.
%
%   Sigue el ciclo después de N ciclos. Vistas asocia cada memoria ya
%   vista, ordenada con msort/2, con el ciclo en que apareció. Falla si
%   falla una acción de la instancia elegida.
vigilado(Modulos, Estrategia, Limite, N, Vistas, Memoria0, Memoria,
         Resultado) :-
    msort(Memoria0, Clave),
    conflicto(Modulos, Memoria0, Instancias),
    (   get_assoc(Clave, Vistas, K)
    ->  Memoria = Memoria0,
        Resultado = repetida(K, N)
    ;   N >= Limite
    ->  Memoria = Memoria0,
        Resultado = limite(N)
    ;   Instancias == []
    ->  Memoria = Memoria0,
        Resultado = nada_aplicable
    ;   elegir(Estrategia, Memoria0, Instancias, Elegida),
        Elegida = instancia(_, _, _, Acciones),
        put_assoc(Clave, Vistas, N, Vistas1),
        acciones(Acciones, Memoria0, Memoria1, Fin),
        N1 is N + 1,
        (   Fin = parar(R)
        ->  Memoria = Memoria1,
            Resultado = R
        ;   vigilado(Modulos, Estrategia, Limite, N1, Vistas1, Memoria1,
                     Memoria, Resultado)
        )
    ).
```

El programa `luz` enciende la luz si está apagada y la apaga si está
encendida; vuelve al estado inicial cada dos ciclos. `contador` suma uno
indefinidamente, sin repetir nunca una memoria, y solo lo detiene el límite:

```prolog
?- vigilar(luz, primera, 100, [luz(encendida)], M, R).
M = [luz(encendida)],
R = repetida(0, 2).

?- vigilar(contador, primera, 1000, [contador(0)], M, R).
M = [contador(1000)],
R = limite(1000).
```

**Un error de un carácter.** `mcd_mal` es el máximo común divisor con `>=`
en lugar de `>`. La intención parece la misma, porque restar dos números
iguales no debería hacer falta, pero las dos condiciones `numero(X)` y
`numero(Y)` pueden usar el mismo hecho: con `X` y `Y` ligados a `numero(25)`,
la resta da 0, y desde ahí `0 - 0` deja la memoria igual:

```prolog
?- vigilar(mcd_mal, primera, 100, [numero(25), numero(10)], M, R).
M = [numero(0), numero(10)],
R = repetida(1, 2).
```

La memoria después del segundo ciclo es la misma que después del primero.
Con `ejecutar/5` el mismo programa no termina. Con `>`, el mismo hecho no
puede cumplir las dos condiciones, porque un número no es mayor que sí
mismo.

La vigilancia tiene un costo —ordenar la memoria y buscarla en el árbol en
cada ciclo— y un límite: detecta la repetición exacta de un estado, no un
programa que produce estados siempre nuevos. Por eso no reemplaza a la
medida que decrece, que se razona al escribir el programa; la complementa
mientras se lo prueba.

!!! question "Actividad"
    Predecir qué da `vigilar/6` con el programa `mcd_mal` y la memoria
    `[numero(6), numero(4)]`, en qué ciclo aparece la repetición y cuál es
    la memoria repetida. Comprobarlo, y escribir la traza de los primeros
    ciclos a mano con `conflicto/3` y `elegir/4`.

**Lo que falta.** En cada ciclo, cada patrón se compara con toda la lista de
hechos, aunque solo pueda unificar con los de un nombre y una aridad; y en
el máximo común divisor el programa depende de que la estrategia prefiera
`resta` a `resultado`, que se puede aplicar siempre.

El capítulo continúa en la página
[Índices y metarreglas](indices.md#618-version-6-indices-y-metarreglas), con la memoria indexada y
los programas por fases.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios extienden los programas: cada solución es un
archivo que carga los del capítulo, sin modificarlos.

9. ★ **(2)** Escribir el programa `criba`, que parte de los hechos
   `numero(2)`, …, `numero(N)` y quita todo número múltiplo de otro, de modo
   que la memoria termina con los primos. Dar una medida que decrece en cada
   ciclo y comprobar el resultado para N = 30.
10. ★ **(3)** Agregar al demostrador un módulo que quite una cláusula cuando
    otra, distinta, contiene solo literales suyos: `[a]` hace inútil a
    `[a, b]`. Escribirlo como un programa nuevo, `resolucion_subsuncion`,
    verificar con `vigilar/6` que termina —un resolvente quitado puede
    volver a agregarse— y comparar sus ciclos con los de `resolucion` en las
    fórmulas de las pruebas.
11. ★ **(2)** Predecir qué ocurre si se quita del módulo `resolver` la
    condición `no(clausula(R))`, con la fórmula `(p v q) ==> p`, que no es
    un teorema, y con la fórmula de Bratko. Escribir ese programa,
    `resolucion_sin_control`, y comprobar la predicción con `vigilar/6` y un
    límite de 50 ciclos. Explicar por qué la vigilancia no informa una
    memoria repetida.
12. **(2)** Escribir el programa `luz_limitada`, que cambia la luz como
    `luz` pero lleva la cuenta de los cambios en un hecho `cambios(N)` y
    para después de un número dado de cambios. Indicar la medida que
    decrece.
