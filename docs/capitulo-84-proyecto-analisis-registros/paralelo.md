# Muchos días en paralelo

Esta página es parte del [capítulo 84](index.md): su versión 6, que
resume cada día por separado, en paralelo, y combina los resúmenes. La
[sección 84.8](index.md#848-version-6-muchos-dias-en-paralelo) la resume.

## Versión 6: muchos días en paralelo

Ajustar los umbrales con más días obliga a leer más archivos. Los días
son independientes: cada uno se puede leer y resumir en un hilo, como en
el paralelismo de datos del
[capítulo 37](../capitulo-37-concurrencia-y-paralelismo/paralelismo.md#paralelismo-de-datos),
siempre que los resúmenes de los días se puedan **combinar** después. La
media y el desvío se combinan: la cantidad, la suma y la suma de los
cuadrados de dos conjuntos son las sumas de las de cada uno, y Denning
guarda en cada perfil exactamente esos tres números para poder
actualizarlo con cada observación nueva. La mediana no se combina así:
la mediana de dos conjuntos no se deduce de sus medianas. Lo que sí se
combina es el **histograma**, los pares `Valor-Veces`, a costa de guardar
tantos pares como valores distintos haya.

<!-- ejemplo: capitulo-84/paralelo.pl predicado: resumir/3 combinar/3 mezclar/3 mezclar/6 resumir_en_serie/3 resumir_en_paralelo/3 -->
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

<!-- ejemplo: capitulo-84/paralelo.pl predicado: ajustar_resumen/3 mediana_histograma/3 posicion/3 -->
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
    [ejercicio 9](index.md#ejercicios).
