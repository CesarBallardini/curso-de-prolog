# Un configurador, el costo del reconocimiento, demonios y reglas de control

Esta página continúa el [capítulo 64](index.md) después de la
[sección 64.4](index.md#644-version-3-marcos), con las secciones
[64.5](#645-version-4-un-configurador) a
[64.8](#648-version-7-conjuntos-de-reglas-y-reglas-de-control): la versión
4, `configurador.pl`, un sistema de producción que elige los componentes
de una computadora, y las versiones 5 a 7, que miden el costo del
reconocimiento, agregan a los marcos los valores calculados y los
demonios, y agrupan las reglas en conjuntos. Los archivos están en
`ejemplos/capitulo-64/`, con sus pruebas, y cargan las versiones
anteriores; `configurador.pl` carga la versión 3, `marcos.pl`.

## 64.5 Versión 4: un configurador

El configurador elige los componentes de una computadora. La memoria
empieza con el catálogo, un objeto por componente en venta, el pedido, el
consumo acumulado en 0, el orden de las fases —`despues(procesador, placa)`
y los demás— y la primera fase, `buscar(procesador)`:

<!-- ejemplo: capitulo-64/configurador.pl fragmento: catalogo([ .. ]). -->
```prolog
catalogo([ objeto(cpu_a, procesador, [zocalo-am5, nucleos-6, precio-190,
                                      necesita_disipador-no]),
           objeto(cpu_b, procesador, [zocalo-am5, nucleos-8, precio-320,
                                      consumo-120]),
           objeto(cpu_c, procesador, [zocalo-lga1700, nucleos-6,
                                      precio-170]),
           objeto(placa_a, placa, [zocalo-am5, memoria-ddr5, precio-180]),
           objeto(placa_b, placa, [zocalo-lga1700, memoria-ddr4,
                                   precio-120]),
           objeto(mem_a, memoria, [tipo-ddr5, gb-16, precio-60]),
           objeto(mem_b, memoria, [tipo-ddr5, gb-32, precio-110]),
           objeto(mem_c, memoria, [tipo-ddr4, gb-16, precio-40]),
           objeto(dis_a, disipador, [precio-35]),
           objeto(gpu_a, placa_de_video, [consumo-220, precio-400]),
           objeto(fuente_a, fuente, [potencia-450, precio-50]),
           objeto(fuente_b, fuente, [potencia-650, precio-80]),
           objeto(fuente_c, fuente, [potencia-850, precio-120])
         ]).
```

Cada tipo de componente pasa por dos fases. En `buscar(Tipo)`, una regla por
tipo agrega un `candidato` por cada componente compatible con lo ya elegido;
en `elegir(Tipo)`, `descartar_caro` quita el más caro de cada par de
candidatos, y `elegir` se queda con el que resta, suma su consumo y pasa a
la fase siguiente:

<!-- ejemplo: capitulo-64/configurador.pl fragmento: programa(configurador, Reglas) :- .. ], Reglas). -->
```prolog
programa(configurador, Reglas) :-
    con_marcos(
    [ candidato_procesador ::
          [fase(buscar(procesador)), pedido(nucleos, Minimo),
           es(P, procesador, [nucleos-N]), {N >= Minimo}]
          ---> [agregar(candidato(procesador, P))],
      candidato_placa ::
          [fase(buscar(placa)), elegido(procesador, P),
           es(P, procesador, [zocalo-Z]), es(B, placa, [zocalo-Z])]
          ---> [agregar(candidato(placa, B))],
      candidato_memoria ::
          [fase(buscar(memoria)), elegido(placa, B), es(B, placa, [memoria-T]),
           pedido(memoria, Minimo), es(M, memoria, [tipo-T, gb-G]),
           {G >= Minimo}]
          ---> [agregar(candidato(memoria, M))],
      candidato_disipador ::
          [fase(buscar(disipador)), elegido(procesador, P),
           es(P, procesador, [necesita_disipador-si]), es(D, disipador, [])]
          ---> [agregar(candidato(disipador, D))],
      candidato_video ::
          [fase(buscar(placa_de_video)), pedido(video, si),
           es(V, placa_de_video, [])]
          ---> [agregar(candidato(placa_de_video, V))],
      candidato_fuente ::
          [fase(buscar(fuente)), consumo(W), es(F, fuente, [potencia-P]),
           {P >= W * 1.3}]
          ---> [agregar(candidato(fuente, F))],
      a_eleccion :: [fase(buscar(T)), {T \== fin}]
          ---> [reemplazar(fase(buscar(T)), fase(elegir(T)))],
      descartar_caro ::
          [fase(elegir(T)), candidato(T, A), candidato(T, B),
           es(A, componente, [precio-PA]), es(B, componente, [precio-PB]),
           {PA > PB}]
          ---> [quitar(candidato(T, A))],
      elegir ::
          [fase(elegir(T)), candidato(T, X), es(X, componente, [consumo-C]),
           consumo(W), despues(T, T1), {W1 is W + C}]
          ---> [quitar(candidato(T, X)), agregar(elegido(T, X)),
                reemplazar(consumo(W), consumo(W1)),
                reemplazar(fase(elegir(T)), fase(buscar(T1)))],
      faltante :: [fase(elegir(T)), obligatorio(T), despues(T, T1)]
          ---> [agregar(falta(T)),
                reemplazar(fase(elegir(T)), fase(buscar(T1)))],
      omitido :: [fase(elegir(T)), no(obligatorio(T)), despues(T, T1)]
          ---> [reemplazar(fase(elegir(T)), fase(buscar(T1)))],
      terminar :: [fase(buscar(fin))]
          ---> [parar(configurada)]
    ], Reglas).
```

Las fases no están escritas en ningún orden de reglas: las ordena la
estrategia. Todas las reglas tienen la fase como primer patrón, así que MEA
empata en él y decide como LEX. `a_eleccion` usa solo el hecho de la fase:
cualquier regla de candidatos que se pueda disparar usa además hechos del
catálogo, y su lista de sellos, con la fase al frente, es más larga; la
fase cambia cuando no queda ningún candidato por agregar. En `elegir(Tipo)`,
`descartar_caro` usa los dos candidatos, y el segundo es más reciente que el
consumo que usa `elegir`: descarta mientras haya dos. `faltante` y
`omitido`, sin candidatos, pierden contra `elegir`, y se disparan solo si no
hay ninguno.

```prolog
?- rastrear_pedido(configurador, mea, [pedido(nucleos, 8), pedido(memoria, 32), pedido(video, si)], R).
1: candidato_procesador de 2
2: a_eleccion de 1
3: elegir de 2
4: candidato_placa de 2
5: a_eleccion de 1
6: elegir de 2
7: candidato_memoria de 2
8: a_eleccion de 1
9: elegir de 2
10: candidato_disipador de 2
11: a_eleccion de 1
12: elegir de 2
13: candidato_video de 2
14: a_eleccion de 1
15: elegir de 2
16: candidato_fuente de 3
17: candidato_fuente de 2
18: a_eleccion de 1
19: descartar_caro de 4
20: elegir de 2
21: terminar de 1
R = configurada.
```

Solo el procesador `cpu_b` tiene ocho núcleos, y solo la placa `placa_a` su
zócalo; la fuente de 450 W no alcanza para 378 W con el margen, y de las dos
que quedan, `descartar_caro` quita la de 850 W. Un pedido imposible no
detiene la configuración: `faltante` registra el tipo sin candidatos y la
configuración sigue:

```prolog
?- configurar([pedido(nucleos, 6), pedido(memoria, 64), pedido(video, no)], C, P, W).
C = [procesador-cpu_c, placa-placa_b, falta(memoria), disipador-dis_a, fuente-fuente_a],
P = 375,
W = 98.
```

!!! question "Actividad"
    `configurador_invertido` tiene las mismas reglas en el orden inverso.
    Antes de leer lo que sigue, predecir qué componentes elige para el
    pedido de 6 núcleos, 16 GB y sin placa de video con `orden`, con `lex`
    y con `mea`. Comprobarlo con `configuracion/5`.

**Las reglas son independientes.** Con `orden`, el programa invertido pasa a
`elegir` antes de buscar candidatos, porque `a_eleccion` ahora está escrita
antes que las reglas de candidatos, y declara que falta todo:

```prolog
?- configuracion(configurador_invertido, orden, [pedido(nucleos, 6), pedido(memoria, 16), pedido(video, no)], C, R).
C = [falta(procesador), falta(placa), falta(memoria), falta(fuente)],
R = configurada.

?- configuracion(configurador_invertido, lex, [pedido(nucleos, 6), pedido(memoria, 16), pedido(video, no)], C, R).
C = [procesador-cpu_c, placa-placa_b, memoria-mem_c, disipador-dis_a, fuente-fuente_a],
R = configurada.
```

Con LEX y MEA el orden de las reglas no cambia la configuración: la eligen
los sellos y la cantidad de condiciones. Es la propiedad que hace útil a un
sistema de producción grande: se agrega una regla sin buscar dónde
escribirla. El costo es otro: el programador tiene que entender la
estrategia para saber qué regla se dispara, como advierte Merritt.

**Lo que falta.** El configurador elige por fases y, en cada una, lo más
barato: no vuelve atrás si una elección temprana encarece las siguientes.
Y cada ciclo vuelve a comparar todas las reglas con todo el catálogo.

## 64.6 Versión 5: el costo del reconocimiento

`costo.pl` ejecuta el mismo ciclo y registra, en cada uno, el tamaño del
conjunto de conflicto, cuántas de sus instanciaciones ya estaban en el del
ciclo anterior —la misma regla con los mismos sellos— y cuántas inferencias
costó reunirlo, medidas con `statistics/2` como en el
[capítulo 17](../capitulo-17-rendimiento/index.md#171-medir):

<!-- ejemplo: capitulo-64/costo.pl predicado: medir_ciclos/7 -->
```prolog
%!  medir_ciclos(+Reglas:list, +Estrategia, +N:integer, +Anteriores:list,
%!               +Disparadas:list, +Memoria, -Filas:list) is det.
%
%   Como reconocer_actuar/9, y devuelve la fila de cada ciclo. Anteriores
%   es el conjunto ordenado de las instanciaciones del ciclo anterior, como
%   pares Regla-Sellos.
medir_ciclos(Reglas, Estrategia, N, Anteriores, Disparadas, Memoria0,
             Filas) :-
    statistics(inferences, I0),
    conjunto_conflicto(Reglas, Memoria0, Todas),
    statistics(inferences, I1),
    Inferencias is I1 - I0,
    maplist(identidad, Todas, Identidades0),
    sort(Identidades0, Identidades),
    ord_intersection(Identidades, Anteriores, Comunes),
    length(Todas, Tamano),
    length(Comunes, Repetidas),
    refractar(Todas, Disparadas, Nuevas),
    (   Nuevas == []
    ->  Filas = []
    ;   preferida(Estrategia, Nuevas, Elegida),
        Elegida = instanciacion(Nombre, Sellos, _, Acciones),
        ord_add_element(Disparadas, Nombre-Sellos, Disparadas1),
        aplicar_acciones(Acciones, Memoria0, Memoria1, Fin),
        Filas = [ciclo(N, Tamano, Repetidas, Inferencias)|Filas1],
        (   Fin = parar(_)
        ->  Filas1 = []
        ;   N1 is N + 1,
            medir_ciclos(Reglas, Estrategia, N1, Identidades, Disparadas1,
                         Memoria1, Filas1)
        )
    ).
```

```prolog
?- familia(H), medir(familia, orden, H, C, I, R, Inf).
H = [padre(juan, ana), padre(juan, pedro), padre(pedro, luis), padre(pedro, eva), madre(marta, ana), madre(marta, pedro), madre(ana, sofia)],
C = 29,
I = 651,
R = 622,
Inf = 21606.
```

En 29 ciclos se reunieron 651 instanciaciones, y 622 de ellas, el 96 %,
estaban ya en el ciclo anterior. En un programa que solo agrega hechos, el
conjunto de conflicto crece en cada ciclo: la refracción descarta las
instanciaciones viejas, pero el reconocimiento las vuelve a calcular.

El configurador muestra el otro factor, el tamaño de la memoria.
`pedido_ampliado/2` agrega al catálogo memorias que ninguna placa admite:
no cambian la configuración ni el conjunto de conflicto, pero cada patrón
`objeto/3` se compara con ellas en cada ciclo:

```prolog
?- medir_ampliado(100, H, C, I, Inf).
H = 128,
C = 21,
I = 46,
Inf = 72689.
```

| Hechos iniciales | Ciclos | Instanciaciones | Inferencias | Por ciclo |
|---|---|---|---|---|
| 28 | 21 | 46 | 18 789 | 895 |
| 128 | 21 | 46 | 72 689 | 3 461 |
| 228 | 21 | 46 | 126 589 | 6 028 |
| 428 | 21 | 46 | 234 389 | 11 161 |

El costo por ciclo crece con la memoria, en unas 26 inferencias por cada
hecho agregado al catálogo, aunque cada ciclo quita y agrega a lo sumo seis
hechos y el conjunto de conflicto nunca pasa de cuatro instanciaciones. El trabajo útil de un ciclo
es proporcional a lo que cambió; el reconocimiento de este capítulo es
proporcional a todo lo que hay. El
[capítulo 65](../capitulo-65-proyecto-algoritmo-rete/index.md) conserva
entre ciclos las comparaciones ya hechas y procesa solo los hechos que
entran y salen.

## 64.7 Versión 6: valores calculados y demonios

En *Foops*, Merritt da a cada ranura de un marco varias **facetas**: el
valor propio, el valor por omisión, un procedimiento que calcula el valor
cuando no hay otro, y **demonios**, procedimientos que se ejecutan al poner
o quitar un valor. La versión 3 tiene las dos primeras. `facetas.pl` agrega
las otras dos como predicados aparte, `calculo/4` y `demonio/5`, sin cambiar
los marcos: el precio de una memoria se calcula por gigabyte; un precio
propio negativo se rechaza; y cambiar el tamaño de una memoria quita su
precio propio, para que el cálculo vuelva a regir.

<!-- ejemplo: capitulo-64/facetas.pl fragmento: calculo(memoria, precio, Ranuras, Precio) :- .. exclude(de_ranura(precio), Ranuras0, Ranuras). -->
```prolog
calculo(memoria, precio, Ranuras, Precio) :-
    memberchk(gb-Gb, Ranuras),
    Precio is Gb * 3.

% Un precio propio no puede ser negativo.
demonio(componente, precio, Precio, Ranuras, Ranuras) :-
    (   number(Precio),
        Precio >= 0
    ->  true
    ;   domain_error(precio_no_negativo, Precio)
    ).
% Al cambiar el tamaño de una memoria, su precio propio deja de valer, y
% el cálculo vuelve a regir.
demonio(memoria, gb, _, Ranuras0, Ranuras) :-
    exclude(de_ranura(precio), Ranuras0, Ranuras).
```

El valor de una ranura sigue la cadena de herencia, y en cada clase busca
primero el valor por omisión y después el cálculo; así el cálculo de
`memoria` oculta el precio 0 que `componente` da por omisión:

<!-- ejemplo: capitulo-64/facetas.pl predicado: valor_con_facetas/4 faceta/4 poner_con_demonios/5 -->
```prolog
%!  valor_con_facetas(+Clase, +Ranuras:list, +Ranura, -Valor) is semidet.
%
%   Valor es el de la Ranura en un objeto de la Clase con los valores
%   propios Ranuras: el propio, o, en la primera clase de la cadena de
%   herencia que tenga alguno, el valor por omisión o el calculado. Falla
%   si ninguna clase lo define.
valor_con_facetas(_, Ranuras, Ranura, Valor) :-
    memberchk(Ranura-Propio, Ranuras),
    !,
    Valor = Propio.
valor_con_facetas(Clase, Ranuras, Ranura, Valor) :-
    once(( es_un(Clase, Superclase),
           faceta(Superclase, Ranuras, Ranura, Valor0)
         )),
    Valor = Valor0.

%!  faceta(+Clase, +Ranuras:list, +Ranura, -Valor) is semidet.
%
%   Valor es el valor por omisión de la Ranura en la Clase, o, si no lo
%   tiene, el que calcula calculo/4 para los valores propios Ranuras.
faceta(Clase, Ranuras, Ranura, Valor) :-
    (   marco(Clase, _, PorOmision),
        memberchk(Ranura-Valor0, PorOmision)
    ->  Valor = Valor0
    ;   once(calculo(Clase, Ranura, Ranuras, Valor))
    ).

%!  poner_con_demonios(+Clase, +Ranuras0:list, +Ranura, +Valor,
%!                     -Ranuras:list) is det.
%
%   Ranuras es Ranuras0 con Ranura-Valor como valor propio, después de
%   ejecutar el demonio de la Ranura de la primera clase de la cadena de
%   herencia que tenga uno. Sin demonio, es lo que da fijar_ranura/4.
poner_con_demonios(Clase, Ranuras0, Ranura, Valor, Ranuras) :-
    fijar_ranura(Ranuras0, Ranura, Valor, Ranuras1),
    (   es_un(Clase, Superclase),
        clause(demonio(Superclase, Ranura, _, _, _), _)
    ->  once(demonio(Superclase, Ranura, Valor, Ranuras1, Ranuras))
    ;   Ranuras = Ranuras1
    ).
```

```prolog
?- valor_con_facetas(memoria, [gb-16], precio, P).
P = 48.

?- valor_con_facetas(memoria, [gb-16, precio-40], precio, P).
P = 40.
```

Las reglas no cambian: `con_facetas/2` las traduce con `con_marcos/2` y
después cambia la consulta de las ranuras por `consultar_facetas/3` y la
escritura por `poner_con_demonios/5`. El programa `ampliar_memoria` lleva
cada memoria al tamaño pedido e informa su precio; la memoria que tenía un
precio propio de 40 lo pierde al crecer:

```prolog
?- encadenar(ampliar_memoria, orden, [objeto(mem_a, memoria, [gb-8]), objeto(mem_b, memoria, [gb-16, precio-40]), pedido_memoria(32)], M, R).
M = [precio(mem_b, 32, 96), precio(mem_a, 32, 96), objeto(mem_a, memoria, [gb-32]), objeto(mem_b, memoria, [gb-32]), pedido_memoria(32)],
R = nada_aplicable.
```

Un demonio de Merritt también puede conversar con el usuario, como el que
pide confirmación antes de borrar un valor, y su configurador de muebles
lee los datos con reglas que ponen metas de lectura en la memoria. El
capítulo no escribe esa parte: el intérprete es puro, la memoria es un
argumento y cada ciclo se puede repetir y medir, y una lectura del
teclado en medio de las reglas lo impediría. Los demonios de esta versión
solo validan o ajustan las ranuras del objeto que cambia.

## 64.8 Versión 7: conjuntos de reglas y reglas de control

En un programa grande, todas las reglas compiten en cada ciclo, y el
resultado puede depender de la estrategia. Merritt propone agrupar las
reglas en **conjuntos**, cada uno con su conjunto de conflicto, que se
ejecuta hasta que no tiene nada que hacer, y reglas de nivel superior que
deciden qué conjunto sigue; Rowe llama **meta-reglas** a las reglas que
eligen entre reglas. `conjuntos.pl` lo escribe sin cambiar el intérprete.
El hecho `conjunto(C)` de la memoria dice qué conjunto está activo, y
`con_conjuntos/4` agrega la condición `conjunto(C)` al principio de cada
regla del conjunto `C`; las reglas de control no la tienen, y la estrategia
`conjuntos(E)` las pone detrás de todas las demás:

<!-- ejemplo: capitulo-64/conjuntos.pl fragmento: % Con conjuntos(E), la clave es c(P, K): .. clave_estrategia(E, Instanciacion, K). -->
```prolog
% Con conjuntos(E), la clave es c(P, K): P es 0 para una regla de control
% y 1 para las demás, y K es la clave de la estrategia E.
clave_estrategia(conjuntos(E), Instanciacion, c(P, K)) :-
    Instanciacion = instanciacion(Nombre, _, _, _),
    (   control(_, Nombre)
    ->  P = 0
    ;   P = 1
    ),
    clave_estrategia(E, Instanciacion, K).
```

Una regla de control se dispara, entonces, solo cuando el conjunto activo
ya no tiene ninguna instanciación nueva, y reemplaza `conjunto(C)` por el
siguiente. El ejemplo es un ticket de compra en tres etapas: cargar los
ítems como líneas, aplicar las ofertas, sumar. Con conjuntos, el total es
el mismo con cualquier estrategia; sin ellos, LEX suma la línea de la leche,
el hecho más reciente, antes de aplicarle la oferta del 25 %:

```prolog
?- ticket(ticket, conjuntos(lex), [item(pan, 2), item(leche, 3), item(queso, 1)], T).
T = 680.

?- ticket(ticket_plano, lex, [item(pan, 2), item(leche, 3), item(queso, 1)], T).
T = 740.
```

Es el uso de MEA de la [sección 64.3](index.md#643-version-2-las-estrategias-lex-y-mea) llevado un paso más
allá: allí una meta en el primer patrón dirige qué reglas se prefieren;
aquí la etapa activa decide qué reglas existen. La anotación de las reglas
de control es lo único que la versión guarda fuera de la memoria: un hecho
`control/2` que `con_conjuntos/4` escribe al construir el programa.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `cumple/3` y `es_un/2` son `nondet`, `retirar/3` y `aplicar_acciones/4` son `semidet` porque fallan si se quita un hecho ausente, y los ciclos son `det` |
    | C2 | las reglas son datos del lenguaje del [capítulo 61](../capitulo-61-proyecto-interprete-dirigido-patrones/index.md), verificadas con su `bien_formado/1`; los marcos se traducen a ese lenguaje en lugar de extender el intérprete |
    | C4 | los ciclos eligen con un si-entonces y `valor_ranura/4` corta después del valor propio; las pruebas, que fallan si queda una alternativa pendiente, lo confirman |
    | C6 | la memoria viaja en argumentos como un término `mt/2`; la traza es la única salida, y las estrategias se agregan con cláusulas `multifile` sin tocar el intérprete |
    | C7 | 85 pruebas en ocho archivos: la memoria como conjunto, el punto fijo del [capítulo 21](../capitulo-21-base-de-datos-dinamica/index.md), la comparación con el [capítulo 61](../capitulo-61-proyecto-interprete-dirigido-patrones/index.md), las claves y sus empates, la herencia, la traducción de reglas, las tres configuraciones, el programa invertido y las mediciones |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios extienden los programas: cada solución es un
archivo que carga los del capítulo, sin modificarlos.

9. ★ **(2)** Una alternativa para el consumo es una regla aparte,
   `sumar :: [elegido(T, X), es(X, componente, [consumo-C]), consumo(W)]
   ---> [...]`, que suma el consumo de cada componente elegido. Predecir
   qué hace el configurador con esa regla en lugar de la suma de `elegir`,
   comprobarlo con el `encadenar_vigilado/7` del ejercicio 2 y explicar por
   qué la refracción no lo evita.
10. ★ **(3)** Agregar al configurador el gabinete: una clase `gabinete` con
    la ranura `formatos`, la lista de formatos de placa que admite, una
    ranura `formato` en las placas con `atx` por omisión, y una fase
    `gabinete` después de la fuente. Escribirlo como un programa nuevo y una
    memoria inicial nueva, sin cambiar `configurador.pl`.
11. **(3)** Escribir con Prolog, sin reglas de producción, la búsqueda de la
    configuración compatible más barata para un pedido, y compararla con la
    del configurador en los tres pedidos del capítulo. Construir un catálogo
    en que las dos difieran, y explicar por qué.
12. **(2)** Medir con `medir/7` el programa `familia` con dos, cuatro y ocho
    copias de la familia, con nombres distintos. Explicar cómo crecen los
    ciclos, las instanciaciones reunidas y las repetidas.
13. **(2)** Agregar en un archivo propio un cálculo del consumo de una
    `placa_de_video` según su ranura `memoria_gb`, 100 más 20 por
    gigabyte. Predecir qué da `valor_con_facetas/4` para una placa con
    `memoria_gb-8`, comprobarlo, y lograr que el cálculo rija sin quitar
    el valor por omisión de la clase.

## Resumen

| | |
|---|---|
| **sistema de producción** | reglas de condición y acción sobre una memoria de trabajo, repetidas hasta que ninguna tiene nada nuevo que hacer |
| **encadenamiento hacia adelante** | de los datos a las conclusiones, sin una pregunta que guíe la búsqueda |
| **memoria como conjunto** | un hecho que ya está no se agrega; cada hecho nuevo recibe un sello del reloj |
| **instanciación** | una regla con los hechos que cumplen sus condiciones, identificada por la regla y los sellos |
| **refracción** | una instanciación se dispara una sola vez |
| **LEX** | los sellos de mayor a menor, comparados como listas; con los mismos sellos, más condiciones |
| **MEA** | el sello del primer patrón antes que LEX: las metas se atienden como una pila |
| **marco** | una clase con ranuras y valores por omisión que hereda de otras clases |
| **objeto** | un hecho `objeto(Nombre, Clase, Ranuras)` de la memoria, con los valores propios |
| **costo del reconocimiento** | cada ciclo compara todas las reglas con toda la memoria, aunque cambie pocos hechos |
| `memoria.pl`, `produccion.pl` | la memoria con sellos, el conjunto de conflicto, la refracción y el ciclo |
| `estrategias.pl`, `marcos.pl` | LEX, MEA, el robot de las cajas; las clases y la traducción de `es/3` |
| `configurador.pl`, `costo.pl` | el configurador de computadoras y la medición del reconocimiento |
| **faceta, demonio** | un valor calculado cuando la ranura no tiene otro; un procedimiento que se ejecuta al poner un valor |
| **conjunto de reglas, regla de control** | las reglas de una etapa, activas mientras `conjunto(C)` está en la memoria; la regla que pasa a la etapa siguiente cuando la activa no tiene nada que hacer |
| `facetas.pl`, `conjuntos.pl` | los valores calculados y los demonios; los conjuntos de reglas y la estrategia `conjuntos(E)` |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Las reglas de este capítulo compiladas en una red que conserva las comparaciones entre ciclos: memorias alfa por patrón, memorias beta por condiciones unidas, y solo los hechos que cambian recorren la red | [capítulo 65](../capitulo-65-proyecto-algoritmo-rete/index.md) |

## Referencias

- Dennis Merritt, *Building Expert Systems in Prolog*, Springer-Verlag,
  1989 — capítulos «Forward Chaining», «Frames» e «Integration»
  (*Foops* y el configurador de muebles).
  [Edición en línea](https://www.amzi.com/ExpertSystemsInProlog/), de
  Amzi!. Esta página toma de allí la idea de un configurador como caso de
  estudio, la advertencia de que el programador tiene que entender la
  estrategia, y, en las versiones 6 y 7, las facetas de cálculo y los
  demonios de los marcos y los conjuntos de reglas con reglas de nivel
  superior que eligen el siguiente (su ejercicio 5.6).
- Neil C. Rowe, *Artificial Intelligence through Prolog*, Prentice-Hall,
  1988 — capítulos «Control structures for rule-based systems» e
  «Implementation of rule-based systems».
  [Edición en línea](https://hdl.handle.net/10945/36984), del archivo de la
  Naval Postgraduate School. Esta página toma de allí las meta-reglas que
  eligen entre reglas, que aquí son las reglas de control de la versión 7,
  y las reglas parciales con condiciones ya cumplidas, que anticipan la
  red del [capítulo 65](../capitulo-65-proyecto-algoritmo-rete/index.md).
- John McDermott, «R1: A Rule-Based Configurer of Computer Systems»,
  *Artificial Intelligence* 19(1), 1982. Merritt cita XCON, el nombre
  posterior de R1, como el sistema de encadenamiento hacia adelante más
  conocido; es el antecedente del configurador de la versión 4, que elige
  componentes compatibles a partir de un pedido, por fases y sin
  enumerar las configuraciones.

El código del capítulo es propio, escrito para el curso: la memoria, el
intérprete, las claves, la traducción de los marcos, el robot, el
configurador y la medición son nuevos, y de los libros se toman las ideas y
los ejemplos, no el código.
