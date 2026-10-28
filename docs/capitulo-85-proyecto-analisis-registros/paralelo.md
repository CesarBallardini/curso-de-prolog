# Muchos días en paralelo

Esta página continúa la página
[Umbrales ajustados a los datos y un umbral aprendido](aprendido.md#857-version-5-un-umbral-aprendido) del
[capítulo 85](index.md), con la sección
[85.8](#858-version-6-muchos-dias-en-paralelo), la última: la versión 6, que resume cada día por separado, en paralelo, y combina los
resúmenes.

## 85.8 Versión 6: muchos días en paralelo

Ajustar los umbrales con más días obliga a leer más archivos. Los días
son independientes: cada uno se puede leer y resumir en un hilo, como en
el paralelismo de datos del
[capítulo 38](../capitulo-38-concurrencia-y-paralelismo/paralelismo.md#384-paralelismo-de-datos),
siempre que los resúmenes de los días se puedan **combinar** después. La
media y el desvío se combinan: la cantidad, la suma y la suma de los
cuadrados de dos conjuntos son las sumas de las de cada uno, y Denning
guarda en cada perfil exactamente esos tres números para poder
actualizarlo con cada observación nueva. La mediana no se combina así:
la mediana de dos conjuntos no se deduce de sus medianas. Lo que sí se
combina es el **histograma**, los pares `Valor-Veces`, a costa de guardar
tantos pares como valores distintos haya.

<!-- ejemplo: capitulo-85/paralelo.pl predicado: resumir/3 combinar/3 mezclar/3 mezclar/6 resumir_en_serie/3 resumir_en_paralelo/3 -->
```prolog
%!  resumir(+Metrica, +Archivo, -Resumen) is det.
%
%   Resumen es r(N, Suma, Cuadrados, Histograma) de los valores de la
%   Metrica en las horas del registro Archivo: la cantidad, la suma, la
%   suma de los cuadrados, y los pares Valor-Veces, ordenados por valor.
resumir(Metrica, Archivo, r(N, Suma, Cuadrados, Histograma)) :-
    leer_registro(Archivo, Pedidos),
    metricas(Pedidos, Horas),
    valores(Metrica, Horas, Valores),
    length(Valores, N),
    sum_list(Valores, Suma),
    foldl(sumar_cuadrado, Valores, 0, Cuadrados),
    msort(Valores, Ordenados),
    clumped(Ordenados, Histograma).

%!  combinar(+R1, +R2, -R) is det.
%
%   R resume los valores de R1 y los de R2 juntos.
combinar(r(N1, S1, Q1, H1), r(N2, S2, Q2, H2), r(N, S, Q, H)) :-
    N is N1 + N2,
    S is S1 + S2,
    Q is Q1 + Q2,
    mezclar(H1, H2, H).

% mezclar(H1, H2, H): H es la unión de los histogramas H1 y H2, con las
% veces de un valor común sumadas.
mezclar([], H, H) :- !.
mezclar(H, [], H) :- !.
mezclar([V1-K1|R1], [V2-K2|R2], H) :-
    compare(Orden, V1, V2),
    mezclar(Orden, V1-K1, R1, V2-K2, R2, H).

% mezclar(Orden, P1, R1, P2, R2, H): un paso de mezclar/3, según el Orden
% de los valores de los primeros pares.
mezclar(<, P1, R1, P2, R2, [P1|H]) :-
    mezclar(R1, [P2|R2], H).
mezclar(>, P1, R1, P2, R2, [P2|H]) :-
    mezclar([P1|R1], R2, H).
mezclar(=, V-K1, R1, V-K2, R2, [V-K|H]) :-
    K is K1 + K2,
    mezclar(R1, R2, H).

%!  resumir_en_serie(+Metrica, +Archivos:list, -Resumen) is det.
%
%   Resumen resume la Metrica en todos los Archivos, leídos uno tras otro.
%   Archivos no es vacía.
resumir_en_serie(Metrica, [A|As], Resumen) :-
    maplist(resumir(Metrica), [A|As], [R|Rs]),
    foldl(combinar, Rs, R, Resumen).

%!  resumir_en_paralelo(+Metrica, +Archivos:list, -Resumen) is det.
%
%   Como resumir_en_serie/3, con cada archivo leído en un hilo.
resumir_en_paralelo(Metrica, [A|As], Resumen) :-
    concurrent_maplist(resumir(Metrica), [A|As], [R|Rs]),
    foldl(combinar, Rs, R, Resumen).
```

```prolog
?- combinar(r(2, 4, 10, [1-1, 3-1]), r(3, 6, 14, [1-1, 2-1, 3-1]), R).
R = r(5, 10, 24, [1-2, 2-1, 3-2]).
```

`mezclar/3` es la mezcla de dos listas ordenadas, con las veces de un
valor común sumadas; `compare/3` da el orden de los dos primeros valores
y `mezclar/6` decide con él, sin alternativas pendientes. Del resumen
combinado salen los mismos umbrales que la versión 4 calculaba con todos
los valores: la mediana se busca recorriendo el histograma hasta la
posición del medio, y la MAD, con el histograma de las distancias.

<!-- ejemplo: capitulo-85/paralelo.pl predicado: ajustar_resumen/3 mediana_histograma/3 posicion/3 -->
```prolog
%!  ajustar_resumen(+Modelo, +Resumen, -Intervalo) is det.
%
%   Como ajustar/3 de la versión 4, con los valores dados por su Resumen.
%   La media y el desvío salen de la cantidad, la suma y los cuadrados; la
%   mediana y la MAD, del histograma.
ajustar_resumen(media_desvio(D), r(N, S, Q, _), entre(Inferior, Superior)) :-
    Media is S / N,
    Desvio is sqrt(max(0, Q / N - Media ** 2)),
    Inferior is Media - D * Desvio,
    Superior is Media + D * Desvio.
ajustar_resumen(mediana_mad(Z), r(N, _, _, H), entre(Inferior, Superior)) :-
    mediana_histograma(H, N, Mediana),
    maplist(distancia_par(Mediana), H, Distancias0),
    keysort(Distancias0, Distancias1),
    sumar_iguales(Distancias1, Distancias),
    mediana_histograma(Distancias, N, Mad),
    Ancho is Z * Mad / 0.6745,
    Inferior is Mediana - Ancho,
    Superior is Mediana + Ancho.

%!  mediana_histograma(+Histograma:list, +N:integer, -Mediana:number) is det.
%
%   Mediana es la mediana de los N valores del Histograma, con sus pares
%   ordenados por valor: el valor de la posición del medio, o la media de
%   los dos del medio si N es par.
mediana_histograma(H, N, Mediana) :-
    (   N mod 2 =:= 1
    ->  K is N // 2,
        posicion(H, K, Mediana)
    ;   K is N // 2 - 1,
        posicion(H, K, A),
        K1 is K + 1,
        posicion(H, K1, B),
        Mediana is (A + B) / 2
    ).

% posicion(H, K, V): V es el valor de la posición K, desde 0, de los
% valores del histograma H puestos en orden.
posicion([V-Veces|Resto], K, Valor) :-
    (   K < Veces
    ->  Valor = V
    ;   K1 is K - Veces,
        posicion(Resto, K1, Valor)
    ).
```

```prolog
?- dias_de_referencia(As), resumir_en_paralelo(fallos, As, R), ajustar_resumen(mediana_mad(3.5), R, I).
As = [registros('2026-09-28.log'), registros('2026-09-29.log'), registros('2026-09-30.log')],
R = r(36, 166, 1606, [0-3, 1-4, 2-7, 3-3, 4-5, 5-4, 6-3, ... - ...|...]),
I = entre(-6.378057820607857, 14.378057820607857).
```

El límite superior es el 14,38 de la versión 4. Las pruebas de
`paralelo.plt` comparan los dos modelos, para las tres métricas, con los
de la versión 4, y el resumen en serie con el resumen en paralelo. Con la
lista de los cuatro días en `A4`, en una computadora con un AMD Ryzen 9
5900HX, de 16 hilos de ejecución, y SWI-Prolog 9.2.9 para Windows:

```text
?- time(resumir_en_serie(fallos, A4, R1)), time(resumir_en_paralelo(fallos, A4, R2)), R1 == R2.
% 84,055 inferences, 0.031 CPU in 0.043 seconds (73% CPU, 2689760 Lips)
% 69,963 inferences, 0.062 CPU in 0.022 seconds (285% CPU, 1119408 Lips)
```

El tiempo transcurrido baja a la mitad con cuatro archivos de unos
cien kilobytes, y la CPU usada pasa del 100 %: varios hilos trabajan a la
vez. Cada día es una tarea, así que con cuatro días no se aprovechan más
de cuatro hilos; con más días la ganancia crece hasta la cantidad de
núcleos, y con uno solo el paralelismo no tiene nada que repartir.

!!! example "Patrón 94 — Resumen que se combina"
    **Problema.** Un cálculo sobre muchos valores se reparte en partes,
    como los días de referencia leídos cada uno en un hilo, y el resultado
    tiene que ser el mismo que con todos los valores juntos.

    **Versión ingenua.** Juntar los valores de todas las partes en una
    lista y calcular al final, como `referencia/1` de la versión 4 con
    `append/2`: cada parte devuelve todos sus valores, y el cálculo que
    importa se hace en serie sobre la lista entera. O combinar los
    resultados de cada parte, que no siempre se puede: la mediana de dos
    conjuntos no se deduce de sus medianas.

    **Patrón.** Resumir cada parte en un término que se combina con el de
    otra y da el resumen de la unión: `resumir/3` produce
    `r(N, Suma, Cuadrados, Histograma)` y `combinar/3` suma los tres
    números y mezcla los histogramas con `mezclar/3`. La combinación es
    asociativa y conmutativa, así que el orden de las partes no cambia el
    resultado: `resumir_en_paralelo/3` resume con
    `concurrent_maplist/3` y combina con `foldl/4`, y da el mismo término
    que `resumir_en_serie/3`. El valor final sale del resumen, con
    `ajustar_resumen/3`: la media y el desvío, de los tres números; la
    mediana y la MAD, del histograma, porque necesitan saber cuántas veces
    aparece cada valor. Es el acumulado que reúne varios valores del
    [Patrón 15](../patrones.md#15-plegado-con-foldl), con una condición
    más: dos acumulados se combinan entre sí, no solo con un elemento. Y
    los hilos no comparten estado, de modo que no hace falta el mutex del
    [Patrón 52](../patrones.md#52-estado-compartido-detras-de-un-mutex):
    cada uno devuelve su resumen.

    **Cuándo no usarlo.** Cuando el resumen no es menor que los datos: en
    los días de referencia, el histograma de los fallos tiene 12 pares
    para 36 horas, pero el de la CPU, con valores de punto flotante, tiene
    36, uno por hora; entonces los valores se agrupan en intervalos, a
    costa de una mediana aproximada. Cuando hay una sola parte, porque no
    hay nada que repartir. Y cuando las partes pueden superponerse: el
    resumen no sabe de dónde vino cada valor, y un día combinado dos veces
    pesa el doble, como mide el
    [ejercicio 11](#ejercicios).

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `cargar_hechos/2` explica el aviso que desactiva, y `hora_del_dia/3` falla fuera de las horas de servicio |
    | C2 | representaciones limpias: `pedido/6` con `sin_medir` cuando falta el dato, `m/4`, `perfil/4`, `r/4`, los límites `mayor(L)` y `menor(L)`, las causas `cliente/2`, `ruta/2` y `sin_trafico` |
    | C3 | los límites son un argumento: los fijos, los ajustados y los del mismo día pasan por el mismo `anomalias/3`; cada versión carga la anterior con `reexport/1`, y la 5 carga el perceptrón del [capítulo 70](../capitulo-70-proyecto-perceptron/index.md) sin copiarlo |
    | C4 | `paso/4`, `paso_comun/3`, `causa/5` y `mezclar/6` deciden por el primer argumento o con si-entonces-sino; el mes se busca en una tabla indexada |
    | C6 | el núcleo trabaja con listas de pedidos; solo los lectores abren archivos, y solo `escribir_metricas/1` y `escribir_anomalias/1` escriben |
    | C7 | 93 pruebas en siete archivos, y 26 sobre las soluciones; una verifica que los archivos de datos son lo que el generador escribe, otra que los dos lectores coinciden, y otras que el resumen combinado da los umbrales de la versión 4 |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos.

11. **(2)** Medir `resumir_en_serie/3` y `resumir_en_paralelo/3` con la
    lista de los cuatro días repetida diez veces. Explicar el resultado, y
    por qué el resumen da 480 horas aunque haya solo 48 distintas.

## Resumen

| | |
|---|---|
| **registro** | la serie de eventos que un sistema anota, uno por pedido o por acción, en el orden en que ocurren |
| **corrida** | lo que el servidor anota entre un arranque y el siguiente; los números de pedido valen dentro de ella |
| **formato común** | una línea de texto por pedido respondido: cliente, identidades, fecha, pedido, código y bytes |
| **métrica** | una cantidad acumulada en un período: un contador de eventos o una medida de recursos |
| **modelo operacional** | un valor es anómalo si pasa un límite fijo |
| **modelo de media y desvío** | un valor es anómalo si se aleja de la media más de D desvíos |
| **MAD** | la mediana de las distancias a la mediana; con el puntaje z modificado, un modelo que los atípicos no desplazan |
| **enmascaramiento** | un atípico grande infla el desvío y esconde a los atípicos menores |
| **perfil** | las métricas de un sujeto, aquí un cliente, en un período |
| **resumen combinable** | un término que resume un conjunto y se combina con el de otro sin volver a los valores |
| **[Patrón 92](../patrones.md#92-limites-como-argumento)** | límites como argumento |
| **[Patrón 93](../patrones.md#93-ajuste-robusto)** | ajuste robusto |
| **[Patrón 94](../patrones.md#94-resumen-que-se-combina)** | resumen que se combina |
| `cargar_hechos/2`, `par_hechos/3`, `sin_respuesta_hechos/2` | el registro cargado como programa |
| `leer_registro/3`, `leer_registro/2`, `paso/4`, `cerrar/2`, `contar_registro/3` | el registro leído como datos, versión 1 |
| `linea//1`, `paso_comun/3`, `leer_comun/3`, `comparar/4`, `diferencias/4` | el formato común, versión 2 |
| `metricas/2`, `medir/2`, `anomalias/3`, `causa/3`, `informe/1`, `informe_anomalias/2` | métricas, anomalías e informes, versión 3 |
| `media_desvio/3`, `mad/3`, `ajustar/3`, `umbrales/3` | los umbrales ajustados, versión 4 |
| `perfiles/2`, `ejemplos_de_referencia/1`, `aprendizaje/2`, `sospechosos/3` | el umbral aprendido, versión 5 |
| `resumir/3`, `combinar/3`, `resumir_en_paralelo/3`, `ajustar_resumen/3` | los resúmenes combinables, versión 6 |
| `style_check/1` | activa o desactiva un aviso del compilador, como el de las cláusulas discontinuas |
| `date_time_stamp/2` | convierte una fecha con su zona horaria en un instante Unix |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Reglas sobre hechos evaluadas de abajo hacia arriba, como los informes sobre datos que no cambian | [capítulo 86](../capitulo-86-proyecto-motor-datalog/index.md) |

## Referencias

- Dorothy E. Denning, «An Intrusion-Detection Model», *IEEE Transactions
  on Software Engineering*, volumen SE-13, número 2, 1987, páginas
  222–232. [Copia de la autora](https://faculty.nps.edu/dedennin/publications/IDS%20model.pdf).
  Esta página toma de allí la cantidad, la suma y la suma de cuadrados
  como los parámetros de un perfil, que la versión 6 combina.

El código del capítulo es propio, escrito para el curso, y los datos son
simulados por `generar.pl`: ninguna dirección pertenece a un cliente
real, y las de los atacantes son de los bloques reservados para
documentación. Las fuentes dan las ideas y los modelos; los lectores, la
gramática, las métricas, las reglas de causa, el ajuste de los umbrales,
los perfiles y los resúmenes combinables no tienen equivalente en ellas.
