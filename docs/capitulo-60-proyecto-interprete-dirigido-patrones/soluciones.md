# Soluciones del capítulo 60 — Proyecto: un intérprete dirigido por patrones

El código de esta página está en `ejemplos/capitulo-60/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga las versiones 4 y 5, que
cargan las anteriores, y no modifica ningún archivo del capítulo: los
programas nuevos son cláusulas de `programa/2` y la estrategia nueva es una
cláusula de `clave/4`, dos predicados que el capítulo declara `multifile`.
Los ejercicios 1 y 6 se resuelven con los archivos del capítulo. Es
`% solo-local`, porque carga otros archivos.

## 1

En cada ciclo, `primera` elige `resta` mientras haya dos números distintos,
y dentro de `resta`, el primer par en el orden de la memoria, del hecho más
reciente al más antiguo. El conjunto de conflicto tiene una instancia de
`resta` por par de números distintos con el mayor primero, y una de
`resultado` por número:

<!-- ejemplo: capitulo-60/conflictos.pl predicado: mostrar/5 -->
```prolog
%!  mostrar(+Traza, +N:integer, +Instancias:list, +Elegida, +Memoria:list)
%!      is det.
%
%   Con con_traza, escribe el ciclo N: cuántas instancias hay, cuál se
%   eligió y los hechos de Memoria que usa. Con sin_traza no hace nada.
mostrar(sin_traza, _, _, _, _).
mostrar(con_traza, N, Instancias, Elegida, Memoria) :-
    length(Instancias, Cantidad),
    Elegida = instancia(Nombre, _, Posiciones, _),
    findall(F, ( member(I, Posiciones), nth0(I, Memoria, F) ), Hechos),
    format("~w: ~w de ~w, con ~w~n", [N, Nombre, Cantidad, Hechos]).
```

```prolog
?- trazar(mcd, primera, [numero(18), numero(12), numero(8)], M, R).
1: resta de 6, con [numero(18),numero(12)]
2: resta de 6, con [numero(12),numero(6)]
3: resta de 5, con [numero(8),numero(6)]
4: resta de 5, con [numero(6),numero(2)]
5: resta de 6, con [numero(4),numero(2)]
6: resta de 5, con [numero(6),numero(2)]
7: resta de 5, con [numero(4),numero(2)]
8: resultado de 3, con [numero(2)]
M = [numero(2), numero(2), numero(2)],
R = 2.
```

Son ocho ciclos, siete restas y el resultado, 2. En el primero los tres
números son distintos: tres pares y tres números, seis instancias. El
primer ciclo reemplaza 18 por 6, y el segundo, 12 por 6: en el tercero la
memoria es `[numero(6), numero(6), numero(8)]`, con dos pares —8 con cada
6— y tres números, cinco instancias. Dos números iguales no forman par, y
el conjunto se reduce cuando se repiten.

## 2

`menor` quita un número si hay otro mayor; cuando queda uno solo, `menor`
ya no se aplica y `resultado` da el máximo:

<!-- ejemplo: capitulo-60/soluciones.pl fragmento: programa(maximo, .. ]). -->
```prolog
programa(maximo,
    [ menor :: [numero(X), numero(Y), {X < Y}]
           ---> [quitar(numero(X))],
      resultado :: [numero(X)]
           ---> [parar(X)]
    ]).
```

```prolog
?- ejecutar(maximo, [numero(25), numero(10), numero(15), numero(30)], M, R).
M = [numero(30)],
R = 30.
```

Si el máximo aparece dos veces, ninguno de los dos es menor que el otro, y
`resultado` se aplica con dos hechos en la memoria: da el mismo valor.

## 3

<!-- ejemplo: capitulo-60/soluciones.pl fragmento: programa(criba, .. ]). -->
```prolog
programa(criba,
    [ multiplo :: [numero(X), numero(Y), {X < Y, Y mod X =:= 0}]
           ---> [quitar(numero(Y))]
    ]).
```

<!-- ejemplo: capitulo-60/soluciones.pl predicado: numeros/3 -->
```prolog
%!  numeros(+Desde:integer, +Hasta:integer, -Hechos:list) is det.
%
%   Hechos son los hechos numero(I) para I de Desde a Hasta.
numeros(Desde, Hasta, Hechos) :-
    findall(numero(I), between(Desde, Hasta, I), Hechos).
```

<!-- ejemplo: capitulo-60/soluciones.pl predicado: primos_hasta/2 -->
```prolog
%!  primos_hasta(+N:integer, -Primos:list(integer)) is det.
%
%   Ejercicio 3. Primos son los primos hasta N, en orden, según el
%   programa criba.
primos_hasta(N, Primos) :-
    numeros(2, N, Hechos),
    ejecutar(criba, Hechos, Memoria, nada_aplicable),
    findall(X, member(numero(X), Memoria), Xs),
    msort(Xs, Primos).
```

```prolog
?- primos_hasta(20, P).
P = [2, 3, 5, 7, 11, 13, 17, 19].
```

La prueba `ej3_criba` verifica también el caso N = 30, cuya lista el
intérprete interactivo abrevia al escribirla.

La medida es la cantidad de hechos de la memoria: cada ciclo quita uno y no
agrega ninguno. Un número compuesto `Y` tiene un divisor `X` con
`1 < X < Y`, que está en la memoria mientras nadie lo quite, y solo se
quitan compuestos; un primo no es múltiplo de ningún otro número de la
memoria. Por eso quedan exactamente los primos.

## 4

`burbuja` agrega a la condición de `ordenar` que las posiciones sean
vecinas:

<!-- ejemplo: capitulo-60/soluciones.pl fragmento: programa(burbuja, .. ]). -->
```prolog
programa(burbuja,
    [ vecinos :: [pos(I, X), pos(J, Y), {J =:= I + 1, X > Y}]
           ---> [reemplazar(pos(I, X), pos(I, Y)),
                 reemplazar(pos(J, Y), pos(J, X))]
    ]).
```

| Lista | `burbuja`, `primera` | `burbuja`, `reciente` | `ordenar`, `primera` | `ordenar`, `reciente` |
|---|---|---|---|---|
| invertida de 10 | 45 | 45 | 45 | 45 |
| `[4, 5, 1, 3, 2]` | 7 | 7 | 7 | 5 |

Un intercambio entre vecinos quita exactamente una inversión, así que
`burbuja` hace tantos ciclos como inversiones tiene la lista —45 y 7—,
cualquiera que sea la estrategia. `ordenar` puede intercambiar elementos
lejanos, que quitan varias inversiones de una vez; si lo hace o no depende
de qué instancia se elige: con la lista invertida de 10, las dos
estrategias eligen pares que quitan una sola, y con `[4, 5, 1, 3, 2]`,
`reciente` encuentra intercambios más provechosos.

## 5

La clave se lee en las acciones de la instancia, que ya tienen las
posiciones ligadas:

<!-- ejemplo: capitulo-60/soluciones.pl predicado: clave/4 distancia/2 -->
```prolog
%!  clave(+Estrategia, +Largo:integer, +Instancia, -Clave) is det.
%
%   Ejercicio 5: la estrategia lejana. Al ordenar, las acciones de una
%   instancia nombran las dos posiciones que intercambia; la clave prefiere
%   la mayor distancia entre ellas. Una instancia sin intercambio tiene
%   clave 0.
clave(lejana, _, instancia(_, _, _, Acciones), Clave) :-
    distancia(Acciones, Clave).

%!  distancia(+Acciones:list, -Clave:integer) is det.
%
%   Clave es J - I con el signo cambiado si Acciones reemplaza los hechos
%   pos(I, _) y pos(J, _), y 0 si no.
distancia(Acciones, Clave) :-
    (   Acciones = [reemplazar(pos(I, _), _), reemplazar(pos(J, _), _)]
    ->  Clave is I - J
    ;   Clave = 0
    ).
```

<!-- ejemplo: capitulo-60/soluciones.pl predicado: ciclos_invertida/4 -->
```prolog
%!  ciclos_invertida(+Programa, +Estrategia, +Largo:integer,
%!                   -Ciclos:integer) is det.
%
%   Ejercicios 4 y 5. Ciclos es la cantidad de ciclos del Programa de
%   ordenamiento, con la Estrategia, para la lista Largo, ..., 2, 1.
ciclos_invertida(Programa, Estrategia, Largo, Ciclos) :-
    numlist(1, Largo, Creciente),
    reverse(Creciente, Lista),
    posiciones(Lista, Hechos),
    ciclos(Programa, Estrategia, Hechos, Ciclos).
```

```prolog
?- ciclos_invertida(ordenar, lejana, 20, N), ciclos_invertida(ordenar, primera, 20, P).
N = 10,
P = 190.
```

Diez ciclos, contra los 190 de `primera`: el primero intercambia las
posiciones 1 y 20, que es el par más separado; el segundo, 2 y 19; y así
hasta 10 y 11. Cada intercambio deja dos elementos en su lugar definitivo.
La estrategia no forma parte del programa `ordenar`, que no cambió: se
agregó desde otro archivo como una clave más.

## 6

`ejecucion/4` puede aplicar `resultado` en cualquier ciclo. Desde 12 y 8 la
memoria pasa por 12 y 8, después 4 y 8, después 4 y 4: los resultados
posibles son los números que aparecen, 4, 8 y 12:

<!-- ejemplo: capitulo-60/ciclo.pl predicado: ejecucion/4 -->
```prolog
%!  ejecucion(+Programa, +Memoria0:list, -Memoria:list, -Resultado)
%!      is nondet.
%
%   Como ejecutar/4, pero cada ciclo aplica cualquier módulo que se pueda
%   aplicar, con cualquiera de los hechos que cumplen sus condiciones: el
%   retroceso da una respuesta por cada ejecución posible.
ejecucion(Programa, Memoria0, Memoria, Resultado) :-
    programa(Programa, Modulos),
    ciclo_libre(Modulos, Memoria0, Memoria, Resultado).
```

```prolog
?- aggregate_all(count, ejecucion(mcd, [numero(12), numero(8)], _, _), N), setof(R, M^ejecucion(mcd, [numero(12), numero(8)], M, R), Rs).
N = 6,
Rs = [4, 8, 12].
```

Seis ejecuciones: en cada una de las tres memorias, `resultado` puede usar
cualquiera de los dos hechos.

## 7

<!-- ejemplo: capitulo-60/soluciones.pl fragmento: programa(escrutinio, .. ]). -->
```prolog
programa(escrutinio,
    [ otro_voto :: [voto(C), total(C, N)]
           ---> [quitar(voto(C)), {M is N + 1},
                 reemplazar(total(C, N), total(C, M))],
      primer_voto :: [voto(C), no(total(C, _))]
           ---> [quitar(voto(C)), agregar(total(C, 1))]
    ]).
```

```prolog
?- ejecutar(escrutinio, [voto(ana), voto(luis), voto(ana), voto(eva), voto(ana)], M, R).
M = [total(eva, 1), total(luis, 1), total(ana, 3)],
R = nada_aplicable.
```

`no(total(C, _))` distingue el primer voto de cada candidato. Los dos
módulos son mutuamente excluyentes para un mismo voto, así que el orden
entre ellos no cambia el resultado. Cada ciclo quita un voto: la medida es
la cantidad de votos.

## 8

La memoria inicial la construye `memoria_inicial/2` de la versión 4:

<!-- ejemplo: capitulo-60/resolucion.pl predicado: memoria_inicial/2 -->
```prolog
%!  memoria_inicial(+Formula, -Memoria:list) is det.
%
%   Memoria tiene un hecho clausula(C) por cada cláusula de la forma
%   clausal de la negación de Formula.
memoria_inicial(Formula, Memoria) :-
    clausulas(-Formula, Clausulas),
    findall(clausula(C), member(C, Clausulas), Memoria).
```

<!-- ejemplo: capitulo-60/soluciones.pl fragmento: programa(resolucion_subsuncion, .. ]). -->
```prolog
programa(resolucion_subsuncion,
    [ contradiccion :: [clausula([])]
           ---> [parar(contradiccion)],
      tautologia :: [clausula(C), {tautologica(C)}]
           ---> [quitar(clausula(C))],
      subsumir :: [clausula(C1), clausula(C2),
                   {C1 \== C2, ord_subset(C1, C2)}]
           ---> [quitar(clausula(C2))],
      resolver :: [clausula(C1), clausula(C2),
                   {resolvente(C1, C2, R), \+ tautologica(R)},
                   no(clausula(R)), no(hecha(C1, C2, R))]
           ---> [agregar(clausula(R)), agregar(hecha(C1, C2, R))],
      agotado :: []
           ---> [parar(sin_contradiccion)]
    ]).
```

Sin más cambios que el módulo `subsumir`, el programa puede no terminar: un
resolvente subsumido se quita, `no(clausula(R))` vuelve a cumplirse y
`resolver` lo agrega otra vez. El registro `hecha(C1, C2, R)`, el `done` de
Bratko, impide resolver dos veces el mismo par con el mismo resultado; con
una cantidad finita de cláusulas posibles, los registros también son
finitos, y el programa termina. `vigilar/6` con un límite de 500 ciclos lo
confirma en las fórmulas de las pruebas:

| Fórmula | `resolucion` | `resolucion_subsuncion` |
|---|---|---|
| `(a ==> b) & (b ==> c) ==> (a ==> c)` | 4 | 6 |
| `(p ==> q) ==> (-q ==> -p)` | 3 | 4 |
| `p v -p` | 2 | 2 |
| `(p ==> q) ==> (q ==> p)` | 1 | 2 |
| `((p ==> q) ==> p) ==> p` | 2 | 3 |
| `(p v q) & (p ==> r) & (q ==> r) ==> r` | 4 | 7 |

```prolog
?- memoria_inicial(((p ==> q) ==> p) ==> p, M), ciclos(resolucion_subsuncion, primera, M, N).
M = [clausula([p]), clausula([p, -q]), clausula([-p])],
N = 3.
```

En fórmulas tan pequeñas la subsunción no ahorra ciclos: los agrega, porque
cada cláusula quitada es un ciclo, y la contradicción se alcanza antes de
que las cláusulas subsumidas lleguen a usarse. Su beneficio aparece cuando
la memoria crece y cada cláusula quitada evita muchos resolventes; el
[capítulo 62](../capitulo-62-proyecto-demostrador-teoremas/index.md) la
retoma.

## 9

<!-- ejemplo: capitulo-60/soluciones.pl fragmento: programa(resolucion_sin_control, .. ]). -->
```prolog
programa(resolucion_sin_control,
    [ contradiccion :: [clausula([])]
           ---> [parar(contradiccion)],
      tautologia :: [clausula(C), {tautologica(C)}]
           ---> [quitar(clausula(C))],
      resolver :: [clausula(C1), clausula(C2),
                   {resolvente(C1, C2, R), \+ tautologica(R)}]
           ---> [agregar(clausula(R))],
      agotado :: []
           ---> [parar(sin_contradiccion)]
    ]).
```

Con la fórmula de Bratko el programa termina igual: con `primera`, cada
resolvente nuevo queda al principio de la memoria y el siguiente ciclo lo
usa, hasta la cláusula vacía, y `contradiccion` va antes que `resolver`.
Con `(p v q) ==> p`, que no es teorema, la memoria tiene `[p, q]` y `[-p]`,
cuyo resolvente es `[q]`; sin la condición, `resolver` lo agrega en cada
ciclo:

<!-- ejemplo: capitulo-60/soluciones.pl predicado: vigilar_formula/5 -->
```prolog
%!  vigilar_formula(+Programa, +Formula, +Limite:integer, -Resultado,
%!                  -Hechos:integer) is det.
%
%   Ejercicio 9. Ejecuta el Programa de resolución sobre la negación de
%   Formula con vigilar/6. Hechos es la cantidad de hechos de la memoria
%   final.
vigilar_formula(Programa, Formula, Limite, Resultado, Hechos) :-
    memoria_inicial(Formula, Memoria0),
    vigilar(Programa, primera, Limite, Memoria0, Memoria, Resultado),
    length(Memoria, Hechos).
```

```prolog
?- vigilar_formula(resolucion_sin_control, (p v q) ==> p, 50, R, N).
R = limite(50),
N = 52.

?- vigilar_formula(resolucion_sin_control, (a ==> b) & (b ==> c) ==> (a ==> c), 50, R, N).
R = contradiccion,
N = 7.
```

La vigilancia no informa una repetición porque la memoria es una colección
con repeticiones: cada ciclo le agrega una copia de `clausula([q])`, y la
memoria de 52 hechos es distinta de la de 51. Solo el límite la detiene. La
memoria como conjunto, sin hechos repetidos, habría hecho de este programa
uno que repite su memoria; es una decisión de diseño que el
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) toma
para su memoria de trabajo.

## 10

<!-- ejemplo: capitulo-60/soluciones.pl predicado: historia/5 historia/6 escribir_historia/1 -->
```prolog
%!  historia(+Programa, +Estrategia, +Memoria0:list, -Historia:list,
%!           -Resultado) is semidet.
%
%   Ejercicio 10. Historia es la traza de la ejecución como datos: un
%   término ciclo(N, Nombre, Cantidad, Hechos) por ciclo, con el módulo
%   elegido, el tamaño del conjunto de conflicto y los hechos que usa.
%   Falla si falla una acción de la instancia elegida.
historia(Programa, Estrategia, Memoria0, Historia, Resultado) :-
    programa(Programa, Modulos),
    historia(Modulos, Estrategia, 1, Memoria0, Historia, Resultado).

%!  historia(+Modulos:list, +Estrategia, +N:integer, +Memoria0:list,
%!           -Historia:list, -Resultado) is semidet.
%
%   Historia es la traza desde el ciclo N con la memoria Memoria0. Falla
%   si falla una acción de la instancia elegida.
historia(Modulos, Estrategia, N, Memoria0, Historia, Resultado) :-
    conflicto(Modulos, Memoria0, Instancias),
    (   Instancias == []
    ->  Historia = [],
        Resultado = nada_aplicable
    ;   elegir(Estrategia, Memoria0, Instancias, Elegida),
        Elegida = instancia(Nombre, _, Posiciones, Acciones),
        length(Instancias, Cantidad),
        findall(F, ( member(I, Posiciones), nth0(I, Memoria0, F) ), Hechos),
        Historia = [ciclo(N, Nombre, Cantidad, Hechos)|Resto],
        acciones(Acciones, Memoria0, Memoria1, Fin),
        (   Fin = parar(R)
        ->  Resto = [],
            Resultado = R
        ;   N1 is N + 1,
            historia(Modulos, Estrategia, N1, Memoria1, Resto, Resultado)
        )
    ).

%!  escribir_historia(+Historia:list) is det.
%
%   Escribe la Historia con el formato de trazar/5.
escribir_historia(Historia) :-
    forall(member(ciclo(N, Nombre, Cantidad, Hechos), Historia),
           format("~w: ~w de ~w, con ~w~n", [N, Nombre, Cantidad, Hechos])).
```

```prolog
?- historia(mcd, primera, [numero(12), numero(8)], H, R), escribir_historia(H).
1: resta de 3, con [numero(12),numero(8)]
2: resta de 3, con [numero(8),numero(4)]
3: resultado de 2, con [numero(4)]
H = [ciclo(1, resta, 3, [numero(12), numero(8)]), ciclo(2, resta, 3, [numero(8), numero(4)]), ciclo(3, resultado, 2, [numero(4)])],
R = 4.
```

La historia es un valor: una prueba la compara con `==`, otra la cuenta, y
`escribir_historia/1` la escribe. La prueba `ej10_igual_a_trazar` verifica
que el texto es el mismo que el de `trazar/5`. Separar el cálculo de la
escritura es lo que el criterio C6 pide.

## 11

<!-- ejemplo: capitulo-60/soluciones.pl predicado: ruido/2 -->
```prolog
%!  ruido(+Cantidad:integer, -Hechos:list) is det.
%
%   Ejercicio 11. Hechos son Cantidad hechos ruido(I) que ningún módulo
%   usa.
ruido(Cantidad, Hechos) :-
    findall(ruido(I), between(1, Cantidad, I), Hechos).
```

Con los números 60, 120, …, 720 y los 100 hechos `ruido(I)` agregados al
final de la memoria, las mediciones con `time/1` dan:

| Versión | Sin ruido | Con ruido al final | Con ruido al principio |
|---|---|---|---|
| 2, `ejecutar/4` | 8 759 | 16 658 | 18 958 |
| 3, `ejecutar/5` con `primera` | 80 533 | 174 333 | — |

`condicion/4` busca cada patrón con `nth0/3`, que recorre la lista entera:
un hecho que ningún módulo usa cuesta lo mismo que uno útil. En la versión
2 la búsqueda se detiene en la primera instancia, y el ruido al final se
recorre solo cuando hace falta llegar hasta él; en la versión 3 el conjunto
de conflicto entero se reúne en cada ciclo, y cada patrón recorre los 112
hechos. Bratko sugiere indexar o partir la memoria para que cada patrón vea
solo los hechos que pueden unificar con él; el
[capítulo 64](../capitulo-64-proyecto-algoritmo-rete/index.md) lleva esa
idea hasta no repetir la comparación entre ciclos.

## 12

La ejecución usa `vigilar/6` de la versión 5, que termina aunque el
programa no lo haga:

<!-- ejemplo: capitulo-60/terminacion.pl predicado: vigilar/6 -->
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

<!-- ejemplo: capitulo-60/soluciones.pl fragmento: programa(luz_limitada, .. ]). -->
```prolog
programa(luz_limitada,
    [ fin :: [cambios(0)]
           ---> [parar(listo)],
      apagar :: [luz(encendida), cambios(N), {N > 0}]
           ---> [{M is N - 1}, reemplazar(cambios(N), cambios(M)),
                 reemplazar(luz(encendida), luz(apagada))],
      encender :: [luz(apagada), cambios(N), {N > 0}]
           ---> [{M is N - 1}, reemplazar(cambios(N), cambios(M)),
                 reemplazar(luz(apagada), luz(encendida))]
    ]).
```

```prolog
?- vigilar(luz_limitada, primera, 100, [luz(encendida), cambios(3)], M, R).
M = [luz(apagada), cambios(0)],
R = listo.
```

La medida es el número del hecho `cambios(N)`: cada cambio de la luz lo
reduce en uno, y ningún módulo cambia la luz con `N` en 0. `fin` va
primero, pero con `N` mayor que 0 su condición no se cumple, así que el
orden no altera el resultado; en cambio, si `fin` fuera después, con `N` en
0 sería igual el único módulo aplicable, porque los otros dos piden
`N > 0`.

## 13

La solución está en `soluciones_indices.pl`, que carga `indices.pl`. El
programa `contador_fases` tiene tres fases: `limpiar` quita los hechos
`ruido(I)`, `contar` aumenta el contador hasta 3 y deja un `ruido(I)` en
cada paso, e `informar` para con el valor del contador:

<!-- ejemplo: capitulo-60/soluciones_indices.pl fragmento: programa_fases(contador_fases, .. ]). -->
```prolog
% programa_fases(contador_fases, Fases): limpiar quita los hechos
% ruido(I), contar aumenta el contador hasta 3 y deja un ruido(I) en cada
% paso, informar para con el contador.
programa_fases(contador_fases,
    [ limpiar - [ quitar_ruido :: [ruido(I)]
                       ---> [quitar(ruido(I))] ],
      contar - [ paso :: [contador(N), {N < 3}]
                       ---> [{M is N + 1},
                             reemplazar(contador(N), contador(M)),
                             agregar(ruido(M))] ],
      informar - [ fin :: [contador(N)]
                       ---> [parar(N)] ]
    ]).
```

La metarregla de prioridades busca, en cada ciclo, la primera fase con un
conjunto de conflicto no vacío:

<!-- ejemplo: capitulo-60/soluciones_indices.pl predicado: prioridades/5 primera_fase/3 -->
```prolog
%!  prioridades(+Fases:list, +Estrategia, +Memoria0, -Memoria,
%!              -Resultado) is semidet.
%
%   Aplica una instancia de la primera fase con instancias, y vuelve a
%   empezar desde la primera fase, hasta parar/1 o hasta que ninguna fase
%   tiene instancias. Falla si falla una acción de la instancia elegida.
prioridades(Fases, Estrategia, Memoria0, Memoria, Resultado) :-
    (   primera_fase(Fases, Memoria0, Instancias)
    ->  elegir_i(Estrategia, Instancias, instancia(_, _, _, Acciones)),
        acciones_i(Acciones, Memoria0, Memoria1, Fin),
        (   Fin = parar(R)
        ->  Memoria = Memoria1,
            Resultado = R
        ;   prioridades(Fases, Estrategia, Memoria1, Memoria, Resultado)
        )
    ;   Memoria = Memoria0,
        Resultado = nada_aplicable
    ).

%!  primera_fase(+Fases:list, +Memoria, -Instancias:list) is semidet.
%
%   Instancias es el conjunto de conflicto, no vacío, de la primera fase de
%   Fases que tiene alguno. Falla si ninguna lo tiene.
primera_fase([_-Modulos|Fases], Memoria, Instancias) :-
    conflicto_i(Modulos, Memoria, Instancias0),
    (   Instancias0 == []
    ->  primera_fase(Fases, Memoria, Instancias)
    ;   Instancias = Instancias0
    ).
```

Como etapas, `limpiar` se agota al principio, cuando no hay ruido, y no
vuelve a activarse: los tres hechos `ruido(I)` quedan en la memoria. Como
prioridades, `limpiar` vuelve a ser la fase activa después de cada paso de
`contar`, y quita el ruido que ese paso dejó:

```prolog
?- ejecutar_fases_de(contador_fases, primera, [contador(0)], M, R).
M = [ruido(3), contador(3), ruido(2), ruido(1)],
R = 3.

?- ejecutar_prioridades_de(contador_fases, primera, [contador(0)], M, R).
M = [contador(3)],
R = 3.
```

En `mcd_fases` ninguna acción de `calcular` vuelve aplicable a un módulo de
una fase anterior, porque no hay fase anterior, y la fase `informar` para:
las dos metarreglas dan 5 con las tres
estrategias, como comprueban las pruebas de `soluciones_indices.plt`. Con
prioridades, las fases funcionan como una estrategia de resolución de
conflictos que ordena los módulos por grupos; como etapas, además, recuerdan
qué grupos ya terminaron.
