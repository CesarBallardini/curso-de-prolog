# Más allá de WARPLAN

Esta página continúa el [capítulo 71](index.md) después de la
[sección 71.6](comparacion.md#716-version-4-el-mundo-del-capitulo-41), con
la [sección 71.7](#717-mas-alla-de-warplan), que lo termina: tres partes
de sus fuentes que las cuatro versiones no cubren, los planes
condicionales que Warren agregó a WARPLAN en 1976, una de las mejoras que
su memo de 1974 propone en «Deficiencies of the system», y el mundo de las
llaves y las cajas del apéndice del mismo memo. Los ejemplos están en
`ejemplos/capitulo-71/`, con sus pruebas, y se ejecutan en una instalación
local: cargan `warplan.pl`.

## 71.7 Más allá de WARPLAN

Los **planes condicionales** de Warren (1976) examinan un hecho del mundo
y siguen por una rama u otra; `condicional.pl` construye una versión
simple, para un estado inicial que puede ser uno de varios. El **control
de ciclos** que el memo de 1974 propone entre sus mejoras vuelve finita
la búsqueda sin cota, pero en el segundo orden de la anomalía no la hace
practicable: `ciclos.pl` lo mide. Y el **mundo de las llaves y las
cajas** del apéndice del memo, `llaves.pl`, reproduce el plan de ocho
acciones que Warren publica, con dos versiones de la acción de llevar,
una por cada clase de destino.

### Planes condicionales

WARPLAN supone que el estado inicial se conoce entero. Cuando no se
conoce, un plan fijo puede servir en un estado y no en otro. Warren (1976)
extendió el planificador para generar **planes condicionales**: planes que
en un punto examinan un hecho del mundo y siguen por una rama u otra. La
versión de esta página es mucho más simple que la suya: recibe una lista
de estados iniciales posibles, examina los hechos solo antes de la primera
acción, y usa el planificador de la
[sección 71.4](index.md#714-version-2-warplan-insertar-la-accion-antes)
sin cambios.

El mundo `dudoso.pl` reexporta el de `cubos.pl` y agrega dos estados
iniciales que solo difieren en dónde está c: sobre a, como en la anomalía,
o sobre b.

<!-- ejemplo: capitulo-71/dudoso.pl predicado: dado/2 -->
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

<!-- ejemplo: capitulo-71/condicional.pl predicado: planificar_casos/5 distinguidor/3 -->
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

<!-- contexto: capitulo-71/condicional.pl -->
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

### Control de ciclos

Entre las deficiencias que Warren enumera en su memo están dos que el
[capítulo 71](index.md#714-version-2-warplan-insertar-la-accion-antes)
mide: la búsqueda en profundidad pura no termina en el segundo orden de
la anomalía, y nada impide intentar lograr una meta que ya se está
intentando lograr más arriba. La mejora que el memo propone es un control
automático de ciclos. `ciclos.pl` lo agrega a la búsqueda sin cota: cada
llamada recibe la **cadena** de metas que se están logrando por encima de
ella, y la cláusula que elige una acción no se aplica a una meta que es
una variante de una de la cadena:

<!-- ejemplo: capitulo-71/ciclos.pl predicado: resolver/8 -->
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

<!-- contexto: capitulo-71/ciclos.pl -->
```prolog
?- once(planificar_sin_ciclos(cubos, sussman, [sobre(a, b), sobre(b, c)], P)).
P = [mover(c, a, mesa), mover(b, mesa, c), mover(a, mesa, b)].

?- call_with_inference_limit(once(planificar_sin_ciclos(cubos, sussman, [sobre(b, c), sobre(a, b)], _)), 2000000, R).
R = inference_limit_exceeded.
```

La medición corrige la explicación de la
[sección 71.4](index.md#714-version-2-warplan-insertar-la-accion-antes):
la cadena «liberar c, poner algo sobre c» es una de las ramas infinitas,
pero cortarla no basta. La búsqueda sin cota recorre en profundidad un
espacio que, aun finito, crece de manera exponencial con la cantidad de
metas pendientes, y la cota con profundización sigue siendo lo que da un
plan en los dos órdenes.

### Las llaves y las cajas

El apéndice del memo de Warren prueba WARPLAN en una versión simplificada
de un problema de Donald Michie. Adentro hay cuatro lugares, la mesa, dos
cajas y la puerta; afuera, uno. La llave 1 está en la caja 1, la llave 2
en la caja 2 y un objeto rojo en la puerta. El robot puede ir a cualquier
lugar de adentro y llevar consigo un objeto, pero solo si es el único que
hay donde está, y solo puede sacar algo afuera si las dos llaves están en
la puerta. La meta es tener el objeto rojo afuera.

`llaves.pl` describe ese mundo con los siete predicados del
[capítulo 71](index.md#711-el-mundo-como-descripcion). Como en el memo,
llevar un objeto tiene dos versiones según lo que haya en el destino:
`llevar/3` a un lugar vacío, que queda con un solo objeto, y `juntar/4` a
un lugar que ya tiene uno. Una acción de WARPLAN tiene un solo juego de
precondiciones, y los efectos de llevar dependen del destino:

<!-- ejemplo: capitulo-71/llaves.pl predicado: puede/2 -->
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

<!-- ejemplo: capitulo-71/llaves.pl predicado: saca_el_rojo/1 -->
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

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `planificar/5` es `nondet` y da los planes de menor a mayor longitud, y `preservada/3` e `inconsistente/3` aclaran cómo tratan las variables libres |
    | C3 | el planificador no conoce el mundo: recibe su módulo y solo llama a los siete predicados de la descripción; el mismo código planifica en los cubos, en el robot y en los dos mundos del [capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) |
    | C4 | `preservada/3`, `inconsistente/3` y `es_prueba/2` trabajan sobre una copia dentro de `\+ \+`: no ligan nada ni dejan alternativas |
    | C7 | 92 pruebas en siete archivos, y 33 más sobre las soluciones; cada plan que se prueba pasa además por `logra/4`, que lo ejecuta por regresión desde el estado inicial |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio.

12. **(2)** Con `condicional.pl` y el mundo `dudoso.pl`, predecir el plan
    condicional para `[sobre(c, a)]` y para `[sobre(b, c)]` desde los
    estados `c_sobre_a` y `c_sobre_b`. Comprobarlo con
    `planificar_casos/5`, obtener con `ejecutar_casos/4` las acciones de
    cada rama y explicar por qué una de las ramas de la primera meta está
    vacía.

## Resumen

| | |
|---|---|
| **descripción del mundo** | siete predicados: lo que cada acción agrega, borra y exige, las combinaciones imposibles, los hechos que no cambian, las pruebas y el estado inicial |
| **regresión de un hecho** | vale después de un plan si la última acción lo agrega, o si vale antes y la acción no lo borra |
| **hecho protegido** | una meta lograda, que ninguna acción nueva puede borrar |
| **objeto desconocido** | una variable libre de un plan parcial, que se compara sobre una copia hecha con `numbervars/3` |
| **extensión, inserción** | la acción nueva va al final del plan, o antes de una acción que no borra la meta |
| **regresar los protegidos** | a través de una acción: se quitan los que la acción agrega y se agregan sus precondiciones |
| **intercalar** | poner una acción de una meta entre las acciones de otra; resuelve la anomalía de Sussman |
| `vale/4`, `preservada/3`, `logra/4` | lo que vale después de un plan, y la comprobación de un plan |
| `planificar/5` de `extension.pl` | la versión 1: extensión, metas protegidas y cota |
| `planificar/5` de `warplan.pl`, `regresar/4`, `planificar_sin_cota/4` | la versión 2, WARPLAN |
| `robot.pl` | la versión 3: el mundo del robot, con hechos deducidos |
| `pinza.pl`, `sin_pinza.pl`, `medios_fines/3` | la versión 4: los mundos del [capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md), traducidos |
| `planificar_casos/5`, `planificar_sin_ciclos/4`, `llaves.pl` | más allá de WARPLAN: planes condicionales, control de ciclos y el mundo de las llaves y las cajas |
| **[Patrón 69](../patrones.md#69-descripcion-del-mundo-como-parametro)** | descripción del mundo como parámetro |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| La planificación de tareas con duraciones y procesadores, como búsqueda de costo mínimo | [capítulo 73](../capitulo-73-proyecto-planificacion-tareas/index.md) |

## Referencias

- Feliks Kluźniak y Stanisław Szpakowicz, *Prolog for Programmers*,
  Academic Press, 1985 — capítulo «Two case studies», apartado «Planning».
  [Edición en línea](https://www.site.uottawa.ca/~szpak/pub/P4P/Prolog_for_Programmers_neat.pdf).
  Sus notas bibliográficas remiten a Warren (1976), *Generating
  Conditional Plans and Programs* (AISB, Edimburgo, 1976), la extensión a
  planes condicionales; sin edición en línea de acceso libre, el capítulo
  la conoce por esa nota, y la versión por casos de
  [Planes condicionales](#planes-condicionales) es propia.
- David H. D. Warren, *WARPLAN: a system for generating plans*, Memo 76
  del Department of Computational Logic, Universidad de Edimburgo, 1974 —
  apartados «The 3 blocks problem», «Specifying a problem»,
  «Implementation of the system», «Deficiencies of the system» y
  «Completeness and irredundancy».
  [Copia del Software Preservation Group](https://www.softwarepreservation.org/projects/prolog/edinburgh/doc/Warren-WARPLAN_A_System_for_Generating_Plans-1974_06.pdf/view).
  Esta página toma de su apartado «Deficiencies of the system» el control
  de ciclos y de su apéndice el problema de las llaves y las cajas, una
  simplificación que Warren hace de una prueba de Donald Michie (*On
  Machine Intelligence*, Edinburgh University Press, 1974), con su plan de
  ocho acciones.

El código del capítulo es propio, escrito para el curso: del libro se
toman las ideas y la estructura del algoritmo, no el código. La cota de
acciones con profundización, las listas de hechos en lugar de
conjunciones, las pruebas declaradas con `prueba/1`, la traducción de los
operadores del [capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) y las mediciones son del curso.
