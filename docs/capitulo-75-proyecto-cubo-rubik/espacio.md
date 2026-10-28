# El cubo como espacio de estados y los macrooperadores

Esta página continúa el [capítulo 75](index.md) después de la
[sección 75.3](index.md#753-version-2-el-cubo-a-la-vista), con las
secciones [75.4](#754-version-3-el-cubo-como-espacio-de-estados) a
[75.8](#758-version-7-soluciones-mas-cortas): la versión 3 del programa,
que aplica al cubo las búsquedas del
[capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) y mide su
costo, y las versiones 4 a 7, que reemplazan los giros por
macrooperadores, los descubren con una búsqueda, resuelven el cubo por
etapas y acortan la solución. Los ejemplos de la versión 3 están en
`capitulo41.pl` y `espacio.pl`, en `ejemplos/capitulo-75/`, con sus
pruebas; los dos son `% solo-local`, porque cargan otros archivos.

## 75.4 Versión 3: el cubo como espacio de estados

El [capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md#411-el-problema-como-interfaz)
define un problema con tres predicados, `inicial/2`, `meta/2` y
`sucesor/5`, y lo resuelve con búsquedas que no saben nada del dominio.
El cubo encaja en esa interfaz: el estado es el término `c/54`, la meta es
el cubo resuelto y cada sucesor es uno de los doce cuartos de vuelta. Los
archivos del [capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) no son módulos, y los dos que se usan definen los
mismos predicados, así que `capitulo41.pl` carga cada uno en un módulo
propio con `load_files/2` y les agrega las cláusulas del cubo, declaradas
`multifile` antes de la carga:

<!-- ejemplo: capitulo-75/capitulo41.pl fragmento: :- multifile .. user:mover(M, C, C1). -->
```prolog
:- multifile
    anchura41:inicial/2,
    anchura41:meta/2,
    anchura41:sucesor/5,
    iterativa41:inicial/2,
    iterativa41:meta/2,
    iterativa41:sucesor/5.

:- load_files(user:cubo, [if(not_loaded)]).
:- load_files(anchura41:'../capitulo-41/visitados', []).
:- load_files(iterativa41:'../capitulo-41/profundizacion', []).

% anchura41:inicial(Problema, C): C es el estado inicial de cubo(C).
anchura41:inicial(cubo(C), C).

%!  anchura41:meta(+Problema, +C) is semidet.
%
%   El cubo C es una meta de Problema: en cubo(_), el cubo resuelto.
anchura41:meta(cubo(_), C) :-
    user:resuelto(C).

%!  anchura41:sucesor(+Problema, +C, -M, -C1, -Costo:integer) is nondet.
%
%   El cubo C1 sigue a C en Problema con el cuarto de vuelta M, que
%   cuesta 1.
anchura41:sucesor(cubo(_), C, M, C1, 1) :-
    user:cuarto_de_vuelta(M),
    user:mover(M, C, C1).
```

`en_anchura/3` usa la búsqueda en anchura con registro de estados vistos
de la [sección 41.3](../capitulo-41-busqueda-y-planificacion/visitados.md#413-ciclos-y-visitados),
y `profundizando/2`, la profundización iterativa de la
[sección 41.4](../capitulo-41-busqueda-y-planificacion/heuristicas.md#414-profundidad-limitada-y-profundizacion-iterativa).
Las dos encuentran una de las soluciones más cortas.

### Cuántos estados hay

`capas/2` cuenta los estados a cada distancia del cubo resuelto. Genera
cada capa a partir de la anterior: los sucesores de sus estados que no
están en la misma capa ni en la anterior, porque cada cuarto de vuelta
tiene su inverso y un sucesor está, a lo sumo, una capa más atrás. Cada
capa es una lista ordenada con `sort/2`, y las diferencias salen de
`ord_subtract/3`:

<!-- ejemplo: capitulo-75/espacio.pl predicado: capas/4 -->
```prolog
%!  capas(+D:integer, +Anterior:list, +Actual:list, -Cuantos:list) is det.
%
%   Cuantos cuenta Actual, la capa de una distancia, y las D capas que
%   siguen; Anterior es la capa de la distancia anterior. Un estado de la
%   capa siguiente es sucesor de uno de Actual y no está en Actual ni en
%   Anterior: todo cuarto de vuelta tiene inverso, y un sucesor está a lo
%   sumo una capa más atrás.
capas(0, _, Actual, [N]) :-
    !,
    length(Actual, N).
capas(D, Anterior, Actual, [N|Cuantos]) :-
    length(Actual, N),
    findall(C1, ( member(C, Actual), cuarto_de_vuelta(M), mover(M, C, C1) ),
            Sucesores0),
    sort(Sucesores0, Sucesores),
    ord_subtract(Sucesores, Actual, Sucesores1),
    ord_subtract(Sucesores1, Anterior, Siguiente),
    D1 is D - 1,
    capas(D1, Actual, Siguiente, Cuantos).
```

```prolog
?- capas(4, Cuantos).
Cuantos = [1, 12, 114, 1068, 10011].

?- estados(N).
N = 43252003274489856000.
```

Cada capa multiplica la anterior por casi diez. `estados/1` da el total
de estados del cubo, unos 4,3 × 10¹⁹: las ocho esquinas en cualquier
orden y con cualquier orientación salvo la última, que queda determinada
por las otras; lo mismo con las doce aristas; y la mitad de esas
combinaciones, porque las permutaciones de esquinas y de aristas tienen
siempre la misma paridad.

### Cuánto cuesta buscar

`medir/5` resuelve la mezcla de una semilla con una de las dos búsquedas
y cuenta las inferencias:

```prolog
?- medir(profundizando, 5, 5, Largo, Inferencias).
Largo = 5,
Inferencias = 567572.

?- medir(en_anchura, 4, 4, Largo, Inferencias).
Largo = 4,
Inferencias = 2495902.
```

Con las mezclas de las semillas 3 a 7, cada una de tantos giros como su
semilla, las dos búsquedas miden:

| Giros de la mezcla | Profundización iterativa | Anchura con visitados |
|---|---|---|
| 3 | 5 866 inferencias | 408 796 inferencias, 578 nodos expandidos |
| 4 | 39 183 | 2 495 620, 3 112 nodos, 0,8 s |
| 5 | 567 572, 0,17 s | 32 761 797, 34 994 nodos, 12,3 s |
| 6 | 10 783 026, 3,2 s | — |
| 7 | 131 586 078, 40 s | — |

Cada giro más multiplica el costo de la profundización iterativa por
alrededor de doce, la cantidad de sucesores. Una mezcla de veinte giros,
a ese ritmo, llevaría más de cien millones de años. La búsqueda en
anchura es peor todavía: el registro de visitados compara términos de 54
argumentos en un árbol AVL en cada inserción, y ahorra poco, porque en las
primeras capas casi todos los estados son distintos (10 011 estados a
distancia 4 contra 12⁴ = 20 736 secuencias). Las inferencias de la
anchura cambian en unas centenas de una ejecución a otra; las de la
profundización, no. `capas/2` evita el árbol y recorre las cinco primeras
capas, 93 840 estados en la última, con 1,3 millones de inferencias.

La conclusión es la de Merritt: una búsqueda ciega no resuelve el cubo.
El [capítulo 41](../capitulo-41-busqueda-y-planificacion/heuristicas.md#415-heuristicas-a-e-ida)
agrega heurísticas a la búsqueda; el cubo, en cambio, se resuelve
cambiando las acciones. Las
[versiones 4 a 6](#755-version-4-los-macrooperadores) reemplazan los
doce giros por secuencias que mueven pocas piezas y dividen la meta en
veinte metas parciales.

**Lo que falta.** Una búsqueda ciega no resuelve una mezcla real. Hace
falta conocimiento: secuencias que muevan pocas piezas.

## 75.5 Versión 4: los macrooperadores

Un **macrooperador** es una secuencia de giros tratada como un solo
movimiento. Para usarla con el mismo costo que un giro, se compila: se
aplica a un cubo cuyas 54 casillas son variables libres, como en la
[sección 33.5](../capitulo-33-inspeccion-de-terminos/index.md#335-variables-como-datos).
El resultado es un par `Antes-Despues` con las mismas variables en otro
orden, exactamente la forma de un giro:

<!-- ejemplo: capitulo-75/macros.pl predicado: compilar/2 term_expansion/2 -->
```prolog
%!  compilar(+Movimientos:list, -Macro) is det.
%
%   Macro es Antes-Despues: dos términos c/54 con las mismas variables,
%   tales que Despues es Antes con Movimientos aplicados.
compilar(Movimientos, Antes-Despues) :-
    functor(Antes, c, 54),
    aplicar(Movimientos, Antes, Despues).

%!  term_expansion(+Termino, -Hechos:list) is semidet.
%
%   El término macro(Nombre, Texto) se reemplaza, al cargar, por el hecho
%   macro(Nombre, Antes, Despues), con la secuencia de Texto compilada, y
%   el hecho texto_macro(Nombre, Texto).
term_expansion(macro(Nombre, Texto),
               [macro(Nombre, Antes, Despues), texto_macro(Nombre, Texto)]) :-
    leer_notacion(Texto, Movimientos),
    compilar(Movimientos, Antes-Despues).
%!  term_expansion(+Termino, -Hechos:list) is semidet.
%
%   El término generar_piezas se reemplaza, al cargar, por un hecho
%   pieza(P, Nombre, Casillas) por cada arista y cada esquina.
term_expansion(generar_piezas, Hechos) :-
    findall(pieza(P, Nombre, Casillas),
            pieza_calculada(P, Nombre, Casillas),
            Hechos).
```

Merritt precompila sus secuencias de la misma manera, con `assertz/1` en
tiempo de ejecución; aquí `term_expansion/2` reemplaza cada término
`macro(Nombre, Texto)` del archivo por el hecho compilado, al cargar.
Aplicar una macro de 18 giros cuesta lo mismo que aplicar un giro:

```prolog
?- inferencias(dos_esquinas, 1000, EnLista, Compilada).
EnLista = 58002,
Compilada = 3002.
```

El par compilado dice, además, qué hace la secuencia sin aplicarla a
ningún cubo. Una pieza queda quieta si cada una de sus casillas recibe en
`Despues` la misma variable que tenía en `Antes`; la comparación es con
`==/2`, porque son variables:

<!-- ejemplo: capitulo-75/macros.pl predicado: efecto/2 quieta/3 -->
```prolog
%!  efecto(+Macro, -Piezas:list(atom)) is det.
%
%   Piezas son los nombres de las piezas que Macro, un par Antes-Despues,
%   cambia de lugar o de orientación.
efecto(Antes-Despues, Piezas) :-
    findall(Nombre,
            ( pieza(_, Nombre, Casillas),
              \+ quieta(Casillas, Antes, Despues) ),
            Piezas).

%!  quieta(+Casillas:list(integer), +Antes, +Despues) is semidet.
%
%   Cada una de Casillas tiene en Despues la misma variable que en Antes.
quieta(Casillas, Antes, Despues) :-
    forall(member(I, Casillas),
           ( arg(I, Antes, X),
             arg(I, Despues, Y),
             X == Y )).
```

`pieza/3` es una tabla generada al cargar con las 20 piezas móviles
(ocho esquinas y doce aristas), cada una con su nombre en la notación
(UFR, DB, FL…) y los números de sus casillas:

```prolog
?- efecto_de("R U R' U'", Piezas).
Piezas = ['UBL', 'UB', 'DFR', 'FR', 'UBR', 'UR', 'UFR'].

?- efecto_macro(giro_esquina, Piezas).
Piezas = ['DBL', 'DB', 'DBR', 'DR', 'DFR', 'FR', 'UFR'].

?- efecto_macro(dos_esquinas, Piezas).
Piezas = ['UBR', 'UFR'].
```

`giro_esquina` es R' D' R D dos veces: en la capa de arriba solo toca la
esquina UFR, que queda en su lugar pero girada sobre sí misma, y
desordena la capa de abajo. `dos_esquinas` es un **conmutador**:
`giro_esquina`, U, la inversa de `giro_esquina` y U'. U lleva otra esquina
a la posición UFR; la inversa la gira en sentido contrario y arregla la
capa de abajo; U' devuelve la capa de arriba. El resultado gira dos
esquinas y no toca nada más. `conmutador/3` y `conjugado/3` construyen
estas secuencias.

!!! example "Patrón 74 — Transformación como par de términos"
    **Problema.** Es necesario aplicar muchas veces una transformación que
    reordena las partes de un término de tamaño fijo, como un giro del
    cubo, y también componer transformaciones, invertirlas y saber qué
    partes cambian.

    **Versión ingenua.** Escribir cada transformación como un
    procedimiento que lee el término argumento por argumento y construye
    otro; su inversa es otro procedimiento, y una secuencia se aplica paso
    a paso cada vez: `dos_esquinas`, de 18 giros, aplicada como lista
    cuesta 58 002 inferencias en mil aplicaciones.

    **Patrón.** La transformación es un par `Antes-Despues` de dos
    términos que comparten sus variables, en otro orden, como los hechos
    `giro(Cara, Antes, Despues)` de la versión 1. Aplicarla es **una
    unificación**: `Antes` con el término, y `Despues` es el resultado.
    Componer es aplicarla a un término de variables libres: `compilar/2`
    aplica una secuencia a un `c/54` sin ligar y obtiene otro par con la
    forma de un giro, que se aplica con `usar/3` en 3 002 inferencias las
    mismas mil veces. El mismo hecho, leído en sentido inverso, da la
    inversa, como `mover/3` para `-Cara`. Y el par dice qué hace sin
    aplicarlo: `efecto/2` compara las variables con `==/2`.

    **Cuándo no usarlo.** Cuando la transformación depende de los valores
    y no solo de las posiciones, como una que cambia un color según otro:
    un par de términos solo reordena, copia o descarta partes. Cuando no es
    una permutación: si `Despues` repite una variable o no contiene
    alguna, leer el par en sentido inverso no da la inversa, sino una
    restricción de igualdad o una parte libre. Y cuando el par no es un
    hecho sino un término que viaja en una variable: la primera
    aplicación liga sus variables, y cada uso siguiente necesita antes
    una copia con `copy_term/2`; por eso `term_expansion/2` guarda cada
    macro compilada como un hecho.

!!! question "Actividad"
    Predecir qué piezas mueve el conmutador R L R' L' y cuáles mueve
    F R U R' U' F'. Comprobarlo con `efecto_de/2` y explicar el primer
    resultado a partir de las capas que tocan R y L.

**Lo que falta.** Las secuencias útiles se escriben a mano, copiadas de
un libro o de la experiencia de quien resuelve el cubo.

## 75.6 Versión 5: descubrir macros

Merritt propone, como ejercicio de su capítulo, que el programa descubra
secuencias. El conmutador de dos secuencias A y B deshace las dos salvo
en las piezas que ambas mueven: si comparten una sola pieza, mueve apenas
tres. `descubrir/3` genera los conmutadores de una secuencia A de hasta
tres cuartos de vuelta con un cuarto de vuelta B, compila cada uno y se
queda con los que mueven exactamente tres esquinas de la cara de arriba:

<!-- ejemplo: capitulo-75/descubrir.pl predicado: descubrir/3 -->
```prolog
%!  descubrir(+Largo:integer, -Encontradas:list, -Probadas:integer) is det.
%
%   Encontradas son los conmutadores A B A' B', con A de 1 a Largo
%   cuartos de vuelta y B un cuarto de vuelta, que mueven tres esquinas de
%   la cara de arriba y nada más; cada uno como una lista de giros, sin
%   repetidos. Probadas es la cantidad de conmutadores examinados.
descubrir(Largo, Encontradas, Probadas) :-
    findall(S-Sirve,
            ( between(1, Largo, N),
              length(A, N),
              reducida(A),
              cuarto_de_vuelta(B),
              conmutador(A, [B], S),
              compilar(S, Macro),
              efecto(Macro, Piezas),
              (   tres_esquinas_de_arriba(Piezas)
              ->  Sirve = si
              ;   Sirve = no
              ) ),
            Todas),
    length(Todas, Probadas),
    findall(S, member(S-si, Todas), Encontradas0),
    sort(Encontradas0, Encontradas).
```

```prolog
?- descubrir(2, Encontradas, Probadas).
Encontradas = [],
Probadas = 1584.

?- aggregate_all(count, descubierta(3, _), N).
N = 24.

?- descubierta(3, T), sub_string(T, 0, _, _, "U' L").
T = "U' L' U R U' L U R'" ;
false.
```

Con A de uno o dos giros no hay ninguno; con tres, 24 entre 15 984
conmutadores, en 5 millones de inferencias y menos de dos segundos. La
secuencia U' L' U R U' L U R' es el conmutador de U' L' U con R: cicla
las esquinas UFR, UBR y UBL. Su inversa, R U' L' U R' U' L U, es la que
Merritt llama *tri-corner*. Las dos son candidatas de la última etapa de
la versión 6.

**Lo que falta.** Con giros, macros y metas, todavía no hay un
resolvedor.

## 75.7 Versión 6: la solución por etapas

El resolvedor arma el cubo por capas, de abajo hacia arriba, en cinco
etapas de cuatro piezas, y coloca las piezas de a una. Merritt organiza
su programa de la misma manera, con un plan de piezas y una lista de
candidatos por etapa, pero sigue las seis etapas del libro de Black y
Taylor, que arman el cubo de la cara izquierda a la derecha:

| Etapa | Piezas | Candidatos |
|---|---|---|
| 1. la cruz de abajo | DF, DR, DB, DL | los 18 giros de U, D y las caras laterales |
| 2. las esquinas de abajo | DFR, DBR, DBL, DFL | U; tres inserciones de una esquina desde arriba |
| 3. las aristas del medio | FR, BR, BL, FL | U; dos inserciones de una arista, por la derecha y por la izquierda |
| 4. las aristas de arriba | UF, UR, UB, UL | U; F R U R' U' F', que da vuelta aristas; la secuencia de Sune, que las cicla |
| 5. las esquinas de arriba | UFR, UBR, UBL, UFL | el ciclo de tres esquinas de la versión 5 y su inversa; `dos_esquinas` y sus variantes |

La meta de cada pieza es un **criterio**: un término `c/54` con las
casillas de las piezas ya colocadas y de la pieza nueva ligadas a su color,
y las demás libres. Un cubo cumple el criterio si unifica con él. No hace
falta recorrer el cubo buscando piezas: la unificación compara las
casillas ligadas e ignora las libres.

<!-- ejemplo: capitulo-75/etapas.pl predicado: criterio/2 colocar/5 -->
```prolog
%!  criterio(+Piezas:list(atom), -Criterio) is det.
%
%   Criterio es un término c/54 con las casillas de Piezas ligadas al
%   color del cubo resuelto y las demás libres.
criterio(Piezas, Criterio) :-
    functor(Criterio, c, 54),
    resuelto(Resuelto),
    maplist(casillas_de, Piezas, Listas),
    append(Listas, Casillas),
    maplist(copiar_casilla(Resuelto, Criterio), Casillas).

%!  colocar(+Etapa, +Cubo, +Criterio, -Movimientos:list, -Cubo1) is det.
%
%   Movimientos es una de las secuencias más cortas de candidatos de
%   Etapa que llevan Cubo a Cubo1, que cumple Criterio. La búsqueda es la
%   profundización iterativa del capítulo 41.
colocar(Etapa, Cubo, Criterio, Movimientos, Cubo1) :-
    colocar_pieza(Etapa, Cubo, [Criterio], Plan),
    append(Plan, Movimientos),
    aplicar(Movimientos, Cubo, Cubo1).
```

`colocar/5` busca la secuencia más corta de candidatos que lleva el cubo
a un estado que unifica con el criterio. Merritt escribe esa búsqueda con
una recursión que recalcula los estados intermedios en lugar de
guardarlos; es la profundización iterativa del
[capítulo 41](../capitulo-41-busqueda-y-planificacion/heuristicas.md#414-profundidad-limitada-y-profundizacion-iterativa),
y `colocar_pieza/4` la toma de allí, con un tercer problema agregado en
`capitulo41.pl`: el estado inicial es el cubo, la meta unifica con el
criterio y cada sucesor aplica un candidato. Cada candidato es un giro o
una macro compilada, así que aplicarlo es una unificación.

Los candidatos se escriben por familias, para la posición de adelante a la
derecha, y `orientar/3` genera las otras tres cambiando cada cara lateral
por la de su izquierda: es girar el cubo entero sobre el eje vertical. El
término `generar_candidatos` se expande, al cargar, en un hecho
`candidato/4` compilado por cada secuencia distinta:

<!-- ejemplo: capitulo-75/etapas.pl fragmento: familia(3, "U") .. familia(3, "U' F' U F U R U' R'"). -->
```prolog
familia(3, "U").
familia(3, "U'").
familia(3, "U2").
familia(3, "U R U' R' U' F' U F").
familia(3, "U' F' U F U R U' R'").
```

En `capitulo41.pl`, el módulo de la profundización iterativa recibe las
cláusulas de los dos problemas, el cubo entero y la pieza:

<!-- ejemplo: capitulo-75/capitulo41.pl fragmento: iterativa41:inicial(cubo(C), C). .. user:candidato(Etapa, Ms, C, C1). -->
```prolog
iterativa41:inicial(cubo(C), C).
iterativa41:inicial(pieza(_, C, _), C).

%!  iterativa41:meta(+Problema, +C) is semidet.
%
%   El cubo C es una meta de Problema: en cubo(_), el cubo resuelto; en
%   pieza(_, _, Criterios), un cubo que unifica con alguno de Criterios.
iterativa41:meta(cubo(_), C) :-
    user:resuelto(C).
iterativa41:meta(pieza(_, _, Criterios), C) :-
    memberchk(C, Criterios).

%!  iterativa41:sucesor(+Problema, +C, -Ms, -C1, -Costo:integer)
%!      is nondet.
%
%   El cubo C1 sigue a C en Problema, con costo 1: en cubo(_), por el
%   cuarto de vuelta Ms; en pieza(Etapa, _, _), por el candidato de Etapa
%   cuya lista de giros es Ms.
iterativa41:sucesor(cubo(_), C, M, C1, 1) :-
    user:cuarto_de_vuelta(M),
    user:mover(M, C, C1).
iterativa41:sucesor(pieza(Etapa, _, _), C, Ms, C1, 1) :-
    user:candidato(Etapa, Ms, C, C1).
```

```prolog
?- orientar(1, [r, u, -r], Ms).
Ms = [f, u, -f].

?- resolver_mezcla(7, 20, PorEtapa, Total).
PorEtapa = [1-14, 2-39, 3-56, 4-25, 5-42],
Total = 176.
```

Sobre las mezclas de 25 giros de las semillas 1 a 200, el resolvedor
arma los 200 cubos con 172,7 cuartos de vuelta en promedio, entre 107 y
247, y 53 926 inferencias en promedio; la más larga tarda 0,09 s. Ninguna
pieza pide más de cinco candidatos. La etapa más larga es la última, con
50,9 cuartos de vuelta en promedio, porque sus macros tienen entre 8 y
20 giros. La diferencia con la versión 3 es de escala: una búsqueda ciega
de siete giros costaba 130 millones de inferencias, y el cubo entero
cuesta aquí 54 mil. Las macros convierten el problema en veinte búsquedas
cortas, y la unificación con el criterio hace que cada prueba de meta
cueste una sola operación.

!!! question "Actividad"
    Antes de consultar, predecir cuántos candidatos tiene cada etapa: cada
    familia da cuatro secuencias, salvo las que no tocan las caras
    laterales, que dan una sola. Comprobarlo con
    `aggregate_all(count, candidato(E, _, _, _), N)` para E de 1 a 5.

**Lo que falta.** Las soluciones son largas: 172 cuartos de vuelta en
promedio para deshacer mezclas de 25.

## 75.8 Versión 7: soluciones más cortas

Dos cambios, medidos por separado. El primero es de limpieza: una macro
termina con giros de U y la siguiente empieza con otros giros de U, de
modo que al concatenarlas quedan secuencias como U' U2 o R R'.
`simplificar/2` apila los giros y suma los cuartos de vuelta de una misma
cara módulo 4; si la suma da cero, el grupo desaparece y el anterior puede
sumarse con el siguiente:

<!-- ejemplo: capitulo-75/mejoras.pl predicado: apilar/3 -->
```prolog
%!  apilar(+Movimiento, +Pila0:list, -Pila:list) is det.
%
%   Pila es Pila0 con Movimiento sumado: Pila es una lista de pares
%   Cara-Cuartos, el último grupo primero. Si el grupo de arriba es de la
%   misma cara, se suman; si la suma da 0 módulo 4, el grupo desaparece y
%   el de abajo puede volver a sumarse con el siguiente.
apilar(Movimiento, Pila0, Pila) :-
    cara_de(Movimiento, Cara),
    cuartos(Movimiento, K),
    (   Pila0 = [Cara-K0|Resto]
    ->  K1 is (K0 + K) mod 4,
        (   K1 =:= 0
        ->  Pila = Resto
        ;   Pila = [Cara-K1|Resto]
        )
    ;   Pila = [Cara-K|Pila0]
    ).
```

El segundo es una heurística de orden. En cada etapa, en lugar de
colocar las piezas en el orden fijo de la tabla, se busca la que pide la
secuencia más corta: `colocar_pieza/4` recibe un criterio por cada pieza
que falta y termina con el primero que se cumple.

```prolog
?- simplificar([r, u, -u, -r, f, f, f], Ms).
Ms = [-f].

?- medir(etapas, 20, Media, Maximo).
Media = 169.7,
Maximo = 215.

?- medir(cercana_simplificada, 20, Media, Maximo).
Media = 146.1,
Maximo = 195.
```

Sobre las 200 mezclas de la versión 6:

| Método | Cuartos de vuelta (media) | Máximo | Inferencias (media) |
|---|---|---|---|
| etapas (versión 6) | 172,7 | 247 | 53 926 |
| etapas, simplificada | 160,4 | 235 | 53 926 |
| pieza más cercana | 153,4 | 217 | 62 856 |
| pieza más cercana, simplificada | 142,7 | 197 | 62 856 |

La simplificación no cuesta búsqueda y ahorra un 7 %. La pieza más
cercana ahorra un 11 % de giros a cambio de un 17 % más de inferencias,
porque cada nivel de la profundización prueba varios criterios. Juntas
reducen la solución en un 17 %. El resolvedor sigue lejos del óptimo:
colocar las piezas de a una, con macros que preservan todo lo anterior,
es lo que hace que la búsqueda sea corta, y también lo que alarga la
solución. Merritt observa lo mismo: más heurísticas y más macros ahorran
búsqueda solo mientras cuestan menos que la búsqueda que evitan.

El capítulo continúa en la página
[Piezas y una ayuda para la búsqueda](piezas.md#759-version-8-piezas-y-una-ayuda-para-la-busqueda),
con la versión 8: la segunda representación del cubo de Merritt, una
lista de piezas, y sus heurísticas para mover una pieza antes de buscar.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos.

4. ★ **(1)** Predecir `orden([r, r], N)`, `orden([r, l], N)` y
   `cambiadas([r, l, -r, -l], N)`, y comprobarlo. Explicar con `efecto_de/2`
   por qué el último da 0.
5. **(2)** Extender `leer_notacion/2` para que acepte una secuencia entre
   paréntesis seguida de un número de repeticiones:
   `"(R' D' R D)2 U"`. Comprobar que `"(R' D' R D)2"` da la secuencia de
   `giro_esquina`.
6. ★ **(2)** Escribir `tipo_efecto(Texto, Esquinas, Aristas)`, que cuenta
   las esquinas y las aristas que mueve una secuencia, y aplicarlo a las
   familias de cada etapa. Explicar por qué ninguna candidata de la etapa
   3 mueve una pieza de la capa de abajo.
7. **(3)** Escribir los tres giros del cubo entero, `rotacion(Eje, Antes,
   Despues)`, generados al cargar como los giros de las caras. Verificar
   que `orientar/3` equivale a conjugar con la rotación sobre el eje
   vertical: para cada familia de `etapas.pl`, la secuencia orientada y la
   original entre una rotación y su inversa dan la misma macro.
8. ★ **(2)** Medir, sobre las semillas 1 a 50, la media y el máximo de
   cuartos de vuelta de cada etapa de `resolver/2`. Decir qué etapa pesa
   más y relacionarlo con el largo de sus macros.
9. **(2)** En la búsqueda de una pieza, dos candidatos seguidos que solo
   giran U se pueden reemplazar por uno. Escribir `colocar_podado/5`, que
   descarta esas secuencias, y medir las inferencias de `resolver/2` con y
   sin la poda en las semillas 1 a 50.
10. **(3)** Adaptar `descubrir/3` para buscar conmutadores de A, de hasta
    tres cuartos de vuelta, con B, un cuarto de vuelta de U, que muevan
    exactamente tres aristas de la cara de arriba. Informar cuántos hay y
    explicar el resultado.
11. **(3)** El otro ejercicio de Merritt: que el programa recuerde lo que
    aprende. Escribir una variante de `resolver/2` que, cada vez que
    coloca una pieza con tres o más candidatos, agregue la secuencia
    compilada como un candidato nuevo de la etapa para las mezclas
    siguientes. Medir, sobre las semillas 1 a 50 resueltas en orden, los
    candidatos aprendidos, los cuartos de vuelta y las inferencias.

## Referencias

- Dennis Merritt, *Building Expert Systems in Prolog*, Springer-Verlag,
  1989 — capítulo «Rubik's Cube» (las secciones sobre el cubo, la rotación,
  las reglas de alto nivel, la búsqueda y las heurísticas) y el apéndice
  con el código del programa.
  [Edición en línea](https://www.amzi.com/ExpertSystemsInProlog/), de
  Amzi!. Esta página toma de allí las ideas y no el código: las secuencias
  precompiladas como un giro más; la solución por etapas, con un plan de
  piezas y candidatos por etapa; el cubo criterio con variables libres
  como meta parcial, y la búsqueda que recalcula los estados en lugar de
  guardarlos. También los dos ejercicios del final de su capítulo: más
  heurísticas y el descubrimiento de secuencias.
- M. Razid Black y Herbert Taylor, *Unscrambling the Cube*, Zephyr
  Engineering Design (ZED), Burbank, California, 1980 (impreso en 1981),
  40 páginas, ISBN 0-940874-03-2; incluye el folleto anterior de Black,
  *Constructing Patterns on the Cube*. Merritt no da los datos
  bibliográficos: salen de la reseña de David Singmaster en
  [*Cubic Circular* 3 y 4](https://www.jaapsch.net/puzzles/cubic3.htm)
  (1982) y de la bibliografía de cubos de Georges Helm. Sin edición en
  línea de acceso libre verificada. Es la fuente de Merritt para la solución por etapas,
  con sus seis etapas de la cara izquierda a la derecha, y para las
  secuencias que intercambian y giran esquinas; el capítulo conoce el
  libro a través de él, y usa cinco etapas por capas de abajo hacia
  arriba.
- David Singmaster, *Notes on Rubik's «Magic Cube»*, Enslow, 1981. Sin
  edición en línea de acceso libre verificada. Esta página toma la
  notación de las piezas y el recuento de los estados del cubo.
