# La tabla de un juego

Esta página contiene la [sección 85.9](index.md#859-la-tabla-de-un-juego)
del [capítulo 85](index.md): la tabla de un juego calculada hacia atrás,
primero examinando todas las posiciones en cada ronda, como la tabla de
finales del [capítulo 79](../capitulo-79-proyecto-lenguaje-consejos-ajedrez/index.md),
y después partiendo solo de lo que cambió, como la evaluación
semi-ingenua. El código está en `retrogrado.pl`, en
`ejemplos/capitulo-85/`, con sus pruebas; no carga otros archivos y corre
en SWISH.

## Un programa que no es estratificado

La [sección 38.5](../capitulo-38-semantica-de-los-programas-logicos/index.md#385-la-semantica-bien-fundada)
escribió quién gana un juego con una sola regla: el que mueve en X gana
si puede pasar a una posición desde la que el rival no gana.

```prolog
gana(X) :- mueve(X, Y), \+ gana(Y).
```

`gana/1` depende de su propia negación: el programa no es estratificado,
y el motor lo rechaza. El [capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md) le dio significado con la semántica
bien fundada, en tres valores: las posiciones que ganan, las que pierden y
las **tablas**, en las que ninguno de los dos puede forzar el final y que
quedan indefinidas. La tabla de finales de la
[sección 79.6](../capitulo-79-proyecto-lenguaje-consejos-ajedrez/index.md#796-version-6-la-tabla-de-finales)
calcula lo mismo para el final de rey y torre contra rey, con un número
más: en cuántas jugadas se gana o se pierde con el mejor juego de los dos
bandos. Se calcula **hacia atrás**: pierden en 0 las posiciones sin
jugadas; gana en K una posición con una jugada a otra que pierde en menos
de K; pierde en K una posición cuyas jugadas llevan todas a posiciones que
ganan en menos de K. Se repite con K + 1 hasta que ninguna posición
cambia. Es un punto fijo calculado de abajo hacia arriba, como el modelo
de un programa Datalog, aunque el programa no sea estratificado: la
cuenta de las rondas reemplaza a los estratos.

`retrogrado.pl` representa un juego como una lista de jugadas `X-Y`. El
juego de restar es el ejemplo de prueba: una pila de N fichas, de la que
cada jugador saca 1, 2 o 3, y pierde quien no puede sacar. El que mueve
pierde en los múltiplos de 4, porque siempre puede dejar al rival en el
múltiplo de 4 anterior.

<!-- ejemplo: capitulo-85/retrogrado.pl predicado: restar/2 -->
```prolog
%!  restar(+N:integer, -Jugadas:list) is det.
%
%   Jugadas son las del juego de restar: una pila de N fichas, de la que
%   cada jugador saca 1, 2 o 3.
restar(N, Jugadas) :-
    findall(X-Y,
            ( between(1, N, X),
              between(1, 3, M),
              Y is X - M,
              Y >= 0 ),
            Jugadas).
```

## Las rondas del capítulo 79

`rondas/3` hace lo que `retroceder/1` del [capítulo 79](../capitulo-79-proyecto-lenguaje-consejos-ajedrez/index.md): en cada ronda
examina todas las posiciones que todavía no tienen valor, y cuenta los
arcos que recorre para decidirlas:

<!-- ejemplo: capitulo-85/retrogrado.pl predicado: rondas/3 ronda/7 valor_en/4 -->
```prolog
%!  rondas(+Jugadas:list, -Tabla:list, -Arcos:integer) is det.
%
%   Tabla son los pares Posicion-Valor de las posiciones con valor,
%   ordenados; Arcos, los que se examinaron. Pierden en 0 las posiciones
%   sin jugadas; en cada ronda K, toda posición sin valor se examina: gana
%   en K si una jugada lleva a una que pierde, y pierde en K si todas
%   llevan a posiciones que ganan.
rondas(Jugadas, Tabla, Arcos) :-
    posiciones(Jugadas, Ps),
    vecinos(Jugadas, Ps, Sucesoras),
    findall(P-pierde(0), ( member(P, Ps), get_assoc(P, Sucesoras, []) ),
            Finales),
    list_to_assoc(Finales, Valores0),
    ronda(1, Ps, Sucesoras, Valores0, Valores, 0, Arcos),
    assoc_to_list(Valores, Tabla).

%!  ronda(+K:integer, +Ps:list, +Sucesoras, +Valores0, -Valores,
%!        +Arcos0:integer, -Arcos:integer) is det.
%
%   Valores agrega a Valores0 las posiciones que reciben valor en la ronda
%   K y en las siguientes, hasta una ronda que no agrega nada.
ronda(K, Ps, Sucesoras, Valores0, Valores, Arcos0, Arcos) :-
    findall(P-V-N,
            ( member(P, Ps),
              \+ get_assoc(P, Valores0, _),
              get_assoc(P, Sucesoras, Ss),
              length(Ss, N),
              valor_en(K, Ss, Valores0, V) ),
            Nuevos),
    findall(P, ( member(P, Ps), \+ get_assoc(P, Valores0, _) ), SinValor),
    foldl(sumar_sucesoras(Sucesoras), SinValor, Arcos0, Arcos1),
    (   Nuevos == []
    ->  Valores = Valores0,
        Arcos = Arcos1
    ;   foldl(poner_valor, Nuevos, Valores0, Valores1),
        K1 is K + 1,
        ronda(K1, Ps, Sucesoras, Valores1, Valores, Arcos1, Arcos)
    ).

%!  valor_en(+K:integer, +Ss:list, +Valores, -V) is semidet.
%
%   V es gana(K) si una de las sucesoras Ss pierde, o pierde(K) si todas
%   ganan, según los Valores de las rondas anteriores.
valor_en(K, Ss, Valores, V) :-
    (   member(S, Ss),
        get_assoc(S, Valores, pierde(_))
    ->  V = gana(K)
    ;   forall(member(S, Ss), get_assoc(S, Valores, gana(_)))
    ->  V = pierde(K)
    ).
```

```prolog
?- rondas([a-b, b-a, b-c], T, N).
T = [a-pierde(2), b-gana(1), c-pierde(0)],
N = 4.
```

Es el juego j1 del [capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md): `c` no tiene jugadas y pierde; `b` puede
pasar a `c` y gana en una jugada; `a` solo puede pasar a `b`, y pierde en
dos. Cada ronda vuelve a examinar todas las posiciones sin valor, aunque
la anterior no haya cambiado nada cerca de ellas: es la evaluación
ingenua de la
[sección 38.6](../capitulo-38-semantica-de-los-programas-logicos/index.md#386-evaluacion-de-abajo-hacia-arriba).
En la tabla de finales del [capítulo 79](../capitulo-79-proyecto-lenguaje-consejos-ajedrez/index.md), las 62 320 posiciones se recorren
en cada ronda, hasta la del mate más lejano, a 16 jugadas.

## Partir de lo que cambió

Una posición solo puede recibir valor en la ronda K si una de sus
sucesoras lo recibió en la ronda K − 1. `retrogrado/3` parte en cada
ronda de esas posiciones **nuevas** y recorre solo los arcos que llegan a
ellas, con las predecesoras de cada posición calculadas una vez al
principio. Si la nueva pierde, la predecesora gana. Si la nueva gana, la
predecesora tiene una jugada menos que podría salvarla: cada posición
lleva la **cuenta** de sus jugadas que todavía no llevan a una posición
ganada por el rival, y pierde cuando la cuenta llega a 0.

<!-- ejemplo: capitulo-85/retrogrado.pl predicado: retrogrado/3 hacia_atras/8 propagar/6 predecesora/6 -->
```prolog
%!  retrogrado(+Jugadas:list, -Tabla:list, -Arcos:integer) is det.
%
%   La misma Tabla que rondas/3. Cada ronda parte de las posiciones que
%   recibieron valor en la anterior, las nuevas, y examina solo los arcos
%   que llegan a ellas: una predecesora sin valor gana si la nueva pierde,
%   y si la nueva gana, descuenta una de sus jugadas pendientes, y pierde
%   cuando no le quedan.
retrogrado(Jugadas, Tabla, Arcos) :-
    posiciones(Jugadas, Ps),
    vecinos(Jugadas, Ps, Sucesoras),
    findall(Y-X, member(X-Y, Jugadas), Inversas),
    vecinos(Inversas, Ps, Predecesoras),
    findall(P-N,
            ( member(P, Ps),
              get_assoc(P, Sucesoras, Ss),
              length(Ss, N) ),
            Cuentas0),
    list_to_assoc(Cuentas0, Cuentas),
    findall(P-pierde(0), member(P-0, Cuentas0), Finales),
    list_to_assoc(Finales, Valores0),
    pairs_keys(Finales, Nuevas),
    hacia_atras(1, Nuevas, Predecesoras, Cuentas, Valores0, Valores,
                0, Arcos),
    assoc_to_list(Valores, Tabla).

%!  hacia_atras(+K:integer, +Nuevas:list, +Predecesoras, +Cuentas0,
%!              +Valores0, -Valores, +Arcos0:integer, -Arcos:integer)
%!      is det.
%
%   Valores agrega a Valores0 los de la ronda K, que parte de las
%   posiciones Nuevas, y los de las siguientes, hasta que no hay nuevas.
hacia_atras(K, Nuevas, Predecesoras, Cuentas0, Valores0, Valores,
            Arcos0, Arcos) :-
    (   Nuevas == []
    ->  Valores = Valores0,
        Arcos = Arcos0
    ;   foldl(propagar(K, Predecesoras, Valores0), Nuevas,
              Cuentas0-[]-Arcos0, Cuentas-Ganadas0-Arcos1),
        sort(Ganadas0, Ganadas),
        foldl(poner_valor, Ganadas, Valores0, Valores1),
        findall(P, member(P-_-_, Ganadas), Siguientes),
        K1 is K + 1,
        hacia_atras(K1, Siguientes, Predecesoras, Cuentas, Valores1,
                    Valores, Arcos1, Arcos)
    ).

%!  propagar(+K:integer, +Predecesoras, +Valores, +Nueva, +Estado0,
%!           -Estado) is det.
%
%   Estado0 es Cuentas0-Ganadas0-Arcos0. Recorre los arcos que llegan a la
%   posición Nueva desde las predecesoras sin valor: si Nueva pierde, la
%   predecesora gana en K; si gana, la cuenta de la predecesora baja en 1,
%   y al llegar a 0 pierde en K. Ganadas agrega los términos P-V-0 de las
%   posiciones que reciben valor.
propagar(K, Predecesoras, Valores, Nueva, C0-G0-A0, C-G-A) :-
    get_assoc(Nueva, Valores, VNueva),
    get_assoc(Nueva, Predecesoras, Qs),
    length(Qs, L),
    A is A0 + L,
    foldl(predecesora(K, VNueva, Valores), Qs, C0-G0, C-G).

%!  predecesora(+K:integer, +VNueva, +Valores, +Q, +Estado0, -Estado)
%!      is det.
%
%   Estado0 es Cuentas0-Ganadas0: aplica a la predecesora Q el valor
%   VNueva de una de sus sucesoras, si Q no tiene valor todavía.
predecesora(K, VNueva, Valores, Q, C0-G0, C-G) :-
    (   get_assoc(Q, Valores, _)
    ->  C = C0,
        G = G0
    ;   VNueva = pierde(_)
    ->  C = C0,
        G = [Q-gana(K)-0|G0]
    ;   get_assoc(Q, C0, N0),
        N is N0 - 1,
        put_assoc(Q, C0, N, C),
        (   N =:= 0
        ->  G = [Q-pierde(K)-0|G0]
        ;   G = G0
        )
    ).
```

Los átomos nuevos de la evaluación semi-ingenua son aquí las posiciones
nuevas, y la cuenta reemplaza a la negación: «todas las jugadas llevan a
posiciones ganadas» se decide sin volver a recorrer las jugadas, restando
una cada vez que una sucesora gana. Es la misma técnica que la cola del
filtrado de Waltz del
[capítulo 80](../capitulo-80-proyecto-etiquetado-waltz/index.md#806-version-4-el-filtrado-de-waltz):
se trabaja solo donde algo cambió.

```prolog
?- retrogrado([a-b, b-a, b-c], T, N).
T = [a-pierde(2), b-gana(1), c-pierde(0)],
N = 3.

?- retrogrado([a-b, b-a, b-c, c-d], T, N).
T = [c-gana(1), d-pierde(0)],
N = 2.
```

El segundo es el juego j2 del capítulo 38. `c` gana, porque pasa a `d`,
que no tiene jugadas; `a` y `b` no reciben valor: la cuenta de `b` baja
de 2 a 1 cuando `c` gana, y nunca llega a 0, porque su otra jugada lleva a
`a`, que tampoco se decide. Son las dos posiciones que el modelo bien
fundado de la
[sección 38.5](../capitulo-38-semantica-de-los-programas-logicos/index.md#385-la-semantica-bien-fundada)
deja indefinidas: las tablas.

```prolog
?- restar(12, Js), retrogrado(Js, T, N).
Js = [1-0, 2-1, 2-0, 3-2, 3-1, 3-0, 4-3, 4-2, ... - ...|...],
T = [0-pierde(0), 1-gana(1), 2-gana(1), 3-gana(1), 4-pierde(2), 5-gana(3), 6-gana(3), 7-gana(...), ... - ...|...],
N = 33.

?- restar(1000, Js), rondas(Js, T1, N1), retrogrado(Js, T2, N2), T1 == T2.
Js = [1-0, 2-1, 2-0, 3-2, 3-1, 3-0, 4-3, 4-2, ... - ...|...],
T1 = T2, T2 = [0-pierde(0), 1-gana(1), 2-gana(1), 3-gana(1), 4-pierde(2), 5-gana(3), 6-gana(3), 7-gana(...), ... - ...|...],
N1 = 750747,
N2 = 2997.
```

Las dos tablas son iguales (prueba `costos:restar_1000`). Con 1 000 fichas hay 2 997 jugadas, y
`retrogrado/3` recorre cada una una sola vez, desde la posición a la que
llega; `rondas/3` recorre 750 747 arcos, porque el valor avanza dos
fichas por ronda y cada ronda examina todas las posiciones que todavía no
lo tienen. La tabla de finales del
[capítulo 79](../capitulo-79-proyecto-lenguaje-consejos-ajedrez/index.md)
tiene la misma estructura: registra para cada posición los códigos de sus
sucesoras, y podría registrar también los de sus predecesoras y una
cuenta, para que cada ronda partiera solo de las posiciones nuevas.

!!! question "Actividad"
    Predecir la tabla del juego `[a-b, b-c, c-a, c-d, d-e]`, con el
    valor de cada posición o su ausencia, y cuántos arcos examina cada
    uno de los dos métodos. Comprobarlo.
