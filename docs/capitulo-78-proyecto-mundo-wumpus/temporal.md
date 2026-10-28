# El agente con historia

Esta página continúa el [capítulo 78](index.md) después de la
[sección 78.7](index.md#787-version-5-un-agente-para-la-cueva-de-yob), con
la [sección 78.8](#788-el-agente-con-historia): la parte del capítulo
«Logical Agents» de Russell y Norvig que las cinco versiones no programan.
El ejemplo es `temporal.pl`, en `ejemplos/capitulo-78/`, con sus pruebas;
carga la versión 3 y se ejecuta en una instalación local.

## 78.8 El agente con historia

Las cinco versiones dan al agente su celda como dato. El agente del
apartado «Agents Based on Propositional Logic» de Russell y Norvig no la
recibe: avanza, gira y dispara, y deduce dónde está de lo que hizo y de lo
que percibió, con un **axioma de estado sucesor** por cada propiedad que
cambia con el tiempo. Esta sección escribe esos axiomas como cláusulas de
`temporal.pl`, arma con ellos el conocimiento de la versión 3 en cada
momento de una historia, traduce los planes de la versión 3 a las acciones
del libro y explica por qué el conocimiento `c/7`, que se actualiza con
cada acción, evita releer la historia en cada decisión.

### Fluentes y axiomas de estado sucesor

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

El axioma de la ubicación en el código de `aima-python` difiere del
libro: en la disyunción que deja al agente en su celda escribe la
ubicación del mismo momento a los dos lados del bicondicional, donde el
libro usa la del momento anterior. La página sigue la forma del libro.

La segunda parte de cada disyunción es la que resuelve el **problema del
marco**: sin ella, nada dice que el agente que gira sigue en la misma
celda, ni que la flecha sigue en su lugar mientras no se dispara. Con un
axioma por fluente, y no uno por fluente y por acción, la cantidad de
axiomas crece con la cantidad de fluentes, no con su producto por la de
acciones.

En Prolog, cada axioma es una cláusula que calcula el valor del fluente
en T a partir del de T − 1. Los fluentes del momento 0 son hechos:

<!-- ejemplo: capitulo-78/temporal.pl predicado: vale/3 sucesor/4 -->
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
[sección 39.3](../capitulo-39-semantica-de-los-programas-logicos/resolucion.md#393-negacion-como-falla-la-complecion-de-clark-y-sldnf):
el fluente vale solo en los casos que las cláusulas enumeran. Esa lectura
es correcta aquí porque la historia está completa: una acción que no
figura en ella no se hizo, y `\+ hizo(H, disparar, T0)` puede afirmarlo.
El código de `aima-python` dice lo mismo de manera explícita: cada vez
que registra una acción, registra también la negación de las demás.

La historia de la figura 7.4 del libro, con las acciones del libro: el
agente avanza a (2, 1), percibe brisa, gira dos veces, vuelve a (1, 1),
gira a la derecha y avanza a (1, 2), donde percibe hedor.

<!-- contexto: capitulo-78/temporal.pl -->
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

### Lo que se sabe en cada momento

Con la celda de cada momento, la historia se convierte en el conocimiento
de la [versión 3](index.md#785-version-3-el-agente-basado-en-conocimiento):
las celdas visitadas, con la brisa y el hedor percibidos en cada una, y el
estado de la flecha y del wumpus en el momento pedido.
`conocimiento_en/3` lo arma, y `ok/3` es el fluente que el libro llama
OK, una celda sin pozo ni wumpus vivo:

$$\mathit{OK}^{t}_{x,y} \Leftrightarrow \lnot P_{x,y} \land \lnot (W_{x,y} \land \mathit{WumpusAlive}^{t})$$

<!-- ejemplo: capitulo-78/temporal.pl predicado: conocimiento_en/3 visitar/4 ok/3 -->
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

### De los planes a las acciones del libro

El agente de la versión 3 planea con `ir(C)`, y los caminos del A\* del
[capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) son
listas de celdas. Para jugar con las acciones del libro, cada `ir(C)` se
traduce en los giros que llevan a mirar hacia C y un avance. `giros/3` da
ninguno, uno o dos giros, y `traducir/4` recorre el plan llevando la
posición, un término `p(Celda, Direccion)`:

<!-- ejemplo: capitulo-78/temporal.pl predicado: giros/3 traducir/4 paso/5 -->
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

<!-- contexto: capitulo-78/temporal.pl -->
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

### El costo de deducir desde el principio

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

Dos partes de ese apartado del libro solo se describen aquí, sin
programarlas. La primera es el agente que escribe los axiomas como
fórmulas proposicionales, un símbolo por fluente y por momento, y decide
si una celda es segura preguntando a un procedimiento de satisfacibilidad
(SAT) si la base de conocimiento es compatible con un peligro en ella. La
segunda es SATPlan, que planifica por la misma vía: afirma la meta en el
momento T, para T = 1, 2, …, y lee el plan en los símbolos de acción del
primer modelo que el procedimiento encuentra. Tampoco se programan
«Wumpus 2» y «Wumpus 3», las versiones posteriores del juego de Yob, con
otras cuevas y peligros nuevos: no hay una edición de acceso libre de
sus reglas que el capítulo pueda seguir.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `subconjunto/2` es `multi` y `mundos_pozos/2`, que reúne sus respuestas, `det` |
    | C2 | representaciones limpias: el estado del juego, el mundo y el conocimiento son términos con un functor cada uno; las jugadas devuelven términos y el texto se redacta aparte |
    | C4 | `actuar/6` resuelve el disparo en una sola cláusula y `pares_con/4` recorre la lista en su primer argumento, de modo que las pruebas no encuentran alternativas pendientes |
    | C6 | el núcleo es puro: `jugada/5` y `simular/5` no escriben nada, y el bucle de la terminal y `narrar/1` solo escriben lo que ellos devuelven |
    | C7 | 156 pruebas en once archivos; el azar sale de una semilla, así que cada partida de las pruebas es reproducible en cualquier instalación |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos.

12. **(2)** Escribir el axioma de estado sucesor del fluente «lleva el
    oro» como un predicado `tiene_oro(H, T)` sobre las historias de
    `temporal.pl`: el agente lleva el oro si en un momento anterior lo
    tomó mientras percibía el brillo. Comprobarlo con la partida de la
    cueva de la figura 7.2 traducida a las acciones del libro, y explicar
    qué parte del predicado resuelve el problema del marco.

## Resumen

| | |
|---|---|
| **agente basado en conocimiento** | registra lo que percibe, infiere qué es seguro y elige una acción; el simulador no le muestra el mundo |
| **mundo consistente** | una ubicación de los peligros que explica cada percepción registrada; una celda es segura si ningún mundo consistente pone un peligro en ella |
| **frontera** | las celdas sin visitar vecinas de una visitada; un pozo fuera de ella no cambia ninguna percepción |
| **probabilidad por mundos** | la suma de las probabilidades de los mundos consistentes con el peligro en la celda, dividida por la de todos |
| **azar como estado** | el generador congruencial lineal pasa su estado de un predicado a otro: una partida queda determinada por su semilla |
| **coordenadas trasladadas** | una búsqueda escrita para una meta fija sirve para cualquier otra si el problema se traslada |
| **forall/2 y las restricciones** | lo que `forall/2` prueba se deshace al terminar, incluidas las restricciones; se imponen con `maplist/2` |
| **fluente** | una propiedad que cambia con el tiempo, como la celda del agente o la flecha |
| **axioma de estado sucesor** | un fluente vale en t + 1 si una acción de t lo produjo, o si valía en t y ninguna lo deshizo; resuelve el problema del marco con un axioma por fluente |
| **lambdas de `library(yall)` compilados** | si la biblioteca ya está cargada, un lambda se traduce al compilar y sus variables libres no declaradas con `/` quedan como variables nuevas; un predicado con nombre evita el problema |
| `nueva_partida/2`, `jugada/5`, `observacion/2` | el juego de Yob |
| `mundo/2`, `mundo_sembrado/2`, `percepciones/3`, `actuar/6`, `simular/5` | el simulador de la grilla |
| `mundos_pozos/2`, `posiciones_wumpus/2`, `clasificar/3`, `seguras/2`, `ruta/4`, `jugar/2` | el agente |
| `probabilidad_pozo/3`, `riesgo/3`, `disparo/3`, `medir/3` | la flecha y el riesgo |
| `cazar/3`, `narrar/1`, `medir_caza/2` | el agente en la cueva de Yob |
| `seguras_con/3`, `comparar_en/3` | la comparación de los enfoques |
| `vale/3`, `conocimiento_en/3`, `ok/3`, `traducir/4`, `historia/3` | el agente con historia |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Descartar las hipótesis que no explican las respuestas: Mastermind | [capítulo 79](../capitulo-79-proyecto-kalah-mastermind-nim/index.md) |
| Reglas como las de seguridad evaluadas por un motor Datalog | [capítulo 86](../capitulo-86-proyecto-motor-datalog/index.md) |

## Referencias

- Stuart Russell y Peter Norvig, *Artificial Intelligence: A Modern
  Approach*, 4.ª edición, Pearson, 2020 — capítulo «Logical Agents»,
  sección «Agents Based on Propositional Logic».
  [Sitio oficial del libro](https://aima.cs.berkeley.edu/). Esta página
  toma de allí las acciones de avanzar y girar, los fluentes con el tiempo
  como superíndice, los axiomas de estado sucesor de la flecha y de la
  ubicación, el fluente OK, el problema del marco y la estimación del
  estado como remedio del costo creciente de la inferencia.
- aima-python, el código oficial del libro, con licencia MIT:
  `aima/logic.py` (`WumpusKB`).
  [Repositorio](https://github.com/aimacode/aima-python). De `WumpusKB`
  esta página toma el axioma de estado sucesor del wumpus vivo, que usa
  junto con los del libro, y la negación explícita de las acciones no
  hechas, que en Prolog da la compleción del programa.

El código del capítulo es propio, escrito para el curso: ninguno de los
programas de esas fuentes se copió, y la enumeración de mundos
consistentes como método principal, la cueva de Yob jugada por un agente
y las mediciones no tienen equivalente en ellas.
