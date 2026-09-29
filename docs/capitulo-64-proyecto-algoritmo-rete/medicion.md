# La medición y las pruebas alfa

Esta página continúa el [capítulo 64](index.md): la
[sección 64.6](index.md#646-version-5-el-ciclo-sobre-la-red) deja el ciclo
sobre la red funcionando, con los mismos resultados que el
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md); aquí se
mide y se corrige lo que la medición encuentra.

## 64.7 Versión 6: la medición

`medida.pl` cuenta las inferencias de una ejecución completa del
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) y de la red, y en la red separa la **carga** de la memoria inicial de los
**ciclos**. Con el configurador y el pedido de 8 núcleos, 32 GB y video, y
`K` memorias más en el catálogo que ninguna placa admite, como en la
[sección 63.6](../capitulo-63-proyecto-sistema-produccion/index.md#636-version-5-el-costo-del-reconocimiento):

<!-- contexto: capitulo-64/medida.pl -->
```prolog
?- comparar(0, F).
F = fila(28, 20984, 7803, 52653).

?- comparar(400, F).
F = fila(428, 238584, 167130, 570637).
```

| Hechos | Capítulo 63 | Red: carga | Red: ciclos |
|---|---|---|---|
| 28 | 20 984 | 7 803 | 52 653 |
| 128 | 75 384 | 46 319 | 175 336 |
| 228 | 129 784 | 86 084 | 305 142 |
| 428 | 238 584 | 167 130 | 570 637 |
| 828 | 456 184 | 332 337 | 1 117 295 |

La red **pierde**: sus ciclos cuestan más que la ejecución entera del
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md), y crecen más rápido con el catálogo, 1 331 inferencias por
hecho agregado contra 544. La memoria más grande dice por qué:

```prolog
?- memorias_grandes(400, 3, M).
M = [413-3, 3-4, 1-36].
```

El nodo 3 tiene 413 tokens: es la unión de `candidato_procesador` con
`objeto(P, C, R)`, el patrón en que `con_marcos/2` traduce
`es(P, procesador, [nucleos-N])`. El patrón no tiene ninguna constante, así
que todos los objetos del catálogo entran en su memoria alfa, y cada uno
forma un token con la fase y el pedido; la prueba de la clase viene después,
en otro nodo, y descarta 410. Cada cambio de fase quita esos tokens y forma
otros tantos en la fase siguiente:

```prolog
?- ciclos_que_cambian(400, C).
C = [2, 3, 5, 6, 8, 9, 11, 12, 14, 15, 18].
```

Once de los 21 ciclos cuestan más con 400 memorias agregadas; el ciclo 3,
por ejemplo, pasa de 4 329 inferencias a 53 747. La red recuerda las
comparaciones, pero recuerda también las inútiles.

Con otra clase de programa la red gana desde el principio. `cadena(N, H)`
es una familia de `N + 1` generaciones con una persona en cada una;
`antepasado` agrega del orden de `N²/2` hechos, y cada ciclo agrega uno.
La consulta de 40 generaciones tarda unos 45 segundos, casi todos del
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) y de su ejecución previa sin medir, y la consulta muestra la de 20:

```prolog
?- comparar_cadena(20, F).
F = fila(249, 4101400, 5683, 229795).
```

| N | Ciclos | Capítulo 63 | Red: carga | Red: ciclos |
|---|---|---|---|---|
| 10 | 74 | 212 670 | 2 790 | 41 113 |
| 20 | 249 | 4 101 400 | 5 683 | 229 795 |
| 40 | 899 | 120 603 212 | 11 724 | 1 809 623 |

Al duplicar `N`, el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) multiplica su costo por 19 y por 29, porque
cada uno de los ciclos, que se multiplican por 3,4 y por 3,6, compara todas las
reglas con una memoria que también crece; los ciclos de la red multiplican
su costo por 5,6 y por 7,9, poco más que la cantidad de ciclos. Con 40 generaciones, la red hace en 1,8
millones de inferencias lo que al [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) le cuesta 120 millones.

Dos decisiones de la versión 3 son parte de estas cifras. Un nodo cuyo padre
no tiene tokens no se activa por la derecha, porque no tiene con qué unir el
hecho: sin ese control, cargar el catálogo costaría una activación por cada
objeto y cada uno de los doce nodos que leen `objeto/3` ([ejercicio 7](index.md#ejercicios)).
Y las memorias están indexadas, alfa por el primer argumento y beta por los
sellos: con listas, quitar un token era recorrer la memoria, y la red crecía
con el cuadrado del catálogo.

## 64.8 Versión 7: las pruebas de un solo hecho en la red alfa

La prueba `{es_de_clase(C, procesador), consultar(C, R, [nucleos-N])}` que
sigue a `objeto(P, C, R)` mira solo ese hecho: sus variables son las del
patrón, o nuevas. Puede ejecutarse en el nodo alfa, antes de cualquier
unión, y entonces la memoria alfa guarda solo los procesadores. Una prueba
`{G}` que sigue a un patrón `F` se puede mover si cada variable de `G` que
aparece en las condiciones anteriores aparece también en `F`, que el hecho
liga; si no, `G` se ejecutaría con una variable libre que en la regla ya
estaba ligada. Antes de agrupar, cada `{A, B}` se separa en `{A}` y `{B}`,
para mover la parte que se puede mover.

<!-- ejemplo: capitulo-64/pruebas.pl predicado: tomar_pruebas/5 solo_del_hecho/3 -->
```prolog
%!  tomar_pruebas(+Condiciones:list, +F, +Anteriores:list, -Pruebas:list,
%!                -Resto:list) is det.
%
%   Pruebas son las metas de las pruebas del principio de Condiciones que
%   solo miran el hecho del patrón F, y Resto, las condiciones que siguen.
tomar_pruebas(Condiciones, F, Anteriores, Pruebas, Resto) :-
    (   Condiciones = [{G}|Cs],
        solo_del_hecho(G, F, Anteriores)
    ->  Pruebas = [G|Gs],
        tomar_pruebas(Cs, F, Anteriores, Gs, Resto)
    ;   Pruebas = [],
        Resto = Condiciones
    ).

%!  solo_del_hecho(+G, +F, +Anteriores:list) is semidet.
%
%   Cada variable de la meta G que aparece en los pasos Anteriores aparece
%   también en el patrón F.
solo_del_hecho(G, F, Anteriores) :-
    term_variables(G, EnG),
    term_variables(Anteriores, EnAnteriores),
    term_variables(F, EnF),
    forall(( member(V, EnG),
             contiene(EnAnteriores, V) ),
           contiene(EnF, V)).
```

`pasos_con_pruebas/2` es otro agrupador para `compilar_red/3`, que lo recibe
como argumento: la red cambia, las reglas no. Es una transformación en el
momento de compilar, como las del
[capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md).

<!-- contexto: capitulo-64/pruebas.pl -->
```prolog
?- pasos_con_pruebas([p(X), q(X, Y), {Y > 2, X \== Y}], P).
P = [alfa(p(X), []), alfa(q(X, Y), [Y>2, X\==Y])].

?- mostrar_pasos(configurador, candidato_memoria).
fase(buscar(memoria))
elegido(placa,A)
objeto(A,B,C) [es_de_clase(B,placa),consultar(B,C,[memoria-D])]
pedido(memoria,E)
objeto(F,G,H) [es_de_clase(G,memoria)]
{consultar(G,H,[tipo-D,gb-I])}
{I>=E}
true.
```

En la segunda regla, la consulta de la memoria no se mueve: su `D`, el tipo
de memoria que admite la placa, viene de una condición anterior. Se mueve la
clase, y la memoria alfa de `objeto(F, G, H)` guarda solo las memorias. La
red tiene más nodos alfa y menos nodos beta, porque dos pasos alfa con
pruebas distintas ya no son el mismo nodo:

```prolog
?- tamano_con_pruebas(configurador, A, B, C).
A = 29,
B = 43,
C = 58.

?- comparar_con_pruebas(400, F).
F = fila(428, 238584, 167130, 570637, 265033, 127146).

?- ciclos_que_cambian_con_pruebas(400, C).
C = [6, 8].
```

| Hechos | Capítulo 63 | Versión 6: carga | Versión 6: ciclos | Versión 7: carga | Versión 7: ciclos |
|---|---|---|---|---|---|
| 28 | 20 984 | 7 803 | 52 653 | 11 181 | 33 924 |
| 128 | 75 384 | 46 319 | 175 336 | 72 627 | 55 870 |
| 228 | 129 784 | 86 084 | 305 142 | 135 998 | 79 168 |
| 428 | 238 584 | 167 130 | 570 637 | 265 033 | 127 146 |
| 828 | 456 184 | 332 337 | 1 117 295 | 527 796 | 225 918 |

Con 400 memorias agregadas, 19 de los 21 ciclos cuestan exactamente lo mismo
que sin ellas, inferencia por inferencia. Los otros dos son el 6, en que
empieza la fase de la memoria y la regla `candidato_memoria` examina cada
módulo del catálogo, y el 8, en que la fase termina y esos tokens salen. Las
memorias agregadas son memorias: cualquier reconocimiento tiene que
examinarlas una vez para decidir que ninguna placa las admite. La red lo
hace una vez por ejecución; el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md), una vez por ciclo. Después de
cargar la memoria, cada ciclo de la red solo depende de lo que cambia.

**Lo que cuesta.** La carga de un objeto es ahora más cara, 646 inferencias
contra 406 de la versión 6, porque el objeto pasa por las pruebas de clase
de cada nodo alfa de `objeto/3`. Sumadas la carga y los ciclos, el
configurador sigue costando más con la red que con el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md): su
ejecución tiene 21 ciclos y un catálogo que no cambia, y el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md)
gasta 26 inferencias por hecho y por ciclo, contra 646 que la red gasta una
sola vez. La red se paga cuando los ciclos son muchos respecto de los
hechos, como en la cadena de la [sección 64.7](#647-version-6-la-medicion), o cuando la memoria
inicial se carga una vez y el sistema la consulta durante mucho tiempo.
Es el intercambio que Merritt señala al final de su capítulo: la red guarda
copias de los tokens en cada nodo, y cambia memoria y trabajo inicial por
ciclos más baratos.

!!! question "Actividad"
    Predecir, para la regla `descartar_caro` del configurador, qué pruebas
    lleva cada paso alfa y cuál queda en la red beta. Comprobarlo con
    `mostrar_pasos(configurador, descartar_caro)`, y explicar por qué la
    memoria alfa de sus dos patrones `objeto/3` guarda todos los objetos del
    catálogo, y por qué eso no encarece sus uniones.
