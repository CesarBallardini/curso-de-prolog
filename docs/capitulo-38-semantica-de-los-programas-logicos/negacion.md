# Estratificación y semántica bien fundada

Esta página contiene las secciones [38.4](index.md#384-estratificacion) y
[38.5](index.md#385-la-semantica-bien-fundada) del [capítulo 38](index.md):
qué significa un programa con negación cuando un predicado depende de su
propia negación. La estratificación excluye esos programas y da a los demás
un modelo estándar; la semántica bien fundada da un significado a todos, con
tres valores de verdad. Los evaluadores están en `semantica.pl`, en
`ejemplos/capitulo-38/`, con sus pruebas, y corren en SWISH; como todos los
del capítulo, tienen una forma terminada en `_de`, que recibe la lista de
cláusulas, y otra que recibe el nombre del programa. Usan `cumple/3` y
`semi_ingenua_de/4`, de las secciones [38.1](index.md#381-modelos-y-consecuencia-logica)
y [38.6](index.md#386-evaluacion-de-abajo-hacia-arriba), y el programa
`circular` de la [sección 38.3](resolucion.md#un-predicado-definido-por-su-propia-negacion).

## Estratificación

El problema de `r :- \+ r` es que el predicado se define en términos de su
propio complemento. Krzysztof Apt, Howard Blair y Adrian Walker, y de forma
independiente Allen Van Gelder, propusieron en 1988 escribir los programas
**en capas**: un predicado se usa negado solo cuando ya está completamente
definido en una capa inferior. El **grafo de dependencias** tiene un nodo
por predicado y una arista de p a q cuando una cláusula de p tiene un literal
de q en el cuerpo, marcada como negativa si el literal está negado:

<!-- ejemplo: capitulo-38/semantica.pl predicado: dependencias_de/2 dependencia/3 -->
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

<!-- ejemplo: capitulo-38/semantica.pl predicado: inalcanzable/2 -->
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

<!-- ejemplo: capitulo-38/semantica.pl predicado: estratos_de/2 niveles/2 subir/4 elevar/4 -->
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

<!-- ejemplo: capitulo-38/semantica.pl predicado: ciclos_negativos_de/2 alcanza/3 -->
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

<!-- ejemplo: capitulo-38/semantica.pl predicado: modelo_estandar_de/2 evaluar_estrato/4 -->
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
cada uno exige que el otro sea falso (ejercicio 3).

## La semántica bien fundada

Un programa que no es estratificado puede tener un significado claro. El
programa `juego` describe dos juegos: en cada turno, el jugador que mueve
pasa de una posición a otra, y el que no puede mover pierde. Una posición
es ganadora si hay un movimiento a una posición que no es ganadora para el
rival. Es el ejemplo de Nilsson y Małuszyński (apartado 4.7):

<!-- ejemplo: capitulo-38/semantica.pl predicado: mueve/3 gana/2 -->
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

<!-- ejemplo: capitulo-38/semantica.pl predicado: reducido/3 bien_fundado_de/3 alternar/4 -->
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

<!-- ejemplo: capitulo-38/semantica.pl predicado: valor_de/3 -->
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
negación del otro. El [capítulo 39](../capitulo-39-tabulacion/index.md) lo presenta.

!!! question "Actividad"
    Agregar al juego j2 el movimiento `mueve(j2, a, e)`, sin movimientos
    desde e. Predecir el valor de `gana(j2, a)` y de `gana(j2, b)` antes de
    calcularlo con `bien_fundado/3`, y explicar por qué el empate
    desaparece.
