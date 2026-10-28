# Explicar un ejemplo y generalizar la explicación

Esta página continúa el [capítulo 69](index.md) después de la
[sección 69.4](index.md#694-version-4-preguntar-antes-de-converger), con
las secciones [69.5](#695-version-5-explicar-un-ejemplo) y
[69.6](#696-version-6-generalizar-la-explicacion): la teoría del dominio,
la explicación de un solo ejemplo con un metaintérprete con árbol de
prueba, y la generalización de esa explicación en una regla. Los ejemplos
están en `teorias.pl`, `explicacion.pl` y `ebg.pl`, en
`ejemplos/capitulo-69/`, con sus pruebas; cargan archivos de otros
capítulos y se ejecutan localmente.

## 69.5 Versión 5: explicar un ejemplo

La quinta versión cambia de enfoque: un solo ejemplo, con una teoría del
dominio que dice qué hace falta para que un objeto sirva de taza. Las entradas del aprendizaje por explicación, en la formulación de
DeJong y Mooney, son un concepto, un ejemplo, una teoría del dominio y un
criterio de operacionalidad. El dominio de la taza viene de Winston y
sus colegas, a través de Mitchell, Keller y Kedar-Cabelli.
Una **teoría del dominio** es un conjunto de reglas. La de la taza dice
que un objeto sirve de taza si se puede levantar, contiene un líquido y
se apoya firme, y define cada una de esas condiciones:

<!-- ejemplo: capitulo-69/teorias.pl predicado: regla/2 -->
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
[capítulo 68](../capitulo-68-proyecto-aprender-reglas-ejemplos/index.md). Cada ejemplo se describe con una lista de hechos sin
variables, separada de la teoría: la descripción de `taza1` tiene doce
hechos, entre ellos el color, que ninguna regla menciona. Los predicados
**operacionales** de una teoría son los que se verifican directamente en
la descripción:

<!-- ejemplo: capitulo-69/teorias.pl predicado: operacionales/2 -->
```prolog
% operacionales(T, Ps): Ps son los predicados operacionales de la teoría T.
operacionales(taza, [ peso/2, material/2, color/2, parte/2, asa/1,
                      concava/1, abierta_arriba/1, base/1, plana/1 ]).
operacionales(familia, [varon/1, mujer/1, padre/2, madre/2]).
```

`explicar/4` es un metaintérprete con árbol de prueba, como el de la
[sección 34.4](../capitulo-34-introspeccion-y-metainterpretes/index.md#344-arboles-de-prueba) y con la misma representación: un objetivo predefinido
se ejecuta y queda como `sis(G)`; uno operacional se busca entre los
hechos y queda como `prueba(G, [])`; cualquier otro se prueba con una
regla de la teoría:

<!-- ejemplo: capitulo-69/explicacion.pl predicado: prueba//3 -->
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

`como/3` escribe el árbol con `mostrar/1` del [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md), cargado
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

## 69.6 Versión 6: generalizar la explicación

La **generalización basada en la explicación**, en la forma de
Kedar-Cabelli y McCarty que siguen Luger y Stubblefield, prueba dos
objetivos a la vez, con las mismas reglas: el del ejemplo, `taza(taza1)`, y una copia
general, `taza(X)`. La prueba del ejemplo elige las reglas y consulta los
hechos; la copia general sigue las mismas reglas sin consultar ningún
hecho, y así recibe solo las ligaduras que imponen las reglas. Cuando la
prueba llega a un objetivo operacional o predefinido, la copia general de
ese objetivo pasa a ser una condición de la regla que se aprende:

<!-- ejemplo: capitulo-69/ebg.pl predicado: generalizar//5 -->
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
lista, como los cuerpos de las cláusulas del [capítulo 68](../capitulo-68-proyecto-aprender-reglas-ejemplos/index.md), y
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
una prueba, la transformación de la [sección 36.3](../capitulo-36-transformacion-de-programas-y-compilacion/index.md#363-desplegar-y-plegar): se despliega solo lo
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
    [capítulo 68](../capitulo-68-proyecto-aprender-reglas-ejemplos/index.md#684-version-3-induccion-ascendente) induce para `abuela/2` de los ejemplos. Comprobarlo con
    `mostrar_aprendida/3` y con `como/3`.

La teoría `familia` permite comparar con el [capítulo 68](../capitulo-68-proyecto-aprender-reglas-ejemplos/index.md). La inducción
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
del [capítulo 68](../capitulo-68-proyecto-aprender-reglas-ejemplos/index.md) propone reglas que los datos sugieren y pueden ser falsas;
el espacio de versiones conserva todas las hipótesis de un lenguaje fijo
hasta que los ejemplos las reducen a una; la generalización por
explicación no aprende nada que la teoría no sepa, pero lo deja en una
forma que se usa sin buscar.

El capítulo continúa en la página
[Otras generalizaciones e incorporar las reglas](otras-generalizaciones.md#697-version-7-otras-generalizaciones-e-incorporar-las-reglas),
con las operaciones de generalización que las versiones anteriores no usan
y con las reglas aprendidas guardadas en la base.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio.

8. ★ **(1)** Predecir la regla que se aprende de `taza1` con `tiene_asa/1`
   y `estable/1` agregados a los operacionales de la teoría, y cuántas
   condiciones tiene. Comprobarlo con `mostrar_aprendida_con/4`.
9. ★ **(2)** Aprender reglas de `abuelo/2` con la teoría `familia` a
   partir de cada positivo de `ejemplos/3` del [capítulo 68](../capitulo-68-proyecto-aprender-reglas-ejemplos/index.md), quitar
   las que otra subsume con `subsume/2` del mismo capítulo, y contar
   cuántos positivos y cuántos negativos cubren las restantes. Comparar
   con la hipótesis de `aprender_asc/3`.
10. **(2)** Agregar `is/2` a los predefinidos del intérprete, en una copia
    de `explicacion.pl` y `ebg.pl`, y una teoría `pesado` con la regla
    `pesado(X) :- peso(X, P), volumen(X, V), D is P / V, D > 1`. Aprender
    una regla del ejemplo `bloque1`, descrito por su peso y su volumen, y
    explicar qué parte del cálculo queda en ella.
11. **(3)** Aprender una regla de cada una de las cuatro tazas de la
    población, quitar las repetidas con `subsume/2`, y medir las
    inferencias de `reconocidas/3` con 1, 2, 4 y 8 reglas, repitiendo las
    mismas si hace falta. Explicar qué muestra la medición sobre el
    costo de acumular reglas aprendidas.
12. **(2)** Escribir `relevantes(T, E, Meta, Hs)`, los hechos de la
    descripción de E que usa la primera explicación de Meta, e
    `irrelevantes/4`, los que no usa, con los encabezados de PlDoc de los
    dos predicados; elegir sus
    modos y su determinación es parte del ejercicio. Aplicarlo a `taza1`
    y a `abuelo(juan, luis)`.

## Referencias

- George F. Luger y William A. Stubblefield, *AI Algorithms, Data
  Structures, and Idioms in Prolog, Lisp, and Java*, Pearson
  Addison-Wesley, 2009 — capítulo «Machine Learning Algorithms in Prolog»,
  secciones «Machine Learning: Version Space Search» y «Explanation Based
  Learning in Prolog».
  [Edición en línea del autor](https://www.cs.unm.edu/~luger/ai-final2/CH7_Machine%20Learning%20Algorithms%20in%20Prolog.pdf).
  Esta página toma de allí la generalización basada en la explicación
  como prueba simultánea del ejemplo y de su copia general, el corte en
  los nodos operacionales y el dominio de la taza. Las referencias
  siguientes son las que Luger y Stubblefield citan para esas ideas.
- Tom M. Mitchell, Richard M. Keller y Smadar T. Kedar-Cabelli,
  «Explanation-based generalization: a unifying view», *Machine Learning*
  1(1), 1986, págs. 47–80,
  [doi:10.1007/BF00116250](https://doi.org/10.1007/BF00116250), de acceso
  abierto. Formula la generalización basada en la explicación con la
  regresión de la meta, y adapta a ella el dominio de la taza: la
  versión 6.
- Gerald DeJong y Raymond Mooney, «Explanation-based learning: an
  alternative view», *Machine Learning* 1(2), 1986, págs. 145–176,
  [doi:10.1007/BF00114116](https://doi.org/10.1007/BF00114116), de acceso
  abierto. Da las cuatro entradas del aprendizaje por explicación que usa
  la versión 5: el concepto, el ejemplo, la teoría del dominio y el
  criterio de operacionalidad.
- Smadar T. Kedar-Cabelli y L. Thorne McCarty, «Explanation-based
  generalization as resolution theorem proving», en *Proceedings of the
  Fourth International Workshop on Machine Learning*, Morgan Kaufmann,
  1987. Sin edición en línea de acceso libre verificada. Construye la
  prueba del ejemplo y la de su copia general a la vez, en un
  metaintérprete: es la forma de la versión 6.
- Patrick H. Winston, Thomas O. Binford, Boris Katz y Michael Lowry,
  «Learning physical descriptions from functional definitions, examples,
  and precedents», en *Proceedings of the National Conference on
  Artificial Intelligence (AAAI-83)*, 1983, págs. 433–439.
  [Edición en línea de AAAI](https://cdn.aaai.org/AAAI/1983/AAAI83-060.pdf).
  Plantea el problema de la taza: reconocer un objeto por una descripción
  funcional y un ejemplo.
