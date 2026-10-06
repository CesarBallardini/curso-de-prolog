# La terminación

Esta página contiene la sección
[60.7](index.md#607-version-5-la-terminacion) del
[capítulo 60](index.md): la versión 5, `terminacion.pl`, que ejecuta el
ciclo con un límite y con un registro de las memorias vistas. El archivo
está en `ejemplos/capitulo-60/`, con sus pruebas, y carga la versión 3,
`conflictos.pl`.

## La terminación

Un programa dirigido por patrones termina si cada ciclo reduce una medida
que no puede decrecer para siempre, como pide el
[Patrón 56](../capitulo-43-proyecto-resolver-ecuaciones/index.md#433-version-2-reglas-de-reescritura-y-coleccion),
«Medida que decrece». En el máximo común divisor, cada resta reduce la suma
de los números, que es un número natural. En el ordenamiento, cada
intercambio reduce la cantidad de inversiones, que es el tamaño del
conjunto de conflicto. En el demostrador, cada ciclo quita una cláusula o
agrega una de un conjunto finito que nunca se repite.

Cuando la medida no existe, el programa puede no terminar de dos maneras: la
memoria crece sin fin, o vuelve a un estado por el que ya pasó. `vigilar/6`
ejecuta el ciclo de la versión 3 con dos controles: un límite de ciclos, y un
registro de las memorias vistas en un árbol AVL de `library(assoc)`, de la
[sección 22.5](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#225-libraryassoc-y-libraryrbtrees).
Como la memoria es un término, reconocer que se repite es comparar
términos; `msort/2` la ordena antes, porque dos memorias con los mismos
hechos en otro orden son el mismo estado:

<!-- ejemplo: capitulo-60/terminacion.pl predicado: vigilado/8 -->
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
