# Soluciones del capítulo 63 — Proyecto: un sistema de producción

El código de esta página está en `ejemplos/capitulo-63/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `costo.pl`, que carga las
demás versiones, y no modifica ningún archivo del capítulo: los programas
nuevos son cláusulas de `programa/2`, la estrategia nueva es una cláusula de
`clave_estrategia/3` y las clases nuevas son cláusulas de `marco/3`, tres
predicados que el capítulo declara `multifile`. Los ejercicios 1, 3, 5 y 6
se resuelven con los archivos del capítulo: `rastrear/5` y `preferida/3`
están en `produccion.pl`, y `valor_ranura/4`, en `marcos.pl`. Es
`% solo-local`, porque carga otros archivos.

## 1

La memoria tiene `b` sobre `a`, y la meta pide la torre inversa. La única
regla aplicable al principio es `despejar_segunda`, porque hay algo sobre
la segunda caja de la meta, `a`:

<!-- ejemplo: capitulo-63/estrategias.pl fragmento: despejar_segunda :: .. [agregar(meta(despejar(Z)))], -->
```prolog
      despejar_segunda :: [meta(apilar([_, Y|_])), sobre(Z, Y)]
           ---> [agregar(meta(despejar(Z)))],
```

```prolog
?- rastrear(cajas, orden, [sobre(a, piso), sobre(b, a), meta(apilar([b, a]))], M, R).
1: despejar_segunda de 1, con [3-meta(apilar([b,a])),2-sobre(b,a)]
2: bajar de 2, con [4-meta(despejar(b)),2-sobre(b,a)]
3: apilar de 1, con [3-meta(apilar([b,a])),1-sobre(a,piso)]
4: terminada de 1, con [7-meta(apilar([a]))]
M = [sobre(a, b), sobre(b, piso)],
R = nada_aplicable.
```

Son cuatro ciclos. En el segundo compiten `bajar` y `despejada` por la meta
`despejar(b)`: `b` no tiene nada encima, pero no está en el piso; `bajar`
está escrita antes y gana. `despejada` no vuelve a tener instanciación,
porque `bajar` quita la meta. Después `a` y `b` están libres, `apilar` pone
`a` sobre `b` y `terminada` quita la meta que queda, `apilar([a])`.

## 2

`encadenar_vigilado/7` repite el ciclo de `reconocer_actuar/9` con un
límite, y con la refracción según un argumento:

<!-- ejemplo: capitulo-63/soluciones.pl predicado: encadenar_vigilado/7 vigilado_63/9 candidatas/4 -->
```prolog
%!  encadenar_vigilado(+Programa, +Estrategia, +Refraccion, +Limite:integer,
%!                     +Hechos:list, -Memoria:list, -Resultado) is det.
%
%   Como encadenar/5, con la refracción si Refraccion es si y sin ella si
%   es no. Resultado es limite(Limite) si el programa disparó Limite
%   reglas sin terminar.
encadenar_vigilado(Programa, Estrategia, Refraccion, Limite, Hechos,
                   Memoria, Resultado) :-
    programa(Programa, Reglas),
    memoria_con(Hechos, Memoria0),
    vigilado_63(Reglas, Estrategia, Refraccion, Limite, 0, [], Memoria0,
                Memoria1, Resultado),
    hechos(Memoria1, Memoria).

%!  vigilado_63(+Reglas:list, +Estrategia, +Refraccion, +Limite:integer,
%!              +N:integer, +Disparadas:list, +Memoria0, -Memoria,
%!              -Resultado) is det.
%
%   El ciclo de reconocer_actuar/9 con un límite de ciclos. N es la
%   cantidad de ciclos hechos.
vigilado_63(Reglas, Estrategia, Refraccion, Limite, N, Disparadas,
            Memoria0, Memoria, Resultado) :-
    conjunto_conflicto(Reglas, Memoria0, Todas),
    candidatas(Refraccion, Todas, Disparadas, Nuevas),
    (   Nuevas == []
    ->  Memoria = Memoria0,
        Resultado = nada_aplicable
    ;   N >= Limite
    ->  Memoria = Memoria0,
        Resultado = limite(N)
    ;   preferida(Estrategia, Nuevas, Elegida),
        Elegida = instanciacion(Nombre, Sellos, _, Acciones),
        ord_add_element(Disparadas, Nombre-Sellos, Disparadas1),
        aplicar_acciones(Acciones, Memoria0, Memoria1, Fin),
        N1 is N + 1,
        (   Fin = parar(R)
        ->  Memoria = Memoria1,
            Resultado = R
        ;   vigilado_63(Reglas, Estrategia, Refraccion, Limite, N1,
                        Disparadas1, Memoria1, Memoria, Resultado)
        )
    ).

%!  candidatas(+Refraccion, +Todas:list, +Disparadas:list, -Nuevas:list)
%!      is det.
%
%   Nuevas son Todas sin las ya disparadas si Refraccion es si, y Todas si
%   es no.
candidatas(si, Todas, Disparadas, Nuevas) :-
    refractar(Todas, Disparadas, Nuevas).
candidatas(no, Todas, _, Todas).
```

Sin refracción, la primera instanciación del conjunto de conflicto es la
misma en cada ciclo: `progenitor_p` con `padre(juan, ana)`. La primera vez
agrega `progenitor(juan, ana)`; las siguientes, la memoria no cambia,
porque el hecho ya está:

```prolog
?- encadenar_vigilado(familia, orden, no, 50, [padre(juan, ana), madre(ana, sofia)], M, R).
M = [progenitor(juan, ana), madre(ana, sofia), padre(juan, ana)],
R = limite(50).
```

La memoria como conjunto evita que crezca, pero no cambia qué regla se
elige: con la misma memoria, el mismo conjunto de conflicto y la misma
estrategia, el ciclo elige lo mismo para siempre. La refracción es lo que
cambia la elección, porque saca del conjunto lo ya hecho. Con `si`, la
misma familia llega al punto fijo de 34 hechos.

## 3

Las claves se escriben ordenando los sellos de mayor a menor; MEA antepone
el sello del primer patrón, el primero de la lista sin ordenar:

| Instanciación | LEX | MEA |
|---|---|---|
| `[4, 9]`, 2 condiciones | `lex([9, 4], 2)` | `mea(4, [9, 4], 2)` |
| `[9, 2, 7]`, 3 condiciones | `lex([9, 7, 2], 3)` | `mea(9, [9, 7, 2], 3)` |
| `[9, 7]`, 3 condiciones | `lex([9, 7], 3)` | `mea(9, [9, 7], 3)` |

Con LEX, `[9, 7, 2]` y `[9, 7]` superan a `[9, 4]` en el segundo sello, y
`[9, 7]` es prefijo de `[9, 7, 2]`: gana la segunda, que usa un hecho más.
Con MEA, la primera queda afuera por su primer sello, 4, y entre las otras
dos decide LEX:

```prolog
?- L = [instanciacion(r1, [4, 9], 2, []), instanciacion(r2, [9, 2, 7], 3, []), instanciacion(r3, [9, 7], 3, [])], preferida(lex, L, E1), preferida(mea, L, E2).
L = [instanciacion(r1, [4, 9], 2, []), instanciacion(r2, [9, 2, 7], 3, []), instanciacion(r3, [9, 7], 3, [])],
E1 = E2, E2 = instanciacion(r2, [9, 2, 7], 3, []).
```

## 4

La clave de `prioridad` es un término `prio(P, Lex)`: el orden estándar
compara primero la prioridad y, si empatan, la clave de LEX:

<!-- ejemplo: capitulo-63/soluciones.pl fragmento: prioridad(apilar, 1). .. clave_estrategia(lex, Instanciacion, Lex). -->
```prolog
prioridad(apilar, 1).

% Con prioridad, la clave es prio(P, Lex): la prioridad de la regla y la
% clave de LEX.
clave_estrategia(prioridad, Instanciacion, prio(P, Lex)) :-
    Instanciacion = instanciacion(Nombre, _, _, _),
    prioridad_de(Nombre, P),
    clave_estrategia(lex, Instanciacion, Lex).
```

<!-- ejemplo: capitulo-63/soluciones.pl predicado: prioridad_de/2 -->
```prolog
%!  prioridad_de(+Regla, -P:integer) is det.
%
%   P es la prioridad de la Regla, o 0 si no tiene.
prioridad_de(Regla, P) :-
    (   prioridad(Regla, P0)
    ->  P = P0
    ;   P = 0
    ).
```

Con prioridad para `apilar`, el robot apila siempre que puede, como con
`orden`, donde `apilar` está escrita primero:

```prolog
?- rastrear(cajas, prioridad, [sobre(a, piso), sobre(b, piso), sobre(c, a), sobre(d, piso), meta(apilar([b, c])), meta(apilar([a, d]))], M, R).
1: apilar de 2, con [5-meta(apilar([b,c])),3-sobre(c,a)]
2: apilar de 2, con [6-meta(apilar([a,d])),4-sobre(d,piso)]
3: terminada de 2, con [10-meta(apilar([d]))]
4: terminada de 1, con [8-meta(apilar([c]))]
M = [sobre(d, a), sobre(c, b), sobre(b, piso), sobre(a, piso)],
R = nada_aplicable.
```

La prioridad es la forma más directa de controlar un sistema de producción,
y también la que más se aleja de su idea: la regla deja de ser
independiente de las demás.

## 5

Las tres estrategias hacen lo mismo:

```prolog
?- rastrear(cajas, mea, [sobre(a, piso), sobre(b, a), sobre(c, b), meta(apilar([c, b, a]))], M, R).
1: despejar_segunda de 1, con [4-meta(apilar([c,b,a])),3-sobre(c,b)]
2: bajar de 2, con [5-meta(despejar(c)),3-sobre(c,b)]
3: apilar de 1, con [4-meta(apilar([c,b,a])),2-sobre(b,a)]
4: apilar de 1, con [8-meta(apilar([b,a])),1-sobre(a,piso)]
5: terminada de 1, con [10-meta(apilar([a]))]
M = [sobre(a, b), sobre(b, c), sobre(c, piso)],
R = nada_aplicable.
```

Con `orden` y con `lex` la traza es idéntica. En cuatro de los cinco ciclos
el conjunto de conflicto tiene una sola instanciación nueva, y en el
segundo, `bajar` gana a `despejada` con las tres estrategias: está escrita
antes, y usa un hecho más con los mismos sellos. Una estrategia solo
decide cuando hay de dónde elegir; Covington escribe sus reglas para que el
conjunto tenga un solo miembro, y entonces cualquier estrategia da el mismo
resultado.

## 6

Una fuente sin precio propio lo hereda de `componente`, 0; la memoria con
`consumo-8` usa su valor propio; `disipador` no hereda de `refrigerado`, y
ninguna de sus clases define la ranura:

```prolog
?- valor_ranura(fuente, [], precio, V).
V = 0.

?- valor_ranura(memoria, [consumo-8], consumo, V).
V = 8.

?- valor_ranura(disipador, [], necesita_disipador, V).
false.
```

## 7

Las dos clases tienen los mismos padres en órdenes distintos:

<!-- ejemplo: capitulo-63/soluciones.pl fragmento: marco(apu, .. marco(apu_invertida, [placa_de_video, procesador], []). -->
```prolog
marco(apu, [procesador, placa_de_video], []).
marco(apu_invertida, [placa_de_video, procesador], []).
```

`es_un/2` recorre en profundidad: para `apu`, `procesador` y sus padres van
antes que `placa_de_video`. El consumo es el de `procesador`, 65; con los
padres invertidos, el de `placa_de_video`, 200. La necesidad de disipador
viene de `refrigerado` en los dos casos, porque `placa_de_video` no define
la ranura y la búsqueda sigue hasta encontrarla:

```prolog
?- valor_ranura(apu, [], consumo, C), valor_ranura(apu, [], necesita_disipador, D).
C = 65,
D = si.

?- valor_ranura(apu_invertida, [], consumo, C), valor_ranura(apu_invertida, [], necesita_disipador, D).
C = 200,
D = si.
```

Con herencia múltiple, el orden de los padres es parte de la definición de
la clase.

## 8

El programa nuevo reemplaza `elegir` por una versión que no suma, y agrega
`sumar`:

<!-- ejemplo: capitulo-63/soluciones.pl predicado: configurar_sumando/4 -->
```prolog
%!  configurar_sumando(+Estrategia, -Componentes:list, -Consumo:number,
%!                     -Resultado) is det.
%
%   Ejecuta configurador_sumando con la Estrategia, la refracción y un
%   límite de 200 ciclos, para el pedido de 8 núcleos, 32 GB y placa de
%   video.
configurar_sumando(Estrategia, Componentes, Consumo, Resultado) :-
    memoria_del_pedido([pedido(nucleos, 8), pedido(memoria, 32),
                        pedido(video, si)], Hechos),
    encadenar_vigilado(configurador_sumando, Estrategia, si, 200, Hechos,
                       Memoria, Resultado),
    componentes(Memoria, Componentes, _),
    memberchk(consumo(Consumo), Memoria).
```

<!-- ejemplo: capitulo-63/soluciones.pl fragmento: programa(configurador_sumando, Reglas) :- .. append(Nuevas, Reglas1, Reglas). -->
```prolog
programa(configurador_sumando, Reglas) :-
    programa(configurador, Reglas0),
    exclude(regla_llamada(elegir), Reglas0, Reglas1),
    con_marcos(
        [ elegir ::
              [fase(elegir(T)), candidato(T, X), despues(T, T1)]
              ---> [quitar(candidato(T, X)), agregar(elegido(T, X)),
                    reemplazar(fase(elegir(T)), fase(buscar(T1)))],
          sumar ::
              [elegido(_, X), es(X, componente, [consumo-C]), consumo(W),
               {W1 is W + C}]
              ---> [reemplazar(consumo(W), consumo(W1))]
        ], Nuevas),
    append(Nuevas, Reglas1, Reglas).
```

Con MEA, `sumar` no se dispara nunca: su primer patrón es un `elegido`, y
el hecho de la fase, primer patrón de todas las demás reglas, es siempre
más reciente, porque `elegir` lo reemplaza después de agregar `elegido`. El
consumo queda en 0, y la fuente elegida es la de 450 W, que no alcanza:

```prolog
?- configurar_sumando(mea, C, W, R).
C = [procesador-cpu_b, placa-placa_a, memoria-mem_b, disipador-dis_a, placa_de_video-gpu_a, fuente-fuente_a],
W = 0,
R = configurada.

?- configurar_sumando(orden, C, W, R).
C = [procesador-cpu_b],
W = 23640,
R = limite(200).
```

Con `orden`, `sumar` está escrita al principio y se dispara en cuanto hay
un `elegido`, y no para: cada suma reemplaza `consumo(W)` por un hecho con
otro sello, y la instanciación de `sumar` con el mismo `elegido` y el
consumo nuevo es otra instanciación. La refracción compara sellos, y el
sello cambió. En el capítulo, `elegir` suma en la misma acción que elige,
y la suma ocurre una vez por componente.

## 9

El gabinete necesita una clase, una ranura nueva en las placas, una regla
de candidatos y dos fases en la memoria:

<!-- ejemplo: capitulo-63/soluciones.pl fragmento: % Una segunda cláusula .. Reglas = [Regla|Reglas0]. -->
```prolog
% Una segunda cláusula de marco/3 para placa le agrega una ranura.
marco(gabinete, [componente], [formatos-[atx]]).
marco(placa, [componente], [formato-atx]).

% El configurador con una regla más, para el gabinete.
programa(configurador_gabinete, Reglas) :-
    programa(configurador, Reglas0),
    con_marcos(
        [ candidato_gabinete ::
              [fase(buscar(gabinete)), elegido(placa, B),
               es(B, placa, [formato-F]), es(G, gabinete, [formatos-Fs]),
               {memberchk(F, Fs)}]
              ---> [agregar(candidato(gabinete, G))]
        ], [Regla]),
    Reglas = [Regla|Reglas0].
```

<!-- ejemplo: capitulo-63/soluciones.pl predicado: memoria_con_gabinete/2 -->
```prolog
%!  memoria_con_gabinete(+Pedido:list, -Hechos:list) is det.
%
%   Hechos es la memoria inicial del configurador para el Pedido, con dos
%   gabinetes y una placa micro-ATX más en el catálogo, y el gabinete como
%   fase obligatoria después de la fuente.
memoria_con_gabinete(Pedido, Hechos) :-
    memoria_del_pedido(Pedido, Hechos0),
    subtract(Hechos0, [despues(fuente, fin)], Hechos1),
    append(Hechos1,
           [objeto(placa_c, placa, [zocalo-lga1700, memoria-ddr4,
                                    formato-microatx, precio-90]),
            objeto(gab_a, gabinete, [formatos-[microatx], precio-40]),
            objeto(gab_b, gabinete, [formatos-[atx, microatx], precio-70]),
            despues(fuente, gabinete), despues(gabinete, fin),
            obligatorio(gabinete)],
           Hechos).
```

La segunda cláusula de `marco/3` para `placa` le agrega la ranura
`formato`: `valor_ranura/4` recorre todas las cláusulas de una clase.
`es_un/2` da `componente` dos veces para `placa`, lo que no cambia ninguna
consulta, porque `es_de_clase/2` y `valor_ranura/4` usan la primera
respuesta. Las reglas de descarte y de elección son las del capítulo, y
sirven para el tipo nuevo sin cambios; la placa micro-ATX, más barata,
cambia también la elección de la placa:

```prolog
?- configurar_gabinete([pedido(nucleos, 6), pedido(memoria, 16), pedido(video, no)], C).
C = [procesador-cpu_c, placa-placa_c, memoria-mem_c, disipador-dis_a, fuente-fuente_a, gabinete-gab_a].

?- configurar_gabinete([pedido(nucleos, 8), pedido(memoria, 32), pedido(video, si)], C).
C = [procesador-cpu_b, placa-placa_a, memoria-mem_b, disipador-dis_a, placa_de_video-gpu_a, fuente-fuente_b, gabinete-gab_b].
```

## 10

`compatible/4` genera las configuraciones con las mismas condiciones que las
reglas, y `aggregate_all/3` se queda con la de menor precio:

<!-- ejemplo: capitulo-63/soluciones.pl predicado: mas_barata/4 compatible/4 -->
```prolog
%!  mas_barata(+Catalogo:list, +Pedido:list, -Componentes:list,
%!             -Precio:number) is semidet.
%
%   Como mas_barata/3, con otro Catalogo.
mas_barata(Catalogo, Pedido, Componentes, Precio) :-
    aggregate_all(min(P, C), compatible(Catalogo, Pedido, C, P),
                  min(Precio, Componentes)).

%!  compatible(+Catalogo:list, +Pedido:list, -Componentes:list,
%!             -Precio:number) is nondet.
%
%   Componentes es una configuración que cumple el Pedido con el Catalogo,
%   con las mismas condiciones que las reglas del configurador, y Precio,
%   la suma de sus precios.
compatible(Catalogo, Pedido, Componentes, Precio) :-
    memberchk(pedido(nucleos, Nucleos), Pedido),
    memberchk(pedido(memoria, Gb), Pedido),
    memberchk(pedido(video, Video), Pedido),
    ranura(Catalogo, Cpu, procesador, nucleos, N), N >= Nucleos,
    ranura(Catalogo, Cpu, procesador, zocalo, Z),
    ranura(Catalogo, Placa, placa, zocalo, Z),
    ranura(Catalogo, Placa, placa, memoria, T),
    ranura(Catalogo, Mem, memoria, tipo, T),
    ranura(Catalogo, Mem, memoria, gb, G), G >= Gb,
    disipador(Catalogo, Cpu, Disipador),
    video(Catalogo, Video, Placas),
    append([[Cpu, Placa, Mem], Disipador, Placas], Partes),
    consumo_total(Catalogo, Partes, W),
    ranura(Catalogo, Fuente, fuente, potencia, P), P >= W * 1.3,
    append(Partes, [Fuente], Componentes),
    consumo_o_precio(Catalogo, precio, Componentes, Precio).
```

En los dos pedidos posibles del capítulo, la búsqueda da la misma
configuración que el configurador, y con 64 GB no hay ninguna:

```prolog
?- mas_barata([pedido(nucleos, 6), pedido(memoria, 16), pedido(video, no)], C, P).
C = [cpu_c, placa_b, mem_c, dis_a, fuente_a],
P = 415.

?- mas_barata([pedido(nucleos, 6), pedido(memoria, 64), pedido(video, no)], C, P).
false.
```

El configurador elige el procesador más barato sin mirar lo que cuesta lo
que viene después. Con el disipador a 110 en lugar de 35, `cpu_c` sigue
siendo el procesador más barato, pero necesita el disipador, y `cpu_a` trae
el suyo:

```prolog
?- comparar_disipador_caro(O, PO, E, PE).
O = [cpu_a, placa_a, mem_a, fuente_a],
PO = 480,
E = [procesador-cpu_c, placa-placa_b, memoria-mem_c, disipador-dis_a, fuente-fuente_a],
PE = 490.
```

Un sistema de producción avanza sin volver atrás: cada regla cambia la
memoria y la decisión queda tomada. La búsqueda de Prolog prueba todas las
combinaciones y retrocede. Para un catálogo grande, la búsqueda completa
crece con el producto de las cantidades de componentes, y la configuración
por fases, con su suma.

## 11

`familias/2` construye `K` copias de la familia con nombres `N-I`:

<!-- ejemplo: capitulo-63/soluciones.pl predicado: familias/2 copia/3 -->
```prolog
%!  familias(+K:integer, -Hechos:list) is det.
%
%   Hechos son los de K copias de la familia del capítulo 20, con cada
%   nombre N de la copia I escrito N-I.
familias(K, Hechos) :-
    familia(Familia),
    findall(H, ( between(1, K, I),
                 member(H0, Familia),
                 copia(I, H0, H) ),
            Hechos).

%!  copia(+I:integer, +Hecho0, -Hecho) is det.
%
%   Hecho es Hecho0 con cada nombre N reemplazado por N-I.
copia(I, Hecho0, Hecho) :-
    Hecho0 =.. [F, A, B],
    Hecho =.. [F, A-I, B-I].
```

```prolog
?- forall(member(K, [1, 2, 4, 8]), (familias(K, H), medir(familia, orden, H, C, I, R, _), format("~w ~w ~w ~w~n", [K, C, I, R]))).
1 29 651 622
2 58 2640 2582
4 116 10632 10516
8 232 42672 42440
true.
```

Los ciclos crecen como las copias: cada copia tiene sus 29. Las
instanciaciones reunidas se multiplican por cuatro cada vez que las copias
se duplican: hay el doble de ciclos, y en cada uno el conjunto de conflicto
tiene las instanciaciones de todas las copias, el doble. Crecen con el
cuadrado de la cantidad de copias, y casi todas, más del 99 % con ocho
copias, estaban en el ciclo anterior.

## 12

`con_origen/2` es una transformación de las reglas como datos, como las del
[capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md): no
cambia el intérprete:

<!-- ejemplo: capitulo-63/soluciones.pl predicado: con_origen/2 regla_con_origen/2 con_su_origen/4 -->
```prolog
%!  con_origen(+Reglas0:list, -Reglas:list) is det.
%
%   Reglas son las Reglas0 con una acción agregar(origen(F, Regla, Hechos))
%   después de cada agregar(F): Hechos son los hechos que cumplen los
%   patrones de la Regla.
con_origen(Reglas0, Reglas) :-
    maplist(regla_con_origen, Reglas0, Reglas).

%!  regla_con_origen(+Regla0, -Regla) is det.
%
%   Regla es Regla0 con los origen/3 agregados.
regla_con_origen(Nombre :: Condiciones ---> Acciones0,
                 Nombre :: Condiciones ---> Acciones) :-
    include(patron_de_hecho, Condiciones, Patrones),
    maplist(con_su_origen(Nombre, Patrones), Acciones0, Partes),
    append(Partes, Acciones).

%!  con_su_origen(+Nombre, +Patrones:list, +Accion, -Acciones:list) is det.
%
%   Acciones es [Accion] seguida de su origen si Accion es agregar/1.
con_su_origen(Nombre, Patrones, Accion, Acciones) :-
    (   Accion = agregar(F)
    ->  Acciones = [Accion, agregar(origen(F, Nombre, Patrones))]
    ;   Acciones = [Accion]
    ).
```

Los patrones de la regla, ya instanciados cuando se ejecuta la acción, son
los hechos que la cumplieron. `explicar/2` reconstruye el árbol de la
derivación desde los hechos `origen/3` de la memoria final:

<!-- ejemplo: capitulo-63/soluciones.pl predicado: explicar/3 -->
```prolog
%!  explicar(+Memoria:list, +Hecho, -Arbol) is nondet.
%
%   Como explicar/2, en la Memoria dada.
explicar(Memoria, Hecho, Arbol) :-
    (   memberchk(origen(Hecho, _, _), Memoria)
    ->  member(origen(Hecho, Regla, Usados), Memoria),
        maplist(explicar(Memoria), Usados, Arboles),
        Arbol = por(Hecho, Regla, Arboles)
    ;   Arbol = inicial(Hecho)
    ).
```

```prolog
?- explicar(antepasado(juan, sofia), A).
A = por(antepasado(juan, sofia), antepasado_2, [por(progenitor(juan, ana), progenitor_p, [inicial(padre(juan, ana))]), por(antepasado(ana, sofia), antepasado_1, [por(progenitor(ana, sofia), progenitor_m, [inicial(madre(ana, sofia))])])]) ;
false.
```

Un hecho agregado dos veces tiene dos orígenes, y `explicar/2` da una
explicación por cada uno. Merritt señala la dificultad de fondo: una regla
puede quitar los hechos que la justificaron, y la explicación se refiere
entonces a hechos que ya no están en la memoria. Aquí los `origen/3`
guardan copias de esos hechos, y la explicación sigue siendo posible.
