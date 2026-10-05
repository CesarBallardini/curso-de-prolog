# Soluciones del capítulo 70 — Proyecto: planificación por regresión

Las soluciones que piden código están en `ejemplos/capitulo-70/`:
`soluciones_cubos.pl` (ejercicios 2, 9 y 11), `soluciones_robot.pl`
(ejercicios 4 y 5), `soluciones_pinza.pl` (ejercicio 7) y `soluciones.pl`
(ejercicios 6 y 8), que reexporta `warplan.pl` y `regresion.pl` y carga
los otros tres. Cada archivo tiene sus pruebas en el `.plt` del mismo
nombre. Los mundos nuevos son módulos que reexportan el mundo del que
parten y cambian solo lo que el ejercicio pide. Las inferencias se
midieron en esta máquina, con las bibliotecas ya cargadas.

## Ejercicio 1

<!-- contexto: capitulo-70/soluciones.pl -->
```prolog
?- vale(cubos, sussman, sobre(X, mesa), [mover(c, a, b)]).
X = a ;
X = b ;
false.

?- preservada(cubos, sobre(a, mesa), mover(a, mesa, W)).
false.

?- preservada(cubos, libre(c), mover(b, mesa, W)).
true.

?- planificar(cubos, sussman, [libre(a)], 1, Plan).
Plan = [mover(c, a, mesa)] ;
Plan = [mover(c, a, b)] ;
false.
```

Después de mover c a b, siguen sobre la mesa a y b: la acción solo borra
lo que está debajo de c. En la segunda consulta, mover a borra
`sobre(a, mesa)` sea cual sea el destino. En la tercera, el destino
desconocido W se toma como un objeto distinto de c, y la respuesta es
optimista: con W ligada a c, `libre(c)` se borraría, y por eso `lograr/8`
repite la prueba después de planificar las precondiciones. En la cuarta,
las dos acciones de un paso que liberan a mueven c; `mover(c, a, mesa)`
sale primero porque la cláusula del movimiento a la mesa es la primera
de `puede/2`.

## Ejercicio 2

El mundo `cubos2` reexporta el de `cubos.pl` y define otro `dado/2`, que
incluye los estados de `cubos.pl` y agrega `torre` y el `cuatro` del
ejercicio 9:

<!-- ejemplo: capitulo-70/soluciones_cubos.pl predicado: dado/2 -->
```prolog
%!  dado(?Inicio, ?Hecho) is nondet.
%
%   Hecho vale en el estado inicial Inicio: los de cubos.pl, torre, con a
%   sobre b sobre c, y cuatro, con d sobre c sobre b sobre a.
dado(Inicio, Hecho) :-
    cubos:dado(Inicio, Hecho).
dado(torre, Hecho) :-
    member(Hecho, [sobre(a, b), sobre(b, c), sobre(c, mesa), libre(a)]).
dado(cuatro, Hecho) :-
    member(Hecho, [sobre(d, c), sobre(c, b), sobre(b, a), sobre(a, mesa),
                   libre(d)]).
```

```prolog
?- once(extension:planificar(cubos2, torre, [sobre(c, b), sobre(b, a)], 6, Plan)).
Plan = [mover(a, b, mesa), mover(b, c, a), mover(c, mesa, b)].

?- once(planificar(cubos2, torre, [sobre(c, b), sobre(b, a)], 6, Plan)).
Plan = [mover(a, b, mesa), mover(b, c, a), mover(c, mesa, b)].

?- once(planificar_sin_cota(cubos2, torre, [sobre(c, b), sobre(b, a)], Plan)).
Plan = [mover(a, b, mesa), mover(b, c, mesa), mover(b, mesa, a), mover(c, mesa, b)].
```

Las dos versiones con cota dan el plan de tres acciones; esta vez no hace
falta intercalar, porque lograr `sobre(c, b)` libera de paso a y b. La
búsqueda sin cota da cuatro. Para `sobre(c, b)` necesita `libre(b)`, que
logra con `mover(a, b, mesa)`, y `libre(c)`, que logra moviendo b. El
destino de b queda libre en `mover(b, c, W)`, y la primera cláusula de
`puede/2` lo liga a la mesa: `mover(b, c, mesa)`. Después, para
`sobre(b, a)`, hace falta otra acción que lleve b de la mesa a a, y la
versión 2 la inserta antes de `mover(c, mesa, b)`. Con la cota, las
longitudes se prueban de menor a mayor, y con tres acciones el único
camino es que el mismo movimiento que libera c deje b sobre a.

## Ejercicio 3

Con las metas `[sobre(b, c), sobre(a, b)]`, la primera se logra con
`mover(b, mesa, c)`: c y b están libres. El plan es
`[mover(b, mesa, c)]` y los protegidos son `sobre(b, c)`. Para
`sobre(a, b)` la acción es `mover(a, mesa, b)`, con la precondición
`libre(a)`; liberar a exige mover c, con `mover(c, a, W)`, cuya
precondición `libre(c)` ya no vale, porque b está sobre c, y liberar c
exige mover b, que borra `sobre(b, c)`, protegida. Como la versión 1 solo
agrega acciones al final, no hay plan de tres. El de cuatro es:

```prolog
?- once(extension:planificar(cubos, sussman, [sobre(b, c), sobre(a, b)], 8, Plan)).
Plan = [mover(c, a, b), mover(c, b, mesa), mover(b, mesa, c), mover(a, mesa, b)].
```

Con la cota de cuatro, que hay que gastar entera, el primer plan que la
versión 1 encuentra no toma `libre(b)`, precondición de
`mover(b, mesa, c)`, como un hecho que ya vale, sino que lo **logra**: la
cuarta cláusula de `resolver/9` también se prueba para un hecho que ya
vale. Para liberar b
mueve c de b a la mesa, lo que exige antes poner c sobre b. El rodeo saca
c de encima de a, y cuando llega `sobre(a, b)`, a ya está libre.

## Ejercicio 4

<!-- contexto: capitulo-70/soluciones.pl -->
```prolog
?- planificar(robot, strips1, [en(robot, punto(5))], 6, Plan), memberchk(empujar(_, robot, _), Plan).
Plan = [acercarse(caja(1), habitacion(1)), empujar(caja(1), robot, habitacion(1)), subir(caja(1)), bajar(caja(1)), ir_a(punto(5), habitacion(1))] ;
Plan = [acercarse(caja(2), habitacion(1)), empujar(caja(2), robot, habitacion(1)), subir(caja(2)), bajar(caja(2)), ir_a(punto(5), habitacion(1))] ;
Plan = [acercarse(caja(3), habitacion(1)), empujar(caja(3), robot, habitacion(1)), subir(caja(3)), bajar(caja(3)), ir_a(punto(5), habitacion(1))] ;
Plan = [acercarse(caja(1), habitacion(1)), empujar(caja(1), robot, habitacion(1)), empujar(caja(1), robot, habitacion(1)), subir(caja(1)), bajar(caja(1)), ir_a(punto(5), habitacion(1))] ;
Plan = [acercarse(caja(2), habitacion(1)), empujar(caja(2), robot, habitacion(1)), empujar(caja(2), robot, habitacion(1)), subir(caja(2)), bajar(caja(2)), ir_a(punto(5), habitacion(1))] ;
Plan = [acercarse(caja(3), habitacion(1)), empujar(caja(3), robot, habitacion(1)), empujar(caja(3), robot, habitacion(1)), subir(caja(3)), bajar(caja(3)), ir_a(punto(5), habitacion(1))] ;
false.

?- robot:puede(empujar(caja(1), robot, habitacion(1)), Pre).
Pre = [empujable(caja(1)), en_habitacion(robot, habitacion(1)), en_habitacion(caja(1), habitacion(1)), junto(robot, caja(1)), en_el_piso].
```

La precondición `en_habitacion(Y, R)` de `empujar/3` se cumple con
Y = robot, porque el robot está en la habitación. Seis planes lo usan:
para gastar la cota exacta, el planificador logra `junto(robot, caja(N))`,
que ya valía, empujando la caja hacia el robot. La corrección agrega la
prueba `distinto(Y, robot)` después de `en_habitacion(Y, R)`, que liga Y.
El mundo `robot2` define su propio `puede/2`, que usa el de `robot.pl`
para las demás acciones:

<!-- ejemplo: capitulo-70/soluciones_robot.pl predicado: puede/2 -->
```prolog
%!  puede(?Accion, -Precondiciones:list) is nondet.
%
%   Las de robot.pl, con empujar/3 restringida a un Y que no es el robot,
%   y las de empujar_por/4.
puede(empujar(X, Y, R), [empujable(X), en_habitacion(Y, R),
                         distinto(Y, robot), en_habitacion(X, R),
                         junto(robot, X), en_el_piso]).
puede(Accion, Pre) :-
    robot:puede(Accion, Pre),
    Accion \= empujar(_, _, _).
puede(empujar_por(X, D, R1, R2), [empujable(X), conecta(D, R1, R2),
                                  en_habitacion(X, R1),
                                  en_habitacion(robot, R1),
                                  junto(X, D), junto(robot, X),
                                  en_el_piso]).
```

```prolog
?- planificar(robot2, strips1, [en(robot, punto(5))], 6, Plan), memberchk(empujar(_, robot, _), Plan).
false.
```

## Ejercicio 5

La acción nueva agrega que la caja y el robot están en la habitación de
destino, y que el robot sigue junto a la caja; borra las habitaciones,
los puntos y lo que tenían al lado, salvo estar uno junto al otro.
`agrega/2` y `borra/2` de `robot2` llaman a los de `robot.pl` y agregan
esas cláusulas:

<!-- ejemplo: capitulo-70/soluciones_robot.pl predicado: agrega/2 borra/2 -->
```prolog
%!  agrega(?Hecho, ?Accion) is nondet.
%
%   Las de robot.pl, y las de empujar_por/4: la caja y el robot quedan en
%   la habitación R2, uno junto al otro.
agrega(Hecho, Accion) :-
    robot:agrega(Hecho, Accion).
agrega(en_habitacion(X, R2), empujar_por(X, _, _, R2)).
agrega(en_habitacion(robot, R2), empujar_por(_, _, _, R2)).
agrega(junto(robot, X), empujar_por(X, _, _, _)).

%!  borra(?Hecho, ?Accion) is nondet.
%
%   Las de robot.pl, y las de empujar_por/4: la caja y el robot dejan la
%   habitación de la que salen, su punto y lo que tenían al lado, salvo
%   estar uno junto al otro.
%   La cláusula de junto/2 compara con ==: el planificador la llama sobre
%   una copia sin variables, y un hecho junto(X, Y) con X o Y libres no da
%   respuestas.
borra(Hecho, Accion) :-
    robot:borra(Hecho, Accion).
borra(en_habitacion(X, _), empujar_por(X, _, _, _)).
borra(en_habitacion(robot, _), empujar_por(_, _, _, _)).
borra(en(X, _), empujar_por(X, _, _, _)).
borra(en(robot, _), empujar_por(_, _, _, _)).
borra(junto(X, Y), empujar_por(Z, _, _, _)) :-
    (   X == Z
    ;   Y == Z
    ;   X == robot
    ;   Y == robot
    ),
    \+ ( X == robot, Y == Z ),
    \+ ( X == Z, Y == robot ).
```

La precondición es que la caja esté junto a la puerta, además de que el
robot esté junto a la caja (está en el `puede/2` del ejercicio 4). La
primera versión de la solución pedía que el robot estuviera junto a la
caja y junto a la puerta a la vez, y no había plan: ninguna acción deja al
robot junto a dos cosas.

```prolog
?- once(planificar_sin_cota(robot2, strips1, [en_habitacion(caja(2), habitacion(2))], Plan)).
Plan = [acercarse(caja(2), habitacion(1)), empujar(caja(2), puerta(1), habitacion(1)), empujar_por(caja(2), puerta(1), habitacion(1), habitacion(5)), empujar(caja(2), puerta(2), habitacion(5)), empujar_por(caja(2), puerta(2), habitacion(5), habitacion(2))].
```

`planificar/5` con máximo 12 da el mismo plan de cinco acciones con 7 242
inferencias; sin cota, 1 114.

## Ejercicio 6

<!-- ejemplo: capitulo-70/soluciones.pl predicado: planificar_techo/5 -->
```prolog
%!  planificar_techo(+Mundo, +Inicio, +Metas:list, +Maximo:integer,
%!                   -Plan:list) is nondet.
%
%   Plan tiene a lo sumo Maximo acciones y logra las Metas. La búsqueda es
%   una sola, en profundidad, con Maximo como techo: termina, pero el
%   primer plan no es necesariamente el más corto.
planificar_techo(Mundo, Inicio, Metas, Maximo, Plan) :-
    planear(Mundo, Inicio, Metas, [], _, [], Hechas, Maximo, _),
    reverse(Hechas, Plan).
```

| Metas | `planificar/5` | `planificar_techo/5` |
|---|---|---|
| anomalía, `[sobre(b, c), sobre(a, b)]`, techo 6 | 6 789 | 267 688 |
| la misma, techo 12 | 6 789 | sin respuesta en un minuto |
| robot, luz y punto 6, techo 12 | 607 229 | 1 505 |

Los tres planes, cuando llegan, son iguales a los de `planificar/5`. En la
anomalía, la búsqueda en profundidad entra en la cadena de «liberar c,
poner algo sobre c» y la recorre hasta el techo antes de volver; cuanto
más alto el techo, más hondo baja. En el robot, la primera rama es la
buena, y la profundización es la que paga de más: recorre sin éxito cada
cota menor que 10. El techo sirve cuando se conoce una cota ajustada, y la
profundización cuando no.

## Ejercicio 7

<!-- ejemplo: capitulo-70/soluciones_pinza.pl predicado: imposible/1 -->
```prolog
% imposible(Hs): los hechos de Hs no pueden valer juntos.
imposible([sostiene(_), mano_vacia]).
imposible([sostiene(X), sostiene(Y), distinto(X, Y)]).
imposible([sostiene(X), sobre(X, _)]).
imposible([sobre(X, Y), sobre(X, Z), distinto(Y, Z)]).
imposible([sobre(_, Y), libre(Y)]).
```

| Metas | sin `imposible/1` | con `imposible/1` |
|---|---|---|
| `[sobre(a, b), sobre(b, c)]` | 115 764 | 202 929 |
| `[sobre(b, c), sobre(a, b)]` | 276 542 | 236 055 |

El plan es el mismo. La prueba de consistencia se hace en cada acción que
se intenta, y en este mundo casi nunca descarta algo que la búsqueda no
descartaría enseguida por otro camino: en el primer orden cuesta más de lo
que ahorra, en el segundo ahorra un poco. Las combinaciones imposibles
valen la pena cuando las precondiciones pueden contradecirse con los
protegidos lejos de la raíz, antes de una búsqueda larga.

## Ejercicio 8

<!-- ejemplo: capitulo-70/soluciones.pl predicado: estado_final/4 -->
```prolog
%!  estado_final(+Mundo, +Inicio, +Plan:list, -Estado:list) is det.
%
%   Estado es el conjunto ordenado de los hechos que valen después de
%   ejecutar Plan, en el orden en que se ejecuta, desde Inicio.
estado_final(Mundo, Inicio, Plan, Estado) :-
    reverse(Plan, Hechas),
    findall(H, vale(Mundo, Inicio, H, Hechas), Hs),
    sort(Hs, Estado).
```

```prolog
?- estado_final(cubos, sussman, [mover(c, a, mesa), mover(b, mesa, c), mover(a, mesa, b)], Estado).
Estado = [libre(a), sobre(a, b), sobre(b, c), sobre(c, mesa)].
```

En el robot, después de `ir_a(punto(4), habitacion(1))`, el estado tiene
diez hechos: el robot en el punto 4, las tres cajas en sus puntos y en la
habitación 1, el robot en la habitación 1 y en el piso, y el interruptor
apagado. Los hechos de `siempre/1` no aparecen, porque `vale/4` no los
consulta: son parte del mundo, no del estado.

## Ejercicio 9

```prolog
?- once(planificar(cubos2, cuatro, [sobre(a, b), sobre(b, c), sobre(c, d)], 8, Plan)).
Plan = [mover(d, c, mesa), mover(c, b, d), mover(b, a, c), mover(a, mesa, b)].

?- once(planificar_sin_cota(cubos2, cuatro, [sobre(a, b), sobre(b, c), sobre(c, d)], Plan)).
Plan = [mover(d, c, mesa), mover(c, b, mesa), mover(b, a, mesa), mover(c, mesa, d), mover(b, mesa, c), mover(a, mesa, b)].
```

| Metas | `planificar/5` | `planificar_sin_cota/4` |
|---|---|---|
| `[sobre(a, b), sobre(b, c), sobre(c, d)]` | 4 acciones, 24 348 | 6 acciones, 4 623 |
| `[sobre(c, d), sobre(b, c), sobre(a, b)]` | 4 acciones, 20 049 | 4 acciones, 2 860 |

En el primer orden, la búsqueda sin cota lleva cada cubo a la mesa, como
en el ejercicio 2, y después lo apila: seis acciones. Con la cota, el
plan de cuatro lleva cada cubo directamente a su destino. En el orden
inverso, la primera meta que se logra es la de abajo, y la búsqueda sin
cota encuentra también el plan de cuatro. La profundización cuesta entre
cinco y siete veces más, y lo que compra es el plan más corto en los dos
órdenes. En el robot, los planes de la búsqueda sin cota ya eran los más
cortos, y la profundización solo agregaba costo.

## Ejercicio 10

| Orden de las metas | `planificar/5` | `planificar_sin_cota/4` |
|---|---|---|
| punto 6, luz | 144 695 | 6 292 |
| luz, punto 6 | 607 229 | 1 567 |

Los dos órdenes dan el mismo plan de diez acciones: primero encender la
luz y después ir al punto 6. Con el punto 6 primero, el planificador llega
allí, y las acciones de la luz no pueden ir al final: volver a la
habitación 1 borraría `en(robot, punto(6))`, protegida. Las inserta antes
de todo el camino, y cada paso hacia atrás regresa los protegidos a
través de una acción. Sin cota, eso hace el primer orden cuatro veces más
caro. Con la cota, el orden se invierte: el costo lo deciden las cotas 0
a 9, que fallan, y el tamaño de lo que recorren depende de qué meta se
resuelve primero, no del plan que se encuentra al final.

## Ejercicio 11

<!-- contexto: capitulo-70/soluciones.pl -->
```prolog
?- planificar(cubos, sussman, [sobre(X, b), sobre(b, X)], 4, Plan).
false.

?- planificar(cubos2, sussman, [sobre(X, b), sobre(b, X)], 4, Plan).
false.
```

Dos cubos no pueden estar cada uno sobre el otro, pero `cubos.pl` no lo
declara: la primera consulta falla después de recorrer todos los planes de
hasta cuatro acciones, con 182 484 inferencias. `cubos2` agrega la
combinación, y la segunda falla en la prueba de consistencia de
`planificar/5`, antes de buscar, con 332:

<!-- ejemplo: capitulo-70/soluciones_cubos.pl predicado: imposible/1 -->
```prolog
%!  imposible(?Hechos:list) is nondet.
%
%   Las combinaciones de cubos.pl, y dos cubos cada uno sobre el otro.
imposible(Hechos) :-
    cubos:imposible(Hechos).
imposible([sobre(X, Y), sobre(Y, X)]).
```

`inconsistente/3` hace la prueba sobre una copia con `numbervars/3`: X
se convierte en un objeto desconocido, el mismo en las dos metas, y la
combinación `[sobre(X, Y), sobre(Y, X)]` unifica con las dos.

## Ejercicio 12

<!-- contexto: capitulo-70/condicional.pl -->
```prolog
?- planificar_casos(dudoso, [c_sobre_a, c_sobre_b], [sobre(c, a)], 4, P).
P = si(libre(a), [mover(c, b, a)], []).

?- planificar_casos(dudoso, [c_sobre_a, c_sobre_b], [sobre(b, c)], 4, P), ejecutar_casos(dudoso, c_sobre_b, P, A).
P = si(libre(a), [mover(c, b, mesa), mover(b, mesa, c)], [mover(b, mesa, c)]),
A = [mover(c, b, mesa), mover(b, mesa, c)].
```

El hecho que separa los dos estados es `libre(a)`, el primero en el orden
estándar de términos entre los que valen en uno y no en el otro. Para
`sobre(c, a)`, la rama de `c_sobre_a` está vacía porque la meta ya vale en
ese estado: `resolver/9` la encuentra con `vale/4` y no agrega ninguna
acción. En `c_sobre_b`, c está libre y se mueve de b a a con una acción.
Para `sobre(b, c)`, en `c_sobre_b` hay que bajar c antes de mover b, y en
`c_sobre_a` b y c están libres desde el principio.
