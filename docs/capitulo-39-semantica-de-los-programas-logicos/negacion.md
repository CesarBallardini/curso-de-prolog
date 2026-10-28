# Estratificación, semántica bien fundada y evaluación de abajo hacia arriba

Esta página continúa el [capítulo 39](index.md) después de la
[sección 39.3](resolucion.md#393-negacion-como-falla-la-complecion-de-clark-y-sldnf),
con las secciones [39.4](#394-estratificacion) a
[39.7](#397-las-reglas-del-sistema-experto): qué significa un programa con negación cuando un predicado depende de su
propia negación. La estratificación excluye esos programas y da a los demás
un modelo estándar; la semántica bien fundada da un significado a todos, con
tres valores de verdad. Las dos últimas secciones calculan el modelo mínimo
de abajo hacia arriba y aplican el verificador de estratos a las reglas del
sistema experto. Los evaluadores están en `semantica.pl`, en
`ejemplos/capitulo-39/`, con sus pruebas, y corren en SWISH; como todos los
del capítulo, tienen una forma terminada en `_de`, que recibe la lista de
cláusulas, y otra que recibe el nombre del programa. Usan `cumple/3` y
`semi_ingenua_de/4`, de las secciones [39.1](index.md#391-modelos-y-consecuencia-logica)
y [39.6](#396-evaluacion-de-abajo-hacia-arriba), y el programa
`circular` de la [sección 39.3](resolucion.md#un-predicado-definido-por-su-propia-negacion).

## 39.4 Estratificación

El problema de `r :- \+ r` es que el predicado se define en términos de su
propio complemento. Krzysztof Apt, Howard Blair y Adrian Walker, y de forma
independiente Allen Van Gelder, propusieron en 1988 escribir los programas
**en capas**: un predicado se usa negado solo cuando ya está completamente
definido en una capa inferior. El **grafo de dependencias** tiene un nodo
por predicado y una arista de p a q cuando una cláusula de p tiene un literal
de q en el cuerpo, marcada como negativa si el literal está negado:

<!-- ejemplo: capitulo-39/semantica.pl predicado: dependencias_de/2 dependencia/3 -->
```prolog
%!  dependencias_de(+Clausulas:list, -Aristas:list) is det.
%
%   Aristas son los términos P-Q-Signo, ordenados y sin repetir: una
%   cláusula de P tiene en el cuerpo un literal de Q, positivo (Signo es
%   pos) o negado (neg). Las comparaciones no cuentan.
dependencias_de(Clausulas, Aristas) :-
    findall(P-Q-Signo,
            ( member(Cabeza :- Cuerpo, Clausulas),
              indicador(Cabeza, P),
              conjuncion_lista(Cuerpo, Literales),
              member(Literal, Literales),
              dependencia(Literal, Q, Signo) ),
            Todas),
    sort(Todas, Aristas).

%!  dependencia(+Literal, -Q, -Signo) is semidet.
%
%   Literal es un literal de Q, con el Signo pos o neg. Falla con una
%   comparación.
dependencia(\+ A, Q, neg) :-
    indicador(A, Q).
dependencia(A, Q, pos) :-
    atomo(A),
    indicador(A, Q).
```

El programa `grafo` agrega a `caminos` los nodos y la relación
`inalcanzable/2`:

<!-- ejemplo: capitulo-39/semantica.pl predicado: inalcanzable/2 -->
```prolog
%!  inalcanzable(?X, ?Y) is nondet.
%
%   X e Y son nodos, y no hay un camino de X a Y.
inalcanzable(X, Y) :-
    nodo(X),
    nodo(Y),
    \+ camino(X, Y).
```

```prolog
?- dependencias(grafo, A).
A = [camino/2-arco/2-pos, camino/2-camino/2-pos, inalcanzable/2-camino/2-neg, inalcanzable/2-nodo/1-pos].
```

Un programa es **estratificado** si a cada predicado se le puede asignar un
número, su **estrato**, de modo que para cada arista de p a q:

$$\mathit{estrato}(p) \ge \mathit{estrato}(q) \;\text{si es positiva}, \qquad \mathit{estrato}(p) > \mathit{estrato}(q) \;\text{si es negativa}$$

Equivalentemente, si ningún ciclo del grafo pasa por una arista negativa.
`estratos_de/2` parte de 0 para todos los predicados y sube, en rondas, los que
violan alguna desigualdad. Si el programa es estratificado, las rondas
terminan con el menor estrato de cada uno; si no, algún estrato crece sin
límite, y llegar a la cantidad de predicados alcanza para saberlo:

<!-- ejemplo: capitulo-39/semantica.pl predicado: estratos_de/2 niveles/2 subir/4 elevar/4 -->
```prolog
%!  estratos_de(+Clausulas:list, -Estratos:list) is semidet.
%
%   Estratos son los pares N-Predicados, de N = 0 en adelante: los
%   predicados de Clausulas agrupados por estrato. El estrato de un
%   predicado es el menor número que no es menor que el de ninguno de los
%   que usa en positivo, y es mayor que el de cada uno que usa negado.
%   Falla si el programa no es estratificado.
estratos_de(Clausulas, Estratos) :-
    niveles(Clausulas, Niveles),
    findall(N-P, member(P-N, Niveles), Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Estratos).

%!  niveles(+Clausulas:list, -Niveles:list) is semidet.
%
%   Niveles son los pares Predicado-N, con el estrato N de cada predicado.
%   Parte de 0 para todos y sube lo que haga falta, en rondas; si un
%   estrato llega a la cantidad de predicados, hay un ciclo con una
%   negación, y falla.
niveles(Clausulas, Niveles) :-
    dependencias_de(Clausulas, Aristas),
    findall(P, ( member(Cabeza :- _, Clausulas), indicador(Cabeza, P)
               ; member(_-P-_, Aristas) ),
            Ps0),
    sort(Ps0, Ps),
    findall(P-0, member(P, Ps), N0),
    length(Ps, Tope),
    subir(Aristas, Tope, N0, Niveles).

%!  subir(+Aristas:list, +Tope:integer, +N0:list, -N:list) is semidet.
%
%   N son los niveles que resultan de subir los de N0 hasta que ninguna
%   arista los cambie. Falla si alguno llega a Tope.
subir(Aristas, Tope, N0, N) :-
    maplist(elevar(Aristas, N0), N0, N1),
    (   N1 == N0
    ->  N = N0
    ;   member(_-K, N1), K >= Tope
    ->  fail
    ;   subir(Aristas, Tope, N1, N)
    ).

%!  elevar(+Aristas:list, +Niveles:list, +P0, -P) is det.
%
%   P es el par Predicado-K de P0 con el nivel K que exigen sus aristas:
%   al menos el de cada predicado que usa, y uno más si lo usa negado.
elevar(Aristas, Niveles, P-K0, P-K) :-
    findall(K1,
            ( member(P-Q-Signo, Aristas),
              memberchk(Q-KQ, Niveles),
              exigido(Signo, KQ, K1) ),
            Ks),
    max_list([K0|Ks], K).
```

```prolog
?- estratos(grafo, E).
E = [0-[arco/2, camino/2, nodo/1], 1-[inalcanzable/2]].

?- estratos(juego, E).
false.
```

`false.` dice que no hay estratos, pero no dónde está el problema.
`ciclos_negativos/2` lo localiza: da cada arista negativa de p a q tal que q
depende, directa o indirectamente, de p:

<!-- ejemplo: capitulo-39/semantica.pl predicado: ciclos_negativos_de/2 alcanza/3 -->
```prolog
%!  ciclos_negativos_de(+Clausulas:list, -Pares:list) is det.
%
%   Pares son los P-Q, ordenados, tales que P usa negado a Q y Q depende, de
%   forma directa o indirecta, de P: cada par cierra un ciclo que pasa por
%   una negación. Pares es vacía si y solo si el programa es estratificado.
ciclos_negativos_de(Clausulas, Pares) :-
    dependencias_de(Clausulas, Aristas),
    findall(P-Q,
            ( member(P-Q-neg, Aristas),
              alcanza(Aristas, Q, P) ),
            Todos),
    sort(Todos, Pares).

%!  alcanza(+Aristas:list, +Desde, +Hasta) is semidet.
%
%   Hay una sucesión de aristas, quizás vacía, de Desde a Hasta.
alcanza(Aristas, Desde, Hasta) :-
    alcanza(Aristas, [Desde], [], Hasta).
```

```prolog
?- ciclos_negativos(circular, P).
P = [p/0-q/0, q/0-p/0, r/0-r/0].
```

`s/0`, que usa negado a `t/0`, no aparece: `t/0` no depende de nadie. Que un
programa sea estratificado es decidible, y rápido de verificar; que su
compleción sea consistente, no (Nilsson y Małuszyński, apartado 4.4). Apt,
Blair y Walker demostraron que la compleción de un programa estratificado
es siempre consistente, y que el programa tiene un modelo mínimo
privilegiado, el **modelo estándar**: se calcula estrato por estrato, cada
uno hasta su punto fijo a partir del modelo de los anteriores, y el
resultado no depende de cómo se elijan los estratos. Spivey describe esa
construcción capa por capa (*An Introduction to Logic Programming through
Prolog*, apartado 8.3, «Semantics of negation»). Cuando se evalúa un
estrato, los predicados negados ya tienen su extensión definitiva, y `\+ A`
significa exactamente que A no está en ella:

<!-- ejemplo: capitulo-39/semantica.pl predicado: modelo_estandar_de/2 evaluar_estrato/4 -->
```prolog
%!  modelo_estandar_de(+Clausulas:list, -M:list) is semidet.
%
%   M es el modelo estándar de Clausulas, un programa estratificado: cada
%   estrato, del 0 en adelante, se evalúa con semi_ingenua_de/4 a partir del
%   modelo de los anteriores. Falla si el programa no es estratificado.
modelo_estandar_de(Clausulas, M) :-
    estratos_de(Clausulas, Estratos),
    foldl(evaluar_estrato(Clausulas), Estratos, [], M).

%!  evaluar_estrato(+Clausulas:list, +Estrato, +I0:list, -I:list) is det.
%
%   I agrega a I0 las consecuencias de las cláusulas de los predicados del
%   Estrato, N-Predicados, hasta el punto fijo.
evaluar_estrato(Clausulas, _-Predicados, I0, I) :-
    include(define_alguno(Predicados), Clausulas, DelEstrato),
    semi_ingenua_de(DelEstrato, I0, I, _).
```

```prolog
?- findall(X-Y, (modelo_estandar(grafo, M), member(inalcanzable(X, Y), M)), Ps).
Ps = [d-a, d-b, d-c, d-d].

?- modelo_estandar(circular, M).
false.
```

Desde `d` no sale ningún arco, y cada uno de los otros tres nodos alcanza a
todos, incluido él mismo. Evaluar sin respetar los estratos da otra cosa:
`modelo_minimo/2` sobre `circular` responde `M = [p, q, r, s]`, una
interpretación en la que p y q son verdaderos aunque la única cláusula de
cada uno exige que el otro sea falso (ejercicio 7).

## 39.5 La semántica bien fundada

Un programa que no es estratificado puede tener un significado claro. El
programa `juego` describe dos juegos: en cada turno, el jugador que mueve
pasa de una posición a otra, y el que no puede mover pierde. Una posición
es ganadora si hay un movimiento a una posición que no es ganadora para el
rival. Es el ejemplo de Nilsson y Małuszyński (apartado 4.7):

<!-- ejemplo: capitulo-39/semantica.pl predicado: mueve/3 gana/2 -->
```prolog
% mueve(Juego, X, Y): en Juego, un jugador puede pasar de la posición X a
% la posición Y.
mueve(j1, a, b).
mueve(j1, b, a).
mueve(j1, b, c).
mueve(j2, a, b).
mueve(j2, b, a).
mueve(j2, b, c).
mueve(j2, c, d).

%!  gana(?Juego, ?X) is nondet.
%
%   En Juego, quien mueve desde X gana: puede pasar a una posición desde
%   la que el rival no gana. Con los ciclos de los dos juegos, Prolog no
%   termina.
gana(J, X) :-
    mueve(J, X, Y),
    \+ gana(J, Y).
```

`gana/2` depende de su propia negación, y el programa no es estratificado.
Aun así, en el juego j1 el razonamiento es directo: desde c no hay
movimientos, así que c pierde; desde b se puede ir a c, así que b gana; desde
a solo se puede ir a b, que gana para el rival, así que a pierde. En el juego
j2, c gana porque puede ir a d, que pierde; pero desde a y desde b los dos
jugadores pueden pasarse la posición sin fin: el juego no termina, y ni «gana»
ni «no gana» es la respuesta correcta.

La **semántica bien fundada**, de Allen Van Gelder, Kenneth Ross y John
Schlipf (1991), asigna a cada átomo uno de **tres valores**: verdadero,
falso o **indefinido**. Un átomo es falso si no tiene ninguna forma de
probarse que no dependa de él mismo, y verdadero si se prueba con lo ya
sabido; lo que queda es indefinido. Nilsson y Małuszyński la construyen con
los conjuntos infundados; `bien_fundado_de/3` la calcula con el **punto fijo
alternado** de Van Gelder, que usa solo modelos mínimos. `reducido/3` es el
modelo mínimo del programa con las negaciones fijas: `\+ A` es verdadero si
A no está en un conjunto J dado, y no cambia mientras el modelo crece.

<!-- ejemplo: capitulo-39/semantica.pl predicado: reducido/3 bien_fundado_de/3 alternar/4 -->
```prolog
%!  reducido(+Clausulas:list, +J:list, -M:list) is det.
%
%   M es el modelo mínimo de Clausulas con las negaciones fijas: \+ A es
%   verdadero si A no está en J, y no cambia mientras M crece.
reducido(Clausulas, J, M) :-
    reducido(Clausulas, J, [], M).

%!  bien_fundado_de(+Clausulas:list, -Verdaderos:list, -Indefinidos:list)
%!      is det.
%
%   El modelo bien fundado de Clausulas: Verdaderos son los átomos
%   verdaderos, e Indefinidos los que no son verdaderos ni falsos; todos
%   los demás son falsos. Alterna dos cálculos con reducido/3: lo que es
%   posible si es falso todo lo que todavía no es verdadero, y lo que es
%   verdadero si es falso todo lo que no es posible, hasta que no cambian.
bien_fundado_de(Clausulas, Verdaderos, Indefinidos) :-
    alternar(Clausulas, [], Verdaderos, Posibles),
    ord_subtract(Posibles, Verdaderos, Indefinidos).

%!  alternar(+Clausulas:list, +V0:list, -V:list, -P:list) is det.
%
%   V son los átomos verdaderos y P los posibles, calculados desde los
%   verdaderos V0.
alternar(Clausulas, V0, V, P) :-
    reducido(Clausulas, V0, P0),
    reducido(Clausulas, P0, V1),
    (   V1 == V0
    ->  V = V0,
        P = P0
    ;   alternar(Clausulas, V1, V, P)
    ).
```

La alternancia empieza sin átomos verdaderos, $V_0 = \varnothing$. Si todo
lo que no es verdadero se toma por falso, las negaciones se cumplen de más, y
el modelo reducido da todo lo **posible**: $P_i = \Gamma(V_i)$. Si solo lo
imposible se toma por falso, las negaciones se cumplen de menos, y el
modelo reducido da lo que es **seguro**: $V_{i+1} = \Gamma(P_i)$. Los $V_i$
crecen y los $P_i$ decrecen, y cuando $V_{i+1} = V_i$ el modelo bien fundado
tiene los verdaderos en $V_i$, los indefinidos en $P_i \setminus V_i$ y los
falsos fuera de $P_i$:

```prolog
?- bien_fundado(juego, V, I).
V = [gana(j1, b), gana(j2, c), mueve(j1, a, b), mueve(j1, b, a), mueve(j1, b, c), mueve(j2, a, b), mueve(j2, b, a), mueve(j2, b, c), mueve(..., ..., ...)],
I = [gana(j2, a), gana(j2, b)].

?- bien_fundado(circular, V, I).
V = [s],
I = [p, q, r].
```

El modelo de j1 es **total**: no tiene indefinidos, y dice lo mismo que el
razonamiento de arriba. En j2, a y b quedan indefinidos: son posiciones de
empate. En `circular`, s es verdadero porque t no tiene cláusulas, y p, q y
r quedan indefinidos: la semántica no elige entre los dos modelos de p y q,
y no fuerza un valor para r. `valor/3` da el valor de un átomo:

<!-- ejemplo: capitulo-39/semantica.pl predicado: valor_de/3 -->
```prolog
%!  valor_de(+Clausulas:list, +Atomo, -Valor) is det.
%
%   Valor es verdadero, falso o indefinido: el de Atomo, sin variables, en
%   el modelo bien fundado de Clausulas.
valor_de(Clausulas, Atomo, Valor) :-
    must_be(ground, Atomo),
    bien_fundado_de(Clausulas, Verdaderos, Indefinidos),
    (   ord_memberchk(Atomo, Verdaderos)
    ->  Valor = verdadero
    ;   ord_memberchk(Atomo, Indefinidos)
    ->  Valor = indefinido
    ;   Valor = falso
    ).
```

```prolog
?- valor(juego, gana(j2, b), V).
V = indefinido.
```

Dos teoremas sitúan la semántica respecto de las anteriores (Nilsson y
Małuszyński, teoremas 4.28 y 4.29): el modelo bien fundado de un programa
definido es total y es su modelo mínimo, y el de un programa estratificado
es total y es su modelo estándar. La prueba `bien_fundado_estratificado` de
`semantica.plt` lo comprueba con `grafo`. Otra semántica, la de los
**modelos estables** de Michael Gelfond y Vladimir Lifschitz (1988), asigna
a `p :- \+ q` y `q :- \+ p` dos modelos, en lugar de un tercer valor
(ejercicio 12).

La tabulación de SWI-Prolog calcula la semántica bien fundada: con
`gana/2` tabulado y `tnot/1` en lugar de `\+`, `gana(j2, a)` no agota la
pila, sino que responde con el **programa residual** que lo deja
indefinido, en el que `gana(j2, a)` y `gana(j2, b)` dependen cada uno de la
negación del otro. El [capítulo 40](../capitulo-40-tabulacion/index.md) lo presenta.

!!! question "Actividad"
    Agregar al juego j2 el movimiento `mueve(j2, a, e)`, sin movimientos
    desde e. Predecir el valor de `gana(j2, a)` y de `gana(j2, b)` antes de
    calcularlo con `bien_fundado/3`, y explicar por qué el empate
    desaparece.

## 39.6 Evaluación de abajo hacia arriba

El **operador de consecuencia inmediata** $T_P$ lleva una interpretación a
los átomos que el programa concluye en un paso a partir de ella:

$$T_P(I) = \{\, A \mid A \leftarrow B_1, \dots, B_n \text{ es una instancia sin variables de una cláusula de } P, \; B_1, \dots, B_n \in I \,\}$$

Maarten van Emden y Robert Kowalski demostraron en 1976 que el modelo mínimo
es el menor punto fijo de $T_P$, y que se alcanza aplicándolo desde la
interpretación vacía: $M_P = \bigcup_{k \ge 0} T_P^k(\varnothing)$
(Nilsson y Małuszyński, apartado 2.4; Hein, *Prolog Experiments*, apartado
10.1). Los hechos entran en el primer paso, lo que se deduce de ellos en el
segundo, y así sucesivamente. `consecuencias_de/3` es $T_P$:

<!-- ejemplo: capitulo-39/semantica.pl predicado: consecuencias_de/3 derivar/4 -->
```prolog
%!  consecuencias_de(+Clausulas:list, +I:list, -T:list) is det.
%
%   T es T_P(I), el conjunto ordenado de las consecuencias inmediatas de I:
%   las cabezas de las cláusulas cuyo cuerpo es verdadero en I.
consecuencias_de(Clausulas, I, T) :-
    derivar(Clausulas, I, I, Cabezas),
    sort(Cabezas, T).

%!  derivar(+Clausulas:list, +I:list, +J:list, -Cabezas:list) is det.
%
%   Cabezas son las cabezas de las cláusulas cuyo cuerpo es verdadero con
%   I y J (cumple/3), una por cada forma de hacerlo verdadero, con
%   repeticiones. Error de instanciación si una cabeza queda con variables.
derivar(Clausulas, I, J, Cabezas) :-
    findall(Cabeza,
            ( member(Cabeza :- Cuerpo, Clausulas),
              cumple(Cuerpo, I, J),
              must_be(ground, Cabeza) ),
            Cabezas).
```

```prolog
?- consecuencias(lluvia, [], T1), consecuencias(lluvia, T1, T2), consecuencias(lluvia, T2, T3).
T1 = [llueve],
T2 = T3, T3 = [calle_mojada, llueve].
```

`T2 = T3` es el punto fijo. La **evaluación ingenua** repite ese paso hasta
que la interpretación no cambia; `ingenua_de/4` agrega cada vez $T_P(I)$ a I,
lo que da lo mismo para un programa definido y permite empezar desde una
interpretación dada, como hace `modelo_estandar_de/2` con cada estrato. Cuenta
las aplicaciones de $T_P$ y las **derivaciones**, cada cabeza obtenida de una
instancia de una cláusula:

<!-- ejemplo: capitulo-39/semantica.pl predicado: ingenua_de/4 -->
```prolog
%!  ingenua_de(+Clausulas:list, +I0:list, -M:list, -Costo) is det.
%
%   Evaluación ingenua: M es el primer I que no cambia en la sucesión que
%   empieza en I0 y agrega en cada paso T_P(I). Costo es costo(Pasos,
%   Derivaciones): cuántas veces se aplicó T_P, y cuántas cabezas derivaron
%   todas esas aplicaciones, contando las repetidas.
ingenua_de(Clausulas, I0, M, Costo) :-
    ingenua_de(Clausulas, I0, M, costo(0, 0), Costo).
```

La evaluación de abajo hacia arriba termina siempre en un programa sin
functores, como los del capítulo, porque la base de Herbrand es finita: es
lo que se llama **Datalog**. La recursión a la izquierda y los ciclos de
`caminos`, que impiden terminar a Prolog, no le afectan. Su defecto es otro:
cada paso vuelve a derivar todo lo que ya derivaron los anteriores. En el
paso k, `camino(X, Y) :- camino(X, Z), arco(Z, Y)` recombina todos los
caminos conocidos, aunque solo los del paso k − 1 puedan dar algo nuevo.

La **evaluación semi-ingenua** evita esa repetición: después del primer
paso, una cláusula se usa solo con al menos un átomo del cuerpo tomado de
los **nuevos** del paso anterior, y los demás del conjunto completo
(Nilsson y Małuszyński, apartado 15.2):

<!-- ejemplo: capitulo-39/semantica.pl predicado: semi_ingenua_de/4 derivar_con_nuevos/4 -->
```prolog
%!  semi_ingenua_de(+Clausulas:list, +I0:list, -M:list, -Costo) is det.
%
%   Evaluación semi-ingenua: el mismo M que ingenua_de/4. Después del primer
%   paso, cada cláusula se evalúa solo con al menos un átomo del cuerpo
%   tomado de los nuevos del paso anterior. Costo, como en ingenua_de/4.
semi_ingenua_de(Clausulas, I0, M, Costo) :-
    derivar(Clausulas, I0, I0, Cabezas),
    length(Cabezas, D),
    sort(Cabezas, T),
    ord_subtract(T, I0, Nuevos),
    ord_union(I0, Nuevos, I1),
    semi_ingenua_de(Clausulas, I1, Nuevos, M, costo(1, D), Costo).

%!  derivar_con_nuevos(+Clausulas:list, +I:list, +Nuevos:list,
%!                     -Cabezas:list) is det.
%
%   Cabezas son las de derivar/4 con I, restringidas a las derivaciones que
%   toman de Nuevos el átomo de alguna posición del cuerpo; los demás
%   literales se evalúan con I. Una derivación que usa dos átomos nuevos
%   aparece dos veces.
derivar_con_nuevos(Clausulas, I, Nuevos, Cabezas) :-
    findall(Cabeza,
            ( member(Cabeza :- Cuerpo, Clausulas),
              conjuncion_lista(Cuerpo, Literales),
              append(Antes, [Literal|Despues], Literales),
              atomo(Literal),
              member(Literal, Nuevos),
              cumple_todos(Antes, I),
              cumple_todos(Despues, I),
              must_be(ground, Cabeza) ),
            Cabezas).
```

```prolog
?- ingenua(caminos, [], _, C1), semi_ingenua(caminos, [], _, C2).
C1 = costo(5, 60),
C2 = costo(5, 20).
```

Los dos métodos dan el mismo modelo en los mismos cinco pasos; el
semi-ingenuo hace un tercio de las derivaciones. La diferencia crece con el
programa. `cadena(N, Cs)` arma las cláusulas de `camino/2` sobre N arcos en
fila, de 0 a N, y `generado/2` las registra como el programa `cadena(N)`:
`clausulas/2` busca en él los nombres que no están en `programa/2`, y otros
archivos le agregan programas, porque está declarado `multifile`, como
`prolog:message//1` en la [sección 26.7](../capitulo-26-errores-y-excepciones/index.md#267-mensajes-para-el-usuario):

<!-- ejemplo: capitulo-39/semantica.pl predicado: generado/2 -->
```prolog
%!  generado(+Programa, -Clausulas:list) is semidet.
%
%   Clausulas son las del programa Programa, construido como datos: aquí,
%   cadena(N), el de cadena/2. Falla con otro nombre.
generado(cadena(N), Clausulas) :-
    cadena(N, Clausulas).
```

```text
?- time(ingenua(cadena(40), [], _, C)).
% 15,935,580 inferences, 1.609 CPU in 1.612 seconds (100% CPU, 9901720 Lips)
C = costo(42, 24640).

?- time(semi_ingenua(cadena(40), [], _, C)).
% 483,874 inferences, 0.047 CPU in 0.048 seconds (97% CPU, 10322645 Lips)
C = costo(42, 860).
```

El modelo tiene 860 átomos, 40 arcos y 820 caminos, y la evaluación
semi-ingenua deriva cada uno exactamente una vez: cada camino de i a j se
obtiene solo del camino de i a j − 1 y del arco de j − 1 a j. La ingenua
hace casi treinta veces más derivaciones, y tarda más de treinta veces
más.

Queda un defecto en los dos métodos: calculan el modelo entero, aunque la
consulta pregunte solo por los caminos que salen de un nodo. La
**transformación mágica** (Nilsson y Małuszyński, apartado 15.3) reescribe el
programa para que la evaluación de abajo hacia arriba derive solo lo que la
consulta necesita. La tabulación del [capítulo 40](../capitulo-40-tabulacion/index.md) llega al mismo
lugar desde el otro lado: parte de la consulta, como Prolog, y guarda las
respuestas de cada subobjetivo en una tabla que completa hasta el punto
fijo. Y la cláusula `WITH RECURSIVE` de SQL, del
[capítulo 43](../capitulo-43-prolog-y-sql/index.md), es una evaluación semi-ingenua: cada iteración une
la tabla con las filas nuevas de la iteración anterior. Flach escribe en
Prolog un evaluador de abajo hacia arriba para cláusulas generales, que
construye modelos (*Simply Logical*, apartado 5.4).

!!! question "Actividad"
    Predecir `costo(Pasos, Derivaciones)` de las dos evaluaciones con
    el programa `cadena(10)`, y comprobarlo. ¿Cuántos pasos da cada una, y
    por qué las derivaciones de la semi-ingenua son tantas como los átomos
    del modelo?

## 39.7 Las reglas del sistema experto

Las reglas del sistema experto del [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md#347-el-sistema-experto-explica) son términos
`si Condiciones entonces Conclusion`, y su [ejercicio 13](../capitulo-34-introspeccion-y-metainterpretes/soluciones.md#13) les agregó la
negación `no`: r11 concluye `pinguino` de `ave y no vuela y nada`, y r12
`avestruz` de `ave y no vuela y peso(P) y P > 50`. `experto.pl` tiene esas
reglas y las convierte en cláusulas de Prolog, con `,` en lugar de `y` y
`\+` en lugar de `no`, para que los evaluadores de `semantica.pl`, que carga
con `ensure_loaded/1`, las examinen como a cualquier programa:

<!-- ejemplo: capitulo-39/experto.pl predicado: base/2 regla_clausula/2 condiciones_cuerpo/2 -->
```prolog
%!  base(+Version:atom, -Clausulas:list) is det.
%
%   Clausulas son las reglas de la base, más las que agrega Version
%   (original, vuela o puede_volar), como cláusulas Conclusion :- Cuerpo.
base(Version, Clausulas) :-
    must_be(oneof([original, vuela, puede_volar]), Version),
    findall(R, regla(_, R), Reglas),
    findall(R, agregada(Version, _, R), Agregadas),
    append(Reglas, Agregadas, Todas),
    maplist(regla_clausula, Todas, Clausulas).

%!  regla_clausula(+Regla, -Clausula) is det.
%
%   Clausula es Regla, si Condiciones entonces Conclusion, escrita como la
%   cláusula Conclusion :- Cuerpo.
regla_clausula(si Condiciones entonces Conclusion, Conclusion :- Cuerpo) :-
    condiciones_cuerpo(Condiciones, Cuerpo).

%!  condiciones_cuerpo(+Condiciones, -Cuerpo) is det.
%
%   Cuerpo es Condiciones con , en lugar de y, y \+ en lugar de no.
condiciones_cuerpo(Condiciones, Cuerpo) :-
    (   Condiciones = (A y B)
    ->  Cuerpo = (CuerpoA, CuerpoB),
        condiciones_cuerpo(A, CuerpoA),
        condiciones_cuerpo(B, CuerpoB)
    ;   Condiciones = (no A)
    ->  Cuerpo = (\+ A)
    ;   Cuerpo = Condiciones
    ).
```

El programa de cada versión se llama `base(Version)`: `experto.pl` lo agrega
a `generado/2`, y los evaluadores lo reciben por ese nombre:

```prolog
?- regla(r12, R), regla_clausula(R, C).
R = (si ave y no vuela y peso(_A)y _A>50 entonces avestruz),
C = (avestruz:-ave, \+vuela, peso(_A), _A>50).

?- estratos(base(original), [_|Superiores]).
Superiores = [1-[avestruz/0, pinguino/0]].
```

La base es estratificada: `vuela` es una observación, sin reglas, y
`pinguino` y `avestruz`, que la usan negada, quedan en el estrato 1; todos
los demás predicados están en el 0. El significado de la base es claro, y el
intérprete del [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md) lo calcula.

Una regla natural de agregar es la de las aves que vuelan: «un ave que no es
pingüino ni avestruz vuela». Flach analiza una regla de este tipo, con sus
excepciones, como razonamiento por defecto (*Simply Logical*, apartados 8.1
y 8.2). La versión `vuela` de la base agrega r13, `si ave y no pinguino y no
avestruz entonces vuela`:

```prolog
?- estratos(base(vuela), E).
false.

?- ciclos_negativos(base(vuela), P).
P = [avestruz/0-vuela/0, pinguino/0-vuela/0, vuela/0-avestruz/0, vuela/0-pinguino/0].
```

r13 crea dos clases de ciclos. Con r4, `si vuela y pone_huevos entonces
ave`, crea uno **positivo**, `ave` → `vuela` → `ave`, que no afecta al
significado: la evaluación de abajo hacia arriba lo recorre sin problema,
aunque el intérprete del [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md), que resuelve de arriba hacia
abajo, entra en él y agota la pila con cualquier caso, también el del
guepardo. Con r11 y r12 crea dos ciclos **negativos**: `pinguino` depende de
no `vuela`, y `vuela` de no `pinguino`. Esos no los resuelve ninguna
evaluación. `diagnostico/3` agrega las observaciones como hechos, con el
programa `con_hechos(base(Version), Observaciones)` que `generado/2` define
en `experto.pl`, y calcula el modelo bien fundado:

<!-- ejemplo: capitulo-39/experto.pl predicado: generado/2 diagnostico/3 -->
```prolog
%!  generado(+Programa, -Clausulas:list) is semidet.
%
%   Los programas de este archivo: base(Version), las cláusulas de base/2,
%   y con_hechos(Programa, Hechos), las del programa Programa más un hecho
%   por cada uno de Hechos.
generado(base(Version), Clausulas) :-
    base(Version, Clausulas).
generado(con_hechos(Programa, Hechos), Clausulas) :-
    clausulas(Programa, Reglas),
    findall(H :- true, member(H, Hechos), Nuevas),
    append(Reglas, Nuevas, Clausulas).

%!  diagnostico(+Version:atom, +Observaciones:list, -Resultado) is det.
%
%   Resultado es resultado(Verdaderas, Indefinidas): las hipótesis
%   verdaderas y las indefinidas en el modelo bien fundado de la base de
%   Version con Observaciones como hechos.
diagnostico(Version, Observaciones, resultado(Verdaderas, Indefinidas)) :-
    bien_fundado(con_hechos(base(Version), Observaciones), V, I),
    findall(H, ( hipotesis(H), ord_memberchk(H, V) ), Verdaderas),
    findall(H, ( hipotesis(H), ord_memberchk(H, I) ), Indefinidas).
```

```prolog
?- diagnostico(original, [tiene_plumas, nada, peso(30)], R).
R = resultado([pinguino], []).

?- diagnostico(vuela, [tiene_plumas, nada, peso(30)], R).
R = resultado([], [pinguino]).

?- diagnostico(vuela, [tiene_plumas, peso(90)], R).
R = resultado([], [avestruz]).
```

Con la base original, un ave que nada y pesa 30 es un pingüino. Con r13, el
mismo caso queda indefinido: el ave es un pingüino que no vuela, o un ave que
vuela y no es pingüino, y las reglas no deciden entre las dos lecturas. Una
base de reglas con negación a través de la recursión no tiene un
significado claro: el sistema no da una respuesta falsa, pero tampoco una
respuesta.

La corrección es romper el ciclo: que r13 concluya algo que r11 y r12 no
usan. La versión `puede_volar` concluye `puede_volar`, y deja `vuela` como
observación:

```prolog
?- estratos(base(puede_volar), [_|Superiores]).
Superiores = [1-[avestruz/0, pinguino/0], 2-[puede_volar/0]].

?- diagnostico(puede_volar, [tiene_plumas, nada, peso(30)], R).
R = resultado([pinguino], []).
```

La base vuelve a ser estratificada, con un estrato más, y cada caso tiene
una respuesta. La verificación es estática: `estratos/2` y
`ciclos_negativos/2` leen las reglas, no las ejecutan, y se pueden aplicar a
cada versión de la base antes de usarla. El [capítulo 40](../capitulo-40-tabulacion/index.md) lleva el
intérprete a la tabulación, donde el ciclo positivo de r4 y r13 termina, y
el [capítulo 66](../capitulo-66-proyecto-razonamiento-rebatible/index.md) trata las reglas con excepciones como razonamiento
rebatible.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada evaluador declara modos y determinación: `estratos/2` y `modelo_estandar/2` son `semidet` y fallan solo si el programa no es estratificado; `bien_fundado/3`, `ingenua/4`, `semi_ingenua/4` y `arbol_sld/5` son `det`, y sus pruebas no declaran `nondet` |
    | C2, C5 | `clausulas/2` produce un error de instanciación con el programa libre y uno de existencia con un nombre desconocido, también con una lista de cláusulas pasada en lugar de un nombre; `cumple/3` produce un error de instanciación con una negación que tiene variables, y `derivar/4` con una cabeza que el cuerpo no liga: un programa que no es Datalog permitido no da un modelo incorrecto sin aviso |
    | C6 | los evaluadores `_de` son puros: reciben las cláusulas como una lista y devuelven conjuntos ordenados; las formas que reciben el nombre solo agregan `clausulas/2`, y el único contacto con el programa es `clause/2`, dentro de ella |
    | C7 | 103 pruebas en tres archivos, que prueban cada evaluador por su nombre y con una lista; cada evaluador se compara con otro que calcula lo mismo por otro camino: `ingenua/4` con `semi_ingenua/4`, `modelo_estandar/2` con `modelo_minimo/2` en un programa definido, y `bien_fundado/3` con `modelo_estandar/2` en uno estratificado |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

7. ★ **(2)** `modelo_minimo/2` sobre `circular` responde `M = [p, q, r,
   s]`. Verificar con `es_modelo/2` si esa interpretación es un modelo,
   buscar uno menor, y explicar por qué la sucesión de $T_P$ deja de crecer
   de manera ordenada cuando el programa tiene negación.
8. ★ **(2)** Escribir la compleción de `gana/2` y de `mueve/3`, del
   programa `juego`, y compararla con la de `complecion/3`. Explicar por
   qué la compleción de `gana/2` no decide `gana(j2, a)`, y por qué la de
   `r/0` no tiene ningún modelo.
9. ★ **(2)** Determinar a mano si cada programa es estratificado y, si lo
   es, sus estratos; comprobarlo con `estratos_de/2` y
   `ciclos_negativos_de/2`, que reciben la lista de cláusulas:
   (a) `a :- \+ b.` `b :- c.` `c :- \+ d.` (b) `a :- b, \+ c.`
   `c :- \+ a.` (c) `a :- \+ b.` `b :- a.`
10. **(2)** El programa `par(N) :- sigue(M, N), \+ par(M).` con los hechos
    `sigue(0, 1)`, `sigue(1, 2)`, …, `sigue(5, 6)` y `par(0)` no es
    estratificado. Calcular su modelo bien fundado, y explicar por qué es
    total aunque `par/1` dependa de su propia negación.
11. **(2)** Escribir `alternancia_de(Clausulas, Pasos)`, que da la sucesión
    de pares $V_i$-$P_i$ del punto fijo alternado, y `alternancia/2`, que
    recibe el nombre del programa, y seguirla con el juego j2:
    en qué paso se sabe que c gana, y en cuál que d pierde.
12. **(3)** Un modelo M es **estable** si M es igual al modelo reducido del
    programa con las negaciones evaluadas contra M, `reducido(Cs, M, M)`.
    Escribir `estables_de(Clausulas, Modelos)`, que prueba como candidatos
    los subconjuntos de lo posible, `reducido(Cs, [], P)`, y `estables/2`,
    que recibe el nombre del programa. ¿Cuántos modelos
    estables tienen `p :- \+ q.` `q :- \+ p.`, el programa `circular` y el
    juego j2?
13. **(2)** Escribir el programa `alcanza(Y)`, los nodos alcanzables desde
    0 en la fila del programa `cadena(N)`, y comparar el costo de su
    evaluación semi-ingenua con la de `camino/2` para 40 arcos. ¿Qué parte del modelo
    de `camino/2` hacía falta para responder `camino(0, Y)`?
14. **(3)** Escribir `semi_ingenua_estricta_de/4`, y su forma por nombre
    `semi_ingenua_estricta/4`, que en cada paso evalúa los
    literales anteriores al nuevo con la interpretación del paso anterior, y
    los posteriores con la actual, de modo que ninguna derivación se cuente
    dos veces. Compararla con `semi_ingenua/4` en un programa donde una
    cláusula tiene dos literales recursivos:
    `camino(X, Y) :- camino(X, Z), camino(Z, Y).`
15. ★ **(2)** Agregar a la versión `puede_volar` de la base r14, `si
    mamifero y no carnivoro entonces herbivoro`, y r15, `si herbivoro y
    no tiene_cascos entonces carnivoro`. Decidir si la base sigue siendo
    estratificada, dar los ciclos negativos, y calcular con `valor/3` los
    valores de `carnivoro` y de `herbivoro` cuando la única observación es
    `tiene_pelo`. Proponer una corrección.

## Resumen

| | |
|---|---|
| **base de Herbrand** | los átomos sin variables que se construyen con los símbolos del programa |
| **modelo** | una interpretación que hace verdadera cada instancia de cada cláusula |
| **modelo mínimo** | la intersección de los modelos de un programa definido: sus consecuencias lógicas |
| **forma clausal** | toda fórmula se escribe como conjunción de cláusulas; las de Horn con conclusión tienen modelo mínimo |
| **resolución SLD** | regla de selección, cláusula renombrada, unificador más general; correcta, completa, independiente de la regla |
| **compleción de Clark** | cada predicado definido con «si y solo si»; justifica la negación como falla finita |
| **SLDNF** | SLD con negación como falla; un literal negado se elige solo sin variables |
| **estratificación** | ningún ciclo de dependencias pasa por una negación; el modelo estándar se calcula por estratos |
| **semántica bien fundada** | tres valores; coincide con el modelo mínimo y con el estándar donde existen |
| **$T_P$** | el operador de consecuencia inmediata; su menor punto fijo es el modelo mínimo |
| **evaluación semi-ingenua** | cada paso usa al menos un átomo nuevo del paso anterior |
| `clausulas/2` | las cláusulas de un programa por su nombre: de `programa/2`, leídas con `clause/2`, o de `generado/2` |
| `generado/2` | los programas construidos como datos, como `cadena(N)`; `multifile`, para que otros archivos agreguen los suyos |
| `modelo_minimo/2` y `modelo_minimo_de/2` | las dos formas de cada evaluador: la primera recibe el nombre del programa, la terminada en `_de` la lista de sus cláusulas |
| `es_modelo/2`, `consecuencias/3`, `modelo_minimo/2` | verificar un modelo, aplicar $T_P$, calcular el modelo mínimo |
| `consecuencia/2` | los átomos del modelo mínimo, uno por respuesta |
| `ingenua/4`, `semi_ingenua/4` | las dos evaluaciones, con su costo en pasos y derivaciones |
| `estratos/2`, `ciclos_negativos/2`, `modelo_estandar/2` | los estratos, los ciclos que los impiden y el modelo estándar |
| `bien_fundado/3`, `valor/3` | el modelo bien fundado y el valor de un átomo en él |
| `paso/4`, `arbol_sld/5` | un paso SLD y el árbol SLD con una regla de selección |
| `sldnf/2`, `complecion/3` | la resolución SLDNF con la regla segura, y la definición completada |
| `unify_with_occurs_check/2` | la unificación con verificación de ocurrencia |
| `ord_subset/2` | un conjunto ordenado está contenido en otro; en las soluciones, para elegir los modelos minimales |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| La semántica bien fundada en SWI-Prolog: `tnot/1` y las respuestas indefinidas | [capítulo 40](../capitulo-40-tabulacion/index.md) |
| El intérprete del sistema experto con tablas, donde los ciclos positivos terminan | [capítulo 40](../capitulo-40-tabulacion/index.md) |
| La resolución general, sobre cláusulas que no son de Horn | [capítulo 63](../capitulo-63-proyecto-demostrador-teoremas/index.md) |
| Las reglas con excepciones, como razonamiento rebatible | [capítulo 66](../capitulo-66-proyecto-razonamiento-rebatible/index.md) |
| Un motor Datalog con evaluación semi-ingenua y transformación mágica | [capítulo 86](../capitulo-86-proyecto-motor-datalog/index.md) |
| `WITH RECURSIVE`, la evaluación semi-ingenua de SQL | [capítulo 43](../capitulo-43-prolog-y-sql/index.md) |

## Referencias

- Ulf Nilsson y Jan Małuszyński, *Logic, Programming and Prolog*, 2.ª
  edición, John Wiley & Sons, 1995 — capítulo «Negation in Logic
  Programming» (apartados «General Logic Programs» y «Well-founded
  Semantics») y capítulo «Query-answering in Deductive Databases»
  (apartados «Semi-naive Evaluation» y «Magic Transformation»).
  [Edición en línea de los autores](https://www.ida.liu.se/~ulfni53/lpp/).
  Esta página toma de allí los enunciados de los teoremas que cita sin
  demostrar, el juego de las posiciones ganadoras y las evaluaciones
  ingenua y semi-ingenua.
- Michael Spivey, *An Introduction to Logic Programming through Prolog*,
  Prentice Hall, 1996 — apartado «Semantics of negation» del capítulo
  «Negation as failure».
  [Edición del autor](https://spivey.oriel.ox.ac.uk/wiki/files/logprog/logic.pdf).
  De allí viene la construcción del modelo de un programa estratificado
  capa por capa.
- Peter Flach, *Simply Logical: Intelligent Reasoning by Example*, John
  Wiley & Sons, 1994 — apartados «Forward chaining»
  ([en línea](https://book.simply-logical.space/src/text/2_part_ii/5.4.html)),
  «Default reasoning»
  ([en línea](https://book.simply-logical.space/src/text/3_part_iii/8.1.html))
  y «The semantics of incomplete information»
  ([en línea](https://book.simply-logical.space/src/text/3_part_iii/8.2.html)).
  Esta página toma el evaluador de abajo hacia arriba que construye
  modelos y la lectura de una regla con excepciones como razonamiento por
  defecto.
- James L. Hein, *Prolog Experiments in Discrete Mathematics, Logic, and
  Computability*, Portland State University, 2009 — apartado «The
  Immediate Consequence Operator» del capítulo «Logic Programming
  Theory». Es la presentación de $T_P$ y de su sucesión desde la
  interpretación vacía que sigue la [sección 39.6](#396-evaluacion-de-abajo-hacia-arriba).
- Los artículos originales que esta página nombra, citados a través de los
  libros anteriores: Maarten van Emden y Robert Kowalski, «The semantics
  of predicate logic as a programming language», *Journal of the ACM*
  23(4), 1976 ($T_P$ y el menor punto fijo); Krzysztof Apt, Howard Blair
  y Adrian Walker, «Towards a theory of declarative knowledge», 1988, y
  Allen Van Gelder, «Negation as failure using tight derivations for
  general logic programs», 1988 (la estratificación); Michael Gelfond y
  Vladimir Lifschitz, «The stable model semantics for logic programming»,
  1988 (los modelos estables); y Allen Van Gelder, Kenneth Ross y John
  Schlipf, «The well-founded semantics for general logic programs»,
  *Journal of the ACM* 38(3), 1991 (la semántica bien fundada).

Los programas del capítulo son propios, escritos para el curso: las
fuentes aportan las definiciones, los teoremas y los ejemplos, como el
juego de Nilsson y Małuszyński, pero no código; los evaluadores sobre
listas de cláusulas, el punto fijo alternado con `reducido/3`, el conteo de
derivaciones y el verificador de estratos por rondas son del curso.
