# Un configurador

Esta página contiene la sección
[63.5](index.md#635-version-4-un-configurador) del
[capítulo 63](index.md): la versión 4, `configurador.pl`, un sistema de
producción que elige los componentes de una computadora. El archivo está
en `ejemplos/capitulo-63/`, con sus pruebas, y carga la versión 3,
`marcos.pl`.

## Un configurador

El configurador elige los componentes de una computadora. La memoria
empieza con el catálogo, un objeto por componente en venta, el pedido, el
consumo acumulado en 0, el orden de las fases —`despues(procesador, placa)`
y los demás— y la primera fase, `buscar(procesador)`:

<!-- ejemplo: capitulo-63/configurador.pl fragmento: catalogo([ .. ]). -->
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

<!-- ejemplo: capitulo-63/configurador.pl fragmento: programa(configurador, Reglas) :- .. ], Reglas). -->
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
