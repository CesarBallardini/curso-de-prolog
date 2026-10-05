# Explicar un ejemplo y generalizar la explicación

Esta página contiene las secciones
[68.5](index.md#685-version-5-explicar-un-ejemplo) y
[68.6](index.md#686-version-6-generalizar-la-explicacion) del
[capítulo 68](index.md): la teoría del dominio, la explicación de un
ejemplo con un metaintérprete con árbol de prueba, y la generalización de
esa explicación en una regla. Los ejemplos están en `teorias.pl`,
`explicacion.pl` y `ebg.pl`, en `ejemplos/capitulo-68/`, con sus pruebas;
cargan archivos de otros capítulos y se ejecutan localmente.

## Versión 5: explicar un ejemplo

Las entradas del aprendizaje por explicación, en la formulación de
DeJong y Mooney, son un concepto, un ejemplo, una teoría del dominio y un
criterio de operacionalidad. El dominio de la taza viene de Winston y
sus colegas, a través de Mitchell, Keller y Kedar-Cabelli.
Una **teoría del dominio** es un conjunto de reglas. La de la taza dice
que un objeto sirve de taza si se puede levantar, contiene un líquido y
se apoya firme, y define cada una de esas condiciones:

<!-- ejemplo: capitulo-68/teorias.pl predicado: regla/2 -->
```prolog
%!  regla(?T, -R) is nondet.
%
%   R es una regla de la teoría T: un término Cabeza :- Cuerpo.
regla(taza, (taza(X) :- se_levanta(X), contiene_liquido(X), estable(X))).
regla(taza, (se_levanta(X) :- liviano(X), tiene_asa(X))).
regla(taza, (liviano(X) :- peso(X, P), P < 400)).
regla(taza, (liviano(X) :- material(X, carton))).
regla(taza, (tiene_asa(X) :- parte(X, A), asa(A))).
regla(taza, (contiene_liquido(X) :- parte(X, R), concava(R),
                                     abierta_arriba(R))).
regla(taza, (estable(X) :- parte(X, B), base(B), plana(B))).
regla(familia, (Cabeza :- Cuerpo)) :-
    member(Cabeza, [progenitor(_, _), abuelo(_, _), abuela(_, _)]),
    clause(familia3:Cabeza, Cuerpo).
```

Las reglas son datos, términos `Cabeza :- Cuerpo`, y la última cláusula
de `regla/2` agrega a la teoría `familia` las reglas del
[capítulo 3](../capitulo-03-reglas-y-conjunciones/index.md), leídas con `clause/2` del módulo en el que las carga el
[capítulo 67](../capitulo-67-proyecto-aprender-reglas-ejemplos/index.md). Cada ejemplo se describe con una lista de hechos sin
variables, separada de la teoría: la descripción de `taza1` tiene doce
hechos, entre ellos el color, que ninguna regla menciona. Los predicados
**operacionales** de una teoría son los que se verifican directamente en
la descripción:

<!-- ejemplo: capitulo-68/teorias.pl predicado: operacionales/2 -->
```prolog
% operacionales(T, Ps): Ps son los predicados operacionales de la teoría T.
operacionales(taza, [ peso/2, material/2, color/2, parte/2, asa/1,
                      concava/1, abierta_arriba/1, base/1, plana/1 ]).
operacionales(familia, [varon/1, mujer/1, padre/2, madre/2]).
```

`explicar/4` es un metaintérprete con árbol de prueba, como el de la
[sección 33.4](../capitulo-33-introspeccion-y-metainterpretes/index.md#334-arboles-de-prueba) y con la misma representación: un objetivo predefinido
se ejecuta y queda como `sis(G)`; uno operacional se busca entre los
hechos y queda como `prueba(G, [])`; cualquier otro se prueba con una
regla de la teoría:

<!-- ejemplo: capitulo-68/explicacion.pl predicado: prueba//3 -->
```prolog
%!  prueba(+T, +Hs:list, +G)// is nondet.
%
%   La lista tiene un elemento, la prueba del objetivo G: sis(G) si es
%   predefinido, prueba(G, []) si es operacional y está en Hs, y
%   prueba(G, Hijos) si se prueba con una regla de T.
prueba(T, Hs, G) -->
    (   { predefinido(G) }
    ->  { ejecutar(G) },
        [sis(G)]
    ;   { operacional(T, G) }
    ->  { member(G, Hs) },
        [prueba(G, [])]
    ;   { regla(T, R),
          copy_term(R, (G :- Cuerpo)),
          phrase(pruebas(T, Hs, Cuerpo), Hijos) },
        [prueba(G, Hijos)]
    ).
```

`como/3` escribe el árbol con `mostrar/1` del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md), cargado
en un módulo propio:

```prolog
?- como(taza, taza1, taza(taza1)).
taza(taza1)
  se_levanta(taza1)
    liviano(taza1)
      peso(taza1, 300)
      300<400
    tiene_asa(taza1)
      parte(taza1, asa1)
      asa(asa1)
  contiene_liquido(taza1)
    parte(taza1, cuerpo1)
    concava(cuerpo1)
    abierta_arriba(cuerpo1)
  estable(taza1)
    parte(taza1, base1)
    base(base1)
    plana(base1)
true ;
false.

?- como(taza, vaso1, taza(vaso1)).
false.
```

La explicación **selecciona**: de los doce hechos de `taza1` usa nueve, y
deja afuera el material y los dos colores, que no intervienen en ninguna
regla que la prueba necesite. Un vaso sin asa no tiene explicación. El límite de
esta versión es que la explicación habla de `taza1`, `asa1` y
`cuerpo1`: para reconocer otra taza hay que recorrer la teoría otra vez,
con sus reglas intermedias y sus alternativas.

## Versión 6: generalizar la explicación

La **generalización basada en la explicación**, en la forma de
Kedar-Cabelli y McCarty que siguen Luger y Stubblefield, prueba dos
objetivos a la vez, con las mismas reglas: el del ejemplo, `taza(taza1)`, y una copia
general, `taza(X)`. La prueba del ejemplo elige las reglas y consulta los
hechos; la copia general sigue las mismas reglas sin consultar ningún
hecho, y así recibe solo las ligaduras que imponen las reglas. Cuando la
prueba llega a un objetivo operacional o predefinido, la copia general de
ese objetivo pasa a ser una condición de la regla que se aprende:

<!-- ejemplo: capitulo-68/ebg.pl predicado: generalizar//5 -->
```prolog
%!  generalizar(+T, +Ops:list, +Hs:list, +G, ?GG)// is nondet.
%
%   G se prueba con la teoría T y los hechos Hs, y GG, la copia general
%   de G, sigue las mismas reglas. La lista son las condiciones: las
%   copias generales de los objetivos predefinidos y operacionales en los
%   que la prueba se detiene.
generalizar(T, Ops, Hs, G, GG) -->
    (   { predefinido(G) }
    ->  { ejecutar(G) },
        [GG]
    ;   { functor(G, Nombre, Aridad),
          memberchk(Nombre/Aridad, Ops) }
    ->  { explicar(T, Hs, G, _) },
        [GG]
    ;   { regla(T, R),
          copy_term(R, (G :- Cuerpo)),
          copy_term(R, (GG :- CuerpoG)) },
        generalizar_cuerpo(T, Ops, Hs, Cuerpo, CuerpoG)
    ).
```

Las dos copias de cada regla salen del mismo término `R`, y por eso las
dos pruebas usan la misma regla en cada paso. Las condiciones forman una
lista, como los cuerpos de las cláusulas del [capítulo 67](../capitulo-67-proyecto-aprender-reglas-ejemplos/index.md), y
`mostrar/1` de ese capítulo las escribe como regla de Prolog:

La consulta `mostrar_aprendida(taza, taza1, taza(taza1))` escribe:

```prolog
taza(A) :-
    peso(A, B),
    B<400,
    parte(A, C),
    asa(C),
    parte(A, D),
    concava(D),
    abierta_arriba(D),
    parte(A, E),
    base(E),
    plana(E).
```

La regla no nombra `taza1`, ni sus partes, ni su material: las
constantes del ejemplo quedaron en la prueba particular. La comparación
`B<400` se conserva con la variable general, y el número 400, que viene de
la teoría, se conserva como constante. La regla que se aprende de
`taza2`, la que muestra la [introducción del capítulo](index.md), es otra, porque `taza2` es liviana por su
material: una regla por cada manera de explicar.

El **criterio de operacionalidad** decide hasta dónde se despliega la
prueba. Con `liviano/1` declarado operacional, la generalización se
detiene en él y la regla sirve para las dos tazas:

La consulta `operacionales(taza, Ops), mostrar_aprendida_con(taza, [liviano/1|Ops], taza1, taza(taza1))` escribe:

```prolog
taza(A) :-
    liviano(A),
    parte(A, B),
    asa(B),
    parte(A, C),
    concava(C),
    abierta_arriba(C),
    parte(A, D),
    base(D),
    plana(D).
```

La regla aprendida es el resultado de desplegar la teoría a lo largo de
una prueba, la transformación de la [sección 35.3](../capitulo-35-transformacion-de-programas-y-compilacion/index.md#353-desplegar-y-plegar): se despliega solo lo
que la prueba del ejemplo usó. No afirma nada que la teoría no implique.
En la población de 48 objetos de `poblacion/1`, las dos reglas juntas
reconocen exactamente las mismas tazas que la teoría, y cada una solo las
que se explican como su ejemplo:

```prolog
?- reconocidas_de([taza1], T1), reconocidas_de([taza2], T2), reconocidas_de([taza1, taza2], T).
T1 = [o1, o9],
T2 = [o9, o25, o41],
T = [o1, o9, o25, o41].

?- costos(Teoria, Reglas, Una).
Teoria = 15390,
Reglas = 12756,
Una = 13566.
```

Lo que se gana es costo. Clasificar los 48 objetos con la teoría usa
15 390 inferencias; con las dos reglas, 12 756, un 17 % menos, porque
desaparecen los pasos por `se_levanta/1`, `tiene_asa/1` y las demás reglas
intermedias. La regla con `liviano/1` operacional queda en el medio: es
una sola, pero `liviano/1` se sigue resolviendo con la teoría.

!!! question "Actividad"
    Predecir la regla que se aprende de `abuela(marta, luis)` con la teoría
    `familia`, y en qué se diferencia de la que el
    [capítulo 67](../capitulo-67-proyecto-aprender-reglas-ejemplos/index.md#674-version-3-induccion-ascendente) induce para `abuela/2` de los ejemplos. Comprobarlo con
    `mostrar_aprendida/3` y con `como/3`.

La teoría `familia` permite comparar con el [capítulo 67](../capitulo-67-proyecto-aprender-reglas-ejemplos/index.md). La inducción
necesitó 3 positivos y 46 negativos para proponer una regla de
`abuelo/2`, sin teoría. La generalización por explicación necesita un
positivo, pero solo porque la teoría ya contiene la regla:

La consulta `mostrar_aprendida(familia, familia, abuelo(juan, luis))` escribe:

```prolog
abuelo(A, B) :-
    varon(A),
    padre(A, C),
    padre(C, B).
```

La consulta `mostrar_aprendida_con(familia, [progenitor/2, varon/1], familia, abuelo(juan, luis))` escribe:

```prolog
abuelo(A, B) :-
    varon(A),
    progenitor(A, C),
    progenitor(C, B).
```

Con `padre/2` y `madre/2` como operacionales, la regla es un caso
particular de la del [capítulo 3](../capitulo-03-reglas-y-conjunciones/index.md): la prueba eligió `padre/2` en los dos
eslabones, y la regla no cubre `abuelo(pedro, sofia)`, cuyo segundo
eslabón es una madre. Con `progenitor/2` operacional, la regla es la del
[capítulo 3](../capitulo-03-reglas-y-conjunciones/index.md) sin cambios. Las tres técnicas se ubican así: la inducción
del [capítulo 67](../capitulo-67-proyecto-aprender-reglas-ejemplos/index.md) propone reglas que los datos sugieren y pueden ser falsas;
el espacio de versiones conserva todas las hipótesis de un lenguaje fijo
hasta que los ejemplos las reducen a una; la generalización por
explicación no aprende nada que la teoría no sepa, pero lo deja en una
forma que se usa sin buscar.
