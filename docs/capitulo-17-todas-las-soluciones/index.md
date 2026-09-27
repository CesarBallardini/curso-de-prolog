# Capítulo 17 — Todas las soluciones

Hasta aquí, Prolog entregó las respuestas de una consulta de a una: el toplevel
las muestra con `;`, y un programa las recorre volviendo atrás. Muchas preguntas
de un programa real no son sobre una respuesta sino sobre **todas**: cuántos
hijos tiene una persona, cuál es la mayor edad, qué alumnos están inscriptos en
una materia, cuál es el promedio de sus notas. La parte I las dejó pendientes en
varios capítulos, porque con sus herramientas no se podían escribir sin repetir
los datos en una lista.

Este capítulo presenta los predicados que reúnen las respuestas de un objetivo
—`findall/3`, `bagof/3`, `setof/3`—, los que calculan un valor sobre ellas sin
reunirlas —`aggregate_all/3`—, el que comprueba que todas cumplen una condición
—`forall/2`— y los que las ordenan o las limitan. El proyecto los usa para sus
informes, y el Buscaminas cuenta las minas alrededor de una celda.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- reunir las respuestas de un objetivo en una lista con `findall/3`, `bagof/3` y
  `setof/3`, y elegir entre los tres, o entre `setof/3` y `findall/3` seguido
  de `sort/2`;
- explicar qué hacen `bagof/3` y `setof/3` con las variables libres, y usar `^`;
- predecir qué responde cada predicado cuando el objetivo no tiene respuestas;
- contar, sumar y obtener el máximo con `aggregate_all/3`, o el de una lista
  ya reunida con `max_member/2`, y comprobar una condición sobre todas las
  respuestas con `forall/2`;
- ordenar y limitar las respuestas de un objetivo con `order_by/2` y `limit/2`.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **0:54 h**.
    Resolver los 7 ejercicios marcados con ★: **2:11 h**.
    Resolver los 16 ejercicios del final: **5:03 h**.

## 17.1 De una respuesta por vez a todas juntas

El [capítulo 3](../capitulo-03-reglas-y-conjunciones/index.md) mostró que `es_padre(Quien)` responde juan dos veces: hay dos
demostraciones de la misma conclusión. El [capítulo 6](../capitulo-06-recursion/index.md) preguntó cuántos hijos
tiene una persona y no pudo responder: los hijos no forman una secuencia que una
recursión pueda recorrer. El [capítulo 10](../capitulo-10-negacion-como-falla/index.md) escribió `no_tiene_hijos/1` sin `\+` a
costa de repetir los datos en una lista.

Las tres preguntas tienen la misma forma: requieren el **conjunto** de las
respuestas de un objetivo, no cada respuesta por separado. Los predicados de
este capítulo reciben un objetivo, obtienen todas sus respuestas —volviendo
atrás internamente, como el toplevel cuando se presiona `;`— y las entregan
juntas.

## 17.2 `findall/3`

`findall(Plantilla, Objetivo, Lista)` ejecuta `Objetivo` hasta agotar sus
respuestas, y por cada una agrega a `Lista` una copia de `Plantilla` con los
valores de esa respuesta:

<!-- ejemplo: capitulo-17/todas.pl predicado: hijos_de/2 cuantos_hijos/2 consulta: hijos_de(juan, Hijos). -->
```prolog
%!  hijos_de(+P, -Hijos:list) is det.
%
%   Hijos es la lista de los hijos de P, en el orden de los hechos; la lista
%   vacía si P no tiene hijos.
hijos_de(P, Hijos) :-
    findall(H, padre(P, H), Hijos).

%!  cuantos_hijos(+P, -N:integer) is det.
%
%   N es la cantidad de hijos de P.
cuantos_hijos(P, N) :-
    hijos_de(P, Hijos),
    length(Hijos, N).
```

```prolog
?- hijos_de(juan, Hijos).
Hijos = [ana, pedro].

?- hijos_de(ana, Hijos).
Hijos = [].

?- cuantos_hijos(pedro, N).
N = 2.
```

La lista respeta el orden de las respuestas, que es el orden de los hechos.
Cuando el objetivo no tiene ninguna, la lista es vacía: `findall/3` siempre se
cumple, exactamente una vez, y por eso `hijos_de/2` es `det`. `cuantos_hijos/2`,
la pregunta del [capítulo 6](../capitulo-06-recursion/index.md), es la longitud de esa lista.

La plantilla puede ser cualquier término: `findall(P-H, padre(P, H), Pares)`
reúne pares, y `findall(H, (padre(P, H), P \== juan), L)` reúne con un
objetivo compuesto, entre paréntesis.

## 17.3 `bagof/3`, `setof/3` y `^`

`bagof/3` reúne como `findall/3`, con una diferencia en el tratamiento de las
variables que aparecen en el objetivo y no en la plantilla. `findall/3` las
ignora: reúne todas las respuestas en una lista. `bagof/3` **agrupa** por ellas:
da una lista por cada valor, como respuestas distintas.

<!-- ejemplo: capitulo-17/todas.pl predicado: hijos_agrupados/2 padres/1 consulta: hijos_agrupados(P, Hijos). -->
```prolog
%!  hijos_agrupados(?P, -Hijos:list) is nondet.
%
%   Hijos es la lista de los hijos de P, para cada P que tiene hijos: una
%   respuesta por padre.
hijos_agrupados(P, Hijos) :-
    bagof(H, padre(P, H), Hijos).

%!  padres(-Padres:list) is semidet.
%
%   Padres es la lista ordenada y sin repetidos de las personas que tienen
%   algún hijo. H^ indica que el hijo no agrupa: hay una sola lista.
padres(Padres) :-
    setof(P, H^padre(P, H), Padres).
```

```prolog
?- hijos_agrupados(P, Hijos).
P = juan,
Hijos = [ana, pedro] ;
P = pedro,
Hijos = [luis, eva].
```

En `bagof(H, padre(P, H), Hijos)`, `P` aparece en el objetivo y no en la
plantilla: `bagof/3` responde una vez por cada padre, con la lista de sus hijos.
Para que una variable no agrupe, se la marca con `^`: `H^padre(P, H)` se lee
«existe un H tal que `padre(P, H)`», y `H` deja de dividir las respuestas.

`setof/3` es `bagof/3` con la lista **ordenada y sin repetidos**. Es la
respuesta a los duplicados del [capítulo 3](../capitulo-03-reglas-y-conjunciones/index.md):

```prolog
?- padres(Padres).
Padres = [juan, pedro].
```

`setof(P, H^padre(P, H), Padres)` reúne los padres —con `H^` para que los hijos
no agrupen—, los ordena y deja juan una sola vez.

| | Variables libres del objetivo | Sin respuestas | Orden | Repetidos |
|---|---|---|---|---|
| `findall/3` | se ignoran | lista vacía | el de las respuestas | se conservan |
| `bagof/3` | agrupan, salvo las marcadas con `^` | falla | el de las respuestas | se conservan |
| `setof/3` | agrupan, salvo las marcadas con `^` | falla | orden estándar | se eliminan |

Cuando la lista ya está reunida, `sort/2` la ordena en el mismo orden estándar
y elimina los repetidos: `sort([c, a, b, a], L)` da `L = [a, b, c]`. `findall/3`
seguido de `sort/2` da la lista de `setof/3` cuando no hay variables libres que
agrupen, con una diferencia: sin respuestas da la lista vacía en lugar de
fallar. El orden estándar entre términos de distinto tipo, y las otras formas
de ordenar, son del [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md).

!!! question "Actividad"
    Predecir y comprobar: `bagof(H, padre(P, H), L).` ·
    `bagof(H, P^padre(P, H), L).` · `setof(H-P, padre(P, H), L).` ·
    `findall(P, padre(P, _), L).` ¿Cuántas respuestas tiene cada una, y por qué?

## 17.4 Cuando no hay respuestas

La diferencia entre `findall/3` y `bagof/3` ante un objetivo sin respuestas no
es un detalle: decide qué responde el predicado que los usa.

```prolog
?- findall(H, padre(ana, H), L).
L = [].

?- bagof(H, padre(ana, H), L).
false.
```

`findall/3` afirma «la lista de los hijos de ana es vacía»; `bagof/3`, «no hay
ninguna lista de hijos de ana». Para `cuantos_hijos/2`, la primera es la
correcta: ana tiene 0 hijos, y el predicado debe responderlo. Para una pregunta
como «para cada padre, sus hijos», la segunda: ana no es padre, y no debe
aparecer.

El criterio C2 exige que esa decisión sea explícita. Un informe que falla cuando
no hay datos puede leerse como «no existe», cuando la respuesta correcta era
«cero» o «ninguno». La regla práctica: `findall/3` cuando la lista vacía es una
respuesta válida; `bagof/3` o `setof/3` cuando no lo es, o cuando se necesita
agrupar. `no_tiene_hijos/1` usa el primer caso a su favor —una persona sin hijos
es aquella cuya lista de hijos es vacía—, y así cierra el
[ejercicio 9 del capítulo 10](../capitulo-10-negacion-como-falla/soluciones.md#9) sin `\+` y sin repetir los datos:

<!-- ejemplo: capitulo-17/todas.pl predicado: no_tiene_hijos/1 consulta: no_tiene_hijos(Quien). -->
```prolog
%!  no_tiene_hijos(?P) is nondet.
%
%   P es una persona sin hijos: la lista de sus hijos está vacía. Sin \+ y
%   sin repetir los datos en una lista.
no_tiene_hijos(P) :-
    persona(P),
    findall(H, padre(P, H), []).
```

!!! example "Patrón 11 — Reunir y después procesar"
    **Problema.** Un cálculo necesita todas las respuestas de un objetivo a la
    vez: su cantidad, su orden, compararlas entre sí.

    **Versión ingenua.** Repetir los datos en una lista escrita a mano, como en
    la [sección 10.8](../capitulo-10-negacion-como-falla/index.md#108-prescindir-de), o recorrer las respuestas con un bucle por falla, que no
    puede construir un resultado.

    **Patrón.** `findall/3` (o `setof/3`, si hacen falta orden y unicidad) para
    obtener la lista, y después un predicado de listas del [capítulo 7](../capitulo-07-listas/index.md) para
    procesarla.

    **Cuándo no usarlo.** Cuando el cálculo es un conteo, una suma o un máximo:
    `aggregate_all/3` lo hace sin construir la lista ([Patrón 12](../patrones.md#12-contar-y-agregar-sin-recorrer)).

## 17.5 `aggregate_all/3`

Muchas veces la lista es solo un paso intermedio: se la construye para contar
sus elementos o sumarlos. `aggregate_all(Operacion, Objetivo, Resultado)`
recorre las respuestas y calcula el resultado directamente. Las operaciones más
usadas son `count`, `sum(Expresion)`, `max(Expresion)`, `min(Expresion)`,
`bag(Plantilla)` y `set(Plantilla)`:

```prolog
?- aggregate_all(count, padre(juan, _), N).
N = 2.

?- aggregate_all(sum(E), edad(_, E), S).
S = 168.

?- aggregate_all(max(E), edad(_, E), M).
M = 68.
```

`max(Expresion, Testigo)` da además quién alcanza el máximo. Es la otra forma de
`mayor_edad/1` de la [sección 10.7](../capitulo-10-negacion-como-falla/index.md#107-obtener-una-respuesta-por-negacion), sin negación:

<!-- ejemplo: capitulo-17/agregados.pl predicado: mayor_edad/2 edad_promedio/1 consulta: mayor_edad(Quien, Edad). -->
```prolog
%!  mayor_edad(-Quien, -Edad:integer) is semidet.
%
%   Quien tiene la mayor edad de la base, Edad. Con empate, la primera
%   persona. Falla si no hay ninguna edad registrada.
mayor_edad(Quien, Edad) :-
    aggregate_all(max(E, P), edad(P, E), max(Edad, Quien)).

%!  edad_promedio(-Promedio:number) is semidet.
%
%   Promedio es el promedio de las edades de la base. Falla si no hay
%   ninguna: el promedio de ninguna edad no existe.
edad_promedio(Promedio) :-
    aggregate_all(count, edad(_, _), Cantidad),
    Cantidad > 0,
    aggregate_all(sum(E), edad(_, E), Suma),
    Promedio is Suma / Cantidad.
```

```prolog
?- mayor_edad(Quien, Edad).
Quien = juan,
Edad = 68.
```

Ante un objetivo sin respuestas, `count` da 0 y `sum` da 0, pero `max` y `min`
**fallan**: el máximo de ningún valor no existe. Por eso `edad_promedio/1`
cuenta primero y solo divide si hay al menos una edad; sin esa comprobación,
una base vacía produciría una división por cero.

Si la lista ya está reunida, `max_member/2` y `min_member/2`, de
`library(lists)`, dan su mayor y su menor elemento en el orden estándar:
`max_member(M, [3, 8, 5])` da `M = 8`. Con una lista vacía, también fallan.

`library(aggregate)` ofrece además `aggregate/3`, que agrupa por las variables
libres como `bagof/3`: `aggregate(count, H^padre(P, H), N)` responde la cantidad
de hijos de cada padre.

!!! example "Patrón 12 — Contar y agregar sin recorrer"
    **Problema.** Es necesario contar, sumar o encontrar el máximo de las
    respuestas de un objetivo.

    **Versión ingenua.** Reunir las respuestas con `findall/3` y recorrer la
    lista con un acumulador, o escribir la recursión que cuenta.

    **Patrón.** `aggregate_all(count, …)`, `aggregate_all(sum(E), …)`,
    `aggregate_all(max(E, Testigo), …)`, comprobando antes el caso sin
    respuestas cuando la operación no lo admite.

    **Cuándo no usarlo.** Cuando el resultado es la lista misma, o cuando hay
    que agrupar por una variable: `bagof/3`, `setof/3` o `aggregate/3`.

## 17.6 `forall/2`

`forall(Condicion, Accion)` se cumple si **toda** respuesta de `Condicion`
cumple `Accion`. Es la forma directa de «para todos» que el [capítulo 10](../capitulo-10-negacion-como-falla/index.md)
anticipaba:

<!-- ejemplo: capitulo-17/agregados.pl predicado: todos_los_hijos_son_menores/1 consulta: todos_los_hijos_son_menores(pedro). -->
```prolog
%!  todos_los_hijos_son_menores(+P) is semidet.
%
%   Todos los hijos de P son menores de 18 años. Se cumple también si P no
%   tiene hijos: no hay ninguno que no lo sea.
todos_los_hijos_son_menores(P) :-
    forall(padre(P, H),
           ( edad(H, E),
             E < 18 )).
```

`forall(C, A)` es `\+ (C, \+ A)`: no existe una respuesta de `C` para la que `A`
no se cumpla. Por eso comparte las propiedades de `\+`: no liga ninguna
variable, y es una comprobación, no un generador. Y por eso se cumple cuando `C`
no tiene respuestas: `todos_los_hijos_son_menores(ana)` responde `true.`, porque
ana no tiene ningún hijo que no sea menor. Es la verdad vacía de la
[plantilla 11](../plantillas.md#11-todos-los-elementos-cumplen), y el encabezado debe decirlo cuando importa.

`forall/2` es también la forma declarativa del bucle por falla de la
[sección 15.7](../capitulo-15-control/index.md#157-bucles-por-falla): `forall(edad(P, A), format("~w: ~d~n", [P, A]))` escribe todas
las edades, y se cumple al terminar.

!!! example "Patrón 13 — Comprobar para todos"
    **Problema.** Es necesario verificar que todas las respuestas de un
    objetivo cumplen una condición.

    **Versión ingenua.** Una recursión sobre una lista de los datos, o la doble
    negación escrita a mano: `\+ (C, \+ A)`.

    **Patrón.** `forall(Condicion, Accion)`, con las variables de `Condicion`
    ligadas en ella y usadas en `Accion`.

    **Cuándo no usarlo.** Cuando se necesita saber **cuál** no cumple:
    `forall/2` solo responde sí o no. En ese caso, se busca el contraejemplo con
    un objetivo que lo genere, como las pruebas de datos del capítulo 13.

## 17.7 `library(solution_sequences)`

Algunas operaciones sobre las respuestas no requieren reunirlas: basta con
filtrar o reordenar la secuencia en la que llegan. `library(solution_sequences)`
las ofrece como predicados que envuelven un objetivo:

- `distinct(Plantilla, Objetivo)` descarta las respuestas repetidas;
- `limit(N, Objetivo)` entrega solo las primeras `N`;
- `offset(N, Objetivo)` descarta las primeras `N`;
- `order_by([asc(X)], Objetivo)` y `order_by([desc(X)], Objetivo)` entregan las
  respuestas ordenadas por `X`.

<!-- ejemplo: capitulo-17/agregados.pl predicado: de_mayor_a_menor/2 los_dos_mayores/2 consulta: los_dos_mayores(P, E). -->
```prolog
%!  de_mayor_a_menor(-P, -E:integer) is multi.
%
%   Las personas de la base, de la mayor a la menor edad.
de_mayor_a_menor(P, E) :-
    order_by([desc(E)], edad(P, E)).

%!  los_dos_mayores(-P, -E:integer) is nondet.
%
%   Las dos personas de mayor edad, de la mayor a la menor.
los_dos_mayores(P, E) :-
    limit(2, de_mayor_a_menor(P, E)).
```

```prolog
?- los_dos_mayores(P, E).
P = juan,
E = 68 ;
P = ana,
E = 41.
```

A diferencia de `findall/3`, estos predicados siguen entregando las respuestas
de a una: se combinan entre sí, y con `findall/3` cuando se quiere la lista.
`order_by/2` necesita obtener todas las respuestas para ordenarlas, pero
`limit/2` y `distinct/2` trabajan sobre la marcha.

## 17.8 Lo que ahora se puede escribir

Con los predicados de este capítulo se cierran varias preguntas de la parte I:

| Pregunta | Capítulo | Ahora |
|---|---|---|
| Eliminar las respuestas repetidas de `es_padre/1` | [3](../capitulo-03-reglas-y-conjunciones/index.md) | `setof(P, H^padre(P, H), Padres)` o `distinct(P, padre(P, _))` |
| Cuántos hijos tiene una persona | [6](../capitulo-06-recursion/index.md) | `findall/3` y `length/2`, o `aggregate_all(count, …)` |
| Reunir en una lista las respuestas de una consulta | [7](../capitulo-07-listas/index.md) | `findall/3` |
| `no_tiene_hijos/1` sin `\+` ni datos repetidos | [10](../capitulo-10-negacion-como-falla/index.md) | la lista de hijos vacía, con `findall/3` |
| El máximo sin negación | [10](../capitulo-10-negacion-como-falla/index.md) | `aggregate_all(max(E, P), …)` |
| «Para todos» sin los problemas de `\+` | [10](../capitulo-10-negacion-como-falla/index.md) | `forall/2` |
| Quitar repetidos conservando la primera aparición | [9](../capitulo-09-backtracking-y-corte/index.md) | `list_to_set/2`, de `library(lists)` |

## 17.9 El proyecto: los informes

La versión de *Inscripciones* de este capítulo agrega los informes: los
inscriptos de una materia, los alumnos sin ninguna nota, el promedio de una
materia y de un alumno, y los mejores promedios.

<!-- ejemplo: capitulo-17/inscripciones.pl predicado: inscriptos/2 sin_notas/1 promedio_de_materia/2 promedio_de_alumno/2 mejores/2 consulta: mejores(3, Ranking). -->
```prolog
%!  inscriptos(+Materia:atom, -Legajos:list(integer)) is det.
%
%   Legajos son los alumnos inscriptos en Materia, en orden y sin repetidos;
%   la lista vacía si no hay ninguno.
inscriptos(Materia, Legajos) :-
    findall(Legajo, inscripcion(Legajo, Materia, _), Todos),
    sort(Todos, Legajos).

%!  sin_notas(-Legajos:list(integer)) is det.
%
%   Legajos son los alumnos que no tienen ninguna nota: los que no se
%   inscribieron en nada y los que solo están cursando.
sin_notas(Legajos) :-
    findall(Legajo,
            ( alumno(Legajo, _, _, _),
              \+ inscripcion(Legajo, _, nota(_)) ),
            Legajos).

%!  promedio_de_materia(+Materia:atom, -Promedio:number) is semidet.
%
%   Promedio es el promedio de las notas de Materia. Falla si la materia no
%   tiene ninguna nota.
promedio_de_materia(Materia, Promedio) :-
    aggregate_all(count, inscripcion(_, Materia, nota(_)), Cantidad),
    Cantidad > 0,
    aggregate_all(sum(N), inscripcion(_, Materia, nota(N)), Suma),
    Promedio is Suma / Cantidad.

%!  promedio_de_alumno(?Legajo:integer, -Promedio:number) is nondet.
%
%   Promedio es el promedio de las notas del alumno Legajo, para cada alumno
%   con al menos una nota.
promedio_de_alumno(Legajo, Promedio) :-
    alumno(Legajo, _, _, _),
    aggregate_all(count, inscripcion(Legajo, _, nota(_)), Cantidad),
    Cantidad > 0,
    aggregate_all(sum(N), inscripcion(Legajo, _, nota(N)), Suma),
    Promedio is Suma / Cantidad.

%!  mejores(+Cantidad:integer, -Ranking:list(pair)) is det.
%
%   Ranking es la lista de los Cantidad mejores promedios, de mayor a menor,
%   como pares Legajo-Promedio.
mejores(Cantidad, Ranking) :-
    findall(Legajo-Promedio,
            limit(Cantidad,
                  order_by([desc(Promedio)],
                           promedio_de_alumno(Legajo, Promedio))),
            Ranking).
```

```prolog
?- inscriptos(am1, L).
L = [101, 102, 103, 105, 106].

?- sin_notas(L).
L = [105, 107].

?- promedio_de_materia(am1, P).
P = 6.25.

?- mejores(3, R).
R = [101-8.5, 104-8, 103-6].
```

Cada informe decide qué hacer cuando no hay datos. `inscriptos/2` y
`sin_notas/1` usan `findall/3`: una materia sin inscriptos tiene una lista
vacía, y el informe lo dice. `promedio_de_materia/2` falla con una materia sin
notas, porque el promedio de ninguna nota no existe, y su encabezado lo
declara. `mejores/2` combina `order_by/2` para ordenar, `limit/2` para quedarse
con los primeros, y `findall/3` para entregar la lista.

!!! success "Criterios de calidad"
    | Criterio | En los informes |
    |---|---|
    | C2 | el caso sin datos está decidido y declarado: lista vacía en `inscriptos/2` y `sin_notas/1`; falla declarada en `promedio_de_materia/2`, con una prueba que lo verifica (`promedio_de_una_materia_sin_notas`) |
    | C4 | `inscriptos/2`, `sin_notas/1` y `mejores/2` son `det`: `findall/3` se cumple exactamente una vez, y sus pruebas no declaran `nondet` |
    | C7 | 32 pruebas en `inscripciones.plt`, siete de ellas de los informes |

## 17.10 Buscaminas: las minas alrededor de una celda

El Buscaminas es el ejemplo de la parte II en el que se aplican los patrones de
varios capítulos, y su versión completa está en el [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md). El número que
el juego muestra en una celda es la cantidad de minas en sus ocho vecinas: una
cuenta sobre las respuestas de un objetivo, el Patrón 12.

<!-- ejemplo: capitulo-17/buscaminas.pl predicado: tamanio/2 mina/2 vecina/4 minas_alrededor/3 consulta: minas_alrededor(2, 2, N). -->
```prolog
% tamanio(Filas, Columnas): las dimensiones del tablero.
tamanio(5, 5).

% mina(Fila, Columna): hay una mina en esa celda.
mina(1, 1).
mina(2, 3).
mina(4, 2).
mina(4, 5).

%!  vecina(+F:integer, +C:integer, -VF:integer, -VC:integer) is nondet.
%
%   (VF, VC) es una de las celdas vecinas de (F, C), dentro del tablero: las
%   ocho que la rodean, o menos en los bordes.
vecina(F, C, VF, VC) :-
    tamanio(Filas, Columnas),
    between(-1, 1, DF),
    between(-1, 1, DC),
    ( DF, DC ) \== ( 0, 0 ),
    VF is F + DF,
    VC is C + DC,
    between(1, Filas, VF),
    between(1, Columnas, VC).

%!  minas_alrededor(+F:integer, +C:integer, -N:integer) is det.
%
%   N es la cantidad de minas en las celdas vecinas de (F, C).
minas_alrededor(F, C, N) :-
    aggregate_all(count, ( vecina(F, C, VF, VC), mina(VF, VC) ), N).
```

```prolog
?- minas_alrededor(2, 2, N).
N = 2.
```

`vecina/4` genera las vecinas de una celda con `between/3` —un desplazamiento
de −1 a 1 en cada dirección, salvo el propio lugar—, y descarta las que quedan
fuera del tablero. `minas_alrededor/3` cuenta las que tienen mina, sin
construir la lista de vecinas.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir la respuesta de cada consulta: `findall(X, member(X, [c, a,
   b, a]), L).` · `setof(X, member(X, [c, a, b, a]), L).` ·
   `bagof(X, member(X, []), L).` · `findall(X-Y, member(X-Y, [1-a, 2-b]), L).`
2. **(1)** Escribir `nietos_de(Abuelo, Nietos)` con `findall/3`.
3. ★ **(2)** Escribir `abuelos_con_nietos(Abuelo, Nietos)` que dé una respuesta
   por cada abuelo con la lista de sus nietos, con `bagof/3`. ¿Qué cambia si se
   usa `findall/3`?
4. **(2)** Escribir `edades_ordenadas(L)`: la lista de las edades de la base,
   ordenada y sin repetidos, primero con `setof/3` y después con `findall/3` y
   `sort/2`.
5. ★ **(2)** Escribir `materia_de_anio(Anio, Materias)`, el ejercicio 14 del
   [capítulo 14](../capitulo-14-estilo-y-documentacion/index.md), con su encabezado y las pruebas que ese ejercicio pedía.
6. **(2)** Escribir `requisitos_faltantes/3` de la [solución 11 del capítulo 15](../capitulo-15-control/soluciones.md#11)
   sin la tabla `requisitos/2`.
7. ★ **(2)** Escribir `menor_edad(Quien, Edad)` con `aggregate_all/3` y
   `mayor_edad_2(Quien, Edad)` con `findall/3` y `max_member/2`. ¿Qué responde
   cada uno si hay dos personas con la edad máxima?
8. **(2)** Escribir una prueba de datos para `inscripciones.plt` que falle si
   hay dos inscripciones idénticas, la que el [ejercicio 11 del capítulo 13](../capitulo-13-el-entorno-de-trabajo/soluciones.md#11) no
   podía escribir.
9. ★ **(2)** Escribir `todos_aprobados(Legajo)`: el alumno aprobó todas las
   materias en las que se inscribió. ¿Qué responde con un alumno que no se
   inscribió en nada, y es lo que corresponde?
10. **(2)** Escribir `cantidad_por_materia(Materia, N)`, una respuesta por
    materia con la cantidad de inscriptos, con `aggregate/3`.
11. ★ **(2)** Escribir `mejor_de_materia(Materia, Legajo, Nota)`: el alumno con
    la nota más alta de la materia. Compararlo con `mejor_de/2` del ejercicio 16
    del capítulo 10.
12. **(1)** ¿Qué responde `forall(member(X, []), X > 0).`? ¿Y
    `forall(member(X, [1, -1]), X > 0).`?
13. **(2)** Escribir `listar_inscriptos(Materia)`, que escribe una línea por
    alumno inscripto con su nombre, con `forall/2`.
14. ★ **(3)** Escribir `tablero_texto(Lineas)` para el Buscaminas: una lista de
    cinco cadenas, una por fila, con `*` en las minas y el número de minas
    vecinas en las demás celdas.
15. **(3)** Escribir `los_mejores_de_cada_carrera(Carrera, Legajo)`: para cada
    carrera, el alumno de mejor promedio. ¿Qué combinación de los predicados
    del capítulo hace falta?
16. **(3)** `mejores/2` usa `order_by/2`. Escribir la misma consulta con
    `findall/3`, `sort/4` y un predicado que tome los primeros `N` elementos, y
    comparar las dos con 5 000 alumnos generados como en el capítulo 16.

## Resumen

| | |
|---|---|
| `findall/3` | todas las respuestas en una lista; la lista vacía si no hay ninguna |
| `bagof/3` | como `findall/3`, agrupando por las variables libres; falla sin respuestas |
| `setof/3` | como `bagof/3`, ordenada y sin repetidos |
| `sort/2` | una lista ordenada en el orden estándar y sin repetidos |
| `Var^Objetivo` | la variable no agrupa: «existe un Var tal que…» |
| `aggregate_all/3` | `count`, `sum`, `max`, `min`, `bag`, `set` sin construir la lista |
| `aggregate/3` | como `aggregate_all/3`, agrupando por las variables libres |
| `max_member/2`, `min_member/2` | el mayor y el menor elemento de una lista, en el orden estándar |
| `forall/2` | todas las respuestas de la condición cumplen la acción; se cumple sin respuestas |
| `distinct/2`, `limit/2`, `offset/2`, `order_by/2` | filtran y ordenan la secuencia de respuestas |
| caso sin respuestas | decidirlo y declararlo: lista vacía, cero o falla |
| **Patrones 11, 12, 13** | reunir y después procesar; contar y agregar sin recorrer; comprobar para todos |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| `maplist/3`, `foldl/4` e `include/3` sobre las listas reunidas | [capítulo 18](../capitulo-18-orden-superior/index.md) |
| El agente del mundo del Wumpus, que usa `forall/2` y `aggregate_all/3` | [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md) |
| El orden estándar, `sort/4` y los pares | [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md) |
| El Buscaminas: descubrir una región | [capítulo 18](../capitulo-18-orden-superior/index.md) |
| Tabulación: reunir respuestas de relaciones recursivas sin repetirlas | [capítulo 38](../capitulo-38-tabulacion/index.md) |
| Consultas de SQL con `GROUP BY` y funciones de agregación | [capítulo 40](../capitulo-40-prolog-y-sql/index.md) |
