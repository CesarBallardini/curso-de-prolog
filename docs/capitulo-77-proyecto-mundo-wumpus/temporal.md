# El agente con historia

Esta página completa el [capítulo 77](index.md) con la parte del
capítulo «Logical Agents» de Russell y Norvig que las cinco versiones no
programan: el agente del apartado «Agents Based on Propositional Logic»,
que no recibe su ubicación como dato, sino que la deduce de lo que hizo y
de lo que percibió, con un **axioma de estado sucesor** por cada
propiedad que cambia con el tiempo. El ejemplo es `temporal.pl`, en
`ejemplos/capitulo-77/`, con sus pruebas; carga la versión 3 y se ejecuta
en una instalación local.

## Fluentes y axiomas de estado sucesor

En la versión 2 la acción `ir(C)` lleva al agente a la celda vecina C, y
el agente sabe siempre en qué celda está. Las acciones del libro son
otras: **avanzar** una celda hacia donde se mira, **girar** a la izquierda
o a la derecha, **disparar** hacia donde se mira, **tomar** y **salir**.
El agente empieza en (1, 1) mirando al este, y un avance contra una pared
no lo mueve: deja la percepción **golpe**. Para saber dónde está, el
agente tiene que recordar sus acciones y sus percepciones, y deducir.

Una **historia** registra las dos cosas: el término `h(N, Percepciones,
Acciones)` tiene el tamaño de la cueva, la lista de las percepciones de
los momentos 0, 1, …, T y la de las acciones de los momentos 0, …, T − 1.
Lo que cambia con el tiempo se llama un **fluente**: `en(Celda)`,
`mira(Direccion)`, `tiene_flecha` y `wumpus_vivo`. Russell y Norvig
escriben un símbolo proposicional por fluente y por momento, con el
momento como superíndice, y describen cada fluente con un axioma de
estado sucesor: el fluente vale en t + 1 si y solo si una acción lo
produjo en t, o si valía en t y ninguna acción lo deshizo. Los axiomas
de la flecha y de la celda (1, 1) son los del libro; el del wumpus, que
muere cuando se oye el grito, es el del código de `aima-python`:

$$\mathit{HaveArrow}^{t+1} \Leftrightarrow \mathit{HaveArrow}^{t} \land \lnot \mathit{Shoot}^{t}$$

$$\mathit{WumpusAlive}^{t+1} \Leftrightarrow \mathit{WumpusAlive}^{t} \land \lnot \mathit{Scream}^{t+1}$$

$$L^{t+1}_{1,1} \Leftrightarrow (L^{t}_{1,1} \land (\lnot \mathit{Forward}^{t} \lor \mathit{Bump}^{t+1})) \lor (L^{t}_{1,2} \land \mathit{FacingSouth}^{t} \land \mathit{Forward}^{t}) \lor (L^{t}_{2,1} \land \mathit{FacingWest}^{t} \land \mathit{Forward}^{t})$$

La segunda parte de cada disyunción es la que resuelve el **problema del
marco**: sin ella, nada dice que el agente que gira sigue en la misma
celda, ni que la flecha sigue en su lugar mientras no se dispara. Con un
axioma por fluente, y no uno por fluente y por acción, la cantidad de
axiomas crece con la cantidad de fluentes, no con su producto por la de
acciones.

En Prolog, cada axioma es una cláusula que calcula el valor del fluente
en T a partir del de T − 1. Los fluentes del momento 0 son hechos:

<!-- ejemplo: capitulo-77/temporal.pl predicado: vale/3 sucesor/4 -->
```prolog
%!  vale(+H, ?Fluente, +T:integer) is nondet.
%
%   Fluente vale en el momento T de la historia H. En el momento 0 el
%   agente está en (1, 1), mira al este, tiene la flecha y el wumpus vive;
%   en cada momento posterior, cada fluente sigue su axioma de estado
%   sucesor.
vale(_, Fluente, 0) :-
    inicial(Fluente).
vale(H, Fluente, T) :-
    T > 0,
    T0 is T - 1,
    sucesor(Fluente, H, T0, T).

%!  sucesor(?Fluente, +H, +T0:integer, +T:integer) is nondet.
%
%   Fluente vale en T = T0 + 1, según lo que valía en T0, la acción de T0
%   y lo que se percibió en T.
sucesor(en(C), H, T0, T) :-
    vale(H, en(C0), T0),
    (   hizo(H, avanzar, T0),
        \+ percibio(H, golpe, T)
    ->  vale(H, mira(D), T0),
        adelante(C0, D, C)
    ;   C = C0
    ).
sucesor(mira(D), H, T0, _) :-
    vale(H, mira(D0), T0),
    (   hizo(H, girar(Lado), T0)
    ->  girar(Lado, D0, D)
    ;   D = D0
    ).
sucesor(tiene_flecha, H, T0, _) :-
    vale(H, tiene_flecha, T0),
    \+ hizo(H, disparar, T0).
sucesor(wumpus_vivo, H, T0, T) :-
    vale(H, wumpus_vivo, T0),
    \+ percibio(H, grito, T).
```

`adelante/3` da la celda vecina hacia una dirección, y `girar/3` la
dirección después de un giro. La cláusula de `en/1` dice lo mismo que el
axioma de la celda (1, 1), para todas las celdas a la vez: la celda
cambia solo si el agente avanzó y no percibió un golpe. Las cláusulas
escriben una sola mitad de cada bicondicional, la que va de las acciones
al fluente. La otra mitad la da la lectura de un programa como su
**compleción**, la de la
[sección 38.3](../capitulo-38-semantica-de-los-programas-logicos/index.md#383-negacion-como-falla-la-complecion-de-clark-y-sldnf):
el fluente vale solo en los casos que las cláusulas enumeran. Esa lectura
es correcta aquí porque la historia está completa: una acción que no
figura en ella no se hizo, y `\+ hizo(H, disparar, T0)` puede afirmarlo.
El código de `aima-python` dice lo mismo de manera explícita: cada vez
que registra una acción, registra también la negación de las demás.

La historia de la figura 7.4 del libro, con las acciones del libro: el
agente avanza a (2, 1), percibe brisa, gira dos veces, vuelve a (1, 1),
gira a la derecha y avanza a (1, 2), donde percibe hedor.

<!-- contexto: capitulo-77/temporal.pl -->
```prolog
?- ejemplo_historia(figura_7_4, H), trayectoria(H, Cs).
H = h(4, [[], [brisa], [brisa], [brisa], [], [], [hedor]], [avanzar, girar(izquierda), girar(izquierda), avanzar, girar(derecha), avanzar]),
Cs = [1-1, 2-1, 2-1, 2-1, 1-1, 1-1, 1-2].

?- ejemplo_historia(figura_7_4, H), findall(F, vale(H, F, 6), Fs).
H = h(4, [[], [brisa], [brisa], [brisa], [], [], [hedor]], [avanzar, girar(izquierda), girar(izquierda), avanzar, girar(derecha), avanzar]),
Fs = [en(1-2), mira(norte), tiene_flecha, wumpus_vivo].
```

`trayectoria/2` da la celda deducida en cada momento. `historia/3`
ejecuta una lista de acciones del libro en un mundo de la versión 2, con
`actuar/6` para los avances y los disparos, y registra lo que percibe el
agente; un avance hacia el sur desde (1, 1) deja un golpe, y la celda no
cambia:

```prolog
?- mundo(figura_7_2, M), historia(M, [girar(derecha), avanzar], H), trayectoria(H, Cs).
M = mundo(4, [3-1, 3-3, 4-4], 1-3, 2-3),
H = h(4, [[], [], [golpe]], [girar(derecha), avanzar]),
Cs = [1-1, 1-1, 1-1].
```

## Lo que se sabe en cada momento

Con la celda de cada momento, la historia se convierte en el conocimiento
de la [versión 3](index.md#775-version-3-el-agente-basado-en-conocimiento):
las celdas visitadas, con la brisa y el hedor percibidos en cada una, y el
estado de la flecha y del wumpus en el momento pedido.
`conocimiento_en/3` lo arma, y `ok/3` es el fluente que el libro llama
OK, una celda sin pozo ni wumpus vivo:

$$\mathit{OK}^{t}_{x,y} \Leftrightarrow \lnot P_{x,y} \land \lnot (W_{x,y} \land \mathit{WumpusAlive}^{t})$$

<!-- ejemplo: capitulo-77/temporal.pl predicado: conocimiento_en/3 visitar/4 ok/3 -->
```prolog
%!  conocimiento_en(+H, +T:integer, -K) is det.
%
%   K es el conocimiento de la versión 3 que se sigue de la historia H
%   hasta el momento T: la celda del agente en T, las celdas visitadas en
%   orden, con la brisa y el hedor percibidos en cada una, si tiene la
%   flecha y si el wumpus vive.
conocimiento_en(H, T, c(N, C, Visitadas, no, Flecha, Wumpus, [])) :-
    H = h(N, _, _),
    once(vale(H, en(C), T)),
    numlist(0, T, Momentos),
    foldl(visitar(H), Momentos, [], Visitadas),
    (   vale(H, tiene_flecha, T)
    ->  Flecha = si
    ;   Flecha = no
    ),
    (   vale(H, wumpus_vivo, T)
    ->  Wumpus = vivo([])
    ;   Wumpus = muerto
    ).

%!  visitar(+H, +T:integer, +Vs0:list, -Vs:list) is det.
%
%   Vs agrega a Vs0 la celda del agente en el momento T, con su brisa y su
%   hedor, si no estaba.
visitar(H, T, Vs0, Vs) :-
    once(vale(H, en(C), T)),
    (   memberchk(C-_, Vs0)
    ->  Vs = Vs0
    ;   findall(P, ( percibio(H, P, T), de_la_celda(P) ), Ps0),
        msort(Ps0, Ps),
        append(Vs0, [C-Ps], Vs)
    ).

%!  ok(+H, +C, +T:integer) is semidet.
%
%   En el momento T de la historia H se sabe que la celda C no tiene pozo
%   ni un wumpus vivo: es una celda visitada o una celda segura de la
%   frontera.
ok(H, C, T) :-
    conocimiento_en(H, T, K),
    clasificar(K, C, Clase),
    memberchk(Clase, [visitada, segura]).
```

La decisión sobre los pozos y el wumpus es la de la versión 3, por mundos
consistentes; la historia agrega el tiempo. Una celda que no es OK en un
momento puede serlo en el siguiente, aunque nada cambie en la cueva más
que el wumpus. La historia `disparo` agrega a la anterior un disparo
hacia el norte desde (1, 2), y el grito que sigue:

```prolog
?- ejemplo_historia(figura_7_4, H), celdas_ok(H, 6, Cs).
H = h(4, [[], [brisa], [brisa], [brisa], [], [], [hedor]], [avanzar, girar(izquierda), girar(izquierda), avanzar, girar(derecha), avanzar]),
Cs = [1-1, 1-2, 2-1, 2-2].

?- ejemplo_historia(disparo, H), celdas_ok(H, 7, Cs).
H = h(4, [[], [brisa], [brisa], [brisa], [], [], [hedor], [...|...]], [avanzar, girar(izquierda), girar(izquierda), avanzar, girar(derecha), avanzar, disparar]),
Cs = [1-1, 1-2, 1-3, 2-1, 2-2].
```

En el momento 6 la celda (1, 3) tiene el wumpus; en el 7, el grito hace
falso `wumpus_vivo`, y la celda queda OK: la falta de brisa en (1, 2)
prueba que no tiene pozo.

## De los planes a las acciones del libro

El agente de la versión 3 planea con `ir(C)`, y los caminos del A\* del
[capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) son
listas de celdas. Para jugar con las acciones del libro, cada `ir(C)` se
traduce en los giros que llevan a mirar hacia C y un avance. `giros/3` da
ninguno, uno o dos giros, y `traducir/4` recorre el plan llevando la
posición, un término `p(Celda, Direccion)`:

<!-- ejemplo: capitulo-77/temporal.pl predicado: giros/3 traducir/4 paso/5 -->
```prolog
%!  giros(+D0, +D, -Giros:list) is det.
%
%   Giros son los giros que llevan de mirar hacia D0 a mirar hacia D: ninguno,
%   uno a cada lado o dos a la izquierda.
giros(D, D, []) :-
    !.
giros(D0, D, [girar(izquierda)]) :-
    izquierda(D0, D),
    !.
giros(D0, D, [girar(derecha)]) :-
    izquierda(D, D0),
    !.
giros(_, _, [girar(izquierda), girar(izquierda)]).

%!  traducir(+Plan:list, +Inicio, -Acciones:list, -Fin) is semidet.
%
%   Acciones son las acciones del libro que ejecutan Plan, una lista de
%   acciones de la versión 3, desde Inicio, un término p(Celda, Direccion);
%   Fin es la posición en que termina. Falla si Plan va a una celda que no
%   es vecina.
traducir([], P, [], P).
traducir([A|Plan], P0, Acciones, Fin) :-
    paso(A, P0, Acciones, Resto, P),
    traducir(Plan, P, Resto, Fin).

%!  paso(+A, +P0, -Acciones:list, ?Resto:list, -P) is semidet.
%
%   Acciones son las acciones del libro que ejecutan la acción A de la
%   versión 3 desde la posición P0, seguidas de Resto, y P es la posición
%   final. ir(C) gira hacia C y avanza; disparar(D) gira hacia D y
%   dispara; tomar y salir no cambian.
paso(ir(C), p(C0, D0), Acciones, Resto, p(C, D)) :-
    once(adelante(C0, D, C)),
    giros(D0, D, Giros),
    append(Giros, [avanzar|Resto], Acciones).
paso(disparar(D), p(C, D0), Acciones, Resto, p(C, D)) :-
    giros(D0, D, Giros),
    append(Giros, [disparar|Resto], Acciones).
paso(tomar, P, [tomar|Resto], Resto, P).
paso(salir, P, [salir|Resto], Resto, P).
```

<!-- contexto: capitulo-77/temporal.pl -->
```prolog
?- traducir([ir(1-2), ir(1-1), disparar(este)], p(1-1, este), As, Fin).
As = [girar(izquierda), avanzar, girar(izquierda), girar(izquierda), avanzar, girar(izquierda), disparar],
Fin = p(1-1, este).

?- mundo(figura_7_2, M), jugar(M, final(_, _, Plan)), traducir(Plan, p(1-1, este), As, Fin), length(As, N).
M = mundo(4, [3-1, 3-3, 4-4], 1-3, 2-3),
Plan = [ir(1-2), ir(1-1), ir(2-1), ir(2-2), ir(2-3), tomar, ir(2-2), ir(... - ...), ir(...)|...],
As = [girar(izquierda), avanzar, girar(izquierda), girar(izquierda), avanzar, girar(izquierda), avanzar, girar(izquierda), avanzar|...],
Fin = p(1-1, oeste),
N = 18.
```

La partida de diez acciones de la versión 3 son dieciocho acciones del
libro: ocho giros más. Con el puntaje del libro, un punto menos por
acción, la misma partida da 982 puntos en lugar de 990. La prueba
`partida` de `temporal.plt` ejecuta esas dieciocho acciones con
`historia/3` y verifica que la trayectoria que el agente deduce de su
historia pasa por cada celda del plan y termina en (1, 1).

## El costo de deducir desde el principio

`vale/3` recalcula cada fluente desde el momento 0: la celda del momento
T pide la del T − 1 y la dirección del T − 1, que a su vez piden las
anteriores. Russell y Norvig señalan el mismo problema en la versión
proposicional: el agente que pregunta por el momento t razona sobre una
fórmula que crece con t, y el tiempo de cada decisión crece con la
partida. Su remedio es la **estimación del estado**: guardar, en lugar de
la historia, lo que se sabe del estado actual, y actualizarlo con cada
acción y cada percepción.

Es lo que hace el conocimiento `c/7` de la versión 3. `registrar/3`
agrega las percepciones de la celda actual, y la celda, la flecha y el
wumpus se actualizan con cada acción, de modo que el agente nunca vuelve
a leer su pasado. Con las acciones de la versión 3, y una historia sin
percepciones faltantes, el estado se conoce exactamente, y la estimación
no pierde nada. La historia y sus axiomas siguen siendo necesarios cuando
el estado no se deduce de una sola manera, por ejemplo si una percepción
puede faltar: entonces la ubicación es una disyunción de celdas, y la
decisión necesita un procedimiento completo para fórmulas, como el de
`library(clpb)` en [Los enfoques comparados](enfoques.md).
