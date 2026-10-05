# Más allá de WARPLAN

Esta página completa el [capítulo 70](index.md) con tres partes de sus
fuentes que las cuatro versiones no cubren: los planes condicionales que
Warren agregó a WARPLAN en 1976, una de las mejoras que su memo de 1974
propone en «Deficiencies of the system», y el mundo de las llaves y las
cajas del apéndice del mismo memo. Los ejemplos están en
`ejemplos/capitulo-70/`, con sus pruebas, y se ejecutan en una instalación
local: cargan `warplan.pl`.

## Planes condicionales

WARPLAN supone que el estado inicial se conoce entero. Cuando no se
conoce, un plan fijo puede servir en un estado y no en otro. Warren (1976)
extendió el planificador para generar **planes condicionales**: planes que
en un punto examinan un hecho del mundo y siguen por una rama u otra. La
versión de esta página es mucho más simple que la suya: recibe una lista
de estados iniciales posibles, examina los hechos solo antes de la primera
acción, y usa el planificador de la
[sección 70.4](index.md#704-version-2-warplan-insertar-la-accion-antes)
sin cambios.

El mundo `dudoso.pl` reexporta el de `cubos.pl` y agrega dos estados
iniciales que solo difieren en dónde está c: sobre a, como en la anomalía,
o sobre b.

<!-- ejemplo: capitulo-70/dudoso.pl predicado: dado/2 -->
```prolog
%!  dado(?Inicio, ?Hecho) is nondet.
%
%   Hecho vale en el estado inicial Inicio: los de cubos.pl, c_sobre_a y
%   c_sobre_b.
dado(Inicio, Hecho) :-
    cubos:dado(Inicio, Hecho).
dado(c_sobre_a, Hecho) :-
    cubos:dado(sussman, Hecho).
dado(c_sobre_b, Hecho) :-
    member(Hecho, [sobre(a, mesa), sobre(b, mesa), sobre(c, b), libre(a),
                   libre(c)]).
```

`planificar_casos/5` busca primero un plan para el primer estado y
comprueba con `logra/4` que sirve para todos. Si no sirve, elige un hecho
que vale en unos estados y no en otros, los separa en dos grupos y
planifica cada grupo por su lado:

<!-- ejemplo: capitulo-70/condicional.pl predicado: planificar_casos/5 distinguidor/3 -->
```prolog
%!  planificar_casos(+Mundo, +Inicios:list, +Metas:list, +Maximo:integer,
%!                   -Plan) is semidet.
%
%   Plan logra las Metas desde cada uno de los estados iniciales Inicios
%   del Mundo. Es una lista de acciones, o si(Hecho, PlanSi, PlanNo): un
%   examen de Hecho en el estado inicial, seguido de PlanSi si vale y de
%   PlanNo si no vale. Cada lista tiene a lo sumo Maximo acciones.
planificar_casos(Mundo, [Inicio|Inicios], Metas, Maximo, Plan) :-
    once(planificar(Mundo, Inicio, Metas, Maximo, Plan0)),
    forall(member(I, Inicios), logra(Mundo, I, Plan0, Metas)),
    !,
    Plan = Plan0.
planificar_casos(Mundo, Inicios, Metas, Maximo,
                 si(Hecho, PlanSi, PlanNo)) :-
    distinguidor(Mundo, Inicios, Hecho),
    partition(vale_al_inicio(Mundo, Hecho), Inicios, Si, No),
    planificar_casos(Mundo, Si, Metas, Maximo, PlanSi),
    planificar_casos(Mundo, No, Metas, Maximo, PlanNo).

%!  distinguidor(+Mundo, +Inicios:list, -Hecho) is semidet.
%
%   Hecho vale en algunos de los estados Inicios y no en otros: el primero
%   en el orden estándar de términos.
distinguidor(Mundo, Inicios, Hecho) :-
    findall(H, ( member(I, Inicios), Mundo:dado(I, H) ), Hs0),
    sort(Hs0, Hs),
    member(Hecho, Hs),
    \+ forall(member(I, Inicios), Mundo:dado(I, Hecho)),
    !.
```

El hecho que separa los estados es el primero en el orden estándar de
términos, `libre(a)`. Para liberar a, si a ya está libre no hace falta
nada; si no, hay que bajar c. Para la anomalía, las dos ramas difieren en
la primera acción. Para `libre(c)` un mismo plan, vacío, sirve en los dos
estados, y el plan no examina nada:

<!-- contexto: capitulo-70/condicional.pl -->
```prolog
?- planificar_casos(dudoso, [c_sobre_a, c_sobre_b], [libre(a)], 4, P).
P = si(libre(a), [], [mover(c, a, mesa)]).

?- planificar_casos(dudoso, [c_sobre_a, c_sobre_b], [sobre(a, b), sobre(b, c)], 6, P).
P = si(libre(a), [mover(c, b, mesa), mover(b, mesa, c), mover(a, mesa, b)], [mover(c, a, mesa), mover(b, mesa, c), mover(a, mesa, b)]).

?- planificar_casos(dudoso, [c_sobre_a, c_sobre_b], [libre(c)], 4, P).
P = [].
```

`ejecutar_casos/4` recorre el plan condicional para un estado inicial y
da la lista de acciones que ejecuta; las pruebas comprueban con `logra/4`
que la rama de cada estado logra las metas. Lo que esta versión no hace,
y la de Warren sí, es examinar un hecho **en medio** del plan, después de
acciones cuyo resultado no se conoce de antemano; para eso la acción de
examinar tiene que ser una acción más del mundo, con su propia regresión.

## Control de ciclos

Entre las deficiencias que Warren enumera en su memo están dos que el
[capítulo 70](index.md#704-version-2-warplan-insertar-la-accion-antes)
mide: la búsqueda en profundidad pura no termina en el segundo orden de
la anomalía, y nada impide intentar lograr una meta que ya se está
intentando lograr más arriba. La mejora que el memo propone es un control
automático de ciclos. `ciclos.pl` lo agrega a la búsqueda sin cota: cada
llamada recibe la **cadena** de metas que se están logrando por encima de
ella, y la cláusula que elige una acción no se aplica a una meta que es
una variante de una de la cadena:

<!-- ejemplo: capitulo-70/ciclos.pl predicado: resolver/8 -->
```prolog
%!  resolver(+Mundo, +Inicio, +Meta, +Cadena:list, +Protegidas0:list,
%!           -Protegidas:list, +Hechas0:list, -Hechas:list) is nondet.
%
%   Como resolver/9 de warplan.pl. La última cláusula, la que elige una
%   acción, no se aplica si Meta es una variante de una meta de la Cadena.
resolver(Mundo, _, Meta, _, Ps, Ps, Hechas, Hechas) :-
    Mundo:siempre(Meta).
resolver(Mundo, _, Meta, _, Ps, Ps, Hechas, Hechas) :-
    es_prueba(Mundo, Meta),
    call(Mundo:Meta).
resolver(Mundo, Inicio, Meta, _, Ps0, Ps, Hechas, Hechas) :-
    \+ es_prueba(Mundo, Meta),
    vale(Mundo, Inicio, Meta, Hechas),
    proteger(Meta, Ps0, Ps).
resolver(Mundo, Inicio, Meta, Cadena, Ps, [Meta|Ps], Hechas0, Hechas) :-
    \+ es_prueba(Mundo, Meta),
    \+ ( member(M, Cadena), M =@= Meta ),
    Mundo:agrega(Meta, Accion),
    lograr(Mundo, Inicio, Meta, Accion, [Meta|Cadena], Ps, Hechas0, Hechas).
```

Como hay una cantidad finita de metas distintas salvo el nombre de las
variables, la cadena no puede crecer sin límite, y el árbol de búsqueda
queda finito. Pero finito no quiere decir chico. En el primer orden de la
anomalía, en la figura del libro y en los ejemplos del robot el control
cuesta casi lo mismo que la búsqueda sin él; en el segundo orden, después
de dos millones de inferencias todavía no hay plan:

<!-- contexto: capitulo-70/ciclos.pl -->
```prolog
?- once(planificar_sin_ciclos(cubos, sussman, [sobre(a, b), sobre(b, c)], P)).
P = [mover(c, a, mesa), mover(b, mesa, c), mover(a, mesa, b)].

?- call_with_inference_limit(once(planificar_sin_ciclos(cubos, sussman, [sobre(b, c), sobre(a, b)], _)), 2000000, R).
R = inference_limit_exceeded.
```

La medición corrige la explicación de la
[sección 70.4](index.md#704-version-2-warplan-insertar-la-accion-antes):
la cadena «liberar c, poner algo sobre c» es una de las ramas infinitas,
pero cortarla no basta. La búsqueda sin cota recorre en profundidad un
espacio que, aun finito, crece de manera exponencial con la cantidad de
metas pendientes, y la cota con profundización sigue siendo lo que da un
plan en los dos órdenes.

## Las llaves y las cajas

El apéndice del memo de Warren prueba WARPLAN en una versión simplificada
de un problema de Donald Michie. Adentro hay cuatro lugares, la mesa, dos
cajas y la puerta; afuera, uno. La llave 1 está en la caja 1, la llave 2
en la caja 2 y un objeto rojo en la puerta. El robot puede ir a cualquier
lugar de adentro y llevar consigo un objeto, pero solo si es el único que
hay donde está, y solo puede sacar algo afuera si las dos llaves están en
la puerta. La meta es tener el objeto rojo afuera.

`llaves.pl` describe ese mundo con los siete predicados del
[capítulo 70](index.md#701-el-mundo-como-descripcion). Como en el memo,
llevar un objeto tiene dos versiones según lo que haya en el destino:
`llevar/3` a un lugar vacío, que queda con un solo objeto, y `juntar/4` a
un lugar que ya tiene uno. Una acción de WARPLAN tiene un solo juego de
precondiciones, y los efectos de llevar dependen del destino:

<!-- ejemplo: capitulo-70/llaves.pl predicado: puede/2 -->
```prolog
%!  puede(?Accion, -Precondiciones:list) is nondet.
%
%   Accion se puede ejecutar donde valen las Precondiciones. Ir a un lugar
%   no exige nada: el robot puede ir a cualquier lugar de adentro.
puede(ir(L), [adentro(L)]).
puede(llevar(X, L1, L2), [vacio(L2), adentro(L2), solo(X, L1), robot(L1),
                          distinto(L1, L2)]).
puede(juntar(X, L1, L2, Y), [solo(Y, L2), solo(X, L1), robot(L1),
                             distinto(L1, L2)]).
puede(sacar(X, L), [esta(llave1, puerta), esta(llave2, puerta), solo(X, L),
                    robot(L)]).
```

En el estado inicial el robot no está en ningún lugar conocido, y el plan
empieza por ir a alguno. Con la cota, WARPLAN encuentra el plan de ocho
acciones que publica el memo: llevar el objeto rojo a la mesa para dejar
la puerta libre, llevar las dos llaves a la puerta y sacar el objeto rojo
desde la mesa. La búsqueda cuesta 75 millones de inferencias y unos nueve
segundos en esta máquina; una prueba de `llaves.plt` hace la búsqueda
entera. Sin la cota, la búsqueda en profundidad agota la pila. Warren ya
anota que, con su búsqueda en profundidad, llegar a una solución dependía
del orden de las precondiciones; con los órdenes que se probaron en
`llaves.pl`, el costo de la búsqueda con cota va de 65 a 440 millones de
inferencias.

`plan_de_warren/1` da ese plan, y `saca_el_rojo/1` lo comprueba con
`logra/4`; sin llevar antes las llaves a la puerta, el objeto no sale:

<!-- ejemplo: capitulo-70/llaves.pl predicado: saca_el_rojo/1 -->
```prolog
%!  saca_el_rojo(+Plan:list) is semidet.
%
%   Plan, ejecutado desde el estado inicial michie, deja el objeto rojo
%   afuera: cada acción es ejecutable y la meta vale al final.
saca_el_rojo(Plan) :-
    logra(llaves, michie, Plan, [esta(rojo, afuera)]).
```

```prolog
?- plan_de_warren(P), saca_el_rojo(P).
P = [ir(puerta), llevar(rojo, puerta, mesa), ir(caja1), llevar(llave1, caja1, puerta), ir(caja2), juntar(llave2, caja2, puerta, llave1), ir(mesa), sacar(rojo, mesa)].

?- saca_el_rojo([ir(puerta), llevar(rojo, puerta, mesa), sacar(rojo, mesa)]).
false.
```
