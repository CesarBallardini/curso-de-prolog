# Capítulo 18 — Orden superior

Los recorridos de listas de la parte I tienen siempre la misma forma: un caso
para la lista vacía, un caso para el primer elemento y la llamada recursiva
sobre el resto. De un predicado a otro cambia solo lo que se hace con cada
elemento. Un programa profesional no repite esa forma en cada predicado: la
escribe una vez, en un predicado que recibe como argumento **qué hacer** con
cada elemento.

Este capítulo presenta los predicados que reciben otros predicados —`call/N`,
`maplist/2..5`, `foldl/4..6`, `include/3` y los demás de `library(apply)`—, las
lambdas de `library(yall)`, y la forma de escribir y declarar un predicado
propio de ese tipo, junto con los casos en los que una recursión escrita a
mano sigue siendo preferible. El proyecto reescribe sus informes con un
predicado genérico, y el Buscaminas descubre una región del tablero.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- pasar un predicado como argumento y llamarlo con `call/N`;
- recorrer, plegar y filtrar listas con `maplist`, `foldl`, `include`,
  `exclude`, `partition` y `convlist`, y escribir una lambda con `yall`;
- escribir un predicado de orden superior propio, con su encabezado y su
  declaración `meta_predicate`;
- decidir cuándo una recursión escrita a mano es preferible al orden
  superior.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:28 h**.
    Resolver los 6 ejercicios marcados con ★: **1:53 h**.
    Resolver los 12 ejercicios del final: **3:34 h**.

## 18.1 Un predicado como argumento

`call/1` ejecuta un término como objetivo: `call(padre(juan, H))` es lo mismo
que `padre(juan, H)`. `call/N`, con más argumentos, **agrega** los argumentos
restantes al final del término antes de ejecutarlo:

<!-- ejemplo: capitulo-18/aplicar.pl predicado: mayor_de_edad/1 menor_de_edad/1 cumplen/2 consulta: cumplen(mayor_de_edad, Personas). -->
```prolog
%!  mayor_de_edad(?P) is nondet.
%
%   P tiene 18 años o más.
mayor_de_edad(P) :-
    edad(P, E),
    E >= 18.

%!  menor_de_edad(?P) is nondet.
%
%   P tiene menos de 18 años.
menor_de_edad(P) :-
    edad(P, E),
    E < 18.

%!  cumplen(:Condicion, -Personas:list) is det.
%
%   Personas son las personas de la base que cumplen Condicion, un predicado
%   de un argumento.
cumplen(Condicion, Personas) :-
    findall(P, ( edad(P, _), call(Condicion, P) ), Personas).
```

```prolog
?- call(padre, juan, H).
H = ana ;
H = pedro.

?- G = padre(juan), call(G, H).
G = padre(juan),
H = ana ;
G = padre(juan),
H = pedro.

?- cumplen(mayor_de_edad, L).
L = [juan, ana, pedro].

?- cumplen(menor_de_edad, L).
L = [luis, eva].
```

`call(padre, juan, H)` construye `padre(juan, H)` y lo ejecuta.
`call(padre(juan), H)` hace lo mismo a partir de un objetivo **incompleto**, al
que le falta el último argumento. Ese objetivo incompleto se llama **clausura**:
un predicado con algunos de sus argumentos ya fijados, que `call/N` completa.

`cumplen/2` recibe una clausura de un argumento y la aplica a cada persona. Un
mismo predicado responde dos preguntas distintas según el argumento que recibe:
eso es un predicado de **orden superior**. En su encabezado, el modo `:` de la
[sección 14.3](../capitulo-14-estilo-y-documentacion/index.md#143-el-encabezado-completo) indica que `Condicion` no es un dato sino algo que se va a
llamar.

## 18.2 `maplist/2..5`

`maplist/2` aplica una clausura a cada elemento de una lista, y se cumple si se
cumple para todos. `maplist/3` relaciona los elementos de dos listas, uno a uno,
y `maplist/4` y `maplist/5` hacen lo mismo con tres y cuatro listas. Tres de las
plantillas de recorrido de la parte I se escriben con una línea cada una:

| Plantilla | Con `maplist` |
|---|---|
| [9 — Recorrer una lista](../plantillas.md#9-recorrer-una-lista), procesando cada elemento | `maplist(procesar, L)` |
| [11 — Todos los elementos cumplen](../plantillas.md#11-todos-los-elementos-cumplen) | `maplist(cumple, L)` |
| [12 — Construir una lista durante el recorrido de otra](../plantillas.md#12-construir-una-lista-durante-el-recorrido-de-otra) | `maplist(relacionar, L, R)` |

<!-- ejemplo: capitulo-18/aplicar.pl predicado: edades/2 mostrar_edades/1 mostrar_edad/1 consulta: edades([juan, ana, eva], Edades). -->
```prolog
%!  edades(?Personas:list, ?Edades:list(integer)) is nondet.
%
%   Edades son las edades de Personas, en el mismo orden. Con Personas
%   ligada hay una respuesta.
edades(Personas, Edades) :-
    maplist(edad, Personas, Edades).

%!  mostrar_edades(+Personas:list) is semidet.
%
%   Escribe una línea por persona, con su edad. Falla, después de escribir las
%   anteriores, en la primera persona sin edad registrada.
mostrar_edades(Personas) :-
    maplist(mostrar_edad, Personas).

%!  mostrar_edad(+P) is semidet.
%
%   Escribe el nombre y la edad de P. Falla si P no tiene edad registrada.
mostrar_edad(P) :-
    edad(P, E),
    format("~w: ~d~n", [P, E]).
```

```prolog
?- edades([juan, ana, eva], Edades).
Edades = [68, 41, 8].

?- edades(Personas, [41, 8]).
Personas = [ana, eva].

?- maplist(mayor_de_edad, [juan, eva]).
false.

?- mostrar_edades([juan, eva]).
juan: 68
eva: 8
true.

?- maplist(plus, [1, 2], [10, 20], L).
L = [11, 22].
```

`maplist/3` es una relación, no una función: conserva los modos de la clausura.
`edad/2` responde en los dos sentidos, y por eso `edades/2` también: de las
personas a las edades, y de las edades a las personas. Con `maplist/2`, la
lista vacía cumple la condición —«todos los elementos de ninguno» es cierto—,
como en la plantilla 11.

!!! example "Patrón 14 — Recorrido con `maplist`"
    **Problema.** Hay que aplicar la misma relación a cada elemento de una o
    varias listas: comprobar, transformar o procesar cada uno.

    **Versión ingenua.** Una recursión escrita a mano, con su caso base y su
    caso recursivo, que repite la forma de la plantilla en cada predicado.

    **Patrón.** `maplist(Relacion, L1, …)`, con `Relacion` un predicado con
    nombre y encabezado propio, o una clausura que fija sus primeros
    argumentos.

    **Cuándo no usarlo.** Cuando el recorrido debe detenerse en el primer
    elemento que cumple una condición ([plantilla 10](../plantillas.md#10-buscar-un-elemento-que-cumple-una-condicion)), cuando un elemento
    depende de los anteriores ([Patrón 15](../patrones.md#15-plegado-con-foldl)), o cuando el resultado no tiene un
    elemento por cada elemento de la entrada ([sección 18.4](#184-include3-exclude3-partition4-convlist3)).

## 18.3 `foldl/4..6`

`foldl(Paso, Lista, V0, V)` recorre `Lista` de izquierda a derecha y lleva un
valor acumulado: empieza en `V0`, y en cada elemento `X` llama
`call(Paso, X, Antes, Despues)`. `V` es el valor después del último elemento.
Es la [plantilla 13, el acumulador](../plantillas.md#13-acumulador), con el paso como argumento:

<!-- ejemplo: capitulo-18/aplicar.pl predicado: suma_de_edades/2 sumar/3 mayor/2 el_mayor/3 consulta: suma_de_edades([juan, ana, eva], Suma). -->
```prolog
%!  suma_de_edades(+Personas:list, -Suma:integer) is semidet.
%
%   Suma es la suma de las edades de Personas.
suma_de_edades(Personas, Suma) :-
    edades(Personas, Edades),
    foldl(sumar, Edades, 0, Suma).

%!  sumar(+X:number, +Hasta:number, -Total:number) is det.
%
%   Total es Hasta más X: el paso de foldl/4 recibe primero el elemento y
%   después el valor acumulado.
sumar(X, Hasta, Total) :-
    Total is Hasta + X.

%!  mayor(+L:list(number), -Mayor:number) is semidet.
%
%   Mayor es el mayor elemento de L. Falla con la lista vacía, que no tiene
%   mayor elemento.
mayor([Primero|Resto], Mayor) :-
    foldl(el_mayor, Resto, Primero, Mayor).

%!  el_mayor(+X:number, +Hasta:number, -Mayor:number) is det.
%
%   Mayor es el mayor entre X y Hasta.
el_mayor(X, Hasta, Mayor) :-
    Mayor is max(X, Hasta).
```

```prolog
?- suma_de_edades([juan, ana, eva], S).
S = 117.

?- mayor([3, 9, 2], M).
M = 9.

?- mayor([], M).
false.
```

El orden de los argumentos del paso es fijo: primero el elemento, después el
valor anterior, al final el nuevo. Un paso escrito con otro orden produce un
resultado incorrecto sin ningún error cuando la operación no es conmutativa.

El valor inicial decide qué pasa con la lista vacía. `suma_de_edades([], S)`
responde `S = 0`, la suma de ninguna edad. `mayor/2` no tiene un valor inicial
que sirva para todas las listas: toma el primer elemento, y por eso falla con
la lista vacía, como el máximo de `aggregate_all/3` en la
[sección 17.5](../capitulo-17-todas-las-soluciones/index.md#175-aggregate_all3).

!!! example "Patrón 15 — Plegado con `foldl`"
    **Problema.** Hay que construir un valor a partir de todos los elementos de
    una lista, en un solo recorrido: una suma, un máximo, varios valores a la
    vez.

    **Versión ingenua.** Un predicado auxiliar con acumulador escrito a mano
    ([plantilla 13](../plantillas.md#13-acumulador)), o varios recorridos, uno por valor.

    **Patrón.** `foldl(Paso, Lista, Inicial, Final)`, con `Paso(X, Antes,
    Despues)`. Si hacen falta varios valores, el acumulado es un término que
    los reúne, como el par `Cantidad-Suma` de la [sección 18.8](#188-el-proyecto-informes-genericos). Si el
    recorrido también produce una lista, con un elemento por cada elemento de
    la entrada, `foldl/6` ([sección 18.7](#187-cuando-no-usar-el-orden-superior)).

    **Cuándo no usarlo.** Cuando la biblioteca ya tiene el predicado:
    `sum_list/2`, `max_list/2`, `length/2`. Y cuando los valores vienen de las
    respuestas de un objetivo y no de una lista: `aggregate_all/3` ([Patrón 12](../patrones.md#12-contar-y-agregar-sin-recorrer)).

## 18.4 `include/3`, `exclude/3`, `partition/4`, `convlist/3`

Cuatro predicados de `library(apply)` producen una lista que no tiene un
elemento por cada elemento de la entrada:

- `include(Condicion, L, Cumplen)` conserva los que cumplen la condición;
- `exclude(Condicion, L, NoCumplen)` conserva los que no la cumplen;
- `partition(Condicion, L, Cumplen, NoCumplen)` hace las dos cosas a la vez;
- `convlist(Relacion, L, R)` relaciona cada elemento con uno nuevo, como
  `maplist/3`, y omite los elementos para los que la relación falla.

<!-- ejemplo: capitulo-18/aplicar.pl predicado: separar_por_edad/3 edades_conocidas/2 consulta: separar_por_edad([juan, luis, ana, eva], Mayores, Menores). -->
```prolog
%!  separar_por_edad(+Personas:list, -Mayores:list, -Menores:list) is det.
%
%   Mayores son las Personas mayores de edad y Menores las demás, cada una en
%   el orden de Personas.
separar_por_edad(Personas, Mayores, Menores) :-
    partition(mayor_de_edad, Personas, Mayores, Menores).

%!  edades_conocidas(+Personas:list, -Edades:list(integer)) is det.
%
%   Edades son las edades de las Personas que la tienen registrada; las demás
%   se omiten.
edades_conocidas(Personas, Edades) :-
    convlist(edad, Personas, Edades).
```

```prolog
?- include(mayor_de_edad, [juan, luis, ana], L).
L = [juan, ana].

?- exclude(mayor_de_edad, [juan, luis, ana], L).
L = [luis].

?- separar_por_edad([juan, luis, ana, eva], Mayores, Menores).
Mayores = [juan, ana],
Menores = [luis, eva].

?- edades([juan, zoe, eva], E).
false.

?- edades_conocidas([juan, zoe, eva], E).
E = [68, 8].
```

zoe no tiene edad registrada. `maplist/3` falla, porque exige que la relación se
cumpla para todos; `convlist/3` la omite. Elegir entre los dos es decidir qué
significa un elemento sin dato: un error en los datos, o un caso que el
resultado no incluye.

Los cuatro son deterministas: la condición se usa como una prueba, y solo su
primera respuesta cuenta. `include/3` no genera alternativas aunque la
condición tenga varias.

!!! question "Actividad"
    Predecir la respuesta de `include(padre(juan), [ana, luis, pedro], L).` y
    la de `exclude(padre(pedro), [ana, luis, pedro], L).` Después, ejecutarlas.
    ¿Qué argumentos de `padre/2` recibe cada llamada?

## 18.5 Lambdas con `yall`

A veces la clausura que se necesita no existe como predicado: sumar 10 a cada
elemento, o comprobar una edad contra un número que llega como argumento.
Escribir un predicado auxiliar para cada caso es posible, pero aleja el código
del lugar donde se usa. `library(yall)` permite escribirlo en el mismo lugar,
como una **lambda**: `[X, Y]>>Objetivo` es un predicado de dos argumentos, `X` e
`Y`, cuyo cuerpo es `Objetivo`.

<!-- ejemplo: capitulo-18/aplicar.pl predicado: sumar_a_todos/3 mayores_que/3 consulta: sumar_a_todos(10, [1, 2, 3], R). -->
```prolog
%!  sumar_a_todos(+N:number, +L:list(number), -R:list(number)) is det.
%
%   R es la lista de los elementos de L más N. {N} declara que la lambda
%   comparte N con la cláusula.
sumar_a_todos(N, L, R) :-
    maplist({N}/[X, Y]>>(Y is X + N), L, R).

%!  mayores_que(+Umbral:integer, +Personas:list, -Mayores:list) is det.
%
%   Mayores son las Personas cuya edad supera Umbral. Umbral se comparte con
%   la cláusula; E es local a la lambda y toma un valor para cada persona.
mayores_que(Umbral, Personas, Mayores) :-
    include({Umbral}/[P]>>( edad(P, E), E > Umbral ), Personas, Mayores).
```

```prolog
?- sumar_a_todos(10, [1, 2, 3], R).
R = [11, 12, 13].

?- mayores_que(40, [juan, ana, pedro, luis], M).
M = [juan, ana].
```

La forma completa es `{Libres}/[Parametros]>>Objetivo`. Los parámetros, entre
corchetes, reciben los argumentos que agrega `call/N`. Las variables entre
llaves son las que la lambda **comparte** con la cláusula que la contiene. Las
demás variables del cuerpo, como `E` en `mayores_que/3`, son locales: cada
llamada de la lambda trabaja con una copia nueva.

Esa copia es la causa del error más frecuente con las lambdas. Una variable de
la cláusula que no se declara entre llaves y todavía está libre cuando la
lambda se ejecuta no recibe ningún valor desde adentro:

```prolog
?- maplist([X]>>(X = Y), [1, 2]).
true.

?- maplist({Y}/[X]>>(X = Y), [1, 1]).
Y = 1.

?- maplist({Y}/[X]>>(X = Y), [1, 2]).
false.
```

La primera consulta se cumple, aunque no hay ningún `Y` igual a 1 y a 2: cada
llamada ligó una copia distinta de `Y`, y la `Y` de la consulta quedó libre.
Con `{Y}`, las dos llamadas comparten la misma variable, y la consulta responde
lo esperado.

La regla práctica: **toda variable de la cláusula que aparece en la lambda se
declara entre llaves**, aunque la versión sin llaves responda bien mientras la
variable ya está ligada cuando la lambda se copia.

!!! question "Actividad"
    Quitar `{N}` de `sumar_a_todos/3` en `aplicar.pl` y consultar
    `sumar_a_todos(10, [1, 2, 3], R).`: responde bien. Después iniciar
    `swipl -O aplicar.pl` y observar qué informa al cargar el archivo. Explicar
    qué cambia cuando SWI-Prolog compila la lambda al cargar en lugar de
    copiarla en cada llamada, y por qué la regla práctica exige las llaves en
    los dos casos.

!!! question "Actividad"
    Predecir y comprobar: `maplist([X, Y]>>atom_concat(X, '_bis', Y), [a, b], L).`
    · `foldl([X, A0, A]>>(A is A0 * X), [1, 2, 3, 4], 1, P).` · ¿Por qué la
    primera no necesita llaves?

## 18.6 Escribir un predicado de orden superior

Un predicado de orden superior propio se escribe como cualquier recorrido de la
parte I, con la condición como argumento y `call/N` en el lugar donde antes
había un predicado fijo. La primera versión de `cada_uno/2`, que es
`maplist/2`, sigue la [plantilla 11](../plantillas.md#11-todos-los-elementos-cumplen) al pie de la letra:

<!-- ejemplo: capitulo-18/propio.pl predicado: cada_uno_1/2 consulta: cada_uno(mayor_de_edad, [juan, ana]). -->
```prolog
%!  cada_uno_1(:Condicion, +L:list) is semidet.
%
%   Primera versión de cada_uno/2, con la condición como primer argumento.
%   Es correcta, pero en las dos cláusulas el primer argumento es una
%   variable: la indexación no las distingue, y al terminar la lista queda
%   pendiente la segunda cláusula.
cada_uno_1(_, []).
cada_uno_1(Condicion, [X|Resto]) :-
    call(Condicion, X),
    cada_uno_1(Condicion, Resto).
```

Es correcta, pero en sus dos cláusulas el primer argumento es una variable, y
la indexación del [capítulo 16](../capitulo-16-rendimiento/index.md) no puede elegir entre ellas: al llegar a la
lista vacía, la segunda cláusula queda como alternativa pendiente. La versión
definitiva delega el recorrido en un predicado con la **lista primero**, y lo
mismo hace `relacionar/3`, que es `maplist/3`:

<!-- ejemplo: capitulo-18/propio.pl predicado: cada_uno/2 cada_uno_/2 relacionar/3 relacionar_/3 consulta: relacionar(edad, [juan, eva], Edades). -->
```prolog
%!  cada_uno(:Condicion, +L:list) is semidet.
%
%   Todos los elementos de L cumplen Condicion, un predicado de un argumento.
%   Se cumple con la lista vacía.
cada_uno(Condicion, L) :-
    cada_uno_(L, Condicion).

%!  cada_uno_(+L:list, :Condicion) is semidet.
%
%   El recorrido de cada_uno/2, con la lista como primer argumento para que
%   la indexación elija la cláusula.
cada_uno_([], _).
cada_uno_([X|Resto], Condicion) :-
    call(Condicion, X),
    cada_uno_(Resto, Condicion).

%!  relacionar(:Relacion, ?L1:list, ?L2:list) is nondet.
%
%   Cada elemento de L1 está en Relacion con el que ocupa su lugar en L2.
relacionar(Relacion, L1, L2) :-
    relacionar_(L1, L2, Relacion).

%!  relacionar_(?L1:list, ?L2:list, :Relacion) is nondet.
%
%   El recorrido de relacionar/3, con las listas primero.
relacionar_([], [], _).
relacionar_([X|Xs], [Y|Ys], Relacion) :-
    call(Relacion, X, Y),
    relacionar_(Xs, Ys, Relacion).
```

```prolog
?- cada_uno(mayor_de_edad, [juan, ana]).
true.

?- relacionar(edad, [juan, eva], Edades).
Edades = [68, 8].

?- relacionar(edad, Personas, [41, 8]).
Personas = [ana, eva].
```

La indexación distingue `[]` de `[X|Resto]`, y no queda ninguna alternativa.
Es lo que hace `library(apply)`: `maplist/2` llama a un predicado interno cuyo
primer argumento es la lista. Es el [Patrón 9](../patrones.md#9-el-argumento-que-indexa-primero) aplicado a un predicado de orden
superior: el argumento que indexa va primero. Las pruebas lo verifican con
`call_cleanup/2`, que ejecuta su segundo argumento cuando el primero ya no
tiene alternativas; `alternativas/2`, en `propio.plt`, responde `pendientes` o
`ninguna` según ese segundo argumento se haya ejecutado o no:

```prolog
% La primera versión deja una alternativa pendiente; la segunda, no.
test(primera_version, true(R == pendientes)) :-
    alternativas(cada_uno_1(mayor_de_edad, [juan, ana]), R).

test(segunda_version, true(R == ninguna)) :-
    alternativas(cada_uno(mayor_de_edad, [juan, ana]), R).
```

Al principio del archivo, la directiva `meta_predicate` declara qué argumentos
son objetivos:

<!-- ejemplo: capitulo-18/propio.pl fragmento: :- meta_predicate .. cuantos_cumplen(1, +, -). consulta: cada_uno(mayor_de_edad, [juan, ana]). -->
```prolog
:- meta_predicate
    cada_uno_1(1, ?),
    cada_uno(1, ?),
    cada_uno_(?, 1),
    relacionar(2, ?, ?),
    relacionar_(?, ?, 2),
    cuantos_cumplen(1, +, -).
```

Un número indica cuántos argumentos agrega `call/N` a esa clausura (`1` en
`cada_uno/2`, `2` en `relacionar/3`), y `+`, `-` o `?` marcan los argumentos
comunes. Mientras todo el programa está en un solo archivo, la declaración no
cambia el comportamiento: documenta, y la usan las herramientas de
SWI-Prolog. Pasa a ser necesaria cuando el predicado está en un módulo y recibe
una clausura definida en otro, el caso del
[capítulo 24](../capitulo-24-modulos-y-organizacion/index.md). La declaración queda registrada, y
`predicate_property/2`, que el [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md) presenta con los demás predicados que
examinan el programa, la informa:

```prolog
?- predicate_property(cada_uno(_, _), meta_predicate(M)).
M = cada_uno(1, ?).
```

## 18.7 Cuándo no usar el orden superior

`maplist/3` con un predicado con nombre cuesta lo mismo que la recursión
escrita a mano. Con 100 000 elementos, `maplist(doble, L, D)` y la plantilla 12
usan 300 000 inferencias cada uno. Una lambda, en cambio, se copia en cada
llamada: con la misma lista, `maplist([X, Y]>>(Y is 2 * X), L, D)` usa
1 300 000 inferencias y tarda unas diez veces más. `swipl -O` compila las
lambdas y elimina esa diferencia, y `library(apply_macros)`, de la
[sección 16.9](../capitulo-16-rendimiento/index.md#169-libraryapply_macros), expande `maplist/N` en una recursión; con un
predicado con nombre, en SWI-Prolog 9 esa expansión no cambia la cantidad de
inferencias.

```text
?- numlist(1, 100000, L), time(maplist(doble, L, _)).
% 300,000 inferences, 0.016 CPU in 0.012 seconds (126% CPU, 19200000 Lips)

?- numlist(1, 100000, L), time(maplist([X, Y]>>(Y is 2 * X), L, _)).
% 1,300,000 inferences, 0.125 CPU in 0.133 seconds (94% CPU, 10400000 Lips)
```

Además del costo, hay casos en los que el orden superior hace el código menos
claro:

- **Una lambda larga.** Si el cuerpo de la lambda ocupa varias líneas,
  requiere un nombre y un encabezado: un predicado auxiliar con nombre se lee, se prueba
  y se documenta; una lambda no.
- **Un recorrido que se detiene.** `maplist/2` examina todos los elementos.
  Buscar el primero que cumple una condición es la [plantilla 10](../plantillas.md#10-buscar-un-elemento-que-cumple-una-condicion), o
  `memberchk/2`, o `once/1` sobre un generador.
- **Un recorrido que hace varias cosas por elemento.** Tres `maplist` seguidos
  sobre la misma lista recorren la lista tres veces; una recursión, o un
  `foldl/4` con un acumulado compuesto, la recorre una vez.

Cuando el orden superior conviene, la forma del recorrido indica el predicado.
La forma depende de dos preguntas: cuántos elementos tiene el resultado, y si
el resultado de un elemento depende de los anteriores. Elegir la forma de un
recorrido según la operación —mapeo, selección o agregación— y según la
estructura que se recorre es una idea que ya proponen P. Brna y otros,
«Prolog programming techniques», *Instructional Science* 20 (2-3), 1991,
pp. 111–133; la tabla la desarrolla con los predicados de la biblioteca.

| Forma del recorrido | Ejemplo | Predicado |
|---|---|---|
| mapeo completo: un resultado por elemento | las edades de una lista de personas | `maplist/3` |
| mapeo parcial: un resultado para algunos elementos | los mayores de edad; las edades conocidas | `include/3`, `exclude/3`, `convlist/3` |
| salidas disjuntas: cada elemento va a una de dos o tres listas | mayores y menores; menores, iguales y mayores que un valor | `partition/4`, `partition/5` |
| mapeo completo con estado: el resultado de un elemento depende de los anteriores | numerar los elementos | `foldl/6` |
| mapeo secuencial con estado: un resultado por cada racha de elementos iguales consecutivos | `[a, a, b, a]` da `[a-2, b-1, a-1]` | `clumped/2`, que presenta el [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md), o una recursión escrita a mano |
| mapeo disperso con estado: un resultado por valor, que reúne apariciones no consecutivas | la frecuencia de cada elemento | `msort/2` y después `clumped/2`, o `aggregate_all/3` |
| reducción a un valor | la suma, el máximo | `foldl/4` |

`foldl/5` y `foldl/6` recorren dos y tres listas a la vez, como `maplist/3` y
`maplist/4`: el paso recibe un elemento de cada lista, el valor anterior y el
nuevo. Con la última lista libre, `foldl/6` la construye: es un `maplist/3`
que además lleva un estado de un elemento al siguiente. `partition/5` recibe
una relación que responde el orden de cada elemento, `<`, `=` o `>`, como
`compare/3` en el [capítulo 11](../capitulo-11-texto/index.md):

```prolog
?- foldl([X, I-X, I0, I]>>(I is I0 + 1), [a, b, c], L, 0, _).
L = [1-a, 2-b, 3-c].

?- partition([X, O]>>compare(O, X, 5), [7, 5, 2, 9, 5], Menores, Iguales, Mayores).
Menores = [2],
Iguales = [5, 5],
Mayores = [7, 9].
```

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | el modo `:` en cada argumento que se llama (`cumplen/2`, `informe/3`), y la declaración `meta_predicate` que da cuántos argumentos agrega `call/N` |
    | C2 | la lista vacía decidida en cada plegado: `suma_de_edades([], 0)`, `mayor([], _)` falla y lo declara, y `informe/3` con una lista vacía da `[]` (prueba `informe_vacio`) |
    | C4 | los recorridos propios con la lista primero: la prueba `segunda_version` verifica que `cada_uno/2` no deja alternativas; `informe/3` es `det` con clausuras `nondet`, gracias a `once/1` |
    | C7 | 119 pruebas en los cinco archivos del capítulo; las 32 de los informes del [capítulo 17](../capitulo-17-todas-las-soluciones/index.md) pasan sin cambios sobre la versión reescrita |

## 18.8 El proyecto: informes genéricos

La versión de *Inscripciones* de este capítulo reescribe los informes del
[capítulo 17](../capitulo-17-todas-las-soluciones/index.md) con los predicados de este capítulo, y agrega un informe genérico:
`informe/3` aplica a una lista de alumnos **cualquier** cálculo de dos
argumentos, y devuelve una fila por alumno.

<!-- ejemplo: capitulo-18/inscripciones.pl predicado: promedio/2 contar_y_sumar/3 informe/3 consulta: legajos(Ls), informe(promedio_de_alumno, Ls, Filas). -->
```prolog
%!  promedio(+Notas:list(number), -Promedio:number) is semidet.
%
%   Promedio es el promedio de Notas. Falla con la lista vacía. Un solo
%   recorrido cuenta y suma a la vez: el valor acumulado es el par
%   Cantidad-Suma.
promedio(Notas, Promedio) :-
    foldl(contar_y_sumar, Notas, 0-0, Cantidad-Suma),
    Cantidad > 0,
    Promedio is Suma / Cantidad.

%!  contar_y_sumar(+Nota:number, +Hasta:pair, -Total:pair) is det.
%
%   Total es el par Cantidad-Suma de Hasta con Nota agregada.
contar_y_sumar(Nota, Cantidad0-Suma0, Cantidad-Suma) :-
    Cantidad is Cantidad0 + 1,
    Suma is Suma0 + Nota.

%!  informe(:Calculo, +Legajos:list(integer), -Filas:list(pair)) is det.
%
%   Filas tiene un par Legajo-Valor por cada alumno de Legajos para el que
%   call(Calculo, Legajo, Valor) se cumple, con su primer Valor; los demás
%   se omiten.
informe(Calculo, Legajos, Filas) :-
    convlist({Calculo}/[Legajo, Legajo-Valor]>>
                 once(call(Calculo, Legajo, Valor)),
             Legajos, Filas).
```

```prolog
?- legajos(Ls), informe(promedio_de_alumno, Ls, Filas).
Ls = [101, 102, 103, 104, 105, 106, 107],
Filas = [101-8.5, 102-4, 103-6, 104-8, 106-4.5].

?- legajos(Ls), informe(aprobadas, Ls, F), mostrar_informe('Aprobadas', F).
Aprobadas
  101 ana: 4
  102 bruno: 1
  103 carla: 1
  104 diego: 3
  105 elena: 0
  106 facundo: 1
  107 gabriela: 0
Ls = [101, 102, 103, 104, 105, 106, 107],
F = [101-4, 102-1, 103-1, 104-3, 105-0, 106-1, 107-0].
```

`promedio/2` cuenta y suma en un solo recorrido: el valor acumulado de
`foldl/4` es el par `Cantidad-Suma`. `promedio_de_materia/2` y
`promedio_de_alumno/2` reúnen las notas con `findall/3` y llaman a
`promedio/2`. `sin_notas/1` es la lista de todos los legajos (`legajos/1`) sin
los que tienen nota, con `exclude/3`. `aprobadas/2` cuenta las materias
aprobadas, y `mostrar_informe/2` escribe las filas con `maplist/2`. `informe/3` usa `convlist/3`,
y por eso omite los alumnos para los que el cálculo falla: elena y gabriela no
tienen promedio, y no aparecen en el primer informe; con `aprobadas/2`, que
siempre responde, aparecen todos. La lambda de `informe/3` declara `{Calculo}`
entre llaves, según la regla de la [sección 18.5](#185-lambdas-con-yall), y usa `once/1` para que un
cálculo con varias respuestas aporte solo la primera.

Las 32 pruebas del [capítulo 17](../capitulo-17-todas-las-soluciones/index.md) se mantienen sin cambios, y pasan sobre la
versión reescrita: la prueba de que la reescritura no cambió el comportamiento.
Las nueve pruebas nuevas cubren `promedio/2`, `aprobadas/2` e `informe/3`.

## 18.9 Buscaminas: descubrir una región

Al descubrir una celda sin minas vecinas, el Buscaminas descubre también sus
vecinas, y sigue así mientras encuentre celdas sin minas vecinas: un clic puede
descubrir una región entera. El tablero de esta sección tiene seis filas y seis
columnas, con cuatro minas.

<!-- ejemplo: capitulo-18/buscaminas.pl predicado: descubrir/3 consulta: descubrir(1-6, [], D), mostrar(D). -->
```prolog
%!  descubrir(+Celda:pair, +Vistas:list, -Descubiertas:list) is det.
%
%   Descubiertas son las celdas de Vistas más las que descubre un clic en
%   Celda, un par Fila-Columna sin mina: la celda, y si no tiene minas
%   vecinas, las que descubren sus vecinas.
descubrir(F-C, Vistas, Descubiertas) :-
    (   memberchk(F-C, Vistas)
    ->  Descubiertas = Vistas
    ;   minas_alrededor(F, C, 0)
    ->  findall(VF-VC, vecina(F, C, VF, VC), Vecinas),
        foldl(descubrir, Vecinas, [F-C|Vistas], Descubiertas)
    ;   Descubiertas = [F-C|Vistas]
    ).
```

`descubrir/3` recorre la región con `foldl/4`. El valor acumulado es la lista
de celdas ya descubiertas, y cumple dos funciones: es el resultado, y evita
visitar dos veces la misma celda. Si la celda ya está en la lista, no cambia
nada; si no tiene minas vecinas, se agrega y se pliega `descubrir/3` sobre sus
vecinas; si tiene, solo se agrega. El predicado del paso es el mismo
`descubrir/3`: el recorrido es recursivo, y `foldl/4` lleva la lista de una
vecina a la siguiente.

`mostrar/1`, en el mismo archivo, escribe el tablero con dos `maplist`
anidados, uno por las filas y otro por las columnas:

```prolog
?- descubrir(1-6, [], D), mostrar(D).
#10000
#21000
##1111
######
######
######
D = [3-3, 3-4, 3-6, 3-5, 2-6, 2-5, 2-4, 2-3, ... - ...|...].
```

Un clic en la esquina (1, 6) descubre catorce celdas: las que no tienen minas
vecinas y su borde, las que tienen un número. Las celdas con `#` quedan
ocultas. En `mostrar/1`, `maplist(mostrar_fila(Descubiertas), Fs)` usa una
clausura: fija la lista de celdas descubiertas y deja el número de fila como el
argumento que agrega `call/N`.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir la respuesta de cada consulta:
   `maplist(succ, [1, 2, 3], L).` · `maplist(succ, L, [0, 1, 2]).` ·
   `foldl([X, A0, A]>>(A is A0 * X), [1, 2, 3, 4], 1, P).` ·
   `partition([X]>>(X < 3), [3, 1, 4, 1, 5], I, E).`
2. **(1)** Escribir `dobles(L, D)` con `maplist/3` y el predicado `doble/2` del
   [capítulo 8](../capitulo-08-aritmetica/index.md), y `todos_positivos(L)` con `maplist/2`.
3. ★ **(2)** Escribir `largo/2`, `maximo/2` y `dar_vuelta/2` con `foldl/4`.
   ¿Cuál de los tres falla con la lista vacía, y por qué?
4. **(2)** Escribir `conservar(Condicion, L, Cumplen)` y
   `descartar(Condicion, L, NoCumplen)`, que hacen lo mismo que `include/3` y
   `exclude/3`, sin usarlos, con su declaración `meta_predicate`.
5. ★ **(2)** Explicar la respuesta de `maplist([X]>>(X = Y), [a, b]).` y la de
   `maplist({Y}/[X]>>(X = Y), [a, b]).` Después, escribir
   `todos_hijos_de(P, Hijos)`: P es el padre de todos los Hijos, con una
   lambda. ¿Qué responde `todos_hijos_de(P, [ana, luis])` con la lambda sin
   llaves?
6. ★ **(2)** Escribir `mi_foldl/4`, con el mismo comportamiento que `foldl/4`,
   su encabezado completo y su declaración `meta_predicate`. Explicar el modo
   de cada argumento y la determinación.
7. **(2)** Escribir `materias_cursando(Legajo, N)` y usarlo con `informe/3`
   para todos los alumnos. ¿Qué alumnos aparecen, y por qué no ocurre lo mismo
   que con `promedio_de_alumno/2`?
8. **(2)** Usar `informe/3` con la lista de materias y
   `promedio_de_materia/2`. ¿Hace falta cambiar `informe/3`? Escribir
   `mostrar_informe/3`, que recibe además el predicado que da el nombre de
   cada clave, y usarlo con alumnos y con materias.
9. ★ **(3)** Escribir `jugar(Jugadas, Resultado)` para el Buscaminas: aplica
   una lista de clics `Fila-Columna` con `foldl/4`, y el resultado es
   `perdida(Celda)` si un clic cae en una mina, `ganada` si quedan descubiertas
   todas las celdas sin mina, o `en_curso(Descubiertas)`.
10. **(3)** Escribir `descubrir_a_lo_ancho(Celda, Descubiertas)`, que descubre
    la región con una lista de celdas pendientes: primero la celda, después sus
    vecinas, después las vecinas de estas. Comparar el orden y el conjunto de
    celdas con los de `descubrir/3`.
11. ★ **(2)** Escribir `promedios_parciales(Notas, Promedios)` con `foldl/6`:
    el elemento i-ésimo de `Promedios` es el promedio de las i primeras notas
    de `Notas`, y la lista se recorre una sola vez.
    `promedios_parciales([8, 6, 10], P)` responde `P = [8, 7, 8]`. ¿Qué lleva
    el valor acumulado, y por qué no alcanza con llevar el último promedio?
12. **(1)** Escribir `producto_interno(V1, V2, P)` con `foldl/5`: `P` es el
    producto interno de dos vectores representados como listas de números, y
    para `[1, 2, 3]` y `[4, 5, 6]` vale 32. ¿Qué responde con dos listas de
    distinto largo, y es correcta esa respuesta?

## Resumen

| | |
|---|---|
| `call/N` | agrega argumentos a un objetivo y lo ejecuta |
| clausura | un objetivo al que le faltan los últimos argumentos |
| `maplist/2..5` | la misma relación sobre cada elemento de una o varias listas |
| `foldl/4..6` | un valor construido en un recorrido; el paso recibe elemento, anterior, nuevo |
| `include/3`, `exclude/3`, `partition/4` | filtran con una condición |
| `partition/5` | separa en menores, iguales y mayores, según el orden que responde una relación |
| `convlist/3` | como `maplist/3`, omitiendo los elementos para los que falla |
| forma del recorrido | mapeo completo, parcial, con salidas disjuntas, con estado (completo, secuencial o disperso), reducción: la tabla de la [sección 18.7](#187-cuando-no-usar-el-orden-superior) |
| `{Libres}/[Parametros]>>Objetivo` | una lambda de `yall`; las variables compartidas, entre llaves |
| `:- meta_predicate` | qué argumentos se llaman, y con cuántos argumentos agregados |
| cuándo no usarlo | una lambda larga, un recorrido que se detiene, varios recorridos sobre la misma lista |
| **Patrones 14, 15** | recorrido con `maplist`; plegado con `foldl` |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Operadores propios y reglas como datos, con un intérprete que las prueba | [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md) |
| `dcg/high_order`: gramáticas que reciben gramáticas | [capítulo 21](../capitulo-21-gramaticas-dcg/index.md) |
| `clumped/2`: rachas y frecuencias | [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md) |
| El tablero del Buscaminas como `assoc` | [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md) |
| `meta_predicate` y los módulos | [capítulo 24](../capitulo-24-modulos-y-organizacion/index.md) |
| La búsqueda en un espacio de estados con visitados | [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md) |
